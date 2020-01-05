classdef transformer < handle
    properties
       CAPACITY;
       priceRecord; gridPriceRecord24; gridPriceRecord; tielineRecord;
       Tout; mkt;
       theta_h; d_theta_h1; d_theta_h2; theta_o; expectancy; yrs; install_cost; R; x; y; d_theta_or; d_theta_hr; eta_o; eta_w; k11; k21; k22; DL_record;
       pCurve;
       eta; cost;
    end
    methods
        function obj = transformer(d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY, gp, Tout, mkt, eta)
            global I T
            obj.CAPACITY = CAPACITY;
            obj.priceRecord = zeros(1, I);
            gridPriceRecord = zeros(1, I);
            for t_index = 1: I
                gridPriceRecord(t_index) = gp(floor((t_index - 1) * T) + 1);
            end
            obj.gridPriceRecord24 = gp;
            obj.gridPriceRecord = gridPriceRecord;
            
            obj.tielineRecord = zeros(1, I);
            obj.Tout = Tout;
            obj.mkt = mkt;
            obj.pCurve = (obj.mkt(1) : (obj.mkt(2) - obj.mkt(1)) / obj.mkt(3) : obj.mkt(2));
            obj.theta_h =  theta_o + d_theta_h1 - d_theta_h2; 
            obj.d_theta_h1 = d_theta_h1;
            obj.d_theta_h2 = d_theta_h2;
            obj.theta_o = theta_o;
            obj.expectancy = yrs * 365 * 24 * 60;
            obj.yrs = yrs;
            obj.install_cost = obj.CAPACITY * 100; %yuan
            obj.R = 8;
            obj.x = 0.8;
            obj.y = 1.6;
            obj.d_theta_or = 45; %K
            obj.d_theta_hr = 35;
            obj.eta_o = 180; %min
            obj.eta_w = 8;
            obj.k11 = 1;
            obj.k21 = 1;
            obj.k22 = 2;
            obj.DL_record = zeros(1, I);
            obj.eta = eta;
            obj.cost = zeros(1, 2);

        end
        
        function [DL, KR, Tmin, tmp_theta_o, tmp_d_theta_h1, tmp_d_theta_h2 ] = getTheta_h(obj, K, t_index)
            global T;
            Tmin = T * 60;
            theta_a = obj.Tout(t_index);
            d_theta_oi = obj.theta_o - theta_a;
            KR = (1 + K .^ 2 * obj.R) ./ (1 + obj.R);
            % 指数
            tmp_theta_o = theta_a + d_theta_oi + (obj.d_theta_or * (KR .^ obj.x) -d_theta_oi) * (1 - exp(- Tmin / (obj.k11 * obj.eta_o)));
            tmp_d_theta_h1 = obj.d_theta_h1 + (obj.k21 * (K .^ obj.y) * obj.d_theta_hr - obj.d_theta_h1) * (1 - exp(- Tmin / (obj.k22 * obj.eta_w)));
            tmp_d_theta_h2 = obj.d_theta_h2 + ((obj.k21 - 1) * (K .^ obj.y) * obj.d_theta_hr - obj.d_theta_h2) * (1 - exp(- Tmin / (obj.eta_o / obj.k22)));
            
            % 差分
            % ay' + y = b
            a = obj.k11 * obj.eta_o;
            b = obj.d_theta_or * (KR .^ obj.x) + theta_a;
            tmp_theta_o = (1 - Tmin /a) * obj.theta_o + b * Tmin / a;
            
            a = obj.k22 * obj.eta_w;
            b = obj.k21 * K .^ obj.y * obj.d_theta_hr;
            tmp_d_theta_h1 = (1 - Tmin /a) * obj.d_theta_h1 + b * Tmin / a;
            
            a = obj.eta_o / obj.k22;
            b = (obj.k21 -1) * K .^ obj.y * obj.d_theta_hr;
            tmp_d_theta_h2 = (1 - Tmin /a) * obj.d_theta_h2 + b * Tmin / a;

            d_theta_h = tmp_d_theta_h1 - tmp_d_theta_h2;
            tmp_theta_h = tmp_theta_o + d_theta_h;
            DL = 2 .^ ((tmp_theta_h - 98) / 6);%98 for non-thermally updated paper,          
        end
        
        function dC_dP = getDerivative(obj, K, t_index)
            global T;
            [DL, KR, Tmin] = getTheta_h(obj, K, t_index);
            dC_dL = obj.install_cost / obj.expectancy;
            dL_dtheta_h = DL * log(2) / 6;
            dtheta_h_dK =  (1 - exp(- Tmin / (obj.k22 * obj.eta_w))) * obj.d_theta_hr * obj.k21 * obj.y .* K .^(obj.y - 1) + ... %d_theta_h1
                (1 - exp(- Tmin / (obj.eta_o / obj.k22))) * obj.d_theta_hr * (obj.k21 - 1 ) * obj.y .* K .^ (obj.y - 1) + ... %d_theta_h2
                (1 - exp(- Tmin / (obj.eta_o * obj.k11))) * obj.d_theta_or * obj.x .* KR .^ (obj.x - 1) * 2 .* K * obj.R / (1 + obj.R); %theta_o
            dK_dP = 1 / obj.CAPACITY;
            dC_dP = 60 * dC_dL .* dL_dtheta_h .* dtheta_h_dK .* dK_dP;
        end
        
        function transUpdate(obj, t_index)
            [DL, ~, ~, theta_o_next, d_theta_h1_next, d_theta_h2_next] = getTheta_h(obj, obj.tielineRecord(t_index) / obj.CAPACITY, t_index);
            obj.theta_h= theta_o_next + d_theta_h1_next - d_theta_h2_next;
            obj.d_theta_h1= d_theta_h1_next;
            obj.d_theta_h2 = d_theta_h2_next;
            obj.theta_o = theta_o_next;
            obj.DL_record(t_index) = DL;
        end
        
        function power = getPower(obj, t_index)
            power = obj.tielineRecord(t_index);
        end
        
        function setPower(obj, power)
            obj.tielineRecord = power;
        end
        
        function calculateCost(obj)
            global T;
            obj.cost(1) = T * obj.tielineRecord * obj.gridPriceRecord';
            obj.cost(2) = sum(obj.DL_record) * obj.install_cost / obj.expectancy * 15;%变压器老化成本
        end

    end
end