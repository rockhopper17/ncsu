%% Mirror of the Image
clear; clc; close all;

% Read jpg image and convert to a 3D array
A = imread('NCSUTalley.jpg');
imshow(A)
[nr,nc,np] = size(A);

%reduce storage requirements
B=uint8(zeros(nr,nc,np));
%vectorize the code
for c=1:nc
    B(:,c,:)=A(:,nc-c+1,:);
end    

figure
imshow(B) %show the 3D array data as an image
% Write 3D array B to memory as a jpg image
imwrite(B,'NCSUTalleyMirror.jpg')


