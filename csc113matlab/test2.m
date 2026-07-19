n = 42;
seq(1) = n;
totTerms = 1;

while n ~= 1

  totTerms = totTerms + 1;

  if rem(n,2) == 0
    n = n / 2;
  else
    n = 3 * n + 1;
  end
  
  seq(totTerms) = n;

end
