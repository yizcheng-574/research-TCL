function [p, fval, dlrecord] = lineOptimizeAccordingToPrice(gridPriceRecord, theta_a, eta, yrs,...
    lambda, T_C, isPrecision)

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
   
     k0 = 1.05;
    if isPrecision == 1
         % 精确形式
        kX = @(p) ((1 + R * (p(1: I)/T_C).^2)/(1 + R)).^x;     
        kY = @(p) (p(1: I)/T_C).^y;
        theta_h = @(p)A_h * (theta_a + d_theta_or * kX(p)) + residual_h * theta_o0 ;
        dtheta_h1 = @(p)A_h1 * (k21 * d_theta_hr * kY(p)) + residual_h1 * d_theta_h10;
        dtheta_h2 = @(p)A_h2 * ((k21 - 1) * d_theta_hr * kY(p)) + residual_h2 * d_theta_h20;
    elseif isPrecision == 0 %平方展开
         % 近似形式
        fk = @(k2) ((1 + k2* R) / (1 + R)) ^x; %fx
        f1k = @(k2) x * R / (1 + R) * ((1 + k2 * R) / (1 + R)) ^ (x -1); %f'x
        fy = @(k2) k2 ^ (y /2); %fy
        f1y = @(k2) y /2  * k2 ^(y / 2 -1); %f1y
        kX_taylor = @(p) fk(k0^2) + f1k(k0^2) * ((p(1: I) / T_C) .^2 - k0 ^2); %一阶泰勒
        kY_taylor = @(p) fy(k0^2) + f1y(k0^2) * ((p(1: I) / T_C) .^2 - k0 ^2);
        theta_h = @(p)A_h * (theta_a + d_theta_or * kX_taylor(p)) + residual_h * theta_o0 ;
        dtheta_h1 = @(p)A_h1 * (k21 * d_theta_hr * kY_taylor(p)) + residual_h1 * d_theta_h10;
        dtheta_h2 = @(p)A_h2 * ((k21 - 1) * d_theta_hr * kY_taylor(p)) + residual_h2 * d_theta_h20;
        % 判断是否正定
%         for i = 1 : 96
%         lambdaaaa = d_theta_or * f1k(k0) * (1 - (1 - T * 60 / (k11 * eta_o)) ^(96 -i + 1)) +...
%             k21 * d_theta_hr * f1y(k0) * (1 - (1 - T * 60 / (eta_w * k22)) ^ (96 - i + 1)) -...
%             (k21 - 1) * d_theta_hr * f1y(k0) * (1 - (1 - T * 60 / (eta_o / k22)) ^ (96 - i + 1));
%         lambda_Q(i) = lambdaaaa;
%         end
    elseif isPrecision == 2
        fk = @(k) ((1 + k.^2* R) / (1 + R)) ^x; %fx
        f1k = @(k) 2 * x * R / (1 + R) * ((1 + k.^2 * R) / (1 + R)) ^ (x -1); %f'x
        fy = @(k) k ^ y; %fy
        f1y = @(k) y /2  * k ^(y -2); %f1y
        kX_taylor = @(p) fk(k0) + f1k(k0) * (p(1: I) / T_C - k0); %一阶泰勒
        kY_taylor = @(p) fy(k0) + f1y(k0) * (p(1: I) / T_C - k0);
        theta_h = @(p)A_h * (theta_a + d_theta_or * kX_taylor(p)) + residual_h * theta_o0 ;
        dtheta_h1 = @(p)A_h1 * (k21 * d_theta_hr * kY_taylor(p)) + residual_h1 * d_theta_h10;
        dtheta_h2 = @(p)A_h2 * ((k21 - 1) * d_theta_hr * kY_taylor(p)) + residual_h2 * d_theta_h20;
    end
    ub = 1.4 * T_C * ones(I , 1);
    lb = zeros(I, 1);
    f = @(p) gridPriceRecord' * p * (1/ eta - 1) - lambda' * p + ...
    ones(1, I) * dC_dL * T * 60 * 2 .^ ((theta_h(p /eta) + dtheta_h1(p/eta) - dtheta_h2(p/eta) -98)/ 6);
    [p, fval] = fmincon(f, T_C * ones(I, 1), [], [], [], [], lb, ub);
    dlrecord = T * 60 * 2 .^ ((theta_h(p /eta) + dtheta_h1(p/eta) - dtheta_h2(p/eta) -98)/ 6);
end
