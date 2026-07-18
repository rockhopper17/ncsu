	
	! x range, con disc loc at t=0
	real(8), parameter :: xlow = 0.0, xhigh = 1.0, xcd = 0.5	
	integer, parameter :: npts = 1e2+1	! num of pts on x line
	real(8), dimension(npts) :: xvals				! spatial x values


	u2 = uR + (cR/gma)*((p2/pR)-1)/sqrt(((gma+1)/(2*gma))*((p2/pR)-1)+1)
	rho2 = rhoR*(1+alpha)*(p2/pR)/(alpha+(p2/pR))
	!===================

	!=========================================
! calculate metrics
!=========================================
subroutine rp_metrics

	real(8) :: xrange,dx

	! generate uniform x grid
	xrange = xhigh - xlow
	dx = xrange/(npts-1)
	xvals(1) = xlow
	xvals(npts) = xhigh
	do i = 2,npts-1
		xvals(i) = dx*dble(i-1)
	end do

end subroutine rp_metrics


	
	real(8) :: p,pa,pb		! pressure ratio p2/pR cur val and endpoint values
	real(8) :: curerr,u2,fp,u2a,fpa,u2b,fpb

! use bisection method to solve Luo version (see Gilat p63)
	! interval for prat is pR/pR = 1 to pL/pR (assumes pL > pR)
	pa = 1
	pb = pL/pR
	do i = 1,maxiter
		! calculate next guess for pressure ratio
		p = 0.5*(pa + pb)

		! calculate how close we are to zooming in on solution
		curerr = 0.5*(pb - pa)

		! formula for pressure ratio (see lecture notes)
		u2 = uR + (cR/gma)*(p-1)/sqrt((gma+1)/(2*gma)*(p-1)+1)
		fp = p*(1+((gma-1)/cL)*(uL-u2))**(-2*gma/(gma-1))

		u2a = uR + (cR/gma)*(pa-1)/sqrt((gma+1)/(2*gma)*(pa-1)+1)
		fpa = pa*(1+((gma-1)/cL)*(uL-u2))**(-2*gma/(gma-1))
		u2b = uR + (cR/gma)*(pb-1)/sqrt((gma+1)/(2*gma)*(pb-1)+1)
		fpb = pb*(1+((gma-1)/cL)*(uL-u2))**(-2*gma/(gma-1))

		! debug output
		write(*,*) "i=",i," p=",p," fp=",fp," fpa=",fpa," fpb=",fpb," curerr=",curerr

		! tolerance achieved
		if (curerr.lt.eps) then
			stop
		end if

		! set new interval based on func eval gt or lt zero
		if (fpa.lt.0.0) then
			pb = p
		else
			pa = p
		end if
	end do


