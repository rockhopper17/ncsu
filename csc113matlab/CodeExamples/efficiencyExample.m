%% NCSU CSC 113 Efficient Example
% create a 1x2000000 vector where each element is pi
clear;clc;

%% 
% for loop, 
% NO preallocation
tic
A = ones(1,2000000);
for i=1:length(A)
    B(i)=A(i)*pi;
end
noPreallocTime = toc

%% 
% for loop 
% with preallocation
clear;
tic
A = ones(1,2000000);
B = zeros(1,2000000);
for i=1:length(A)
    B(i)=A(i)*pi;
end
withPreallocTime = toc


%%
% vectorized#1
clear;
tic
A = ones(1,2000000);
B = A * pi;
toc
vectorizedTime = toc;

%%
% vectorized#2
clear;
tic
A = ones(1,2000000);
A = A * pi;
toc
vectorizedTime = toc;
