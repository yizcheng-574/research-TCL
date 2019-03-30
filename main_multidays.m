%考虑随机因素影响
% clc;clear;
% sen_index = sen_index + 1;
load 'D:\CYZ\TCLdata\0308\100initData'
tic;
DAY = 7;
RATIO = 100;
EV = 5 * RATIO;%EV总数，额定功率为3.7kW
FFA = 6 * RATIO;%空调总数
IVA = 4 * RATIO;
T = 15 / 60;%控制周期15min
dt = 1 / 60 / 60;%空调控制周期2s
T_tcl = 1; %空调控制指令周期60min
T_mpc = 6;
I1 = 24 * DAY / dt;
I = 24 * DAY / T;
I_day = 24 / T;
I_tcl = T_tcl / T;
I2 = 24 * DAY / T_tcl;
LOAD = 20 * RATIO;%LOAD最大负荷（kW）
WIND = 10 * RATIO;%WIND风电装机容量（kW）
tielineSold = 4 * RATIO;
tielineBuy = 32 * RATIO;
nod33 = 33;
tolerance = 0.01;
if exist('DAY', 'var') == 1
    isMultiDay = 1;
else
    isMultiDay = 0;
end
% isAging = 1;
% isEVflex = 1;
% isTCLflex = 1;
% mktInit;   %市场初始化
% priceInit;
% EVinit;
% TCLinit;
tielineRecord = zeros(1,I);%自联络线购电量
gridPriceRecord4 = zeros(1,I);
priceRecord = zeros(1,I); %考虑预测误差，随机优化的出清电价
priceRecord_noStochastic = zeros(1,I); %不考虑预测误差的出清电价
priceRecord_stochastic = zeros(1, I); %考虑预测误差，确定优化的出清电价
hasCongest = 0;

EV_totalpowerRecord = zeros(1, I);%EV总充电功率
TCL_totalpowerRecord = zeros(1, I);
IVA_totalpowerRecord = zeros(1, I);

EVpowerRecord = zeros(EV, I);
EVavgPowerRecord = zeros(EV, I);
EVmaxPowerRecord = zeros(EV, I);
EVminPowerRecord = zeros(EV, I);
EVdata_E = zeros(EV, I);
EVdata_E(:, 1) = EVdata_initE .* EVdata_capacity';
totalPowerEV = 0;
if isTCLflex == 1   
    IVApowerRecord = zeros(IVA, I);
    IVAsetPowerRecord = zeros(IVA, I);
    IVAmaxPowerRecord = zeros(IVA, I);
    IVAminPowerRecord = zeros(IVA, I);
    IVAdata_Ta = zeros(IVA, I);
    IVAdata_Ta(:, 1) = TCLdata_initT(FFA + 1, end, 1);
    
    TCLdata_state = ceil(unifrnd(0, 4, 1, FFA));
    TCLdata_Ta = zeros(FFA, I);
    TCLdata_P = zeros(FFA, I);
    TCLdata_lockTime = zeros(1, FFA);
    TCLpowerRecord = zeros(FFA, I2);
    TCLsetPowerRecord = zeros(FFA, I2);
    TCLmaxPowerRecord = zeros(FFA, I2);
    TCLminPowerRecord = zeros(FFA, I2);
    TCLdata_Ta(:, 1) =  TCLdata_initT(1 : FFA, 1);
    
%     if isEVflex == 1 && isAging == 1
%         TCLinstantPowerRecord = zeros(1, I1);
%     end
    FFASOArecord = zeros(FFA, I2);
    IVASOArecord = zeros(IVA, I);
else
    TCLdata_state_benchmark = floor(unifrnd(0, 2, 1, FFA + IVA));
    TCLdata_P_benchmark = zeros(FFA + IVA, I);
    TCLdata_Ta_benchmark = zeros(FFA + IVA, I);
    TCLdata_Ta_benchmark(:, 1) = TCLdata_initT;
    TCLinstantPowerRecord_benchmark = zeros(1, I1);
end
if isAging == 1
    TransformerInit;
end
for t_index = 1: I
    gridPrice = gridPriceRecord(floor((t_index - 1) * T) + 1);
    gridPriceRecord4(t_index) = gridPrice;
end

for day = 1 : DAY
    for i = 1: I_day
        t_index = (day - 1) * I_day + i;
        t_index_tcl = floor(t_index / I_tcl) + 1;
        time = (i - 1) * T ;%当前时长（24小时制）
        time_all = (t_index - 1) * T;%总时长
        theta_a = Tout(i);%C %Tout
        gridPrice = gridPriceRecord4(t_index);
        sigma = sigmaRecord(floor(time) + 1);
        
        bidCurve = zeros(1, step + 1);
        %联络线投标
        if isAging == 1 %考虑变压器损耗
            isBid = 1;
            transformer_ageing_expo;
        else %不考虑变压器损耗
            tielineCurve = zeros(1, step + 1);
            for q = 1 : step + 1
                if pCurve(q) < gridPrice
                    tielineCurve(q) = tielineSold;
                elseif pCurve(q) >= gridPrice
                    tielineCurve(q) = -tielineBuy;
                end
            end
        end
        
        totalPowerEV = 0;
        tmp_E =  EVdata_E(:, t_index);
        if isEVflex == 1
            tmp_maxP = zeros(EV, 1);
            tmp_avgP = zeros(EV, 1);
            tmp_minP = zeros(EV, 1);
            parfor ev = 1 : EV
                if time >= EVdata(2, ev) && time - T < EVdata(2, ev)
                    tmp_E(ev) = max(tmp_E(ev) - EVdata_mile(ev), 0);
                end
                if time >= EVdata(1, ev) || time < EVdata(2,ev)
                    %预测未来电价
                    k1 = 1;
                    if time >= EVdata(1, ev)
                        prePrice = getTout(gridPriceRecord4, t_index , day * I_day + floor(EVdata(2,ev) / T) - t_index);
                        remain_t =  24 + EVdata(2,ev) - time;
                    else
                        prePrice = getTout(gridPriceRecord4, t_index , (day - 1) * I_day + floor(EVdata(2,ev) / T) - t_index);
                        remain_t =  EVdata(2,ev) - time;
                    end
                    [Pmax, Pmin, Pavg] = EVBidPara(T, tmp_E(ev), EVdata_alpha(ev), remain_t, ...
                        EVdata_mile(ev), EVdata_capacity(ev), PN, prePrice);
                    
                    tmp_maxP(ev) = Pmax;
                    tmp_avgP(ev) = Pavg;
                    tmp_minP(ev) = Pmin;
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, EVdata_beta(ev), gridPrice, sigma);
                end
            end
            EVmaxPowerRecord(:, t_index) = tmp_maxP;
            EVavgPowerRecord(:, t_index) = tmp_avgP;
            EVminPowerRecord(:, t_index) = tmp_minP;
        else
            parfor ev = 1: EV
                if time >= EVdata(1, ev) || time < EVdata(2,ev)
                    power_EV = min(PN, (EVdata_alpha(ev) * EVdata_capacity(ev) + (1 - EVdata_alpha(ev)) * EVdata_mile(ev) - tmp_E(ev))/ T);
                    EVpowerRecord(ev, t_index) = power_EV;
                    totalPowerEV = totalPowerEV + power_EV;
                end
            end
        end

        if isTCLflex == 1
            totalPowerIVA = 0;
            N = T_mpc / T;
            IVAmpcPriceRecord = getTout(gridPriceRecord4, t_index, N);     
            ToutRecord = getTout(Tout,i , N); 
            tmp_SOA = zeros(IVA, 1);
            tmp_maxP = zeros(IVA, 1);
            tmp_setP = zeros(IVA, 1);
            tmp_minP = zeros(IVA, 1);
            tmp_T = IVAdata_Ta(:, t_index);
            parfor iva = 1 : IVA
                tcl = iva + FFA;
                %按跟踪目标温度投标
                [Pmax, Pmin, Pset, SOA] = IVABidPara(IVAmpcPriceRecord', tmp_T(iva), ToutRecord, ...
                    TCLdata_T(1, tcl), TCLdata_T(2, tcl), TCLdata_R(1, tcl), TCLdata_C(1, tcl), TCLdata_PN(1, tcl), IVAdata_Pmin(1, iva), ...
                    p1, p2, q1, q2, T);
                tmp_SOA(iva) = SOA;
                tmp_maxP(iva) = Pmax;
                tmp_setP(iva) = Pset;
                tmp_minP(iva) = Pmin;            
                bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, EVdata_beta(mod(tcl - 1, EV) + 1), gridPrice, sigma);          
            end
            IVASOArecord(:, t_index) = tmp_SOA;
            IVAmaxPowerRecord(:, t_index) = tmp_maxP;
            IVAsetPowerRecord(:, t_index) = tmp_setP;
            IVAminPowerRecord(:, t_index) = tmp_minP;
            
            if mod(t_index, I_tcl) == 1
                totalPowerFFA = 0;
                N = T_mpc / T_tcl;
                TCLmpcPriceRecord = getTout(gridPriceRecord, floor(t_index / (T_tcl / T)) + 1, N);
                ToutRecord = zeros(N, 1);
                for n = 1 : N
                    ToutRecord(n) = mean(getTout(Tout,i + (n - 1) * (T_tcl / T), T_tcl / T));
                end
                tmp_Ta = TCLdata_Ta(:, t_index );
                tmp_SOA = zeros(FFA, 1);
                tmp_maxP = zeros(FFA, 1);
                tmp_setP = zeros(FFA, 1);
                tmp_minP = zeros(FFA, 1);
                parfor tcl1 = 1 : FFA
                    [Pmax, Pmin, Pset, SOA] = FFABidPara(TCLmpcPriceRecord',tmp_Ta(tcl1), ToutRecord, ...
                            TCLdata_T(1, tcl1), TCLdata_T(2, tcl1), TCLdata_R(1, tcl1), TCLdata_C(1, tcl1), TCLdata_PN(1, tcl1),...
                            T_tcl);
                    tmp_SOA(tcl1) = SOA;
                    tmp_maxP(tcl1) = Pmax;
                    tmp_setP(tcl1) = Pset;
                    tmp_minP(tcl1) = Pmin;
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, EVdata_beta(mod(tcl1 - 1, EV) + 1), gridPrice, sigma);
                end
                FFASOArecord(:, t_index_tcl) = tmp_SOA;
                TCLmaxPowerRecord(:, t_index_tcl) = tmp_maxP;
                TCLsetPowerRecord(:, t_index_tcl) = tmp_setP;
                TCLminPowerRecord(:, t_index_tcl) = tmp_minP;
            end
        else
            TCLuncontrolled;
            totalPowerFFA =sum(TCLdata_P_benchmark(1: FFA, t_index));
            totalPowerIVA = sum(TCLdata_P_benchmark(FFA + 1: FFA + IVA, t_index));
        end
        %出清
        clcPrice = calculateIntersection(mkt, 0, bidCurve - windPowerRecord(t_index) + loadPowerRecord(t_index) + tielineCurve + totalPowerFFA + totalPowerIVA + totalPowerEV);
        priceRecord(t_index) = clcPrice;
        %反聚合
        %EV
        tmp_E_next = zeros(EV, 1);
        if isEVflex == 1
            tmp_P = zeros(EV, 1);
            parfor ev = 1 : EV
                if time >= EVdata(1,ev) || time < EVdata(2, ev) %接入充电
                    bidCurve = EVbid(mkt, EVmaxPowerRecord(ev, t_index), EVminPowerRecord(ev, t_index), EVavgPowerRecord(ev, t_index),...
                            EVdata_beta(ev), gridPrice, sigma);
                    power_EV = handlePriceUpdate(bidCurve, clcPrice, mkt );
                    tmp_P(ev, 1) = power_EV;
                    totalPowerEV = totalPowerEV + power_EV;
                    tmp_E_next(ev) = tmp_E(ev) + power_EV * T;
                else
                    tmp_E_next(ev) = tmp_E(ev);
                end
            end
        else
            tmp_P = EVpowerRecord(:, t_index);
            parfor ev = 1 : EV
                tmp_E_next(ev) = tmp_E(ev) +tmp_P(ev) * T;
            end
        end
        EVdata_E(:, t_index + 1) = tmp_E_next;
        EV_totalpowerRecord(t_index) = totalPowerEV;
        EVpowerRecord(:, t_index) = tmp_P;

        %FFA
        if isTCLflex == 1
            if mod(t_index, I_tcl) == 1
                parfor tcl = 1 : FFA
                    bidCurve = EVbid(mkt, TCLmaxPowerRecord(tcl, t_index_tcl), TCLminPowerRecord(tcl, t_index_tcl), TCLsetPowerRecord(tcl, t_index_tcl),...
                            EVdata_beta(mod(tcl - 1, EV) + 1), gridPrice, sigma);
                    power_TCL = handlePriceUpdate(bidCurve, clcPrice, mkt );
                    TCLpowerRecord(tcl, t_index_tcl) = power_TCL;
                    totalPowerFFA = totalPowerFFA + power_TCL;
                end
%                 if isEVflex == 1 && isAging == 1%还要记录实际跟踪情况
%                     FFAupdate;
%                 else 
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
%                 end
            end
        end
        TCL_totalpowerRecord(t_index) = totalPowerFFA;
        
        %IVA
        if isTCLflex == 1
            parfor iva = 1 : IVA
                bidCurve = EVbid(mkt, IVAmaxPowerRecord(iva, t_index), IVAminPowerRecord(iva, t_index), IVAsetPowerRecord(iva, t_index),...
                        EVdata_beta(mod( iva + FFA - 1, EV) + 1), gridPrice, sigma);
                power_IVA = handlePriceUpdate(bidCurve, clcPrice, mkt );
                IVApowerRecord(iva, t_index) = power_IVA;
                totalPowerIVA = totalPowerIVA + power_IVA;
            end
            tmp_P = IVApowerRecord(:, t_index);
            tmp_Ta = IVAdata_Ta(:, t_index);
            parfor iva = 1: IVA
                heat_rate_IVA = q1 / p1 * tmp_P(iva) - (q1 * p2 - p1 * q2) / p1;
                tmp_Ta(iva) = theta_a - heat_rate_IVA * TCLdata_R(1, iva + FFA) - (theta_a - heat_rate_IVA * TCLdata_R(1, iva + FFA) - tmp_Ta(iva)) * exp(- T / TCLdata_R(1, iva + FFA) / TCLdata_C(1, iva + FFA));
            end
            IVAdata_Ta(:, t_index + 1) = tmp_Ta;
        end
        IVA_totalpowerRecord(t_index) = totalPowerIVA;
        
        tmp = totalPowerEV + totalPowerFFA + totalPowerIVA;
        tielineRecord(t_index) = tmp - windPowerRecord(t_index) + loadPowerRecord(t_index);%正表示自主网购电，负表示向主网售电
        if isAging == 1
            isBid = 0;
            transformer_ageing_expo;
        end
    end
end
toc;
