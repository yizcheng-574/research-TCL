% 见main_EVTCL.m
% 预测部分参考main_EVpenes.m
tic;

tielineRecord = zeros(1,I); % 自联络线购电量
if isTCLflex ~= 0 || isEVflex == 1
    priceRecord = zeros(1,I); % 考虑预测误差，随机优化的出清电价
    hasCongest = 0;
end

EV_totalavgPowerRecord = zeros(1, I);

EV_totalpowerRecord = zeros(1, I); % EV总充电功率
TCL_totalpowerRecord = zeros(1, I);
IVA_totalpowerRecord = zeros(1, I);

EVpowerRecord = zeros(EV, I);
EVdata_E = zeros(EV, I);
EVdata_E(:, 1) = EVdata_initE .* EVdata_capacity';
totalPowerEV = 0;

if isEVflex == 1
    EVavgPowerRecord = zeros(EV, 1);
    EVmaxPowerRecord = zeros(EV, 1);
    EVminPowerRecord = zeros(EV, 1);
end
isUserAtHome = zeros(EV, 1);
TCLinstantPowerRecord = zeros(1, I1);

if isTCLflex ~= 0   
    IVApowerRecord = zeros(IVA, I);
    IVAsetPowerRecord = zeros(IVA, 1);
    IVAmaxPowerRecord = zeros(IVA, 1);
    IVAminPowerRecord = zeros(IVA, 1);
    IVAdata_Ta = zeros(IVA, I);
    IVAdata_Ta(:, 1) = TCLdata_initT(FFA + 1, end, 1);
    
    TCLdata_state = ceil(unifrnd(0, 4, 1, FFA));
    TCLdata_Ta = zeros(FFA, I);
    TCLdata_lockTime = zeros(1, FFA);
    TCLpowerRecord = zeros(FFA, I2);
    TCLsetPowerRecord = zeros(FFA, 1);
    TCLmaxPowerRecord = zeros(FFA, 1);
    TCLminPowerRecord = zeros(FFA, 1);
    TCLdata_Ta(:, 1) =  TCLdata_initT(1 : FFA, 1);   
else
    TCLdata_state = floor(unifrnd(0, 2, 1, FFA + IVA));
    TCLdata_P = zeros(FFA + IVA, I);
    TCLdata_Ta = zeros(FFA + IVA, I);
    TCLdata_Ta(:, 1) = TCLdata_initT;
end
TransformerInit;

if isHeb == 1
    congeMin = 0.4;
    congeMax = mkt_max * 1.1;
    congeList = congeMin: 0.05: congeMax;
    m = length(congeList) - 1;
    congeQujian = zeros(1, m);
    for i = 1 : m
        congeQujian(i) = (congeList(i) + congeList(i + 1)) / 2;
    end
%     W = -1 * ones(m, I_day);
    load('../data/heb_weight.mat');
    prePriceRecord = zeros(1, I);
end
preConge = gridPriceOneDay;

for day = 1 : DAY
    for i = 1: I_day
        t_index = (day - 1) * I_day + i;
        t_index_tcl = floor(t_index / I_tcl) + 1;
        time = (i - 1) * T ; % 当前时长（24小时制）
        time_all = (t_index - 1) * T; % 总时长
        theta_a = Tout(i); % C %Tout
        gridPrice = gridPriceOneDay(i);
        sigma = sigmaRecordOneDay(i);
        
        bidCurve = zeros(1, step + 1);
        % 联络线投标
        if isAging == 1 || (isAging == 2 && gridPrice == priceValley)% 考虑变压器损耗 或 分时段采用不同策略
            isBid = 1;
            transformer_ageing_expo;
        else % 不考虑变压器损耗
            tielineCurve = zeros(1, step + 1);
            for q = 1 : step + 1
                if pCurve(q) < gridPrice
                    tielineCurve(q) = tielineSold;
                elseif pCurve(q) >= gridPrice
                    tielineCurve(q) = - tielineBuy;
                end
            end
            maxPower = tielineSold;
        end
        
        totalPowerEV = 0;
        tmp_E = abs(EVdata_E(:, t_index));
           
        parfor ev = 1 : EV
            if time >= EVdata(2, ev) && time - T < EVdata(2, ev)
                tmp_E(ev) = max(tmp_E(ev) - EVdata_mile(ev), 0);
            end
        end
        
        updateACLon_offstate;
        
        if isEVflex == 1
            EVavgPowerRecord = zeros(EV, 1);
            EVmaxPowerRecord = zeros(EV, 1);
            EVminPowerRecord = zeros(EV, 1);
        end

        if isEVflex == 1 
            parfor ev = 1 : EV
                if isUserAtHome(ev)
                     % 预测未来电价
                    k1 = 1;
                    if time >= EVdata(1, ev)
                        prePrice = getTout(repmat(preConge, 1, DAY), t_index , day * I_day + floor(EVdata(2,ev) / T) - t_index);
                        remain_t =  24 + EVdata(2,ev) - time;
                    else
                        prePrice = getTout(repmat(preConge, 1, DAY), t_index , (day - 1) * I_day + floor(EVdata(2,ev) / T) - t_index);
                        remain_t =  EVdata(2,ev) - time;
                    end
                    [Pmax, Pmin, Pavg] = EVBidPara(T, tmp_E(ev), EVdata_alpha(ev), remain_t, ...
                        EVdata_mile(ev), EVdata_capacity(ev), PN, prePrice); 
                    EVmaxPowerRecord(ev) = Pmax;
                    EVavgPowerRecord(ev) = Pavg;
                    EVminPowerRecord(ev) = Pmin;
                    bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, EVdata_beta(ev), gridPrice, sigma);
                end
            end
            EV_totalavgPowerRecord(t_index) = sum(EVavgPowerRecord);
        else
            tmp_P = zeros(EV, 1);
            parfor ev = 1: EV
                if isUserAtHome(ev)
                    power_EV = min(PN, (EVdata_alpha(ev) * EVdata_capacity(ev) + (1 - EVdata_alpha(ev)) * EVdata_mile(ev) - tmp_E(ev))/ T);
                    tmp_P(ev) = power_EV;
                end
            end
            totalPowerEV = sum(tmp_P);
            EVpowerRecord(:, t_index) = tmp_P;
        end

        if isTCLflex ~= 0
            totalPowerIVA = 0;
            N = T_mpc / T;
            IVAmpcPriceRecord = getTout(repmat(preConge, 1, DAY), t_index, N);     
            ToutRecord = getTout(Tout,i , N);
            tmp_T = abs(IVAdata_Ta(:, t_index));
            parfor iva = 1 : IVA
                tcl = iva + FFA;
                if isIVAon(iva)
                     % 按跟踪目标温度投标
                    [Pmax, Pmin, Pset] = IVABidPara(IVAmpcPriceRecord', tmp_T(iva), ToutRecord, ...
                        TCLdata_T(1, tcl), TCLdata_T(2, tcl), TCLdata_R(1, tcl), TCLdata_C(1, tcl), TCLdata_PN(1, tcl), IVAdata_Pmin(1, iva), ...
                        p1, p2, q1, q2, T, ratioIVA);
                    IVAmaxPowerRecord(iva) = Pmax;
                    IVAsetPowerRecord(iva) = Pset;
                    IVAminPowerRecord(iva) = Pmin;
                    if isTCLflex == 1
                        bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, EVdata_beta(mod(tcl - 1, EV) + 1), gridPrice, sigma);          
                    end
                end
            end
            if mod(t_index, I_tcl) == 1
                totalPowerFFA = 0;
                N = T_mpc / T_tcl;
                preCongePerh = mean(reshape(preConge, 4, 24));
                TCLmpcPriceRecord = getTout(repmat(preCongePerh, 1, DAY), floor(t_index / (T_tcl / T)) + 1, N);
                ToutRecord = zeros(N, 1);
                for n = 1 : N
                    ToutRecord(n) = mean(getTout(Tout,i + (n - 1) * (T_tcl / T), T_tcl / T));
                end
                tmp_Ta = abs(TCLdata_Ta(:, t_index ));
                parfor tcl = 1 : FFA
                    if isFFAon(tcl)
                        [Pmax, Pmin, Pset] = FFABidPara(TCLmpcPriceRecord',tmp_Ta(tcl), ToutRecord, ...
                                TCLdata_T(1, tcl), TCLdata_T(2, tcl), TCLdata_R(1, tcl), TCLdata_C(1, tcl), TCLdata_PN(1, tcl),...
                                T_tcl, ratioFFA);
                        TCLmaxPowerRecord(tcl) = Pmax;
                        TCLsetPowerRecord(tcl) = Pset;
                        TCLminPowerRecord(tcl) = Pmin;
                        bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, EVdata_beta(mod(tcl - 1, EV) + 1), gridPrice, sigma);
                    end
                end
            end
            if isTCLflex == 2
                totalPowerIVA = sum(IVAsetPowerRecord);
                IVApowerRecord(:, t_index) = IVAsetPowerRecord;
                if mod(t_index, I_tcl) == 1
                    totalPowerFFA = sum(TCLsetPowerRecord);
                    TCLpowerRecord(:, t_index_tcl) = TCLsetPowerRecord;
                end
            end
        else
            TCLuncontrolledComfort;
            totalPowerFFA =sum(TCLdata_P(1: FFA, t_index));
            totalPowerIVA = sum(TCLdata_P(FFA + 1: FFA + IVA, t_index));
        end
        if isTCLflex == 1 || isEVflex == 1
         % 出清
            % 找到市场价对应的功率，如果小于maxPower, 则直接出清价格为市场价
            indexToGridPrice = (gridPrice - mkt_min)/ (mkt_max - mkt_min) * step + 1;
            indexToGridPrice = floor(indexToGridPrice);
            if bidCurve(indexToGridPrice) - windPowerRecord(t_index) + loadPowerRecord(t_index) + totalPowerFFA + totalPowerIVA + totalPowerEV <= maxPower * eta
                clcPrice = gridPrice;
            else
                clcPrice = calculateIntersection(mkt, 0, bidCurve - windPowerRecord(t_index) + loadPowerRecord(t_index) + eta * tielineCurve + totalPowerFFA + totalPowerIVA + totalPowerEV);
            end
            priceRecord(t_index) = clcPrice;

            % 更新sigma数据
            iPriceRecord = reshape(priceRecord, DAY, I_day);
            iPriceRecord = iPriceRecord(1 : day, i);
%             sigmaRecordOneDay(i) = sqrt(sum((iPriceRecord - mean(iPriceRecord)).^2) / day);
        end
         % 反聚合
         % EV
        tmp_E_next = zeros(EV, 1);
        if isEVflex == 1
            tmp_P = zeros(EV, 1);
            for ev = 1 : EV
                if isUserAtHome(ev)
                    bidCurve = EVbid(mkt, EVmaxPowerRecord(ev), EVminPowerRecord(ev), EVavgPowerRecord(ev),...
                            EVdata_beta(ev), gridPrice, sigma);
                    power_EV = handlePriceUpdate(bidCurve, clcPrice, mkt);
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
        EVdata_E(1:EV, t_index + 1) = tmp_E_next;
        EV_totalpowerRecord(t_index) = totalPowerEV;
        EVpowerRecord(:, t_index) = tmp_P;

        % FFA
        if isTCLflex ~= 0
            if mod(t_index, I_tcl) == 1
                if isTCLflex == 1
                    parfor tcl = 1 : FFA
                        if isFFAon(tcl)
                            bidCurve = EVbid(mkt, TCLmaxPowerRecord(tcl), TCLminPowerRecord(tcl), TCLsetPowerRecord(tcl),...
                                    EVdata_beta(mod(tcl - 1, EV) + 1), gridPrice, sigma);
                            power_TCL = handlePriceUpdate(bidCurve, clcPrice, mkt );
                            TCLpowerRecord(tcl, t_index_tcl) = power_TCL;
                            totalPowerFFA = totalPowerFFA + power_TCL;
                        end
                    end
                end
 %                  if isEVflex == 1 && isAging == 1%还要记录实际跟踪情况
 %                      FFAupdate;
 %                  else 
                    tmp_P = TCLpowerRecord(:, t_index_tcl);
                    for sub_i = 1 : T_tcl / T
                        T0 = getTout(Tout, i + sub_i - 1, 1);
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
 %                  end
            end
        end
        
        TCL_totalpowerRecord(t_index) = totalPowerFFA;
        
        % IVA
        if isTCLflex ~= 0
            if isTCLflex == 1
                parfor iva = 1 : IVA
                    if isIVAon(iva)
                    bidCurve = EVbid(mkt, IVAmaxPowerRecord(iva), IVAminPowerRecord(iva), IVAsetPowerRecord(iva),...
                            EVdata_beta(mod( iva + FFA - 1, EV) + 1), gridPrice, sigma);
                    power_IVA = handlePriceUpdate(bidCurve, clcPrice, mkt );
                    IVApowerRecord(iva, t_index) = power_IVA;
                    totalPowerIVA = totalPowerIVA + power_IVA;
                    end
                end
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
        tielineRecord(t_index) = (tmp - windPowerRecord(t_index) + loadPowerRecord(t_index))/eta; % 正表示自主网购电，负表示向主网售电

        if isHeb == 1
            % 调整Heb学习权重
            y = W(:, i);
            y = exp(y) / sum(exp(y));
            a = zeros(m, 1);
            x = clcPrice;
            if x < congeList(1)
                a(1) = 1;
            elseif x > congeList(end)
                a(end) = 1;
            else
                for tmp = 1 : m-1
                    if x >= congeList(tmp) && x < congeList(tmp+1)
                        break;
                    end
                end
                a(tmp) = 1;
                clear tmp
            end
            W(:, i) = W(:, i) + 1.5 * (a - y);
            
            % 根据heb学习预测,预测值为期望
            y = W(:, i);
            tmp = exp(y) ./ sum(exp(y));
            preResult = sum(congeQujian' .* tmp);
            preConge (i) = preResult;
            prePriceRecord(t_index) = preResult;
        end

        if isAging == 1 || isAging == 2
            isBid = 0; transformer_ageing_expo;
        end
    end
end

toc;
cal_cost;