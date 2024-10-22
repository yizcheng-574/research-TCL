function drawPrice(path, subPath, t, c1, c2, index)
figure;
hold on;
load([path, subPath], 'priceRecord', 'gridPriceRecord4', 'mkt_max', 'mkt_min', 'DAY', 'I');
Hbar1 = fill([t, fliplr(t)],  [gridPriceRecord4, fliplr(priceRecord)], c2);
Hbar1.EdgeColor = 'none';
Hbar2 = fill([t, fliplr(t)], [min(gridPriceRecord4) * ones(1,length(t)), fliplr(gridPriceRecord4)], [0.8, 0.8, 0.8]);
Hbar2.EdgeColor = 'none';
Hbar2.FaceColor = 'none';
% Hline = plot(t, gridPriceRecord4, 'LineWidth', 1, 'Color', c1);
if (index ==2)
    ylabel('price(yuan/kWh)');
end
ylim([mkt_min, mkt_max]);
if (index == 1)
    le = legend([Hbar2, Hbar1], 'utility price', 'clearing price', 'Orientation','horizontal');
    set(le ,'Box', 'off');
end
xlim([0, 24 * DAY]);
xticks(0 : 12 : 24 * DAY);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
set(gcf,'unit','normalized','position',[0,0,0.3,0.1]);
cnt = 0;
for d = 1: 6
drawVerticalLine(24 * d, 0, 1.5, 'black', ':')
end
for i = 2 : I
    cnt = cnt + (priceRecord(i) - priceRecord(i - 1))^2;
end
% evaluation_price_volatility = sqrt(cnt/ (I - 1)) / (mkt_max - mkt_min)
end

