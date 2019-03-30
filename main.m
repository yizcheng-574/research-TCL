%考虑随机因素影响
clc; clear;
% sen_index = sen_index + 1;
% load 'D:\CYZ\TCLdata\0228\initData'
startmatlabpool();
tic;
global dt T T_tcl T_mpc I1 I I2
RATIO = 1;
EV = 5 * RATIO;%EV总数，额定功率为3.7kW
FFA = 6 * RATIO;%空调总数
IVA = 4 * RATIO;
T = 15 / 60;%控制周期15min
dt = 1 / 60 / 60;%空调控制周期2s
T_tcl = 1; %空调控制指令周期60min
T_mpc = 6;
I1 = 24 / dt;
I = 24 / T;
I_tcl = T_tcl / T;
I2 = 24 / T_tcl;
LOAD = 20 * RATIO;%LOAD最大负荷（kW）
WIND = 20 * RATIO;%WIND风电装机容量（kW）
tielineSold = 4 * RATIO;
tielineBuy = 28 * RATIO;
nod33 = 33;
tolerance = 0.01;
mktInit;   %市场初始化
priceInit;
EVinit;
TCLinit;
tielineRecord = zeros(1,I);%自联络线购电量
gridPriceRecord4 = zeros(1,I);
priceRecord = zeros(1,I); %考虑预测误差，随机优化的出清电价
priceRecord_noStochastic = zeros(1,I); %不考虑预测误差的出清电价
priceRecord_stochastic = zeros(1, I); %考虑预测误差，确定优化的出清电价
hasCongest = 0;
offset = 12;

isMpc = 1;
isAging = 0;
isEVflex = 1;
isTCLflex = 1;
isOccupRandom = 0;

EV_totalpowerRecord = zeros(1, I);%EV总充电功率
TCL_totalpowerRecord = zeros(1, I);
IVA_totalpowerRecord = zeros(1, I);%EV总充电功率

EVpowerRecord = zeros(EV, I);
EVavgPowerRecord = zeros(EV, I);
EVmaxPowerRecord = zeros(EV, I);
EVminPowerRecord = zeros(EV, I);
EVdata_E = zeros(EV, I);
EVdata_E(:, mod(offset / T , I) + 1) = EVdata_initE .* EVdata_capacity';
totalPowerEV = 0;
if isTCLflex == 1
    
    IVApowerRecord = zeros(IVA, I);
    IVAsetPowerRecord = zeros(IVA, I);
    IVAmaxPowerRecord = zeros(IVA, I);
    IVAminPowerRecord = zeros(IVA, I);
    IVAdata_Ta = zeros(IVA, I);
    IVAdata_Ta(:, mod(offset / T , I) + 1) = TCLdata_initT(FFA + 1, end, 1);
    
    TCLdata_state = ceil(unifrnd(0, 4, 1, FFA));
    TCLdata_Ta = zeros(FFA, 24 / dt);
    TCLdata_P = zeros(FFA, 24 / dt);
    TCLdata_lockTime = zeros(1, FFA);
    TCLpowerRecord = zeros(FFA, I2);
    TCLsetPowerRecord = zeros(FFA, I2);
    TCLmaxPowerRecord = zeros(FFA, I2);
    TCLminPowerRecord = zeros(FFA, I2);
    TCLdata_Ta(:, mod(offset / dt , I1) + 1) =  TCLdata_initT(1 : FFA, 1);
    
    FFASOArecord = zeros(FFA, I2);
    IVASOArecord = zeros(IVA, I);
end
TCLdata_P_benchmark = zeros(FFA + IVA, 24 / dt);
TCLdata_state_benchmark = floor(unifrnd(0, 2, 1, FFA + IVA));
TCLdata_Ta_benchmark = zeros(FFA + IVA, 24 / dt);
if isTCLflex == 1
    TCLdata_Ta_benchmark(:, mod(offset / dt , I1) + 1) = [TCLdata_Ta(:, mod(offset / dt , I1) + 1) ; IVAdata_Ta(:, mod(offset / T , I) + 1)];
else
    TCLdata_Ta_benchmark(:, mod(offset / dt , I1) + 1) = unifrnd(25.8, 26.2, FFA + IVA, 1);
end
if isAging == 1
    TransformerInit;
end
for t_index = 1: I
    gridPrice = gridPriceRecord(floor((t_index - 1) * T) + 1);
    gridPriceRecord4(t_index) = gridPrice;
end
windRecord = zeros(1, I);
loadRecord = zeros(1, I);
sigma_wind = 0;
sigma_load = 0;

IVApsiPreRecord = zeros(1, IVA);
FFApsiPreRecord = zeros(1, FFA);
psiRecord =  zeros(1, IVA + FFA);
for i = 1: I
    t_index = mod(i - 1 + offset / T , I) + 1;
    t_index_tcl = floor(t_index / I_tcl) + 1;
    mod_t = mod(t_index, I) + 1;
    mod_t_1 = mod(t_index - 1, I) + 1;
    time = (t_index - 1) * T ;
    theta_a = mean(Tout( 1 + time * 60 : (time + 0.25) * 60));%C
    gridPrice = gridPriceRecord4(t_index);
    wp = windPowerRecord(t_index) * (1 + normrnd(0, sigma_wind));
    lp = loadPowerRecord(t_index) * (1 + normrnd(0, sigma_load));
    bidCurve = zeros(1, step + 1);
    %联络线投标
    sigma = sigmaRecord(floor(time) + 1);
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
    if t_index > 3
        if  hasCongest == 0 && priceRecord(t_index-1) > mkt_max - 0.1 && priceRecord(t_index - 2) > mkt_max - 0.1
            hasCongest = 1;
        elseif hasCongest == 1 && priceRecord(t_index - 1) / gridPriceRecord4(t_index - 1) < 1.15 ...
                && priceRecord(t_index - 1) / gridPriceRecord4(t_index - 1) < 1.15...
                && gridPriceRecord4(t_index - 1) < mkt_max - 0.4 && gridPriceRecord4(t_index - 2) < mkt_max - 0.4
            hasCongest = 0;
        end
    end
    totalPowerEV = 0;
    tmp_E =  EVdata_E(:, t_index);
    parfor ev = 1 : EV
        if isEVflex == 1
            if time >= EVdata(1, ev) || time < EVdata(2,ev)
                %预测未来电价
                if time >= EVdata(1, ev)
                    prePrice = [ gridPriceRecord4(t_index : I ) , gridPriceRecord4(1 : floor( EVdata(2,ev) / T)) ];
                    remain_t =  EVdata(2,ev) + 24 - time;
                else
                    prePrice = gridPriceRecord4(t_index : floor( EVdata(2,ev) / T));
                    remain_t =  EVdata(2,ev) - time;
                end
                [Pmax, Pmin, Pavg] = EVBidPara(T, tmp_E(ev), EVdata_alpha(ev), remain_t, ...
                    EVdata_mile(ev), EVdata_capacity(ev), PN, prePrice);
                
                EVmaxPowerRecord(ev, t_index) = Pmax;
                EVavgPowerRecord(ev, t_index) = Pavg;
                EVminPowerRecord(ev, t_index) = Pmin;
                if hasCongest == 1
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, 2, gridPrice, sigma);
                else
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, EVdata_beta(ev), gridPrice, sigma);
                end
            end
        else
            if time >= EVdata(1, ev) || time < EVdata(2,ev)
                power_EV = min(PN, (EVdata_alpha(ev) * EVdata_capacity(ev) + (1 - EVdata_alpha(ev)) * EVdata_mile(ev) - tmp_E(ev))/ T);
                EVpowerRecord(ev, t_index) = power_EV;
                totalPowerEV = totalPowerEV + power_EV;
                EVdata_E(ev, mod_t) = tmp_E + power_EV * T;
            end
        end
    end
    if isOccupRandom == 1
        psiRecord(1, FFA + 1: end) = normrnd(0, 1.5, 1, IVA); %当前周期实际扰动误差
        psiRecord(psiRecord < 0) = 0;
    end
    if isTCLflex == 1
        totalPowerIVA = 0;
        parfor iva = 1 : IVA
            tcl = iva + FFA;
            N = T_mpc / T;
            IVAmpcPriceRecord = zeros(N, 1);
            ToutRecord = zeros(N, 1);
            for n = 1 : N
                IVAmpcPriceRecord(n) = gridPriceRecord(floor(mod(time + T * (n - 1), 24)) + 1);
                minute_s = mod(time * 60 + T * (n - 1) * 60 + 1, 1440);
                minute_e = time * 60 + T * n * 60;
                if minute_e > 1440
                    minute_e = minute_e - 1440;
                end
                if minute_e < minute_s
                    x = 1;
                end
                ToutRecord(n) = mean(Tout(minute_s :minute_e));
            end
            %按跟踪目标温度投标
            [Pmax, Pmin, Pset, SOA1] = IVABidPara(IVAmpcPriceRecord, IVAdata_Ta(iva, t_index), ToutRecord, ...
                TCLdata_T(1, tcl), TCLdata_T(2, tcl), TCLdata_R(1, tcl), TCLdata_C(1, tcl), TCLdata_PN(1, tcl), IVAdata_Pmin(1, iva), IVApsiPreRecord(1, iva), ...
                p1, p2, q1, q2, T);
            IVASOArecord(iva, t_index) = SOA1;
            IVAmaxPowerRecord(iva, t_index) = Pmax;
            IVAsetPowerRecord(iva, t_index) = Pset;
            IVAminPowerRecord(iva, t_index) = Pmin;
            if hasCongest == 1
                bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, 2, gridPrice, sigma);
            else
                bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, EVdata_beta(mod(tcl - 1, EV) + 1), gridPrice, sigma);
            end
        end
        if mod(t_index, I_tcl) == 1
            if isOccupRandom == 1
                psiRecord(1, 1 : FFA) = normrnd(0, 1.5, 1, FFA); %当前周期实际扰动误差
                psiRecord(psiRecord < 0) = 0;
            end
            N = T_mpc / T_tcl;
            totalPowerFFA = 0;
            TCLmpcPriceRecord = zeros(N, 1);
            ToutRecord = zeros(N, 1);
            for n = 1 : N
                TCLmpcPriceRecord(n) = gridPriceRecord(floor(mod(time + T_tcl * (n - 1), 24)) + 1);
                minute_s = mod(time * 60 + T_tcl * (n - 1) * 60 + 1, 1440);
                minute_e = time * 60 + T_tcl * n * 60;
                if minute_e > 1440
                    minute_e = minute_e - 1440;
                end
                if minute_e < minute_s
                    x = 1;
                end
                ToutRecord(n) = mean(Tout(minute_s :minute_e));
            end
            parfor tcl1 = 1 : FFA
                %按跟踪目标温度投标
                if isMpc == 0
                    [Pmax, Pmin, Pset] = ACload(TCLdata_T(1, tcl1), TCLdata_T(2, tcl1),  TCLdata_Ta(tcl1, time / dt + 1 ),...
                        TCLdata_R(1, tcl1), TCLdata_C(1, tcl1), Tout(time * 60 + 1), TCLdata_PN(1, tcl1),...
                        T_tcl);
                else %按底层mpc投标
                    [Pmax, Pmin, Pset, SOA] = FFABidPara(TCLmpcPriceRecord, TCLdata_Ta(tcl1, time / dt + 1), ToutRecord, ...
                        TCLdata_T(1, tcl1), TCLdata_T(2, tcl1), TCLdata_R(1, tcl1), TCLdata_C(1, tcl1), TCLdata_PN(1, tcl1), FFApsiPreRecord(1, tcl1),...
                        T_tcl);
                end
                FFASOArecord(tcl1, t_index_tcl) = SOA;
                TCLmaxPowerRecord(tcl1, t_index_tcl) = Pmax;
                TCLsetPowerRecord(tcl1, t_index_tcl) = Pset;
                TCLminPowerRecord(tcl1, t_index_tcl) = Pmin;
                if hasCongest == 1
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, 2, gridPrice, sigma);
                else
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset,EVdata_beta(mod(tcl1 - 1, EV) + 1), gridPrice, sigma);
                end
            end
        end
    end
    TCLuncontrolled;
    if isTCLflex == 0
        totalPowerFFA = mean(sum(TCLdata_P_benchmark(1: FFA, time / dt + 1 : (time + T) / dt)));
        totalPowerIVA = mean(sum(TCLdata_P_benchmark(FFA + 1: FFA + IVA, time / dt + 1 : (time + T) / dt)));
    end
    %出清
    clcPrice = calculateIntersection(mkt, 0, bidCurve - wp + lp + tielineCurve + totalPowerFFA + totalPowerIVA + totalPowerEV);
    priceRecord(t_index) = clcPrice;
    %反聚合
    %EV
    if isEVflex == 1
        parfor ev = 1 : EV
            if time >= EVdata(1,ev) || time < EVdata(2, ev)
                if hasCongest == 1
                    bidCurve = EVbid(mkt, EVmaxPowerRecord(ev, t_index), EVminPowerRecord(ev, t_index), EVavgPowerRecord(ev, t_index),...
                        2, gridPrice, sigma);
                else
                    bidCurve = EVbid(mkt, EVmaxPowerRecord(ev, t_index), EVminPowerRecord(ev, t_index), EVavgPowerRecord(ev, t_index),...
                        EVdata_beta(ev), gridPrice, sigma);
                end
                power_EV = handlePriceUpdate(bidCurve, clcPrice, mkt );
                EVpowerRecord(ev, t_index) = power_EV;
                totalPowerEV = totalPowerEV + power_EV;
                EVdata_E(ev, mod_t) = tmp_E(ev) + power_EV * T;
            elseif time > EVdata(2, ev)
                EVdata_E(ev, mod_t) = tmp_E(ev);
            end
        end
    end
    EV_totalpowerRecord(t_index) = totalPowerEV;
    
    %FFA
    if isTCLflex == 1
        if mod(t_index, I_tcl) == 1
            parfor tcl2 = 1 : FFA
                if hasCongest == 1
                    bidCurve = EVbid(mkt, TCLmaxPowerRecord(tcl2, t_index_tcl), TCLminPowerRecord(tcl2, t_index_tcl), TCLsetPowerRecord(tcl2, t_index_tcl),...
                        2, gridPrice, sigma);
                else
                    bidCurve = EVbid(mkt, TCLmaxPowerRecord(tcl2, t_index_tcl), TCLminPowerRecord(tcl2, t_index_tcl), TCLsetPowerRecord(tcl2, t_index_tcl),...
                        EVdata_beta(mod(tcl2 - 1, EV) + 1), gridPrice, sigma);
                end
                power_TCL = handlePriceUpdate(bidCurve, clcPrice, mkt );
                TCLpowerRecord(tcl2, t_index_tcl) = power_TCL;
                totalPowerFFA = totalPowerFFA + power_TCL;
            end
            FFAupdate;
        end
    end
    TCL_totalpowerRecord(t_index) = totalPowerFFA;
    
    %IVA
    if isTCLflex == 1
        parfor iva = 1 : IVA
            if hasCongest == 1
                bidCurve = EVbid(mkt, IVAmaxPowerRecord(iva, t_index), IVAminPowerRecord(iva, t_index), IVAsetPowerRecord(iva, t_index),...
                    2, gridPrice, sigma);
            else
                bidCurve = EVbid(mkt, IVAmaxPowerRecord(iva, t_index), IVAminPowerRecord(iva, t_index), IVAsetPowerRecord(iva, t_index),...
                    EVdata_beta(mod( iva + FFA - 1, EV) + 1), gridPrice, sigma);
            end
            power_IVA = handlePriceUpdate(bidCurve, clcPrice, mkt );
            IVApowerRecord(iva, t_index) = power_IVA;
            totalPowerIVA = totalPowerIVA + power_IVA;
        end
        for iva = 1: IVA
            heat_rate_IVA = q1 / p1 * IVApowerRecord(iva, t_index) - (q1 * p2 - p1 * q2) / p1 - psiRecord(1, iva + FFA);
            IVAdata_Ta(iva, mod_t) = theta_a - heat_rate_IVA * TCLdata_R(1, iva + FFA) - (theta_a - heat_rate_IVA * TCLdata_R(1, iva + FFA) - IVAdata_Ta(iva, t_index)) * exp(- T / TCLdata_R(1, iva + FFA) / TCLdata_C(1, iva + FFA));
        end
    end
    IVA_totalpowerRecord(t_index) = totalPowerIVA;
    
    tmp = totalPowerEV + totalPowerFFA + totalPowerIVA;
    tielineRecord(t_index) = tmp - windPowerRecord(t_index) + loadPowerRecord(t_index);%正表示自主网购电，负表示向主网售电
    windRecord(t_index) = wp;
    loadRecord(t_index) = lp;
    if isAging == 1
        isBid = 0;
        transformer_ageing_expo;
    end
    if isOccupRandom == 1
        %根据上一周期预测的当前周期误差
        IVApsiPreRecord = psiRecord(1, FFA + 1: end); %不考虑RC误差情况下，准确得到上一周期误差
        %FFA预测在FFAupdate内
    end
end

toc;
closematlabpool();
tongji;

