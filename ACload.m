function [Pmax, Pmin, Pset] = ACload(Tmax, Tmin, Ta, R, C, T0, Pa, T_tcl)
%自变量参数分别对应最大温度，最小温度，当前室内温度，空调等效阻抗，等效电容，室外温度，额定功率
eta = 2.7;%能效比
e = exp(- T_tcl / R / C);
a = (Tmax - Tmin) / R / (1 - e );
b = - (Tmax -Tmin) / R * e / (1 - e);
c = -(T0 - Tmin - (T0 - Tmin) * e) / R / (1 - e);
SOC = (Ta - Tmin) / (Tmax - Tmin);
Pmax = ( b * SOC + c) / -eta;
Pmin = ( a + b * SOC + c) / -eta;
Pmax = min(Pa, Pmax);
Pmin = max(Pmin, 0);
Pset = (0.5 * (Tmax + Tmin) - T0) / R / -eta;