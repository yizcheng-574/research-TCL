function [] = draw_aging(macPath, variable, t, yLabelName, titleName, index, c1, c2, c3, c4 )
figure;
hold on

v = load_v([macPath, '/TEC_wo_ACLs.mat'], variable); 
h2 =  plot(t, v, 'Color', c2, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case II - TEC w/o ACLs'); 

v = load_v([macPath, '/TEC_wo_SOM.mat'], variable); 
h3 =  plot(t, v,'Color', c3, 'LineStyle', '-', 'LineWidth', 1.5,'DisplayName', 'Case III - TEC w/o smart overloading management'); 

v = load_v([macPath, '/non_coordinated.mat'], variable); 
h4 =  plot(t, v, 'Color', c2, 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', 'Case IV - non-coordinated'); 
minY = min(v) / 1.05;
v = load_v([macPath, '/uncontrolled.mat'], variable); 
h5 = plot(t, v, 'Color', c3, 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', 'Case V - uncontrolled'); 
maxY = max(v) * 1.05;

v = load_v([macPath, '/TEC.mat'], variable); 
h1 = plot(t, v,'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5); 

if (index == 1) % temperature
    plot([0, 34 * 7], [120,120], 'LineStyle', '--', 'LineWidth', 0.5, 'Color', c4);
    plot([0, 34 * 7], [140,140], 'LineStyle', '--', 'LineWidth', 0.5, 'Color', c4);
end
if (index == 2)
    le = legend([h1, h2, h3, h4, h5],'Case I   - TEC with ACLs',...
                                'Case II  - TEC w/o ACLs', ...
                                'Case III - TEC w/o smart overloading management',...
                                'Case IV  - non-coordinated',...
                                'Case V   - uncontrolled',...
                                'Orientation', 'vertical');
    set(le, 'Box', 'off');
end
for d = 1: 6
drawVerticalLine(24 * d, 0, maxY, 'black', ':')
end
xlim([0, 24 * 7]);
ylim([minY, maxY]);
xticks(0 : 12 : 24 * 7);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
xlabel('t(day)');
ylabel(yLabelName);
% title(titleName);
set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);

end

