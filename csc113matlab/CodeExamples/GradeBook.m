clear;clc;
%%

[numbers,text,all] = xlsread('GradeBook.xlsx'); %read in the data
[rows,columns] = size(all); 


%% 
% Using Cell Array
disp('Solution by Using Cell Array');

[numbers,text,all] = xlsread('GradeBook.xlsx'); %read in the data
studentData = all(2:end,:); %get rid of the head row
test1Scores = [ studentData{:,5} ]; %extract the Test 1 scores
avgTest1 = mean(test1Scores); % calculate the average on Test 1
numStudents = length(test1Scores); % determine the number of students

fprintf('Test 1 Scores, above average of %.2f%% are:\n', avgTest1);
for i=1:numStudents
    if ( test1Scores(i) > avgTest1)
        %get first,last name, score from the Cell Array
        fprintf('%s %s %d%%\n', studentData{i,1}, studentData{i,2}, studentData{i,5});
    end
end
fprintf('\n');

%% Solution using a Structure Array

disp('Solution by Using Structure Array');
[numStudents, numFields ] = size( all(2:end,:) ); 

%get the first row to create the fields of the Structure
fields = all(1,:);
%create the Structure array
for i=numStudents:-1:1
    Students(i) = cell2struct( all(i+1,:), fields, 2);
end

%calculate the average on test1
avgTest1 = mean([Students.Test1]);

fprintf('Test 1 Scores, above average of %.2f%% are:\n', avgTest1);
for i=1:numStudents
    if ( Students(i).Test1 > avgTest1)
        fprintf('%s %s %d%%\n', Students(i).FirstName, Students(i).LastName, Students(i).Test1);
    end
end







