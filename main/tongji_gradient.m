close all;
global T t tomato royalblue
T = 0.25;
t = T:T:24;
tomato = [0.811764705882353,0.360784313725490,0.360784313725490];
royalblue = [0.254900000000000,0.411760000000000,0.882350000000000];

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

figure;
plotTwoScheme(mean(EVdata_E_normal(:, 2:end)), mean(EVdata_E_normal_G(:, 2:end)), 'mean SOC', 2);

figure;
subplot(2, 1, 1);
plotTwoScheme(trans.tielineRecord /1000, transG.tielineRecord /1000, 'tranformer power(MW)', 2);
plot(t, ones(1, length(t)) * trans.CAPACITY / 1000, 'LineWidth', 1, 'LineStyle', ':', 'Color', 'black');

subplot(2, 1, 2);
plotTwoScheme(trans.priceRecord, transG.priceRecord * transG.eta , 'price', 2); 
plot(t, trans.gridPriceRecord, 'DisplayName', 'RT', 'LineWidth', 1.5, 'Color', 'black')
figure
plotTwoScheme(trans.DL_record, transG.DL_record, 'loss of life (min)', 2);

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


function plotTwoScheme(plot1, plot2, label, lineWdith)
    global T t tomato royalblue
    plot(t, plot1, 'DisplayName', 'TC', 'Color', tomato, 'LineWidth', lineWdith); hold on;
    plot(t, plot2, 'DisplayName', 'SG', 'Color', royalblue, 'LineWidth', lineWdith);
    ylabel(label)
    set(gcf,'unit','normalized','position',1.2 * [0,0,0.2,0.15]);
    set(gca,'xticklabel','');
    xticks(0 : 6 : 24);
    xticklabels({ '12', '18', '24', '6', '12'});
end