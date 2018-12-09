%P, Pa, Ta, T0, state_flag, time, R, C
%自变量参数分别对应：目标功率 额定功率 室内温度  室外温度  空调状态  等效阻抗  等效电容
global TCLdata_state TCLdata_lockTime TCLdata_Ta TCLdata_P
for tcl = 1: TCL
    state_flag = TCLdata_state(1, tcl);
    lockTime = TCLdata_lockTime(1, tcl);
    Ta = TCLdata_Ta(tcl, time/dt + 1);
    Pa = TCLdata_PN(1, tcl);
    P = TCLpowerRecord(tcl, t_index);
    R = TCLdata_R(1, tcl);
    C = TCLdata_C(1, tcl);

    ratio =  P/ Pa;
    if  ratio < 0.5
        u1 = 0.01 + 0.005 * rand();
        u0 = (u1 * ratio) / (1 + 90 * u1 - ratio - ratio * 180 * u1);
    else
        u0 = 0.01 + 0.005 * rand();
        u1 = (u0 * ratio - u0) / (90 * u0 - ratio - ratio * 180 * u0);
    end
    
    for sub_i = 1 : T / dt
        T0 = Tout(floor((time + (sub_i - 1) * dt ) * 60) + 1);
        if state_flag == 1
            if rand(1, 1) <= u1
                state_flag = 2;
                lockTime = 0;
            else
                state_flag = 1;
            end
        else
            if state_flag == 2
                if (lockTime < 89)
                    state_flag = 2;
                    lockTime = lockTime + 1;
                else
                    state_flag = 3;
                end
            else
                if state_flag == 3
                    if rand(1, 1) <= u0
                        state_flag = 4;
                        lockTime = 0;
                    else
                        state_flag = 3;
                    end
                else
                    if lockTime<89
                        state_flag = 4;
                        lockTime = lockTime + 1;
                    else
                        state_flag = 1;
                    end
                end
            end
        end
        if state_flag == 1 || state_flag == 4
            state = 1;
        else
            state = 0;
        end
        Ta = T0 - 2.7 * Pa * state * R - (T0 - 2.7 * Pa * state * R - Ta) * exp(-dt / R / C);
        TCLdata_Ta(tcl, time /dt + sub_i + 1) = Ta;
        TCLdata_P(tcl, time /dt + sub_i) = state * Pa;
    end
    TCLdata_state(1, tcl) = state_flag;
    TCLdata_lockTime(1, tcl) = lockTime;
end
