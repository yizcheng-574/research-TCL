addPath;warning('off');
startmatlabpool();
clc; clear;
path = '../../data/20200305';
dataPath = [path, '/data.mat'];
WEEK = 1;
DAY = WEEK * 7;
RATIO = 10; 
EV = 5 * RATIO; % EV总数，额定功率为3.7kW
FFA = 6 * RATIO; % 空调总数
IVA = 4 * RATIO;
T = 15 / 60; % 控制周期15min
dt = 1 / 60 / 60; % 空调控制周期2s
T_tcl = 1; % 空调控制指令周期60min
T_mpc = 6;
I1 = 24 * DAY / dt;
I = 24 * DAY / T;
I_day = 24 / T;
I_tcl = T_tcl / T;
I2 = 24 * DAY / T_tcl;
LOAD = 18 * RATIO; % LOAD最大负荷（kW）
WIND = 6 * RATIO; % WIND风电装机容量（kW）
tielineSold = 10 * RATIO;
tielineBuy = 31.5 * RATIO;
eta = 0.9;
ratioFFA = 0.7;
ratioIVA = 2;
tolerance = 0.01;
if exist('DAY', 'var') == 1
    isMultiDay = 1;
else
    isMultiDay = 0;
end
willFFAclose = 0;
willIVAclose = 1;
mktInit;
priceInit;
EVinit;
TCLinit;
save(dataPath);
modeType = [
    1, 1, 1, 1; % Case I - TEC
    1, 1, 0, 1; % Case II - TEC w/o ACLs  
    0, 1, 1, 1; % Case III - TEC w/o smart overloading management
    % 0, 1, 1, 0; % Case III 2 - TEC w/o smart overloading management w/o heb
    0, 0, 0, 0; % Case V - uncontrolled
];
    % TC方案，对EV、TCL进行优化结果比较
for mode = 1 : 4
    clearvars -except modeType mode dataPath penetration
    load(dataPath);
    isAging = modeType(mode, 1);
    isEVflex = modeType(mode,2);
    isTCLflex = modeType(mode, 3);
    isHeb = modeType(mode, 4);
    main_multidays;
    if mode == 1
          save([path, '/TEC']);
    elseif mode == 2
        save([path, '/TEC_wo_ACLs']);
    elseif mode == 3
        save([path, '/TEC_wo_SOM']);
    else
        save([path, '/uncontrolled']);
    end
end
clearvars -except dataPath modeType mode penetration RATIO 
load(dataPath);
priceDriven; % Case IV - non-coordinated
save([path, '/non_coordinated']);
clearvars -except dataPath modeType mode penetration RATIO 
closematlabpool();