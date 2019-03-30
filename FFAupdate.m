%P, Pa, Ta, T0, state_flag, time, R, C
%自变量参数分别对应：目标功率 额定功率 室内温度  室外温度  空调状态  等效阻抗  等效电容
dt_second = dt * 3600;
tmp_P_desire = TCLpowerRecord(:, t_index_tcl);
ratio =  tmp_P_desire ./ TCLdata_PN(1:FFA)';
u1 = zeros(FFA, 1);
u0 = zeros(FFA, 1);
randU = rand(1, FFA);
e = exp( - dt ./ TCLdata_R ./ TCLdata_C); 
parfor tcl = 1 : FFA
    if  ratio(tcl) > 0.5
        u1(tcl) = 0.01 + 0.005 * randU(tcl);
        u0(tcl) = u1(tcl) * ( 1 - ratio(tcl)) * dt_second / (dt_second * ratio(tcl) + 360 * ratio(tcl) * u1(tcl) -180 * u1(tcl));
    else
        u0(tcl) = 0.01 + 0.005 * randU(tcl);
        u1(tcl) = (dt_second * u0(tcl) * ratio(tcl)) / (dt_second - dt_second * ratio(tcl) - 360 * ratio(tcl) * u0(tcl) + 180 * u0(tcl));
    end
end
if isMultiDay == 1
    tmp_Ta = TCLdata_Ta(:, t_index);
    cnt_P = zeros(FFA, 1);
else
    tmp_Ta = TCLdata_Ta(:, time / dt + 1);
end

for sub_i = 1 : T_tcl / dt
    T0 = getTout(Tout, i + floor(sub_i * dt / T), 1);
    tmp_P = zeros(FFA, 1);
    parfor tcl = 1: FFA        
        if TCLdata_state(1, tcl) == 1
            if rand(1, 1) <= u0(tcl)
                TCLdata_state(1, tcl) = 2;
                TCLdata_lockTime(1, tcl) = 0;
            else
                TCLdata_state(1, tcl) = 1;
            end
        else
            if TCLdata_state(1, tcl) == 2
                if (TCLdata_lockTime(1, tcl) < 180 / dt_second - 1) %闭锁时间3分钟
                    TCLdata_state(1, tcl) = 2;
                    TCLdata_lockTime(1, tcl) = TCLdata_lockTime(1, tcl) + 1;
                else
                    TCLdata_state(1, tcl) = 3;
                end
            else
                if TCLdata_state(1, tcl) == 3
                    if rand(1, 1) <= u1(tcl)
                        TCLdata_state(1, tcl) = 4;
                        TCLdata_lockTime(1, tcl) = 0;
                    else
                        TCLdata_state(1, tcl) = 3;
                    end
                else
                    if TCLdata_lockTime(1, tcl) < 180 / dt_second - 1
                        TCLdata_state(1, tcl) = 4;
                        TCLdata_lockTime(1, tcl) = TCLdata_lockTime(1, tcl) + 1;
                    else
                        TCLdata_state(1, tcl) = 1;
                    end
                end
            end
        end
        if TCLdata_state(1, tcl) == 1 || TCLdata_state(1, tcl) == 4
            state = 1;
        else
            state = 0;
        end
        tmp_Ta(tcl) = T0 - (2.7 * TCLdata_PN(1, tcl) * state)* TCLdata_R(1, tcl) - (T0 - (2.7 * TCLdata_PN(1, tcl) * state) * TCLdata_R(1, tcl) - tmp_Ta(tcl)) * e(tcl);
        tmp_P(tcl) = state * TCLdata_PN(1, tcl);
    end
    if isMultiDay == 0
        TCLdata_Ta(:, time / dt + sub_i + 1) = tmp_Ta;
        TCLdata_P(:, time / dt + sub_i) = tmp_P;
    else
        cnt_P = cnt_P + tmp_P; %计算各FFA平均功率
        TCLinstantPowerRecord(:, time_all / dt + sub_i) = sum(tmp_P); % 记录FFA集群总跟踪功率
    end
    if isMultiDay == 1 && mod(sub_i, T / dt) == 0
        TCLdata_Ta(:,t_index + sub_i * dt/ T) = tmp_Ta;
        TCLdata_P(:, t_index + sub_i * dt/ T - 1) = cnt_P / sub_i;
    end
end




