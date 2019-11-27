% 针对 UNCONTROLLED, EV ONLY, EV + HVAC, UNCOORDINATED四个进行对比
clc;clear;
close all;
addPath;
load('../../data/COLOR');
macPath = '../../data/0705-2';
load([macPath, '/mode']);

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

subPath3 = '/modeEV';
% ----------------------------------------------------------------------
figure;
c5 = darkblue; c6 = tomato;
subplot(2,1,1); drawPrice(macPath, subPath3, t, c5, c6)
subplot(2,1,2); drawPrice(macPath, '/modeTCL', t, c5, c6)
xlabel('t(day)')
drawPower(macPath,'/mode', 'Case I (UC)', t, t2, c1, c2, c3, c4, '-', 1)
drawPower(macPath, '/modePD', 'Case II (ND)', t, t2, c1, c2, c3, c4, '-', 4)
drawPower(macPath, subPath3, 'Case III (EV only)', t, t2, c1, c2, c3, c4, '-', 2)
drawPower(macPath,'/modeTCL', 'Case IV (NI-TC)', t, t2, c1, c2, c3, c4, '-', 3)

xlabel('t(day)')
% ----------------------------------------------------------------------
figure;
load([macPath, '/modeTCL'], ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord', 'tielineBuy', 'DAY', 'T', 'I');
hold on;
st = I_day * 3;
en = I_day * 5;
t3 = (st : en) * T - T;
Ht = plot(t3, tielineRecord(st : en) / 1000, 'color', c1, 'LineWidth', 1, 'LineStyle', '-', 'marker', 'none');
Hev = plot(t3, EV_totalpowerRecord(st : en) / 1000, 'color', c2, 'LineWidth', 1, 'LineStyle', '-', 'marker', 'none');
Htcl = plot(t3, (TCL_totalpowerRecord(st : en) + IVA_totalpowerRecord(st : en)) / 1000, 'color', c3, 'LineWidth', 1, 'LineStyle', '-', 'marker', 'none');
load([macPath, '/modePD'], ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord', 'tielineBuy', 'DAY', 'T', 'I');
Ht1 = plot(t3, tielineRecord(st : en) / 1000, 'color', [0.3 0.3 0.3], 'LineWidth', 2, 'LineStyle', ':', 'marker', 'none');
Hev1 = plot(t3, EV_totalpowerRecord(st : en) / 1000, 'g', 'LineWidth', 2, 'LineStyle', ':', 'marker', 'none');
Htcl1 = plot(t3, (TCL_totalpowerRecord(st : en) + IVA_totalpowerRecord(st : en)) / 1000, 'color', [24 91 179]/255, 'LineWidth', 2, 'LineStyle', ':', 'marker', 'none');
Hlimit = plot(t3, tielineBuy / 1000 * ones(1, length(t3)), 'color', c4, 'LineWidth' , 1, 'LineStyle', '--', 'marker', 'none');
ylabel('power(MW)')
ylim([0, max(tielineRecord(st : en))/1000 * 1.05])
xlim([st * T, en * T])
xticks(st * T: 12 : en * T);
xticklabels({ '3', '12:00', '4', '12:00', '5'});
le = legend([Ht, Hev, Htcl, Ht1, Hev1, Htcl1], 'case IV : transformer', 'case IV: EV', 'case IV: ACL', 'case II : transformer', 'case II: EV', 'case II: ACL');
set(le, 'Box', 'off', 'Orientation', 'horizontal');
% set(le, 'NumColumns', 3);
set(gcf,'unit','normalized','position',[0,0,0.17,0.15]);

%----------------------------------------------------------------------
%温度曲线
load([macPath, '/modeTCL']);
figure;
DAY = 1;
t4 =  0 : T : DAY * 24;
color = ones(FFA + IVA, 3);
color(:, 2:3) = repmat(0.3 + EVdata_beta /4, 2, 2)';


colorBlue =  ones(FFA + IVA, 3);
colorBlue(:, 1:2) = repmat(0.3 + EVdata_beta/4, 2, 2)';

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


t3 = 0: T: 7 * 24;

% 热点温度
figure; 
subplot(2,1,1); hold on;
load([macPath, '/mode'], 'theta_h_record'); 
h1 = plot(t3, theta_h_record,'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5); 
load([macPath, '/modePD'], 'theta_h_record'); 
h2 = plot(t3, theta_h_record, 'Color', c1, 'LineStyle', ':', 'LineWidth', 2); 
load([macPath, subPath3], 'theta_h_record'); 
h3 = plot(t3, theta_h_record,'Color', darkblue, 'LineStyle', '-', 'LineWidth', 1.5); 
load([macPath, '/modeTCL'], 'theta_h_record'); 
h4 = plot(t3, theta_h_record, 'Color', firebrick, 'LineStyle', '-', 'LineWidth', 1.5); 

 plot([0, 34 * 7], [120,120], 'LineStyle', '--', 'LineWidth', 0.5, 'Color', firebrick);
 plot([0, 34 * 7], [140,140], 'LineStyle', '--', 'LineWidth', 0.5, 'Color', tomato);

ylabel('temperature(^oC)')
title('hot spot temperature');
xlim([0, 24 * 7]);
xticks(0 : 12 : 24 * 7);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});

% 老化情况
subplot(2,1,2); hold on;
load([macPath, '/mode'], 'DL_record'); 
h1 = plot(t3, DL_record/15,'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5); 
load([macPath, '/modePD'], 'DL_record'); 
h2 = plot(t3, DL_record/15, 'Color', c1, 'LineStyle', ':', 'LineWidth', 2); 
load([macPath, subPath3], 'DL_record'); 
h3 = plot(t3, DL_record/15,'Color', darkblue, 'LineStyle', '-', 'LineWidth', 2); 
load([macPath, '/modeTCL'], 'DL_record'); 
h4 = plot(t3, DL_record/15, 'Color', firebrick, 'LineStyle', '-', 'LineWidth', 1.5); 

ylabel('relative aing rate')
title('relative aging');
xlim([0, 24 * 7]);
xticks(0 : 12 : 24 * 7);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
% set(gca,'xticklabel','');
le = legend([h1, h2, h3, h4],'Case I (UC)','Case II (NC)', 'Case III (EV only)', 'Case IV (NI-TC)', 'Orientation', 'vertical');
set(le ,'Box', 'off');
% set(le, 'NumColumns', 1);

set(gcf,'unit','normalized','position',[0,0,0.3,0.25]); 
xlim([0, 24 * 7]);
xticks(0 : 12 : 24 * 7);
xlabel('t(day)')

figure;

subplot(3,1,1); hold on
load([macPath, '/mode'], 'tielineRecord'); 
[f, xi] = ecdf(tielineRecord/1000);
h1 = plot((1-f)*24*7, xi,'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case I (UC)'); 
load([macPath, '/modePD'], 'tielineRecord'); 
[f, xi] = ecdf(tielineRecord/1000);
h2 = plot((1-f)*24*7, xi, 'Color', c1, 'LineStyle', ':', 'LineWidth', 2, 'DisplayName', 'Case II (NC)'); 
load([macPath, subPath3], 'tielineRecord'); 
[f, xi] = ecdf(tielineRecord/1000);
h3 = plot((1-f)*24*7, xi,'Color', darkblue, 'LineStyle', '-', 'LineWidth', 1.5,'DisplayName', 'Case III (EV only)'); 
load([macPath, '/modeTCL'], 'tielineRecord'); 
[f, xi] = ecdf(tielineRecord/1000);
h4 = plot((1-f)*24*7, xi, 'Color', firebrick, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case IV (NI-TC)'); 
le = legend([h1, h2, h3, h4],'Case I (UC)','Case II (NC)', 'Case III (EV only)', 'Case IV (NI-TC)', 'Orientation', 'vertical');
set(le ,'Box', 'off');
set(gcf,'unit','normalized','position',[0,0,0.3,0.25]); 
xlim([0, 24 * 7]);
ylim([1, 4])
xticks(0 : 12 : 24 * 7);
xlabel('t(h)');
ylabel('transformer power(MW)');

subplot(3,1,2); hold on
load([macPath, '/mode'], 'theta_h_record'); 
[f, xi] = ecdf(theta_h_record);
h1 = plot((1-f)*24*7, xi,'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case I (UC)'); 
load([macPath, '/modePD'], 'theta_h_record'); 
[f, xi] = ecdf(theta_h_record);
h2 = plot((1-f)*24*7, xi, 'Color', c1, 'LineStyle', ':', 'LineWidth', 2, 'DisplayName', 'Case II (NC)'); 
load([macPath, subPath3], 'theta_h_record'); 
[f, xi] = ecdf(theta_h_record);
h3 = plot((1-f)*24*7, xi,'Color', darkblue, 'LineStyle', '-', 'LineWidth', 1.5,'DisplayName', 'Case III (EV only)'); 
load([macPath, '/modeTCL'], 'theta_h_record'); 
[f, xi] = ecdf(theta_h_record);
h4 = plot((1-f)*24*7, xi, 'Color', firebrick, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case IV (NI-TC)'); 
le = legend([h1, h2, h3, h4],'Case I (UC)','Case II (NC)', 'Case III (EV only)', 'Case IV (NI-TC)', 'Orientation', 'vertical');
set(le ,'Box', 'off');
% set(gcf,'unit','normalized','position',[0,0,0.3,0.25]); 
xlim([0, 24 * 7]);
xticks(0 : 12 : 24 * 7);
ylabel('temperature(^oC)')


subplot(3,1,3); hold on
load([macPath, '/mode'], 'DL_record'); 
[f, xi] = ecdf(DL_record);
h1 = plot((1-f)*24*7, xi,'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case I (UC)'); 
load([macPath, '/modePD'], 'DL_record'); 
[f, xi] = ecdf(DL_record);
h2 = plot((1-f)*24*7, xi, 'Color', c1, 'LineStyle', ':', 'LineWidth', 2, 'DisplayName', 'Case II (NC)'); 
load([macPath, subPath3], 'DL_record'); 
[f, xi] = ecdf(DL_record);
h3 = plot((1-f)*24*7, xi,'Color', darkblue, 'LineStyle', '-', 'LineWidth', 1.5,'DisplayName', 'Case III (EV only)'); 
load([macPath, '/modeTCL'], 'DL_record'); 
[f, xi] = ecdf(DL_record);
h4 = plot((1-f)*24*7, xi, 'Color', firebrick, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case IV (NI-TC)'); 
le = legend([h1, h2, h3, h4],'Case I (UC)','Case II (NC)', 'Case III (EV only)', 'Case IV (NI-TC)', 'Orientation', 'vertical');
set(le ,'Box', 'off');
set(gcf,'unit','normalized','position',[0,0,0.3,0.25]); 
xlim([0, 24 * 7]);
xticks(0 : 12 : 24 * 7);
ylim([0, 650]);
xlabel('t(h)');
ylabel('relative aging');