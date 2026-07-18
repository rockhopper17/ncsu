syms x t a b c d

f = (x+a)*(x+b)*(x+c)*(x+d)
f1 = diff(f)
f1exp = expand(f1)
f1a = collect(f1exp)

