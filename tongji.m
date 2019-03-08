close all;
global FFA IVA EV T T_tcl dt I I2 I1 t2

gold = [1 0.843 0];
gray = [0.9 0.9 0.9];
black = [0, 0, 0];
olivedrab = [0.41961 0.55686 0.13725];
light_olivedrab = [203, 218, 175] / 255;
yellowgreen = [0.60392 0.80392 0.19608];

firebrick = [0.69804 0.13333 0.13333];
tomato = [207, 92, 92] / 255;

royalblue = [0.2549 0.41176 0.88235];
royalblue_dark = [0.15294 0.25098 0.5451];
darkblue =[0 0 0.5451];
dodgerblue = [0.11765 0.56471 1];
light_dodgerblue = [157,197,238]/255;

green = [103, 138 ,38] / 255;
blue = [109 179 223] / 255;
purple = [52, 29, 94] / 255;

light_green = [194, 216, 153] / 255;
light_blue = [168, 204, 226] / 255;
light_purple = [175, 153, 216] / 255;

t1 = dt: dt : 24;
t = T : T :24;
t2 = 0 : T_tcl : 24;

FFApowerAvg = zeros(1, I2);
TCLpowerAvg_benchmark = zeros(1, I2);
FFApowerAvg_benchmark = zeros(1, I2);

for i = 1 : I2
    if isTCLflex == 1
        FFApowerAvg(1, i) = mean(sum(TCLdata_P(:, (i - 1) * T_tcl / dt + 1 : i * T_tcl / dt)));
        if isEVflex == 1
            TCLpowerAvg_benchmark(1, i) = mean(sum(TCLdata_P_benchmark(:, (i - 1) * T_tcl / dt + 1 : i * T_tcl / dt)));
            FFApowerAvg_benchmark(1, i) = mean(sum(TCLdata_P_benchmark(1: FFA, (i - 1) * T_tcl / dt + 1 : i * T_tcl / dt)));
        end
    end
end

%计算老化
if isAging == 0 
    TransformerInit;
    for i = 1 : I
        t_index = mod(i - 1 + offset / T , I) + 1;
        mod_t = mod(t_index, I) + 1;
        mod_t_1 = mod(t_index - 1, I) + 1;
        isBid = 0;
        time = (t_index - 1) * T ;
        theta_a = mean(Tout( 1 + time * 60 : (time + 0.25) * 60));%C
        transformer_ageing;
    end
end

%各TCL实际成本和优化所得成本
%统计单个TCL电费
TCLdata_cost = zeros(3, FFA);
IVAdata_cost = zeros(3, IVA);

if isTCLflex == 1
    for tcl = 1 : FFA
        cost = 0;
        cost_ideal = 0;
    for i = 1 : I
        cost = cost + T * mean(TCLdata_P(tcl, (i - 1) * T / dt + 1 : i * T / dt )) * priceRecord(1, i);
        cost_ideal = cost_ideal + T * TCLpowerRecord(tcl, ceil(i / 4)) * priceRecord(1, i);    
    end
        TCLdata_cost(1, tcl) = cost;%按主网结算实际电价
        TCLdata_cost(2, tcl) = cost_ideal;%按主网结算理想电价
        
    end
    IVAdata_cost(1,:) = gridPriceRecord4 * IVApowerRecord' * T;
    IVAdata_cost(2,:) = priceRecord * IVApowerRecord'* T;
else
    for tcl = 1 : FFA + IVA
        cost_benchmark = 0;
        for i = 1 : I
            cost_benchmark = cost_benchmark + T * mean(TCLdata_P_benchmark(tcl, (i - 1) * T / dt + 1 : i * T / dt )) * priceRecord(1, i);
        end
        if tcl <= FFA
            TCLdata_cost(3, tcl) = cost_benchmark;
        else
            IVAdata_cost(3, tcl - FFA) = cost_benchmark;
        end
    end
end

EVdata_cost(1,:) = gridPriceRecord4 * EVpowerRecord' * T;
EVdata_cost(2,:) = priceRecord * EVpowerRecord'* T;

%计算配网成本
DSO_cost(1) = tielineRecord * (priceRecord - gridPriceRecord4)' * T; %DSO收益
DSO_cost(2) = sum(DL_record) * install_cost / expectancy;%变压器老化成本
DSO_cost(3) = tielineRecord * gridPriceRecord4' * T; %配网总用电成本

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
%----------------------------------------------------------------------
% boxplot(evaluation_ev_finish','Widths',0.3, 'Notch','on','Labels',{'1)', '2)', '3)' '4)'}, 'Colors', [tomato; royalblue; royalblue; royalblue], 'Orientation', 'horizontal'); 
% set(gcf,'unit','normalized','position',[0,0,0.25,0.1]);
% xlabel('EV充电完成度(%)')
% ylabel('方案')
%温度越线情况
% boxplot([evaluation_violation(1:2,1:FFA);evaluation_violation(4, 1:FFA)]','Widths',0.3, 'Notch','on','Labels',{'1)', '2)', '4)'}, 'Colors', [tomato; royalblue; royalblue], 'Orientation', 'horizontal'); 
% set(gcf,'unit','normalized','position',[0,0,0.25,0.1]);
% xlabel('越限程度(小时)')
% ylabel('方案')
%EV充电情况
% figure;
% boxplot(evaluation_ev_finish','Widths',0.3, 'Notch','on','Labels',{'1)', '2)', '3)' '4)'}, 'Colors', [tomato; royalblue; royalblue], 'Orientation', 'horizontal'); 
% set(gcf,'unit','normalized','position',[0,0,0.25,0.1]);
% xlabel('EV充电完成度')
% ylabel('方案')
%用户成本
% figure;
% boxplot(100 * cost(2:4, :)'./ cost(1,:)','Widths',0.3, 'Notch','on','Labels',{'2)', '3)' '4)'}, 'Colors', [tomato; royalblue; royalblue], 'Orientation', 'horizontal'); 
% set(gcf,'unit','normalized','position',[0,0,0.25,0.1]);
% xlabel('各方案用户日成本与方案1的比值(%)')
% ylabel('方案')
%----------------------------------------------------------------------
%基本仿真数据
hold on;
yyaxis left
Hbar = bar(1:24, 100 * offsetArray(gridPriceRecord, I2/2)/ mkt_max); 
Hbar(1).FaceColor = [0.8, 0.8, 0.8];
Hbar(1).EdgeColor = Hbar(1).FaceColor;
H0 = plot(t, 100 * offsetArray(loadPowerRecord, I/2) / LOAD); hold on;
set(H0, 'color', [0, 173, 52 ]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
H1 = plot(t, 100 * offsetArray(windPowerRecord, I/2) / WIND);
set(H1, 'color', [0, 93, 186]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
ylabel('标幺值(%)')
yyaxis right
H3 = plot(1/60:1/60:24, offsetArray(Tout, 720));
set(H3, 'color', tomato,'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
ylabel('室外温度(摄氏度)')

le = legend([H0, H1, Hbar, H3], '基本负荷', '风电功率', '实时电价', '室外温度'); set(le, 'Box', 'off')
plotNormalize;
%----------------------------------------------------------------------
%主变功率，EV，TCL功率曲线，
isFill = 0;
figure;
hold on;
% yyaxis left

%投标上下限功率
if isTCLflex == 1
    H0 = fill([t, fliplr(t)], [offsetArray(sum(IVAminPowerRecord/1000), I / 2), fliplr(offsetArray(sum(IVAmaxPowerRecord/1000), I / 2))], light_purple);
    alpha(0.5);set(H0, {'LineStyle'}, {'none'});
    aggTCLminPowerRecord = sum(TCLminPowerRecord);
    aggTCLmaxPowerRecord = sum(TCLmaxPowerRecord);
    H2 = fill([t2, fliplr(t2)], [appendStairArray(offsetArray(aggTCLminPowerRecord, I2 / 2))/1000, fliplr(appendStairArray(offsetArray(aggTCLmaxPowerRecord, I2 / 2))/1000)], light_blue);
    alpha(0.5);set(H2, {'LineStyle'}, {'none'});
end
if isEVflex == 1
    H1 = fill([t, fliplr(t)], [offsetArray(sum(EVminPowerRecord/1000), I / 2), fliplr(offsetArray(sum(EVmaxPowerRecord/1000), I / 2))], light_green);
    alpha(0.5);set(H1, {'LineStyle'}, {'none'});
end
%投标最优功率和实际出清功率
if isEVflex == 1
    Hev = plot(t, offsetArray(sum(EVavgPowerRecord), I / 2) / 1000);
    set(Hev, 'color', green, 'LineWidth', 1, 'LineStyle', '-.', 'marker', 'none');
end
H1 = plot(t, [offsetArray(EV_totalpowerRecord/1000, I / 2); offsetArray(tielineRecord/1000, I / 2) ]);
set(H1(1), 'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
set(H1(2), 'color', black, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');

if isTCLflex ==1
    Htcl = stairs(t2, appendStairArray(offsetArray(sum(TCLsetPowerRecord), I2 / 2))/1000);
    set(Htcl, 'color', blue, 'LineWidth', 1.5, 'LineStyle', '-.', 'marker', 'none');
    Hiva = plot(t, offsetArray(sum(IVAsetPowerRecord), I / 2) / 1000);
    set(Hiva, 'color', purple, 'LineWidth', 1, 'LineStyle', '-.', 'marker', 'none');
end
H4(1) = stairs(t, offsetArray(TCL_totalpowerRecord, I / 2)/1000);
H4(2) = plot(t, offsetArray(IVA_totalpowerRecord/1000, I / 2));
set(H4(1), 'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
set(H4(2), 'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
%主变功率
H3 = plot(t2, tielineBuy/1000 * ones(1, length(t2)),...
    'color', black, 'LineWidth' , 1, 'LineStyle', ':', 'DisplayName', '功率上限', 'marker', 'none');
ylabel('功率(MW)')
ylim([0, max(tielineRecord)/1000])

le = legend([H1(2), H1(1), H4(1), H4(2), Hev],...
'主变功率', 'EV出清功率', 'FFA出清功率','IVA出清功率', '最优功率', 'Orientation','vertical'); 
set(le, 'Box', 'off')
plotNormalize;
%----------------------------------------------------------------------
%FFA成本偏差
% H0 = scatter(TCLdata_cost(1,:), TCLdata_cost(2,:),10, watermelon, 'filled');
% alpha(0.5);
figure;
boxplot(100 * (TCLdata_cost(1,:) -  TCLdata_cost(2,:))./ TCLdata_cost(2,:), 0, '+', 0);
xlabel('相对误差(%)')
set(gcf,'unit','normalized','position',[0,0,0.25,0.1]);
set(gca,'YTicklabel',{''})

%----------------------------------------------------------------------
%FFA群体跟踪精度
TCLdesiredPower = zeros(1, I2);
for i = 1: I2
    TCLdesiredPower(i) = TCL_totalpowerRecord(1, 4 * i);
end
tmp = sum(TCLdata_P);
FFAerror = zeros(1, I1);
for i = 1: I1
    FFAerror(i) = (tmp(i) - TCLdesiredPower(ceil(i/3600)))/TCLdesiredPower(ceil(i/3600));
end
max(abs((FFApowerAvg - TCLdesiredPower) / TCLdesiredPower))

if isTCLflex == 1
    figure;
%     yyaxis left
    H1 = stairs(t2, appendStairArray(offsetArray(FFApowerAvg/1000, I2 / 2))); hold on;
    set(H1, 'color', [109, 111, 223]/255, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
    H0 = plot(t1, offsetArray(sum((TCLdata_P)/1000), I1 / 2));
    set(H0, 'color', light_blue, 'LineWidth', 0.5, 'LineStyle', '-', 'marker', 'none');
    H2 = stairs(t - T, offsetArray(TCL_totalpowerRecord, I / 2)/1000);
    set(H2, 'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
    H3 = plot(t1, offsetArray(sum(TCLdata_P_benchmark(1:FFA, :)/1000), I1 /2));
    set(H3, 'color', gray - 0.2, 'LineWidth', 0.5, 'LineStyle', '-', 'marker', 'none');
    H4 = stairs(t2, appendStairArray(offsetArray(FFApowerAvg_benchmark/1000, I2 / 2))); hold on;
    set(H4, 'color', gray - 0.2, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none');
    le = legend([H0, H1, H2, H3, H4], '实际功率', '1h平均功率', '出清功率(目标功率)', '不控实际功率', '不控平均功率', 'Orientation', 'vertical'); set(le, 'Box', 'off');
    ylabel('FFA聚合功率(MW)')
    ylim([min(sum(TCLdata_P_benchmark(1:FFA, :)/1000)) / 1.1, max(sum(TCLdata_P_benchmark(1:FFA, :)/1000)) * 1.1])
%     yyaxis right
%     H5 = plot(1 / 60 : 1 / 60 : 24 , offsetArray(Tout, 720), 'color', tomato, 'LineWidth', 1.5, 'LineStyle', '-', 'DisplayName', '室外温度');
%     ylabel('室外温度(摄氏度)');
    plotNormalize;
end
%----------------------------------------------------------------------
%功率与电价的关系
figure; hold on;
%电价
yyaxis left;
Hbar = bar(t - 0.25, [offsetArray(gridPriceRecord4, I / 2);offsetArray(priceRecord - gridPriceRecord4, I / 2)]', 'stacked');
Hbar(1).FaceColor = gray;
Hbar(1).EdgeColor = Hbar(1).FaceColor;
Hbar(2).FaceColor = tomato;
Hbar(2).EdgeColor = 'none';% Hbar(2).FaceColor;
ylabel('电价(元/kWh)');
ylim([min(gridPriceRecord) * 0.9, max(priceRecord) * 1.1]);
yyaxis right;

if isTCLflex == 1
   %HVAC功率 
    H1 = stairs(t, offsetArray((TCL_totalpowerRecord + IVA_totalpowerRecord)/1000, I / 2)); 
    H2 = stairs(t2, appendStairArray(offsetArray(TCLpowerAvg_benchmark/1000, I2 / 2)));
    set(H1, 'color', blue, 'LineWidth', 2, 'LineStyle', '-', 'marker', 'none');
    set(H2, 'color', blue, 'LineWidth', 2, 'LineStyle', ':', 'marker', 'none');
end
if isEVflex == 1
    %EV功率
    H3 = stairs(t, offsetArray((EV_totalpowerRecord)/1000, I / 2)); 
    H4 = stairs(t, offsetArray(EVpowerAvg_benchmark/1000, I / 2));
    set(H3, 'color', green, 'LineWidth', 2, 'LineStyle', '-', 'marker', 'none');
    set(H4, 'color', green, 'LineWidth', 2, 'LineStyle', ':', 'marker', 'none');
end
if isTCLflex * isEVflex == 1
    le = legend([Hbar(1), Hbar(2), H1, H2, H3, H4],'实时电价', '出清电价', 'HVAC出清功率', 'HVAC不控功率', 'EV出清功率', 'EV不控功率',  'Orientation','vertical'); 
elseif isTCLflex == 1 && isEVflex == 0
    le = legend([Hbar(1), Hbar(2), H1, H2],'实时电价', '出清电价', 'HVAC出清功率', 'HVAC不控功率',  'Orientation','vertical'); 
else
    le = legend([Hbar(1), Hbar(2), H3, H4],'实时电价', '出清电价', 'EV出清功率', 'EV不控功率',  'Orientation','vertical'); 
end
set(le, 'Box', 'off');
plotNormalize;
ylabel('聚合功率(MW)');

if isTCLflex == 1
    figure; hold on;
    TOTAL_PLOT = 1;
    %TCL跟踪曲线和实际响应曲线
    [~, tcl_max] = max(EVdata_beta);
    draw(1, EVdata_beta(tcl_max), TCLdata_P(tcl_max, :), TCLpowerRecord(tcl_max, :), TCLdata_PN(tcl_max), TCLdata_Ta(tcl_max, :), ...
        T_tcl, Tout, TCLdata_T(1, tcl_max), TCLdata_T(2, tcl_max), blue, tomato, light_blue, 0);
    tcl = 1;
    draw(2, EVdata_beta(tcl), TCLdata_P(tcl, :), TCLpowerRecord(tcl, :), TCLdata_PN(tcl), TCLdata_Ta(tcl, :),...
        T_tcl, Tout, TCLdata_T(1, tcl), TCLdata_T(2, tcl),  blue, tomato, light_blue, 0);
    [~, tcl_min] = min(EVdata_beta);
    draw(3, EVdata_beta(tcl_min), TCLdata_P(tcl_min, :), TCLpowerRecord(tcl_min, :), TCLdata_PN(tcl_min), TCLdata_Ta(tcl_min, :),...
        T_tcl, Tout, TCLdata_T(1, tcl_min), TCLdata_T(2, tcl_min),  blue, tomato, light_blue, 1);
    set(gcf,'unit','normalized','position',[0,0,0.2,0.4]);
end

%-------------function definition-------------------------------------
function [] = draw( subNo, beta, P, powerRecord, PN, Ta,...
    T_tcl, Tout, T_max, T_min, powerColor, temperatureColor, instantPowerColor, showAxis)
global dt I2 I1 t1 t2 TOTAL_PLOT
P = offsetArray(P, I1 / 2);
powerRecord = offsetArray(powerRecord, I2 / 2);
Ta = offsetArray(Ta, I1 / 2);
Tout = offsetArray(Tout, 720);
% subplot(TOTAL_PLOT, 1, subNo);
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
% content = sprintf('\gamma = %2f', beta);
% title(content)
end

function [ result ] = offsetArray(array, offset)
[row, col] = size(array);
offset = mod(offset, max(row, col));
if row == 1 %行向量
    result = [ array(1, offset + 1 : end), array(1, 1: offset)];
elseif col == 1
    result = [ array(offset + 1: end, 1); array(1 : offset, 1)];
else
    result = [ array(:, offset + 1 : end), array(:, 1: offset)];
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