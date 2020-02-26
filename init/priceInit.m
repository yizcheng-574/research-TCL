% time of use price
% 谷时：23:00～7:00 0.43元
% 峰时：8:30~11:30, 16:00~21:00 1.17元
% 其他平时 0.8元

gridPriceOneDay = 0.8 * ones(1, 24 * 4);
gridPriceOneDay(1:28) = 0.43 * ones(1, 28);
gridPriceOneDay(end-3:end) = 0.43 * ones(1, 4);
gridPriceOneDay(35:46) = 1.17 * ones(1, 12);
gridPriceOneDay(65:84) = 1.17 * ones(1, 20);
sigmaRecordOneDay = 0.5 * gridPriceOneDay;
gridPriceRecord4 = repmat(gridPriceOneDay, 1, 7);

gridPriceRecordByHour = reshape(gridPriceOneDay, 4, 24);
gridPriceRecord = repmat(mean(gridPriceRecordByHour), 1, 7);
clear gridPriceOneDay gridPriceRecordByHour
