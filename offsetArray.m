function [ result ] = offsetArray(array, offset)
[row, col] = size(array);
offset = mod(offset, max(row, col));
if row == 1 %ĞĞÏòÁ¿
    result = [ array(1, offset + 1 : end), array(1, 1: offset)];
elseif col == 1
    result = [ array(offset + 1: end, 1); array(1 : offset, 1)];
else
    result = [ array(:, offset + 1 : end), array(:, 1: offset)];
end
end