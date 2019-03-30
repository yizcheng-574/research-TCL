function Parray = EVopt( T, E, alpha, E_min, E_max, PN, prePrice ) %tÎªÊ£ÓàÊ±¼ä
E_avg = alpha * E_max + (1 - alpha) * E_min;
delta_E = max(0, E_avg - E);
len = length(prePrice);
f = prePrice;
A = - ones(1, len);
b = - delta_E / T;
Parray = linprog(f, A, b, [], [], zeros(len, 1), ones(len, 1) * PN);
if exist('Parray', 'var') ~= 1
    delta_E
    len
end
end

