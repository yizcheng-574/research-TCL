T0 = theta_a;
if isMultiDay == 1
    tmp_Ta = TCLdata_Ta_benchmark(:, t_index);
    cnt_P = zeros(FFA + IVA, 1);
else
    tmp_Ta = TCLdata_Ta(:, time / dt + 1);
end
e = exp(- dt ./ TCLdata_R ./ TCLdata_C);
 for sub_i = 1 : T / dt
    tmp_P = zeros(FFA + IVA, 1);
    for tcl = 1 : FFA + IVA
        Ta = tmp_Ta(tcl);
        state = TCLdata_state_benchmark(1, tcl);
        Pa = TCLdata_PN(1, tcl);
        R = TCLdata_R(1, tcl);
        C = TCLdata_C(1, tcl);
        if state == 0
            if Ta < TCLdata_T(1, tcl)
                state = 0;
            else
                state = 1;
            end
        else
            if Ta > TCLdata_T(2, tcl)
                state = 1;
            else
                state = 0;
            end
        end
        if tcl > FFA
            if state == 1
                Q = q1 / p1 * Pa -(q1 * p2 - p1 * q2) / p1;
                tmp_P(tcl) = Pa; 
            else
                Q = q1 / p1 * IVAdata_Pmin(1, tcl - FFA) - (q1 * p2 - p1 * q2) / p1;
                tmp_P(tcl) = IVAdata_Pmin(1, tcl - FFA);       
            end
        else
            Q = 2.7 * Pa * state;
            tmp_P(tcl) = state * Pa;       
        end
        Ta = T0 - Q * R - (T0 - Q * R - Ta) * e(tcl);
        tmp_Ta(tcl) = Ta;
        TCLdata_state_benchmark(1, tcl) = state; 
     end
    if isMultiDay == 0
        TCLdata_Ta_benchmark(:, time / dt + sub_i + 1) = tmp_Ta;
        TCLdata_P_benchmark(:, time / dt + sub_i) = tmp_P;
    else
        cnt_P = cnt_P + tmp_P;
        TCLinstantPowerRecord_benchmark(:, time / dt + sub_i) = sum(tmp_P);
    end
 end
 TCLdata_Ta_benchmark(:,t_index + 1) = tmp_Ta;
 TCLdata_P_benchmark(:, t_index) = cnt_P / sub_i;
