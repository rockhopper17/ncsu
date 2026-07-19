%%

function out = myOnes(varargin)
% Creates a 2D matrix of ones, like ones()
out=[];
if(nargin == 1) %one input, square matrix
    m = varargin{1};
    for r=1:m        
        for c=1:m
            out(r,c)=1;
        end
    end
elseif (nargin == 2)%two inputs, m x n matrix
    m = varargin{1};
    n = varargin{2};
    for r=1:m
        for c=1:n
            out(r,c)=1;
        end
    end
else
    disp('Invalid Number of Arguments');
end
end


% another way of definining it, first argument is m
% function out = myOnes(m, varargin)
% % Creates a 2D matrix of ones, like ones()
% out=[];
% if(nargin == 1) %one input, square matrix
%     for r=1:m
%         for c=1:m
%             out(r,c)=1;
%         end
%     end
% elseif (nargin == 2) %two inputs, mxn matrix
%     n = varargin{1};
%     for r=1:m
%         for c=1:n
%             out(r,c)=1;
%         end
%     end
% else
%     disp('Invalid Number of Arguments');
% end

