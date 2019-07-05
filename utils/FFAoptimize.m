function [ pOptimal, fval] = FFAoptimize(priceRecord, T_0, T_out, T_max, T_min, R, C, PN, T_tcl, proxPoint, rho )
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
b_resi = zeros(N, 1); b_resi(1) = b * SOA_0;
p = @(x) A_main * x + b_resi + c;
fun = @(x) priceRecord' * (p(x) + (x - 0.5).^2 * (- a * 0.7)) + 0.5 * rho * (p(x) - proxPoint)' * (p(x) - proxPoint); %beta 1-10 10-热 1-冷

% heat rate上下限约束
b22 =  PN - c - b_resi;
b21 = - c - b_resi;
A2 = [A2_main; -A2_main];
b2 = [b22; -b21];
A = A2;
B = b2;
[SOA, fval] = fmincon(fun, SOA_0 * ones(N, 1), A, B, [], [], 0.1 * ones(N, 1), 0.9 * ones(N, 1));
pOptimal = A2_main * SOA + c + b_resi;
end

