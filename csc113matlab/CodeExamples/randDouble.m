function [num] = randDouble(lo, hi)
% randDouble generates a random number in a specified range 
%   Inputs:  lo - the beginning of the range
%            hi - the end of the range
%   Returns: num - the random number in the range

num= rand*(hi-lo) + lo;