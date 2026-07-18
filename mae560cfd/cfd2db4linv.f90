! Andrew Navratil
! MAE 560 Final Project - Incompressible Navier-Stokes - Projection Method

!==============================================================================
! module for reading/setting constants, inputs, grid data and metrics
!==============================================================================
module grid_data
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	! constants	===============================
	integer, parameter :: pblm = 1				! 1 = Taylor-Green
	integer, parameter :: nx = 100, ny = 100	! n cells => n+1 nodes
	real(8), parameter :: Lx = 2.0*PI, Ly = 2.0*PI	
	!integer, parameter :: nx = 10, ny = 10	! n cells => n+1 nodes
	!real(8), parameter :: Lx = 1.0, Ly = 1.0
	!real(8), parameter :: nu = 0.1		! Re=10=1/nu => nu=1/10
	real(8), parameter :: nu = 0.01		! Re=100=1/nu => nu=1/100
	
	!integer, parameter :: pblm = 17				! 17=g.dat
	!integer, parameter :: nx = 96				! nx cells => nx+1 nodes
	!integer, parameter :: ny = 56				! ny cells => ny+1 nodes
	!real(8), parameter :: Lx = 1.0, Ly = 1.0	
	
	real(8), parameter :: tstart = 0.0, tstop = 1.0  ! start,stop times
	integer, parameter :: niter = 1E6			! max num iter for elliptic solver
	integer, parameter :: iteropt = 2			! 1=Jacobi, 2=GS/SOR
	real(8), parameter :: omega = 1.2			! relaxation parameter for SOR
	real(8), parameter :: tol = 1E-2			! residual tolerance
	!real(8), parameter :: cfl = 1.0			

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

	!real(8), dimension(2,2,nx,ny) :: Linv	! gradient least sq inverse matrix

	real(8), dimension(0:nx+1,0:ny+1) :: dpa,dpb,dpc	! pressure correction a,b,c
	
	real(8), dimension(0:nx+1,0:ny+1) :: u,v,p	! sln(k): u vel, v vel, p pressure
	real(8), dimension(0:nx+1,0:ny+1) :: un,vn,pn	! sln(k+1)
	real(8), dimension(0:nx+1,0:ny+1) :: dudt,dvdt,dpdt	! sln,p time derivatives
	real(8), dimension(0:nx+1,0:ny+1) :: dveldt ! vel* divergence (not zero)
	real(8), dimension(nx,ny) :: dpdx,dpdy ! pressure x,y derivatives

	integer :: i,j,k							! reserve i,j,k for indexing

contains

!==============================================================================
! generate or read in the grid/mesh
!==============================================================================
subroutine grid_setup

	real(8) :: dx,dy			! delta x,y for uniform grids
	
	! uniform grid
	if (pblm.eq.1) then
		dx = Lx/nx
		dy = Ly/ny
		write(*,*) dx,dy

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
		!write(*,*) i,j,vol(i,j)
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
	! ======================================	
	
	! pressure correction initialize a,b,c
	do j = 0,ny+1
	do i = 0,nx+1
		dpa(i,j) = 0.0
		dpb(i,j) = 0.0
		dpc(i,j) = 0.0
	end do
	end do

	! loop i faces
	do j = 1,ny
	do i = 1,nx+1
		xf_i(i,j) = 0.5*(xn(i,j)+xn(i,j+1))
		yf_i(i,j) = 0.5*(yn(i,j)+yn(i,j+1))

		area_i(i,j) = sqrt((yn(i,j+1)-yn(i,j))**2 + (xn(i,j+1)-xn(i,j))**2)

		nhat_i(1,i,j) = (yn(i,j+1)-yn(i,j)) / area_i(i,j)
		nhat_i(2,i,j) = -(xn(i,j+1)-xn(i,j)) / area_i(i,j)

		dinv_i(i,j) = 1/sqrt((xc(i,j)-xc(i-1,j))**2 + (yc(i,j)-yc(i-1,j))**2)
	
		! pressure correction a,b,c
		! since normals are squared/multiplied, both ops are +
		dpa(i-1,j) = dpa(i-1,j) + (nhat_i(1,i,j)**2)*(area_i(i,j)**2)
		dpa(i,j) = dpa(i,j) + (nhat_i(1,i,j)**2)*(area_i(i,j)**2)

!if (j.eq.2) then
	!write(*,*) 'dpa(',i,',',j,') = ',dpa(i,j)
!end if
		
		dpb(i-1,j) = dpb(i-1,j) + nhat_i(1,i,j)*nhat_i(2,i,j)*(area_i(i,j)**2) 
		dpb(i,j) = dpb(i,j) + nhat_i(1,i,j)*nhat_i(2,i,j)*(area_i(i,j)**2) 
	
		dpc(i-1,j) = dpc(i-1,j) + (nhat_i(2,i,j)**2)*(area_i(i,j)**2)
		dpc(i,j) = dpc(i,j) + (nhat_i(2,i,j)**2)*(area_i(i,j)**2)
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

		dinv_j(i,j) = 1/sqrt((xc(i,j)-xc(i,j-1))**2 + (yc(i,j)-yc(i,j-1))**2)
	
		! pressure correction a,b,c	
		! since normals are squared/multiplied, both ops are +
		dpa(i,j-1) = dpa(i,j-1) + (nhat_j(1,i,j)**2)*(area_j(i,j)**2)
		dpa(i,j) = dpa(i,j) + (nhat_j(1,i,j)**2)*(area_j(i,j)**2)

!if (j.eq.2) then
	!write(*,*) 'dpa(',i,',',j,') = ',dpa(i,j)
!end if
		
		dpb(i,j-1) = dpb(i,j-1) + nhat_j(1,i,j)*nhat_j(2,i,j)*(area_j(i,j)**2) 
		dpb(i,j) = dpb(i,j) + nhat_j(1,i,j)*nhat_j(2,i,j)*(area_j(i,j)**2) 
	
		dpc(i,j-1) = dpc(i,j-1) + (nhat_j(2,i,j)**2)*(area_j(i,j)**2)
		dpc(i,j) = dpc(i,j) + (nhat_j(2,i,j)**2)*(area_j(i,j)**2)
	end do
	end do

!write(*,*) '**********************************$$$$'

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
		end if
	end do
	end do

end subroutine sln_setup

!==============================================================================
! apply boundary conditions
!==============================================================================
subroutine apply_boundary_uv
use grid_data

	! Taylor-Green - periodic BCs
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
	end if

end subroutine apply_boundary_uv

subroutine apply_boundary_p
use grid_data

	! PPE - Taylor-Green - periodic BCs
	if (pblm.eq.1) then
		do i=1,nx
			p(i,ny+1) = p(i,1)  	! upper
			p(i,0) = p(i,ny)			! lower
		end do
		do j=1,ny
			p(0,j) = p(nx,j)			! left
			p(nx+1,j) = p(1,j)		! right
		end do	   
	end if

end subroutine apply_boundary_p

!==============================================================================
! dudt,dvdt = derivative/flux calculation (spatial discretization)
!				for nonlinear and viscous terms
!==============================================================================
subroutine ode_dudt_dvdt
use grid_data

	real(8) uf,vf,dudn,dvdn,veln

	! initialize the flux arrays (dudt = Nu+Vu, dvdt=Nv+Vv)
	! we don't really need the boundary flux values, but that's ok
	! simplifies the loops over faces to just calculate it too
	do j = 0,ny+1
	do i = 0,nx+1
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
		vf = 0.5*(v(i-1,j) + v(i,j))
		
		dudn = (u(i,j) - u(i-1,j))*dinv_i(i,j)
		dvdn = (v(i,j) - v(i-1,j))*dinv_i(i,j)
		
		veln = uf*nhat_i(1,i,j) + vf*nhat_i(2,i,j) ! vn = uf*nx + vf*ny
		
		dudt(i-1,j) = dudt(i-1,j) + (nu*dudn - veln*uf)*area_i(i,j)
		dvdt(i-1,j) = dvdt(i-1,j) + (nu*dvdn - veln*vf)*area_i(i,j)
		
		dudt(i,j) = dudt(i,j) + (nu*(-dudn) - (-veln)*uf)*area_i(i,j)
		dvdt(i,j) = dvdt(i,j) + (nu*(-dvdn) - (-veln)*vf)*area_i(i,j)
	end do
	end do

	! loop over horizontal j faces (normal points in j dir)
	! for face in between j-1 and j (that's how metrics are stored)
	do j = 1,ny+1
	do i = 1,nx
		uf = 0.5*(u(i,j-1) + u(i,j))
		vf = 0.5*(v(i,j-1) + v(i,j))
		
		dudn = (u(i,j) - u(i,j-1))*dinv_j(i,j)
		dvdn = (v(i,j) - v(i,j-1))*dinv_j(i,j)

		veln = uf*nhat_j(1,i,j) + vf*nhat_j(2,i,j)

		dudt(i,j-1) = dudt(i,j-1) + (nu*dudn - veln*uf)*area_j(i,j)
		dvdt(i,j-1) = dvdt(i,j-1) + (nu*dvdn - veln*vf)*area_j(i,j)
		
		dudt(i,j) = dudt(i,j) + (nu*(-dudn) - (-veln)*uf)*area_j(i,j)
		dvdt(i,j) = dvdt(i,j) + (nu*(-dvdn) - (-veln)*vf)*area_j(i,j)
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
	! we don't really need the boundary flux values, but that's ok
	! simplifies the loops over faces to just calculate it too
	do j = 0,ny+1
	do i = 0,nx+1
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

		dveldt(i-1,j) = dveldt(i-1,j) + velflux
		dveldt(i,j) = dveldt(i,j) - velflux
	end do
	end do

	! loop j faces
	do j = 1,ny+1
	do i = 1,nx
		uf = 0.5*(u(i,j-1) + u(i,j))
		vf = 0.5*(v(i,j-1) + v(i,j))

		veln = uf*nhat_j(1,i,j) + vf*nhat_j(2,i,j)

		velflux = veln*area_j(i,j)

		dveldt(i,j-1) = dveldt(i,j-1) + velflux
		dveldt(i,j) = dveldt(i,j) - velflux
	end do
	end do

	! calculate total vel divergence across cells only (no boundaries)
	! this should be close to zero when u,v are actual sln
	! will be greater than zero for u*,v*
	totaldiv = 0.0
	do j = 1,ny
	do i = 1,nx
		totaldiv = totaldiv + dveldt(i,j)
	end do
	end do
	write(*,*) 'total velocity divergence = ', totaldiv, 'dveldt(2,2)=',dveldt(2,2)

end subroutine ode_dveldt


!==============================================================================
! minimized dp/dx and dp/dy for pressure correction, using least squares
!==============================================================================
subroutine ode_dpdx_dpdy
use grid_data

	! RHS of two pressure correction eqns: sum(px*nx*Sf^2), pf=pn=p at face
	real(8) pf,pxdenom,pydenom
	real(8), dimension(0:nx+1,0:ny+1) :: dpx,dpy

	! zero out the RHS to begin with
	do j = 0,ny+1
	do i = 0,nx+1
		dpx(i,j) = 0.0
		dpy(i,j) = 0.0
	end do
	end do

	! loop i faces to build RHS
	do j = 1,ny
	do i = 1,nx+1
		pf = 0.5*(p(i-1,j) + p(i,j))  ! pf = pn = symmetric avg across face

		dpx(i-1,j) = dpx(i-1,j) + pf*nhat_i(1,i,j)*area_i(i,j)**2
		dpx(i,j) = dpx(i,j) + pf*(-nhat_i(1,i,j))*area_i(i,j)**2
		
		dpy(i-1,j) = dpy(i-1,j) + pf*nhat_i(2,i,j)*area_i(i,j)**2
		dpy(i,j) = dpy(i,j) + pf*(-nhat_i(2,i,j))*area_i(i,j)**2
	end do
	end do

	! loop j faces to finish building RHS
	do j = 1,ny+1
	do i = 1,nx
		pf = 0.5*(p(i,j-1) + p(i,j))

		dpx(i,j-1) = dpx(i,j-1) + pf*nhat_j(1,i,j)*area_j(i,j)**2
		dpx(i,j) = dpx(i,j) + pf*(-nhat_j(1,i,j))*area_j(i,j)**2
		
		dpy(i,j-1) = dpy(i,j-1) + pf*nhat_j(2,i,j)*area_j(i,j)**2
		dpy(i,j) = dpy(i,j) + pf*(-nhat_j(2,i,j))*area_j(i,j)**2
	end do
	end do

	! loop cells and solve for px,py
	! a*px+b*py=dpx, b*px+c*py=dpy
	! px = (b*dpy - c*dpx)/(b-ac)
	! py = (dpx - a*px)/b
	do j = 1,ny
	do i = 1,nx
		pxdenom = dpb(i,j)-dpa(i,j)*dpc(i,j)
		if (pxdenom.eq.0) then
			dpdx(i,j) = 0.0
		else
			dpdx(i,j) = (dpb(i,j)*dpy(i,j)-dpc(i,j)*dpx(i,j))/pxdenom
		end if

		pydenom = dpb(i,j)
		if (pydenom.eq.0) then
			dpdy(i,j) = 0.0
		else
			dpdy(i,j) = (dpx(i,j)-dpa(i,j)*dpdx(i,j))/pydenom
		end if
	end do
	end do

	!write(*,*) 'dpdx(2,2) = ',dpdx(2,2),' dpdy(2,2) = ',dpdy(2,2)

end subroutine ode_dpdx_dpdy

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
	dt = 0.001
	!dt = 0.1

end subroutine calc_dt

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
	
	real(8) :: t,dt
	integer :: tidx

	! set boundary conditions before calculating fluxes
	call apply_boundary_uv

	! initialize dudt,dvdt for first time step
	call ode_dudt_dvdt

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
		do j = 0,ny+1
		do i = 0,nx+1
			dudtprev(i,j) = dudt(i,j)
			dvdtprev(i,j) = dvdt(i,j)
		end do
		end do
write(*,*) 'dudtprev(2,2) = ',dudtprev(2,2),' dvdtprev(2,2) = ',dvdtprev(2,2)

		! set boundary conditions before calculating fluxes
		call apply_boundary_uv

		! calculate current dudt,dvdt
		call ode_dudt_dvdt
write(*,*) 'dudt(2,2) = ',dudt(2,2),' dvdt(2,2) = ',dvdt(2,2)
write(*,*) 'dt=',dt,'vol(2,2)=',vol(2,2)

		! calculate solution at time step t+dt using AB2 algorithm (predict)
		! and backfill into solution / update solution
		! this calculates u*,v*
		do j = 1,ny
		do i = 1,nx
			u(i,j) = u(i,j) + (dt/vol(i,j))*0.5*(3*dudt(i,j) - dudtprev(i,j))
			v(i,j) = v(i,j) + (dt/vol(i,j))*0.5*(3*dvdt(i,j) - dvdtprev(i,j))
		end do
		end do
write(*,*) 'u*(2,2) = ',u(2,2),' v*(2,2) = ',v(2,2)

		! calculate pressure from pressure poisson equation (pressure)
		! ss_poisson iterates to convergence, includes boundary conditions
		! assumes u*,v* are in u,v
		call ss_poisson(dt)
write(*,*) 'p(2,2) = ',p(2,2)

		! add back pressure gradient (correct)
		! currently u* is in u, so correct to get u(k+1)
		call ode_dpdx_dpdy
write(*,*) 'dpdx(2,2) = ',dpdx(2,2),' dpdy(2,2) = ',dpdy(2,2)
		do j = 1,ny
		do i = 1,nx
			u(i,j) = u(i,j) - dt*dpdx(i,j)
			v(i,j) = v(i,j) - dt*dpdy(i,j)
		end do
		end do

		! calculate the total velocity divergence
		!call ode_dveldt

write(*,*) 'u(2,2) = ',u(2,2),' v(2,2) = ',v(2,2),' p(2,2) = ',p(2,2)
write(*,*) '**************************************'
		! increment time - use a time index so we get to tstop
		! otherwise computer roundoff error causes us to quit early
		!t = t + dt
		t = tstart + (tidx*dt)
		tidx = tidx+1
	end do

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
	call ode_dveldt

	! iterate solution
	do k=1,niter
		res = 0.0

		! apply boundary conditions to current solution p
		call apply_boundary_p

write(*,*) 'dveldt(2,2)=',dveldt(2,2),'p(2,2)=',p(2,2)

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
			! assume density = 1
			!f = exp(-35*((xc(i,j)-x0)**2+(yc(i,j)-y0)**2))
			fint = dveldt(i,j)/dt

			! discretization rearrangement
			! (au's) - sigma*u = f*vol => u = (au's - f*vol)/sigma
			! or
			! (au's) - sigma*u = integral(f) => u = (au's - integral(f))/sigma
			! integrate over volume, divergence eqn transforms LHS to area
			! RHS (source term f(x,y,t)) still integrated over volume
			!	or specific to that f (integrating veln over faces for example)
			!pcur = (a1*p(i-1,j)+a2*p(i+1,j)+a3*p(i,j-1)+a4*p(i,j+1)-f*vol(i,j))/sigma
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
			!if (pcur-pold.gt..0001) then
				!write(*,*) i,j,pcur,pold
			!end if
		end do
		end do

write(*,*) 'p(2,2)=',p(2,2)

		! Jacobi copy new solution to current solution
		if (iteropt.eq.1) then
			do j=1,ny
			do i=1,nx
				p(i,j) = pn(i,j)
			end do
			end do
		end if

		! calculate residual for convergene
		res = sqrt(res)
		!write(*,*) res,p(2,2)
		!if (k.eq.1) then
			!resinit = sqrt(res)
			!write(*,*) resinit
			!write(*,*) '*************************************'
		!else
			!res = sqrt(res)/resinit
		!end if

		! write residual to file for plotting convergence
		!if (k.ne.1) then		
			!write(*,*) k,res
			!write(2,"(I8,E20.8)") k,res
		!end if

		!write(*,*) tol
		! break if convergence tolerance achieved
		!if (res.le.tol.and.k.ne.1) then
		if (res.le.tol) then
			!close(2)
			!write(*,*) '*************************************'
			!write(*,*) 'p(2,2) = ',p(2,2)
			exit
		end if
	end do

end subroutine ss_poisson

!==============================================================================
! subroutine to print out the solution with corresponding 1/2 grid pt values to file
! cell centered FV
!==============================================================================
subroutine print_sln_to_file
use grid_data

	open(1, file = 'finalprojdata/slndata.txt', status='replace')
	!write(1,*) 'i,x,u'
	do j = 1,ny
	do i = 1,nx
		!write(1,"(2I3,3F32.16)") i,j,xval,yval,u(i,j)
		write(1,"(2I5,5E20.8)") i,j,xc(i,j),yc(i,j),u(i,j),v(i,j),p(i,j)
	end do
	end do
	close(1)

end subroutine print_sln_to_file

!==============================================================================
! print out solution in a matrix form like viewing x-y axis
! ** only do for small nx,ny like 10x10
!==============================================================================
subroutine print_sln
use grid_data

	! print the top right corner
	!do j = ny+1,ny-5,-1

	! print the bottom left corner of u,v velocities
	write(*,*) 'solution for velocity (u,v)'	
	do j = 5,1,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		!do i = nx-5,nx+1
		do i = 1,5
			!write(*,"(A1,F6.4,A2)",advance="no") '(',u(i,j),') '
			write(*,"(A1,F7.4,A1,F7.4,A2)",advance="no") '(',u(i,j),',',v(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

	! print the bottom left corner of pressure
	write(*,*) 'solution for pressure'	
	do j = 5,1,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		!do i = nx-5,nx+1
		do i = 1,5
			!write(*,"(A1,F6.4,A2)",advance="no") '(',u(i,j),') '
			write(*,"(A1,F10.4,A2)",advance="no") '(',p(i,j),') '
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
! print out a grid metric like i,j,grid_x(i,j),grid_y(i,j)
!==============================================================================
subroutine print_grid2
use grid_data

	! cells.dat matching
	! File contains i,j,xc(i,j),yc(i,j),vol(i,j),Linv(1,1),Linv(1,2),Linv(2,1),Linv(2,2)
	! for -interior- cells (for grid 'g.dat': (nx,ny)=(96,56))
	do j=1,2
	do i=1,nx
		write(*,*) i,j,xc(i,j),yc(i,j),vol(i,j)
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

	! adams-bashforth method handles time stepping
	call sln_setup
	call print_sln
	call ode_ab2

	call print_sln

	!call print_sln_to_file

end program cfd

