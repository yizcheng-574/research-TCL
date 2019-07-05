k = 0.4 : 0.05 : 1.4;
X = 0.8;
R = 8;
y = 1.6;
Y3 = 1 + 2 * X * R * (k - 1) * X / (1 +R);

I=96; T=0.25;
d_theta_h10 = 53.2; d_theta_h20= 26.6; theta_o0 = 63.9;%C
R = 8; x = 0.8; y = 1.6; d_theta_or = 45; d_theta_hr = 35; eta_o = 180; eta_w = 8; k11 = 1; k21 = 1; k22 = 2;

% 精确形式
kX = @(k) ((1 + R * k.^2)/(1 + R)).^x;     
kY = @(k) k.^y;
% 近似形式

fk = @(k2) ((1 + k2* R) / (1 + R)) ^x; %fx
f1k = @(k2) x * R / (1 + R) * ((1 + k2 * R) / (1 + R)) ^ (x -1); %f'x
fy = @(k2) k2 ^ (y /2); %fy
f1y = @(k2) y /2  * k2 ^(y / 2 -1); %f'y
k0 = 1;
kX_taylor = @(k) fk(k0) + f1k(k0) * (k .^2 - k0 ^ 2); %一阶泰勒
kY_taylor = @(k) fy(k0) + f1y(k0) * (k .^2 - k0 ^ 2);



plot(k, kX(k), 'LineWidth', 2, 'DisplayName','精确结果', 'Color', 'black'); hold on;
plot(k, kX_taylor(k), 'LineWidth', 1.5, 'DisplayName','平方展开');
plot(k, Y3, 'LineWidth', 1.5, 'DisplayName', '一次展开');
xlabel('K')
set(gcf,'unit','normalized','position',1.2 * [0,0,0.2,0.15]);

figure
Z1 = k .^y;
Z2 = 1 + (y /2) * (k .^2 - 1);
plot(k, Z1); hold on;
plot(k, Z2)
plot(k, (Y2 - Y1) ./ Y1)