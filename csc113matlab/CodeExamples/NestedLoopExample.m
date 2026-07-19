clear;clc;

for line=1:5 %five lines
    for j=1:5-line %dots        
        fprintf('.');
    end
    fprintf('%d',line+4); %number
    for k=1:line-1 %asterisks       
        fprintf('*');
    end
    fprintf('\n'); %next line
end
