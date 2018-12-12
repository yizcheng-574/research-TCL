%P, Pa, Ta, T0, state_flag, time, R, C
%自变量参数分别对应：目标功率 额定功率 室内温度  室外温度  空调状态  等效阻抗  等效电容
global dt T_tcl
for tcl = 1: TCL
    state_flag = TCLdata_state(1, tcl);
    lockTime = TCLdata_lockTime(1, tcl);
    Ta = TCLdata_Ta(tcl, mod(time / dt, I1) + 1);
    Pa = TCLdata_PN(1, tcl);
    P = TCLpowerRecord(tcl, t_index_tcl);
    R = TCLdata_R(1, tcl);
    C = TCLdata_C(1, tcl);
    dt_second = dt * 3600;
    ratio =  P/ Pa;
    if  ratio > 0.5
        u1 = 0.01 + 0.005 * rand();
        u0 = u1 * ( 1 - ratio) * dt_second / (dt_second * ratio + 360 * ratio * u1 -180 * u1);       
    else
        u0 = 0.01 + 0.005 * rand();
        u1 = (dt_second * u0 * ratio) / (dt_second - dt_second * ratio - 360 * ratio * u0 + 180 * u0);   
    end
    
    for sub_i = 1 : T_tcl / dt
        T0 = Tout(floor((time + (sub_i - 1) * dt ) * 60) + 1);
        if state_flag == 1
            if rand(1, 1) <= u0
                state_flag = 2;
                lockTime = 0;
            else
                state_flag = 1;
            end
        else
            if state_flag == 2
                if (lockTime < 180 / dt_second - 1) %闭锁时间3分钟
                    state_flag = 2;
                    lockTime = lockTime + 1;
                else
                    state_flag = 3;
                end
            else
                if state_flag == 3
                    if rand(1, 1) <= u1
                        state_flag = 4;
                        lockTime = 0;
                    else
                        state_flag = 3;
                    end
                else
                    if lockTime < 180 / dt_second - 1
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
        Ta = T0 - 2.7 * Pa * state * R - (T0 - 2.7 * Pa * state * R - Ta) * exp(- dt / R / C);
        TCLdata_Ta(tcl, mod(time / dt + sub_i, I1) + 1) = Ta;
        TCLdata_P(tcl, time / dt + sub_i) = state * Pa;
    end
    TCLdata_state(1, tcl) = state_flag;
    TCLdata_lockTime(1, tcl) = lockTime;
end
