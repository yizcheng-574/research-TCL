function [ToutRecord] = getTout(Tout, s, leng)
N = length(Tout);
e = leng + s - 1;
if s > N
    s = mod(s - 1, N) + 1;
end
if e > N
    e = mod(e - 1, N) + 1;
end
if e < s
    [row, col] = size(Tout);
    if row == 1
        ToutRecord = [Tout(s: end), Tout(1: e)];
    elseif col ==1
        ToutRecord = [Tout(s: end); Tout(1: e)];
    end
else
    ToutRecord = Tout(s:e);
end
end