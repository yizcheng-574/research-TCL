function [ clcPrice] = calculateIntersection(mkt,targetDemand,demandArray)
minMarketPrice=mkt(1);%1最高市场电价
maxMarketPrice=mkt(2);%2最低市场电价
leftIx = 1;
L=length(demandArray);
step=(maxMarketPrice-minMarketPrice)/(L-1);
rightIx = L;
if targetDemand > demandArray(leftIx)
    clcPrice= minMarketPrice;
    return;
elseif targetDemand < demandArray(rightIx)
    clcPrice= maxMarketPrice;
    return;
elseif targetDemand == demandArray(leftIx)
    rightIx = leftIx;
elseif targetDemand == demandArray(rightIx)
    leftIx = rightIx;
else
    while rightIx - leftIx > 1
        middleIx = fix((leftIx + rightIx) / 2);
        middleDemand = demandArray(middleIx);
        if targetDemand==middleDemand
            leftIx = middleIx;
            rightIx = middleIx;
        elseif middleDemand > targetDemand
            leftIx = middleIx;
        else
            rightIx = middleIx;
        end
    end
end

while leftIx > 1 && targetDemand==demandArray(leftIx - 1)
    leftIx=leftIx-1;
end
while rightIx < L && targetDemand== demandArray(rightIx + 1)
    rightIx=rightIx+1;
end

if  rightIx == 1
    leftPrice=minMarketPrice;
else
    leftPrice =minMarketPrice + (leftIx-1) * step;
end

if leftIx == L
    rightPrice = maxMarketPrice;
else
    rightPrice=minMarketPrice + (rightIx-1) * step;
end

leftDemand = demandArray(leftIx);
rightDemand =demandArray(rightIx);
if leftDemand == rightDemand
    demandFactor =  0.5;
else
    demandFactor=(leftDemand - targetDemand) / (leftDemand - rightDemand);
end
clcPrice = leftPrice + (rightPrice - leftPrice) * demandFactor;


end

