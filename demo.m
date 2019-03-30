clear; clc;
global I T
RATIO = 1;
EV = 6 * RATIO;%EV总数，额定功率为3.7kW
T = 1;%控制周期15min
I = 24 / T;

gridPriceRecord = [51 47 45 70 81 60 72 91 82 105 110 82 85 120 100 90 80 105 95 110 90 50 70 55] / 1000 * 8;

TA_avg = 7.82;
TA_sigma = 1.92;
TD_avg = 20.56;
TD_sigma = 2;
EVdata = zeros(2, EV);
EVdata(1,:) = normrnd(TA_avg, TA_sigma, 1, EV);
EVdata(2,:) = normrnd(TD_avg, TD_sigma, 1, EV);
EVdata(EVdata < 0) = 0;
EVdata(EVdata > 24) = 24;
for ev = 1 : EV
    while EVdata(2,ev) < EVdata(1,ev)
        EVdata(2,ev) = normrnd(TD_avg, TD_sigma);
    end
end
EVdata_mile = unifrnd(10,20,1,EV);

PN=3.7;
clear TD_avg TA_avg TD_sigma TA_sigma bus1 busi allBus ev tmp 

lambda = 1e-3;
miu = 1e-1;
beta = 0.5;

MAX_ITER = 100;
ABSTOL   = 1e-4;
RELTOL   = 1e-2;

T_C = PN * 1.5;
DT_C = PN * 4;

A = [
    1 1 0 0 0 0 1 0 0 0 0 0 0;
    0 0 1 1 0 0 0 1 0 0 0 0 0;
    0 0 0 0 1 1 0 0 1 0 0 0 0;
    0 0 0 0 0 0 0 0 0 1 1 1 1;
];
[U, terminal] = size(A);

p = zeros(I , terminal);
p_avg = p;
t2u = [1 1 2 2 3 3 1 2 3 4 4 4 4];
u = zeros(I, U);
rho = 1;
w = -1;
for ev = 1: EV
    p(:,ev) = EVoptimize(...
        gridPriceRecord, EVdata(1, ev), EVdata(2, ev), PN, EVdata_mile(ev), ...
        zeros(I, 1), 0);
end
p(:,7) = - indicator(sum(p(:, 1:2), 2), 0, T_C);
p(:,8) = - indicator(sum(p(:, 3:4), 2), 0, T_C);
p(:,9) = - indicator(sum(p(:, 5:6), 2), 0, T_C); 
p(:,10:12) = - p(:, 7:9);
p(:, 13) = - indicator(sum(p(:, 10:12), 2), 0, DT_C);

pu_avg = p * A' ./ sum(transpose(A)); 
p_avg = pu_avg * A;
u = u + pu_avg;
for k = 1: MAX_ITER
    pold = p;   
    pold_avg = p_avg;
    
    %x update
    for ev = 1: EV
        p(:,ev) = EVoptimize(...
            gridPriceRecord, EVdata(1, ev), EVdata(2, ev), PN, EVdata_mile(ev), ...
            pold(:, ev) - p_avg(:, ev) - u(:,t2u(ev)), rho...
        );
    end
    for d = 7 : 9
        proxPoint1 = pold(:, d) - p_avg(:, d) - u(:, t2u(d));
        proxPoint2 = pold(:, d + 3) - p_avg(:, d + 3) - u(:, t2u(d + 3));
        tmp_p = lineOptimize(proxPoint1,proxPoint2, T_C);
        p(:, d) = tmp_p(1:I, :);
        p(:, d + 3) = tmp_p(I + 1: 2 * I, :);
    end
    
    p(:, 13) = indicator(pold(:, 13) - p_avg(:, 13) - u(:, t2u(13)), -DT_C, 0);
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
    eps_pri = sqrt(I * 13) * ABSTOL + RELTOL * max(norm(p), norm(p_avg - p));
    eps_dual = sqrt(I * 13) *ABSTOL + RELTOL * norm(rho * u);

    if k > 1 && r_norm < eps_pri && s_norm < eps_dual
        break;
    end
end
p(abs(p) < 1e-5) = 0;
p_avg(abs(p_avg) < 1e-5) = 0;

%集中式
%电量约束
A1 = zeros(EV, I * EV);
for ev = 1 : EV
    A1(ev, (ev - 1) * I + 1 : ev * I) = T * ones(1, I);
end
b1 = EVdata_mile';

%联络线约束
A2 = zeros(4 * I, I * EV);
A2(1 : I, 1 : 2 * I) = repmat(eye(I), 1, 2);
A2(I + 1 : 2 * I, 2 * I + 1 : 4 * I) = repmat(eye(I), 1, 2);
A2(2 * I + 1 : 3 * I, 4 * I + 1 : 6 * I) = repmat(eye(I), 1, 2);
A2(3 * I + 1 : 4 * I, :) = repmat(eye(I), 1, EV);
b2 = [T_C * ones(3 * I, 1); DT_C * ones(I, 1)];
lb = zeros(I * EV, 1);
ub = zeros(I * EV, 1);
for ev = 1 : EV
    ta = EVdata(1, ev);
    td = EVdata(2, ev);
    ub((ev - 1) * I + ceil(ta / T) : (ev - 1) * I + floor(td / T)) = PN * ones( - ceil(ta / T) + floor(td / T) + 1, 1);
end
%上下线约束
x = linprog(repmat(gridPriceRecord', EV, 1), A2, b2, A1, b1, lb, ub);

p_central = [reshape(x, I, 6), reshape(A2 * x, 24, 4)];

repmat(gridPriceRecord', EV, 1)' * x
repmat(gridPriceRecord', EV, 1)' * reshape(p(:, 1:6), 144,1)


function x_projection = indicator(x, lower, upper)
    x(x > upper) = upper;
    x(x < lower) = lower;
    x_projection = x;
end

function p = EVoptimize(price, ta, td, PN, E, proxPoint, rho)
    global I T
    H = rho * eye(I); f = price' - rho * proxPoint;
    lb = zeros(I, 1);
    ub = zeros(I, 1);
    ub(ceil(ta / T) : floor(td / T)) = PN * ones( - ceil(ta / T) + floor(td / T) + 1, 1);
    Aeq = T * ones(1, I);
    beq = E;
    p = quadprog(H, f, [], [], Aeq, beq, lb, ub);
end

% function p = tielineOptimize(price, p_targ, lower, upper, proxPoint, rho)
%     global I
%     p = p_targ;
%     for i = 1: I
%         if p_targ(i) < lower || p_targ(i) > upper
%             p(i) = quadprog(rho, - rho * proxPoint(i), [], [], [],[], lower, upper);
%         end
%     end
% end

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