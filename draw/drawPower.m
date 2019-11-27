function [] = drawPower(path, subPath, title1, t, t2, c1, c2, c3, c4, Linestyle, index)
global totalCostRecord relativeAgingRecord lfRecord
theta_h_record = 1;
load([path, subPath], ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord', 'DSO_cost', 'tielineBuy', 'DL_record', 'DAY', 'T', 'I', 'gridPriceRecord4');
figure;
hold on;
t = t(49:end);
DSO_cost(2) = tielineRecord * gridPriceRecord4' * T;
tielineRecord = tielineRecord(49: end);
EV_totalpowerRecord = EV_totalpowerRecord(49: end);
TCL_totalpowerRecord = TCL_totalpowerRecord(49: end);
IVA_totalpowerRecord = IVA_totalpowerRecord(49: end);
t2 = t2(13:end);
maxY = max(tielineRecord)/1000 * 1.05;
Ht = stairs(t, tielineRecord / 1000, 'color', c1, 'LineWidth', 1.5, 'LineStyle', Linestyle, 'marker', 'none');
Hev = stairs(t, EV_totalpowerRecord(1:length(t)) / 1000, 'color', c2, 'LineWidth', 1.5, 'LineStyle', Linestyle, 'marker', 'none');
Htcl = stairs(t, (TCL_totalpowerRecord + IVA_totalpowerRecord) / 1000, 'color', c3, 'LineWidth', 1.5, 'LineStyle', Linestyle, 'marker', 'none');
plot(t2, tielineBuy / 1000 * ones(1, length(t2)), 'color', c4, 'LineWidth' , 1, 'LineStyle', '--', 'DisplayName', '功率上限', 'marker', 'none');
for d = 1: DAY - 1
drawVerticalLine(24 * d, 0, maxY, 'black', ':')
end
ylabel('power(MW)')
xlim([12, 24 * DAY]);
ylim([0, maxY])
xticks(12 : 12 : 24 * DAY);
xticklabels({'12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
% set(gca,'xticklabel','');
set(gcf,'unit','normalized','position',[0,0,0.3,0.15]); title(title1)
if index == 1
    le = legend([Ht, Hev, Htcl], 'transformer', 'EV', 'HVAC', 'Orientation','horizontal');
%     set(le ,'Box', 'off', 'NumColumns', 3);
end
DSO_cost
totalCostRecord(index)= sum(DSO_cost);
relativeAgingRecord(index) = sum(DL_record)/24/60;
lfRecord(index) = mean(tielineRecord) / max(tielineRecord);
end