% 单层\单次出清TC和次梯度法比较
clc; clear;
addPath;
global I ratioIVA ratioFFA
constantInit;
isMultiDay = 0;
isHierarchical = 1;
isGradient = 1;
isAdmm = 1; %% TODO
ratioFFA = 0.7;
ratioIVA = 2;
RATIO = 10;
EV = 5 * RATIO;
FFA = 0 * RATIO;
IVA = 10 * RATIO;
LOAD = 20 * RATIO;
WIND = 10 * RATIO;
CAPACITY = 35 * RATIO;


[EVdata, EVdata_mile, EVdata_capacity, PN, TCLdata_T, TCLdata_C, TCLdata_R, FFAdata_PN, IVAdata_PN, TCLdata_Pmin, TCLdata_initT ] = TCLEVinit (19.82, 1.92, 8.56 + 24, 2, EV, IVA, FFA);

windPowerRecord = Wind(1, 1 + 48: 96+ 48)';
windPowerRecord = windPowerRecord / max(windPowerRecord) * WIND;
maxLoad = max(max(Load));
loadPowerRecord = Load(1, 1+ 48: 96+ 48)';
loadPowerRecord = loadPowerRecord / max(loadPowerRecord) * LOAD;

startmatlabpool();

if isHierarchical == 1
    tic;
    trans = distributionTrans(...
      EV, FFA, IVA, CAPACITY, windPowerRecord, loadPowerRecord, gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
      EVdata, EVdata_mile, EVdata_capacity, PN,...
      TCLdata_T, TCLdata_R, TCLdata_C, FFAdata_PN, IVAdata_PN, TCLdata_Pmin, TCLdata_initT, ...
      p1, q1, p2, q2,...
      d_theta_h1, d_theta_h2, theta_o, yrs, eta...
    );
    for t_index = 1 :I
        time = (t_index - 1) * T + 12;
        bidCurve = trans.bid(t_index, time);
        trans.clear(gridPriceRecord(t_index), t_index, time);
    end
    trans.temperatureNormalize();
    trans.calculateCost();
    toc;
end

if isGradient == 1
    for isPrecision = 0
        maxIteration = 100;
        iteration = 1;
        epsi = 1e-2 * CAPACITY;
        lambda_new = zeros(I, 1);
        lambda_old = ones(I, 1);
        lambdaRecord = zeros(maxIteration, I);
        fvalRecord = zeros(maxIteration, 1);
        balanceDemand_new = 100;
        balanceDemand_old = zeros(I, 1);
        step = 0.01 / RATIO;
        transG = distributionTrans(...
          EV, FFA, IVA, CAPACITY, windPowerRecord, loadPowerRecord, gridPriceRecord24, sigmaRecord, ToutRecord, mkt,...
          EVdata, EVdata_mile, EVdata_capacity, PN,...
          TCLdata_T, TCLdata_R, TCLdata_C, FFAdata_PN, IVAdata_PN, TCLdata_Pmin, TCLdata_initT, ...
          p1, q1, p2, q2,...
          d_theta_h1, d_theta_h2, theta_o, yrs, eta...
        );
        while iteration < maxIteration && max(abs(lambda_new - lambda_old)) > 0.001 && max(abs(balanceDemand_new)) > epsi
            lambda_old = lambda_new;
            [balanceDemand_new, fval] = transG.optimizaAccordingToPrice(lambda_new, 0, isPrecision);
            lambda_new = lambda_new + balanceDemand_new * step / iteration;
            % Barzilai-Borwen方法 适用于梯度法，但不保证收敛。可与line search配合适用
            % step = ((lambda_new - lambda_old )' * (lambda_new - lambda_old)) / ((lambda_new - lambda_old )' * (balanceDemand_new - balanceDemand_old)) ;        
            balanceDemand_old = balanceDemand_new;
            fvalRecord(iteration) = fval;
            lambdaRecord(iteration, :) = lambda_new';
            iteration = iteration + 1;
        end
        transG.optimizaAccordingToPrice((lambda_new + lambda_old) /2, 1, isPrecision);
        transG.temperatureNormalize();
        transG.calculateCost();
        if isPrecision == 1
            transG_precision = transG;
            clear transG;
        end
    end
end

closematlabpool();
clearvars -except trans transG transG_precision fvalRecord lambdaRecord iteration balanceDemand_new lambda_new
% save ('../data/0412/subgradient7.mat')
