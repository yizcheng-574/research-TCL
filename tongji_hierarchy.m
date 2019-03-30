close all;

load('../data/COLOR');

t = T : T :24;
t2 = 0 : T_tcl : 24;

hold on;
H0 = plot(t, ccp.gridPriceRecord,...
    'color', tomato, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '主网电价');
H1 = plot(t, ccp.priceRecord,...
    'color', gold, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配变电价');
H2 = plot(t, trans1.priceRecord,...
    'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站1电价');
H3 = plot(t, trans2.priceRecord,...
    'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站2电价');
H4 = plot(t, trans3.priceRecord,...
    'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站3电价');

figure;
hold on;
H1 = plot(t, ccp.tielineRecord,...
    'color', gold, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配变电');
H2 = plot(t, trans1.tielineRecord,...
    'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站1');
H3 = plot(t, trans2.tielineRecord,...
    'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站2');
H4 = plot(t, trans3.tielineRecord,...
    'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站3');

