global FFA IVA p1 p2 q1 q2

TCLdata_state = ceil(unifrnd(0, 4, 1, FFA));
TCLdata_T(1, :) = unifrnd(27.5, 28.5, 1, FFA + IVA); 
TCLdata_T(2, :) = unifrnd(23.5, 24.5, 1, FFA + IVA); 
TCLdata_C = unifrnd(0.8 ,1.2, 1, FFA + IVA);
TCLdata_R = unifrnd(2 ,2.5, 1, FFA + IVA);
TCLdata_PN(1, 1:FFA) = unifrnd(2.5, 3.5, 1, FFA);
TCLdata_PN(1, FFA + 1 :FFA + IVA) = unifrnd(3.5, 4.5, 1, IVA);
IVAdata_Pmin = unifrnd(0.4, 0.5, 1, IVA);
TCLdata_initT = unifrnd(25.8, 26.2, FFA + IVA, 1);
p1 = 0.03;
q1 = 0.06;
p2 = -0.4;
q2 = -0.3;
sen_index = 1;
load('../data/Tout.mat');