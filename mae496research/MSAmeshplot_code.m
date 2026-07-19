clear all
close all
clc

% GetXYZCoordinates(filename, point); 'point = 0 returns everything'
XYZ = GetXYZCoordinates('C:\Users\Junghyun\Google Drive\Research\Data\181030 two bond 8 cm apart\result\Scan_time.svd',0);
x = XYZ(:,1); % x coordinate of the scan point
y = XYZ(:,2); % y coordinate of the scan point

[t, amp_X, usd_X] = GetPointData('C:\Users\Junghyun\Google Drive\Research\Data\181030 two bond 8 cm apart\result\Scan_time.svd', 'Time', 'Vib X', 'Velocity', 'Samples', 0, 0);
[t, amp_Z, usd_Z] = GetPointData('C:\Users\Junghyun\Google Drive\Research\Data\181030 two bond 8 cm apart\result\Scan_time.svd', 'Time', 'Vib Z', 'Velocity', 'Samples', 0, 0);

% extracts time and amplitude of the scan points
% [x,y,usd] = GetPointData(filename, domainname, channelname, signalname, displayname, point, frame)

% filename is the path of the .pvd or .svd file

% domainname is the name of the domain, e.g. 'FFT' or 'Time'

% channelname is the name of the channel, e.g. 'Vib' or 'Ref1' or 'Vib & Ref1' or 'Vib X' or 'Vib Y' or 'Vib Z'.

% signalname is the name of the signal, e.g. 'Velocity' or 'Displacement'

% displayname is the name of the display, e.g. 'Real' or 'Magnitude' or 'Samples'. If the display name is 'Real & Imag.' 
% the data is returned as complex values.

% point is the (1-based) index of the point to get data from. If point is 0 the data of all points will be returned.
% y will contain the data of point i at row index i.

% frame is the frame number of the data. for data acquired in MultiFrame
%   mode, 0 is the averaged frame and 1-n are the other frames. For user
%   defined datasets the frame number is in the range 1-n where n is the
%   number of frames in the user defined dataset. For all other data,
%   use frame number 0.
%
% Default for returning all data points is point = 0 and frame = 0


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stitch

XYZ_S = GetXYZCoordinates('C:\Users\Junghyun\Google Drive\Research\Data\181030 two bond 8 cm apart\result\Scan_time_plate.svd',0);
x_S = XYZ_S(:,1); % x coordinate of the scan point
y_S = XYZ_S(:,2); % y coordinate of the scan point

[t, amp_Z_S, usd_Z_S] = GetPointData('C:\Users\Junghyun\Google Drive\Research\Data\181030 two bond 8 cm apart\result\Scan_time_plate.svd', 'Time', 'Vib Z', 'Velocity', 'Samples', 0, 0);
[t, amp_X_S, usd_X_S] = GetPointData('C:\Users\Junghyun\Google Drive\Research\Data\181030 two bond 8 cm apart\result\Scan_time_plate.svd', 'Time', 'Vib X', 'Velocity', 'Samples', 0, 0);

amp_Z=[amp_Z;amp_Z_S];
amp_X=[amp_X;amp_X_S];

x=[x;x_S];
y=[y;y_S];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[xq,yq] = meshgrid(-0.05:0.0001:0.05, -0.01:0.0001:0.01);
% meshgrid(x,y) returns 2-D grid coordinates based on the coordinates contained in vectors x and y.
% xq is a matrix where each row is a copy of x, and yq is a matrix where each column is a copy of y.
% The grid represented by the coordinates xq and yq has length(y) rows and length(x) columns.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % figure('units','normalized','outerposition',[0 0 1 1])
% % % loops = length(80-49+1);
% % % P(loops) = struct('cdata',[],'colormap',[]);
% % % 
% % % k=0;
% % % for m=49:80
% % %     k=k+1;
% % %     plot(t(:,:),amp_X(m,:),'LineWidth',2)
% % %     hold on
% % %     plot(t(:,:),amp_Z(m,:),'LineWidth',2)
% % %     axis([0 inf -0.01 0.01])
% % %     xlabel('m')
% % %     ylabel('m/s')
% % %     set(gca,'FontSize',40)
% % %     set(gca,'LineWidth',2)
% % % 
% % %     legend(strcat('node number = ', num2str(k)))
% % %     legend boxoff
% % % 
% % % %     P(k) = getframe(gcf);
% % % 
% % %     
% % %     hold off
% % % 
% % % end
% % % hold off
% % % 
% % % fig = figure('units','normalized','outerposition',[0 0 1 1]);
% % % vid = VideoWriter('video_waveform.avi');   % creates a VideoWriter object to write video data to an AVI file with Motion JPEG compression.
% % % vid.FrameRate=2;
% % % open(vid);                        % Open file for writing video data
% % % movie(fig,P,1);                 % plays the movie defined by a matrix whose columns are movie frames (usually produced by getframe).
% % % writeVideo(vid,P);                % Write video data to file
% % % close(vid);                       % Close file after writing video data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('units','normalized','outerposition',[0 0 1 1])
loops = length(t);
F(loops) = struct('cdata',[],'colormap',[]);
% Creating a structure to store frames for the video.

% for j=1:length(x)
%     windowSize = 10;                          
%     b=(1/windowSize)*ones(1,windowSize);      
%     a=1;                        
%     amp(j,:)=filtfilt(b,a,amp(j,:));
% end





for i=1:length(t)
    
    v = amp_X(:,i);
%     v = amp_Z(:,i);
    



    vq = griddata(x,y,v,xq,yq, 'natural');
    
    % vq = griddata(x,y,v,xq,yq) fits a surface of the form v = f(x,y) to the scattered data in the vectors (x,y,v).
    % The griddata function interpolates the surface at the query points specified by (xq,yq) and returns the interpolated values, vq. 
    % The surface always passes through the data points defined by x and y.
    
    % NOTE IMPORTANT : CANNOT plot surf/mesh/waterfall directly from the
    % raw data because the x, y coordinates are NEITHER evenly spaced nor
    % increments linearly.

    mesh(xq,yq,vq);
    caxis([-0.02 0.02])
    colormap(jet);
    hold on

    plot3(x,y,v,'k.','LineWidth',1.5,'MarkerSize',15);
    zlim([-0.02 0.02]);
    
    xlabel('m')
    ylabel('m')
    zlabel('velocity (m/s)')
    set(gca,'FontSize',20)
    set(gca,'LineWidth',2)

%     drawnow
     F(i) = getframe(gcf);
    
    % captures the current axes as it appears on the screen as a movie frame. F is a structure containing the image data.
    % getframe captures the axes at the same size that it appears on the screen. 
    % It does not capture tick labels or other content outside the axes outline.

%     pause()
    hold off


end


fig = figure('units','normalized','outerposition',[0 0 1 1]);
vid = VideoWriter('video_Z.avi');   % creates a VideoWriter object to write video data to an AVI file with Motion JPEG compression.
open(vid);                        % Open file for writing video data
movie(fig,F,1);                 % plays the movie defined by a matrix whose columns are movie frames (usually produced by getframe).
% writeVideo(vid,F);                % Write video data to file
% close(vid);                       % Close file after writing video data




    
