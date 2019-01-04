step = 500;%投标精度
mkt_min = 0.5;
mkt_max = 2;
mkt = [mkt_min,mkt_max,step];
pCurve = (mkt_min:(mkt_max-mkt_min)/step:mkt_max);
load('../data/load_2017');
loadPower = Load(:, 1 : 96);
for i = 1 : 6
    loadPower = [loadPower; Load(:, i * 96 + 1 : (i + 1) * 96)];  
end
loadPower = loadPower / max(max(Load)) * LOAD;
loadPowerRecord = mean(loadPower);
load('../data/wind_2017');
windPower = Wind(:, 1 : 96);
for i = 1 : 6
    windPower = [windPower; Wind(:, i * 96 + 1 : (i + 1) * 96)];  
end
windPower = windPower / max(max(Wind)) * WIND;
windPowerRecord = mean(windPower);
clear Load Wind loadPower windPower LOAD WIND