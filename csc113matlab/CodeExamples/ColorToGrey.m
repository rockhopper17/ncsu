%% Image to Black and white --  weighted average

A = imread('LawSchool.jpg');
[nr,nc,np] = size(A);
B = uint8(zeros(nr,nc)); %only 2D needed
B = 0.299*A(:,:,1) + 0.587*A(:,:,2) + 0.114*A(:,:,3);
imshow(B); %show the 3D array data as an image
imwrite(B,'LawSchoolBW.jpg')
shg


% average does NOT work
% A = imread('LawSchool.jpg');
% [nr,nc,np] = size(A);
% B = uint8(zeros(nr,nc)); %only 2D needed
% B = (A(:,:,1) + A(:,:,2) + A(:,:,3))/3;
% imshow(B); %show the 3D array data as an image
% imwrite(B,'LawSchoolBW.jpg')
% shg