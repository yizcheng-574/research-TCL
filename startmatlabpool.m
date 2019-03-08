function [] = startmatlabpool()
p = gcp('nocreate'); 
if isempty(p)
    poolsize = 0;
else
    poolsize = p.NumWorkers
end

size = feature('numcores');
if poolsize == 0
    if nargin == 0
        parpool('local');
    else
        try
            parpool('local',size);
        catch ce
            parpool;
            fail_p = gcp('nocreate');
            fail_size = fail_p.NumWorkers;
            display(ce.message);
            display(strcat('输入的size不正确，采用的默认配置size=',num2str(fail_size)));
        end
    end
else
    display('parpool start');
    if poolsize ~= size
        closematlabpool();
        startmatlabpool(size);
    end
end
% --------------------- 
% 作者：王俊杰MSE 
% 来源：CSDN 
% 原文：https://blog.csdn.net/dang_wang/article/details/35553953 
% 版权声明：本文为博主原创文章，转载请附上博文链接！