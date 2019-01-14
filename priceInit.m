load('../data/RTP_pjm');
% RTP( RTP > 150) = 150;
% RTP( RTP < 0) = 0;
gridPriceRecord = mean(RTP);

maxP = max(gridPriceRecord);
minP = min(gridPriceRecord);
gridPriceRecord = (gridPriceRecord - minP) / (maxP - minP) * (0.9 * mkt_max - 1.1 * mkt_min) + mkt_min;
% for i = 1 : 24
% sigmaRecord(i) = sqrt(mean((RTP(:, i) - gridPriceRecord(i)).^2)); 
% end
% sigmaRecord = (sigmaRecord - minP) / (maxP - minP) * (0.9 * mkt_max - 1.1 * mkt_min) + mkt_min;
sigmaRecord = 0.5 * gridPriceRecord;
clear i RTP minP maxP

gridPriceRecord = [50 47 45 70 80 60 72 90 82 105 110 82 85 120 100 90 80 105 95 110 90 50 70 55] / 1000 * 8;
sigmaRecord = 0.8 * gridPriceRecord;
