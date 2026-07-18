! Andrew Navratil
! MAE 560 Final Project - Incompressible Navier-Stokes - Projection Method

!==============================================================================
! module for reading/setting constants, inputs, grid data and metrics
!==============================================================================
module grid_data
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	! constants	===============================
	!integer, parameter :: pblm = 1				! 1 = Taylor-Green
	!integer, parameter :: nx = 100, ny = 100	! n cells => n+1 nodes
	!real(8), parameter :: Lx = 2.0*PI, Ly = 2.0*PI	
	!real(8), parameter :: omega = 1.0			! relaxation parameter for SOR
	!logical, parameter :: savekin = .true.		! save kinetic,vel div

	!real(8), parameter :: nu = 0.1		! Re=10=1/nu => nu=1/10
	!real(8), parameter :: nu = 0.01	! Re=100
	!real(8), parameter :: nu = 0.001	! Re=1000
	
	!real(8), parameter :: tstart = 0.0
	!real(8), parameter :: tstop = 1.0
	!real(8), parameter :: tstop = 5.0
	!integer, parameter :: niter = 1e4			! max num iter for elliptic solver
	!integer, parameter :: iteropt = 2			! 1=Jacobi, 2=GS/SOR
	!real(8), parameter :: tol = 1E-2			! residual tolerance

	!------------------------------------
	integer, parameter :: pblm = 2				! 2 = lid-driven cavity
	integer, parameter :: nx = 128, ny = 128	! n cells => n+1 nodes
	real(8), parameter :: Lx = 1.0, Ly = 1.0	
	real(8), parameter :: omega = 0.35			! relaxation parameter for SOR
	logical, parameter :: savekin = .false.		! save kinetic,vel div
	
	real(8), parameter :: tstart = 0.0
	real(8), parameter :: tstop = 600.0  ! make this big, will use u val stop cond.

	real(8), parameter :: stoptol = 1e-6  ! AB2 stop tol for Ghia paper compare

	!real(8), parameter :: nu = 0.01	! Re=100
	!real(8), parameter :: stopval = -0.03717  ! u(64,8) val from Ghia paper
	
	!real(8), parameter :: nu = 0.0025	! Re=400
	!real(8), parameter :: stopval = -0.08186
	
	real(8), parameter :: nu = 0.001	! Re=1000
	real(8), parameter :: stopval = -0.18109
	
	integer, parameter :: niter = 1e4			! max num iter for elliptic solver
	integer, parameter :: iteropt = 2			! 1=Jacobi, 2=GS/SOR
	real(8), parameter :: tol = 1E-2			! residual tolerance for PPE

	!------------------------------------
	!integer, parameter :: pblm = 17				! 17=g.dat
	!integer, parameter :: nx = 96, ny = 56		! n cells => n+1 nodes
	!real(8), parameter :: Lx = 1.0, Ly = 1.0	

	! global variables ========================
	! using 1 pair of ghost cells
	real(8), dimension(nx+1,ny+1) :: xn,yn	! grid node 

	real(8), dimension(0:nx+1,0:ny+1) :: xc,yc	! cell center 

	real(8), dimension(nx+1,ny) :: xf_i,yf_i	! face center i dir 
	real(8), dimension(nx,ny+1) :: xf_j,yf_j	! face center j dir 
	
	real(8), dimension(nx+1,ny) :: area_i	! face area i dir 
	real(8), dimension(nx,ny+1) :: area_j	! face area j dir 

	real(8), dimension(2,nx+1,ny) :: nhat_i	! face normal i dir (x/y,i,j)
	real(8), dimension(2,nx,ny+1) :: nhat_j	! face normal j dir (x/y,i,j)

	real(8), dimension(nx,ny) :: vol		! cell volume

	real(8), dimension(nx+1,ny) :: dinv_i	! cell distance inverse across i face
	real(8), dimension(nx,ny+1) :: dinv_j	! cell distance inverse across j face

	real(8), dimension(2,2,nx,ny) :: Linv	! gradient least sq inverse matrix

	real(8), dimension(0:nx+1,0:ny+1) :: u,v,p	! sln(k): u vel, v vel, p pressure
	real(8), dimension(0:nx+1,0:ny+1) :: un,vn,pn	! sln(k+1)

	real(8), dimension(nx,ny) :: dudt,dvdt,dpdt	! sln,p time derivatives
	real(8), dimension(nx,ny) :: dveldt ! vel* divergence (not zero)
	real(8), dimension(nx,ny) :: dpdx,dpdy ! pressure x,y derivatives

	integer :: i,j,k							! reserve i,j,k for indexing

contains

!==============================================================================
! generate or read in the grid/mesh
!==============================================================================
subroutine grid_setup

	real(8) :: dx,dy			! delta x,y for uniform grids
	
	! uniform grid
	if (pblm.eq.1 .or. pblm.eq.2) then
		dx = Lx/nx
		dy = Ly/ny
		write(*,*) 'Lx=',Lx,'Ly=',Ly
		write(*,*) 'nx=',nx,'ny=',ny
		write(*,*) 'dx=',dx,'dy=',dy

		! fill grid where data values will be at nodes
		! for FV, cell centers are at 1/2 indices (cell faces are at nodes)
		do j = 1,ny+1
		do i = 1,nx+1
			xn(i,j) = (i-1)*dx
			yn(i,j) = (j-1)*dy
		end do
		end do
	! g.dat
	else if (pblm.eq.17) then
		! nx,ny,Lx,Ly still hard coded by manually checking file
		open(11,file='grids/g.dat',status='old')
		read(11,*)
		do j=1,ny+1
		do i=1,nx+1
			read(11,*) xn(i,j),yn(i,j)
		enddo
		enddo
		close(11)
	end if

end subroutine grid_setup

!==============================================================================
! calculate grid metrics
!==============================================================================
subroutine grid_metrics

	real(8) dx,dy,linvdet

	! ======================================	
	! cell based metrics
	! ======================================	
	
	! cell center, volume
	do j = 1,ny
	do i = 1,nx
		xc(i,j) = 0.25*(xn(i,j)+xn(i+1,j)+xn(i+1,j+1)+xn(i,j+1))
		yc(i,j) = 0.25*(yn(i,j)+yn(i+1,j)+yn(i+1,j+1)+yn(i,j+1))

		vol(i,j) = 0.5*abs((xn(i+1,j+1)-xn(i,j))*(yn(i,j+1)-yn(i+1,j)) &
			-(xn(i,j+1)-xn(i+1,j))*(yn(i+1,j+1)-yn(i,j)))

		Linv(1,1,i,j) = 0.0
		Linv(1,2,i,j) = 0.0
		Linv(2,1,i,j) = 0.0
		Linv(2,2,i,j) = 0.0
	end do
	end do

	! linear extrapolation calculation for ghost cells
	do i = 1,nx
		xc(i,0) = xc(i,1) - (xc(i,2)-xc(i,1))
		yc(i,0) = yc(i,1) - (yc(i,2)-yc(i,1))

		xc(i,ny+1) = xc(i,ny) + (xc(i,ny)-xc(i,ny-1))
		yc(i,ny+1) = yc(i,ny) + (yc(i,ny)-yc(i,ny-1))
	end do

	do j = 0,ny+1
		xc(0,j) = xc(1,j) - (xc(2,j)-xc(1,j))
		yc(0,j) = yc(1,j) - (yc(2,j)-yc(1,j))

		xc(nx+1,j) = xc(nx,j) + (xc(nx,j)-xc(nx-1,j))
		yc(nx+1,j) = yc(nx,j) + (yc(nx,j)-yc(nx-1,j))
	end do

	! ======================================	
	! face based metrics (see quadrilateral cell map in FV2D-geometry-exsercise.pdf)
	! values are computed for 2 faces extending from (i,j) node (bottom left corner)
	! area_i(i,j) = S(i-1/2,j); area_j(i,j) = S(i,j-1/2)
	! nhat points from i-1 -> i and j-1 -> j (negate depending on which cell)
	! dinv_i(i,j) = inv dist xc(i-1,j) to xc(i,j)
	! dinv_j(i,j) = inv dist xc(i,j-1) to xc(i,j)
	! Linv(1,1,i,j) = a, Linv(1,2,i,j) = Linv(2,1,i,j) = b, Linv(2,2,i,j) = c
	! first store matrix as {(c,-b),(-b,a)} while building it up
	! then multiply by determinant later, for actual L inverse
	! ======================================	
	
	! loop i faces
	do j = 1,ny
	do i = 1,nx+1
		xf_i(i,j) = 0.5*(xn(i,j)+xn(i,j+1))
		yf_i(i,j) = 0.5*(yn(i,j)+yn(i,j+1))

		area_i(i,j) = sqrt((yn(i,j+1)-yn(i,j))**2 + (xn(i,j+1)-xn(i,j))**2)

		nhat_i(1,i,j) = (yn(i,j+1)-yn(i,j)) / area_i(i,j)
		nhat_i(2,i,j) = -(xn(i,j+1)-xn(i,j)) / area_i(i,j)

		dx = xc(i-1,j)-xc(i,j)
		dy = yc(i-1,j)-yc(i,j)

		dinv_i(i,j) = 1/sqrt(dx**2+dy**2)
		
		if (i.gt.1) then
			Linv(1,1,i-1,j) = Linv(1,1,i-1,j) + dy**2
			Linv(1,2,i-1,j) = Linv(1,2,i-1,j) - dx*dy
			Linv(2,1,i-1,j) = Linv(2,1,i-1,j) - dx*dy
			Linv(2,2,i-1,j) = Linv(2,2,i-1,j) + dx**2
		end if
	
		if (i.lt.nx+1) then
			Linv(1,1,i,j) = Linv(1,1,i,j) + dy**2
			Linv(1,2,i,j) = Linv(1,2,i,j) - dx*dy
			Linv(2,1,i,j) = Linv(2,1,i,j) - dx*dy
			Linv(2,2,i,j) = Linv(2,2,i,j) + dx**2
		end if
	end do
	end do

	! loop j faces
	do j = 1,ny+1
	do i = 1,nx
		xf_j(i,j) = 0.5*(xn(i,j)+xn(i+1,j))
		yf_j(i,j) = 0.5*(yn(i,j)+yn(i+1,j))

		area_j(i,j) = sqrt((yn(i+1,j)-yn(i,j))**2 + (xn(i+1,j)-xn(i,j))**2)

		nhat_j(1,i,j) = (yn(i,j)-yn(i+1,j)) / area_j(i,j)
		nhat_j(2,i,j) = -(xn(i,j)-xn(i+1,j)) / area_j(i,j)

		dx = xc(i,j-1)-xc(i,j)
		dy = yc(i,j-1)-yc(i,j)

		dinv_j(i,j) = 1/sqrt(dx**2+dy**2)
	
		if (j.gt.1) then
			Linv(1,1,i,j-1) = Linv(1,1,i,j-1) + dy**2
			Linv(1,2,i,j-1) = Linv(1,2,i,j-1) - dx*dy
			Linv(2,1,i,j-1) = Linv(2,1,i,j-1) - dx*dy
			Linv(2,2,i,j-1) = Linv(2,2,i,j-1) + dx**2
		end if
	
		if (j.lt.ny+1) then
			Linv(1,1,i,j) = Linv(1,1,i,j) + dy**2
			Linv(1,2,i,j) = Linv(1,2,i,j) - dx*dy
			Linv(2,1,i,j) = Linv(2,1,i,j) - dx*dy
			Linv(2,2,i,j) = Linv(2,2,i,j) + dx**2
		end if
	end do
	end do

	! finish the L inverse calculation
	do j = 1,ny
	do i = 1,nx
		linvdet = Linv(2,2,i,j)*Linv(1,1,i,j)-Linv(1,2,i,j)**2
		Linv(1,1,i,j) = Linv(1,1,i,j)/linvdet
		Linv(1,2,i,j) = Linv(1,2,i,j)/linvdet
		Linv(2,1,i,j) = Linv(2,1,i,j)/linvdet
		Linv(2,2,i,j) = Linv(2,2,i,j)/linvdet
	end do
	end do

end subroutine grid_metrics

!====================
end module grid_data
!====================

!==============================================================================
! module for procedures
!==============================================================================
module procedures
implicit none
contains

!==============================================================================
! calculate time step based on stability restriction and CFL number
!==============================================================================
subroutine calc_dt(t,dt)
use grid_data
	
	real(8), intent(in) :: t
	real(8), intent(in out) :: dt

	!real(8) :: dt1, dt2

	!dt1 = cfl*dx/c				! advection restriction
	!dt2 = cfl*(dx*dy/(2*d))			! diffusion restriction
	!dt = min(dt1,dt2)
	dt = 0.0001
	!dt = 0.001
	!dt = 0.01
	!dt = 0.1

end subroutine calc_dt

!==============================================================================
! initialize solution (cell centered)
!==============================================================================
subroutine sln_setup
use grid_data

	do j = 1,ny
	do i = 1,nx
		! Taylor-Green
		if (pblm.eq.1) then
			u(i,j) = -cos(xc(i,j))*sin(yc(i,j))
			v(i,j) = sin(xc(i,j))*cos(yc(i,j))
			p(i,j) = -0.25*(cos(2*xc(i,j))+cos(2*yc(i,j)))
		! lid-driven cavity
		else if (pblm.eq.2) then
			u(i,j) = 0.0
			v(i,j) = 0.0
			p(i,j) = 0.0
		end if
	end do
	end do

end subroutine sln_setup

!==============================================================================
! apply boundary conditions and fill ghost cells
!==============================================================================
subroutine apply_boundary_uv
use grid_data

	! Taylor-Green - periodic BCs (cell centered sln)
	if (pblm.eq.1) then
		do i=1,nx
			u(i,ny+1) = u(i,1)  	! upper
			u(i,0) = u(i,ny)		! lower

			v(i,ny+1) = v(i,1)  	! upper
			v(i,0) = v(i,ny)		! lower
		end do
		do j=1,ny
			u(0,j) = u(nx,j)		! left
			u(nx+1,j) = u(1,j)		! right

			v(0,j) = v(nx,j)		! left
			v(nx+1,j) = v(1,j)		! right
		end do	   
	! lid-driven cavity
	else if (pblm.eq.2) then
		do i=1,nx
			u(i,ny+1) = 1.0  	! upper: u=U
			u(i,0) = 0.0		! lower: no-slip

			v(i,ny+1) = 0.0  	! upper: v=0
			v(i,0) = 0.0		! lower: no-slip
		end do
		do j=1,ny
			u(0,j) = 0.0		! left: no-slip
			u(nx+1,j) = 0.0		! right: no-slip

			v(0,j) = 0.0		! left: no-slip
			v(nx+1,j) = 0.0		! right: no-slip
		end do	   

	end if

end subroutine apply_boundary_uv

subroutine apply_boundary_p
use grid_data

	! PPE - Taylor-Green - periodic BCs
	if (pblm.eq.1) then
		do i=1,nx
			p(i,ny+1) = p(i,1)  	! upper
			p(i,0) = p(i,ny)		! lower
		end do
		do j=1,ny
			p(0,j) = p(nx,j)		! left
			p(nx+1,j) = p(1,j)		! right
		end do	   
	! lid-driven cavity
	else if (pblm.eq.2) then
		do i=1,nx
			p(i,ny+1) = p(i,ny)  	! upper: Neumann
			p(i,0) = p(i,1)			! lower: Neumann
		end do
		do j=1,ny
			p(0,j) = p(1,j)			! left: Neumann
			p(nx+1,j) = p(nx,j)		! right: Neumann
		end do	   
	end if

end subroutine apply_boundary_p

!==============================================================================
! dudt,dvdt = derivative/flux calculation (spatial discretization)
!	for nonlinear and viscous terms dudt=Nu+Vu and dvdt=Nv+Vv (without volume)
!==============================================================================
subroutine ode_dudt_dvdt
use grid_data

	real(8) uf,vf,dudn,dvdn,veln,uflux,vflux

	! initialize the flux arrays (dudt = Nu+Vu, dvdt=Nv+Vv)
	do j = 1,ny
	do i = 1,nx
		dudt(i,j) = 0.0
		dvdt(i,j) = 0.0
	end do
	end do

	! use algorithm from lecture 12 so not doubling the computational work
	! loop over vertical i faces (normal points in i dir)
	! for face in between i-1 and i (that's how metrics are stored)
	do j = 1,ny
	do i = 1,nx+1
		! calculate uf,vf using symmetric average across faces
		! see phi^2 proof that this satisfies divergence-free velocity condition
		uf = 0.5*(u(i-1,j) + u(i,j))
		dudn = (u(i,j) - u(i-1,j))*dinv_i(i,j)
		vf = 0.5*(v(i-1,j) + v(i,j))
		dvdn = (v(i,j) - v(i-1,j))*dinv_i(i,j)

		veln = uf*nhat_i(1,i,j) + vf*nhat_i(2,i,j) ! vn = uf*nx + vf*ny

		uflux = (nu*dudn - veln*uf)*area_i(i,j)
		vflux = (nu*dvdn - veln*vf)*area_i(i,j)

		if (i.gt.1) then
			dudt(i-1,j) = dudt(i-1,j) + uflux
			dvdt(i-1,j) = dvdt(i-1,j) + vflux
		end if

		if (i.lt.nx+1) then
			dudt(i,j) = dudt(i,j) - uflux
			dvdt(i,j) = dvdt(i,j) - vflux
		end if
	end do
	end do

	! loop over horizontal j faces (normal points in j dir)
	! for face in between j-1 and j (that's how metrics are stored)
	do j = 1,ny+1
	do i = 1,nx
		uf = 0.5*(u(i,j-1) + u(i,j))
		dudn = (u(i,j) - u(i,j-1))*dinv_j(i,j)
		vf = 0.5*(v(i,j-1) + v(i,j))
		dvdn = (v(i,j) - v(i,j-1))*dinv_j(i,j)

		veln = uf*nhat_j(1,i,j) + vf*nhat_j(2,i,j)

		uflux = (nu*dudn - veln*uf)*area_j(i,j)
		vflux = (nu*dvdn - veln*vf)*area_j(i,j)

		if (j.gt.1) then
			dudt(i,j-1) = dudt(i,j-1) + uflux
			dvdt(i,j-1) = dvdt(i,j-1) + vflux
		end if

		if (j.lt.ny+1) then
			dudt(i,j) = dudt(i,j) - uflux
			dvdt(i,j) = dvdt(i,j) - vflux
		end if
	end do
	end do

end subroutine ode_dudt_dvdt

!==============================================================================
! dveldt = divergence of velocity per cell
! if u,v now contain u*,v*, then we get veln*, which is not zero
! if u,v are corrected solutions, we should get a total value close to zero
!==============================================================================
subroutine ode_dveldt
use grid_data

	real(8) uf,vf,veln,velflux
	real(8) totaldiv

	! zero out the flux arrays to start
	do j = 1,ny
	do i = 1,nx
		dveldt(i,j) = 0.0
	end do
	end do

	! loop i faces
	do j = 1,ny
	do i = 1,nx+1
		! calculate uf,vf using symmetric average across faces
		! see phi^2 proof that this satisfies divergence-free velocity condition
		uf = 0.5*(u(i-1,j) + u(i,j))
		vf = 0.5*(v(i-1,j) + v(i,j))

		veln = uf*nhat_i(1,i,j) + vf*nhat_i(2,i,j) ! vn = uf*nx + vf*ny

		velflux = veln*area_i(i,j)

		if (i.gt.1) then
			dveldt(i-1,j) = dveldt(i-1,j) + velflux
		end if

		if (i.lt.nx+1) then
			dveldt(i,j) = dveldt(i,j) - velflux
		end if
	end do
	end do

	! loop j faces
	do j = 1,ny+1
	do i = 1,nx
		uf = 0.5*(u(i,j-1) + u(i,j))
		vf = 0.5*(v(i,j-1) + v(i,j))

		veln = uf*nhat_j(1,i,j) + vf*nhat_j(2,i,j)

		velflux = veln*area_j(i,j)

		if (j.gt.1) then
			dveldt(i,j-1) = dveldt(i,j-1) + velflux
		end if

		if (j.lt.ny+1) then
			dveldt(i,j) = dveldt(i,j) - velflux
		end if
	end do
	end do

end subroutine ode_dveldt


!==============================================================================
! minimized dp/dx and dp/dy for pressure correction
! using least squares gradients
!==============================================================================
subroutine ode_dpdx_dpdy
use grid_data

	! RHS of two pressure correction eqns: sum(px*nx*Sf^2), pf=pn=p at face
	real(8) dx,dy,dp
	real(8), dimension(2,nx,ny) :: r

	! zero out the RHS to begin with
	do j = 1,ny
	do i = 1,nx
		r(1,i,j) = 0.0
		r(2,i,j) = 0.0
	end do
	end do

	! loop i faces to build RHS r=(d,e)
	do j = 1,ny
	do i = 1,nx+1
		dx = xc(i-1,j)-xc(i,j)
		dy = yc(i-1,j)-yc(i,j)
		dp = p(i-1,j)-p(i,j)

		if (i.gt.1) then
			r(1,i-1,j) = r(1,i-1,j) + dx*dp
			r(2,i-1,j) = r(2,i-1,j) + dy*dp
		end if

		if (i.lt.nx+1) then
			r(1,i,j) = r(1,i,j) + dx*dp
			r(2,i,j) = r(2,i,j) + dy*dp
		end if
	end do
	end do

	! loop j faces to finish building RHS
	do j = 1,ny+1
	do i = 1,nx
		dx = xc(i,j-1)-xc(i,j)
		dy = yc(i,j-1)-yc(i,j)
		dp = p(i,j-1)-p(i,j)

		if (j.gt.1) then
			r(1,i,j-1) = r(1,i,j-1) + dx*dp
			r(2,i,j-1) = r(2,i,j-1) + dy*dp
		end if

		if (j.lt.ny+1) then
			r(1,i,j) = r(1,i,j) + dx*dp
			r(2,i,j) = r(2,i,j) + dy*dp
		end if
	end do
	end do

	! loop cells and calculate gradients for dp/dx,dp/dy
	! see FV2D-geometry-exercise.pdf for this Linv algorithm
	do j = 1,ny
	do i = 1,nx
		dpdx(i,j) = Linv(1,1,i,j)*r(1,i,j) + Linv(1,2,i,j)*r(2,i,j)
		dpdy(i,j) = Linv(2,1,i,j)*r(1,i,j) + Linv(2,2,i,j)*r(2,i,j)
	end do
	end do

!write(*,*) 'dpdx(2,2) = ',dpdx(2,2),' dpdy(2,2) = ',dpdy(2,2)

end subroutine ode_dpdx_dpdy

!==============================================================================
! Adams-Bashforth 2nd order for 2D
! 2D advection-diffusion
!	compact formula for normal derivative (diffusion 2nd deriv term in FV)
!	central differencing scheme (convection 1st deriv term FV/FD)
!==============================================================================
subroutine ode_ab2
use grid_data

	! store previous time step and current time step dudt,dvdt
	real(8), dimension(0:nx+1,0:ny+1) :: dudtprev,dvdtprev
	real(8) totdiv,totk,res
	
	real(8) :: t,dt
	integer :: tidx

	! file for saving velocity divergence and kinetic energy
	if (savekin) then
		open(1, file = 'finalprojdata/evodata.txt', status='replace')
	end if

	! initialize dudt,dvdt for first time step
	call apply_boundary_uv
	call ode_dudt_dvdt

	write(*,*) '*** vel u ***'
	call print_sln(u)
	write(*,*) '*** pressure ***'
	call apply_boundary_p
	call print_sln(p)

	! calculate time step dt
	t = tstart
	call calc_dt(t,dt)

	! time stepping in here so we can save data from any step
	! note: we already initialized at time tstart
	t = tstart + dt
	tidx = 2
	do while (t.le.tstop)
		! copy current dudt,dvdt into previous dudt,dvdt
		! this works on 1st time step too, since dudtprev will equal dudt
		! so 3/2 dudt - 1/2 dudtprev = dudt
		do j = 1,ny
		do i = 1,nx
			dudtprev(i,j) = dudt(i,j)
			dvdtprev(i,j) = dvdt(i,j)
		end do
		end do

		! calculate current dudt,dvdt (Nu+Vu,Nv+Vv)
		call apply_boundary_uv
		call ode_dudt_dvdt

		! calculate solution at time step t+dt using AB2 algorithm (predict)
		! and backfill into solution / update solution
		! this calculates u*,v*
		do j = 1,ny
		do i = 1,nx
			u(i,j) = u(i,j) + (dt/vol(i,j))*0.5*(3*dudt(i,j) - dudtprev(i,j))
			v(i,j) = v(i,j) + (dt/vol(i,j))*0.5*(3*dvdt(i,j) - dvdtprev(i,j))
		end do
		end do

		! calculate pressure from pressure poisson equation (pressure)
		! ss_poisson iterates to convergence, includes boundary conditions
		! assumes u*,v* are in u,v and fills in p
		call ss_poisson(dt)

		! add back pressure gradient (correct)
		! currently u* is in u, so correct to get u(k+1)
		call apply_boundary_p
		call ode_dpdx_dpdy
		call apply_boundary_uv
		do j = 1,ny
		do i = 1,nx
			u(i,j) = u(i,j) - dt*dpdx(i,j)
			v(i,j) = v(i,j) - dt*dpdy(i,j)
		end do
		end do

		if (savekin) then
			! calculate the total velocity divergence and kinetic energy decay
			! this should be close to zero when u,v are actual sln
			! would be greater than zero for u*,v*
			call ode_dveldt
			totdiv = 0.0
			totk = 0.0
			do j = 1,ny
			do i = 1,nx
				totdiv = totdiv + dveldt(i,j)
				totk = totk + 0.5*(u(i,j)**2+v(i,j)**2)*vol(i,j)
			end do
			end do

			totk = totk/(4*PI**2)
			
			write(1,"(3E20.8)") t,totdiv,totk

			write(*,*) 't=',t,'tot vel divergence = ', totdiv,'tot kinetic = ',totk
		end if

		! stop conditions for lid-driven cavity
		if (pblm.eq.2) then
			write(*,*) 't=',t,'u(64,8)=',u(64,8),'v(9,64)=',v(9,64)
			res = abs(stopval - u(64,8))
			if (res.le.stoptol) then
				exit
			end if
		end if

		! increment time - use a time index so we get to tstop
		! otherwise computer roundoff error causes us to quit early
		!t = t + dt
		t = tstart + (tidx*dt)
		tidx = tidx+1
	end do

	! close kinetic energy decay file if saving
	if (savekin) then
		close(1)
	end if

	write(*,*) '*** final vel u ***'
	call apply_boundary_uv
	call print_sln(u)
	write(*,*) '*** final pressure ***'
	call apply_boundary_p
	call print_sln(p)

end subroutine ode_ab2

!==============================================================================
! SOR (successive overrelaxation) iteration method for steady state Poisson
! set omega=1 in constants at top for GS
!==============================================================================
subroutine ss_poisson(dt)
use grid_data

	real(8), intent(in) :: dt
	real(8) pold,pcur
	real(8) sigma,a1,a2,a3,a4,fint,res,resinit

	! save residual & num iter
	!open(2, file = filename2, status='replace')

	! calculate source term, which is vel* divergence
	call apply_boundary_uv
	call ode_dveldt

	! iterate solution
	do k=1,niter
		res = 0.0

		! apply boundary conditions to current solution p
		call apply_boundary_p

		do j=1,ny
		do i=1,nx
			! terms from rearrangement of discretization
			a1 = area_i(i,j) * dinv_i(i,j)
			a2 = area_i(i+1,j) * dinv_i(i+1,j)
			a3 = area_j(i,j) * dinv_j(i,j)
			a4 = area_j(i,j+1) * dinv_j(i,j+1)
			sigma = a1+a2+a3+a4

			! save current sln value into old/prev
			pold = p(i,j)

			! source term, or actual integral of source term in this case
			fint = dveldt(i,j)/dt

			! calculate current sln via discretization rearrangement
			pcur = (a1*p(i-1,j)+a2*p(i+1,j)+a3*p(i,j-1)+a4*p(i,j+1)-fint)/sigma

			! Jacobi
			if (iteropt.eq.1) then
				pn(i,j) = pcur
			! SOR/GS
			else if (iteropt.eq.2) then
				! perform relaxation and update current solution as we go along
				! SOR/GS uses recently updated values from i-1,j-1
				pcur = (1-omega)*pold + omega*pcur
				p(i,j) = pcur
			end if

			! residual calculation for convergence
			res = res + (pcur-pold)**2
		end do
		end do

		! Jacobi copy new solution to current solution
		if (iteropt.eq.1) then
			do j=1,ny
			do i=1,nx
				p(i,j) = pn(i,j)
			end do
			end do
		end if

		! calculate residual for convergene and break if tolerance achieved
		res = sqrt(res)
!write(*,*) 'res=',res,'u(2,2)=',u(2,2),'p(2,2)=',p(2,2)
		if (res.le.tol) then
			!close(2)
			!write(*,*) '*************************************'
			!write(*,*) 'p(2,2) = ',p(2,2)
!write(*,*) 'poisson res=',res,'p(2,2)=',p(2,2)
			exit
		end if
	end do

end subroutine ss_poisson

!==============================================================================
! subroutine to print out the solution to file for tecplot
!==============================================================================
subroutine print_sln_to_tecplot
use grid_data

	real(8) vel

	open(1, file = 'finalprojdata/slndatatec.plt', status='replace')
	write(1,*) 'TITLE=lid-driven cavity'
	write(1,*) 'VARIABLES=X,Y,U,V,P,VEL'
	write(1,*) 'ZONE  F=POINT'
	write(1,*) 'I=',nx,', J=',ny
	do j = 1,ny
	do i = 1,nx
		!write(1,"(2I3,3F32.16)") i,j,xval,yval,u(i,j)
		vel = sqrt(u(i,j)**2 + v(i,j)**2)
		write(1,"(6E20.8)") xc(i,j),yc(i,j),u(i,j),v(i,j),p(i,j),vel
	end do
	end do
	close(1)

end subroutine print_sln_to_tecplot


!==============================================================================
! subroutine to print out the solution to file
! cell centered FV has cell center values for x,y
!==============================================================================
subroutine print_sln_to_file
use grid_data

	real(8) vel

	open(1, file = 'finalprojdata/slndata.txt', status='replace')
	!write(1,*) 'i,x,u'
	do j = 1,ny
	do i = 1,nx
		!write(1,"(2I3,3F32.16)") i,j,xval,yval,u(i,j)
		vel = sqrt(u(i,j)**2 + v(i,j)**2)
		write(1,"(2I5,6E20.8)") i,j,xc(i,j),yc(i,j),u(i,j),v(i,j),p(i,j),vel
	end do
	end do
	close(1)

end subroutine print_sln_to_file

!==============================================================================
! print out solution in a matrix form like viewing x-y axis
!==============================================================================
subroutine print_cells(slnu)
use grid_data
	
	real(8), dimension(nx,ny), intent(in) :: slnu

	! print the top left and right corners
	do j = ny,ny-4,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		do i = 1,5
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do i = nx-4,nx
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

	! print the bottom left and right corners
	do j = 5,1,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		do i = 1,5
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do i = nx-4,nx
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

end subroutine print_cells


!==============================================================================
! print out solution in a matrix form like viewing x-y axis
! ** only do for small nx,ny like 10x10
!==============================================================================
subroutine print_sln(slnu)
use grid_data
	
	real(8), dimension(0:nx+1,0:ny+1), intent(in) :: slnu

	! print the top left and right corners
	do j = ny+1,ny-3,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		do i = 0,4
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do i = nx-3,nx+1
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

	! print the bottom left and right corners
	do j = 4,0,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		do i = 0,4
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do i = nx-3,nx+1
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

end subroutine print_sln

!==============================================================================
! print out a grid metric in a matrix form (only do for small nx,ny like 10x10)
!==============================================================================
subroutine print_grid
use grid_data

	write(*,*) 'cell center (x,y)'
	!do j = ny+1,0,-1
	do j = 5,1,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		!do i = 0,nx+1
		do i = 1,5
			write(*,"(A1,F7.4,A1,F7.4,A2)",advance="no") '(',xc(i,j),',',yc(i,j),') '
			!write(*,"(E15.8,A1)",advance="no") grid(i,j),' '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)  ! write out the new line

end subroutine print_grid

!==============================================================================
! print grid face values
!==============================================================================
subroutine print_grid_faces(slnu)
use grid_data

	real(8), dimension(nx+1,ny+1), intent(in) :: slnu
	
	! print the top left and right corners
	do j = ny+1,ny-3,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		do i = 1,5
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do i = nx-3,nx+1
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

	! print the bottom left and right corners
	do j = 5,1,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		do i = 1,5
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do i = nx-3,nx+1
			write(*,"(A1,F8.5,A2)",advance="no") '(',slnu(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

end subroutine print_grid_faces


!==============================================================================
! print out a grid metric like i,j,grid_x(i,j),grid_y(i,j)
!==============================================================================
subroutine print_grid2
use grid_data

	! cells.dat matching
	! File contains i,j,xc(i,j),yc(i,j),vol(i,j),Linv(1,1),Linv(1,2),Linv(2,1),Linv(2,2)
	! for -interior- cells (for grid 'g.dat': (nx,ny)=(96,56))
	do j=1,2
	do i=1,nx
		write(*,*) i,j,xc(i,j),yc(i,j),vol(i,j),Linv(1,1,i,j),Linv(1,2,i,j) &
			,Linv(2,1,i,j),Linv(2,2,i,j)
	end do
	end do

	! I-faces.dat matching
	! File contains i,j,xf_i(i,j),yf_i(i,j),area_i(i,j),nhat_i(1,i,j),nhat_i(1:2,i,j),
	! dinv_i(i,j) for I-faces (for grid 'g.dat': (nx,ny)=(96,56))
	do j=1,2
	do i=1,nx+1
		write(*,*) i,j,xf_i(i,j),yf_i(i,j),area_i(i,j),nhat_i(1,i,j),nhat_i(2,i,j) &
			,dinv_i(i,j)
	end do
	end do

	! J-faces.dat matching
	! File contains i,j,xf_j(i,j),yf_j(i,j),area_j(i,j),nhat_j(1,i,j),nhat_j(1:2,i,j),
	! dinv_j(i,j) for J-faces (for grid 'g.dat': (nx,ny)=(96,56))
	do j=1,2
	do i=1,nx
		write(*,*) i,j,xf_j(i,j),yf_j(i,j),area_j(i,j),nhat_j(1,i,j),nhat_j(2,i,j) &
			,dinv_j(i,j)
	end do
	end do

end subroutine print_grid2


!====================
end module procedures
!====================

!******************************************************************************
! main cfd solver program
!******************************************************************************
program cfd
use grid_data
use procedures
implicit none

	call grid_setup
	call grid_metrics

	call print_grid
	!call print_grid2

	! adams-bashforth method
	call sln_setup
	call ode_ab2

	call print_sln_to_file  ! print solutions
	call print_sln_to_tecplot  ! print solutions for tecplot

end program cfd

