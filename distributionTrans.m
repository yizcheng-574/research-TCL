classdef distributionTrans < transformer
    properties
        EV; FFA; IVA;
        windPowerRecord; loadPowerRecord;
        sigmaRecord;
        EVdata; EVdata_mile; EVdata_capacity; EVdata_alpha; EVdata_beta; EVdata_PN; EVdata_E; EVpowerRecord; EVavgPowerRecord; EVminPowerRecord; EVmaxPowerRecord;
        p1; p2; q1; q2; TCLdata_state; TCLdata_T; TCLdata_C; TCLdata_R; TCLdata_PN; IVAdata_Pmin; TCLdata_Ta; FFApowerRecord; IVApowerRecord; TCLsetPowerRecord; TCLminPowerRecord; TCLmaxPowerRecord; totalPowerFFA;
        bidCurve; receivedBidCurve;
        gridPrice; sigma;
    end
    
    methods
        function obj = distributionTrans(...
          EV, FFA, IVA, LOAD, WIND, CAPACITY, wp, lp, gp, sr, Tout, mkt,...
          TA_avg, TA_sigma, TD_avg, TD_sigma,...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs...
        )
            global I I2 T
            obj = obj@transformer(d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY, gp, Tout, mkt);
            obj.EV = EV;
            obj.FFA = FFA;
            obj.IVA = IVA;
            TCL = FFA + IVA;

            obj.windPowerRecord = wp / max(wp) * WIND;
            obj.loadPowerRecord = lp / max(lp) * LOAD;
            sigmaRecord =  zeros(1, I);
            for t_index = 1: I
                sigmaRecord(t_index) = sr(floor((t_index - 1) * T) + 1);
            end
            obj.sigmaRecord = sigmaRecord;
            % EVinit
            
            % 到家和离开家的时间
            EVdata = zeros(2,EV);
            EVdata(1,:) = normrnd(TA_avg, TA_sigma, 1, EV);
            EVdata(2,:) = normrnd(TD_avg, TD_sigma, 1, EV);
            EVdata(EVdata < 12) = 12;
            EVdata(EVdata > 36) = 36;
            for ev = 1 : EV
                while EVdata(2,ev) < EVdata(1,ev) + 1
                    EVdata(2,ev) = normrnd(TD_avg, TD_sigma);
                end
            end
            obj.EVdata = EVdata;
            % 目标电量
            EVdata_mile = unifrnd(10,20,1,EV);
            EVdata_capacity = ceil(unifrnd(20,25,1,EV));%表示EV电池老化
            for ev = 1 : EV
                if EVdata_mile(ev) > EVdata_capacity(ev) - 1
                    EVdata_mile(ev) = EVdata_capacity(ev) - 1;
                end
            end
            obj.EVdata_mile = EVdata_mile;
            obj.EVdata_capacity = EVdata_capacity;
            obj.EVdata_alpha = unifrnd(0,1,1,EV);
            obj.EVdata_beta = unifrnd(0,1,1,EV);
            obj.EVdata_PN=3.7;
            obj.EVdata_E = zeros(EV, I);
            obj.EVdata_E(:, 1) = unifrnd(0.1, 0.5, EV, 1) .* obj.EVdata_capacity';
            obj.EVpowerRecord = zeros(EV, I);
            obj.EVavgPowerRecord = zeros(1, EV);
            obj.EVmaxPowerRecord = zeros(1, EV);
            obj.EVminPowerRecord = zeros(1, EV);
            
            % HVACinit
            obj.p1 = p1;
            obj.q1 = q1;
            obj.p2 = p2;
            obj.q2 = q2;
            obj.TCLdata_state = ceil(unifrnd(0, 4, 1, FFA));
            obj.TCLdata_T(1, :) = unifrnd(27.5, 28.5, 1, TCL); 
            obj.TCLdata_T(2, :) = unifrnd(23.5, 24.5, 1, TCL); 
            obj.TCLdata_C = unifrnd(0.8 ,1.2, 1, TCL);
            obj.TCLdata_R = unifrnd(2 ,2.5, 1, TCL);
            obj.TCLdata_PN(1, 1:FFA) = unifrnd(2.5, 3.5, 1, FFA);
            obj.TCLdata_PN(1, FFA + 1 :TCL) = unifrnd(3.5, 4.5, 1, IVA);
            obj.IVAdata_Pmin = unifrnd(0.4, 0.5, 1, IVA);
            obj.TCLdata_Ta = zeros(TCL, I);
            obj.TCLdata_Ta(:, 1) = unifrnd(25.8, 26.2, TCL, 1);
            obj.FFApowerRecord = zeros(FFA, I2);
            obj.IVApowerRecord = zeros(IVA, I);
            obj.TCLsetPowerRecord = zeros(1, TCL);
            obj.TCLmaxPowerRecord = zeros(1, TCL);
            obj.TCLminPowerRecord = zeros(1, TCL);                        
        end
        
        function bidCurve = bid(obj, t_index, time)
            global T T_mpc  I I_tcl T_tcl
            step = obj.mkt(3);
            obj.gridPrice = obj.gridPriceRecord(t_index);
            obj.sigma =  obj.sigmaRecord(t_index);
            bidCurve = zeros(1, step + 1);
            
            %EV自身优化
            tmp_E =  obj.EVdata_E(:, t_index);
            for ev = 1 : obj.EV
                if time >= obj.EVdata(1, ev) && time < obj.EVdata(2,ev)
                    %预测未来电价   
                    prePrice = obj.gridPriceRecord(t_index : floor(obj.EVdata(2, ev) / T) -  I /2);
                    remain_t = obj.EVdata(2,ev) - time;
                    [Pmax, Pmin, Pavg] = EVBidPara(T, tmp_E(ev), obj.EVdata_alpha(ev), remain_t, ...
                        obj.EVdata_mile(ev), obj.EVdata_capacity(ev), obj.EVdata_PN, prePrice);
                    obj.EVavgPowerRecord(1, ev) = Pavg;
                    obj.EVminPowerRecord(1, ev) = Pmin;
                    obj.EVmaxPowerRecord(1, ev) = Pmax;
                    bidCurve = bidCurve + EVbid(obj.mkt, Pmax, Pmin, Pavg, obj.EVdata_beta(ev), obj.gridPrice, obj.sigma);
                end
            end
            
            %IVA 自身优化
            N = T_mpc / T;
            IVAmpcPriceRecord = getTout(obj.gridPriceRecord, t_index, N);     
            ToutRecord = getTout(obj.Tout, t_index , N); 
            tmp_T = obj.TCLdata_Ta(obj.FFA + 1 : end, t_index);
            for iva = 1 : obj.IVA
                tcl = iva + obj.FFA;
                %按跟踪目标温度投标
                [Pmax, Pmin, Pset, ~] = IVABidPara(IVAmpcPriceRecord', tmp_T(iva), ToutRecord, ...
                    obj.TCLdata_T(1, tcl), obj.TCLdata_T(2, tcl), obj.TCLdata_R(1, tcl), obj.TCLdata_C(1, tcl), obj.TCLdata_PN(1, tcl), obj.IVAdata_Pmin(1, iva), ...
                    obj.p1, obj.p2, obj.q1, obj.q2, T);
                obj.TCLmaxPowerRecord(1, tcl) = Pmax;
                obj.TCLminPowerRecord(1, tcl) = Pmin;
                obj.TCLsetPowerRecord(1, tcl) = Pset;
                bidCurve = bidCurve + EVbid(obj.mkt, Pmax, Pmin, Pset, obj.EVdata_beta(mod(tcl - 1, obj.EV) + 1), obj.gridPrice, obj.sigma);          
            end
     
            %FFA 自身优化
            if mod(t_index, I_tcl) == 1
                obj.totalPowerFFA = 0;
                N = T_mpc / T_tcl;
                TCLmpcPriceRecord = getTout(obj.gridPriceRecord24, floor(t_index / (T_tcl / T)) + 1, N);
                ToutRecord = zeros(N, 1);
                for n = 1 : N
                    ToutRecord(n) = mean(getTout(obj.Tout,t_index + (n - 1) * (T_tcl / T), T_tcl / T));
                end
                tmp_Ta = obj.TCLdata_Ta(1: obj.FFA, t_index);
                for tcl = 1 : obj.FFA
                    [Pmax, Pmin, Pset, ~] = FFABidPara(TCLmpcPriceRecord',tmp_Ta(tcl), ToutRecord, ...
                            obj.TCLdata_T(1, tcl), obj.TCLdata_T(2, tcl), obj.TCLdata_R(1, tcl), obj.TCLdata_C(1, tcl), obj.TCLdata_PN(1, tcl),...
                            T_tcl);
                    obj.TCLmaxPowerRecord(1, tcl) = Pmax;
                    obj.TCLsetPowerRecord(:, tcl) = Pset;
                    obj.TCLminPowerRecord(:, tcl) = Pmin; 
                    bidCurve = bidCurve + EVbid(obj.mkt, Pmax, Pmin, Pset, obj.EVdata_beta(mod(tcl - 1, obj.EV) + 1), obj.gridPrice, obj.sigma);
                end
            end
            
            %区域投标
            bidCurve = bidCurve - obj.windPowerRecord(t_index) + obj.loadPowerRecord(t_index) + obj.totalPowerFFA;
            K = bidCurve / obj.CAPACITY;
            dC_dP = getDerivative(obj, K, t_index);
            obj.receivedBidCurve = bidCurve;
            bidCurve = myInterp(obj.pCurve - dC_dP, bidCurve, obj.pCurve);
            obj.bidCurve = bidCurve;
        end
        
        function clear(obj, clcPrice, t_index, time)
             clearingPower = interp1(obj.pCurve, obj.bidCurve, clcPrice);
             clearingPrice = calculateIntersection(obj.mkt, 0, obj.receivedBidCurve - clearingPower);
             obj.update(clearingPrice, t_index, time);
        end
        
        function update(obj, clcPrice, t_index, time)
            global T I_tcl T_tcl
            obj.priceRecord(t_index) = clcPrice;
            %EV update
            tmp_E =  obj.EVdata_E(:, t_index);
            tmp_E_next = zeros(obj.EV, 1);
            tmp_P = zeros(obj.EV, 1);
            for ev = 1 : obj.EV
                if time >= obj.EVdata(1,ev) && time < obj.EVdata(2, ev)
                    EVbidCurve = EVbid(obj.mkt, obj.EVmaxPowerRecord(1, ev), obj.EVminPowerRecord(1, ev), obj.EVavgPowerRecord(1, ev),...
                            obj.EVdata_beta(ev), obj.gridPrice, obj.sigma);
                    power_EV = handlePriceUpdate(EVbidCurve, clcPrice, obj.mkt );
                    tmp_P(ev, 1) = power_EV;
                    tmp_E_next(ev) = tmp_E(ev) + power_EV * T;
                else
                    tmp_E_next(ev) = tmp_E(ev);
                end
            end
            obj.EVdata_E(:, t_index + 1) = tmp_E_next;
            obj.EVpowerRecord(:, t_index) = tmp_P;
            
            %IVA update
            tmp_Ta = obj.TCLdata_Ta(obj.FFA + 1: end, t_index);
            tmp_Ta_next = zeros(obj.IVA, 1);
            tmp_P = zeros(obj.IVA, 1);
            for iva = 1 : obj.IVA
                tcl = iva + obj.FFA;
                IVAbidCurve = EVbid(obj.mkt, obj.TCLmaxPowerRecord(1, tcl), obj.TCLminPowerRecord(1, tcl), obj.TCLsetPowerRecord(1, tcl),...
                        obj.EVdata_beta(mod( tcl - 1, obj.EV) + 1), obj.gridPrice, obj.sigma);
                power_IVA = handlePriceUpdate(IVAbidCurve, clcPrice, obj.mkt );
                tmp_P(iva, 1) = power_IVA;
                heat_rate_IVA = P2Q(obj, tmp_P(iva));
                theta_a = obj.Tout(t_index);
                tmp_Ta_next(iva) = theta_a - heat_rate_IVA * obj.TCLdata_R(1, iva + obj.FFA) - (theta_a - heat_rate_IVA * obj.TCLdata_R(1, iva + obj.FFA) - tmp_Ta(iva)) * exp(- T / obj.TCLdata_R(1, iva + obj.FFA) / obj.TCLdata_C(1, iva + obj.FFA));
            end
            obj.IVApowerRecord(:, t_index) = tmp_P;
            obj.TCLdata_Ta(obj.FFA + 1: end, t_index + 1) = tmp_Ta_next;
            
            %FFA update
            if mod(t_index, I_tcl) == 1
                t_index_tcl = floor(t_index / I_tcl) + 1;
                tmp_P = zeros(obj.FFA, 1);
                for tcl = 1 : obj.FFA
                    FFAbidCurve = EVbid(obj.mkt, obj.TCLmaxPowerRecord(1, tcl), obj.TCLminPowerRecord(1, tcl), obj.TCLsetPowerRecord(1, tcl),...
                            obj.EVdata_beta(mod(tcl - 1, obj.EV) + 1), obj.gridPrice, obj.sigma);
                    power_TCL = handlePriceUpdate(FFAbidCurve, clcPrice, obj.mkt );
                    tmp_P(tcl, 1) = power_TCL;
                end
                obj.FFApowerRecord(:, t_index_tcl) = tmp_P;            
                for sub_i = 1 : T_tcl / T
                    T0 = getTout(obj.Tout, t_index + sub_i, 1);
                    tmp_Ta = obj.TCLdata_Ta(1: obj.FFA, t_index + sub_i - 1 );
                    tmp_Ta_next = zeros(obj.FFA, 1);
                    for tcl = 1: obj.FFA
                        Ta = tmp_Ta(tcl);
                        R_tmp = obj.TCLdata_R(1, tcl);
                        C = obj.TCLdata_C(1, tcl);
                        P = tmp_P(tcl);
                        tmp_Ta_next(tcl) = T0 - (2.7 * P)* R_tmp - (T0 - (2.7 * P) * R_tmp - Ta) * exp(- T / R_tmp / C);
                    end
                    obj.TCLdata_Ta(1: obj.FFA, t_index + sub_i) = tmp_Ta_next;
                end
                obj.totalPowerFFA = sum(tmp_P);
            end
            
            %transformer update
            obj.tielineRecord(t_index) = obj.totalPowerFFA + sum(obj.EVpowerRecord(:, t_index)) + sum(obj.IVApowerRecord(:, t_index))- obj.windPowerRecord(t_index) + obj.loadPowerRecord(t_index);
            obj.transUpdate(t_index);
        end  
        
        function Q = P2Q(obj, P)
            Q = obj.q1 / obj.p1 * P - (obj.q1 * obj.p2 - obj.p1 * obj.q2) / obj.p1;
        end
        
    end
end
        