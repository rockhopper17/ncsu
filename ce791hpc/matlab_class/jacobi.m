function jacobi
parpool(2);
tic;
spmd
    a=0.007; b=-0.07; c=0.2;
    % N = total number of segments
    N=1000; nit=100000;
    % n = number of grid points per processor = total number of interior grid
    % points distributed across processors plus two ghost points
    % n = ((N-1)/nprocs)+2
    n=floor((N-1)/numlabs)+2;
    % allocate remaining grid points to the lower processor ids
    nr=rem(N-1,numlabs);
    if (labindex <= nr)
        n=n+1;
    end
    left=labindex-1; right=labindex+1;
    h0=1; hL=0.1; L=10;
    h=(h0+hL)*ones(n,1)/2;
    hnew=zeros(n,1);
    x=zeros(n,1);
    k=zeros(n,1);
    ha=zeros(n,1);
    dx=L/N;
    for i=1:n
        x(i)=((labindex-1)*n+i-1)*dx;
        k(i)=a*x(i)^2+b*x(i)+c;
    end
    if (labindex == 1)
        h(1)=h0;
    end
    if (labindex == numlabs)
        h(n)=hL;
    end
    for j=1:nit
        if (labindex < numlabs)
            % send to right neighbor your interior right grid point
            labSend(h(n-1),right,1);
            % receive from right neighbor their left grid point
            h(n)=labReceive(right,2);
        end
        if (labindex > 1)
            labSend(h(2),left,2);
            h(1)=labReceive(left,1);
        end
        for i=2:n-1
            hnew(i)=((k(i+1)+k(i))*h(i+1)+(k(i)+k(i-1))*h(i-1))/(k(i+1)+2*k(i)+k(i-1));
        end
        for i=2:n-1
            h(i)=hnew(i);
        end
        if (labindex == 1)
            h(1)=h0;
        end
        if (labindex == numlabs)
            h(n)=hL;
        end
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
    for i=2:n-1
        if (b^2 > 4*a*c)
            cx=log((2*a*x(i)+b-d)/(2*a*x(i)+b+d))/d;
        else
            cx=2*atan((2*a*x(i)+b)/d)/d;
        end
        ha(i)=c0*cx+c1;
        errsq=errsq+(ha(i)-h(i))^2;
    end
    error=sqrt(gplus(errsq))/N;
    hg=gcat(h(2:n-1),1,1);
    xg=gcat(x(2:n-1),1,1);
    hag=gcat(ha(2:n-1),1,1);
    if (labindex == 1)
        fprintf('global error = %g\n',error);
    end
end
hf=hg{1};
xf=xg{1};
haf=hag{1};
toc;
mflops=9*nit{1}*N{1}*1e-6/toc;
fprintf('Mflops = %g\n',mflops);
plot(xf, hf, '-g', xf, haf, '-r');
legend('numerical','analytical');
xlabel('x distance (m)');
ylabel('head (m)');
delete(gcp);
return
