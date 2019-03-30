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
RATIO = 1;
EV = [5, 3, 3] * RATIO;
IVA = [10, 10, 10] * RATIO;
FFA = [0, 0 , 0] * RATIO;
LOAD = [20, 15, 10] * RATIO;
WIND = [10, 10, 3] * RATIO;
CAPACITY = [35, 35, 35, 100] * RATIO;

TA_avg = 19.82;
TA_sigma = 1.92;
TD_avg = 8.56 + 24;
TD_sigma = 2;
EVdata = zeros(2, sum(EV));
EVdata(1,:) = normrnd(TA_avg, TA_sigma, 1, sum(EV));
EVdata(2,:) = normrnd(TD_avg, TD_sigma, 1, sum(EV));
EVdata(EVdata < 12) = 12;
EVdata(EVdata > 36) = 36;
EVdata_mile = unifrnd(10,20,1,sum(EV));
EVdata_capacity = unifrnd(20, 25, 1, sum(EV));
PN = 3.7;

for ev = 1 : sum(EV)
    while EVdata(2,ev) <= EVdata(1,ev) || (EVdata(2, ev) - EVdata(1, ev)) * PN < EVdata_mile(ev)
        EVdata(2,ev) = normrnd(TD_avg, TD_sigma);
    end
end

TCLdata_T(1, :) = unifrnd(27.5, 28.5, 1, sum(IVA)); 
TCLdata_T(2, :) = unifrnd(23.5, 24.5, 1, sum(IVA)); 
TCLdata_C = unifrnd(0.8 ,1.2, 1, sum(IVA));
TCLdata_R = unifrnd(2 ,2.5, 1, sum(IVA));
TCLdata_PN = unifrnd(2.5, 3.5, 1, sum(IVA));
TCLdata_Pmin = unifrnd(0.4, 0.5, 1, sum(IVA));
TCLdata_initT = unifrnd(25.8, 26.2, sum(IVA), 1);

clear TD_avg TA_avg TD_sigma TA_sigma bus1 busi allBus ev tmp 

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

maxWind = max(max(Wind));
windPowerRecord =[
    Wind(1, 1 + 48: 96+ 48) / maxWind * WIND(1);
    Wind(1, 96 + 1+ 48 : 96 * 2+ 48) / maxWind * WIND(2);
    Wind(1, 96 * 2 + 1+ 48 : 96 * 3+ 48) / maxWind * WIND(3)
]';

maxLoad = max(max(Load));
loadPowerRecord = [
    Load(1, 1+ 48: 96+ 48) / maxLoad * LOAD(1);
    Load(1, 96 + 1 + 48: 96 * 2+ 48) / maxLoad * LOAD(2);
    Load(1, 96 * 2 + 1+ 48 : 96 * 3+ 48) / maxLoad * LOAD(3)
]';
ToutRecord = zeros(I, 1);
for i = 1 : 24 / T
    ToutRecord(i) = mean(Tout(15 * (i - 1) +1: 15 * i));
end
ToutRecord = offsetArray(ToutRecord, 12 / T);

load('../data/RTP_pjm');
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
clear Wind Load Tout i RTP minP maxP gridPriceRecord4

isHierarchical = 1;
isADMM = 1;
startmatlabpool();

%----------hierarchical-----------------------------
if isHierarchical == 1
    trans1 = distributionTrans_noAging(0,...
              EV(1), FFA(1), IVA(1), CAPACITY(1), windPowerRecord(:, 1), loadPowerRecord(:, 1), gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
              EVdata(:, 1 : EV(1)), EVdata_mile(1 : EV(1)), EVdata_capacity(1 : EV(1)), PN,...
              TCLdata_T(:, 1 : IVA(1)), TCLdata_R(1 : IVA(1)), TCLdata_C(1 : IVA(1)), TCLdata_PN(1 : IVA(1)), TCLdata_Pmin(1 : IVA(1)), TCLdata_initT(1 : IVA(1)), ...
              p1, q1, p2, q2,...
              d_theta_h1, d_theta_h2, theta_o, yrs...
            );
    trans2 = distributionTrans_noAging(0,...
          EV(2), FFA(2), IVA(2), CAPACITY(2), windPowerRecord(:, 2), loadPowerRecord(:, 1), gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
          EVdata(:, EV(1) + [1 : EV(2)]), EVdata_mile(EV(1) + [1 : EV(2)]), EVdata_capacity(EV(1) + [1 : EV(2)]), PN,...
          TCLdata_T(:, IVA(1) + [1 : IVA(2)]), TCLdata_R(IVA(1) + [1 : IVA(2)]), TCLdata_C(IVA(1) + [1 : IVA(2)]), TCLdata_PN(IVA(1) + [1 : IVA(2)]), TCLdata_Pmin(IVA(1) + [1 : IVA(2)]), TCLdata_initT(IVA(1) + [1 : IVA(2)]), ...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs...
        );
    trans3 = distributionTrans_noAging(0,...
          EV(3), FFA(3), IVA(3), CAPACITY(3), windPowerRecord(:, 3), loadPowerRecord(:, 1), gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
          EVdata(:, end - EV(3) + 1 : end), EVdata_mile(end - EV(3) + 1 : end), EVdata_capacity(end - EV(3) + 1 : end), PN,...
          TCLdata_T(:, end - IVA(3) + 1 : end), TCLdata_R(end - IVA(3) + 1 : end), TCLdata_C(end - IVA(3) + 1 : end), TCLdata_PN(end - IVA(3) + 1 : end), TCLdata_Pmin(end - IVA(3) + 1 : end), TCLdata_initT(end - IVA(3) + 1 : end), ...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs...
        );
    ccp = auctioneer(0, d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY(4), gridPriceRecord, ToutRecord, mkt);

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
    save ('../data/0308/admm', 'trans1', 'trans2', 'trans3', 'ccp')
end
%----------ADMM--------------------------------------
if isADMM == 1
    lambda = 1e-3;
    miu = 1e-1;
    beta = 0.5;

    MAX_ITER = 100;
    ABSTOL   = 1e-4;
    RELTOL   = 1e-2;
    transformer = 3;
    T_C = CAPACITY(1:transformer);
    DT_C = CAPACITY(end);
    loadnumber = sum(EV) + sum(IVA);
    TERMINAL = loadnumber + transformer * 3 + 1;
    % EV1 EV2 EV3 IVA1 IVA2 IVA3 N11 N21 N31 N12 N22 N32 N4
    A = zeros(transformer + 1, TERMINAL);

    A(1, 1 : EV(1)) = ones(1, EV(1));
    A(2, EV(1) + 1: EV(1) + EV(2)) = ones(1, EV(2));
    A(3, EV(1) + EV(2) + 1: sum(EV)) = ones(1, EV(3));

    A(1, sum(EV) + 1 : sum(EV) + IVA(1)) = ones(1, IVA(1));
    A(2, sum(EV) + 1 + IVA(1) : sum(EV) + IVA(1) + IVA(2)) = ones(1, IVA(2));
    A(3, sum(EV) + 1 + IVA(1) + IVA(2): sum(EV) + sum(IVA)) = ones(1, IVA(3));

    A(1:3, loadnumber + 1 : loadnumber + transformer * 2) = repmat(eye(transformer),1 ,2);
    A(4, loadnumber + transformer * 2 + 1 : end ) = ones(1, transformer + 1);

    [U, terminal] = size(A);

    p = zeros(I , terminal);
    p(:, loadnumber + 1) = loadPowerRecord(:, 1) - windPowerRecord(:, 1);
    p(:, loadnumber + 2) = loadPowerRecord(:, 2) - windPowerRecord(:, 2);
    p(:, loadnumber + 3) = loadPowerRecord(:, 3) - windPowerRecord(:, 3);

    t2u = [
        ones(1, EV(1)),...
        2 * ones(1, EV(2)),...
        3 * ones(1, EV(3)),...
        ones(1, IVA(1)),...
        2 * ones(1, IVA(2)),...
        3 * ones(1, IVA(3)),...
        1: 3, 1 : 3,...
        4 * ones(1, 4)...
    ];
    u = zeros(I, U);
    rho = 1;
    w = -1;
    % 初始化
    % EV
    for ev = 1: sum(EV)
        p(:,ev) = EVoptimize(...
            gridPriceRecord, EVdata(1, ev), EVdata(2, ev), PN, EVdata_mile(ev), ...
            zeros(I, 1), 0);
    end
    % IVA
    tmp_p = zeros(I, sum(IVA));
    parfor iva = 1 : sum(IVA)
        tmp_p(:, iva) = IVAoptimize(gridPriceRecord, TCLdata_initT(iva), ToutRecord, ...
            TCLdata_T(1, iva), TCLdata_T(2, iva), TCLdata_R(1, iva), TCLdata_C(1, iva), TCLdata_PN(1, iva), TCLdata_Pmin(1, iva), ...
            p1, p2, q1, q2, T, zeros(I, 1), 0);

    end
    p(:, sum(EV) + 1:sum(EV) + sum(IVA)) = tmp_p;

    p(:,loadnumber + 4) = - indicator(...
        p(:, loadnumber + 1) + ...
        sum(p(:, sum(EV) + 1 : sum(EV) + IVA(1)), 2) +...
        sum(p(:, 1: EV(1)), 2), 0, T_C(1));
    p(:,loadnumber + 5) = - indicator(...
        p(:, loadnumber + 2) +...
        sum(p(:, sum(EV) + IVA(1) + 1 : sum(EV) + IVA(1) + IVA(2)), 2) +...
        sum(p(:, EV(1) + 1: EV(1) + EV(2)), 2), 0, T_C(2));
    p(:,loadnumber + 6) = - indicator(...
        p(:, loadnumber + 3) + ...
        sum(p(:, sum(EV) + IVA(1) + IVA(2) + 1 : sum(EV) + sum(IVA)), 2) + ...
        sum(p(:, EV(1) + EV(2) + 1: sum(EV)), 2), 0, T_C(3));
    p(:,loadnumber + 7 : loadnumber + 9) = - p(:,loadnumber + 4 : loadnumber + 6);
    p(:, end) = - indicator(sum(p(:, loadnumber + 7 : loadnumber + 9), 2), 0, DT_C);

    pu_avg = p * A' ./ sum(transpose(A)); 
    p_avg = pu_avg * A;
    u = u + pu_avg;
    % for k = 1: MAX_ITER
    %     pold = p;   
    %     pold_avg = p_avg;
    %    
    %     %x update
    %     for ev = 1: sum(EV)
    %         p(:,ev) = EVoptimize(...
    %             gridPriceRecord, EVdata(1, ev), EVdata(2, ev), PN, EVdata_mile(ev), ...
    %             pold(:, ev) - p_avg(:, ev) - u(:,t2u(ev)), rho);
    %     end
    %     tmp_p = zeros(I, sum(IVA));
    %     parfor iva = 1 : sum(IVA)
    %         tmp_p(:,iva) = IVAoptimize(gridPriceRecord, TCLdata_initT(iva), ToutRecord, ...
    %             TCLdata_T(1, iva), TCLdata_T(2, iva), TCLdata_R(1, iva), TCLdata_C(1, iva), TCLdata_PN(1, iva), TCLdata_Pmin(1, iva), ...
    %             p1, p2, q1, q2, T, ...
    %             pold(:, iva + sum(EV)) - p_avg(:, iva + sum(EV)) - u(:,t2u(iva + sum(EV))), rho);
    %     end
    %     p(:, sum(EV) + 1 : sum(EV) + sum(IVA)) = tmp_p;
    %     for d = loadnumber + 4 : loadnumber + 6
    %         proxPoint1 = pold(:, d) - p_avg(:, d) - u(:, t2u(d));
    %         proxPoint2 = pold(:, d + 3) - p_avg(:, d + 3) - u(:, t2u(d + 3));
    %         tmp_p = lineOptimize(proxPoint1, proxPoint2, T_C(d - loadnumber - transformer));
    %         p(:, d) = tmp_p(1:I, :);
    %         p(:, d + 3) = tmp_p(I + 1: 2 * I, :);
    %     end
    %     
    %     p(:, end) = indicator(pold(:, end) - p_avg(:, end) - u(:, t2u(end)), -DT_C, 0);
    %     pu_avg = p * A' ./ sum(transpose(A)); 
    %     p_avg = pu_avg * A;
    %     
    %     u = u + pu_avg;
    % 
    %     r_norm = norm(p_avg);
    %     s_norm = norm(rho *(p - p_avg - pold + pold_avg));
    %     wold = w;
    %     w = rho * r_norm / s_norm - 1;
    %     rhoold = rho;
    %     rho = rho * exp(lambda * w + miu * (w - wold));
    %     u = rhoold / rho * u;
    %     eps_pri = sqrt(I * terminal) * ABSTOL + RELTOL * max(norm(p), norm(p_avg - p));
    %     eps_dual = sqrt(I * terminal) * ABSTOL + RELTOL * norm(rho * u);
    % 
    %     if k > 1 && r_norm < eps_pri && s_norm < eps_dual
    %         break;
    %     end
    % end
    p(abs(p) < 1e-5) = 0;
    p_avg(abs(p_avg) < 1e-5) = 0;

    closematlabpool();
    offset=0;

    %tcl温度和ev电量更新
    TCLdata_Ta = zeros(sum(IVA), I + 1);
    TCLdata_Ta(:, 1) = TCLdata_initT;
    EVdata_E = zeros(sum(EV), I + 1);
    isBid = 0;

    for i = 1 : I
        theta_a = ToutRecord(i);
        for iva = 1: sum(IVA)
             heat_rate_IVA = q1 / p1 * p(i, iva + sum(EV)) - (q1 * p2 - p1 * q2) / p1;
             TCLdata_Ta(iva, i + 1) = theta_a - heat_rate_IVA * TCLdata_R(1, iva) - (theta_a - heat_rate_IVA * TCLdata_R(1, iva) - TCLdata_Ta(iva, i)) * exp(- T / TCLdata_R(1, iva) / TCLdata_C(1, iva));
        end
        for ev = 1 : sum(EV)
            EVdata_E(ev, i + 1) = EVdata_E(ev, i) + p(i, ev) * T;
        end
    end

    DSO_cost = - p(:, end)' * gridPriceRecord * T; %配网总用电成本


    t = T : T :24;
    t2 = 0 : T_tcl : 24;
    load('../data/COLOR');
    figure;
    hold on;
    H1 = plot(t, -p(:, end),...
        'color', gold, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配变电');
    H2 = plot(t, p(:, end- 3),...
        'color', purple, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站1');
    H3 = plot(t,  p(:, end- 2),...
        'color', blue, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站2');
    H4 = plot(t,  p(:, end- 1),...
        'color', green, 'LineWidth', 1.5, 'LineStyle', '-', 'marker', 'none', 'DisplayName', '配电站3');

end
%--------------------------------------------------------------------------
function x_projection = indicator(x, lower, upper)
    x(x > upper) = upper;
    x(x < lower) = lower;
    x_projection = x;
end

function p = EVoptimize(price, ta, td, PN, E, proxPoint, rho)
    global I T
    H = rho * eye(I); f = price - rho * proxPoint;
    lb = zeros(I, 1);
    ub = zeros(I, 1);
    ub(ceil(ta / T) : end) = PN * ones( I - ceil(ta / T) + 1, 1);
    ub(1 : floor(td / T)) = PN * ones( floor(td / T), 1);
    Aeq = T * ones(1, I);
    beq = E;
    p = quadprog(H, f, [], [], Aeq, beq, lb, ub);
end

function p = lineOptimize(proxPoint1, proxPoint2, T_C)
    global I
    H = eye(I * 2);
    f = - [proxPoint1 ; proxPoint2];
    A = repmat(eye(I), 1, 2);
    b = zeros(I, 1);
    lb = [-T_C * ones(I , 1); zeros(I, 1)];
    ub = [zeros(I, 1); T_C * ones(I , 1)];
    p = quadprog(H, f, [], [], A, b, lb, ub);
    p(abs(p) < 1e-4) = 0;
end

function pOptimal = IVAoptimize(priceRecord, T_0, T_out, T_max, T_min, R, C, PN, Pmin, p1, p2, q1, q2, T, proxPoint, rho)
    e = exp( - T / R / C);
    denominator = R * (1 - e);
    SOA_0 = (T_0 - T_min) / (T_max - T_min);
    a =  - (T_max - T_min) / denominator;
    b = - e * a;
    c = (T_out - T_min) / R;
    N = length(priceRecord);

    QN = q1 / p1 * PN -(q1 * p2 - p1 * q2) / p1;
    Qmin = q1 / p1 * Pmin -(q1 * p2 - p1 * q2) / p1;
    
    % A矩阵
    % A 0 0 ... 0 0
    % B A 0 ... 0 0
    %..............
    % 0 0 0 ... B A
    
    A_main = diag(a * ones(1, N), 0) + diag(b * ones(1, N - 1), -1);
    b_resi = zeros(N, 1); b_resi(1) = b * SOA_0;
    p = @(x) p1 / q1 * (A_main * x + b_resi + c) + (q1 * p2 - p1 * q2) / q1;
    fun = @(x) priceRecord' * (p1 / q1 * (A_main * x + b_resi + c) + (q1 * p2 - p1 * q2) / q1 + (x - 0.5).^2 * (QN - Qmin)) + 0.5 * rho * (p1 / q1 * (A_main * x + b_resi + c) + (q1 * p2 - p1 * q2) / q1 - proxPoint)' * ( p1 / q1 * (A_main * x + b_resi + c) + (q1 * p2 - p1 * q2) / q1 - proxPoint); %beta 1-10 10-热 1-冷
     
    %heat rate上下限约束
    b22 =  QN - c; b22(1) = b22(1) - b * SOA_0;
    b21 = Qmin - c; b21(1) = b21(1) - b * SOA_0;
    A2 = [A_main; -A_main];
    b2 = [b21; -b22];
    A = A2;
    B = b2;
    % 10%边界
    % [SOA, ~, exitflag] = linprog(- f1 + f2, A, B, [], [], 0.1 * ones(N, 1), 0.9 * ones(N, 1));
    %多目标优化
    SOA = fmincon(fun, SOA_0 * ones(N, 1), A, B, [], [], zeros(N, 1), ones(N, 1));
    %%% TODO 
    Q = A_main * SOA + c + b_resi;
    pOptimal = p1 / q1 * Q + (q1 * p2 - p1 * q2) / q1;

end