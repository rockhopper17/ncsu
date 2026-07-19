close all;
%%
%read in the image
redSkyIm = imread('redSky.jpg');
%display the red sky image
image(redSkyIm) 
% determine the RGB colors of the sky
% at row 400 of the image
row = 400; 
red = redSkyIm(row, :, 1);
green = redSkyIm(row, :, 2);
blue = redSkyIm(row, :, 3);
figure
plot (red, 'r');
hold on;
plot (green, 'g');
plot (blue, 'b');
% create the new image
blueSkyIm = redSkyIm;
% change the sky to more blue
% by removing the red component
blueSkyIm(1:620, :, 1) = 50;
figure
image(blueSkyIm);
imwrite(blueSkyIm, 'blueSky.jpg');



%%


