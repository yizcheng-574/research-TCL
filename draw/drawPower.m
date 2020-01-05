function [] = drawPower(path, titleName, t, c1, c2, c3, c4, Linestyle, index, isOneday)
global totalCostRecord relativeAgingRecord lfRecord isEn
theta_h_record = 1;
load(path, ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord',...
    'DSO_cost', 'tielineBuy', 'DL_record', ...
    'DAY', 'T', 'I',...
    'gridPriceRecord','gridPriceRecord4');

if isOneday > 0
    st = isOneday * 96 + 1;
    en = st + 96;
else
    st = 49;
    en = 672;
end
t = t(st:en);
figure;
yyaxis left;
t0 = 1: 24 * 7;
Hprice = bar(t0((st-1)/4: en/4), gridPriceRecord((st-1)/4: en/4));
Hprice.EdgeColor = 'none';
Hprice.FaceColor = [0.8, 0.8, 0.8];
ylim([0.55, 1.25])
ylabel('主网电价(元/kWh)')
yyaxis right;
hold on;
DSO_cost(2) = tielineRecord * gridPriceRecord4' * T;

tielineRecord = tielineRecord(st: en);
tielineRecord * gridPriceRecord4(st:en)' * T
EV_totalpowerRecord = EV_totalpowerRecord(st: en);
TCL_totalpowerRecord = TCL_totalpowerRecord(st: en);
IVA_totalpowerRecord = IVA_totalpowerRecord(st: en);
maxY = max(tielineRecord)/1000 * 1.05;
Ht = stairs(t, tielineRecord / 1000, 'color', c1, 'LineWidth', 1.5, 'LineStyle', Linestyle, 'marker', 'none');
Hev = stairs(t, EV_totalpowerRecord(1:length(t)) / 1000, 'color', c3, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'd', 'MarkerSize', 3 );
Htcl = stairs(t, (TCL_totalpowerRecord + IVA_totalpowerRecord) / 1000, 'color', c3, 'LineWidth', 1.5,'LineStyle', '--', 'marker', 'none');
limit1 = plot(t, tielineBuy / 1000 * ones(1, length(t)), 'color', c4, 'LineWidth' , 1, 'LineStyle', '--', 'DisplayName', '功率上限', 'marker', 'none');
limit2 = plot(t, tielineBuy * 1.15 / 1000 * ones(1, length(t)), 'color', c4, 'LineWidth' , 1, 'LineStyle', '-', 'DisplayName', '功率上限', 'marker', 'none');

for d = 1: DAY - 1
drawVerticalLine(24 * d, 0, maxY, 'black', ':')
end
if isEn == 1
    ylabel('power(MW)')
    set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);
else
    ylabel('功率(MW)')
    set(gcf,'Position',[0 0 650 250]);
end
if isOneday == 0
    xlim([12, 24 * DAY]);
    xticks(12 : 12 : 24 * DAY);
    xticklabels({'12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
else
    xlim([(st-1)/4, en/4]);
    xticks((st-1)/4 : 6 : en/4);
    xticklabels({'0:00', '6:00', '12:00', '18:00', '24:00'});

end
ylim([0, maxY])

% title(titleName)

if index == 1
    if isEn == 1
        le = legend([Ht, Hev, Htcl,Hprice, limit1, limit2], 'transformer', 'EV', 'ACL','RTP','P_T^N','1.15P_T^N', ...
            'Orientation','horizontal');
    else
           le = legend([Hprice, Ht, Hev, Htcl, limit1, limit2], '主网电价', '变压器', '电动汽车', '空调负荷','P_T^N','1.15P_T^N', ...
        'Orientation','horizontal');
    end
    set(le ,'Box', 'off');
end
DSO_cost(2);
totalCostRecord(index)= sum(DSO_cost);
relativeAgingRecord(index) = sum(DL_record)/672 * 7;
lfRecord(index) = mean(tielineRecord) / max(tielineRecord);
end