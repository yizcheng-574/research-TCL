clear;clc;

Tmax = 26;
Tmin = 22;
Ta = 24;
T0 = 35;
state_flag = 3;%1对应ON,2对应OFFLOCK,3对应OFF,4对应ONLOCK
time = 4;%闭锁时间1个间隔表示2s
[Pmax, Pmin, Pset] = ACload(Tmax, Tmin, Ta, R, C, T0, P);
[Ta, state_flag, time] = AC(0.2 * P, P, Ta, T0, state_flag, time, R, C);