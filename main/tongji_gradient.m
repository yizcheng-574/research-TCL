close all;
global T t tomato royalblue c1 c3
T = 0.25;
t = T:T:24;
load('../../data/COLOR');
c1 = black; c2 = green; c3 = darkblue; c4 = tomato;
isEn = 0;
%比较老化
% [p_linear, fval_linear, dlrecord_linear] = lineOptimizeAccordingToPrice(transG.gridPriceRecord', transG.Tout, transG.eta, transG.yrs, lambda_new,  transG.CAPACITY, 2);
% [p_sq, fval_sq, dlrecord_sq] = lineOptimizeAccordingToPrice(transG.gridPriceRecord', transG.Tout, transG.eta, transG.yrs, lambda_new,  transG.CAPACITY, 0);
% [p, fval, dlrecord] = lineOptimizeAccordingToPrice(transG.gridPriceRecord', transG.Tout, transG.eta, transG.yrs, lambda_new,  transG.CAPACITY, 1);
% plot(dlrecord, 'LineWidth', 2, 'DisplayName','精确结果', 'Color', 'black');hold on
% plot(dlrecord_sq, 'LineWidth', 2, 'DisplayName','平方展开');
% plot(dlrecord_linear, 'LineWidth', 2, 'DisplayName', '线性展开');
% set(gcf,'unit','normalized','position',1.2 * [0,0,0.2,0.15]);
% 
% plot(transG.DL_record, 'LineWidth', 2, 'DisplayName','精确结果', 'Color', 'black');hold on
% plot(dlrecord_sq, 'LineWidth', 2, 'DisplayName','平方展开');
% set(gcf,'unit','normalized','position',1.2 * [0,0,0.2,0.15]);

global I

EVdata_E_normal = zeros(trans.EV, I + 1);
EVdata_E_normal_G = zeros(trans.EV, I + 1);

for ev = 1: trans.EV
   EVdata_E_normal(ev, :) = trans.EVdata_E(ev, :) / trans.EVdata_mile(ev);
   EVdata_E_normal_G(ev, :) = transG.EVdata_E(ev, :) / trans.EVdata_mile(ev);
end
% subplot(2,1,1);
% boxplot(EVdata_E_normal);   
% subplot(2,1,2);
% boxplot(EVdata_E_normal_G);   
if isEn == 1
    titlePower = 'tranformer power(MW)';
    titlePrice = 'price(yuan/kWh)';
else
    titlePower = '变压器功率(MW)';
    titlePrice = '电价(元/kWh)';
end

figure;
plotTwoScheme(mean(EVdata_E_normal(:, 2:end)), mean(EVdata_E_normal_G(:, 2:end)), 'mean SOC', 2);

figure;
plotTwoScheme(trans.tielineRecord /35*31.5/100, transG.tielineRecord/35*31.5 /100, titlePower, 1.5);
plot(t, ones(1, length(t)) * trans.CAPACITY /35*31.5 / 100, 'LineWidth', 1, 'LineStyle', ':', 'Color', 'black');
    set(gcf,'position',[0,0,650,200]);

figure; hold on;
Hbar = bar(1:24, trans.gridPriceRecord24, 'DisplayName', '主网电价');
Hbar.EdgeColor = 'none';
Hbar.FaceColor = [0.8 0.8 0.8];
plotTwoScheme(trans.priceRecord, transG.priceRecord * transG.eta ,titlePrice, 1.5); 
ylim([0.45, 1.25])
if isEn == 1
    xlabel('t(h)');
else
    xlabel('时间')
end
    set(gcf,'position',[0,0,650,250]);

figure
plotTwoScheme(trans.DL_record, transG.DL_record, 'loss of life (min)', 1.5);

figure;
plotTwoScheme(trans.TCLdata_Ta_normalize(:, 2:end)', transG.TCLdata_Ta_normalize(:, 2:end)', 'SOA', 0.2);
alpha(0.2);

figure;
scatter(1: trans.IVA, trans.TCLdata_comfort, 20, tomato, 'filled', 'DisplayName', 'TC'); hold on;
scatter(1: transG.IVA, transG.TCLdata_comfort, 20, royalblue, 'filled', 'DisplayName', 'SG');
alpha(0.5)
set(gcf,'unit','normalized','position',1.2 * [0,0,0.2,0.15]);

figure;
plotTwoScheme(trans.EVdata_E(:, 2:end)', transG.EVdata_E(:, 2:end)', 'EV energy', 0.5); 


function plotTwoScheme(plot1, plot2, label, lineWidth)
    global T t c1 c3
    plot(t, plot1, 'DisplayName', '本文方法出清电价', 'Color', c1, 'LineWidth', lineWidth, 'LineStyle', '-'); hold on;
    plot(t, plot2, 'DisplayName', '基于次梯度的方法出清电价', 'Color', c3 , 'LineWidth', lineWidth, 'LineStyle','--');
    ylabel(label)
%     set(gcf,'unit','normalized','position',1.2 * [0,0,0.2,0.15]);
    set(gcf,'position',[0,0,650,400]);
    set(gca,'xticklabel','');
    xticks(0 : 6 : 24);
    xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
end