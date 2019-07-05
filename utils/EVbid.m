function [ bidCurve ] = EVbid( mkt,Pmax,Pmin,Pavg,gamma,pavg,sigma )
%根据BidPara产生的参数以及用户设定的gamma参数，预测的电价值进行投标
mkt_min=mkt(1);%市场电价
mkt_max=mkt(2);
step=mkt(3);
bidCurve=zeros(1,step+1);

pmax=min(pavg+gamma*sigma,mkt_max);%预测电价平均值pavg,方差sigma
pmin=max(pavg-gamma*sigma,mkt_min);
pCurve=(mkt_min:(mkt_max-mkt_min)/step:mkt_max);
for i=1:step+1
    if pCurve(i)<=pmin
        bidCurve(i)=Pmax;
    elseif pCurve(i)<=pavg
        bidCurve(i)=Pmax-(pCurve(i)-pmin)*(Pmax-Pavg)/(pavg-pmin);
    elseif pCurve(i)<=pmax
        bidCurve(i)=Pavg-(pCurve(i)-pavg)*(Pavg-Pmin)/(pmax-pavg);
    else
        bidCurve(i)=Pmin;
    end
end
% plot(bidCurve,pCurve);
end

