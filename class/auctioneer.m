classdef auctioneer < transformer
    properties
        windPowerRecord; loadPowerRecord;
        DRmode;
    end
    methods
        function obj = auctioneer(d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY, wp, lp, gp, Tout, mkt, eta, dr)
            obj = obj@transformer(d_theta_h1, d_theta_h2, theta_o, yrs, CAPACITY, gp, Tout, mkt, eta);
            obj.windPowerRecord = wp;
            obj.loadPowerRecord = lp;
            obj.DRmode = dr;
        end
        
        function clearingPrice = clear(obj, t_index, bidCurve)
            K = [0.2: 0.1 : 0.7 0.71 : 0.01 :1.5]; %load factor            
            dC_dP = getDerivative(obj, K, t_index);
            step = obj.mkt(3);
            gridPrice = obj.gridPriceRecord(t_index);
            pCurve = (obj.mkt(1) : (obj.mkt(2) - obj.mkt(1)) / step : obj.mkt(2));

            if obj.DRmode(t_index) == 0
                tielineCurve = zeros(1, step + 1);
                k_index = 1;
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
            else
                tielineCurve = zeros(1, step + 1);
                for q = 1 : step + 1
                    if pCurve(q) < gridPrice
                        tielineCurve(q) = - obj.CAPACITY / 4;
                    elseif pCurve(q) >= gridPrice
                        tielineCurve(q) = obj.DRmode(t_index);
                    end
                end
            end
            newBidCurve = bidCurve - obj.windPowerRecord(t_index) + obj.loadPowerRecord(t_index);
            clearingPrice = calculateIntersection(obj.mkt, 0, newBidCurve - tielineCurve);
%             interp1q(pCurve', newBidCurve', clearingPrice)
            obj.priceRecord(t_index) = clearingPrice;
        end
        function update(obj, power, t_index)
            tmp = power- obj.windPowerRecord(t_index) + obj.loadPowerRecord(t_index);
            obj.tielineRecord(t_index) = tmp;
            obj.transUpdate(t_index);
        end
        
    end
end