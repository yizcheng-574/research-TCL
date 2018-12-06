function [pavg,sigma ] = price_pred( ST,END,T,type )

%计算给定时间段ST和END内实时电价平均值和方差
if exist('gridPriceRecord') == 0
    load('./data/gridPriceRecord');
end
l_price=length(gridPriceRecord);
st=ceil(ST/T);
en=floor(END/T);
I=24/T;
k=1;
day=ceil(l_price/24);
if type==1 %week
for d=2:day-1
    tlist(1,d)=ST+(d-1)*24;
    tlist(2,d)=END+(d-1)*24;
end
else
for d=1:6:7
    tlist(1,d)=ST+(d-1)*24;
    tlist(2,d)=END+(d-1)*24;
end
end
d=1;
[tmp,day]=size(tlist);
for i=0:l_price/T-1
    if i*T>=tlist(1,d) && i*T<tlist(2,d)
        time=i*T;
        priceRecord(k)=gridPriceRecord(floor(time)+1);
        k=k+1;
    elseif  i*T>=tlist(2,d)&& (i-1)*T<tlist(2,d)
        d=d+1;
        if d>day
            break;
        end
    end
end
if exist('priceRecord')==0
    for d=1:day
        priceRecord(k)=gridPriceRecord(floor(ST+(d-1)*24)+1);
        k=k+1;
    end
end
pavg=mean(priceRecord);
sigma=sqrt(sum((priceRecord-pavg).^2)/(length(priceRecord)));
end

