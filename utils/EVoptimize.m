% proximal 求解EV优化问题 输出长度为固定I
function [p, fval] = EVoptimize(price, ta, td, PN, E, proxPoint, rho)
    global I T
    H = rho * eye(I); f = price - rho * proxPoint;
    lb = zeros(I, 1);
    ub = zeros(I, 1);
    ub(ceil((ta - 12) / T) : floor((td -12) / T)) = PN * ones(  floor(td / T) - ceil(ta / T)  + 1, 1);
    Aeq = T * ones(1, I);
    beq = E;
    if rho == 0
        [p, fval] = linprog(price, [], [], Aeq, beq, lb, ub);
    else
        [p, fval] = quadprog(H, f, [], [], Aeq, beq, lb, ub);
    end
end