close all;
global T_tcl TOTAL_PLOT t1 t2
orange = [1 0.65 0];
gold = [1 0.843 0];
gray = [0.5 0.5 0.5];
black = [0, 0, 0];
olivedrab = [0.41961 0.55686 0.13725];
light_olivedrab = [203, 218, 175] / 255;
yellowgreen = [0.60392 0.80392 0.19608];

firebrick = [0.69804 0.13333 0.13333];
tomato = [1 0.38824 0.27843];
brown = [0.80392 0.2 0.2];
maroon = [0.6902 0.18824 0.37647];

royalblue = [0.2549 0.41176 0.88235];
royalblue_dark = [0.15294 0.25098 0.5451];
darkblue =[0 0 0.5451];
dodgerblue = [0.11765 0.56471 1];
light_dodgerblue = [157,197,238]/255;
indianred = [1 0.41 0.42];
chocolate3 = [0.804 0.4 0.113];
tan2 = [0.93  0.60 0.286];
t1 = dt: dt : 24;
t = T : T :24;
t2 = 0 : T_tcl : 24;

%----------------------
%主变功率，EV，TCL功率曲线，
%电价曲线
TOTAL_PLOT = 2;
subplot(TOTAL_PLOT, 1 ,1);
isFill = 0;
hold on;
%TCL EV上下限
H1 = fill([t, fliplr(t)], [offsetArray(sum(EVminPowerRecord/1000), I / 2), fliplr(offsetArray(sum(EVmaxPowerRecord/1000), I / 2))], light_olivedrab);
alpha(0.5);
H2 = fill([t2(1:end-1), fliplr(t2(1:end-1))], [offsetArray(sum(TCLminPowerRecord/1000), I2 / 2), offsetArray(sum(TCLmaxPowerRecord/1000), I2 / 2)], light_dodgerblue);
alpha(0.5);
set(H1, {'LineStyle'}, {'none'});
set(H2, {'LineStyle'}, {'none'});

TCLpowerAvg = zeros(1, I2);
for i = 1 : I2
    TCLpowerAvg(1, i) = mean(sum(TCLdata_P(:, (i - 1) * T_tcl / dt + 1 : i * T_tcl / dt)));
end
yyaxis left
H1 = plot(t, [offsetArray(EV_totalpowerRecord/1000, I / 2); offsetArray(tielineRecord/1000, I / 2) ]);

Hev = plot(t, offsetArray(sum(EVavgPowerRecord/1000), I/2));
set(Hev, 'color', olivedrab, 'LineWidth', 1, 'LineStyle', '-.');
Htcl = stairs(t2, appendStairArray(offsetArray(sum(TCLsetPowerRecord/1000), I2 / 2)));
set(Htcl, 'color', dodgerblue, 'LineWidth', 1, 'LineStyle', '-.');

H4(1) = stairs(t2, appendStairArray(offsetArray(TCL_totalpowerRecord/1000, I2 / 2)));
H3 = plot(1: 24, tielineBuy/1000 * ones(1, I2),...
    'color', brown, 'LineWidth' , 0.5, 'LineStyle', '-.', 'DisplayName', '功率上限'); 
set(H1(1), 'color', olivedrab, 'LineWidth', 1.5, 'LineStyle', '-');
set(H1(2), 'color', brown, 'LineWidth', 1.5, 'LineStyle', '-');
set(H4(1), 'color', dodgerblue, 'LineWidth', 1.5, 'LineStyle', '-');

ylim([-tielineSold/1000, tielineBuy/1000 * 1.1]);
ylabel('功率(MW)')
yyaxis right
H2(1) = stairs(t, offsetArray(gridPriceRecord4, I / 2), 'color', black, 'LineWidth', 1, 'LineStyle', '-.');
H2(2) = stairs(t, offsetArray(priceRecord, I / 2), 'color', black, 'LineWidth', 1.5, 'LineStyle', '-');
le = legend([H1(2), H1(1), H4(1), Hev, Htcl, H2(1), H2(2)],...
        '主变功率', 'EV出清功率', 'TCL出清功率', 'EV最优功率', 'TCL最优功率', '主网电价', '本地电价', 'Orientation','vertical'); set(le, 'Box', 'off')
ylabel('电价(元/kWh)');
ylim([min(priceRecord)/1.1, max(priceRecord)*1.1]);
xlim([0, 24]);
xticks(0 : 6 : 24);
% xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
set(gca,'xticklabel','');

subplot(TOTAL_PLOT, 1, 2); hold on;
yyaxis left;
H3 = plot(t1, offsetArray(sum(TCLdata_P/1000), I1 / 2));
H4(2) = stairs(t2, appendStairArray(offsetArray(TCLpowerAvg/1000, I2 / 2)));
H4(1) = stairs(t2, appendStairArray(offsetArray(TCL_totalpowerRecord/1000, I2 / 2)));
set(H3, 'color', gray, 'LineWidth', 0.5);
set(H4(2), 'color', black, 'LineWidth', 2, 'LineStyle', ':');
set(H4(1), 'color', olivedrab, 'LineWidth', 1, 'LineStyle', '-');
ylabel('TCL聚合功率(MW)');
ylim([min(sum(TCLdata_P/1000)) / 1.1, max(sum(TCLdata_P/1000)) * 1.1])
yyaxis right;
H5 = plot(1 / 60 : 1 / 60 : 24 , offsetArray(Tout, 720), 'color', tomato, 'LineWidth', 1.5, 'LineStyle', ':', 'DisplayName', '室外温度');
xlim([0, 24]);
xticks(0 : 6 : 24);
ylabel('室外温度(摄氏度)');
xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
% set(gca,'xticklabel','');
le = legend([H4(1), H4(2), H3, H5],'出清功率', '平均功率','实际功率', '室外温度', 'Orientation','vertical'); set(le, 'Box', 'off');
set(gcf,'unit','normalized','position',[0,0,0.3,0.3]);

figure; hold on;
TOTAL_PLOT = 3;
%TCL跟踪曲线和实际响应曲线
[~, tcl_max] = max(TCLdata_beta);
draw(1, TCLdata_beta(tcl_max), TCLdata_P(tcl_max, :), TCLpowerRecord(tcl_max, :), TCLdata_PN(tcl_max), TCLdata_Ta(tcl_max, :), ...
    T_tcl, Tout, TCLdata_T(1, tcl_max), TCLdata_T(2, tcl_max), dodgerblue, black, tomato, 0);
tcl = 32;
draw(2, TCLdata_beta(tcl), TCLdata_P(tcl, :), TCLpowerRecord(tcl, :), TCLdata_PN(tcl), TCLdata_Ta(tcl, :),...
    T_tcl, Tout, TCLdata_T(1, tcl), TCLdata_T(2, tcl), dodgerblue, black, tomato, 0);
[~, tcl_min] = min(TCLdata_beta);
draw(3, TCLdata_beta(tcl_min), TCLdata_P(tcl_min, :), TCLpowerRecord(tcl_min, :), TCLdata_PN(tcl_min), TCLdata_Ta(tcl_min, :),...
    T_tcl, Tout, TCLdata_T(1, tcl_min), TCLdata_T(2, tcl_min), dodgerblue, black, tomato, 1);
set(gcf,'unit','normalized','position',[0,0,0.2,0.4]);

%各TCL实际成本和优化所得成本
%统计单个TCL电费
TCLdata_cost = zeros(2, TCL);
for tcl = 1 : TCL
    cost = 0;
    for i = 1 : 24
        cost = cost + mean(TCLdata_P(tcl, (i - 1) * T_tcl / dt + 1 : i * T_tcl / dt )) * gridPriceRecord(1, i);
    end
    TCLdata_cost(1, tcl) = cost;
    TCLdata_cost(2, tcl) = TCLpowerRecord(tcl, :) * gridPriceRecord';
end

figure; hold on;
% rgb = num2rgb(TCLdata_beta);
rgb = zeros( TCL, 3);
rgb(: , 1) = 1- TCLdata_beta / 10;
% TCLdata_Tset = (TCLdata_T(1, :) - TCLdata_T(2, :)) / 9 .* ( TCLdata_beta - 1) + TCLdata_T(2, :);
scatter(TCLdata_cost(1, :), TCLdata_cost(2, :) , 15, rgb,'filled', 'DisplayName', '\beta');
xlabel('实际成本(元)');
ylabel('出清成本(元)');
legend('show');
set(gcf,'unit','normalized','position',[0,0,0.2,0.2]);

%-------------function definition-------------------------------------
function [] = draw( subNo, beta, P, powerRecord, PN, Ta,...
    T_tcl, Tout, T_max, T_min,  dodgerblue, black, tomato, showAxis)
global dt I2 I1 t1 t2 TOTAL_PLOT
P = offsetArray(P, I1 / 2);
powerRecord = offsetArray(powerRecord, I2 / 2);
Ta = offsetArray(Ta, I1 / 2);
Tout = offsetArray(Tout, 720);
subplot(TOTAL_PLOT, 1, subNo);
hold on;
TCLpowerAvg = zeros(1, I2);
for ii = 1 : I2
    TCLpowerAvg(1, ii) = mean(P(1, (ii - 1) * T_tcl / dt + 1 : ii * T_tcl / dt));
end
yyaxis left
H1 = stairs(t2, appendStairArray(powerRecord), 'color', black, 'LineWidth', 2, 'DisplayName', '出清功率');
H2 = stairs(t2, appendStairArray(TCLpowerAvg) , 'color', dodgerblue, 'LineWidth', 1, 'DisplayName', '平均功率', 'LineStyle', '-');
ylabel('单个TCL功率((kW)');
ylim([0, PN]);
yyaxis right
TaNormalize = (Ta - T_min) / (T_max - T_min) * 100;
H3 = plot(t1, TaNormalize , 'color', tomato, 'LineWidth', 1.5,'DisplayName', '室内温度');
plot(t1, [zeros(1, I1); 100 * ones(1, I1)],...
    'color', tomato, 'LineWidth' , 0.5, 'LineStyle', '-.', 'DisplayName', '室温上下限'); 
ylabel('SOA(%)');

le = legend([H1, H2, H3], '出清功率', '平均功率', 'SOA', 'Orientation','horizontal'); set(le ,'Box', 'off');
ymin =  min(0, min(TaNormalize));
ymax = max(100, max(TaNormalize));
ylim([ymin - 10, ymax + 10]);
xlim([0, 24]);
xticks(0 : 6 : 24);
if showAxis == 1
    xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
else
    set(gca,'xticklabel','');
end
content = sprintf('gamma = %2f', beta);
title(content)
end

function [ result ] = offsetArray(array, offset) 
[row, col] = size(array);
offset = mod(offset, max(row, col));
if col > 1 %行向量
    result = [ array(1, offset + 1 : end), array(1, 1: offset)];
else
    result = [ array(offset + 1: end, 1); array(1 : offset, 1)];
end
end

function [ result ] = appendStairArray(array)%为stairs作图的数组增加最后一列
[row, col] = size(array);
if col > 1 %行向量
    result = [array, array(end)];
else
    result = [array; array(end)];
end
end