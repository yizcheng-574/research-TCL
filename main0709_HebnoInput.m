%基础部分，不含学习部分,使用实际数据 使用heb预测阻塞点,差别是引入调节系数modify
%heb_flag=1 输出为one-hot
%heb_flag=2 输出为期望
%heb_flag=3 滑动平均预测
%heb_flag=0 不预测
clear
EV_total = 600;%EV_total总数，额定功率为3.7kW
T = 15/60;%控制周期15min
T_m = 1/60;%markov周期1min
LOAD = 1800;%LOAD最大负荷（kW）
WIND = 1000;%WIND风电装机容量（kW）
tielineSold = 400;
tielineBuy = 2000;
WEEK = 1;
DAY = WEEK*7;%仿真天数 （1~30）
nod33 = 33;
EV_init;
heb_flag_list = [2 0 0];%0不预测  2HEB 3滑动平均
isHeur_list = [0 0,2];%0-TC;1-启发式;2-按底层结果
lr_now = 1.5;
lr_next = 1.5;
draw_flag = 0;
for simtype = 1
    heb_flag = heb_flag_list(simtype);
    isHeur = isHeur_list(simtype);
    if heb_flag == 0 && isHeur == 0
        tolerance = 0;
    else
        tolerance = 0.01;
    end
    mkt_init;   %市场初始化
    if heb_flag == 2
        preRecord2 = zeros(1,I1);
        preRecord1 = zeros(1,I1);
    end
    actualRecord = zeros(1,I1);
    modify_record = ones(1,I1);
    eval(['flag',num2str(simtype),' = 1;']);
    maxtime = max(EV_td);
    price_preType = 1;
    cost_type = 1;%比较成本
    us_type = 1-cost_type;%比较用户满意度
    day_max = ceil(I1/I);
    totalpowerRecord = zeros(1,I1+I);%EV总充电功率
    tielineRecord = zeros(1,I1);%自联络线购电量
    E = zeros(EV,I1);
    powerRecord = zeros(EV,I1);
    day_index=1*ones(1,EV);
    avgPowerRecord = zeros(EV,I1);
    maxPowerRecord = zeros(EV,I1);
    minPowerRecord = zeros(EV,I1);
    pavgRecord = zeros(1,EV);
    sigmaRecord = zeros(1,EV);
    EV_last_d = zeros(1,EV);
    EV_last_day = zeros(DAY,EV);
    grid_priceRecord = zeros(1,I1);
    priceRecord = zeros(1,I1);
    hasCongest = 0;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

    if heb_flag == 1 || heb_flag == 2
        conge_list = [0.99,1.01,1.03:0.03:1.3 1.7];
        m = length(conge_list) + 1;
        conge_interval(1) =conge_list(1) - 0.1;
        conge_interval(m) = conge_list(end) + 0.1;
        for i = 2 : m - 1
            conge_interval(i) = (conge_list(i-1) + conge_list(i)) / 2;
        end
        for i = 1:I
            eval(['W',num2str(i),' = -1 * ones(m,1); lr = 1;']);
            eval(['W',num2str(i),'(2) = 3;']);
        end
    end
    pre_conge = ones(1,I);
    pre_conge1 = ones(1,I);
    modify = 1;
    for week = 1 : WEEK
        for daynum = 1:7
            day = (week - 1) * 7 + daynum;
            for i = 1:I
                time = day * 24 + i * T - T;
                itera = i + (day - 1) * I;
                if itera > I1
                    break;
                end
                gridPrice = yearPriceRecord(floor(time) + 1);
                wp = windPower(week, (daynum -1) * I + i);
                lp = loadPower(week,(daynum - 1) * I + i);             
                grid_priceRecord(itera) = gridPrice;
                totalPower = 0;
                bidCurve = zeros(1, step + 1);
                %联络线投标
                tielineCurve = zeros(1, step + 1);
                for q = 1 : step + 1
                    if pCurve(q) < gridPrice
                        tielineCurve(q) = tielineSold;
                    elseif pCurve(q) >= gridPrice
                        tielineCurve(q) = -tielineBuy;
                    end
                end
                if itera > 3
                    if  hasCongest == 0 && priceRecord(itera-1) > mkt_max - 0.1 && priceRecord(itera - 2) > mkt_max - 0.1
                        hasCongest = 1;
                    elseif hasCongest == 1 && priceRecord(itera - 1) / grid_priceRecord(itera - 1) < 1.15 && priceRecord(itera - 1) / grid_priceRecord(itera - 1) < 1.15...
                            && grid_priceRecord(itera - 1) < mkt_max - 0.4 && grid_priceRecord(itera - 2) < mkt_max - 0.4
                        hasCongest = 0;
                    end
                end
                for ev = 1 : EV
                    if day_index(ev) <= DAY
                        if time >= EVdata_week(1, ev) + (day_index(ev) - 1) * 24 && time - T < EVdata_week(1, ev) + (day_index(ev) - 1) * 24%新抵达EV)
                            if day_index(ev) == 1
                                E(ev,itera) = 0;
                            else
                                E(ev,itera) = max(0, EV_last_d(ev) - EVdata_mile(1, ev));
                                tmp2 = max(0,EV_last_d(ev) - EVdata_mile(1, ev));
                                tmp3 = EVdata_week(2,ev) + (day_index(ev) - 3) * 24;
                                slope = (EV_last_d(ev) - tmp2)/(itera-floor(tmp3/T)-1);
                                for tmp = floor(tmp3 / T) + 2 : itera - 1
                                    E(ev, tmp) = EV_last_d(ev) - slope * (tmp - floor(tmp3 / T));
                                end
                            end
                        end
                        if time >= EVdata_week(2, ev)+(day_index(ev)-1) * 24 && time - T < EVdata_week(2, ev) + (day_index(ev) - 1) * 24%新离开EV
                            EV_last_d(ev) = E(ev, itera);
                            EV_last_day(day_index(ev), ev) = E(ev, itera);
                            day_index(ev) = day_index(ev) + 1;
                        end
                        if time >= EVdata_week(1, ev) + (day_index(ev) - 1) * 24 && time < EVdata_week(2,ev) + (day_index(ev) - 1) * 24
                            tt = EVdata_week(2,ev) + (day_index(ev)-1)*24;
                            %预测未来电价
                            k1 = 1;
                            meanPrePrice = 0;
                            for tmp = time : T : tt
                                tmp1 = mod(tmp/T + 1,I);
                                if tmp1 == 0
                                    tmp1 = I;
                                end
                                meanPrePrice(k1) = min(yearPriceRecord(floor(tmp) + 1) * pre_conge(tmp1), mkt_max);
                                k1 = k1 + 1;
                            end
                            if isHeur ~= 1
                                pavg = meanPrePrice(1);
                                sigma = 0.1*pavg;
                            elseif isHeur == 1
                                pavg = mean(meanPrePrice);
                                sigma = sqrt(sum((meanPrePrice - pavg).^2) / (length(meanPrePrice)));
                            end
                            pavgRecord(ev)=pavg;
                            sigmaRecord(ev)=sigma;
                            [Pmax, Pmin, Pavg] = BidPara(T, E(ev, itera), EVdata_alpha(ev), tt - time, EVdata_mile(ev), EVdata_capacity(ev), PN);
                            %底层优化算法
                            if isHeur == 0 || isHeur == 2
                                if tt > time   
                                    if hasCongest == 1 && simtype == 1
                                      delta_E = max(0, 0.8 * EVdata_capacity(ev) + (1-0.8) * EVdata_mile(ev) - E(ev, itera));                        
                                    else
                                     delta_E = max(0, EVdata_alpha(ev) * EVdata_capacity(ev) + (1 - EVdata_alpha(ev)) * EVdata_mile(ev) - E(ev, itera));                        
                                    end
                                    if delta_E==0
                                        Pavg=0;
                                    else
                                        [meanpre_price_order, tmp1]= sort(meanPrePrice);
                                        tmp2 = ceil(delta_E / T / PN);
                                        if tmp2 >= length(meanpre_price_order)
                                            Pavg = min(PN, delta_E / T / tmp2);
                                        else
                                            min_bidprice = meanpre_price_order(tmp2);
                                            if tmp2 + 1 <= length(meanpre_price_order)
                                                tmp3 = meanpre_price_order(tmp2 + 1);
                                                while tmp3 - min_bidprice < tolerance
                                                    tmp2 = tmp2 + 1;
                                                    if tmp2 + 1 > length(meanpre_price_order)
                                                        break;
                                                    else
                                                        tmp3 = meanpre_price_order(tmp2 + 1);
                                                    end
                                                end
                                            end 
                                            [tmp4, tmp5] = find(tmp1 == 1);
                                            if tmp5 <= tmp2
                                                Pavg = delta_E / T / tmp2;
                                            else
                                                Pavg = 0;
                                            end
                                        end
                                    end
                                else
                                    Pavg = 0;
                                end
                                if isHeur == 0
                                    Pavg = max(Pmin,Pavg);
                                    Pavg = min(Pmax,Pavg);
                                end
                            end
%                           Pavg=OptiPara( T,E(ev,itera),EVdata_alpha(ev),tt-time,EVdata_mile(ev),EVdata_capacity(ev),PN,meanpre_price) ;
                            maxPowerRecord(ev,itera) = Pmax;
                            avgPowerRecord(ev,itera) = Pavg;
                            minPowerRecord(ev,itera) = Pmin;
                            if isHeur == 2
                                powerRecord(ev,itera) = Pavg;
                            else
                                if hasCongest == 1 && simtype == 1
                                   bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, 3, pavgRecord(ev), sigmaRecord(ev) );                               
                                else
                                   bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, EVdata_beta(ev), pavgRecord(ev), sigmaRecord(ev) );                               
                                end
                            end
                        end
                    end
                end
                if isHeur ~= 2
                    %出清
                    clcPrice = calculateIntersection(mkt, 0, bidCurve - wp + lp + tielineCurve);
                    priceRecord(itera) = clcPrice;
                    %反聚合
                    for ev = 1 : EV
                        if day_index(ev) <= DAY
                            if time >= EVdata_week(1,ev) + (day_index(ev) - 1) * 24 && time < EVdata_week(2, ev) + (day_index(ev) - 1) * 24
                                tt = EVdata_week(2,ev) + (day_index(ev) - 1) * 24;    
                                 if hasCongest == 1 && simtype == 1
                                    bidCurve = EVbid(mkt, maxPowerRecord(ev, itera), minPowerRecord(ev, itera), avgPowerRecord(ev, itera), 3, pavgRecord(ev), sigmaRecord(ev));
                                 else
                                    bidCurve = EVbid(mkt, maxPowerRecord(ev,itera), minPowerRecord(ev,itera), avgPowerRecord(ev,itera), EVdata_beta(ev), pavgRecord(ev), sigmaRecord(ev));
                                 end
                                power_EV = handlePriceUpdate(bidCurve, clcPrice, mkt );
                                powerRecord(ev, itera) = power_EV;
                                totalPower = totalPower + power_EV;
                                E(ev, itera + 1) = E(ev, itera) + power_EV * T;
                            end
                        end
                    end
                else
                    for ev = 1:EV
                        E(ev, itera + 1) = E(ev, itera) + powerRecord(ev, itera) *T;
                    end
                    totalPower = sum(powerRecord(:, itera));
                end
                totalpowerRecord(itera) = totalPower;
                tmp = sum(powerRecord(:,itera));
                tielineRecord(itera) = tmp - wp + lp;%正表示自主网购电，负表示向主网售电
                wr(itera) = wp;
                lr(itera) = lp;
                bus_inj = zeros(1,nod33);
                for ev = 1 : EV
                    bus_inj(EVdata_bus(ev)) = bus_inj(EVdata_bus(ev)) + powerRecord(ev,itera);
                end
                [loss(itera), tielineRecord(itera)] = cal_powerloss(lp, bus_inj, wp);
                INTERVAL = 4;
                if itera > INTERVAL
                    priceMean = mean(priceRecord(itera - INTERVAL : itera));
                    gridpriceMean = mean(grid_priceRecord(itera - INTERVAL : itera));
                    preMean = mean(preRecord1(itera - INTERVAL : itera));
                    modify = priceMean / gridpriceMean / preMean;
                    modify_record(itera + 1) = modify;
                end
                pre_conge_now = pre_conge(i);
                if heb_flag == 1 || heb_flag == 2
                    %调整Heb学习权重
                    x = gridPrice;
                    eval(['y = W',num2str(i),' * 1;']);
                    y = exp(y) / sum(exp(y));
                    a = zeros(m,1);
                    x1 = clcPrice / gridPrice;
                    actualRecord(itera) = x1;
                    if x1 < conge_list(1)
                        a(1) = 1;
                    elseif x1 > conge_list(end)
                        a(end) = 1;
                    else
                        for tmp = 1 : m - 2
                            if x1 >= conge_list(tmp) && x1 < conge_list(tmp + 1)
                                break;
                            end
                        end
                        a(tmp + 1) = 1;
                    end
                    tmp = x';
                    eval(['W',num2str(i),' = W',num2str(i),' + lr_now * (a - y);']);
                end
                %更新预测结果
                if heb_flag == 1
                    %根据heb学习预测,预测值为one-hot
                    if floor(time) + 1 + 24 <= length(yearPriceRecord)
                        x=yearPriceRecord(floor(time) + 1 + 24);%电价为实际电价
                        eval(['y = W',num2str(i),' * 1;']);
                        [a, b] = max(y);
                        if b == 1
                            a = conge_list(1) - 0.1;
                        elseif b==m
                            a = conge_list(end) + 0.1;
                        else
                            a=(conge_list(b - 1) + conge_list(b)) / 2;
                        end
                        pre_conge(i) = a;
                    end
                elseif heb_flag == 2
                    %根据heb学习预测,预测值为期望
                    if floor(time) + 1 + 24 <= length(yearPriceRecord)
                        x=yearPriceRecord(floor(time) + 1 + 24);%电价为实际电价
                        eval(['y = W',num2str(i),' * 1;']);
                        tmp = exp(y) ./ sum(exp(y));
                        a = sum(conge_interval' .* tmp);
                        pre_conge(i) = a;
                    end
                else
                    %不进行预测
                    pre_conge(i) = 1;
                end
                if i == I
                    preRecord1(itera + 1) = pre_conge(1);
                else
                    preRecord1(itera + 1)=pre_conge(i + 1);
                end
                if heb_flag == 2
                    pre_conge1 = pre_conge * modify_record(itera + 1);
                else
                     pre_conge1 = pre_conge;
                end
                for tmp = 1 : I
                    if pre_conge1(tmp) < 1
                        pre_conge1(tmp) = 1;
                    end
                end
                if i == I
                    preRecord2(itera + 1) = pre_conge1(1);
                else
                    preRecord2(itera + 1) = pre_conge1(i + 1);
                end              
                
            end
        end
    end
    prePriceRecord=grid_priceRecord.*preRecord2(1 : end - 1);
    eval(['prePriceRecord',num2str(simtype),' = prePriceRecord;']);
    eval(['E',num2str(simtype),' = E;']);
    eval(['avgPowerRecord',num2str(simtype),' = avgPowerRecord;']);
    eval(['maxPowerRecord',num2str(simtype),' = maxPowerRecord;']);
    eval(['minPowerRecord',num2str(simtype),' = minPowerRecord;']);
    eval(['powerRecord',num2str(simtype),' = powerRecord;']);
    eval(['tielineRecord',num2str(simtype),' = tielineRecord;']);
    eval(['priceRecord',num2str(simtype),' = priceRecord;']);
    eval(['modify_record',num2str(simtype),' = modify_record;']);
    if heb_flag == 2
        eval(['preRecord2',num2str(simtype),' = preRecord2;']);
        eval(['preRecord1',num2str(simtype),' = preRecord1;']);
    end
end