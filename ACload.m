function [Pmax,Pmin,Pset]=ACload(Tmax,Tmin,Ta,R,C,T0,Pa)
%自变量参数分别对应最大温度，最小温度，当前室内温度，空调等效阻抗，等效电容，室外温度，额定功率

a=(Tmax-Tmin)/R/(1-exp(-1/R/C));
b=-(Tmax-Tmin)/R*exp(-1/R/C)/(1-exp(-1/R/C));
c=-(T0-Tmin-(T0-Tmin)*exp(-1/R/C))/R/(1-exp(-1/R/C));
SOC=(Ta-Tmin)/(Tmax-Tmin);
Pmax=(b*SOC+c)/2.7/-1;
Pmin=(a+b*SOC+c)/-2.7;
Pmax=min(Pa,Pmax);
Pmin=max(Pmin,0);
Pset=(0.5*(Tmax+Tmin)-T0)/R/-2.7;