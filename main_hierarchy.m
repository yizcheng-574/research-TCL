clc; clear;
global T T_tcl T_mpc I I_day I_tcl I2
%---------------------------
T = 15 / 60;%控制周期15min
T_tcl = 1; %空调控制指令周期60min
T_mpc = 6;
I = 24 / T;
I_day = 24 / T;
I_tcl = T_tcl / T;
I2 = 24 / T_tcl;
%---------------------------
isMultiDay = 0;
RATIO = 50;
EV = [5, 3, 4] * RATIO;
% FFA = [6, 5, 2] * RATIO;
IVA = [4, 5, 8] * RATIO;
LOAD = [20, 15, 5] * RATIO;
WIND = [10, 10, 7] * RATIO;
CAPACITY = [35, 35, 30, 90] * RATIO;

TA_avg = 19.82;
TA_sigma = 1.92;
TD_avg = 8.56 + 24;
TD_sigma = 2;%工作日

p1 = 0.03;
q1 = 0.06;
p2 = -0.4;
q2 = -0.3;

d_theta_h1 = 53.2;
d_theta_h2= 26.6;
theta_o = 63.9;%C
yrs = 20;

step = 500;%投标精度
mkt_min = 0.5;
mkt_max = 1.4;
mkt = [mkt_min,mkt_max,step];
pCurve = (mkt_min:(mkt_max-mkt_min)/step:mkt_max);

load('../data/load_2017');
load('../data/wind_2017');
load('../data/Tout.mat');

windPowerRecord =offsetArray([
    Wind(1, 1: 96);
    Wind(1, 96 + 1 : 96 * 2);
    Wind(1, 96 * 2 + 1 : 96 * 3)
], 48);
loadPowerRecord = offsetArray([
    Load(1, 1: 96);
    Load(1, 96 + 1 : 96 * 2);
    Load(1, 96 * 2 + 1 : 96 * 3)
], 48);
for i = 1 : 24 / T
    ToutRecord(i) = mean(Tout(15 * (i - 1) +1: 15 * i));
end
Tout = offsetArray(ToutRecord, 48);

load('../data/RTP_pjm');
gridPriceRecord = mean(RTP);
for i = 1 : 24
    sigmaRecord(i) = sqrt(mean((RTP(:, i) - gridPriceRecord(i)).^2)); 
end
maxP = max([gridPriceRecord,sigmaRecord]);
minP = min([gridPriceRecord,sigmaRecord]);
gridPriceRecord = (gridPriceRecord - minP) / (maxP - minP) * 1.1 + 0.1;
sigmaRecord = (sigmaRecord - minP) / (maxP - minP) * 1.1 + 0.1;
sigmaRecord(15) = 0.4;
sigmaRecord(17) = 0.4;
    
gridPriceRecord = offsetArray(gridPriceRecord, 12);
sigmaRecord = offsetArray(sigmaRecord, 12);

clear Wind Load ToutRecord i RTP minP maxP


trans1 = distributionTrans(...
          EV(1), FFA(1), IVA(1), LOAD(1), WIND(1), CAPACITY(1), windPowerRecord(1, :), loadPowerRecord(1, :), gridPriceRecord, sigmaRecord, Tout, mkt,...
          TA_avg, TA_sigma, TD_avg, TD_sigma,...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs...
        );
trans2 = distributionTrans(...
          EV(2), FFA(2), IVA(2), LOAD(2), WIND(2), CAPACITY(2), windPowerRecord(2, :), loadPowerRecord(2, :), gridPriceRecord, sigmaRecord, Tout, mkt,...
          TA_avg, TA_sigma, TD_avg, TD_sigma,...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs...
        );
trans3 = distributionTrans(...
          EV(3), FFA(3), IVA(3), LOAD(3), WIND(3), CAPACITY(3), windPowerRecord(3, :), loadPowerRecord(3, :), gridPriceRecord, sigmaRecord, Tout, mkt,...
          TA_avg, TA_sigma, TD_avg, TD_sigma,...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs...
        );
ccp = auctioneer(1, d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY(4), gridPriceRecord, Tout, mkt);
clear EV FFA IVA LOAD WIND CAPACITY windPowerRecord loadPowerRecord gridPriceRecord sigmaRecord Tout mkt...
          TA_avg TA_sigma TD_avg TD_sigma...
          p1 q1 p2 q2 ...
          d_theta_h1 d_theta_h2 theta_o yrs...
%---------------------------
for t_index = 1 : I
    time = (t_index - 1) * T + 12;
    bidCurve = trans1.bid(t_index, time) + trans2.bid(t_index, time) + trans3.bid(t_index, time);
    clcPrice = ccp.clear(t_index, bidCurve);
    for tran_index = 1 : 3
        trans1.clear(clcPrice, t_index, time);
        trans2.clear(clcPrice, t_index, time);
        trans3.clear(clcPrice, t_index, time);
    end
    ccp.update(trans1.getPower(t_index) + trans2.getPower(t_index) + trans3.getPower(t_index), t_index);
end
