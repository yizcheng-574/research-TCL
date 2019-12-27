isAging = 0;
TransformerInit;
isUserAtHome = zeros(EV, 1);

tielineRecord = zeros(1,I);%自联络线购电量
gridPriceRecord4 = zeros(1,I);

EVpowerRecord = zeros(EV, I);
EVdata_E = zeros(maxEV, I);
EVdata_E(:, 1) = EVdata_initE .* EVdata_capacity';

IVApowerRecord = zeros(IVA, I);
IVAdata_Ta = zeros(IVA, I);
IVAdata_Ta(:, 1) = TCLdata_initT(FFA + 1, end, 1);

TCLpowerRecord = zeros(FFA, I2);
TCLdata_Ta = zeros(FFA, I);
TCLdata_Ta(:, 1) =  TCLdata_initT(1 : FFA, 1);
TCL_totalpowerRecord = zeros(1, I);
for t_index = 1: I
    gridPrice = gridPriceRecord(floor((t_index - 1) * T) + 1);
    gridPriceRecord4(t_index) = gridPrice;
end

for day = 1 : DAY
    for i = 1 : I_day
        t_index = (day - 1) * I_day + i;
        t_index_tcl = floor(t_index / I_tcl) + 1;
        time = (i - 1) * T ;%当前时长（24小时制）
        time_all = (t_index - 1) * T;%总时长
        theta_a = Tout(i);%C %Tout
        gridPrice = gridPriceRecord4(t_index);
        sigma = sigmaRecord(floor(time) + 1);
        
        %EV仅在到达时刻优化
        for ev = 1 : EV
            if time >= EVdata(1, ev) && time - T < EVdata(1, ev) %刚抵达
                prePrice = getTout(gridPriceRecord4, t_index, day * I_day + floor(EVdata(2,ev) / T) - t_index + 1);
                Pavg = EVopt(T, EVdata_E(ev, t_index), EVdata_alpha(ev),...
                    EVdata_mile(ev), EVdata_capacity(ev), PN, prePrice);
                EVpowerRecord(ev, t_index : t_index + length(prePrice) -1 ) = Pavg;
            end
            if time >= EVdata(2, ev) && time - T < EVdata(2, ev) %刚离开
                EVdata_E(ev, t_index) = max(EVdata_E(ev, t_index) - EVdata_mile(ev), 0);
            end
            if time >= EVdata(1, ev) || time < EVdata(2,ev)
                isUserAtHome(ev) = 1;
            else
                isUserAtHome(ev) = 0;
            end
        end
        isTCLon = repmat(isUserAtHome, 2, 1);
        isFFAon = isTCLon(1:FFA, :);
        isIVAon = ones(IVA, 1);
%         isIVAon = isTCLon(FFA + 1:end, :);

        tmp_P =  EVpowerRecord(:, t_index);
        tmp_E_next = zeros(EV, 1);
        tmp_E = EVdata_E(:, t_index);
        parfor ev = 1 : EV
             tmp_E_next(ev) = tmp_E(ev) + tmp_P(ev) * T;
        end
        EVdata_E(1:EV, t_index + 1) = tmp_E_next;
        
        %IVA
        N = T_mpc / T;
        IVAmpcPriceRecord = getTout(gridPriceRecord4, t_index, N);
        ToutRecord = getTout(Tout, t_index , N);
        tmp_T = IVAdata_Ta(:, t_index);
        tmp_P = zeros(IVA, 1);
        parfor iva = 1 : IVA
            tcl = iva + FFA;
            %按跟踪目标温度投标
            if isIVAon(iva)
                [~, ~, Pset] = IVABidPara(IVAmpcPriceRecord', tmp_T(iva), ToutRecord, ...
                    TCLdata_T(1, tcl), TCLdata_T(2, tcl), TCLdata_R(1, tcl), TCLdata_C(1, tcl), TCLdata_PN(1, tcl), IVAdata_Pmin(1, iva), ...
                    p1, p2, q1, q2, T, ratioIVA);
                tmp_P(iva) = Pset;
            end
        end
        IVApowerRecord(:, t_index) = tmp_P;
        tmp_Ta = IVAdata_Ta(:, t_index);
        parfor iva = 1: IVA
            heat_rate_IVA = q1 / p1 * tmp_P(iva) - (q1 * p2 - p1 * q2) / p1;
            tmp_Ta(iva) = theta_a - heat_rate_IVA * TCLdata_R(1, iva + FFA) - (theta_a - heat_rate_IVA * TCLdata_R(1, iva + FFA) - tmp_Ta(iva)) * exp(- T / TCLdata_R(1, iva + FFA) / TCLdata_C(1, iva + FFA));
        end
       IVAdata_Ta(:, t_index + 1) = tmp_Ta;
        
        %FFA
        if mod(t_index, I_tcl) == 1
            t_index_tcl = floor(t_index / I_tcl) + 1;
            N = T_mpc / T_tcl;
            TCLmpcPriceRecord = getTout(gridPriceRecord, floor(t_index / (T_tcl / T)) + 1, N);
            ToutRecord = zeros(N, 1);
            for n = 1 : N
                ToutRecord(n) = mean(getTout(Tout,t_index + (n - 1) * (T_tcl / T), T_tcl / T));
            end
            tmp_Ta = TCLdata_Ta(1: FFA, t_index);
            tmp_P = zeros(FFA, 1);
            parfor tcl = 1 : FFA
                if isFFAon(tcl)
                    [~, ~, Pset] = FFABidPara(TCLmpcPriceRecord',tmp_Ta(tcl), ToutRecord, ...
                        TCLdata_T(1, tcl), TCLdata_T(2, tcl), TCLdata_R(1, tcl), TCLdata_C(1, tcl), TCLdata_PN(1, tcl),...
                        T_tcl, ratioFFA);
                    tmp_P(tcl) = Pset;
                end
            end
            TCLpowerRecord(:, t_index_tcl) = tmp_P;
            totalPowerFFA = sum(tmp_P);
            tmp_P = TCLpowerRecord(:, t_index_tcl);
            for sub_i = 1 : T_tcl / T
                T0 = getTout(Tout, i + sub_i, 1);
                tmp_Ta = TCLdata_Ta(:, t_index + sub_i - 1 );
                parfor tcl = 1: FFA
                    Ta = tmp_Ta(tcl);
                    R = TCLdata_R(1, tcl);
                    C = TCLdata_C(1, tcl);
                    P = tmp_P(tcl);
                    tmp_Ta(tcl) = T0 - (2.7 * P)* R - (T0 - (2.7 * P) * R - Ta) * exp(- T / R / C);
                end
                TCLdata_Ta(:, t_index + sub_i) = tmp_Ta;
            end
        end
        TCL_totalpowerRecord(t_index) = totalPowerFFA;
        tmp = totalPowerFFA + sum(EVpowerRecord(:, t_index)) + sum(IVApowerRecord(:, t_index))- windPowerRecord(t_index) + loadPowerRecord(t_index);
        tielineRecord(t_index) = tmp / eta;
    end
end
EV_totalpowerRecord = sum(EVpowerRecord);
IVA_totalpowerRecord = sum(IVApowerRecord);
cal_cost;