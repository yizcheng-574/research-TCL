%生成初始的用车习惯
TA_avg1=19.82;TA_sigma1=1.92;TD_avg1=7.56;TD_sigma1=2.33;%工作日
TA_avg2=20;TA_sigma2=2;TD_avg2=9;TD_sigma2=2;%周末
EVdata_week=zeros(2,EV_total);%保存工作日平均到家和离开家的时间
EVdata_weekend=zeros(2,EV_total);%保存休息日平均到家和离开家的时间
%第二种，按正态分布生成数据
EV=EV_total;
% EVdata_weekend=EVdata_week;
EVdata_week(1,:)=normrnd(TA_avg1,TA_sigma1,1,EV);
EVdata_week(2,:)=normrnd(TD_avg1+24,TD_sigma1,1,EV);
EVdata_weekend(1,:)=normrnd(TA_avg2,TA_sigma2,1,EV);
EVdata_weekend(2,:)=normrnd(TD_avg2+24,TD_sigma2,1,EV);

for ev=1:EV
    while EVdata_week(2,ev)<EVdata_week(1,ev)+1
        EVdata_week(2,ev)=normrnd(TD_avg1+24,TD_sigma1);
    end
    while EVdata_week(2,ev)-EVdata_week(1,ev)>20
        EVdata_week(2,ev)=normrnd(TD_avg1+24,TD_sigma1);
    end
    while EVdata_weekend(2,ev)<EVdata_weekend(1,ev)+1%至少停留1小时
        EVdata_weekend(2,ev)=normrnd(TD_avg2+24,TD_sigma2);
    end
end

for ev=1:EV
    [EVdata_price_week(1,ev),EVdata_price_week(2,ev)]=price_pred(EVdata_week(1,ev),EVdata_week(2,ev),T,1);
    [EVdata_price_weekend(1,ev),EVdata_price_weekend(2,ev)]=price_pred(EVdata_weekend(1,ev),EVdata_weekend(2,ev),T,2);
end

% EVdata_mile=0.36*exp(normrnd(3.2,0.88,1,EV));%日行驶里程为对数正态分布，均值3.2英里，方差0.88.ecr=0.36kWh/mile
EVdata_mile=unifrnd(10,20,1,EV);%日行驶里程为对数正态分布，均值3.2英里，方差0.88.ecr=0.36kWh/mile
% EVdata_mile=15*ones(1,EV);
EVdata_capacity=ceil(unifrnd(20,25,1,EV));%表示EV电池老化

for ev=1:EV
    if EVdata_mile(ev)>EVdata_capacity(ev)-1
        EVdata_mile(ev)=EVdata_capacity(ev)-1;
    end
end
EVdata_alpha=unifrnd(0,1,1,EV);
EVdata_beta=unifrnd(0.5,3,1,EV);
load('./data/bus');
EVdata_busnum=round(EVdata_busnum/500*EV);
allBus=sum(EVdata_busnum);
if allBus>EV
    for busi=1:min(nod33,allBus-EV)
        if EVdata_busnum(busi)>1
            EVdata_busnum(busi)=EVdata_busnum(busi)-1;
        end
    end
elseif allBus<EV
    for busi=min(nod33,EV-allBus):-1:1
        
            EVdata_busnum(busi)=EVdata_busnum(busi)+1;
        
    end
end
% EVdata_busnum=fix(bus(:,3)/sum(bus(:,3))*EV);
bus1=1;
for ev=1:EV
    while ev>sum(EVdata_busnum(1:bus1))
        bus1=bus1+1;
    end
    EVdata_bus(ev)=bus1; 
end
tmp=EVdata_bus;
EVdata_bus=tmp(randperm(numel(tmp)));
for ev=1:EV
    if EVdata_beta(ev)<0.5
        EVdata_beta(ev)=0.5;
    end    
end
EV_ta=zeros(DAY+1,EV);%EV到家时间
EV_td=zeros(DAY+1,EV);%EV实际离家时间
EV_mile_pred=zeros(DAY,EV);%EV预计用电量
EV_mile=zeros(DAY,EV);%EV实际用电量
% EV_last_a=zeros(1,EV);%上次抵达时电量
EV_last_d=zeros(1,EV);%离开时电量
for day=1:DAY
    day1=mod(day,7);
    if day1>=2 && day1<=6
        for ev=1:EV
            %无预测误差
            EV_ta(day,ev)=normrnd(EVdata_week(1,ev),0.5);
            EV_td(day,ev)=normrnd(EVdata_week(2,ev),0.5);
            while EV_ta(day,ev)>EV_td(day,ev)
                EV_ta(day,ev)=normrnd(EVdata_week(1,ev),0.5);
                EV_td(day,ev)=normrnd(EVdata_week(2,ev),0.5);
            end
        end
    else
        for ev=1:EV
            EV_ta(day,ev)=normrnd(EVdata_weekend(1,ev),0.5);
            EV_td(day,ev)=normrnd(EVdata_weekend(2,ev),0.5);
            while EV_ta(day,ev)>EV_td(day,ev)
                EV_ta(day,ev)=normrnd(EVdata_weekend(1,ev),0.5);
                EV_td(day,ev)=normrnd(EVdata_weekend(2,ev),0.5);
            end
        end
    end
    for ev=1:EV
         EV_mile_pred(day,ev)=min(EVdata_capacity(ev),max(2,normrnd(EVdata_mile(EV),EVdata_mile(EV)*0.1)));        
        EV_mile(day,ev)=min(EVdata_capacity(ev),normrnd(EV_mile_pred(day,ev),EV_mile_pred(day,ev)*0.05));
%         EV_mile(day,ev)=EV_mile_pred(day,ev);
    end
    EV_td(day,:)=EV_td(day,:)+(day-1)*24;
    EV_ta(day,:)=EV_ta(day,:)+(day-1)*24;
end

PN=3.7;
save('EVdata','PN','EV','EV_last_d','EV_mile','EV_mile_pred','EV_ta','EV_td','EVdata_alpha','EVdata_beta','EVdata_bus','EVdata_capacity','EVdata_mile','EVdata_price_week','EVdata_price_weekend','EVdata_week','EVdata_weekend');
