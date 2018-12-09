%单天优化

clc;clear
EV = 600;%EV总数，额定功率为3.7kW
TCL = 1000;%空调总数
T = 15/60;%控制周期15min
LOAD = 1800;%LOAD最大负荷（kW）
WIND = 1500;%WIND风电装机容量（kW）
tielineSold = 400;
tielineBuy = 4000;
nod33 = 33;
tolerance = 0.01;
mkt_init;   %市场初始化
price_init;
totalpowerRecord = zeros(2,I);%EV总充电功率
tielineRecord = zeros(1,I);%自联络线购电量
gridPriceRecord4 = zeros(1,I);
priceRecord = zeros(1,I);
hasCongest = 0;

EV_init;
EVpowerRecord = zeros(EV,I);
EVavgPowerRecord = zeros(1, EV);
EVmaxPowerRecord = zeros(1, EV);
EVminPowerRecord = zeros(1, EV);
EVdata_E = zeros(EV, I + 1);
EVdata_E(:, 1) = unifrnd(0.1, 0.5, EV, 1);

TCL_init;
TCLpowerRecord = zeros(TCL, I);
TCLsetPowerRecord = zeros(1, TCL);
TCLmaxPowerRecord = zeros(1, TCL);
TCLminPowerRecord = zeros(1, TCL);

for t_index = 1: I
    gridPrice = gridPriceRecord(floor((t_index - 1) * T) + 1);
    gridPriceRecord4(t_index) = gridPrice;
end
for t_index = 1 : I
    time = (t_index - 1) * T ;
    gridPrice = gridPriceRecord4(t_index);
    wp = windPowerRecord(t_index);
    lp = loadPowerRecord(t_index);
    totalPowerEV = 0;
    totalPowerTCL = 0;
    bidCurve = zeros(1, step + 1);
    %联络线投标
    tielineCurve = zeros(1, step + 1);
    sigma = sigmaRecord(floor(time) + 1);
    for q = 1 : step + 1
        if pCurve(q) < gridPrice
            tielineCurve(q) = tielineSold;
        elseif pCurve(q) >= gridPrice
            tielineCurve(q) = -tielineBuy;
        end
    end
    if t_index > 3
        if  hasCongest == 0 && priceRecord(t_index-1) > mkt_max - 0.1 && priceRecord(t_index - 2) > mkt_max - 0.1
            hasCongest = 1;
        elseif hasCongest == 1 && priceRecord(t_index - 1) / gridPriceRecord4(t_index - 1) < 1.15 && priceRecord(t_index - 1) / gridPriceRecord4(t_index - 1) < 1.15...
                && gridPriceRecord4(t_index - 1) < mkt_max - 0.4 && gridPriceRecord4(t_index - 2) < mkt_max - 0.4
            hasCongest = 0;
        end
    end
    for ev = 1 : EV
        if time >= EVdata(1, ev) && time < EVdata(2,ev)
            %预测未来电价
            k1 = 1;
            prePrice = gridPriceRecord4(t_index : floor( EVdata(2,ev) / T));
            [Pmax, Pmin, ~] = BidPara(T, EVdata_E(ev, t_index), EVdata_alpha(ev),  EVdata(2,ev) - time, EVdata_mile(ev), EVdata_capacity(ev), PN);
            %底层优化算法
            if hasCongest == 1
                delta_E = max(0, 0.8 * EVdata_capacity(ev) + (1-0.8) * EVdata_mile(ev) - EVdata_E(ev, t_index));
            else
                delta_E = max(0, EVdata_alpha(ev) * EVdata_capacity(ev) + (1 - EVdata_alpha(ev)) * EVdata_mile(ev) - EVdata_E(ev, t_index));
            end
            if delta_E==0
                Pavg=0;
            else
                [meanpre_price_order, tmp1]= sort(prePrice);
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
                clear tmp1 tmp2 tmp3 tmp4 tmp5
            end
            Pavg = max(Pmin,Pavg);
            Pavg = min(Pmax,Pavg);
            EVmaxPowerRecord(1, ev) = Pmax;
            EVavgPowerRecord(1, ev) = Pavg;
            EVminPowerRecord(1, ev) = Pmin;
            if hasCongest == 1
                bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, 3, gridPrice, sigma);
            else
                bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, EVdata_beta(ev), gridPrice, sigma);
            end
        end
    end
    for tcl = 1 : TCL
        [Pmax, Pmin, Pset] = ACload(TCLdata_T(1, tcl), TCLdata_T(2, tcl),  TCLdata_Ta(tcl, time/dt + 1 ),...
            TCLdata_R(1, tcl), TCLdata_C(1, tcl), Tout(time * 60 + 1), TCLdata_PN(1, tcl));
        TCLmaxPowerRecord(1, tcl) = Pmax;
        TCLsetPowerRecord(1, tcl) = Pset;
        TCLminPowerRecord(1, tcl) = Pmin;
        if hasCongest == 1
            bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, 3, gridPrice, sigma);
        else
            bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pset, TCLdata_beta(tcl), gridPrice, sigma);
        end
    end
    %出清
    clcPrice = calculateIntersection(mkt, 0, bidCurve - wp + lp + tielineCurve);
    priceRecord(t_index) = clcPrice;
    %反聚合
    for ev = 1 : EV
        if time >= EVdata(1,ev) && time < EVdata(2, ev)
            if hasCongest == 1
                bidCurve = EVbid(mkt, EVmaxPowerRecord(1, ev), EVminPowerRecord(1, ev), EVavgPowerRecord(1, ev), 3, gridPrice, sigma);
            else
                bidCurve = EVbid(mkt, EVmaxPowerRecord(1, ev), EVminPowerRecord(1, ev), EVavgPowerRecord(1, ev), EVdata_beta(ev), gridPrice, sigma);
            end
            power_EV = handlePriceUpdate(bidCurve, clcPrice, mkt );
            EVpowerRecord(ev, t_index) = power_EV;
            totalPowerEV = totalPowerEV + power_EV;
            EVdata_E(ev, t_index + 1) = EVdata_E(ev, t_index) + power_EV * T;
        elseif time > EVdata(2, ev)
            EVdata_E(ev, t_index + 1) = EVdata_E(ev, t_index);
        end
    end
    for tcl = 1 : TCL
        if hasCongest == 1
            bidCurve = EVbid(mkt, TCLmaxPowerRecord(1, tcl), TCLminPowerRecord(1, tcl), TCLsetPowerRecord(1, tcl), 3, gridPrice, sigma);
        else
            bidCurve = EVbid(mkt, TCLmaxPowerRecord(1, tcl), TCLminPowerRecord(1, tcl), TCLsetPowerRecord(1, tcl), TCLdata_beta(tcl), gridPrice, sigma);
        end
        power_TCL = handlePriceUpdate(bidCurve, clcPrice, mkt );
        TCLpowerRecord(tcl, t_index) = power_TCL;
        totalPowerTCL = totalPowerTCL + power_TCL;
    end
    
    TCLupdate();
    totalpowerRecord(1, t_index) = totalPowerEV;
    totalpowerRecord(2, t_index) = totalPowerTCL;
    tmp = sum(EVpowerRecord(:,t_index)) + sum(TCLpowerRecord(:, t_index));
    tielineRecord(t_index) = tmp - wp + lp;%正表示自主网购电，负表示向主网售电
    wr(t_index) = wp;
    lr(t_index) = lp;
end