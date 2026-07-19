%%
clear; clc; 
fid = fopen('imdb.txt');  
if fid == -1
    disp('File open not successful')
else
    headingsLine = fgetl(fid);
    while ~feof(fid)
        % Read one line into a String variable
        aLine = fgetl(fid);
        %tokenize that line based on the format & delimiter
        tokens = textscan(aLine, '%d %f %s %d', 'Delimiter', ':');
        %concatenate the new line
        newLine = [num2str(tokens{1}), ' ' , tokens{3}{1}];
        disp(newLine);
    end
    closeresult = fclose(fid);
    if closeresult == 0
        disp('File close successful')
    else
        disp('File close not successful')
    end
end
