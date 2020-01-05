close all;
figure;
subplot(2,2,1); hold on;
for i = 1 : FFA
        plot(12: T: 36, 100 * (TCLdata_Ta(i ,I_day + 48: I_day*2 + 48) - TCLdata_T(2, i)) / (TCLdata_T(1, i) - TCLdata_T(2, i)), 'color', color(i, :)); alpha(0.5);    
    
       
end
plot(t, 100 * ones(length(t),1), 'k', 'LineStyle', '--');

xlim([12, 36]);
xticks(12 : 6 : 36);
xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
ylabel('定频空调满意度(%)')
ylim([60, 110])
        
subplot(2,2,2); hold on;
for i = 1 : FFA
        plot(12: 36, TCLpowerRecord(i, 36:60), 'color', colorBlue(i, :)); alpha(0.5);    
end
xlim([12, 36]);
xticks(12 : 6 : 36);
xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
ylabel('定频空调功率(kW)')
ylim([min(min(TCLpowerRecord(:,24 + 1: 24*2)))*0.9, max(max(TCLpowerRecord(: ,24 + 1: 24*2)))*1.1])

subplot(2,2,3); hold on;
for i = 1 : IVA
    ta = FFAdata(1, i + FFA);
    td = FFAdata(2, i + FFA);
    x1 = ceil(ta/T) * T + T: T: td + 24;
    y1 = (IVAdata_Ta(i ,I_day + 1 + ceil(ta/T): 2 * I_day + floor(td/T))- TCLdata_T(2, i)) / (TCLdata_T(1, i) - TCLdata_T(2, i));
    plot(x1, 100 * y1 , 'color', color(i, :)); alpha(0.5);
end
t = 12:36;
plot(t, 100 * ones(length(t),1), 'k', 'LineStyle', '--');
xlim([12, 36]);
xticks(12 : 6 : 36);
xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
ylim([0, 200])
ylabel('变频空调满意度(%)')


subplot(2,2,4); hold on;
for i = 1 : IVA
    ta = FFAdata(1, i + FFA);
    td = FFAdata(2, i + FFA);
    x1 = ceil(ta/T)* T + T:T: floor(td/T) *T + 24;
    y1 = IVApowerRecord(i ,I_day + 1 + ceil(ta/T): 2 * I_day + floor(td/T));
    plot(x1, y1, 'color', colorBlue(i + FFA - EV, :)); alpha(0.5);   
end

xlim([12, 36]);
xticks(12 : 6 : 36);
xticklabels({ '12:00', '18:00', '24:00', '6:00', '12:00'});
ylim([0,5])
ylabel('变频空调功率(kW)')
set(gcf,'position',[0,0,650,400]);

