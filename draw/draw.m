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