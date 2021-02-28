! Andrew Navratil
! MAE 766 CFD - HW 3: Riemann Problem Exact Sln for 1D Compressible Euler

! Riemann Problem (models shock-tube experiments): contact discontinuity at x=0
! where uL and uR are constant values of vel on either side (can be different)
! also given init values of pressure pL,pR and density rhoL,rhoR
! use nonlinear hyperbolic characteristic curves of 1D Euler
! eigenvals u,u-c,u+c (c spd sound) give 3 wave characteristics
!	=> u: con disc (linearly degenerate), propagates at fluid velocity 
!	across con disc: u,p const but rho changes (see Riemann invariant proof)
!	=> u-c,u+c: shock or rarefaction waves, have their own speeds of propagation
! 	across shock/rarefaction wave: all 3 u,p,rho change
!	- for Euler, assume u+c => shock wave, u-c => rarefaction wave (expansion fan)
! solution field is time and space dependendant, with distinct regions
! can solve for field at a specific time to get x-y plots of u,p,rho on 1D x domain
! will give exact (to a tolerance) solution, useful for approx model validations

! Luo lectures, for Euler assumptions, have 4 const regions + 1 rarefaction wave region
! L <> 4 (inside fan) <> 3 (R of fan/L of con disc) <> 2 (R of con disc/L of shock) <> R

! ref: Luo lectures (4.6 in CFD Lec DG), Toro book (Riemann Solvers for Fluids)
!		Gilat book (numerical methods)

!******************************************************************************
! module for reading/setting constants, inputs, problem data and metrics
!******************************************************************************
module rp_data
implicit none

	! constants	===============================
	real(8), parameter :: gma = 1.4			! gamma (ratio specific heats Cp/Cv)
	integer, parameter :: maxiter = 1e6		! max iterations for nonlinear solvers
	real(8), parameter :: eps = 1e-8	! convergence tolerance for nonlinear solvers
	integer, parameter :: npts = 1e4	! num of cells/elements (1D on x axis)
	real(8), parameter :: xlow=0.0,xhigh=1.0,xcd0=0.5	! x range, con disc init loc

	! Sod shock tube
	real(8), parameter :: uL = 0.0, uR = 0.0			! velocity
	real(8), parameter :: rhoL = 1.0, rhoR = 0.125		! density
	real(8), parameter :: pL = 1.0, pR = 0.1			! pressure
	real(8), parameter :: tcur = 0.2					! time to solve at
	
	! Lax-Harden shock tube
	!real(8), parameter :: uL = 0.698876404, uR = 0.0	! velocity
	!real(8), parameter :: rhoL = 0.445, rhoR = 0.5		! density
	!real(8), parameter :: pL = 3.52773, pR = 0.571		! pressure
	!real(8), parameter :: tcur = 0.15					! time to solve at
	!real(8), parameter :: xcd0 = 0.5			! init loc for con disc (x0)

	! speed of sound	
	real(8), parameter :: cL = sqrt(gma*pL/rhoL), cR = sqrt(gma*pR/rhoR)

	! global variables ========================
	real(8), dimension(npts) :: nodes				! node coordinates (x midpoint)
	real(8), dimension(npts) :: usln,rhosln,psln	! sln values for u,rho,p
	real(8) :: p2		! pressure between waves (region 2 for Luo, * for Toro)
	
	integer :: i,j,k					! reserve i,j,k for indexing

contains

!====================
end module rp_data
!====================

!******************************************************************************
! module for procedures
!******************************************************************************
module rp_procs
implicit none
contains

!=========================================
! calculate pressure in region 2/3 between waves
! uses Newton's method to solve nonlinear eqn for p2
!=========================================
subroutine calc_pressure
use rp_data

	real(8) :: p,pold		! pressure value in region 2 (between waves)
	real(8) :: fp,dfp,fpL,dfpL,fpR,dfpR	! Toro func and deriv values
	real(8) :: curtol	! current error

	! constants for Toro algorithm
	real(8) :: aL = 2.0/((gma+1.0)*rhoL)
	real(8) :: aR = 2.0/((gma+1.0)*rhoR)
	real(8) :: bL = ((gma-1.0)*pL)/(gma+1.0)
	real(8) :: bR = ((gma-1.0)*pR)/(gma+1.0)
	
	! initial guess
	p = 0.5*(pL+pR)

	! use Newton method to solve nonlinear equation for pressure
	! Toro: fp = fpL + fpR + (uR-uL) = 0 (for correct pressure value)
	! where wave pressure functions are functions of all three primitive
	!		initial conditions L and R (u,p,rho) and gamma
	do i = 1,maxiter
		! save cur value to prev value
		pold = p

		! calculate p2 value using Toro formulas (p119 f, p125 df)
		! assumes left rarefaction wave
		fpL = ((2.0*cL)/(gma-1.0))*((p/pL)**((gma-1.0)/(2.0*gma))-1.0)
		dfpL = (1.0/(rhoL*cL))*(p/pL)**(-(gma+1.0)/(2.0*gma))
		! and right shock wave
		fpR = (p-pR)*sqrt(aR/(p+bR))
		dfpR = sqrt(aR/(bR+p))*(1.0-((p-pR)/(2.0*(bR+p))))

		! func value is sum with vel diff (eqn 4.5)
		fp = fpL + fpR + (uR-uL)
		! dfp value is just sum of two derivs
		dfp = dfpL + dfpR

		! Newton iteration
		p = pold - fp/dfp
		curtol = abs((p-pold)/pold)

		! debug output
		write(*,*) "i=",i," p=",p," fp=",fp," dfp=",dfp," curtol=",curtol

		! evaluate convergence and break if tolerance achieved
		if (curtol.lt.eps) then
			exit
		end if
	end do

	! p2 value is now in p, everything else can be calculated from that
	p2 = p
	!u2 = 0.5*(uL+uR) + 0.5*(fpR-fpL)	! Toro calc, but use Luo below (same val)

end subroutine calc_pressure
	
!=========================================
! calculate u,p,rho at all x locations based on p2 and time tcur
! fills in usln,psln,rhosln
!=========================================
subroutine calc_uprho_byx
use rp_data

	!real(8) :: pr1,pr2,gr1,gr2,gr3,gr4,gr5,gr6,gr7,gr8
	real(8) :: c3,c4,ss,st,sh
	real(8) :: xcd,xs,xt,xh,x,dx,dxdt
	real(8) :: u2,rho2,u3,p3,rho3,u4,p4,rho4
	real(8) :: alpha,prat

	! setup some precalculated ratios
	!pr1 = p2/pR
	!pr2 = p2/pL
	!gr1 = (gma-1.0)/(gma+1.0)
	!gr2 = 1.0/gma
	!gr3 = (gma+1.0)/(2.0*gma)
	!gr4 = (gma-1.0)/(2.0*gma)
	!gr5 = 2.0/(gma+1.0)
	!gr6 = (gma-1.0)/2.0
	!gr7 = (2.0*gma)/(gma-1.0)
	!gr8 = 2.0/(gma-1.0)

	! Luo formula ratios
	alpha = (gma+1.0)/(gma-1.0)
	prat = p2/pR

	! region 2 (right of con disc / left of shock)
	u2 = uR+(cR/gma)*(prat-1.0)/sqrt(((gma+1.0)/(2.0*gma))*(prat-1.0)+1.0)
	!u2 = uL + ((2.0*cL)/(gma-1.0))*(1.0-(p2/pL)**((gma-1.0)/(2.0*gma)))
	rho2 = rhoR*(1.0+alpha*prat)/(alpha+prat)

	! region 3 (left of con disc / right of fan)
	p3 = p2
	u3 = u2
	rho3 = rhoL*(p3/pL)**(1.0/gma)

	! calculate wave speeds
	c3 = cL*(p3/pL)**((gma-1.0)/(2.0*gma)) ! sound speed behind (right of) fan
	!ss = uR+cR*sqrt(gr3*pr1+gr4) ! shock speed
	ss = (rhoR*uR-rho2*u2)/(rhoR-rho2)	! shock speed
	st = u3-c3	! fan tail speed (to the right of head)
	sh = uL-cL	! fan head speed

	! calculate location of separation points
	! will be offset from initial x value of con disc (xcd0)
	xcd = u2*tcur + xcd0	! contact discontinuity loc (moves at fluid speed)
	xs = ss*tcur + xcd0		! shock loc
	xt = st*tcur + xcd0		! fan tail loc
	xh = sh*tcur + xcd0		! fan head loc

	! iterate over x domain and fill in sln arrays
	dx = (xhigh-xlow)/(npts-1)
	do i = 1,npts
		!x = dx*dble(i-1)
		x = dx*dble(i-0.5)	! calc values at midpoint of element
		nodes(i) = x

		! left region
		if (x.lt.xh) then
			usln(i) = uL
			psln(i) = pL
			rhosln(i) = rhoL
		! inside fan (region 4)
		else if (x.ge.xh .and. x.le.xt) then
			dxdt = (x-xcd0)/tcur
			u4 = (2.0/(gma+1.0))*(dxdt+cL+((gma-1.0)/2.0)*uL)
			c4 = u4-dxdt
			p4 = pL*(c4/cL)**((2.0*gma)/(gma-1.0))
			rho4 = rhoL*(p4/pL)**(1.0/gma)
			usln(i) = u4
			psln(i) = p4
			rhosln(i) = rho4
			!usln(i) = gr5*(cL+gr6*uL+dxdt)
			!psln(i) = pL*(gr5+(gr1/cL)*(uL-dxdt))**gr7
			!rhosln(i) = rhoL*(gr5+(gr1/cL)*(uL-dxdt))**gr8
		! between waves, left of con disc / right of fan (region 3/*L)
		else if (x.gt.xt .and. x.lt.xcd) then
			usln(i) = u3
			psln(i) = p3
			rhosln(i) = rho3
			!rhosln(i) = rhoL*(pr2**gr2)
		! between waves, right of con disc / left of shock (region 2/*R)
		else if (x.ge.xcd .and. x.lt.xs) then
			usln(i) = u2
			psln(i) = p2
			rhosln(i) = rho2
			!rhosln(i) = rhoR*(pr1+gr1)/(gr1*pr1+1)
		! right region
		else
			usln(i) = uR
			psln(i) = pR
			rhosln(i) = rhoR
		end if
	end do

end subroutine calc_uprho_byx

!=========================================
! print solution to tecplot
!=========================================
subroutine print_sln_tecplot
use rp_data

	open(17, file = 'data/rpexact.plt', status='replace')
	write(17,*) 'TITLE=RIEMANN PROBLEM EXACT SOLUTION'
	write(17,*) 'VARIABLES=x,u,p,rho'
	do i = 1,npts
		write(17,"(4E20.8)") nodes(i),usln(i),psln(i),rhosln(i)
	end do
	close(17)

end subroutine print_sln_tecplot

!====================
end module rp_procs
!====================

!******************************************************************************
! main solver program
!******************************************************************************
program rpexact
use rp_data
use rp_procs
implicit none

	call calc_pressure
	call calc_uprho_byx
	call print_sln_tecplot

end program rpexact
