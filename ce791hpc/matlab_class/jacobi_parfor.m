function jacobi_parfor
parpool(1);
tic;
a=0.007; b=-0.07; c=0.2;
% N = total number of segments
n=1000; nit=1000;
h0=1; hL=0.1; L=10;
h=(h0+hL)*ones(n,1)/2;
hnew=zeros(n,1);
x=zeros(n,1);
k=zeros(n,1);
ha=zeros(n,1);
dx=L/n;
parfor i=1:n
    x(i)=(i-1)*dx;
    k(i)=a*x(i)^2+b*x(i)+c;
end
h(1)=h0;
h(n)=hL;
for j=1:nit
    parfor i=2:n-1
        hnew(i)=((k(i+1)+k(i))*h(i+1)+(k(i)+k(i-1))*h(i-1))/(k(i+1)+2*k(i)+k(i-1));
    end
    parfor i=2:n-1
        h(i)=hnew(i);
    end
    h(1)=h0;
    h(n)=hL;
end
if (b^2 > 4*a*c)
    d=sqrt(b^2-4*a*c);
    b0=log((b-d)/(b+d))/d;
    bL=log((2*a*L+b-d)/(2*a*L+b+d))/d;
    
else
    d=sqrt(4*a*c-b^2);
    b0=2*atan(b/d)/d;
    bL=2*atan((2*a*L+b)/d)/d;
end
c0=(hL-h0)/(bL-b0);
c1=h0-c0*b0;
errsq=0;
parfor i=1:n
    if (b^2 > 4*a*c)
        cx=log((2*a*x(i)+b-d)/(2*a*x(i)+b+d))/d;
    else
        cx=2*atan((2*a*x(i)+b)/d)/d;
    end
    ha(i)=c0*cx+c1;
    errsq=errsq+(ha(i)-h(i))^2;
end
fprintf('Global error = %g\n',errsq/n);
toc;
mflops=9*nit*n*1e-6/toc
delete(gcp);
plot(x, h, '-g', x, ha, '-r');
legend('numerical','analytical');
xlabel('x distance (m)');
ylabel('head (m)');
return