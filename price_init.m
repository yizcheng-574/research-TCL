load('../data/RTP_pjm');
RTP( RTP > 150) = 150;
RTP( RTP < 0) = 0;
RTP = RTP / 150 * (mkt_max - mkt_min) + mkt_min;
gridPriceRecord = mean(RTP);
for i = 1 : 24
    sigmaRecord(i) = sqrt(sum((RTP(:, i) - gridPriceRecord(i)).^2) / 365);
end
clear i RTP