%%

function [V] = InsertionSort(V)
% InsertionSort sorts V in ascending order using insertion sort algorithm
% Input:  V is a column n-vector to be sorted
% Return: Vs is the sorted vector

n = length(V);
for i = 2:n
    V(1:i) = Insert(V(1:i));
end

    function [V] = Insert(V)
      % Pre:  V is a column m-vector with V(1:m-1) sorted.
      % Post: V is sorted in assending order by applying the insert process
        
        k = length(V)-1;
        while k>=1 && V(k)>V(k+1)
            %swap
            t = V(k+1);
            V(k+1) = V(k);
            V(k) = t;            
            k = k-1;
        end
    end
end


