I = 24/T;
I_m = 24/T_m;
step = 500;%投标精度
mkt_min = 0.5;
mkt_max = 1.6;
mkt = [mkt_min,mkt_max,step];
pCurve = (mkt_min:(mkt_max-mkt_min)/step:mkt_max);
I1 = DAY*I;%仿真时长
% load('./data/kmeans2_loadwind')
% windPower=windpower(1,I+1:end-I)*WIND;
% loadPower=loadpower(1,I+1:end-I)*LOAD;

load('./data/load_2017');loadPower=Load/max(max(Load))*LOAD;
load('./data/wind_2017');windPower=Wind/max(max(Wind))*WIND;
clear Load Wind;
%主电网分时电价
% price_table=[0.335,1.253,0.781];%谷，峰，平
% gridPriceRecord=zeros(1,I);%主网电价
% for i=1:I
%     timeNow=fix(mod(i*T,24));
%     if timeNow>=23 ||timeNow<=7
%         grid_price=price_table(1);
%     elseif timeNow>=10 &&timeNow<=15
%         grid_price=price_table(2);
%     elseif timeNow>=18 &&timeNow<=21
%         grid_price=price_table(2);
%     else
%         grid_price=price_table(3);
%     end
%     gridPriceRecord(i)=grid_price;
% end

%主电网实时电价
% load('./data/RTP_nordpool.mat');
% MAX_price=5000;
% tmp=365;%31
% for i=1:tmp*24
%     gridPriceRecord(i)=min(RTP(i),MAX_price);
% end
% for i=5:length(gridPriceRecord)
%     gridPriceRecord(i)=mean(gridPriceRecord(i-4:i));
% end
% % gridPriceRecord=gridPriceRecord/MAX_price*mkt_max;
% pavg_total=mean(gridPriceRecord);
% sigma_total=sqrt(sum((gridPriceRecord-pavg_total).^2)/length(gridPriceRecord));
% 
% for i=1:tmp
%     for j=1:24
%      day_record(j,i)=min(RTP((i-1)*24+j),MAX_price);
%     end
% end
% for j=1:24
%     pavg_record(j)=mean(day_record(j,:));
%     sigma_record(j)=sqrt(sum(((day_record(j,:)-pavg_record(j)).^2))/31);
% end
% for i=1:52
%     for j=1:24*7
%      week_record(j,i)=min(RTP((i-1)*24*7+j),MAX_price);
%     end
% end
% for j=1:24*7
%     week_pavg_record(j)=mean(week_record(j,:));
% end
% 

load('./data/RTP_pjm.mat');
MAX_price=100;
MIN_price=0;
tmp=365;%31
day=1;
gridPriceRecord=zeros(1,365*24);
for i=1:tmp*24
    gridPriceRecord(i)=min(RTP(day,i-(day-1)*24),MAX_price);
    gridPriceRecord(i)=max(gridPriceRecord(i),MIN_price);
   if mod(i,24)==0
        day=day+1;
   end
end
for i=5:length(gridPriceRecord)
    gridPriceRecord(i)=mean(gridPriceRecord(i-4:i));
end
a=1.6;
yearPriceRecord=gridPriceRecord/MAX_price*1.1+0.5;
clear RTP;