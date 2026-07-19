
% create custom colormap
white = [1 1 1];
black = [0 0 0];
myColors = [white;black];  % white = 1, black = 2
colormap(myColors);

% create random 10x10 matrix of 1 or 2
yin = randi([1 2],10,10);

% swap all vaues in yin and put in yang
yang = yin;
yang(yang == 1) = 3;
yang(yang == 2) = 1;
yang(yang == 3) = 2;

% create new figure
figure;

% plot yin
subplot(1,2,1);
image(yin);
title('Yin');

% plot yang
subplot(1,2,2);
image(yang);
title('Yang');
