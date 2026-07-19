%% Mirror of the Image
clear; clc; close all;
% Read jpg image and convert to a 3D array
A = imread('NCSUTalley.jpg');
imshow(A) %figure 1
[nr,nc,np] = size(A);

%reduce storage requirements
B=uint8(zeros(nr,nc,np));
for r=1:nr %all the rows
    for c=1:nc %all the columns
        for p=1:np %pages red, green, blue
            B(r,c,p)=A(r,nc-c+1,p);
        end            
    end
end
figure %new Figure 2
imshow(B) %show the 3D array data as an image
% Write 3D array B to memory as a jpg image
imwrite(B,'NCSUTalleyMirror.jpg')
