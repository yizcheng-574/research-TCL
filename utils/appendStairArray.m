function [ result ] = appendStairArray(array)%为stairs作图的数组增加最后一列
[row, col] = size(array);
if col > 1 %行向量
    result = [array, array(end)];
else
    result = [array; array(end)];
end
end