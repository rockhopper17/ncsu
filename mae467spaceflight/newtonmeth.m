F = 1;
e = 1.2;
Mh = .7621;
ratio = 1;

while (abs(ratio) > 1e-6)
	f = e * sinh(F) - F - Mh;
	fp = e * cosh(F) - 1;
	ratio = f/fp
	F = F - ratio
end
