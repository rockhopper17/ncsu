clear all;
clc;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BW=1588*10^-9                              % Bragg wavelength
pe=0.22                                    % photo-elastic constant


%file=dir('*.csv');                           % Find csv files in the folder list folder content
%filecount=length(file);                      % number of CSV files in the folder

% fnum=1:Remote, fnum=2:Direct
%for fnum=1:2
fnum=2;

if fnum==1
	fldr='20190619_Remote/'
else
	fldr='20190626_Direct/'
end
        
%FBGcurve=file(1).name;                      % read FBG spectrum (its file name should be written such that MATLAB reads it first)
FBGcurve=strcat(fldr,'scope_0.csv');                      % read FBG spectrum (its file name should be written such that MATLAB reads it first)
FBGdata=csvread(FBGcurve,2,0);

% powerpoint creation
%pptfname = strcat(fldr,'direct_fbg');  % powerpoint file name
%import mlreportgen.ppt.*;
%slides = Presentation(pptfname);

%figure('units','normalized','outerposition',[0 0 1 1])      % create a window for plotting
%for i=2:filecount
filecount=15
freqvals=(300:50:1000);

for i=1:filecount
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FBG raw data plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if mod(i,2)==1
        %s=file(i).name;                           
        s=strcat(fldr,'scope_',num2str(i),'.csv');                           

        m{i}=csvread(s,2,0);                    % Read data from files and put in 'm' matrix (each cell contains p x q variables)
        k=m{1,i};                               % Extract actual data from 'm' matrix and put them in matrix.

        data(:,i)=k(1:1000,2:2);                % Extract only voltage value (before excitation) and put in in 'average' matrix
        time(:,:)=k(1:1000,1:1);

        meanvalue(:,i)=mean(mean(data(:,i),2),1);     
        centeredgraph(:,i)=(meanvalue(:,i)-data(:,i));

        [c index]= min(abs(FBGdata(1:250,2)-meanvalue(:,i) )); 
        %closest value to the mean value to find the edge slope location
        %V/s, Linear regression

        X = [ones(length(FBGdata(index-10:index+10,1:1)),1) FBGdata(index-10:index+10,1:1)];
        slope_VS=X\FBGdata(index-10:index+10,2:2);
        slope(i,1)=abs(slope_VS(2,1))*(188/10^-9);  %V/s * s/nm

        windowSize = 1;                             % filter filter (1 is no filtering?)
        b=(1/windowSize)*ones(1,windowSize) ;       % Define number of point that you want to use for rational transfer function
        a=1;                                        % Amplitude variable, usually 1
        FilteredGraph(:,i)=filtfilt(b,a,centeredgraph(:,i)/(slope(i,1)*BW*(1-pe)));      
        % Actual filtering function. Original values ('GraphMean' ) to filtered values ( 'FilteredGraph' )

		subplot(8,2,i)
        %hold on
		%figure;
		plot(time(:,:)*1000000,FilteredGraph(:,i)*1000000,'k-', 'LineWidth',2);
		title(sprintf('%d kHz',freqvals(i)));
		xlabel('');
		ylabel('\mu\epsilon');
		%set(gca,'FontSize',40);
		set(gca,'LineWidth',1.5);
		set(gca,'XTickLabel',[]);
		%axis([65 95 -0.7 0.7]); % remote
		axis([25 75 -0.7 0.7]); % direct
		grid on
		box on
		
		%if i==filecount
			set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');
			xlabel('\mus');
		%end
        
		%imgname = sprintf('fbg_%d.jpg',freqvals(i));
		%saveas(gcf,imgname);
		%img = Picture(imgname);
		%%img.Width = '13.33in';
		%img.Width = '10.5in';
		%img.Height = '7.5in';
		%%img.Width = '1400px';
		%%img.Height = '1000px';
		%slide = add(slides,'Blank');
		%add(slide,img);

%end % end 100 kHz intervals

end % end freqvals file loop

sgtitle('Direct Bond');
%close(slides);

% save peak to peak value
%p2p(fnum,:) = (max(FilteredGraph) - min(FilteredGraph))*1000000;

%end % end fnum (remote or direct)

%plot(freqvals,p2p(1,:),'r.','MarkerSize',25,'DisplayName','Remote');
%hold on;
%grid on;
%plot(freqvals,p2p(2,:),'b.','MarkerSize',25,'DisplayName','Direct');
%ylabel('peak to peak [\mu\epsilon]');
%xlabel('frequency [kHz]');
%title('Calculated strain vs excitation frequency for direct and remote bonded fiber');
%set(gca,'FontSize',18);
%legend show;
%set(gca,'xdir','reverse');

%figure;
%for i=1:2:15
	%subplot(8,1,ceil(i/2))
	%plot(time(:,:)*1000000,FilteredGraph(:,i)*1000000,'k-', 'LineWidth',2);
	%%title(sprintf('%d kHz',freqvals(i)));
	%xlabel('');
	%ylabel('\mu\epsilon');
	%%set(gca,'FontSize',40);
	%set(gca,'LineWidth',1.5);
	%set(gca,'XTickLabel',[]);
	%%axis([60 100 -0.7 0.7]); % remote
	%%axis([25 75 -0.7 0.7]); % direct
	%grid on
	%box on
	%set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');
	%xlabel('\mus');
%end

