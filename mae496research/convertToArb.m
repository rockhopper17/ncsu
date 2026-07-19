% The Matlab function 
% 
% convertToArb(data,samplerate,fName) function allows you to turn vector /
% array data into a waveform format that can be loaded onto Agilent's 3352xA
% function / arbitrary waveform generators (33521A one channel and 33522A
% two channel)
% 
% This function converts a row or colunm vector into a 3352xA generator 
% format .arb file (a waveform file that can be loaded onto the 3352xA). 
% The input vector should contain values expressed in Volts not exeding the
% output limit of the generator.
% 
% input argument 'data' is the vector containing the waveform points
% 
% samplerate is the sample rate you would like to generate the values from
% the 'data' vector. The total time of your waveform is equal to:
% samplerate * numberofpoints in the file
% 
% fName is the name you want to assign to the .arb file that is created, for
% instance "myArb.arb"
% 
% After the conversion the function outputs a .arb file it will be stored in
% the current Matlab directory. You can then transfer the waveform to a
% 3352xA using a USB memory stick. 
% 
% If you have any questions email me at
% neil(underscore)forcier(at)agilent(dot)com

function convertToArb(data,samplerate,fName)

% samplerate=1E-8
%check if data is row vector, if so convert to column
if isrow(data)
    data = data';
end
    
%data=importdata(filetoread1);
numberofpoints = length(data);

%Get max and min values from waveform data
data_min=min(data);
data_max=max(data);

%range has to be the maximum absolute value between data_min and data_max
range=abs(data_max);
if(abs(data_min)>abs(data_max))
    range=abs(data_min);
end
    
%Data Conversion from V to DAC levels
data_conv=round(data*32767/range);

fName = [fName '.arb']; %add file extension to file name

%File creation and formatting
fid = fopen(fName, 'w');
fprintf(fid,'%s\r\n','File Format:1.10');
fprintf(fid,'%s\r\n','Channel Count:1');
fprintf(fid,'%s\r\n','Column Char:TAB');
fprintf(fid,'%s%d\r\n','Sample Rate:',samplerate);
fprintf(fid,'%s%6.4f\r\n','High Level:',data_max(1));
fprintf(fid,'%s%6.4f\r\n','Low Level:',data_min(1));
fprintf(fid,'%s\r\n','Data Type:"Short"');
fprintf(fid,'%s\r\n','Filter:"OFF"');
fprintf(fid,'%s%d\r\n','Data Points:',numberofpoints);
fprintf(fid,'%s\r\n','Data:');
%Write data to file and close it
fprintf(fid,'%d\r\n',data_conv);
fclose(fid);

