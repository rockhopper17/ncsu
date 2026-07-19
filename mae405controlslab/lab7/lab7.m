close all; clear all; clc;

%d=load('data/run1_weighted_motoroff');
%d=load('data/run2_unweighted_motoroff');
%d=load('data/run3_weighted_motoron');
%d=load('data/run4_unweighted_motoron');
%d=load('data/run9_weighted_1_2');
%d=load('data/run23_weighted_1_9');
d=load('data/run33_weighted_2_4');
x=d(:,1);
y=d(:,2);
%yoff = y(end); % find 0 line for amplitude
yoff = (max(y)+min(y))/2; % find 0 line for amplitude, sine sweep
y = y-yoff;

figure;
plot(x,y,'b-');
grid on;
ylabel('amplitude');
xlabel('time');
%title('Motor Unconnected With Weights');
%title('Motor Unconnected Without Weights');
%title('Motor Unpowered With Weights');
%title('Motor With Weights at 1.2 Hz');
title('Motor With Weights at 1.9 Hz');
title('Motor With Weights at 2.4 Hz');
set(gca,'FontSize',16);

if false

% load data
files = dir('data/*_weighted*');
%files = dir('data/*_unweighted*');
%files(ismember( {files.name},{'.','..','.DS_Store'})) = [];

for idx = 1:numel(files)
	fname = files(idx).name;
	data = load(fullfile(files(idx).folder, fname));

	freq = str2num(fname(end-2)) + 0.1*str2num(fname(end));
	peak2peak = max(data(:,2)) - min(data(:,2));

	plot(freq,peak2peak,'bo','LineWidth',2);
	hold on; grid on;
end

ylabel('peak to peak');
xlabel('frequency (Hz)');
title('Sine Sweep With Weights');
%title('Sine Sweep Without Weights');
set(gca,'FontSize',16);

end
