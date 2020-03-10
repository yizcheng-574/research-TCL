% time of use price
% 谷时：23:00～7:00 0.43元
% 峰时：8:30~11:30, 16:00~21:00 1.17元
% 其他平时 0.8元
priceValley = 0.43;
pricePeak = 1.17;
priceFlat = 0.8;
gridPriceOneDay = priceFlat * ones(1, 24 * 4);
gridPriceOneDay(1:28) = priceValley;
gridPriceOneDay(end-3:end) = priceValley;
gridPriceOneDay(35:46) = pricePeak;
gridPriceOneDay(65:84) = pricePeak;
sigmaRecordOneDay = 0.5 * gridPriceOneDay;