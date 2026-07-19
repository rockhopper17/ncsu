clear; clc; close all;
%%
fid = fopen('raleighTemp.csv');
tempAtNoon = []; numDays = 0;
if fid == -1
    disp('File open not successful');
else
    headingsLine = fgetl(fid);
    while ~feof(fid)
        % Read one line into a String variable
        aLine = fgetl(fid);
        %tokenize that line based on the format & delimiter
        tokens = textscan(aLine, '%d %d %d %d %d %f', 'Delimiter', ';');
        if tokens{4} == 12
           numDays = numDays + 1;
           Days{numDays} = [int2str(tokens{2}) '/' int2str(tokens{3})];
           tempAtNoon = [tempAtNoon tokens{6}];
        end
    end
    closeresult = fclose(fid);
    if closeresult ~= 0
        disp('File close not successful');
    end
end

plot(1:numDays, tempAtNoon, 'LineWidth', 2);
set(gca,'xtick',[1:numDays],'xticklabel',Days)
title('Temperature at Noon');
ylabel('Fahrenheit');