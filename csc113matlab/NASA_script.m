%% This file may only be used for academic purposes!

% The main purpose of this thing is to take a look at a gigantic data set of 
% trajectory data (2001 files, each one with about 105,000 rows) and extract 
% some slosh parameters from the oxidizer tank over the course of ascent from
% liftoff to MECO. Specifically, it calculates the maximum slosh wave heights 
% (taken from NASA supercomputers) for a user-entered tank segment width over 
% the course of flight and does some statistical analysis on it. It hasn’t been 
% optimized at all so I’m sure there are faster ways of doing things.

%Last updated 4/10/2017 by D. Yaghoubi


%NOTE: interp.m and combine.m MUST be run before running this script in
%order to generate final_slosh.asc.#

clear;
numfiles = 2001;            % Number of MC runs examined
%Column header for use later on
key=(cellstr(['Time            ';'Liquid Level(in)';'Wave Height (in)';'Frequency (Hz)  ';'Index           ']))';
segment_width = 0.5;        %LOX tank width examined over course of tank height

for k = 1:numfiles
  filename = sprintf('final_slosh.asc.%d', k-1);
  sloshdata = importdata(filename);
  disp(['Case #', num2str(k-1)])
  numrows=size((sloshdata),1);

  T_Liq{k}.Wave=zeros(size((sloshdata),1),5);           %Allocate array
  T_Liq{k}.Wave(2:numrows+1,1)=sloshdata(:,1);          %Time (s)
  T_Liq{k}.Wave(2:numrows+1,2)=(sloshdata(:,2))*12;     %Liquid Level (in., from bottom apex)
  T_Liq{k}.Wave(2:numrows+1,3)=sloshdata(:,3);          %Wave Height (in)
  T_Liq{k}.Wave(2:numrows+1,4)=sloshdata(:,4);          %Slosh Frequency (Hz)
  
  %Calculate total number of segments to divide tank into
  num_segments = 1+ (round(T_Liq{k}.Wave(2,2))-round(T_Liq{k}.Wave(numrows+1,2)))/segment_width;

  %Calculate which vehicle stringer to place each row of data
  %Also, determine whether or to round liquid level up or down
  if round(T_Liq{k}.Wave(2,2)) < T_Liq{k}.Wave(2,2)              
        liqlev_upper_bound=round(T_Liq{k}.Wave(2,2))+segment_width; 
  else
        liqlev_upper_bound=round(T_Liq{k}.Wave(2,2)); 
  end
        liqlev_lower_bound=liqlev_upper_bound-segment_width;
  
  disp(['     Indexing increments...'])
  %Determine which increment number the associated liquid level belongs to.
  %Increments (incr) starts at 1. If the input value is between the initial
  %upper bound and the upper bound - segment width, the liquid level is in
  %that increment. Increase the incr index, reassign the lower bound as the
  %new upper bound, rinse and repeat for the entire case.
  incr=1;
  for j=1:num_segments
      for i=2:numrows+1
          if T_Liq{k}.Wave(i,2) <= liqlev_upper_bound && T_Liq{k}.Wave(i,2) > liqlev_lower_bound
              T_Liq{k}.Wave(i,5)=incr;      %Increment number stored in 5th column.
          end
      end
      liqlev_upper_bound=liqlev_upper_bound-segment_width;
      liqlev_lower_bound=liqlev_upper_bound-segment_width;
      disp(['Case #', num2str(k-1),', Increment #', num2str(incr)]) %Status update to terminal window
      incr=incr+1;
  end

  %Aliasing filter
  if T_Liq{k}.Wave(end,5) == 0;
      T_Liq{k}.Wave(end,5) = incr;
  end

  %Once increments have been determined, find the max wave height within
  %each increment
  disp(['     Finding increment maximums...'])
  for i=1:T_Liq{k}.Wave(end,5)
      h=1;
      clear idx_array
      clear freq_array
      for j=2:numrows+1
          if T_Liq{k}.Wave(j,5) == i
            idx_array(h)=T_Liq{k}.Wave(j,3);    %idx_array exists only for each increment
            freq_array(h)=T_Liq{k}.Wave(j,4);   %frequency at max wave height
            h=h+1;
          end
      end
      max_array(k,i)=max(idx_array);            %increment x MC runs, ~1118x2001
      [actualmax,max_idx]=max(idx_array);
      freq_at_max(k,i)=freq_array(max_idx);     %Wherever this max is, this
                                                %is where the Freq needs to
                                                %be pulled from                                         
      disp(['Case #', num2str(k-1),', Increment Max# ', num2str(i)])    %Status update to terminal window
  end
  
  %Switch to text for consistency with 'key' variable
  T_Liq{k}.Wave = num2cell(T_Liq{k}.Wave);
  T_Liq{k}.Wave(1,:) = key;

end
%%
%Liquid levels start at different heights based upon trajectory. Bottom
%level is the same however. Shift bottom of tank data to be aligned between
%cases rather than top.
%
%NOTE: IF BOTH BOTTOM AND TOP LIQUID LEVELS DO NOT ALIGN BETWEEN CASES,
%RUN shift.m INSTEAD OF THIS SECTION!!!!!!

%Shift max array
for i=1:2001;
    for j=1:1148;
        if max_array_final(i,j)==0;
            max_array_final(i,:)=circshift(max_array_final(i,:), [0, 1]);
        end
    end
end

%Shift frequency array
for i=1:2001;
    for j=1:1148;
        if freq_max_final(i,j)==0;
            freq_max_final(i,:)=circshift(freq_max_final(i,:), [0, 1]);
        end
    end
end

%%
%Determine sort index for statistics determination
[max_array_final_sorted,sort_idx]=sort(max_array_final);

%Apply sort index to frequency array
for i = 1:2001;
    for j=1:1148;
        freq_max_final_sorted(i,j)=freq_max_final(sort_idx(i,j),j);
    end
end
  
 %three_sigma_index = round(0.99865*numfiles);  %actual three sigma value
 three_sigma_index = round(0.977*numfiles);     %two sigma. Leave the variable name alone for now.
 
 three_sigma_max_array = max_array_final_sorted(three_sigma_index,:);
 three_sigma_freq_array = freq_max_final_sorted(three_sigma_index,:);
 final_three_sigma(1,:) = three_sigma_max_array;
 final_three_sigma(2,:) = three_sigma_freq_array;

%clear i j k key numfiles numrows numfiles num_segments sloshdata filename h incr liqlev_lower_bound liqlev_upper_bound ;
save('max_array_final.mat','max_array')
save('freq_array_final.mat','freq_at_max')
disp('Finished!')




