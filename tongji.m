close all;
global T_tcl
orange = [1 0.65 0];
gold = [1 0.843 0];
gray = [0.5 0.5 0.5];
black = [0, 0, 0];
olivedrab = [0.41961 0.55686 0.13725];
yellowgreen = [0.60392 0.80392 0.19608];

firebrick = [0.69804 0.13333 0.13333];
tomato = [1 0.38824 0.27843];
brown = [0.80392 0.2 0.2];
maroon = [0.6902 0.18824 0.37647];

royalblue = [0.2549 0.41176 0.88235];
royalblue_dark = [0.15294 0.25098 0.5451];
darkblue =[0 0 0.5451];
dodgerblue = [0.11765 0.56471 1];

indianred = [1 0.41 0.42];
chocolate3 = [0.804 0.4 0.113];
tan2 = [0.93  0.60 0.286];
%----------------------
%主变功率，EV，TCL功率曲线，
%电价曲线
t1 = dt: dt : 24;
t = T : T :24;
t2 = 0 : T_tcl : 24 - T_tcl;
subplot(3, 1 ,1);
isFill = 0;
hold on;
TCLpowerAvg = zeros(1, I2);
for i = 1 : I2
    TCLpowerAvg(1, i) = mean(sum(TCLdata_P(:, (i - 1) * T_tcl / dt + 1 : i * T_tcl / dt)));
end
yyaxis left
H3 = plot(t1, sum(TCLdata_P), 'k-', 'LineWidth', 0.5);
H1 = plot(t, [EV_totalpowerRecord; tielineRecord]);
H4(1) = stairs(t2, TCL_totalpowerRecord);
H4(2) = stairs(t2, TCLpowerAvg);
set(H4(1), 'color', tomato, 'LineWidth', 1.5, 'LineStyle', '-');
set(H4(2), 'color', tomato, 'LineWidth', 1.5, 'LineStyle', ':');
set(H1(1), 'color', black, 'LineWidth', 1.5, 'LineStyle', '-.');
set(H1(2), 'color', black, 'LineWidth', 2, 'LineStyle', '-');
ylim([-tielineSold, tielineBuy]);
ylabel('功率(kW)')
yyaxis right
if isFill == 0
    H2(1) = stairs(t, gridPriceRecord4, 'color', dodgerblue, 'LineWidth', 2, 'LineStyle', '-.');
    H2(2) = stairs(t, priceRecord, 'color', dodgerblue, 'LineWidth', 2, 'LineStyle', '-');
    legend([H1(2), H1(1), H4(1), H4(2), H3, H2(1), H2(2)],...
        '主变功率', 'EV', 'TCL出清功率', 'TCL平均功率','TCL实际功率', '主网电价', '本地电价', 'Orientation','horizontal')
else
    H2 = fill([t, fliplr(t)], [gridPriceRecord4, fliplr(priceRecord)], dodgerblue);
end
ylabel('电价（元/kWh）');
xlabel('时间');
xlim([0, 24]);
xticks(0 : 6 : 24);
xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});

%TCL跟踪曲线和实际响应曲线
[~, tcl_max] = max(TCLdata_beta);
draw(tcl_max, 2, TCLdata_P, TCLpowerRecord, TCLdata_PN, TCLdata_Ta,TCLdata_T,  T_tcl, Tout, dt, I2, I1,  t1, t2, dodgerblue, black, tomato);

[~, tcl_min] = min(TCLdata_beta);
draw(27, 3, TCLdata_P, TCLpowerRecord, TCLdata_PN, TCLdata_Ta, TCLdata_T, T_tcl, Tout,dt, I2, I1,  t1, t2, dodgerblue, black, tomato);

function [] = draw(tcl, subNo, TCLdata_P, TCLpowerRecord, TCLdata_PN, TCLdata_Ta, TCLdata_T, T_tcl, Tout, dt, I2, I1, t1, t2, dodgerblue, black, tomato)
subplot(3, 1, subNo);
hold on;
TCLpowerAvg = zeros(1, I2);
for i = 1 : I2
    TCLpowerAvg(1, i) = mean(TCLdata_P(tcl, (i - 1) * T_tcl / dt + 1 : i * T_tcl / dt));
end
yyaxis left
H1 = stairs(t2, TCLpowerRecord(tcl, :), 'color', black, 'LineWidth', 2, 'DisplayName', '出清功率');
H2 = stairs(t2, TCLpowerAvg, 'color', dodgerblue, 'LineWidth', 1, 'DisplayName', '平均功率', 'LineStyle', '-');
ylabel('TCL功率((kW)');
ylim([0, TCLdata_PN(1, tcl)]);
yyaxis right
H3 = plot(t1, TCLdata_Ta(tcl,:), 'color', tomato, 'LineWidth', 1.5,'DisplayName', '室内温度');
H4 = plot(1/60 : 1/60 : 24 , (Tout - TCLdata_T(2, tcl)) / (TCLdata_T(1, tcl) -TCLdata_T(2, tcl)) /3, 'color', black, 'LineWidth', 1.5,'DisplayName', '室外温度');

plot(t1, [- ones(1, I1); ones(1, I1)],...
    'color', tomato, 'LineWidth' , 0.5, 'LineStyle', '-.', 'DisplayName', '室温上下限'); 
ylim([0, 1.1])
ylabel('温度（摄氏度)');
xlabel('时间');
legend([H1, H2, H3, H4], '出清功率', '平均功率', '室内温度','室外温度', 'Orientation','horizontal');
xlim([0, 24]);
xticks(0 : 6 : 24);
xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});
end