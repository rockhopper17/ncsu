
! --------------------------------------------------------------------
! --------------------------------------------------------------------
!     Computation of Xsi direction fluxes 
! --------------------------------------------------------------------
! --------------------------------------------------------------------

      sumb = 0.0
      sumby = 0.0
c ----- realizable variables 

      mlim = 4
      mr(1) = 1
      mr(2) = nsp4
      mr(3) = nsp5
      mr(4) = nsp6

      uvmn(1) = 0.0
      uvmx(1) = 1e7
      uvmn(2) = 15.0
      uvmx(2) = 6000.0
      uvmn(3) = 0.0
      uvmx(3) = 1000000.
      uvmn(4) = 0.0
      uvmx(4) = 1e12

      sumymass(1:3) = 0.0
      do k=kstr,kend
      do j=jstr,jend

! --------------------------------------------------------------------
! ----- extrapolate primitive variables to cell interfaces
! --------------------------------------------------------------------


      do m=1,neq
      do i=-2,ii+3
       du(i,m) = 0.0
       dmd(i,m) = 0.0
       dmd1(i,m) = 0.0
      enddo
      enddo

! m=1: pressure; 2: u-velocity, 3: v-velocity, 4: w-velocity, 5: temperature, 6:
! turbulence kinetic energy; 7: turbulence frequency

      do m=1,neq
      do i=-2,ii+4
       qv(i,m) = q(i,j,k,mq(m))
      enddo
      do i=-2,ii+3
       du(i,m) = qv(i+1,m)-qv(i,m)
      enddo
      enddo

! ----- pressure limiters (active near shocks)

      do i=-1,ii+3
       pd = abs(qv(i+1,1) - 2.0*qv(i,1) + qv(i-1,1))
       pdl = min(1000.*pinf,0.25*abs(qv(i+1,1) + 2.0*qv(i,1) + qv(i-1,1)))
       pdif(i) = 1.25*(max(pd/(pd+pdl),0.2)-0.2)
       pdif(i) = 1. - pdif(i)
       pdif2(i) = asec*pdif(i)
       pdif3(i) = strn(i,j,k,3)
      enddo
       if(ibctype(mm,1).ne.0.and.ibctype(mm,1).ne.0) then 
         pdif(-1:1) = pdif(2)
         pdif2(-1:1) = pdif2(2)
         pdif3(-1:1) = pdif3(2)
       endif
       if(ibctype(mm,2).ne.0.and.ibctype(mm,2).ne.0) then
         pdif(ii+1:ii+3) = pdif(ii)
         pdif2(ii+1:ii+3) = pdif2(ii)
         pdif3(ii+1:ii+3) = pdif3(ii)
       endif

      do i=1,ii+1
        if(q(i,j,k,nsp17).eq.1.0.and.q(i+1,j,k,nsp17).eq.0.0) then
         pdif2(i) = pdif2(i+1)
         pdif2(i-1) = pdif2(i)
        endif
        if(q(i,j,k,nsp17).eq.0.0.and.q(i+1,j,k,nsp17).eq.1.0) then
         pdif2(i+1) = pdif2(i)
         pdif2(i+2) = pdif2(i+1)
        endif
      enddo

      do m=1,neq
      do i=-1,ii+3
        dmda = 0.5*(du(i,m)+du(i-1,m))
        dmd(i,m) = dmda
      enddo
      enddo

c ---- this is the averaging method at the cell interfaces.

      do m=1,neq
      do i=0,ii+1
        asc = 1.0-max(pdif3(i),pdif3(i+1))
        uv(i,m) = 0.5*(qv(i,m) + qv(i+1,m)) 
     c          + asc/6.0*(dmd(i,m) - dmd(i+1,m))
     c          - asc/30.0*(3.0*(dmd(i+1,m)-dmd(i,m))
     c                        - (dmd(i+2,m)-dmd(i-1,m)))
c       uv(i,m) = xmed(qv(i,m),uv(i,m),qv(i+1,m))
      enddo
      enddo

      if(ibctype(mm,1).ne.0.and.ibctype(mm,1).ne.20) then
       do m=1,neq
        uv(2,m) = 0.5*(qv(2,m) + qv(3,m))
     c          + 1.0/6.0*(dmd(2,m) - dmd(3,m))
        uv(1,m) = 0.5*(qv(1,m)+qv(2,m))
        uv(0,m) = (4.0*uv(1,m)-uv(2,m))/3.0
       enddo
      endif

      if(ibctype(mm,2).ne.0.and.ibctype(mm,2).ne.20) then
       do m=1,neq
        uv(ii-1,m) = 0.5*(qv(ii-1,m) + qv(ii,m))
     c             + 1.0/6.0*(dmd(ii-1,m) - dmd(ii,m))
        uv(ii,m) = 0.5*(qv(ii+1,m)+qv(ii,m))
        uv(ii+1,m) = (4.0*uv(ii,m)-uv(ii-1,m))/3.0
       enddo
      endif

c ---- this is the left / right state info

      do m=1,neq
      do i=1,ii+1
        uvr(i,m) = uv(i,m)
        uvl(i,m) = uv(i-1,m)

        if( (uvr(i,m)-qv(i,m))*(qv(i,m)-uvl(i,m)) .le. 0.0) then
          uvl(i,m) = qv(i,m)
          uvr(i,m) = qv(i,m)
        else
          dc = uvr(i,m)-uvl(i,m)
          c6 = 6.0*(qv(i,m) - 0.5*(uvl(i,m)+uvr(i,m)))
          if(dc*c6 .gt. dc*dc) then
            uvl(i,m) = 3.0*qv(i,m) - 2.0*uvr(i,m)
          elseif(-dc*dc .gt. dc*c6) then
            uvr(i,m) = 3.0*qv(i,m) - 2.0*uvl(i,m)
          endif
        endif

      enddo
      enddo

      do i=1,ii+1
        if(q(i,j,k,nsp17).eq.1.0.and.q(i+1,j,k,nsp17).eq.0.0) then
         do m=1,neq
          uvr(i,m) = 0.5*(qv(i,m)+qv(i+1,m))
          uvl(i+1,m) = qv(i+1,m)-0.5*xmd(du(i+1,m),du(i,m))
         enddo
        endif
        if(q(i,j,k,nsp17).eq.0.0.and.q(i+1,j,k,nsp17).eq.1.0) then
         do m=1,neq
          uvl(i+1,m) = 0.5*(qv(i+1,m)+qv(i,m))
          uvr(i,m) = qv(i,m)+0.5*xmd(du(i,m),du(i-1,m))
         enddo
        endif
      enddo

      if(ibctype(mm,1).ne.0.and.ibctype(mm,1).ne.20) then
       do m=1,neq
        uvr(1,m) = 0.5*(qv(1,m)+qv(2,m))
        uvl(2,m) = qv(2,m)-0.5*xmd(du(2,m),du(1,m))
       enddo
      endif

      if(ibctype(mm,2).ne.0.and.ibctype(mm,2).ne.20) then
       do m=1,neq
        uvl(ii+1,m) = 0.5*(qv(ii+1,m)+qv(ii,m))
        uvr(ii,m) = qv(ii,m)+0.5*xmd(du(ii,m),du(ii-1,m))
       enddo
      endif

c ---- this is where they are blended (switch is f in my doc.)

c     do m=1,neq
      do m=nsp1,nsp3
      do i=2,ii+1
       switchm = max(1.0-pdif(i-1),qs(i-1,j,k),0.00)
       switch  = max(1.0-pdif(i),qs(i,j,k),0.00)
       uvl(i,m) = uv(i-1,m) + 0.5*(switch+switchm)*(uvl(i,m) - uv(i-1,m))
      enddo
      do i=1,ii
       switch  = max(1.0-pdif(i),qs(i,j,k),0.00)
       switchp = max(1.0-pdif(i+1),qs(i+1,j,k),0.00)
       uvr(i,m) = uv(i,m)   + 0.5*(switch+switchp)*(uvr(i,m) - uv(i,m))
      enddo
      enddo

      do m=1,mlim
      do i=1,ii+1
       if(uvr(i,mr(m)).lt.uvmn(m).or.uvr(i,mr(m)).gt.uvmx(m)
     c  .or. uvl(i,mr(m)).lt.uvmn(m).or.uvl(i,mr(m)).gt.uvmx(m)) then
         uvl(i,mr(m)) = qv(i,mr(m))
         uvr(i,mr(m)) = qv(i,mr(m))
       endif
      enddo
      enddo

c ---- this is where left and right state info is actually calculated.
c      There is another limiting between first order and higher order
c      done here.  
c      e:  pressure, u,v,w - velocity, t: temperature; tke, ome - turbulence
c      h:  enthalpy, a: sound speed

      do i=1,ii

      el(i) = q(i,j,k,nsp6) + pdif2(i)*(uvr(i,1)-q(i,j,k,nsp6))
      ul(i) = q(i,j,k,nsp1) + pdif2(i)*(uvr(i,2)-q(i,j,k,nsp1))
      vl(i) = q(i,j,k,nsp2) + pdif2(i)*(uvr(i,3)-q(i,j,k,nsp2))
      wl(i) = q(i,j,k,nsp3) + pdif2(i)*(uvr(i,4)-q(i,j,k,nsp3))
      tl(i) = q(i,j,k,nsp4) + pdif2(i)*(uvr(i,5)-q(i,j,k,nsp4))
      tkel(i) = q(i,j,k,nsp10) + pdif2(i)*(uvr(i,6)-q(i,j,k,nsp10))
      omel(i) = q(i,j,k,nsp11) + pdif2(i)*(uvr(i,7)-q(i,j,k,nsp11))
      rhol(i) = el(i)/(rgas*wt(1)*tl(i))
      hl(i) = cpf(1,1,0)*tl(i)+0.5*(ul(i)**2 + vl(i)**2 + wl(i)**2) 
      al(i) = sqrt(1.4*rgas*wt(1)*tl(i))

      er(i) = q(i+1,j,k,nsp6) - pdif2(i+1)*(q(i+1,j,k,nsp6)-uvl(i+1,1))
      ur(i) = q(i+1,j,k,nsp1) - pdif2(i+1)*(q(i+1,j,k,nsp1)-uvl(i+1,2))
      vr(i) = q(i+1,j,k,nsp2) - pdif2(i+1)*(q(i+1,j,k,nsp2)-uvl(i+1,3))
      wr(i) = q(i+1,j,k,nsp3) - pdif2(i+1)*(q(i+1,j,k,nsp3)-uvl(i+1,4))
      tr(i) = q(i+1,j,k,nsp4) - pdif2(i+1)*(q(i+1,j,k,nsp4)-uvl(i+1,5))
      tker(i) = q(i+1,j,k,nsp10) - pdif2(i+1)*(q(i+1,j,k,nsp10)-uvl(i+1,6))
      omer(i) = q(i+1,j,k,nsp11) - pdif2(i+1)*(q(i+1,j,k,nsp11)-uvl(i+1,7))
      rhor(i) = er(i)/(rgas*wt(1)*tr(i))
      hr(i) = cpf(1,1,0)*tr(i)+0.5*(ur(i)**2 + vr(i)**2 + wr(i)**2) 
      ar(i) = sqrt(1.4*rgas*wt(1)*tr(i))

      enddo

! --------------------------------------------------------------------
! ----- inviscid flux contribution (LDFSS)
! ----- this is where the inviscid fluxes are calculated.
! --------------------------------------------------------------------

      do i=1,ii

      txp(i) = xmt(i,j,k,1,1) 
      typ(i) = xmt(i,j,k,1,2) 
      tzp(i) = xmt(i,j,k,1,3) 
      tgp(i) = sqrt(txp(i)*txp(i) + typ(i)*typ(i) + tzp(i)*tzp(i))

      ahalf = 0.5*(al(i) + ar(i))
      xml = (txp(i)*ul(i) + typ(i)*vl(i) + tzp(i)*wl(i))/(tgp(i)*ahalf)
      xmr = (txp(i)*ur(i) + typ(i)*vr(i) + tzp(i)*wr(i))/(tgp(i)*ahalf)

      all = 0.5*(1. + sign(1.0,xml))
      alr = 0.5*(1. - sign(1.0,xmr))

      btl = -max(0.,1.-real(int(abs(xml))))
      btr = -max(0.,1.-real(int(abs(xmr))))

      xmml = 0.25*(xml+1.0)**2
      xmmr = -0.25*(xmr-1.0)**2

      xmhalf = sqrt(0.5*(xml*xml + xmr*xmr))
      xmc = 0.25*btl*btr*(xmhalf - 1.0)**2
      delp = el(i) - er(i)
      psum = el(i) + er(i)
      xmcp = xmc*max(0.0,(1.0 - (delp/psum + 2.0*abs(delp)/el(i))))
      xmcm = xmc*max(0.0,(1.0 + (delp/psum - 2.0*abs(delp)/er(i))))

! ----- interface mass flux 

      flag = 1.0
      if(i.eq.1.and.(ibctype(mm,1).eq.4.or.ibctype(mm,1).eq.3
     c              .or.ibctype(mm,1).eq.8.or.ibctype(mm,1).eq.9)) 
     c   flag = 0.0
      if(i.eq.ii.and.(ibctype(mm,2).eq.4.or.ibctype(mm,2).eq.3
     c            .or.ibctype(mm,2).eq.8.or.ibctype(mm,2).eq.9)) 
     c   flag = 0.0
c     if(sign(1.0,q(i,j,k,nsp15)*q(i+1,j,k,nsp15)).eq.-1.0) flag = 0.0
   

      fml = tgp(i)*rhol(i)*ahalf*(all*(1.+btl)*xml - btl*xmml 
     c         - xmcp)*flag
      fmr = tgp(i)*rhor(i)*ahalf*(alr*(1.+btr)*xmr - btr*xmmr 
     c         + xmcm)*flag

      fmla = tgp(i)*rhol(i)*ahalf*all*xml*flag
      fmra = tgp(i)*rhor(i)*ahalf*alr*xmr*flag

! ----- pressure splitting #1

!     ppl = 0.5*(1.+xml)
!     ppr = 0.5*(1.-xmr)

! ----- pressure splitting #2

      ppl = 0.25*(xml+1.)**2*(2.-xml)
      ppr = 0.25*(xmr-1.)**2*(2.+xmr)

      pnet = (all*(1.+btl) - btl*ppl)*el(i) 
     c     + (alr*(1.+btr) - btr*ppr)*er(i)

      ev(i,1) = fml + fmr
      ev(i,nsp1) = fml*ul(i) + fmr*ur(i) + txp(i)*pnet
      ev(i,nsp2) = fml*vl(i) + fmr*vr(i) + typ(i)*pnet
      ev(i,nsp3) = fml*wl(i) + fmr*wr(i) + tzp(i)*pnet
      ev(i,nsp4) = fml*hl(i) + fmr*hr(i)
      ev(i,nsp5) = fml*tkel(i) + fmr*tker(i)
      ev(i,nsp6) = fml*omel(i) + fmr*omer(i)

      if((ibctype(mm,1).eq.1.or.ibctype(mm,1).eq.20).and.i.eq.1) sumymass(1) = sumymass(1) + ev(i,1)
      if(ibctype(mm,2).eq.2.and.i.eq.ii) sumymass(2) = sumymass(2) + ev(i,1)

      enddo
        
!     write(6,*) 'here after inv ',j,k

