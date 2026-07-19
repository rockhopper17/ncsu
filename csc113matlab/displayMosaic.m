function [] = displayMosaic(pic, rows, cols)
% displays a mosaic of pictures concatenated

% Load the image file:
mat = imread(pic);
[matr,matc,matp] = size(mat);

% init new matrix
mosaic = [];
mosaicRow = [];

% create first row
for i = 1:cols
	mosaicRow = [mosaicRow mat];
end

% concatenate mosaic
for i = 1:rows
	mosaic = [mosaic;mosaicRow];
end

imshow(mosaic);

end
