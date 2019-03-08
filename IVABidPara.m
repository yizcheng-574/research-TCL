function [ P_max, P_min, P_set, SOA_1 ] = IVABidPara(priceRecord, T_0, T_out, T_max, T_min, R, C, PN, Pmin, psi, p1, p2, q1, q2, T)
%底层IVA根据动态方程进行优化, priceArray电价序列, T_0 t-1时刻室内温度，T_out室外温度序列
%T_min最低室温， T_max最高室温
%Pset最优当前电价
e = exp( - T / R / C);
denominator = R * (1 - e);
SOA_0 = (T_0 - T_min) / (T_max - T_min);
a =  - (T_max - T_min) / denominator;
b = - e * a;
c = (T_out - T_min) / R + psi;
N = length(priceRecord);

QN = q1 / p1 * PN -(q1 * p2 - p1 * q2) / p1;
Qmin = q1 / p1 * Pmin -(q1 * p2 - p1 * q2) / p1;

Q_min = a + b * SOA_0 + c(1);
Q_max = b * SOA_0 + c(1);
Q_min = min(QN, Q_min);
Q_min = max(Q_min, Qmin);
Q_max = min(QN, Q_max);
Q_max =max(Q_max, Qmin);
P_max = p1 / q1 * Q_max + (q1 * p2 - p1 * q2) / q1;
P_min = p1 / q1 * Q_min + (q1 * p2 - p1 * q2) / q1;

% A B 0 ... 0 0
% 0 A B ... 0 0
%..............
% 0 0 0 ... A B
% 0 0 0 ... 0 A
% fun = @(x) - x' * (diag(a * ones(1, N), 0) + diag(b * ones(1, N - 1), 1)) * priceRecord +  2.5 / beta * sum((x).^2); %beta 1-10 10-热 1-冷
fun = @(x) x' * p1 / q1 * (diag(a * ones(1, N), 0) + diag(b * ones(1, N - 1), 1)) * priceRecord + priceRecord' * (x - 0.5).^2 * (P_max - P_min); %beta 1-10 10-热 1-冷
% A2_main矩阵
% A 0 0 ... 0 0
% B A 0 ... 0 0
%..............
% 0 0 0 ... B A
%heat rate上下限约束
A2_main = diag(a * ones(1, N), 0) + diag(b * ones(1, N - 1), -1);
b22 =  QN - c; b22(1) = b22(1) - b * SOA_0;
b21 = Qmin - c; b21(1) = b21(1) - b * SOA_0;
A2 = [A2_main; -A2_main];
b2 = [b21; -b22];
A = A2;
B = b2;
% 10%边界
% [SOA, ~, exitflag] = linprog(- f1 + f2, A, B, [], [], 0.1 * ones(N, 1), 0.9 * ones(N, 1));
%多目标优化
[SOA, ~, exitflag] = fmincon(fun, SOA_0 * ones(N, 1), A, B, [], [], zeros(N, 1), ones(N, 1));

SOA_1 = SOA(1);
if exist('SOA', 'var') == 1
    Q_set = a * SOA_1 + b * SOA_0 + c(1);
    P_set = p1 / q1 * Q_set + (q1 * p2 - p1 * q2) / q1;
else
    X = 1;
end
end