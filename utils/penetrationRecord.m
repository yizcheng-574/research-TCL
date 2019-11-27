    penaltyP(pindex, cindex) = DSO_cost(1);
    costP(pindex, cindex) = tielineRecord * gridPriceRecord4' * T;
    relativeAgingP(pindex, cindex) = sum(DL_record) / 24 / 60;
    lfP(pindex, cindex) = mean(tielineRecord) / max(tielineRecord);