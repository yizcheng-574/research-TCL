global dt T_tcl I1
for tcl = 1 : TCL
    if isTCLflex == 1
        Ta = TCLdata_Ta_benchmark(tcl, mod(time / dt, I1) + 1);
    else
        Ta = TCLdata_Ta(tcl, mod(time / dt, I1) + 1);
    end
    state = TCLdata_state_benchmark(1, tcl);
    Pa = TCLdata_PN(1, tcl);
    R = TCLdata_R(1, tcl);
    C = TCLdata_C(1, tcl);
    dt_second = dt * 3600;
    for sub_i = 1 : T_tcl / dt
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
        Ta = T0 - 2.7 * Pa * state * R - (T0 - 2.7 * Pa * state * R - Ta) * exp(- dt / R / C);
        if isTCLflex == 1
            TCLdata_Ta_benchmark(tcl, mod(time / dt + sub_i, I1) + 1) = Ta;
            TCLdata_P_benchmark(tcl, time / dt + sub_i) = state * Pa;
        else
            TCLdata_Ta(tcl, mod(time / dt + sub_i, I1) + 1) = Ta;
            TCLdata_P(tcl, time / dt + sub_i) = state * Pa;
        end
    end
    TCLdata_state_benchmark(1, tcl) = state;
   
end