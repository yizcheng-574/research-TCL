function [ rgb ] = num2rgb(array)
%输入数组array，生成对应的渐变rgb矩阵
max_num = max(array);
min_num = min(array);
rgb = zeros(length(array), 3);
base16_array = floor((array - min_num) / (max_num - min_num) * 2^24); %0-FFFFFF
for k = 1: length(array)
    %输入0-ffffff之间数字，生成rgb%
    num = base16_array(k);
    r = floor(num / 2^16);
    g = floor((num - r * 2^16) / 2^8);
    b = num - r * 2^16 - g * 2^8;
    rgb(k, :) =  [r / 255, g / 255, b / 255];
end
end





