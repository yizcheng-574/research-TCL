load('../../data/RTP_pjm');
if isMultiDay == 0
    gridPriceRecord = mean(RTP);
    for i = 1 : 24
        sigmaRecord(i) = sqrt(mean((RTP(:, i) - gridPriceRecord(i)).^2)); 
    end
    maxP = max([gridPriceRecord,sigmaRecord]);
    minP = min([gridPriceRecord,sigmaRecord]);
    gridPriceRecord = (gridPriceRecord - minP) / (maxP - minP) * (1.2 - mkt_min) + mkt_min;
    sigmaRecord = (sigmaRecord - minP) / (maxP - minP) * (1.2 - mkt_min) + mkt_min;
    sigmaRecord(15) = 0.4;
    sigmaRecord(17) = 0.4;
    % sigmaRecord = 0.5 * gridPriceRecord;

    % gridPriceRecord = [50 47 45 70 80 60 72 90 82 105 110 82 85 120 100 90 80 105 95 110 90 50 70 55] / 1000 * 8;
    % sigmaRecord = 0.8 * gridPriceRecord;
else
    gridPrice = zeros(w_e - w_s + 1, 24 * 7);
    for week = w_s : w_e
        for i = 1 : 7
            gridPrice(week - w_s + 1, (i - 1)* 24 + 1: i * 24) = RTP((week - 1) * 7 + i, :);
        end        
    end
    gridPriceRecord = mean(gridPrice);
    for i = 1 : 24 * 7
        sigmaRecord(i) = sqrt(mean((gridPrice(:, i) - gridPriceRecord(i)).^2)); 
    end
    maxP = max([gridPriceRecord,sigmaRecord]);
    minP = min([gridPriceRecord,sigmaRecord]);
    gridPriceRecord = (gridPriceRecord - minP) / (maxP - minP) * (1.2 - mkt_min) + mkt_min;
    sigmaRecord = (sigmaRecord - minP) / (maxP - minP) * (1.2 - mkt_min) + mkt_min;
end

clear i RTP minP maxP
