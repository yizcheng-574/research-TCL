% TC方案，对EV、TCL进行优化结果比较
addPath;warning('off');
startmatlabpool();
clc; clear;
path = '..\..\data\0705-2';
dataPath = [path, '\data'];
% DAY = 7;
% RATIO = 100;
% EV = 5 * RATIO; % EV总数，额定功率为3.7kW
% FFA = 6 * RATIO; % 空调总数
% IVA = 4 * RATIO;
% T = 15 / 60; % 控制周期15min
% dt = 1 / 60 / 60; % 空调控制周期2s
% T_tcl = 1; % 空调控制指令周期60min
% T_mpc = 6;
% I1 = 24 * DAY / dt;
% I = 24 * DAY / T;
% I_day = 24 / T;
% I_tcl = T_tcl / T;
% I2 = 24 * DAY / T_tcl;
% LOAD = 15 * RATIO; % LOAD最大负荷（kW）
% WIND = 10 * RATIO; % WIND风电装机容量（kW）
% tielineSold = 10 * RATIO;
% tielineBuy = 31.5 * RATIO;
% eta = 0.9;
% ratioFFA = 0.7;
% ratioIVA = 2;
% tolerance = 0.01;
% if exist('DAY', 'var') == 1
%     isMultiDay = 1;
% else
%     isMultiDay = 0;
%     
% end
% mktInit;
% priceInit;
% EVinit;
% TCLinit;
% save(dataPath);

% modeType = [
%     0, 0, 0;
%     0, 1, 0;
%     0, 1, 1;
%     1, 1, 1;
% ];
modeType = [
    0, 0, 0;
    1, 1, 0;
    1, 1, 1;
    1, 1, 2;
];
for mode = 4:4
    clearvars -except modeType mode dataPath
    load(dataPath);
    isAging = modeType(mode, 1);
    isEVflex = modeType(mode,2);
    isTCLflex = modeType(mode, 3);
    main_multidays;
    if mode == 1
        save([path, '\mode']);
    elseif mode == 2
        save([path, '\modeEV']);
    elseif mode == 3
        save([path, '\modeTCL']);
    else
        save([path, '\modeAging']);
    end
end
clearvars -except dataPath
load(dataPath);
priceDriven;
save([path, '\modePD']);
closematlabpool();