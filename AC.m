function [Ta,state_flag,time]=AC(P,Pa,Ta,T0,state_flag,time,R,C)  
%自变量参数分别对应：目标功率 额定功率 室内温度  室外温度  空调状态  等效阻抗  等效电容
flag=P/Pa;
dt=1/30/60;
if (flag<0.5)
    u1=0.01+0.005*rand(1,1);
    u0=(u1*flag)/(1+90*u1-flag-flag*180*u1);
else
    u0=0.01+0.005*rand(1,1);
    u1=(u0*flag-u0)/(90*u0-flag-flag*180*u0);
end

for j=1:30*60
    if (state_flag==1)
        if (rand(1,1)<=u1)
            state_flag=2;
            time=0;
        else
            state_flag=1;
        end
    else
        if (state_flag==2)
            if (time<89)
                state_flag=2;
                time=time+1;
            else
                state_flag=3;
            end
        else
            if (state_flag==3)
                if (rand(1,1)<=u0)
                    state_flag=4;
                    time=0;
                else
                    state_flag=3;
                end
            else
                if (time<89)
                    state_flag=4;
                    time=time+1;
                else
                    state_flag=1;
                end
            end
        end
    end
    if (state_flag==1||state_flag==4)
        state=1;
    else
        state=0;
    end
    Ta=T0-2.7*Pa*state*R-(T0-2.7*Pa*state*R-Ta)*exp(-dt/R/C);
end