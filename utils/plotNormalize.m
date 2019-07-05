xlim([0, 24 * DAY]);
xticks(0 : 12 : 24 * DAY);
xticklabels({ '0', '12:00', '1', '12:00', '2', '12:00', '3', '12:00', '4', '12:00', '5', '12:00', '6', '12:00', '7'});
set(gca,'xticklabel','');
xlabel('t(day)')
% xticks(0 : 6 : 24 * DAY);
% xticklabels({ '12', '18', '24', '6', '12'});
% xlabel('t(h)')
set(gcf,'unit','normalized','position',[0,0,0.3,0.15]);