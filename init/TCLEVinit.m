function [EVdata,EVdata_mile, EVdata_capacity, PN, TCLdata_T, TCLdata_C, TCLdata_R, FFAdata_PN, IVAdata_PN, TCLdata_Pmin, TCLdata_initT ] = TCLEVinit (TA_avg, TA_sigma, TD_avg, TD_sigma, EV, IVA, FFA)
% EV init
global T
EVdata = zeros(2, EV);
EVdata(1,:) = normrnd(TA_avg, TA_sigma, 1, EV);
EVdata(2,:) = normrnd(TD_avg, TD_sigma, 1, EV);
EVdata(EVdata < 12) = 12 + T;
EVdata(EVdata > 36) = 36;
EVdata_mile = unifrnd(10,20,1,EV);
EVdata_capacity = unifrnd(20, 25, 1, EV);
PN = 3.7;

for ev = 1 : EV
    while EVdata(2,ev) <= EVdata(1,ev) || (EVdata(2, ev) - EVdata(1, ev)) * PN < EVdata_mile(ev)
        EVdata(2,ev) = normrnd(TD_avg, TD_sigma);
    end
end

% TCL init
TCL = IVA + FFA;
TCLdata_T(1, :) = unifrnd(27.5, 28.5, 1, TCL); 
TCLdata_T(2, :) = unifrnd(23.5, 24.5, 1, TCL); 
TCLdata_C = unifrnd(0.8 ,1.2, 1, TCL);
TCLdata_R = unifrnd(2 ,2.5, 1, TCL);
FFAdata_PN = unifrnd(2.5, 3.5, 1, FFA);
IVAdata_PN = unifrnd(3.5, 4.5, 1, IVA);
TCLdata_Pmin = unifrnd(0.4, 0.5, 1, IVA);
TCLdata_initT = unifrnd(25.8, 26.2, TCL, 1);
end