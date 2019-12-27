%计算老化成本
if isAging == 0 
    for day = 1 : DAY
        for i = 1 : I_day
            isBid = 0;
            t_index = (day - 1) * I_day + i;
            theta_a = Tout(i);
            transformer_ageing_expo;
        end
    end
end
if exist('IVAdata_Ta') == 1
    tmpT = [TCLdata_Ta;IVAdata_Ta];
else
   tmpT = TCLdata_Ta;
end
TCLdata_Ta_normalize = zeros(IVA+FFA, t_index + 1);
for iva = 1: FFA + IVA
    TCLdata_Ta_normalize(iva, :) = (tmpT(iva, :) - TCLdata_T(2, iva)) / (TCLdata_T(1, iva) - TCLdata_T(2, iva));
end
penaltyFFA = zeros(1, IVA + FFA);
denominator = 2.7 * TCLdata_R .* (1 - exp( - T_tcl ./ TCLdata_R ./ TCLdata_C));
a = (TCLdata_T(1,:) - TCLdata_T(2,:)) ./ denominator;

TCLon = repmat(EVdata,1,2);
for tcl = 1 :FFA + IVA
    isTCLon = zeros(1, I_day);
    for i = 1 : I_day
        time = (i - 1) * T ;
        if time > (TCLon(1, tcl) + 1)|| time < TCLon(2,tcl)
            isTCLon(i) = 1;
        else
            isTCLon(i) = 0;
        end
    end
    if tcl <= FFA
        penaltyFFA(tcl) = sum(repmat(isTCLon, 1, DAY) .*(TCLdata_Ta_normalize(tcl,2:end) - 0.5).^2 .* gridPriceRecord4 * a(tcl) * ratioFFA);
    else
        penaltyFFA(tcl) = sum(repmat(isTCLon, 1, DAY) .*(TCLdata_Ta_normalize(tcl,2:end) - 0.5).^2 .* gridPriceRecord4 * (TCLdata_PN(1, tcl)-IVAdata_Pmin(1, tcl-FFA)) * ratioIVA);
    end
end
%计算配网成本
DSO_cost(1) = sum(DL_record) * install_cost / expectancy;%变压器老化成本
DSO_cost(2) = tielineRecord * gridPriceRecord4' * T; %配网总用电成本
DSO_cost(3) = sum(penaltyFFA) * T;
%各TCL实际成本和优化所得成本
%统计单个TCL电费
% if isTCLflex == 1
%     IVAdata_cost = priceRecord * IVApowerRecord'* T;
% else
%     TCLdata_cost = priceRecord * TCLdata_P(1: FFA, :)' * T;
%     IVAdata_cost =  priceRecord * TCLdata_P(FFA +1 : end, :)'* T;
% end
% 
% EVdata_cost = priceRecord * EVpowerRecord'* T;

%%price volatility index
if exist('priceRecord') == 1
    cnt = 0;
    for i = 2 : I
        cnt = cnt + (priceRecord(i) - priceRecord(i - 1))^2;
    end
    evaluation_price_volatility = sqrt(cnt/ (I - 1)) / (mkt_max - mkt_min);
end
%%load volatity
cnt = 0;
for i = 2 : I
    cnt = cnt + (tielineRecord(i) - tielineRecord(i - 1))^2;
end
evaluation_load_volatility =  sqrt(cnt/ (I - 1)) / tielineBuy;