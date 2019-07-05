close all;
% load('../../data/0423/hiearchical.mat')
load('../../data/COLOR');

% transAdmm1.calculateCost();
% transAdmm2.calculateCost();
% transAdmm3.calculateCost();
% ccpAdmm.calculateCost();
trans1.calculateCost();
trans2.calculateCost();
trans3.calculateCost();
ccp.calculateCost();

% transAdmm1.priceRecord = pu_avg(:,1) + gridPriceRecord;
% transAdmm2.priceRecord = pu_avg(:,2) + gridPriceRecord;
% transAdmm3.priceRecord = pu_avg(:,3)+ gridPriceRecord;
% ccpAdmm.priceRecord =  pu_avg(:,4)+ gridPriceRecord;

t = T : T :24;
t2 = 0 : T_tcl : 24;
load('../../data/COLOR');

% 功率
figure;
subplot(1,2,1);
hold on;
% H1 = plot(t, -p(:, end),...
%     'color', tomato, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配变电');
% H2 = plot(t, p(:, end- 3),...
%     'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站1');
% H3 = plot(t,  p(:, end- 2),...
%     'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站2');
% H4 = plot(t,  p(:, end- 1),...
%     'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站3');

H = plot(t, ccp.tielineRecord/1000,...
    'color', tomato, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', 'T');
H1 = plot(t, trans1.tielineRecord/1000,...
    'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', 'T1');
H2 = plot(t, trans2.tielineRecord/1000,...
    'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', 'T2');
H3 = plot(t, trans3.tielineRecord/1000,...
    'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', 'T3');

H01 = plot(t, ccp.CAPACITY * ones(1, I)/1000,...
    'color', tomato, 'LineWidth', 1, 'LineStyle', ':', 'marker', 'none', 'DisplayName', 'T');
H11 = plot(t, trans1.CAPACITY * ones(1, I)/1000,...
    'color', purple, 'LineWidth', 1, 'LineStyle', ':', 'marker', 'none', 'DisplayName', 'T1');
H21 = plot(t, trans2.CAPACITY * ones(1, I)/1000,...
    'color', blue, 'LineWidth', 1, 'LineStyle', ':', 'marker', 'none', 'DisplayName', 'T2');
H31 = plot(t, trans3.CAPACITY * ones(1, I)/1000,...
    'color', green, 'LineWidth', 1, 'LineStyle', ':', 'marker', 'none', 'DisplayName', 'T3');
gray = [0.7, 0.7 , 0.7];
H0 = fill([t, fliplr(t)], [DRmode'/max(DRmode)*max(ccp.tielineRecord/1000)*1.1, zeros(1, length(t))], gray);
    alpha(0.5);set(H0, {'LineStyle'}, {'none'});
le = legend([H, H1, H2, H3], 'T', 'T1', 'T2', 'T3'); set(le, 'Box', 'off', 'Orientation', 'horizontal')
DAY = 1;
xlim([0, 24 * DAY]);
ylim([0, max(ccp.tielineRecord/1000)*1.1])
xticks(0 : 12 : 24 * DAY);
xticks(0 : 6 : 24 * DAY);
xticklabels({ '12', '18', '24', '6', '12'});
xlabel('t(h)')
set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);ylabel('lol of life(min)')
ylabel('transformer power(MW)')
subplot(1,2,2);
hold on
% H1 = plot(t, ccpAdmm.DL_record,...
%     'color', tomato, 'LineWidth', 2, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配变电');
% H2 = plot(t, transAdmm1.DL_record,...
%     'color', purple, 'LineWidth', 2, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配电站1');
% H3 = plot(t, transAdmm2.DL_record,...
%     'color', blue, 'LineWidth', 2, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配电站2');
% H4 = plot(t, transAdmm3.DL_record,...
%     'color', green, 'LineWidth', 2, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配电站3');

% H1 = plot(t, ccp.DL_record,...
%     'color', tomato, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配变电');
% H2 = plot(t, trans1.DL_record,...
%     'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站1');
% H3 = plot(t, trans2.DL_record,...
%     'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站2');
% H4 = plot(t, trans3.DL_record,...
%     'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站3');
% xlim([0, 24 * DAY]);
% xticks(0 : 12 : 24 * DAY);
% xticks(0 : 6 : 24 * DAY);
% xticklabels({ '12', '18', '24', '6', '12'});
% xlabel('t(h)')
% set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);ylabel('lol of life(min)')

% figure
% plot(dlRecord,'DisplayName','dlRecord')
% 电价
% figure
hold on;
H0 = plot(t, ccp.gridPriceRecord ,...
    'color', black, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '主网');
H1 = plot(t, ccp.priceRecord,...
    'color', tomato, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配变');
H2 = plot(t, trans1.priceRecord,...
    'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站1');
H3 = plot(t, trans2.priceRecord,...
    'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站2');
H4 = plot(t, trans3.priceRecord,...
    'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站3');
H0 = fill([t, fliplr(t)], [DRmode'/max(DRmode)*mkt_max, zeros(1, length(t))], gray);
    alpha(0.5);set(H0, {'LineStyle'}, {'none'});
% subplot(2,1,2);
% hold on
% H1 = plot(t, ccpAdmm.priceRecord,...
%     'color', gold, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配变电价');
% H2 = plot(t, transAdmm1.priceRecord,...
%     'color', purple, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配电站1电价');
% H3 = plot(t, transAdmm2.priceRecord,...
%     'color', blue, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配电站2电价');
% H4 = plot(t, transAdmm3.priceRecord,...
%     'color', green, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none', 'DisplayName', '配电站3电价');
xlim([0, 24 * DAY]);
xticks(0 : 12 : 24 * DAY);
xticks(0 : 6 : 24 * DAY);
xticklabels({ '12', '18', '24', '6', '12'});
xlabel('t(h)')
set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);ylabel('lol of life(min)')
ylabel('price(yuan/kW)')