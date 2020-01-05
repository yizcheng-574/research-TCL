classdef distributionTrans < transformer
    properties
        EV; FFA; IVA;
        windPowerRecord; loadPowerRecord;
        sigmaRecord;
        EVdata; EVdata_mile; EVdata_capacity; EVdata_alpha; EVdata_beta; EVdata_PN; EVdata_E; EVpowerRecord; EVavgPowerRecord; EVminPowerRecord; EVmaxPowerRecord;
        p1; p2; q1; q2; TCLdata_state; TCLdata_T; TCLdata_C; TCLdata_R; TCLdata_PN; IVAdata_Pmin; TCLdata_Ta; TCLdata_Ta_normalize; FFApowerRecord; IVApowerRecord; TCLsetPowerRecord; TCLminPowerRecord; TCLmaxPowerRecord; totalPowerFFA; TCLdata_comfort;
        bidCurve; receivedBidCurve;
        gridPrice; sigma;
    end
    
    methods
        function obj = distributionTrans(...
          EV, FFA, IVA, CAPACITY, wp, lp, gp, sr, Tout, mkt,...
          EVdata, EVdata_mile, EVdata_capacity, PN,...
          TCLdata_T, TCLdata_R, TCLdata_C, FFAdata_PN, IVAdata_PN, IVAdata_Pmin, TCLdata_initT, ...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs, eta...
        )
            global I I2 T
            obj = obj@transformer(d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY, gp, Tout, mkt, eta);
            obj.EV = EV;
            obj.FFA = FFA;
            obj.IVA = IVA;
            TCL = FFA + IVA;

            obj.windPowerRecord = wp;
            obj.loadPowerRecord = lp;
            
            sigmaRecord =  zeros(1, I);
            for t_index = 1: I
                sigmaRecord(t_index) = sr(floor((t_index - 1) * T) + 1);
            end
            obj.sigmaRecord = sigmaRecord;
            % EVinit          
            obj.EVdata = EVdata;
            obj.EVdata_mile = EVdata_mile;
            obj.EVdata_capacity = EVdata_capacity;
            obj.EVdata_alpha = unifrnd(0,0,1,EV);
            obj.EVdata_beta = unifrnd(0.5,2,EV);
            obj.EVdata_PN = PN;
            obj.EVdata_E = zeros(EV, I);
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
            obj.TCLdata_T = TCLdata_T; 
            obj.TCLdata_C = TCLdata_C;
            obj.TCLdata_R = TCLdata_R;
            obj.TCLdata_PN = [FFAdata_PN, IVAdata_PN];
            obj.IVAdata_Pmin = IVAdata_Pmin;
            obj.TCLdata_Ta = zeros(TCL, I);
            obj.TCLdata_Ta(:, 1) = TCLdata_initT;
            obj.TCLdata_Ta_normalize = zeros(TCL, I + 1);
            obj.FFApowerRecord = zeros(FFA, I2);
            obj.IVApowerRecord = zeros(IVA, I);
            obj.TCLsetPowerRecord = zeros(1, TCL);
            obj.TCLmaxPowerRecord = zeros(1, TCL);
            obj.TCLminPowerRecord = zeros(1, TCL);    
            obj.TCLdata_comfort = zeros(1, obj.FFA + obj.IVA);
        end
        
        function bidCurve = bid(obj, t_index, time)
            global T T_mpc  I T_tcl I_tcl ratioFFA ratioIVA

            step = obj.mkt(3);
            obj.gridPrice = obj.gridPriceRecord(t_index);
            obj.sigma =  obj.sigmaRecord(t_index);
            bidCurve = zeros(1, step + 1);
            
            %EV自身优化
            tmp_E =  obj.EVdata_E(:, t_index);
            objEV = obj.EV;
            objEVdata = obj.EVdata;
            gridPriceRecord = obj.gridPriceRecord;
            objEVdata_alpha = obj.EVdata_alpha;
            objEVdata_beta = obj.EVdata_beta;
            objEVdata_mile = obj.EVdata_mile;
            objEVdata_capacity = obj.EVdata_capacity;
            objEVdata_PN = obj.EVdata_PN;
            objEVavgPowerRecord = obj.EVavgPowerRecord;
            objEVminPowerRecord = obj.EVminPowerRecord;
            objEVmaxPowerRecord = obj.EVmaxPowerRecord;
            objgridPrice = obj.gridPrice;
            objsigma = obj.sigma;
            mkt = obj.mkt;
            objT = T;
            objI = I;
            parfor ev = 1 : objEV
                if time >= objEVdata(1, ev) && time < objEVdata(2,ev)
                    %预测未来电价   
                    prePrice = gridPriceRecord(t_index : floor(objEVdata(2, ev) / objT) -  objI /2);
                    remain_t = objEVdata(2,ev) - time;
                    [Pmax, Pmin, Pavg] = EVBidPara(objT, tmp_E(ev), objEVdata_alpha(ev), remain_t, ...
                        objEVdata_mile(ev), objEVdata_capacity(ev), objEVdata_PN, prePrice);
                    objEVavgPowerRecord(1, ev) = Pavg;
                    objEVminPowerRecord(1, ev) = Pmin;
                    objEVmaxPowerRecord(1, ev) = Pmax;
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, objEVdata_beta(ev), objgridPrice, objsigma);
                end
            end
            obj.EVavgPowerRecord = objEVavgPowerRecord;
            obj.EVminPowerRecord = objEVminPowerRecord;
            obj.EVmaxPowerRecord = objEVmaxPowerRecord;
            %IVA 自身优化
            N = T_mpc / T;
            IVAmpcPriceRecord = getTout(obj.gridPriceRecord, t_index, N);     
            ToutRecord = getTout(obj.Tout, t_index , N); 
            tmp_T = obj.TCLdata_Ta(obj.FFA + 1 : end, t_index);
            objIVA = obj.IVA;
            objFFA = obj.FFA;
            objTCLdata_T = obj.TCLdata_T;
            objTCLdata_R = obj.TCLdata_R;
            objTCLdata_C = obj.TCLdata_C;
            objTCLdata_PN = obj.TCLdata_PN;
            objTCLmaxPowerRecord = obj.TCLmaxPowerRecord;
            objTCLminPowerRecord = obj.TCLminPowerRecord;
            objTCLsetPowerRecord = obj.TCLsetPowerRecord;
            objIVAdata_Pmin= obj.IVAdata_Pmin;
            objp1 = obj.p1;
            objp2 = obj.p2;
            objq1 = obj.q1;
            objq2 = obj.q2;
            objmkt = obj.mkt;
            
            parfor iva = 1 : objIVA
                tcl = iva + objFFA;
                %按跟踪目标温度投标
                [Pmax, Pmin, Pset] = IVABidPara(IVAmpcPriceRecord', tmp_T(iva), ToutRecord, ...
                    objTCLdata_T(1, tcl), objTCLdata_T(2, tcl), objTCLdata_R(1, tcl), objTCLdata_C(1, tcl), objTCLdata_PN(1, tcl), objIVAdata_Pmin(1, iva), ...
                    objp1, objp2, objq1, objq2, objT, ratioIVA);
                objTCLmaxPowerRecord(1, iva + objFFA) = Pmax;
                objTCLminPowerRecord(1, iva + objFFA) = Pmin;
                objTCLsetPowerRecord(1, iva + objFFA) = Pset;
                bidCurve = bidCurve + EVbid(objmkt, Pmax, Pmin, Pset, objEVdata_beta(mod(tcl - 1, objEV) + 1), objgridPrice, objsigma);          
            end
 
            
            if mod(t_index, I_tcl) == 1
                obj.totalPowerFFA = 0;
                N = T_mpc / T_tcl;
                TCLmpcPriceRecord = getTout(obj.gridPriceRecord24, floor(t_index / (T_tcl / T)) + 1, N);
                ToutRecord = zeros(N, 1);
                for n = 1 : N
                    ToutRecord(n) = mean(getTout(obj.Tout, t_index + (n - 1) * (T_tcl / T), T_tcl / T));
                end
                tmp_Ta = obj.TCLdata_Ta(:, t_index );
                parfor tcl = 1 : obj.FFA
                    [Pmax, Pmin, Pset] = FFABidPara(TCLmpcPriceRecord',tmp_Ta(tcl), ToutRecord, ...
                            objTCLdata_T(1, tcl), objTCLdata_T(2, tcl), objTCLdata_R(1, tcl), objTCLdata_C(1, tcl), objTCLdata_PN(1, tcl),...
                            T_tcl, ratioFFA);
                    objTCLmaxPowerRecord(tcl) = Pmax;
                    objTCLsetPowerRecord(tcl) = Pset;
                    objTCLminPowerRecord(tcl) = Pmin;
                    bidCurve = bidCurve + EVbid(objmkt, Pmax, Pmin, Pset, objEVdata_beta(mod(tcl - 1, objEV) + 1), objgridPrice, objsigma);
                end
            end
            
            obj.TCLmaxPowerRecord = objTCLmaxPowerRecord;
            obj.TCLminPowerRecord = objTCLminPowerRecord;
            obj.TCLsetPowerRecord = objTCLsetPowerRecord;
            
            %区域投标
            bidCurve = (bidCurve +  obj.totalPowerFFA - obj.windPowerRecord(t_index) + obj.loadPowerRecord(t_index))/ obj.eta;
            K = bidCurve / obj.CAPACITY ;
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
            objEV = obj.EV;
            objEVdata = obj.EVdata;
            objEVmaxPowerRecord = obj.EVmaxPowerRecord;
            objEVminPowerRecord = obj.EVminPowerRecord;
            objEVavgPowerRecord = obj.EVavgPowerRecord;
            objEVdata_beta = obj.EVdata_beta;
            objgridPrice = obj.gridPrice;
            objsigma = obj.sigma;
            objmkt = obj.mkt;
            objT = T;
            parfor ev = 1 : objEV
                if time >= objEVdata(1,ev) && time < objEVdata(2, ev)
                    EVbidCurve = EVbid(objmkt, objEVmaxPowerRecord(1, ev), objEVminPowerRecord(1, ev), objEVavgPowerRecord(1, ev),...
                            objEVdata_beta(ev), objgridPrice, objsigma);
                    power_EV = handlePriceUpdate(EVbidCurve, clcPrice, objmkt );
                    tmp_P(ev, 1) = power_EV;
                    tmp_E_next(ev) = tmp_E(ev) + power_EV * objT;
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
            
            objIVA = obj.IVA;
            objFFA = obj.FFA;
            objTCLmaxPowerRecord = obj.TCLmaxPowerRecord;
            objTCLminPowerRecord = obj.TCLminPowerRecord;
            objTCLsetPowerRecord = obj.TCLsetPowerRecord;
            objTCLdata_R = obj.TCLdata_R;
            objTCLdata_C = obj.TCLdata_C;
            objTout = obj.Tout;
            parfor iva = 1 : objIVA
                tcl = iva + objFFA;
                IVAbidCurve = EVbid(objmkt, objTCLmaxPowerRecord(tcl), objTCLminPowerRecord(tcl), objTCLsetPowerRecord(tcl),...
                        objEVdata_beta(mod( tcl - 1, objEV) + 1), objgridPrice, objsigma);
                power_IVA = handlePriceUpdate(IVAbidCurve, clcPrice, objmkt );
                tmp_P(iva, 1) = power_IVA;
                heat_rate_IVA = P2Q(obj, power_IVA);
                theta_a = objTout(t_index);
                tmp_Ta_next(iva) = theta_a - heat_rate_IVA * objTCLdata_R(1, iva + objFFA) - (theta_a - heat_rate_IVA * objTCLdata_R(1, iva + objFFA) - tmp_Ta(iva)) * exp(- objT / objTCLdata_R(1, iva + objFFA) / objTCLdata_C(1, iva + objFFA));
            end
            obj.IVApowerRecord(:, t_index) = tmp_P;
            obj.TCLdata_Ta(obj.FFA + 1: end, t_index + 1) = tmp_Ta_next;
            
            %FFA update
            if mod(t_index, I_tcl) == 1
                t_index_tcl = floor(t_index / I_tcl) + 1;
                tmp_P = zeros(obj.FFA, 1);
                parfor tcl = 1 : objFFA
                    FFAbidCurve = EVbid(objmkt, objTCLmaxPowerRecord(1, tcl), objTCLminPowerRecord(1, tcl), objTCLsetPowerRecord(1, tcl),...
                            objEVdata_beta(mod(tcl - 1, objEV) + 1), objgridPrice, objsigma);
                    power_TCL = handlePriceUpdate(FFAbidCurve, clcPrice, objmkt );
                    tmp_P(tcl, 1) = power_TCL;
                end
                obj.FFApowerRecord(:, t_index_tcl) = tmp_P;            
                for sub_i = 1 : T_tcl / T
                    T0 = getTout(obj.Tout, t_index + sub_i, 1);
                    tmp_Ta = obj.TCLdata_Ta(1: obj.FFA, t_index + sub_i - 1 );
                    tmp_Ta_next = zeros(obj.FFA, 1);
                    parfor tcl = 1: objFFA
                        Ta = tmp_Ta(tcl);
                        R_tmp = objTCLdata_R(1, tcl);
                        C = objTCLdata_C(1, tcl);
                        P = tmp_P(tcl);
                        tmp_Ta_next(tcl) = T0 - (2.7 * P)* R_tmp - (T0 - (2.7 * P) * R_tmp - Ta) * exp(- objT / R_tmp / C);
                    end
                    obj.TCLdata_Ta(1: obj.FFA, t_index + sub_i) = tmp_Ta_next;
                end
                obj.totalPowerFFA = sum(tmp_P);
            end
            
            %transformer update
            tmp = (obj.totalPowerFFA + sum(obj.EVpowerRecord(:, t_index)) + sum(obj.IVApowerRecord(:, t_index))- obj.windPowerRecord(t_index) + obj.loadPowerRecord(t_index))/ obj.eta;
            obj.tielineRecord(t_index) = tmp;
            obj.transUpdate(t_index);
        end  
        
        function [demand, f] = optimizaAccordingToPrice(obj, lambda, update, isPrecision)
            global I T
            gridPriceRecord = obj.gridPriceRecord';
            priceRecord = gridPriceRecord + lambda;
            objI = I;
            demand = - obj.windPowerRecord + obj.loadPowerRecord;
            objEVdata1 = obj.EVdata(1, :);
            objEVdata2 = obj.EVdata(2, :);
            PN = obj.EVdata_PN;
            objEVdata_mile = obj.EVdata_mile;
            f = 0;
            if update == 1
                objEVpowerRecord = zeros(obj.EV, I);
            end
%             tocRecord = zeros(1, obj.EV);
            for ev = 1: obj.EV
%                 tic;
                [p, fval] = EVoptimize(priceRecord, objEVdata1(ev), objEVdata2(ev),...
                    PN, objEVdata_mile(ev), zeros(objI, 1), 0);
                
%                 tocRecord(ev) = toc;
                demand = demand + p;
                f = f + fval;
                if update == 1
                     objEVpowerRecord(ev, :) = p';
                end
            end
            if update == 1
                obj.EVpowerRecord = objEVpowerRecord;
            end
            objTCLdata_initT = obj.TCLdata_Ta(:, 1);
            objTout = obj.Tout;
            objTCLdata_T1 = obj.TCLdata_T(1, :);
            objTCLdata_T2 = obj.TCLdata_T(2, :);
            objTCLdata_R = obj.TCLdata_R;
            objTCLdata_C = obj.TCLdata_C;
            objTCLdata_PN = obj.TCLdata_PN;
            objIVAdata_Pmin = obj.IVAdata_Pmin;
            objp1 = obj.p1;
            objp2 = obj.p2;
            objq1 = obj.q1;
            objq2 = obj.q2;
            objT = T;
            if update == 1
                objIVApowerRecord = zeros(obj.IVA, I);
            end
%             tocRecord = zeros(1, obj.IVA);
            parfor iva = 1: obj.IVA
%                 tic;
                [p, fval] = IVAoptimize(priceRecord, objTCLdata_initT(iva), objTout, ...
                    objTCLdata_T1(iva), objTCLdata_T2(iva), objTCLdata_R(iva), objTCLdata_C(iva), objTCLdata_PN(iva), objIVAdata_Pmin(iva),...
                    objp1, objp2, objq1, objq2, objT, zeros(objI, 1), 0);
                demand = demand + p;
%                 tocRecord(iva) = toc;
                f = f + fval;
                if update == 1
                     objIVApowerRecord(iva, :) = p';
                end
            end
            if update == 1
                obj.IVApowerRecord = objIVApowerRecord;
            end
            [p, fval, dlrecord] = lineOptimizeAccordingToPrice(gridPriceRecord, obj.Tout, obj.eta, obj.yrs,...
                lambda,  obj.CAPACITY, isPrecision);
            if update == 0          
                demand = demand - p;
                f = f + fval;
            else
                obj.tielineRecord = demand' / obj.eta;
%                 obj.tielineRecord = p' / obj.eta;
                obj.priceRecord = obj.gridPriceRecord + lambda';
                obj.updateAll();
            end

        end
        
        function Q = P2Q(obj, P)
            Q = obj.q1 / obj.p1 * P - (obj.q1 * obj.p2 - obj.p1 * obj.q2) / obj.p1;
        end
        
        function updateAll(obj)
            global I T
            for ev = 1: obj.EV
                for t = 1: I
                    obj.EVdata_E(ev, t+1) = obj.EVdata_E(ev, t) + obj.EVpowerRecord(ev, t) * T;
                end
            end
            for iva = 1: obj.IVA
                for t = 1: I
                    heat_rate_IVA = P2Q(obj, obj.IVApowerRecord(iva, t));
                    theta_a = obj.Tout(t);
                    obj.TCLdata_Ta(obj.FFA + iva, t + 1) = theta_a - heat_rate_IVA * obj.TCLdata_R(1, iva + obj.FFA) - (theta_a - heat_rate_IVA * obj.TCLdata_R(1, iva + obj.FFA) - obj.TCLdata_Ta(obj.FFA + iva, t)) * exp(-T / obj.TCLdata_R(1, iva + obj.FFA) / obj.TCLdata_C(1, iva + obj.FFA));
                end
            end
            for t = 1: I
                obj.transUpdate(t);
            end
        end
        
        function temperatureNormalize(obj)
            for iva = 1: obj.IVA
                obj.TCLdata_Ta_normalize(iva, :) = (obj.TCLdata_Ta(iva, :) - obj.TCLdata_T(2, iva)) / (obj.TCLdata_T(1, iva) - obj.TCLdata_T(2, iva));
            end
        end
        
        function calculateCost(obj)
             global T;
            obj.cost(1) = T * obj.tielineRecord * obj.gridPriceRecord';
            obj.cost(2) = sum(obj.DL_record) * obj.install_cost / obj.expectancy;% 变压器老化成本
            for iva = 1: obj.IVA
                obj.TCLdata_comfort(iva) = T * (obj.TCLdata_Ta_normalize(iva, 2: end) - 0.5) .^2 * obj.gridPriceRecord' * (obj.TCLdata_PN(iva) - obj.IVAdata_Pmin(iva));
            end
            obj.cost(3) = sum(obj.TCLdata_comfort);
            
        end
    end
end
        