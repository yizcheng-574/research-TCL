
startmatlabpool();

clc; clear;
main_hierarchy;
save 'C:\Users\Administrator\iCloudDrive\Documents\TCL\data\0308\hierarchy'

closematlabpool();
% isAging  isEVflex  isTCLflex = 1;
modeType = [
    0, 1, 0;
    0, 1, 1;
    1, 1, 1;
];
startmatlabpool();
for mode = 1:3
    clearvars -except modeType mode
    isAging = modeType(mode, 1);
    isEVflex = modeType(mode,2);
    isTCLflex = modeType(mode, 3);
    main_multidays;
    if mode == 1
        save 'C:\Users\Administrator\iCloudDrive\Documents\TCL\data\0308\mode1'
    elseif mode == 2
       save 'C:\Users\Administrator\iCloudDrive\Documents\TCL\data\0308\mode2'
    else
       save 'C:\Users\Administrator\iCloudDrive\Documents\TCL\data\0308\mode3'
    end
end
% clc; clear;
% priceDriven;
% save 'C:\Users\Administrator\iCloudDrive\Documents\TCL\data\0308\PD'
closematlabpool();