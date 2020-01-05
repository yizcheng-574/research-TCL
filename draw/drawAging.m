function [] = draw_aging(macPath, variable, t, yLabelName, titleName, index, c1, c2, c3, c4, isOneday )
global isEn
figure;
hold on

v = load_v([macPath, '/TEC_wo_ACLs.mat'], variable); 
if isOneday > 0
    st = isOneday * 96 + 1;
    en = st + 96;
else
    st = 1;
    en = length(t);
end

h2 =  plot(t(st: en), v(st: en), 'Color', c2, 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', 'd', 'MarkerSize', 3, ...
    'DisplayName', 'Case II - TEC w/o ACLs'); 

v = load_v([macPath, '/TEC_wo_SOM.mat'], variable); 
h3 =  plot(t, v,'Color', c3, 'LineStyle', '--', 'LineWidth', 1.5,'DisplayName', 'Case III - TEC w/o smart overloading management'); 

v = load_v([macPath, '/non_coordinated.mat'], variable); 
h4 =  plot(t(st: en), v(st: en), 'Color', c2, 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', 'Case IV - non-coordinated'); 
minY = min(v(st: en)) / 1.05;

v = load_v([macPath, '/uncontrolled.mat'], variable); 
h5 = plot(t(st: en), v(st: en), 'Color', c3, 'LineStyle', ':', 'LineWidth', 1.5, 'Marker', '+', 'MarkerSize', 3,...
    'DisplayName', 'Case V - uncontrolled'); 
maxY = max(v(st: en)) * 1.05;

v = load_v([macPath, '/TEC.mat'], variable); 
h1 = plot(t(st: en), v(st: en),'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5); 

if (index == 1) % temperature
    plot([0, 34 * 7], [120,120], 'LineStyle', '--', 'LineWidth', 0.5, 'Color', c4);
    plot([0, 34 * 7], [140,140], 'LineStyle', '--', 'LineWidth', 0.5, 'Color', c4);
end
if (index == 1)
    if isEn == 1
        le = legend([h1, h2, h3, h4, h5],'Case I   - TEC with ACLs',...
                                    'Case II  - TEC w/o ACLs', ...
                                    'Case III - TEC w/o smart overloading management',...
                                    'Case IV  - non-coordinated',...
                                    'Case V   - uncontrolled',...
                                    'Orientation', 'vertical');
    else
        le = legend([h1, h2, h3, h4, h5],'方案1',...
                                '方案2', ...
                                '方案3',...
                                '方案4',...
                                '方案5',...
                                'Orientation', 'horizontal');
    end
    set(le, 'Box', 'off');
end
for d = 1: 6
drawVerticalLine(24 * d, 0, maxY, 'black', ':')
end
ylim([minY, maxY]);
if isOneday == 0
    xlim([0, 24 * 7]);
    xticks(0 : 12 : 24 * 7);
    xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
else
    xlim([(st-1)/4, en/4]);
     xticks((st-1)/4 : 6 : en/4);
    xticklabels({'0:00', '6:00', '12:00', '18:00', '24:00'});
end
if isEn == 1
    xlabel('t(day)');
    set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);
else
    xlabel('时间')
    set(gcf,'Position',[0 0 650 250]);
end
ylabel(yLabelName);
% title(titleName);

end

