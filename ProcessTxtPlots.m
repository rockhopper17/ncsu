function ProcessTxtPlots(fname, plotnum, veldir)

% process data saved in an ascii txt file, created by right-clicking on the analyze window
% after a single point scan run and copy pasting to notepad
% 5 header lines:
%Source File Name:	Scan
%Signal:	Time - Vib 3D Velocity - Samples

%Time	Time Signal X	Time Signal Y	Time Signal Z
%[ s ]	[ m/s ]	[ m/s ]	[ m/s ]

% file holding data copied out of PSV window after single point run
txtfile = strcat('svd/',fname);

d = importdata(txtfile,'\t',5); % load data, skip first 5 lines

t = d.data(:,1); % time values
amp_x = d.data(:,2); % x vel
amp_y = d.data(:,3); % y vel
amp_z = d.data(:,4); % z vel

% call function to calculate fourier transform
[ftformx, fpeaksx] = CalcFourierTransform(t,amp_x);
[ftformy, fpeaksy] = CalcFourierTransform(t,amp_y);
[ftformz, fpeaksz] = CalcFourierTransform(t,amp_z);

% convert frequencies to kHz and magnitues to mm/s
ftformx(:,1) = ftformx(:,1) * 1e-3; % Hz to kHz
ftformx(:,2) = ftformx(:,2) * 1e3; % m/s to mm/s
fpeaksx(:,1) = fpeaksx(:,1) * 1e-3; % Hz to kHz
fpeaksx(:,2) = fpeaksx(:,2) * 1e3; % m/s to mm/s
ftformy(:,1) = ftformy(:,1) * 1e-3; % Hz to kHz
ftformy(:,2) = ftformy(:,2) * 1e3; % m/s to mm/s
fpeaksy(:,1) = fpeaksy(:,1) * 1e-3; % Hz to kHz
fpeaksy(:,2) = fpeaksy(:,2) * 1e3; % m/s to mm/s
ftformz(:,1) = ftformz(:,1) * 1e-3; % Hz to kHz
ftformz(:,2) = ftformz(:,2) * 1e3; % m/s to mm/s
fpeaksz(:,1) = fpeaksz(:,1) * 1e-3; % Hz to kHz
fpeaksz(:,2) = fpeaksz(:,2) * 1e3; % m/s to mm/s

% plot fourier transform
figure(1);
set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
subplot(4,1,idx);
hold on; grid on;
plot(ftformx(:,1),ftformx(:,2),'DisplayName','x dir');
plot(ftformy(:,1),ftformy(:,2),'DisplayName','y dir');
plot(ftformz(:,1),ftformz(:,2),'DisplayName','z dir');
text(fpeaksx(1,1),fpeaksx(1,2), num2str(fpeaksx(1,1)));
text(fpeaksy(1,1),fpeaksy(1,2), num2str(fpeaksy(1,1)));
text(fpeaksz(1,1),fpeaksz(1,2), num2str(fpeaksz(1,1)));
title(fnames{idx});
ylabel('magnitude [mm/s]');
xlabel('frequency [kHz]');
set(gca,'FontSize',14);
legend show;

% plot raw velocities
figure(2);
set(gcf,'position',[200 200 1400 1000],'InvertHardCopy','off');
subplot(4,1,idx);
hold on; grid on;
plot(t*1e6,amp_x*1e3,'DisplayName','x vel');
plot(t*1e6,amp_y*1e3,'DisplayName','y vel');
plot(t*1e6,amp_z*1e3,'DisplayName','z vel');
title([fnames{idx} ' time-domain']);
ylabel('velocity [mm/s]');
xlabel('time [\mus]');
set(gca,'FontSize',14);
legend show;
