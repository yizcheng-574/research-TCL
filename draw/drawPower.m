function [] = drawPower(path, titleName, t, c1, c2, c3, c4, Linestyle, index, isOneday)
global totalCostRecord relativeAgingRecord lfRecord isEn howManyDays
theta_h_record = 1;
load(path, ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord', 'EV_totalavgPowerRecord',...
    'DSO_cost', 'tielineBuy', 'DL_record', ...
    'DAY', 'T', 'I',...
    'gridPriceRecord4', 'priceRecord', 'loadPowerRecord', 'windPowerRecord');

if isOneday > 0
    st = isOneday * 96 + 1;
    en = st + 96 * howManyDays - 1;
else
    st = 49;
    en = I;
end
t = t(st:en);
figure;
yyaxis left;
if exist('priceRecord', 'var') == 1
    Hprice = bar(t, [gridPriceRecord4(st: en); priceRecord(st:en)-gridPriceRecord4(st: en)]', 'stacked');
    Hprice(1).EdgeColor = 'none';
    Hprice(1).FaceColor = [0.8, 0.8, 0.8];
    Hprice(2).EdgeColor = 'none';
    Hprice(2).FaceColor = [0, 173, 52 ]/255;
else
    Hprice = bar(t, gridPriceRecord4(st: en)');
    Hprice.EdgeColor = 'none';
    Hprice.FaceColor = [0.8, 0.8, 0.8];
end
ylabel('主网电价(元/kWh)')
yyaxis right;
hold on;
DSO_cost(2) = (tielineRecord - loadPowerRecord + windPowerRecord) * gridPriceRecord4' * T;

tielineRecord = tielineRecord(st: en);
EV_totalpowerRecord = EV_totalpowerRecord(st: en);
TCL_totalpowerRecord = TCL_totalpowerRecord(st: en);
IVA_totalpowerRecord = IVA_totalpowerRecord(st: en);


maxY = max(tielineRecord)/tielineBuy * 1.05;
Ht = stairs(t, tielineRecord / tielineBuy , 'color', c1, 'LineWidth', 1.5, 'LineStyle', Linestyle, 'marker', 'none');
Hev = stairs(t, EV_totalpowerRecord(1:length(t)) / tielineBuy , 'color', c3, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'd', 'MarkerSize', 3 );
Htcl = stairs(t, (TCL_totalpowerRecord + IVA_totalpowerRecord) / tielineBuy , 'color', c3, 'LineWidth', 1.5,'LineStyle', '--', 'marker', 'none');
limit1 = plot(t, ones(1, length(t)), 'color', c4, 'LineWidth' , 1, 'LineStyle', '--', 'DisplayName', '功率上限', 'marker', 'none');
limit2 = plot(t, 1.2 * ones(1, length(t)), 'color', c4, 'LineWidth' , 1, 'LineStyle', '--', 'DisplayName', '功率上限', 'marker', 'none');
for d = 1: DAY - 1
drawVerticalLine(24 * d, 0, maxY, 'black', ':')
end
ylim([0, maxY]);
if isEn == 1
    ylabel('power(MW)')
    set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);
else
    ylabel('功率标幺值(p.u.)')
    set(gcf,'Position',[0 0 650 250]);
end
drawTimeAxis;

% title(titleName)

if isEn == 1
    le = legend([Ht, Hev, Htcl, Hprice(1), limit1, limit2], 'transformer', 'EV', 'ACL','RTP','P_T^N','1.2P_T^N', ...
        'Orientation','horizontal');
else
    if exist('priceRecord', 'var') == 1
        le = legend([Hprice(1), Hprice(2), Ht, Hev, Htcl, limit1, limit2], '主网电价', '出清电价' ,'变压器', '电动汽车', '空调负荷', ...
                'Orientation','horizontal');
    else
       le = legend([Hprice, Ht, Hev, Htcl], '主网电价', '变压器', '电动汽车', '空调负荷', ...
    'Orientation','horizontal');
    end

end
set(le ,'Box', 'off');
totalCostRecord(index, :)= DSO_cost;
relativeAgingRecord(index) = sum(DL_record)/672 * 7;
lfRecord(index) = mean(tielineRecord) / max(tielineRecord);
end