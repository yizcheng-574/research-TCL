clc; clear;
close all;
addPath;
load('../data/COLOR');
macPath = '../data/penetration/';
%%%% variable format
%                  case1 case2 case3 case4
% -----------------------------------------
% penetration 20%
% penetration 100%
costP = zeros(5,4);
penaltyP = zeros(5,4);
relativeAgingP = zeros(5,4);
lfP = zeros(5,4);
penaltyP = zeros(5,4);
for penetration = 2 : 2 : 10
    pindex = penetration / 2 ;
    load([macPath, 'mode', num2str(penetration)]);
    cindex = 1;
    penetrationRecord;
    load([macPath, 'modeEV', num2str(penetration)]);
    cindex = 3;
    penetrationRecord;
    load([macPath, 'modeTCL', num2str(penetration)]);
    cindex = 4;
    penetrationRecord;
    load([macPath, 'modePD', num2str(penetration)]);
    cindex = 2;
    penetrationRecord;
end
subplot(1,3,1);
draw(costP, 'electricity cost(yuan)');
subplot(1,3,2);
draw(penaltyP, 'penalty cost(yuan)');
subplot(1,3,3);
draw(20*7./relativeAgingP, 'transformer life (yrs)');
set(gcf,'unit','normalized','position',[0,0,0.3,0.25]); 

function draw(y, yl)
    p = 20 : 20 : 100;
    hold on;
    h1 = plot(p, y(:, 1), 'k', 'Marker', 'o','LineStyle', ':');
    h2 = plot(p, y(:, 2), 'b', 'Marker', '+','LineStyle', '-');
    h3 = plot(p, y(:, 3), 'k', 'Marker', '*','LineStyle', '-.');
    h4 = plot(p, y(:, 4), 'r', 'Marker', 'o','LineStyle', '-');
    le = legend([h1, h2, h3, h4], 'Case I (UC)', 'Case II (NC)', 'Case III (EV only)', 'Case IV (NI-TC)', 'Orientation', 'vertical');
    set(le ,'Box', 'off');
    xlabel('EV penetration (%)')
    ylabel(yl);
end
