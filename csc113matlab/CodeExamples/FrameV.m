% Draw a frame on the edge of a grayscale jpeg image
%   using vectorized code
%%

close all

% Add a 50 pixels wide frame 
width = 50;
frameColor = 200;  %gray

% Read the original picture (jpeg) and show it:
P = imread('cup.jpg');
imshow(P); %display the original grayscale image
[nr,nc] = size(P); 

P(1:width, 1:nc) = frameColor*ones(width,nc); %top
P(nr-width+1:nr, 1:nc) = frameColor*ones(width,nc); %bottom
P(width+1:nr-width, 1:width) = frameColor*ones(nr-2*width,width); %left
P(width+1:nr-width, nc-width+1:nc) = frameColor*ones(nr-2*width,width); %right

%display the new image after processing, i.e. adding the frame
figure
imshow(P);

shg;