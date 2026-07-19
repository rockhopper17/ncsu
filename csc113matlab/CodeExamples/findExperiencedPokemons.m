%%
clear; clc;
MIN_BASE_EXPERIENCE = 350;
%get the input and output files
fid = fopen('pokemons.csv');
if fid == -1
    disp('Input file open NOT successful');
else
    fOut = fopen('expriencedPokemons.csv', 'w');
    if fOut == -1
        disp('Output file open NOT successful');
    end
end

%start processing the intput file
if fid~=-1 && fOut~=-1
    headingsLine = fgetl(fid);
    numPokemons = 0;
    numExperiencedPokemons = 0;
    while ~feof(fid)
        numPokemons = numPokemons + 1;
        %Read one line into a String variable
        aLine = fgetl(fid);
        %tokenize that line based on the format & delimiter
        tokens = textscan(aLine, '%s %d %d %d', 'Delimiter', ',');
        %the base experience
        baseExperience = tokens{4};
        if baseExperience > MIN_BASE_EXPERIENCE
            numExperiencedPokemons = numExperiencedPokemons + 1;
            %concatenate the new line, pokemon name + experience
            processedLine = [tokens{1}{1} ',' num2str(baseExperience)];
            fprintf(fOut, '%s\n',processedLine);
        end
    end
    fprintf('%d out of %d pokemons have experience more than %d \n', ...
        numExperiencedPokemons,numPokemons, MIN_BASE_EXPERIENCE );
end

%close all the files
closeresult = fclose('all');
if closeresult == 0
    disp('File close successful');
else
    disp('One of the files did not close successfully');
end


