
      pi = 4.0*atan(1.0)

      inputs:  uinf (free-stream velocity)
               alpha (angle of attack; degrees)

      alpha = alpha*pi/180.0

c ----- import panel coordinates (x, y (1:npanel+1))
c ----- Note:  ordering must be from bottom trailing edge to top trailing edge (clockwise)

      for j=1:npanel
       ds(j) = sqrt((x(j+1)-x(j))^2 + (y(j+1)-y(j))^2); ! panel length
       tnx(j) = (x(j+1)-x(j))/ds(j);  ! x component of panel tangent = cos(theta_j)
       tny(j) = (y(j+1)-y(j))/ds(j);  ! y component of panel tangent = sin(theta_j)
       xnx(j) = -tny(j);              ! x component of panel normal
       xny(j) =  tnx(j);              ! y component of panel normal
      end

c ---- apply V dot n = 0.0 for every panel

      for i=1:npanel
        xi = 0.5*(x(i)+x(i+1));
        yi = 0.5*(y(i)+y(i+1));
        sumn = 0.0;
        sumt = 0.0;
        for j=1:npanel
         xj = x(j);
         yj = y(j);
         xip =  tnx(j)*(xi-xj) + tny(j)*(yi-yj);  !x* location in panel coord. system          
         yip = -tny(j)*(xi-xj) + tnx(j)*(yi-yj);  !y* location in panel coord. system
         upv = 0.5/pi*(atan2(yip,xip-ds(j))-atan2(yip,xip)); !x* velocity in panel coord. system.
         vpv = 0.25/pi*log(((xip-ds(j))^2 + yip^2)/(xip^2 + yip^2)); !y* velocity in panel coord. system
         if (i==j) 
         upv = 0.5;
         vpv = 0.0;
         end
         uv = tnx(j)*upv - tny(j)*vpv;  !x component of induced velocity in Cart. system
         vv = tny(j)*upv + tnx(j)*vpv;  !y component of induced velocity in Cart. system
         us = -vv; x component of source velocity
         vs =  uv; y component of source velocity
         a(i,j)  = us*xnx(i) + vs*xny(i); !matrix elements
         at(i,j) = us*tnx(i) + vs*tny(i); !matrix elements storing tangential components
         sumn = sumn + uv*xnx(i) + vv*xny(i);
         sumt = sumt + uv*tnx(i) + vv*tny(i);
        end
        a(i,npanel+1) = sumn;
        b(i) = -uinf*(cos(alpha)*xnx(i) + sin(alpha)*xny(i));
        at(i,npanel+1) = sumt; 
      end

c --- apply Kutta condition

      for j=1:npanel+1;
       a(npanel+1,j) = at(1,j)+at(npanel,j);
      end
      b(npanel+1) = -uinf*(cos(alpha)*(tnx(1)+tnx(npanel)) + sin(alpha)*(tny(1)+tny(npanel)));

c ----now solve A*ss = b to get the source strengths (ss(1:npanel)) and vortex strength (ss(npanel+1))
c     Note that your matrix is (npanel+1,npanel+1)

c ---- now compute tangential velocity and cp for each panel

      for i=1:npanel
       xi = 0.5*(x(i)+x(i+1));
       yi = 0.5*(y(i)+y(i+1));
       sum = 0.0;
       for j=1:npanel+1
        sum = sum + at(i,j)*ss(j);
       end
       vtan = sum + uinf*(cos(alpha)*tnx(i) + sin(alpha)*tny(i));
       cp(i) = 1.0 - vtan^2/uinf^2 !Cp
      end

