figure;
hold on;
yyaxis left
Hbar1 = bar(t, 100 * gridPriceRecord4/ mkt_max); 
Hbar1(1).FaceColor = [0.8, 0.8, 0.8];
Hbar1(1).EdgeColor = Hbar1(1).FaceColor;
Ht1 = plot(t, 100 * loadPowerRecord / LOAD);
set(Ht1, 'color', [0, 173, 52 ]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
H1 = plot(t, 100 * windPowerRecord / LOAD);
set(H1, 'color', [0, 93, 186]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
if isEn == 1
    ylabel('p.u.(%)')
else
    ylabel('标幺值(%)')
end
yyaxis right
H3 = plot(t, repmat(Tout, 1, DAY));
set(H3, 'color', tomato,'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
if isEn == 1
    ylabel('temperature(^oC)')
    le = legend([Ht1, H1, Hbar1, H3], 'base load', 'RES', 'utility price', 'temperature', 'Orientation', 'horizontal'); 
else
    ylabel('温度(摄氏度)')
    le = legend([Ht1, H1, Hbar1, H3], '基本负荷', '可再生能源', '主网电价', '温度', 'Orientation', 'horizontal'); 
end
set(le, 'Box', 'off')

xlim([0, 24 * DAY]);
xticks(0 : 12 : 24 * DAY);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});

if isEn == 1
    xlabel('t(day)');
    set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);
else
    xlabel('时间')
    set(gcf,'Position',[0 0 650 250]);
end