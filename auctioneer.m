classdef auctioneer < transformer  
    properties
        isAging;
    end
    
    methods
        function obj = auctioneer(isAging, d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY, gp, Tout, mkt)
            obj = obj@transformer(d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY, gp, Tout, mkt);
            obj.isAging = isAging;
        end
        
        function clearingPrice = clear(obj, t_index, bidCurve)
            K = [0.2: 0.1 : 0.7 0.71 : 0.01 :1.5]; %load factor            
            dC_dP = getDerivative(obj, K, t_index);
            step = obj.mkt(3);
            gridPrice = obj.gridPriceRecord(t_index);
            tielineCurve = zeros(1, step + 1);
            k_index = 1;
            if obj.isAging == 1
                for q = 1: step + 1
                    price_tmp = obj.pCurve(q) - gridPrice;
                    if price_tmp < 0
                        tielineCurve(q) = -obj.CAPACITY / 4;
                    elseif price_tmp == 0
                        tielineCurve(q) = obj.CAPACITY;
                    else
                        for tmp_i = k_index : length(K) - 1
                            if dC_dP(tmp_i) <= price_tmp && dC_dP(tmp_i + 1) >= price_tmp
                                 k_index = tmp_i;
                                break;
                            end
                        end
                        if tmp_i == length(K)
                            tielineCurve(q) = K(end) * obj.CAPACITY;
                        else
                            dP = K(tmp_i + 1) - K(tmp_i);
                            dlambda = dC_dP(tmp_i + 1) - dC_dP(tmp_i);
                            if dlambda == 0
                                tielineCurve(q) = (K(tmp_i + 1) + K(tmp_i))/2 *  obj.CAPACITY;
                            else
                                tielineCurve(q) =  obj.CAPACITY * (K(tmp_i) + (price_tmp - dC_dP(tmp_i)) * dP / dlambda);
                            end
                        end
                    end
                end
            elseif obj.isAging == 0
                qstep = obj.pCurve;
                qstep(qstep < gridPrice) = - obj.CAPACITY / 4;
                qstep(qstep >= gridPrice) = obj.CAPACITY;
                tielineCurve = qstep;
            end
            clearingPrice = calculateIntersection(obj.mkt, 0, bidCurve - tielineCurve);
            obj.priceRecord(t_index) = clearingPrice;
        end
        function update(obj, power, t_index)
            obj.tielineRecord(t_index) = power;
            obj.transUpdate(t_index);
        end
    end
end