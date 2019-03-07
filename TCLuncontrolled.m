global dt T I1 FFA IVA p1 p2 q1 q2 psiRecord
for tcl = 1 : FFA + IVA
    Ta = TCLdata_Ta_benchmark(tcl, mod(time / dt, I1) + 1);
    state = TCLdata_state_benchmark(1, tcl);
    Pa = TCLdata_PN(1, tcl);
    R = TCLdata_R(1, tcl);
    C = TCLdata_C(1, tcl);
    dt_second = dt * 3600;
    for sub_i = 1 : T / dt
        T0 = Tout(floor((time + (sub_i - 1) * dt ) * 60) + 1);
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
                TCLdata_P_benchmark(tcl, time / dt + sub_i) = Pa;       

            else
                Q = q1 / p1 * IVAdata_Pmin(1, tcl - FFA) -(q1 * p2 - p1 * q2) / p1;
                TCLdata_P_benchmark(tcl, time / dt + sub_i) = IVAdata_Pmin(1, tcl - FFA);       
            end
        else
            Q = 2.7 * Pa * state;
            TCLdata_P_benchmark(tcl, time / dt + sub_i) = state * Pa;       
        end
        Q = Q - psiRecord(tcl);
        Ta = T0 - Q * R - (T0 - Q * R - Ta) * exp(- dt / R / C);
        TCLdata_Ta_benchmark(tcl, mod(time / dt + sub_i, I1) + 1) = Ta;
    end
    TCLdata_state_benchmark(1, tcl) = state; 
end