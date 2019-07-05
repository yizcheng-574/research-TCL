function [ Pmax,Pmin,Pavg ] = EVBidPara( T, E, alpha, t, E_min, E_max, PN, prePrice ) %t为剩余时间
E_avg = alpha * E_max + (1 - alpha) * E_min;
delta_E = max(0, E_avg - E);
% E_avg=E_min;
%该函数根据EV的E,用户设定的信息,包括alpha,E_min,E_max,t
%来计算EV的投标参数Pmax,Pmin,Pavg
%type 1
if t<T
    Pmax = 0;
    Pmin = 0;
    Pavg = 0;
    return;
end
tleft = floor(t/T);
Pmax = min(PN, (E_max - E) / T);
if E_min > E && E_min - E < (tleft - 1) * T * PN
    Pmin = 0;
elseif E_min - E > (tleft - 1) * T * PN && E_min - E < tleft * T * PN
        Pmin =(E_min - E) / tleft / T;
elseif E_min - E > tleft * T * PN
    Pmin = PN;
else
    Pmin=0;
    tmp=max(0,(E_avg-E)/tleft/T);
    Pavg=min(PN,tmp);
    Pmax=min(PN,(E_max-E)/T);
    Pmax=max(0,Pmax);
end   
if delta_E==0
    Pavg=0;
else
    [meanpre_price_order, tmp1]= sort(prePrice);
    tmp2 = ceil(delta_E / T / PN);
    if tmp2 >= length(meanpre_price_order)
        Pavg = min(PN, delta_E / T / tmp2);
    else
        min_bidprice = meanpre_price_order(tmp2);
        if tmp2 + 1 <= length(meanpre_price_order)
            tmp3 = meanpre_price_order(tmp2 + 1);
            while tmp3 - min_bidprice < 0.01
                tmp2 = tmp2 + 1;
                if tmp2 + 1 > length(meanpre_price_order)
                    break;
                else
                    tmp3 = meanpre_price_order(tmp2 + 1);
                end
            end
        end
        [~, tmp5] = find(tmp1 == 1);
        if tmp5 <= tmp2
            Pavg = delta_E / T / tmp2;
        else
            Pavg = 0;
        end
    end
end
Pavg = max(Pmin,Pavg);
Pavg = min(Pmax,Pavg);
end

