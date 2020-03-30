% 针对 UNCONTROLLED, EV ONLY, EV + HVAC, UNCOORDINATED四个进行对比
set(0,'defaultAxesFontName','Microsoft Yahei UI');

clc;clear;
close all;
addPath;
load('../../data/COLOR');
macPath = '../../data/20200311';
load([macPath, '/TEC']);
global totalCostRecord relativeAgingRecord lfRecord isEn howManyDays
totalCostRecord = zeros(5, 3);
relativeAgingRecord = zeros(1, 5);
lfRecord = zeros(1, 5);
isEn = 0;

t1 = dt: dt : DAY * 24;
t = T : T : DAY * 24;
t2 = 0 : T_tcl : DAY * 24;
t0 = 1 : DAY * 24;
t3 = 0: T: DAY * 24;
c1 = black; c2 = green; c3 = darkblue; c4 = tomato;


isOneday = 0;
%基本仿真数据
drawInfo;
% 
% ----------------------------------------------------------------------
c5 = darkblue; c6 = tomato;
% drawPrice(macPath, '/TEC', t, c5, c6, 1)
% drawPrice(macPath, '/TEC_wo_ACLs', t, c5, c6, 2)
% drawPrice(macPath, '/TEC_wo_SOM', t, c5, c6, 3)
% xlabel('t(day)')

isOneday = 3;
howManyDays = 2;
drawPower([macPath,'/TEC'], 'Case I - TEC with ACLs', t, c1, c2, c3, c4, '-', 1, isOneday)
drawPower([macPath, '/TEC_wo_ACLs'], 'Case II - TEC w/o ACLs', t, c1, c2, c3, c4, '-', 2, isOneday)
drawPower([macPath, '/TEC_wo_SOM'], 'Case III - TEC w/o smart overloading management', t, c1, c2, c3, c4, '-', 3, isOneday)
drawPower([macPath,'/non_coordinated'], 'Case IV - non-coordinated', t, c1, c2, c3, c4, '-', 4, isOneday)
drawPower([macPath,'/uncontrolled'], 'Case V - uncontrolled', t, c1, c2, c3, c4, '-', 5, isOneday)
if isEn == 1
    xlabel('t(day)')
else
    xlabel('时间')
end
t3 = 0: T: DAY * 24;
if isEn == 1
    titleTemperature = 'temperature(^oC)';
    titleAging = 'relative aing rate';
else
    titleTemperature = '温度(摄氏度)';
    titleAging = '相对老化率';
end
% 热点温度
drawAging(macPath, 'theta_h_record', t3, titleTemperature, 'hot spot temperature', 1, firebrick, c1, darkblue, tomato, isOneday);
% 老化情况
drawAging(macPath, 'DL_record', t3, titleAging, 'relative aging', 2, firebrick, c1, darkblue, tomato, isOneday);
% 累积概率密度
% figure;
% set(gcf,'unit','normalized','position',[0,0,0.3,0.5]); 
% drawCdf(macPath, 'tielineRecord', 'transformer power(MW)', 1, firebrick, c1, darkblue);
% drawCdf(macPath, 'theta_h_record', 'temperature(^oC)', 2, firebrick, c1, darkblue);
% drawCdf(macPath, 'DL_record', 'relative aging', 3, firebrick, c1, darkblue);


%----------------------------------------------------------------------
%温度曲线

figure;
DAY = 1;
t4 =  0 : T : DAY * 24;
color = ones(FFA + IVA, 3);
color(:, 2:3) = repmat(0.3 + EVdata_beta /4, 2, 2)';

colorBlue =  ones(FFA + IVA, 3);
colorBlue(:, 1:2) = repmat(0.3 + EVdata_beta/4, 2, 2)';
FFAdata = repmat(EVdata, 1, 2);
draw_acl;


%----------------------
% subplot(2,2,1);
% for i = 1 : FFA
%     if i > EV
%         plot(12: T: 36, 100 * (TCLdata_Ta(i ,I_day + 48: I_day*2 + 48) - TCLdata_T(2, i)) / (TCLdata_T(1, i) - TCLdata_T(2, i)), 'color', color(i, :)); alpha(0.5);    
%     else
%         ta = FFAdata(1, i);
%         td = FFAdata(2, i);
%         x1 = ceil(ta/T) * T + T: T: td + 24;
%         y1 = (TCLdata_Ta(i ,I_day + 1 + ceil(ta/T): 2 * I_day + floor(td/T))- TCLdata_T(2, i)) / (TCLdata_T(1, i) - TCLdata_T(2, i));
%         plot(x1, 100 * y1 , 'color', color(i, :)); alpha(0.5);
%     end
% end
% xlim([12, 36]);
% xticks(12 : 6 : 36);
% xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
% ylabel('FFA SOA')
% ylim([60, 110])
% 
% 
% subplot(2,2,2); hold on;
% for i = 1 : FFA
%     if i > EV
%         plot(12: 36, TCLpowerRecord(i, 36:60), 'color', colorBlue(i, :)); alpha(0.5);    
%     else
%         ta = FFAdata(1, i);
%         td = FFAdata(2, i) + 24;
%         x1 = ceil(ta) + 1: td;
%         y1 = TCLpowerRecord(i ,24 + ceil(ta) + 1: 24 + td);
%         plot(x1, y1, 'color', colorBlue(i, :)); alpha(0.5);
%     end
% end
% xlim([12, 36]);
% xticks(12 : 6 : 36);
% xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
% ylabel('FFA power')
% ylim([min(min(TCLpowerRecord(:,24 + 1: 24*2)))*0.9, max(max(TCLpowerRecord(: ,24 + 1: 24*2)))*1.1])
% 
% subplot(2,2,3); hold on;
% for i = 1 : IVA
%     plot(12: T: 36, 100 * (IVAdata_Ta(i ,I_day + 48: I_day*2 + 48) - TCLdata_T(2, i + FFA)) / (TCLdata_T(1, i + FFA) - TCLdata_T(2, i + FFA)), 'color', color(i + FFA - EV, :)); alpha(0.5);    
% end
% xlim([12, 36]);
% xticks(12 : 6 : 36);
% xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
% ylim([50, 105])
% ylabel('IVA SOA')
% 
% 
% subplot(2,2,4); hold on;
% for i = 1 : IVA
%     plot(12: T: 36, IVApowerRecord(i, I_day + 48: I_day * 2 + 48), 'color', colorBlue(i + FFA - EV, :)); alpha(0.5);    
% end
% xlim([12, 36]);
% xticks(12 : 6 : 36);
% xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
% ylim([min(min(IVApowerRecord(:,24 + 1: 24*2)))*0.9, max(max(IVApowerRecord(: ,24 + 1: 24*2)))*1.1])
% ylabel('IVA power')

% % EV电量和接入即充电比较
% subplot(3,2,5); hold on;
% EVdata_Eaging = EVdata_E;
% load([macPath, '/TEC'], 'EVdata_E'); 
% for ev = 1 : EV
%     actuE = EVdata_Eaging(ev,  I_day + 49: I_day * 2 + 48);
%     refE =  actuE./EVdata_E(ev,  I_day + 49: I_day * 2 + 48);
%     tin = fix((EVdata(1,ev) - 12) / T) + 2;
%     tout = min(fix((EVdata(2,ev) + 12) / T) + 2,96);
%     if max(refE) < 3
% %         plot(T:T:24, refE,'color', color(ev, :)); alpha(0.5); 
%         plot((tin:tout)/4, 100 * refE(tin:tout),'color', color(ev, :)); alpha(0.5);
%     end
% end
% xlim([0, 24]);
% xticks(0 : 6 : 24);
% ylim([0, 100])
% xticklabels({ '12:00', '18:00', '0:00', '6:00', '12:00'});
% xlabel('t(h)')
% ylabel('EV SOA')

% subplot(3,2,6); hold on;
% for ev = 1 : EV
%     plot(T: T: 24, EVpowerRecord(ev,  I_day + 1 + 48: I_day * 2 + 48), 'color', colorBlue(ev, :)); alpha(0.5);
% end
% xlim([0, 24]);
% xticks(0 : 6 : 24);
% xticklabels({ '12:00', '18:00', '0:00', '6:00', '12:00'});
% set(gcf,'unit','normalized','position',[0,0,0.3,0.2]);
% ylabel('EV power')
% xlabel('t(h)')
set(gcf,'position',[0,0,650,400]);
