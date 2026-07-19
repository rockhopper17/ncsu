%%

function outv = SelectionSort(vec)
% SelectionSort sorts a vector using the selection sort
% Input: vec vector to be sorted
% Returns: outv the sorted vector
 
% Loop through the elements in the vector to end-1
for i = 1:length(vec)-1
    indexMin = i;  % stores the index of the smallest
    % Find where the smallest number is in the rest of the vector
    for j=i+1:length(vec)
        if vec(j) < vec(indexMin)
            indexMin = j;
        end
    end
    % Exchange elements
    temp = vec(i);
    vec(i) = vec(indexMin);
    vec(indexMin) = temp;
end
outv = vec;
end
