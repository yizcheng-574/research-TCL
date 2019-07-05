function [p, dlRecord] = lineOptimize(gridPriceRecord, theta_a, eta, yrs,...
    proxPoint1, proxPoint2, T_C, rho, isEnd)

    function [A, residual] = getAgingMatrix(a, T, lengthT)
        % return iteration matrix for a y' + y = b;
        A = eye(lengthT);
        T = T * 60;
        for i = 1 : lengthT - 1
            A = A + diag((1 - T / a)^ i * ones(lengthT - i, 1), -i);
        end
        A = A * T / a;
        residual = zeros(lengthT, 1);
        for i = 1 : lengthT
            residual(i) = (1 - T/a)^i;
        end
    end

    global I T
    d_theta_h10 = 53.2; d_theta_h20= 26.6; theta_o0 = 63.9;%C
    R = 8; x = 0.8; y = 1.6; d_theta_or = 45; d_theta_hr = 35; eta_o = 180; eta_w = 8; k11 = 1; k21 = 1; k22 = 2;
    expectancy = yrs * 365 * 24 * 60;
    install_cost = T_C * 100; %yuan
    dC_dL = install_cost / expectancy;
    [A_h, residual_h] = getAgingMatrix(k11 * eta_o, T, I);
    [A_h1, residual_h1] = getAgingMatrix(k22 * eta_w, T, I);
    [A_h2, residual_h2] = getAgingMatrix(eta_o / k22, T, I);
    theta_h = @(p)A_h * (theta_a + d_theta_or * ((1 + R * (p(1: I)/T_C).^2)/(1 + R)).^x) + residual_h * theta_o0 ;
    dtheta_h1 = @(p)A_h1 * (k21 * d_theta_hr * (p(1: I)/T_C).^2.^(y/2)) + residual_h1 * d_theta_h10;
    dtheta_h2 = @(p)A_h2 * ((k21 - 1) * d_theta_hr * (p(1: I)/T_C).^2 .^(y/2)) + residual_h2 * d_theta_h20;
    
    if isEnd == 0
        lb = [- 1.4 * T_C * ones(I , 1); zeros(I, 1)];
        ub = [zeros(I, 1);  1.4 * T_C * ones(I , 1)];
        A = [eye(I), eta * eye(I)]; % ±äÑ¹Æ÷Ð§ÂÊ
        b = zeros(I, 1);
        f = @(p)-gridPriceRecord' * p(1 : I) * (1/ eta - 1) + rho / 2 * (p - [proxPoint1 ; proxPoint2])' * (p - [proxPoint1 ; proxPoint2]) + ...
        ones(1, I) * dC_dL * T * 60 * 2 .^ ((theta_h(p/ eta ) + dtheta_h1(p/ eta) - dtheta_h2(p/ eta) -98)/ 6);
        p = fmincon(f, T_C * [- ones(I, 1); eta * ones(I, 1)], [], [], A, b, lb, ub);
        dlRecord = T * 60 * 2 .^ ((theta_h(p/ eta) + dtheta_h1(p/ eta) - dtheta_h2(p/ eta) -98)/ 6);

    else
        lb = - 1.4 * T_C * ones(I , 1);
        ub = zeros(I, 1);
        f = @(p)-gridPriceRecord' * p * (1/ eta - 1) + rho / 2 * (p - proxPoint1 )' * (p - proxPoint1) + ...
        ones(1, I) * dC_dL * T * 60 * 2 .^ ((theta_h(p /eta) + dtheta_h1(p/eta) - dtheta_h2(p/eta) -98)/ 6);
        p = fmincon(f, - T_C * ones(I, 1), [], [], [], [], lb, ub);
        dlRecord = T * 60 * 2 .^ ((theta_h(p /eta) + dtheta_h1(p /eta) - dtheta_h2(p /eta) -98)/ 6);
    end
end
