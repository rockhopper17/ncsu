%%

fid = fopen('imdb.txt');  % Assumes opening for reading
if fid == -1
    disp('File open not successful')
else
    headingsLine = fgetl(fid); %read headings line
    %read all the data from the file at once
    movieData = textscan(fid,'%d %f %s %s', 'Delimiter', ':');
    
    %put together new string
    for i=1:length(movieData{1})
        newLine = [num2str(movieData{1}(i)) ' ' movieData{3}{i}];
        disp(newLine);
    end
        
    closeresult = fclose(fid);
    if closeresult == 0
        disp('File close successful')
    else
        disp('File close not successful')
    end
end
