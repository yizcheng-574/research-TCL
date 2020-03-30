MAX_TEMP = 120; % C
d_theta_o = 42.3; % K
d_theta_h1 = 53.2;
d_theta_h2= 26.6;
theta_o = 63.9; % C
theta_h_record = zeros(1, I);
d_theta_h1_record = zeros(1, I);
d_theta_h2_record = zeros(1, I);
theta_o_record = zeros(1, I);
if isMultiDay == 1
    tmp = 1;
else
    tmp = mod(offset / T , I) + 1;
end
theta_h_record(tmp) = theta_o + d_theta_h1 - d_theta_h2; 
d_theta_h1_record(tmp)= d_theta_h1;
d_theta_h2_record(tmp)= d_theta_h2;
theta_o_record(tmp) = theta_o;
expectancy = 20 * 365 * 24 * 60; % min
P_rated = tielineBuy;%kW
install_cost = 5000 * RATIO * weightRatio; %yuan
dC_dL = install_cost / expectancy;
