global step
% 
R = 8;
x = 0.8;
y = 1.6;
d_theta_or = 45; %K
d_theta_hr = 35;
eta_o = 180; %min
eta_w = 4;
k11 = 1;
k21 = 1;
k22 = 2;
if isBid == 1
    K = [0: 0.005 : 0.7 0.71 : 0.01 :1.5]; %load factor
else
    d_theta_h1 = d_theta_h1_record(mod_t_1) ;
    d_theta_h2 = d_theta_h2_record(mod_t_1) ;
    theta_o = theta_o_record(mod_t_1);
    K =  tielineRecord(mod_t_1) / P_rated;
end
Tmin = T * 60;
KR = (1 + K .^ 2 * R) ./ (1 + R);
d_theta_oi = theta_o - theta_a;
theta_o = theta_a + d_theta_oi + (d_theta_or * (KR .^ x) -d_theta_oi) * (1 - exp(- Tmin / (k11 * eta_o)));
d_theta_h1 = d_theta_h1 + (k21 * (K .^ y) * d_theta_hr - d_theta_h1) * (1 - exp(- Tmin / (k22 * eta_w)));
d_theta_h2 = d_theta_h2 + ((k21 - 1) * (K .^ y) * d_theta_hr - d_theta_h2) * (1 - exp(- Tmin / (eta_o / k22)));
d_theta_h = d_theta_h1 - d_theta_h2;
theta_h = theta_o + d_theta_h;
% DL = exp((15000 / (110 + 273) - 15000 ./ (theta_h + 273))) * Tmin; % 110 for thermally updated paper
DL = 2 .^ ((theta_h -90) / 6) * Tmin;%98 for non-thermally updated paper,
if isBid == 1
    expectancy = 20 * 365 * 24 * 60;
    P_rated = tielineBuy;%kW
    install_cost = P_rated * 150; %yuan
    dC_dL = install_cost / expectancy;
%     dL_dtheta_h = DL * 15000 ./ ((theta_h + 273) .^ 2);
    dL_dtheta_h = DL * log(2) / 6;
    dtheta_h_dK =  (1 - exp(- Tmin / (k22 * eta_w))) * d_theta_hr * k21 * y .* K .^(y - 1) + ... %d_theta_h1
        (1 - exp(- Tmin / (eta_o / k22))) * d_theta_hr * (k21 - 1 ) * y .* K .^ (y - 1) + ... %d_theta_h2
       (1 - exp(- Tmin / (eta_o * k11))) * d_theta_or * x .* KR .^ (x - 1) * 2 .* K * R / (1 + R); %theta_o
    dK_dP = 1 / P_rated;
    dC_dP = 1 / T * dC_dL .* dL_dtheta_h .* dtheta_h_dK .* dK_dP;
    
    maxp = max(dC_dP);
    tielineCurve = zeros(1, step + 1);
    k_index = 1;
    for q = 1: step + 1
        price_tmp = pCurve(q) - gridPrice;
        if price_tmp < 0
            tielineCurve(q) = -tielineSold;
        elseif price_tmp == 0
            tielineCurve(q) = tielineBuy;
        else
            for tmp_i = k_index : length(K) - 1
                if dC_dP(tmp_i) <= price_tmp && dC_dP(tmp_i + 1) >= price_tmp
                    break; 
                end
            end
            if tmp_i == length(K)
                tielineCurve(q) = K(end) * P_rated;
            else
                dP = K(tmp_i + 1) - K(tmp_i);
                dlambda = dC_dP(tmp_i + 1) - dC_dP(tmp_i);
                if dlambda == 0
                    tielineCurve(q) = (K(tmp_i + 1) + K(tmp_i))/2 * P_rated;
                else
                    tielineCurve(q) = P_rated * (K(tmp_i) + (price_tmp - dC_dP(tmp_i)) * dP / dlambda);
                end
            end
        end
    end
    tielineCurve = -tielineCurve;
else
    theta_h_record(mod_t)= theta_h;
    d_theta_h1_record(mod_t)= d_theta_h1;
    d_theta_h2_record(mod_t)= d_theta_h2;
    theta_o_record(mod_t) = theta_o;
    DL_record(mod_t) = DL;
end