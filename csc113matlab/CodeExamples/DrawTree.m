clear; clc;close all;

%white, green, blue , brown
mycolors=[1 1 1; 0 0.5 0; 0 0 1;  0.3 0 0];
colormap(mycolors)

%start the picture, white background
whole = ones(25,25);
%the sky is blue, index 3 of colormap
whole(1:7, :) = 3;
%the grass is green, index 2 of colormap
whole(23:end, :) = 2;
%the tree_trunk is brown, index 4 of colormap
whole(15:22,12:15) = 4;
%the tree top is green, index 2 of colormap
cols = 13:14;
for i = 10:14
    whole(i,cols) = 2;
    cols = [cols(1)-1 cols cols(end)+1];
end

%draw the figure, whole matrix contains indexes into the colormap
image(whole)

shg