function [pOptimal, fval] = IVAoptimize(priceRecord, T_0, T_out, T_max, T_min, R, C, PN, Pmin, p1, p2, q1, q2, T, proxPoint, rho)
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
    fun = @(x) priceRecord' * (p(x) + (x - 0.5).^2 * (QN - Qmin)) + 0.5 * rho * (p(x) - proxPoint)' * (p(x) - proxPoint); %beta 1-10 10-热 1-冷
     
    % heat rate上下限约束
    b22 =  QN - c; b22(1) = b22(1) - b * SOA_0;
    b21 = Qmin - c; b21(1) = b21(1) - b * SOA_0;
    A2 = [A_main; -A_main];
    b2 = [b22; -b21];
    A = A2;
    B = b2;
    [SOA, fval] = fmincon(fun, SOA_0 * ones(N, 1), A, B, [], [], zeros(N, 1), ones(N, 1));
    % TODO 
    Q = A_main * SOA + c + b_resi;
    pOptimal = p1 / q1 * Q + (q1 * p2 - p1 * q2) / q1;

end