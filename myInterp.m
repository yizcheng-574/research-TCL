function bidCurve = myInterp(x, y, xi)
%假设单调非增
len_xi =  length(xi);
bidCurve = zeros(1, len_xi);
last_k = 1;
for i = 1: len_xi
    if xi(i) < x(1)
        bidCurve(i) = y(1);
    elseif xi(i) > x(len_xi)
        bidCurve(i) = y(len_xi);
    else
        for j = last_k : len_xi -1
            if xi(i) >= x(j) && xi(i) <x(j + 1)
                d_x = x(j + 1) - x(j);
                d_y = y(j + 1) - y(j);
                bidCurve(i) = y(j) + d_y / d_x * (xi(i) - x(j));
                last_k = j;
                break;
            end
        end
    end
end
end