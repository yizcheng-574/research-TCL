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
tmp_P(FFA + 1 : end) =  p1 / q1 * tmp_Q(FFA + 1:end) + (q1 * p2 - p1 * q2) / q1;
parfor tcl = 1: FFA
    if tmp_P(tcl) > TCLdata_PN(tcl)
        tmp_P(tcl) = TCLdata_PN(tcl);
    elseif tmp_P(tcl) < 0
        tmp_P(tcl) = 0;
    end
end
parfor tcl = FFA + 1 : FFA + IVA
    if tmp_P(tcl) > TCLdata_PN(tcl)
        tmp_P(tcl) = TCLdata_PN(tcl);
    elseif tmp_P(tcl) < IVAdata_Pmin(tcl-FFA)
        tmp_P(tcl) = IVAdata_Pmin(tcl-FFA);
    end
end
tmp_P = [isFFAon; isIVAon] .* tmp_P';
TCLdata_P(:, t_index) = tmp_P;
tmp_Ta = TCLdata_Ta(:, t_index);
parfor tcl = 1 : FFA
      Ta = tmp_Ta(tcl);
      R = TCLdata_R(1, tcl);
      C = TCLdata_C(1, tcl);
      P = tmp_P(tcl);
      tmp_Ta(tcl) = T0 - (2.7 * P)* R - (T0 - (2.7 * P) * R - Ta) * exp(- T / R / C);
end
parfor iva = 1: IVA
     R = TCLdata_R(1, iva + FFA);
     C = TCLdata_C(1, iva + FFA);
     heat_rate_IVA = q1 / p1 * tmp_P(iva) - (q1 * p2 - p1 * q2) / p1;
     tmp_Ta(iva) = theta_a - heat_rate_IVA * R - (theta_a - heat_rate_IVA * R - tmp_Ta(iva)) * exp(- T / R / C);
end
TCLdata_Ta(:, t_index + 1) = tmp_Ta;


