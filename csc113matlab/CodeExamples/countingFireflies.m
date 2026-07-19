%%

function curTotNumFireflies = countingFireflies( n )
%counts a total number of fireflies sighted
%Input: n, new sightings of fireflies
%Returns: the total number of fireflies sighted
persistent totNumFireflies;

if isempty(totNumFireflies)
    totNumFireflies = n;
else
    totNumFireflies = totNumFireflies + n;
end
curTotNumFireflies = totNumFireflies;
end

