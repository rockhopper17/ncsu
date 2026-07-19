        pi = 4.0*atan(1.0)
        strength = 
        uinf = 
        rcyl= 
        dist = 

        xmax = 2.0
        ymax = 1.0
        xca = 
        xcb = xca + dist
        yca = 0.5
        ycb = 0.5

        N = 101;
        M = 201;
        xmax = 2.0;
        ymax = 1.0;
        dx = xmax/(M-1);
        dy = ymax/(N-1);

        for j=1:N
        for i=1:M
          x(i,j) = (i-1)*dx;
          y(i,j) = (j-1)*dy;

c --- uniform flow
          psi_1 = uinf*(y(i,j)-yca);
          u_1 = uinf;
          v_1 = 0.0;
          umag1 = sqrt(u_1^2+v_1^2);

c --- source at xca,yca
          rad2a = (x(i,j)-xca)^2 + (y(i,j)-yca)^2 + 1e-6;
          psi_2 = strength*atan2(y(i,j)-yca,x(i,j)-xca);
          u_2 = strength*(x(i,j)-xca)/(rad2a);
          v_2 = strength*(y(i,j)-yca)/(rad2a);
          umag2 = sqrt(u_2^2+v_2^2);

c --- sink at xcb,ycb
          rad2b = (x(i,j)-xcb)^2 + (y(i,j)-ycb)^2 + 1e-6;
          psi_3 = -strength*atan2(y(i,j)-ycb,x(i,j)-xcb);
          u_3 = -strength*(x(i,j)-xcb)/(rad2b);
          v_3 = -strength*(y(i,j)-ycb)/(rad2b);
          umag3 = sqrt(u_3^2+v_3^2);

c --- Rankine half-oval
          psi_4 = psi_1 + psi_2;
          u_4 = u_1 + u_2;
          v_4 = v_1 + v_2;
          umag4 = sqrt(u_4^2+v_4^2);

c --- Rankine full-oval
          psi_5 = psi_4 + psi_3;
          u_5 = u_4 + u_3;
          v_5 = v_4 + v_3;
          umag5 = sqrt(u_5^2+v_5^2);

c --- decide which to plot         
          psiplot(i,j) = psi_5;
          vplot(i,j) = umag5;

        end
        end

c --- plot using contourf; if you can plot vplot as a color flood and psiplot as black lines,
that would be best - not sure how to do this with matlab. 

      figure
      contourf(x,y,psiplot,50)

