myvals = whos;

for n = 1:length(myvals)
	myvals(n).name
	eval(myvals(n).name)
end
