function [ P_max, P_min, P_set, SOA_1 ] = FFABidPara(priceRecord, T_0, T_out, T_max, T_min, R, C, PN, T_tcl, ratioFFA)
%底层TCL根据动态方程进行优化, priceArray电价序列, T_0 t-1时刻室内温度，T_out室外温度序列
%T_min最低室温， T_max最高室温
%Pset最优当前电价
eta = 2.7;
e = exp( - T_tcl / R / C);
denominator = eta * R * (1 - e);
SOA_0 = (T_0 - T_min) / (T_max - T_min);
a =  - (T_max - T_min) / denominator;
b = - e * a;
[row, ~] = size(T_out);
if row == 1
    T_out = T_out';
end
c = (T_out - T_min) / eta / R;
N = length(priceRecord);
P_min = a + b * SOA_0 + c(1);
P_max = b * SOA_0 + c(1);
P_min = min(PN, P_min);
P_min = max(P_min, 0);
P_max = min(PN, P_max);
P_max = max(P_max, 0);
A2_main = diag(a * ones(1, N), 0) + diag(b * ones(1, N - 1), -1);
H = - 2 * diag(priceRecord) * a * 0.7;
f = (priceRecord' * A2_main + priceRecord' * a * 0.7)';

b22 =  PN - c; b22(1) = b22(1) - b * SOA_0;
b21 = - c; b21(1) = b21(1) - b * SOA_0;
A2 = [A2_main; -A2_main];
b2 = [b22; -b21];
A = A2;
B = b2;
% 10%边界
% [SOA, ~, exitflag] = linprog(- f1 + f2, A, B, [], [], 0.1 * ones(N, 1), 0.9 * ones(N, 1));
%多目标优化
SOA = quadprog(H, f, A, B, [], [], 0.1 * ones(N, 1), 0.9 * ones(N, 1));

if exist('SOA', 'var') == 1
    SOA_1 = SOA(1);
    P_set = a * SOA_1 + b * SOA_0 + c(1);
else
    X = 1;
end
end