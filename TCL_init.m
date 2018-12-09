global TCLdata_state TCLdata_lockTime TCLdata_Ta TCLdata_P
dt = 1 / 30 / 60;
I1 = 24 / dt;
TCLdata_state = ceil(unifrnd(0, 4, 1, TCL));
TCLdata_lockTime = zeros(1, TCL);
TCLdata_T(1, :) = unifrnd(27.8, 28.2, 1, TCL); 
TCLdata_T(2, :) = unifrnd(23.8, 24.2, 1, TCL); 
TCLdata_Ta = zeros(TCL, 24 / dt);
TCLdata_P = zeros(TCL, 24 / dt);
TCLdata_C = unifrnd(0.8 ,1.2, 1, TCL);
TCLdata_R = unifrnd(2 ,2.5, 1, TCL);
TCLdata_PN = unifrnd(2.5, 3.5, 1, TCL);
TCLdata_beta = unifrnd(0.5,2,1,TCL);
load('../data/Tout.mat');