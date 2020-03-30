global T T_tcl T_mpc I I_day I_tcl I2

load('../data/load_2017');
load('../data/wind_2017');
load('../data/Tout.mat');
load('../data/RTP_pjm');
%---------------------------
T = 15 / 60;%控制周期15min
T_tcl = 1; %空调控制指令周期60min
T_mpc = 6;
I = 24 / T;
I_day = 24 / T;
I_tcl = T_tcl / T;
I2 = 24 / T_tcl;

p1 = 0.03;
q1 = 0.06;
p2 = -0.4;
q2 = -0.3;

d_theta_h1 = 53.2;
d_theta_h2 = 26.6;
theta_o = 63.9;%C
yrs = 20;
eta = 0.9;

step = 100;%投标精度
mkt_min = 0.1;
mkt_max = 1.5;

mkt = [mkt_min,mkt_max,step];
pCurve = (mkt_min:(mkt_max-mkt_min)/step:mkt_max);

ToutRecord = zeros(I, 1);
for i = 1 : 24 / T
    ToutRecord(i) = mean(Tout(15 * (i - 1) +1: 15 * i));
end
ToutRecord = offsetArray(ToutRecord, 12 / T);

gridPriceRecord = mean(RTP);
for i = 1 : 24
    sigmaRecord(i) = sqrt(mean((RTP(:, i) - gridPriceRecord(i)).^2)); 
end
maxP = max([gridPriceRecord, sigmaRecord]);
minP = min([gridPriceRecord, sigmaRecord]);
gridPriceRecord = (gridPriceRecord - minP) / (maxP - minP) * 1.1 + 0.1;
gridPriceRecord = offsetArray(gridPriceRecord, 12);
gridPriceRecord4 = zeros(I, 1);
gridPriceRecord24 = gridPriceRecord;
for i = 1 : 24 / T
    gridPriceRecord4(i) = gridPriceRecord(ceil(i/4));
end
gridPriceRecord = gridPriceRecord4;

sigmaRecord = (sigmaRecord - minP) / (maxP - minP) * 1.1 + 0.1;
sigmaRecord(15) = 0.4;
sigmaRecord(17) = 0.4;
sigmaRecord = offsetArray(sigmaRecord, 12);
