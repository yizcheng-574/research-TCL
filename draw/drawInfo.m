global howManyDays
figure; hold on;
if isOneday > 0
    st = (isOneday - 1)* 96 + 1;
    en = st + 96 * howManyDays - 1;
else
    st = 49;
    en = I;
end

yyaxis left
% Hbar1 = bar(t(st:en), 100 * gridPriceRecord4(st:en)/ mkt_max); 
% Hbar1(1).FaceColor = [0.8, 0.8, 0.8];
% Hbar1(1).EdgeColor = Hbar1(1).FaceColor;
Ht1 = plot(t(st:en), loadPowerRecord(st:en) / tielineBuy);
set(Ht1, 'color', [0, 173, 52 ]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
H1 = plot(t(st:en),  windPowerRecord(st:en) / tielineBuy);
set(H1, 'color', [0, 93, 186]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
if isEn == 1
    ylabel('p.u.(%)')
else
    ylabel('标幺值(p.u.)')
end
yyaxis right
ToutToPlot = repmat(Tout, 1, DAY);
H3 = plot(t(st:en), ToutToPlot(st:en) - 2);
set(H3, 'color', tomato,'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
if isEn == 1
    ylabel('temperature(^oC)')
    le = legend([Ht1, H1, Hbar1, H3], 'base load', 'RES', 'utility price', 'temperature', 'Orientation', 'horizontal'); 
else
    ylabel('温度(摄氏度)')
    % le = legend([Ht1, H1, Hbar1, H3], '基本负荷', '可再生能源', '主网电价', '温度', 'Orientation', 'horizontal'); 
    le = legend([Ht1, H1, H3], '基本负荷', '可再生能源', '温度', 'Orientation', 'horizontal'); 
end
set(le, 'Box', 'off')

drawTimeAxis;

if isEn == 1
    xlabel('t(day)');
    set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);
else
    xlabel('时间(天)')
    set(gcf,'Position',[0 0 650 250]);
end