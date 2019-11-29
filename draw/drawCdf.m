function [] = draw_cdf(macPath, variable, yLabelName, index, c1, c2, c3 )
subplot(3,1,index);
hold on


v = load_v([macPath, '/TEC_wo_ACLs.mat'], variable); 
[f, xi] = ecdf(v);
h2 = plot((1-f)*24*7, xi, 'Color', c2, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case II - TEC w/o ACLs'); 

v = load_v([macPath, '/TEC_wo_SOM.mat'], variable); 
[f, xi] = ecdf(v);
h3 = plot((1-f)*24*7, xi,'Color', c3, 'LineStyle', '-', 'LineWidth', 1.5,'DisplayName', 'Case III - TEC w/o smart overloading management'); 

v = load_v([macPath, '/non_coordinated.mat'], variable); 
[f, xi] = ecdf(v);
h4 = plot((1-f)*24*7, xi, 'Color', c2, 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', 'Case IV - non-coordinated'); 

v = load_v([macPath, '/uncontrolled.mat'], variable); 
[f, xi] = ecdf(v);
h5 = plot((1-f)*24*7, xi, 'Color', c3, 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', 'Case V - uncontrolled'); 

v = load_v([macPath, '/TEC.mat'], variable); 
[f, xi] = ecdf(v);
h1 = plot((1-f)*24*7, xi,'Color', c1, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Case I - TEC'); 

if (index == 1)
legend([h1, h2, h3, h4, h5],'Case I - TEC',...
                                'Case II - TEC w/o ACLs', ...
                                'Case III - TEC w/o smart overloading management',...
                                'Case IV - non-coordinated',...
                                'Case V - uncontrolled',...
                                'Orientation', 'vertical',...
                                'Box', 'off');
end
xlim([0, 24 * 7]);
xticks(0 : 12 : 24 * 7);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
xlabel('t(h)');
ylabel(yLabelName);

end

