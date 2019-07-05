% 多层admm和单次TC比较
clc; clear;
addPath;
constantInit;
%---------------------------
isMultiDay = 0;
isHierarchical = 1;
isADMM = 0;

RATIO = 100;
EV = [5, 3, 3] * RATIO;
FFA = [8, 8, 8] * RATIO;
IVA = [2, 2, 2] * RATIO;
TCL = FFA + IVA;
LOAD = [22, 15, 10, 10] * RATIO;
WIND = [10, 10, 3, 10] * RATIO;
CAPACITY = [35, 35, 35, 100] * RATIO;

[EVdata,EVdata_mile, EVdata_capacity, PN, ...
TCLdata_T, TCLdata_C, TCLdata_R, FFAdata_PN, IVAdata_PN, TCLdata_Pmin, TCLdata_initT ] ...
    = TCLEVinit (19.82, 1.92, 8.56 + 24, 2, sum(EV), sum(IVA), sum(FFA));

maxWind = max(max(Wind));
windPowerRecord =[
    Wind(1, 1 + 48: 96 + 48) / maxWind * WIND(1);
    Wind(1, 96 + 1 + 48 : 96 * 2 + 48) / maxWind * WIND(2);
    Wind(1, 96 * 2 + 1 + 48 : 96 * 3 + 48) / maxWind * WIND(3);
    Wind(1, 96 * 3 + 1 + 48 : 96 * 4 + 48) / maxWind * WIND(4)
]';
DRmode = zeros(96, 1);
DRmode(5: 16) = 100 * RATIO * ones(12, 1);
maxLoad = max(max(Load));
loadPowerRecord = [
    Load(1, 1 + 48: 96 + 48) / maxLoad * LOAD(1);
    Load(1, 96 + 1 + 48: 96 * 2 + 48) / maxLoad * LOAD(2);
    Load(1, 96 * 2 + 1 + 48 : 96 * 3 + 48) / maxLoad * LOAD(3);
    Load(1, 96 * 3 + 1 + 48 : 96 * 4 + 48) / maxLoad * LOAD(4)
]';
clear Wind Load Tout i RTP minP maxP gridPriceRecord4

startmatlabpool();
tic;
%----------hierarchical-----------------------------
if isHierarchical == 1
    trans1 = distributionTrans(...
              EV(1), FFA(1), IVA(1), CAPACITY(1), windPowerRecord(:, 1), loadPowerRecord(:, 1), gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
              EVdata(:, 1 : EV(1)), EVdata_mile(1 : EV(1)), EVdata_capacity(1 : EV(1)), PN,...
              TCLdata_T(:, 1 : TCL(1)), TCLdata_R(1 : TCL(1)), TCLdata_C(1 : TCL(1)), FFAdata_PN(1 : FFA(1)), IVAdata_PN(1 : IVA(1)), TCLdata_Pmin(1 : IVA(1)), TCLdata_initT(1 : TCL(1)), ...
              p1, q1, p2, q2,...
              d_theta_h1, d_theta_h2, theta_o, yrs, eta...
            );
    trans2 = distributionTrans(...
          EV(2), FFA(2), IVA(2), CAPACITY(2), windPowerRecord(:, 2), loadPowerRecord(:, 2), gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
          EVdata(:, EV(1) + [1 : EV(2)]), EVdata_mile(EV(1) + [1 : EV(2)]), EVdata_capacity(EV(1) + [1 : EV(2)]), PN,...
          TCLdata_T(:, TCL(1) + [1 : TCL(2)]), TCLdata_R(TCL(1) + [1 : TCL(2)]), TCLdata_C(TCL(1) + [1 : TCL(2)]), FFAdata_PN(FFA(1) + [1: FFA(2)]), IVAdata_PN(IVA(1) + [1 : IVA(2)]), TCLdata_Pmin(IVA(1) + [1 : IVA(2)]), TCLdata_initT(TCL(1) + [1 : TCL(2)]), ...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs, eta...
        );
    trans3 = distributionTrans(...
          EV(3), FFA(3), IVA(3), CAPACITY(3), windPowerRecord(:, 3), loadPowerRecord(:, 3), gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
          EVdata(:, end - EV(3) + 1 : end), EVdata_mile(end - EV(3) + 1 : end), EVdata_capacity(end - EV(3) + 1 : end), PN,...
          TCLdata_T(:, end - TCL(3) + 1 : end), TCLdata_R(end - TCL(3) + 1 : end), TCLdata_C(end - TCL(3) + 1 : end), FFAdata_PN(end - FFA(3) + 1 : end), IVAdata_PN(end - IVA(3) + 1 : end), TCLdata_Pmin(end - IVA(3) + 1 : end), TCLdata_initT(end - TCL(3) + 1 : end), ...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs, eta...
        );
    ccp = auctioneer(d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY(4), windPowerRecord(:, 4), loadPowerRecord(:, 4), gridPriceRecord24, ToutRecord, mkt, eta, DRmode);

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
    save '../../data/0423/hiearchical'
end
toc;
%----------ADMM--------------------------------------
if isADMM == 1
    lambda = 1e-3;
    miu = 1e-1;
    beta = 0.5;

    MAX_ITER = 100;
    ABSTOL   = 1e-4;
    RELTOL   = 1e-2;
    transformerNo = 3;
    T_C = CAPACITY(1:transformerNo);
    DT_C = CAPACITY(end);
    loadnumber = sum(EV) + sum(IVA);
    TERMINAL = loadnumber + transformerNo * 3 + 1;
    % EV1 EV2 EV3 IVA1 IVA2 IVA3 N11 N21 N31 N12 N22 N32 N4
    A = zeros(transformerNo + 1, TERMINAL);

    A(1, 1 : EV(1)) = ones(1, EV(1));
    A(2, EV(1) + 1: EV(1) + EV(2)) = ones(1, EV(2));
    A(3, EV(1) + EV(2) + 1: sum(EV)) = ones(1, EV(3));

    A(1, sum(EV) + 1 : sum(EV) + IVA(1)) = ones(1, IVA(1));
    A(2, sum(EV) + 1 + IVA(1) : sum(EV) + IVA(1) + IVA(2)) = ones(1, IVA(2));
    A(3, sum(EV) + 1 + IVA(1) + IVA(2): sum(EV) + sum(IVA)) = ones(1, IVA(3));

    A(1:3, loadnumber + 1 : loadnumber + transformerNo * 2) = repmat(eye(transformerNo),1 ,2);
    A(4, loadnumber + transformerNo * 2 + 1 : end ) = ones(1, transformerNo + 1);

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
    p(:,loadnumber + 7 : loadnumber + 9) = - p(:,loadnumber + 4 : loadnumber + 6) / eta;
    p(:, end) = - indicator(sum(p(:, loadnumber + 7 : loadnumber + 9), 2), 0, DT_C);

    dlRecord = zeros(I, 4);
    pu_avg = p * A' ./ sum(transpose(A)); 
    p_avg = pu_avg * A;
    u = u + pu_avg;
    for k = 1: MAX_ITER
        pold = p;   
        pold_avg = p_avg;
       
        %x update
        for ev = 1: sum(EV)
            p(:,ev) = EVoptimize(...
                gridPriceRecord, EVdata(1, ev), EVdata(2, ev), PN, EVdata_mile(ev), ...
                pold(:, ev) - p_avg(:, ev) - u(:,t2u(ev)), rho);
        end
        tmp_p = zeros(I, sum(IVA));
        TCLdata_T1 = TCLdata_T(1,:);
        TCLdata_T2 = TCLdata_T(2,:);
        parfor iva = 1 : sum(IVA)
            tmp_p(:,iva) = IVAoptimize(gridPriceRecord, TCLdata_initT(iva), ToutRecord, ...
                TCLdata_T1(iva), TCLdata_T2(iva), TCLdata_R(1, iva), TCLdata_C(1, iva), TCLdata_PN(1, iva), TCLdata_Pmin(1, iva), ...
                p1, p2, q1, q2, T, ...
                pold(:, iva + sum(EV)) - p_avg(:, iva + sum(EV)) - u(:,t2u(iva + sum(EV))), rho);
        end
        p(:, sum(EV) + 1 : sum(EV) + sum(IVA)) = tmp_p;
        for d = loadnumber + 4 : loadnumber + 6
            proxPoint1 = pold(:, d) - p_avg(:, d) - u(:, t2u(d));
            proxPoint2 = pold(:, d + 3) - p_avg(:, d + 3) - u(:, t2u(d + 3));
            [tmp_p, dl] = lineOptimize(gridPriceRecord, ToutRecord, eta, yrs, proxPoint1, proxPoint2, T_C(d - loadnumber - transformerNo), rho, 0);
            p(:, d) = tmp_p(1:I);
            p(:, d + 3) = tmp_p(I + 1: 2 * I);
            if k == MAX_ITER
                dlRecord(:, d - loadnumber -3) = dl;
            end
        end
        proxPoint1 = pold(:, end) - p_avg(:, end) - u(:,t2u(end));
        [tmp_p, dl] = lineOptimize(gridPriceRecord , ToutRecord, eta, yrs, proxPoint1, [], DT_C, rho, 1);
        if k == MAX_ITER
            dlRecord(:, 4) = dl;
        end
        p(:, end) = tmp_p(1: I);
        pu_avg = p * A' ./ sum(transpose(A)); 
        p_avg = pu_avg * A;
        
        u = u + pu_avg;
    
        r_norm = norm(p_avg);
        s_norm = norm(rho *(p - p_avg - pold + pold_avg));
        wold = w;
        w = rho * r_norm / s_norm - 1;
        rhoold = rho;
        rho = rho * exp(lambda * w + miu * (w - wold));
        u = rhoold / rho * u;
        eps_pri = sqrt(I * terminal) * ABSTOL + RELTOL * max(norm(p), norm(p_avg - p));
        eps_dual = sqrt(I * terminal) * ABSTOL + RELTOL * norm(rho * u);
        priRecord(k) = s_norm;
        dualRecord(k) = r_norm;
        if k > 1 && r_norm < eps_pri && s_norm < eps_dual
            break;
        end
    end
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
    transAdmm1 = transformer(d_theta_h1, d_theta_h2, theta_o, yrs, T_C(1), gridPriceRecord, ToutRecord, mkt, eta);
    transAdmm1.setPower(p(:, loadnumber + 7)');
    transAdmm2 = transformer(d_theta_h1, d_theta_h2, theta_o, yrs, T_C(2), gridPriceRecord, ToutRecord, mkt, eta);
    transAdmm2.setPower(p(:, loadnumber + 8)');
    transAdmm3 = transformer(d_theta_h1, d_theta_h2, theta_o, yrs, T_C(3), gridPriceRecord, ToutRecord, mkt, eta);
    transAdmm3.setPower(p(:, loadnumber + 9)');
    ccpAdmm = transformer(d_theta_h1, d_theta_h2, theta_o, yrs, DT_C, gridPriceRecord, ToutRecord, mkt, eta);
    ccpAdmm.setPower(- p(:, end)' / eta);

    for t_index = 1 : I
        transAdmm1.transUpdate(t_index);
        transAdmm2.transUpdate(t_index);
        transAdmm3.transUpdate(t_index);
        ccpAdmm.transUpdate(t_index);
    end
end

%--------------------------------------------------------------------------
function x_projection = indicator(x, lower, upper)
    x(x > upper) = upper;
    x(x < lower) = lower;
    x_projection = x;
end
