close all;
load('../data/COLOR');
% load('../data/0308/mode3', 'T', 'dt', 'T_tcl', 'DAY', 'mkt_max', 'tielineBuy');

t1 = dt: dt : DAY * 24;
t = T : T : DAY * 24;
t2 = 0 : T_tcl : DAY * 24;
t0 = 1 : DAY * 24;


%计算老化
if isAging == 0 
    TransformerInit;
    for day = 1 : DAY
        for i = 1 : I_day
            isBid = 0;
            t_index = (day - 1) * I_day + i;
            theta_a = Tout(i);
            transformer_ageing_expo;
        end
    end
end

%各TCL实际成本和优化所得成本
%统计单个TCL电费

% if isTCLflex == 1
%     IVAdata_cost = priceRecord * IVApowerRecord'* T;
% else
%     TCLdata_cost = priceRecord * TCLdata_P_benchmark(1: FFA, :)' * T;
%     IVAdata_cost =  priceRecord * TCLdata_P_benchmark(FFA +1 : end, :)'* T;
% end
% 
% EVdata_cost = priceRecord * EVpowerRecord'* T;

%计算配网成本
DSO_cost(1) = sum(DL_record) * install_cost / expectancy;%变压器老化成本
DSO_cost(2) = tielineRecord * gridPriceRecord4' * T; %配网总用电成本

%%violation level
if isTCLflex == 1
    evaluation_violation = zeros(1, FFA + IVA);
    for tcl = 1 : FFA + IVA
        cnt = 0;
        if tcl > FFA
            [~, total] = size(IVAdata_Ta);
            delta_t = T;
        else
            [~, total] = size(TCLdata_Ta);
            delta_t = dt;
        end
        for i = 1: total
            if tcl > FFA
                Ta = IVAdata_Ta(tcl - FFA, i);
            else
                Ta = TCLdata_Ta(tcl, i);
            end
            if  Ta> TCLdata_T(1, tcl)
                cnt = cnt + Ta - TCLdata_T(1, tcl) ;
            elseif Ta < TCLdata_T(2, tcl)
                cnt = cnt + TCLdata_T(2, tcl) - Ta;
            end
        end
        evaluation_violation(1, tcl) = cnt * delta_t;
    end
end
%%price volatility index
cnt = 0;
for i = 2 : I
    cnt = cnt + (priceRecord(i) - priceRecord(i - 1))^2;
end
evaluation_price_volatility = sqrt(cnt/ (I - 1)) / (mkt_max - mkt_min);

%%load volatity
cnt = 0;
for i = 2 : I
    cnt = cnt + (tielineRecord(i) - tielineRecord(i - 1))^2;
end
evaluation_load_volatility =  sqrt(cnt/ (I - 1)) / tielineBuy;

%%EV充电完成情况
evaluation_ev_finish = zeros(1, EV);
for ev = 1 : EV
    evaluation_ev_finish(1, ev) = (max(EVdata_E(ev,:)) - EVdata_mile(1, ev))/ (EVdata_capacity(1, ev) -  EVdata_mile(1,ev));
end

%基本仿真数据
hold on;
yyaxis left
Hbar1 = bar(t0, 100 * gridPriceRecord/ mkt_max); 
Hbar1(1).FaceColor = [0.8, 0.8, 0.8];
Hbar1(1).EdgeColor = Hbar1(1).FaceColor;
Ht1 = plot(t, 100 * loadPowerRecord / LOAD);
set(Ht1, 'color', [0, 173, 52 ]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
H1 = plot(t, 100 * windPowerRecord / WIND);
set(H1, 'color', [0, 93, 186]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
ylabel('标幺值(%)')
yyaxis right
H3 = plot(t, repmat(Tout, 1, DAY));
set(H3, 'color', tomato,'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
ylabel('室外温度(摄氏度)')

le = legend([Ht1, H1, Hbar1, H3], '基本负荷', '风电功率', '实时电价', '室外温度', 'Orientation', 'horizontal'); set(le, 'Box', 'off')
plotNormalize;
%----------------------------------------------------------------------
%电价和功率数据
load('../data/0308/mode1', ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord', 'gridPriceRecord4', 'priceRecord', 'tielineBuy');

figure(1);
subplot(3,1,1);
hold on;
Hbar1 = bar(t - 0.25, [ gridPriceRecord4; (priceRecord - gridPriceRecord4) ]', 'stacked');
Hbar1(1).FaceColor = gray;
Hbar1(1).EdgeColor = Hbar1(1).FaceColor;
Hbar1(2).FaceColor = tomato;
Hbar1(2).EdgeColor = 'none';% Hbar(2).FaceColor;
ylabel('电价(元/kWh)');
ylim([min(gridPriceRecord4) * 0.9, mkt_max]);
le = legend([Hbar1(1), Hbar1(2)], '实时电价', '出清电价', 'Orientation', 'horizontal');
set(le, 'Box', 'off')
set(gca,'xtick',[]);

subplot(3,1,2);
hold on;
load('../data/0308/mode2', 'priceRecord');
Hbar2 = bar(t - 0.25,  [gridPriceRecord4; (priceRecord - gridPriceRecord4)]', 'stacked');
Hbar2(1).FaceColor = gray;
Hbar2(1).EdgeColor = Hbar1(1).FaceColor;
Hbar2(2).FaceColor = tomato;
Hbar2(2).EdgeColor = 'none';% Hbar(2).FaceColor;
ylabel('电价(元/kWh)');
ylim([min(gridPriceRecord4) * 0.9, mkt_max]);
set(gca,'xtick',[]);

subplot(3,1,3);
hold on;
load('../data/0308/mode3', 'priceRecord');
Hbar2 = bar(t - 0.25,  [gridPriceRecord4; (priceRecord - gridPriceRecord4)]', 'stacked');
Hbar2(1).FaceColor = gray;
Hbar2(1).EdgeColor = Hbar1(1).FaceColor;
Hbar2(2).FaceColor = tomato;
Hbar2(2).EdgeColor = 'none';% Hbar(2).FaceColor;
ylabel('电价(元/kWh)');
ylim([min(gridPriceRecord4) * 0.9, mkt_max]);
plotNormalize;

figure(2);
subplot(2,1,1);
hold on;
Ht1 = stairs(t, tielineRecord/1000, 'color', black, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none');
Hev1 = stairs(t, EV_totalpowerRecord/1000, 'color', green, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none');
Htcl1 = stairs(t, (TCL_totalpowerRecord + IVA_totalpowerRecord) /1000, 'color', darkblue, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none');
Hlimit = plot(t2, tielineBuy/1000 * ones(1, length(t2)), 'color', tomato, 'LineWidth' , 1, 'LineStyle', '-', 'DisplayName', '功率上限', 'marker', 'none');
ylabel('功率(MW)')
load('../data/0308/mode2', ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord');
Ht2 = stairs(t, tielineRecord/1000, 'color', black, 'LineWidth', 1.5, 'LineStyle', ':', 'marker', 'none');
Hev2 = stairs(t, EV_totalpowerRecord/1000, 'color', green, 'LineWidth', 1.5, 'LineStyle', ':', 'marker', 'none');
Htcl2 = stairs(t, (TCL_totalpowerRecord + IVA_totalpowerRecord) /1000, 'color', darkblue, 'LineWidth', 1.5, 'LineStyle', ':', 'marker', 'none');
plotNormalize;
xticklabels({ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''});
subplot(2,1,2);
hold on;
load('../data/0308/mode3', ...
    'tielineRecord', 'EV_totalpowerRecord', 'TCL_totalpowerRecord', 'IVA_totalpowerRecord');
Ht3 = stairs(t, tielineRecord/1000, 'color', black, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
Hev3 = stairs(t, EV_totalpowerRecord/1000, 'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
Htcl3 = stairs(t, (TCL_totalpowerRecord + IVA_totalpowerRecord) /1000, 'color', darkblue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
Hlimit = plot(t2, tielineBuy/1000 * ones(1, length(t2)), 'color', tomato, 'LineWidth' , 1, 'LineStyle', '-', 'DisplayName', '功率上限', 'marker', 'none');
plotNormalize;
le = legend([Ht3, Hev3, Htcl3],...
'主变功率', 'EV功率', 'HVAC功率', 'Orientation','horizontal'); 

% load('../data/0308/PD', ...
%     'tielineRecord', 'EVpowerRecord', 'IVApowerRecord', 'TCLpowerRecord');
% tmp = zeros(1, DAY * 24/T);
% for i = 1: length(tmp)
%     tmp(i) = sum(TCLpowerRecord(:, ceil(i * T)));
% end
% Ht4 = stairs(t, tielineRecord/1000, 'color', black, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none');
% Hev4 = stairs(t, sum(EVpowerRecord(:, 1:DAY*24/T))/1000, 'color', green, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none');
% Htcl4 = stairs(t, (sum(IVApowerRecord) + tmp) /1000, 'color', darkblue, 'LineWidth', 1.5, 'LineStyle', '--', 'marker', 'none');
% plotNormalize;
% ylabel('功率(MW)')
% le = legend([Ht3, Hev3, Htcl3],...
% '主变功率', 'EV功率', 'HVAC功率', 'Orientation','horizontal'); 
% set(le, 'Box', 'off')

set(le, 'Box', 'off')
%----------------------------------------------------------------------
%温度曲线
figure;
DAY = 1;
t4 =  0 : T : DAY * 24;
color = ones(FFA + IVA, 3);
color(:, 2:3) = repmat(0.3 + EVdata_beta /2, 2, 2)';
subplot(2,2,1); hold on;
for i = 1 : FFA
    plot(0: T: 24, TCLdata_Ta(i ,I_day: I_day*2), 'color', color(i, :)); alpha(0.5);    
end
ylabel('室内温度');
xlim([0, 24]);
xticks(0 : 6 : 24);
xticklabels({'', '', '', '', ''});

subplot(2,2,2); hold on;
for i = 1 : IVA
    plot(0: T: 24, IVAdata_Ta(i ,I_day: I_day*2), 'color', color(i + FFA - EV, :)); alpha(0.5);    
end
xlim([0, 24]);
xticks(0 : 6 : 24);
xticklabels({'', '', '', '', ''});
color =  ones(FFA + IVA, 3);
color(:, 1:2) = repmat(0.3 + EVdata_beta/2, 2, 2)';

subplot(2,2,3); hold on;
for i = 1 : FFA
    plot(T: T: 24, TCLdata_P(i ,I_day + 1: I_day*2), 'color', color(i, :)); alpha(0.5);    
end
xlim([0, 24]);
xticks(0 : 6 : 24);
xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});
set(gcf,'unit','normalized','position',[0,0,0.25,0.2]);
ylabel('HVAC功率')

subplot(2,2,4); hold on;
for i = 1 : IVA
    plot(T: T: 24, IVApowerRecord(i, I_day + 1: I_day*2), 'color', color(i + FFA - EV, :)); alpha(0.5);    
end
xlabel('t(day)')
xlim([0, 24]);
xticks(0 : 6 : 24);
xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00'});
set(gcf,'unit','normalized','position',[0,0,0.25,0.2]);

%FFA群体跟踪精度
%{
figure; hold on;
H1 = stairs(t1, TCLinstantPowerRecord/1000); hold on;
set(H1, 'color', [109, 111, 223]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
TCLinstantPower_avg = zeros(1, DAY / T_tcl);
for i = 1 : DAY * 24/ T_tcl
    TCLinstantPower_avg(i) = mean(TCLinstantPowerRecord((i - 1) * (T_tcl /dt) + 1 : i * T_tcl / dt));
end
H0 = stairs(t0 -1, TCLinstantPower_avg/ 1000);
set(H0, 'color', light_blue, 'LineWidth', 0.5, 'LineStyle', '-', 'marker', 'none');
H2 = stairs(T_tcl : T_tcl : DAY * 24, sum(TCLpowerRecord)/1000);
set(H2, 'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
le = legend([H0, H1, H2, H3, H4], '实际功率', '1h平均功率', '出清功率(目标功率)', '不控实际功率', '不控平均功率', 'Orientation', 'vertical'); set(le, 'Box', 'off');
ylabel('FFA聚合功率(MW)')
ylim([min(sum(TCLdata_P_benchmark(1:FFA, :)/1000)) / 1.1, max(sum(TCLdata_P_benchmark(1:FFA, :)/1000)) * 1.1])
plotNormalize;
%}
%FFA成本偏差
% H0 = scatter(TCLdata_cost(1,:), TCLdata_cost(2,:),10, watermelon, 'filled');
% alpha(0.5);
% figure;
% boxplot(100 * (TCLdata_cost(1,:) -  TCLdata_cost(2,:))./ TCLdata_cost(2,:), 0, '+', 0);
% xlabel('相对误差(%)')
% set(gcf,'unit','normalized','position',[0,0,0.25,0.1]);
% set(gca,'YTicklabel',{''})

%----------------------------------------------------------------------


%TCL跟踪曲线和实际响应曲线
% draw(1, EVdata_beta(tcl), TCLdata_P(tcl, :), TCLpowerRecord(tcl, :), TCLdata_PN(tcl), TCLdata_Ta(tcl, :), ...
%     T_tcl, Tout, TCLdata_T(1, tcl), TCLdata_T(2, tcl), blue, tomato, light_blue, 0, dt, I2, I1, t1, t2);


%-------------function definition-------------------------------------
function [] = draw( ~, ~, P, powerRecord, PN, Ta,...
    T_tcl, Tout, T_max, T_min, powerColor, temperatureColor, instantPowerColor, showAxis, dt, I2, I1, t1, t2)
figure; hold on;
P = offsetArray(P, I1 / 2);
powerRecord = offsetArray(powerRecord, I2 / 2);
Ta = offsetArray(Ta, I1 / 2);
Tout = offsetArray(Tout, 720);
hold on;
TCLpowerAvg = zeros(1, I2);
for ii = 1 : I2
    TCLpowerAvg(1, ii) = mean(P(1, (ii - 1) * T_tcl / dt + 1 : ii * T_tcl / dt));
end
yyaxis left
% H0 = fill([t1, fliplr(t1)], [zeros(1, I1), fliplr(P)], instantPowerColor);
% alpha(0.5);set(H0,'DisplayName', '出清功率', {'LineStyle'}, {'none'});
H1 = stairs(t2, appendStairArray(powerRecord), 'color', powerColor, 'LineWidth', 2, 'DisplayName', '出清功率');
H2 = stairs(t2, appendStairArray(TCLpowerAvg) , 'color', powerColor, 'LineWidth', 2, 'DisplayName', '平均功率', 'LineStyle', ':');
ylabel('单个FFA功率(kW)');
ylim([0, PN]);
yyaxis right
TaNormalize = (Ta - T_min) / (T_max - T_min) * 100;
H3 = plot(t1, TaNormalize , 'color', temperatureColor, 'LineWidth', 1,'DisplayName', '室内温度');
plot(t1, [zeros(1, I1); 100 * ones(1, I1)],...
    'color', temperatureColor, 'LineWidth' , 0.2, 'LineStyle', '-.', 'DisplayName', '室温上下限');
ylabel('SOA(%)');

le = legend([H1, H2, H3], '出清功率', '平均功率', 'SOA', 'Orientation','horizontal'); set(le ,'Box', 'off');
ymin =  min(0, min(TaNormalize));
ymax = max(100, max(TaNormalize));
ylim([ymin - 10, ymax + 10]);
plotNormalize;
if showAxis == 1
    xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
else
    set(gca,'xticklabel','');
end
end
