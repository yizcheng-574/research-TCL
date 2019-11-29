% 针对 UNCONTROLLED, EV ONLY, EV + HVAC, UNCOORDINATED四个进行对比
clc;clear;
close all;
addPath;
load('../../data/COLOR');
macPath = '../../data/1127';
load([macPath, '/TEC']);

global totalCostRecord relativeAgingRecord lfRecord
totalCostRecord = zeros(1, 5);
relativeAgingRecord = zeros(1, 5);
lfRecord = zeros(1, 5);

t1 = dt: dt : DAY * 24;
t = T : T : DAY * 24;
t2 = 0 : T_tcl : DAY * 24;
t0 = 1 : DAY * 24;
t3 = 0: T: DAY * 24;
c1 = black; c2 = green; c3 = darkblue; c4 = tomato;

%基本仿真数据
figure;
hold on;
yyaxis left
Hbar1 = bar(t0, 100 * gridPriceRecord/ mkt_max); 
Hbar1(1).FaceColor = [0.8, 0.8, 0.8];
Hbar1(1).EdgeColor = Hbar1(1).FaceColor;
Ht1 = plot(t, 100 * loadPowerRecord / LOAD);
set(Ht1, 'color', [0, 173, 52 ]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
H1 = plot(t, 100 * windPowerRecord / WIND);
set(H1, 'color', [0, 93, 186]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
ylabel('p.u.(%)')
yyaxis right
H3 = plot(t, repmat(Tout, 1, DAY));
set(H3, 'color', tomato,'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
ylabel('temperature(^oC)')

le = legend([Ht1, H1, Hbar1, H3], 'base load', 'RES', 'utility price', 'temperature', 'Orientation', 'horizontal'); set(le, 'Box', 'off')
xlim([0, 24 * DAY]);
xticks(0 : 12 : 24 * DAY);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
xlabel('t(day)')
set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);

% ----------------------------------------------------------------------
c5 = darkblue; c6 = tomato;
drawPrice(macPath, '/TEC', t, c5, c6, 1)
drawPrice(macPath, '/TEC_wo_ACLs', t, c5, c6, 2)
drawPrice(macPath, '/TEC_wo_SOM', t, c5, c6, 3)
xlabel('t(day)')

drawPower([macPath,'/TEC'], 'Case I - TEC with ACLs', t, t2, c1, c2, c3, c4, '-', 1)
drawPower([macPath, '/TEC_wo_ACLs'], 'Case II - TEC w/o ACLs', t, t2, c1, c2, c3, c4, '-', 2)
drawPower([macPath, '/TEC_wo_SOM'], 'Case III - TEC w/o smart overloading management', t, t2, c1, c2, c3, c4, '-', 3)
drawPower([macPath,'/non_coordinated'], 'Case IV - non-coordinated', t, t2, c1, c2, c3, c4, '-', 4)
drawPower([macPath,'/uncontrolled'], 'Case V - uncontrolled', t, t2, c1, c2, c3, c4, '-', 5)
xlabel('t(day)')

t3 = 0: T: 7 * 24;
% 热点温度
drawAging(macPath, 'theta_h_record', t3, 'temperature(^oC)', 'hot spot temperature', 1, firebrick, c1, darkblue, tomato);
% 老化情况
drawAging(macPath, 'DL_record', t3, 'relative aing rate', 'relative aging', 2, firebrick, c1, darkblue, tomato);
% 累积概率密度
% figure;
% set(gcf,'unit','normalized','position',[0,0,0.3,0.5]); 
% drawCdf(macPath, 'tielineRecord', 'transformer power(MW)', 1, firebrick, c1, darkblue);
% drawCdf(macPath, 'theta_h_record', 'temperature(^oC)', 2, firebrick, c1, darkblue);
% drawCdf(macPath, 'DL_record', 'relative aging', 3, firebrick, c1, darkblue);


%----------------------------------------------------------------------
%温度曲线
% figure;
% DAY = 1;
% t4 =  0 : T : DAY * 24;
% color = ones(FFA + IVA, 3);
% color(:, 2:3) = repmat(0.3 + EVdata_beta /4, 2, 2)';
% 
% colorBlue =  ones(FFA + IVA, 3);
% colorBlue(:, 1:2) = repmat(0.3 + EVdata_beta/4, 2, 2)';

% subplot(3,2,1); hold on;
% for i = 1 : FFA
%     plot(0: T: 24, 100 * (TCLdata_Ta(i ,I_day: I_day*2) - TCLdata_T(2, i)) / (TCLdata_T(1, i) - TCLdata_T(2, i)), 'color', color(i, :)); alpha(0.5);    
% end
% xlim([0, 24]);
% xticks(0 : 6 : 24);
% ylim([60, 110])
% xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});
% ylabel('FFA SOA')
% 
% subplot(3,2,3); hold on;
% for i = 1 : IVA
%     plot(0: T: 24, 100 * (IVAdata_Ta(i ,I_day: I_day*2) - TCLdata_T(2, i + FFA)) / (TCLdata_T(1, i + FFA) - TCLdata_T(2, i + FFA)), 'color', color(i + FFA - EV, :)); alpha(0.5);    
% end
% xlim([0, 24]);
% xticks(0 : 6 : 24);
% ylim([50, 105])
% xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});
% ylabel('IVA SOA')
% 
% % EV电量和接入即充电比较
% subplot(3,2,5); hold on;
% EVdata_Eaging = EVdata_E;
% load([macPath, '/mode'], 'EVdata_E'); 
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


% subplot(3,2,2); hold on;
% for i = 1 : FFA
%     plot(1: 24, TCLpowerRecord(i ,24 + 1: 24*2), 'color', colorBlue(i, :)); alpha(0.5);    
% end
% xlim([0, 24]);
% xticks(0 : 6 : 24);
% ylim([min(min(TCLpowerRecord(:,24 + 1: 24*2)))*0.9, max(max(TCLpowerRecord(: ,24 + 1: 24*2)))*1.1])
% xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});
% ylabel('FFA power')
% 
% subplot(3,2,4); hold on;
% for i = 1 : IVA
%     plot(T: T: 24, IVApowerRecord(i, I_day + 1: I_day * 2), 'color', colorBlue(i + FFA - EV, :)); alpha(0.5);    
% end
% xlim([0, 24]);
% xticks(0 : 6 : 24);
% ylim([min(min(IVApowerRecord(:,24 + 1: 24*2)))*0.9, max(max(IVApowerRecord(: ,24 + 1: 24*2)))*1.1])
% xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});
% ylabel('IVA power')
% 
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
