% 求解常微分方程
R = 8;
x = 0.8;
y = 1.6;
d_theta_or = 45; %K
d_theta_hr = 35;
eta_o = 180; %min
eta_w = 8;
k11 = 1;
k21 = 1;
k22 = 2;
if isBid == 1
    K = [0.5:0.1:0.9, 0.91 : 0.01 :1.2]; %load factor 1.2倍为最大限制功率
else
    if isMultiDay == 0
        tmp_t_index = mod_t_1;
    else
        tmp_t_index = t_index;
    end
    d_theta_h1 = d_theta_h1_record(tmp_t_index) ;
    d_theta_h2 = d_theta_h2_record(tmp_t_index) ;
    theta_o = theta_o_record(tmp_t_index);
    K =  tielineRecord(tmp_t_index) / P_rated;
end
Tmin = T * 60;
KR = (1 + K .^ 2 * R) ./ (1 + R);
d_theta_oi = theta_o - theta_a;
theta_o = theta_a + d_theta_oi + (d_theta_or * (KR .^ x) -d_theta_oi) * (1 - exp(- Tmin / (k11 * eta_o)));
d_theta_h1 = d_theta_h1 + (k21 * (K .^ y) * d_theta_hr - d_theta_h1) * (1 - exp(- Tmin / (k22 * eta_w)));
d_theta_h2 = d_theta_h2 + ((k21 - 1) * (K .^ y) * d_theta_hr - d_theta_h2) * (1 - exp(- Tmin / (eta_o / k22)));
d_theta_h = d_theta_h1 - d_theta_h2;
theta_h = theta_o + d_theta_h;
maxIndex = find(theta_h > MAX_TEMP, 1);
if maxIndex > 1
    K = K(1: maxIndex);
    theta_h = theta_h(1: maxIndex);
    KR = KR(1: maxIndex);
    theta_o = theta_o(1: maxIndex);
    d_theta_h1 = d_theta_h1(1: maxIndex);
    d_theta_h2 = d_theta_h2(1: maxIndex);
    d_theta_h = d_theta_h(1: maxIndex);
else
    maxIndex = length(K);
end
DL = exp((15000 / (110 + 273) - 15000 ./ (theta_h + 273))); % 110 for thermally updated paper
if isBid == 1
    P_rated = tielineBuy;%kW
    dC_dL = install_cost / expectancy;
%     dL_dtheta_h = DL1 * log(2) / 6;
    dL_dtheta_h = DL .* 15000 ./ (theta_h + 273) ./(theta_h + 273) ;
    dtheta_h_dK =  (1 - exp(- Tmin / (k22 * eta_w))) * d_theta_hr * k21 * y .* K .^(y - 1) + ... %d_theta_h1
        (1 - exp(- Tmin / (eta_o / k22))) * d_theta_hr * (k21 - 1 ) * y .* K .^ (y - 1) + ... %d_theta_h2
       (1 - exp(- Tmin / (eta_o * k11))) * d_theta_or * x .* KR .^ (x - 1) * 2 .* K * R / (1 + R); %theta_o
    dK_dP = 1 / P_rated;
    dC_dP = 60 * dC_dL .* dL_dtheta_h .* dtheta_h_dK .* dK_dP;
    tielineCurve = zeros(1, step + 1);
    for q = 1: step + 1
        t_index_tmp = maxIndex;
        price_tmp = pCurve(q) - gridPrice;
        if price_tmp < 0
            tielineCurve(q) = - tielineSold;
        elseif price_tmp == 0
            tielineCurve(q) = 0;
            maxPower = tielineBuy;
        else
            while dC_dP(t_index_tmp) > price_tmp
                t_index_tmp = t_index_tmp - 1;
                if t_index_tmp == 1
                    break;
                end
            end
            if t_index_tmp == maxIndex
                tielineCurve(q) = K(end) * P_rated;
            else
                dP = K(t_index_tmp + 1) - K(t_index_tmp);
                dlambda = dC_dP(t_index_tmp + 1) - dC_dP(t_index_tmp);
                if dlambda == 0
                    tielineCurve(q) = (K(t_index_tmp + 1) + K(t_index_tmp))/2 * P_rated;
                else
                    tielineCurve(q) = P_rated * (K(t_index_tmp) + (price_tmp - dC_dP(t_index_tmp)) * dP / dlambda);
                end
            end
        end
    end
    tielineCurve = - tielineCurve;
else
    if isMultiDay == 0
        tmp_t_index = mod_t;
    else
        tmp_t_index = t_index + 1;
    end
    theta_h_record(tmp_t_index)= theta_h;
    d_theta_h1_record(tmp_t_index)= d_theta_h1;
    d_theta_h2_record(tmp_t_index)= d_theta_h2;
    theta_o_record(tmp_t_index) = theta_o;
    DL_record(tmp_t_index) = DL;
end