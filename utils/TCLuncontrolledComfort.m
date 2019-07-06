% TCL按最舒适运行
T0 = theta_a;
tmp_soa = (TCLdata_Ta(:, t_index)'- TCLdata_T(2,:)) ./ (TCLdata_T(1,:) - TCLdata_T(2,:));
e = exp(- T ./ TCLdata_R ./ TCLdata_C);
denominator = TCLdata_R .* (1 - e);
a =  - (TCLdata_T(1,:) - TCLdata_T(2,:)) ./ denominator;
b = - e .* a;
c = (theta_a -TCLdata_T(2,:)) ./ TCLdata_R;
tmp_Q = a * 0.5 + b .* tmp_soa + c;
tmp_P = zeros(1, FFA + IVA);
tmp_P(1:FFA) = tmp_Q(1:FFA) / 2.7;
tmp_P(FFA + 1 : end) =  p1 / q1 * tmp_Q(FFA+1:end) + (q1 * p2 - p1 * q2) / q1;
 
TCLdata_Ta(:,t_index + 1) = mean(TCLdata_T);
TCLdata_P(:, t_index) = tmp_P';
