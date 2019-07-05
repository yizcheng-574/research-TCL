step = 500;%投标精度
mkt_min = 0.1;
mkt_max = 1.5;
mkt = [mkt_min,mkt_max,step];
pCurve = (mkt_min:(mkt_max-mkt_min)/step:mkt_max);
load('../../data/load_2017');
load('../../data/wind_2017');
w_s = 14; w_e = 26;
if isMultiDay == 0 %单天
    Load = Load(w_s: w_e, :);
    loadPower = Load(:, 1 : 96);
    for i = 1 : 6
        loadPower = [loadPower; Load(:, i * 96 + 1 : (i + 1) * 96)];  
    end
    loadPower = loadPower / max(max(Load)) * LOAD;
    loadPowerRecord = mean(loadPower);
    
    Wind = Wind(w_s: w_e, :);
    windPower = Wind(:, 1 : 96);
    for i = 1 : 6
        windPower = [windPower; Wind(:, i * 96 + 1 : (i + 1) * 96)];  
    end
    windPower = windPower / max(max(windPower)) * WIND;
    windPowerRecord = mean(windPower);
else
    loadPowerRecord = mean(Load(w_s:w_e, :));
    loadPowerRecord = loadPowerRecord / max(max(loadPowerRecord)) * 2 / 3 * LOAD + 1 / 3 * LOAD;
    windPowerRecord = mean(Wind(w_s:w_e, :));
    windPowerRecord = windPowerRecord/  max(max(windPowerRecord)) * WIND;
end

clear Load Wind loadPower windPower