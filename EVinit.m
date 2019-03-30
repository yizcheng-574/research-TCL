%生成初始的用车习惯
TA_avg = 19.82;
TA_sigma = 1.92;
TD_avg = 8.56;
TD_sigma = 2;%工作日
EVdata = zeros(2,EV);%保存工作日平均到家和离开家的时间
EVdata(1,:) = normrnd(TA_avg, TA_sigma, 1, EV);
EVdata(2,:) = normrnd(TD_avg, TD_sigma, 1, EV);
EVdata(EVdata < 0) = 0;
EVdata(EVdata > 24) = 24;
for ev = 1 : EV
    while EVdata(2,ev) + 24 < EVdata(1,ev) + 1
        EVdata(2,ev) = normrnd(TD_avg, TD_sigma);
    end
end
EVdata_mile = unifrnd(10,20,1,EV);
EVdata_capacity = ceil(unifrnd(20,25,1,EV));%表示EV电池老化
for ev = 1 : EV
    if EVdata_mile(ev) > EVdata_capacity(ev) - 1
        EVdata_mile(ev) = EVdata_capacity(ev) - 1;
    end
end
EVdata_alpha = unifrnd(0,1,1,EV);
EVdata_beta = unifrnd(0,1,1,EV);

% load('../data/bus');
% EVdata_busnum = round(EVdata_busnum / 500 * EV);
% allBus = sum(EVdata_busnum);
% if allBus > EV
%     for busi = 1 : min(nod33, allBus - EV)
%         if EVdata_busnum(busi) > 1
%             EVdata_busnum(busi) = EVdata_busnum(busi) - 1;
%         end
%     end
% elseif allBus < EV
%     for busi = min(nod33, EV - allBus) : -1 : 1
%        EVdata_busnum(busi)=EVdata_busnum(busi)+1;
%     end
% end
% bus1 = 1;
% EVdata_bus = zeros(1, EV);
% for ev = 1 : EV
%     while ev > sum(EVdata_busnum(1 : bus1))
%         bus1 = bus1 + 1;
%     end
%     EVdata_bus(ev) = bus1; 
% end
% tmp = EVdata_bus;
% EVdata_bus = tmp(randperm(numel(tmp)));
PN=3.7;
EVdata_initE = unifrnd(0.1, 0.5, EV, 1);

clear TD_avg TA_avg TD_sigma TA_sigma bus1 busi allBus ev tmp 