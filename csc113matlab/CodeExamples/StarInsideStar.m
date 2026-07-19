% Draw a sequence of stars inside stars
close all;  figure; 
axis equal off; hold on; 

%stars to be centered at 0,0
x=0; y=0;

%The radius of the kth star is stored in r
r = 1;  rSmall = 0.05;  k = 1;
while  r >= rSmall 
    %even stars are yellow
    if rem(k,2) == 0 
        DrawStar(x,y,r,'k')
    else %odd stars are magenta
        DrawStar(x,y,r,'r')
    end
    %reduce the radius in half
    r=r*.5;
    %count the stars
    k=k+1;
end



