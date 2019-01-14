global dt TCL

TCLdata_state = ceil(unifrnd(0, 4, 1, TCL));
TCLdata_state_benchmark = floor(unifrnd(0, 2, 1, TCL));
TCLdata_T(1, :) = unifrnd(27.5, 28.5, 1, TCL); 
TCLdata_T(2, :) = unifrnd(23.5, 24.5, 1, TCL); 
TCLdata_C = unifrnd(0.8 ,1.2, 1, TCL);
TCLdata_R = unifrnd(2 ,2.5, 1, TCL);
TCLdata_PN = unifrnd(2.5, 3.5, 1, TCL);
sen_index = 1;
load('../data/Tout.mat');