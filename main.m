%单天优化

clc;clear
EV = 600;%EV_total总数，额定功率为3.7kW
T = 15/60;%控制周期15min
LOAD = 1800;%LOAD最大负荷（kW）
WIND = 1500;%WIND风电装机容量（kW）
tielineSold = 400;
tielineBuy = 2000;
nod33 = 33;
EV_init;
tolerance = 0.01;
mkt_init;   %市场初始化
price_init;
totalpowerRecord = zeros(1,I);%EV总充电功率
tielineRecord = zeros(1,I);%自联络线购电量
E = zeros(EV,I);
E(:, 1) = unifrnd(0.1, 0.5, EV, 1);
powerRecord = zeros(EV,I);
avgPowerRecord = zeros(EV,I);
maxPowerRecord = zeros(EV,I);
minPowerRecord = zeros(EV,I);
gridPriceRecord4 = zeros(1,I);
priceRecord = zeros(1,I);
hasCongest = 0;

for i = 1: I
    gridPrice = gridPriceRecord(floor((i - 1) * T) + 1);
    gridPriceRecord4(i) = gridPrice;
end
for i = 1 : I
    time = (i - 1) * T ;
    gridPrice = gridPriceRecord4(i);
    wp = windPowerRecord(i);
    lp = loadPowerRecord(i);
    totalPower = 0;
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
    if i > 3
        if  hasCongest == 0 && priceRecord(i-1) > mkt_max - 0.1 && priceRecord(i - 2) > mkt_max - 0.1
            hasCongest = 1;
        elseif hasCongest == 1 && priceRecord(i - 1) / gridPriceRecord4(i - 1) < 1.15 && priceRecord(i - 1) / gridPriceRecord4(i - 1) < 1.15...
                && gridPriceRecord4(i - 1) < mkt_max - 0.4 && gridPriceRecord4(i - 2) < mkt_max - 0.4
            hasCongest = 0;
        end
    end
    for ev = 1 : EV
        if time >= EVdata(1, ev) && time < EVdata(2,ev)
            %预测未来电价
            k1 = 1;
            prePrice = gridPriceRecord4(i : floor( EVdata(2,ev) / T));
            [Pmax, Pmin, ~] = BidPara(T, E(ev, i), EVdata_alpha(ev),  EVdata(2,ev) - time, EVdata_mile(ev), EVdata_capacity(ev), PN);
            %底层优化算法
            if hasCongest == 1
                delta_E = max(0, 0.8 * EVdata_capacity(ev) + (1-0.8) * EVdata_mile(ev) - E(ev, i));
            else
                delta_E = max(0, EVdata_alpha(ev) * EVdata_capacity(ev) + (1 - EVdata_alpha(ev)) * EVdata_mile(ev) - E(ev, i));
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
            maxPowerRecord(ev,i) = Pmax;
            avgPowerRecord(ev,i) = Pavg;
            minPowerRecord(ev,i) = Pmin;
            if hasCongest == 1
                bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, 3, gridPrice, sigma);
            else
                bidCurve = bidCurve + EVbid(mkt, Pmax, Pmin, Pavg, EVdata_beta(ev), gridPrice, sigma);
            end
        end
    end
    %出清
    clcPrice = calculateIntersection(mkt, 0, bidCurve - wp + lp + tielineCurve);
    priceRecord(i) = clcPrice;
    %反聚合
    for ev = 1 : EV
        if time >= EVdata(1,ev) && time < EVdata(2, ev)
            if hasCongest == 1
                bidCurve = EVbid(mkt, maxPowerRecord(ev, i), minPowerRecord(ev, i), avgPowerRecord(ev, i), 3, gridPrice, sigma);
            else
                bidCurve = EVbid(mkt, maxPowerRecord(ev,i), minPowerRecord(ev,i), avgPowerRecord(ev,i), EVdata_beta(ev), gridPrice, sigma);
            end
            power_EV = handlePriceUpdate(bidCurve, clcPrice, mkt );
            powerRecord(ev, i) = power_EV;
            totalPower = totalPower + power_EV;
            E(ev, i + 1) = E(ev, i) + power_EV * T;
        elseif time > EVdata(2, ev)
             E(ev, i + 1) = E(ev, i);
        end
    end
    totalpowerRecord(i) = totalPower;
    tmp = sum(powerRecord(:,i));
    tielineRecord(i) = tmp - wp + lp;%正表示自主网购电，负表示向主网售电
    wr(i) = wp;
    lr(i) = lp;
end