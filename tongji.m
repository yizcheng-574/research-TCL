close all;
orange = [1 0.65 0];
gold = [1 0.843 0];
gray = [0.5 0.5 0.5];

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
%TCL跟踪曲线和实际响应曲线
t1 = dt: dt : 24;
t2 = T : T :24;
figure; hold on;
[AX, H1, H2] = plotyy(t2, [totalpowerRecord; tielineRecord], t2, [gridPriceRecord4; priceRecord]);
H3 = plot(t1, sum(TCLdata_P), 'Color','k','DisplayName', 'TCL实际功率');
set(H1(1), 'Color', dodgerblue, 'LineWidth', 1.5);
set(H1(2), 'Color', orange, 'LineWidth', 1.5);
set(H1(3), 'Color', yellowgreen, 'LineWidth', 1.5);
set(H3, 'LineWidth', 0.5);
set(H2(2), 'Color', chocolate3, 'LineWidth', 1.5, 'LineStyle', ':');
set(H2(1), 'Color', royalblue, 'LineWidth', 1.5, 'LineStyle', ':');
set(AX(1), 'xlim', [0, 24])
set(AX(2), 'xlim', [0, 24])
set(gca, 'XTick', 0 : 6 : 24, 'XTickLabel',{'0:00','6:00','12:00','18:00','24:00'})
set(AX(2), 'XTick', [], 'XTickLabel', [])
set(AX(1), 'ylim', [-tielineSold, tielineBuy])
legend([H1(3), H1(1), H1(2), H3, H2(1), H2(2)],'主变功率', 'EV', 'TCL', 'TCL实时功率', '主网电价', '本地电价', 'Orientation','horizontal')

figure; hold on;
tcl = 3;
[AX, H1, H2] = plotyy(t2, TCLpowerRecord(tcl, :), t1, [TCLdata_Ta(tcl, 2:end); ones(1, length(t1)) * TCLdata_T(2,tcl); ones(1, length(t1)) * TCLdata_T(1,tcl)]); 
H3 = plot(t1, TCLdata_P(tcl, :));
set(H1, 'Color', dodgerblue, 'LineWidth', 1.5);
set(H2(1), 'Color', gray, 'LineWidth', 1.5);
set(H2(2), 'Color', gold); set(H2(3), 'Color', gold);
set(AX(1), 'xlim', [0, 24])
set(AX(2), 'xlim', [0, 24])
set(gca, 'XTick', 0 : 6 : 24, 'XTickLabel',{'0:00','6:00','12:00','18:00','24:00'})
set(AX(2), 'XTick', [], 'XTickLabel', [])
set(AX(1), 'ylim', [0, TCLdata_PN(1, tcl)]);