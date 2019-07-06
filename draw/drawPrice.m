function drawPrice(path, subPath, t, c1, c2)
hold on;
load([path, subPath], 'priceRecord', 'gridPriceRecord4', 'mkt_max', 'mkt_min', 'DAY', 'I');
% Hbar2 = bar(t - 0.25,  [gridPriceRecord4; (priceRecord - gridPriceRecord4)]', 'stacked');
% Hbar2(1).FaceColor = c1;
% Hbar2(1).EdgeColor = Hbar2(1).FaceColor;
% Hbar2(2).FaceColor = c2;
% Hbar2(2).EdgeColor = 'none';
Hbar = fill([t, fliplr(t)],  [gridPriceRecord4, fliplr(priceRecord)], c2);
Hbar.EdgeColor = 'none';
Hline = plot(t, gridPriceRecord4, 'LineWidth', 1, 'Color', c1);
ylabel('electricity price(yuan/kWh)');
ylim([min(gridPriceRecord4) * 0.9, mkt_max]);
le = legend([Hline, Hbar], 'utility price', 'clearing price', 'Orientation','horizontal'); set(le ,'Box', 'off');
xlim([0, 24 * DAY]);
xticks(0 : 12 : 24 * DAY);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
set(gcf,'unit','normalized','position',[0,0,0.25,0.3]);
cnt = 0;
for i = 2 : I
    cnt = cnt + (priceRecord(i) - priceRecord(i - 1))^2;
end
evaluation_price_volatility = sqrt(cnt/ (I - 1)) / (mkt_max - mkt_min)
end

