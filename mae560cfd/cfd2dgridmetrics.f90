! Andrew Navratil
! MAE 560 HW4 - 2D Laplace and Poisson

!==============================================================================
! module for reading/setting constants, inputs, grid data and metrics
!==============================================================================
module grid_data
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	! constants	===============================
	! hard code number of cells for performance
	! look in dat file for numbers (will be nx+1,ny+1 values)
	!integer, parameter :: pblm = 1				! 1=uniform
	!integer, parameter :: nx = 10				! nx cells => nx+1 nodes
	!integer, parameter :: ny = 10				! ny cells => ny+1 nodes
	integer, parameter :: pblm = 2				! 2=grids/g.dat
	integer, parameter :: nx = 96				! nx cells => nx+1 nodes
	integer, parameter :: ny = 56				! ny cells => ny+1 nodes
	
	real(8), parameter :: gridlen = 1.0			! Lx=Ly=1
	real(8), parameter :: h = gridlen/nx		! delta x and delta y
	real(8), parameter :: tstart = 0.0			! starting time
	!real(8), parameter :: tstop = 0.5			! stopping time
	real(8), parameter :: tstop = 5.0			! stopping time
	real(8), parameter :: cfl = 1.0				! CFL number

	real(8), parameter :: c = 1.0				! wave speed (c1=u=c2=v=c=1)
	real(8), parameter :: d = 0.005				! diffusion coefficient (kappa in hw)

	! global variables ========================
	! using 1 pair of ghost cells
	real(8), dimension(1:nx+1,1:ny+1) :: xn		! grid node x-coordinates
	real(8), dimension(1:nx+1,1:ny+1) :: yn		! grid node y-coordinates

	real(8), dimension(0:nx+1,0:ny+1) :: xc		! cell center x-coordinates
	real(8), dimension(0:nx+1,0:ny+1) :: yc		! cell center y-coordinates

	real(8), dimension(1:nx+1,1:ny) :: xf_i		! face center i dir x-coordinates
	real(8), dimension(1:nx+1,1:ny) :: yf_i		! face center i dir y-coordinates
	real(8), dimension(1:nx,1:ny+1) :: xf_j		! face center j dir x-coordinates
	real(8), dimension(1:nx,1:ny+1) :: yf_j		! face center j dir y-coordinates
	
	real(8), dimension(1:nx+1,1:ny) :: area_i	! face area i dir 
	real(8), dimension(1:nx,1:ny+1) :: area_j	! face area j dir 

	real(8), dimension(2,1:nx+1,1:ny) :: nhat_i	! face normal i dir
	real(8), dimension(2,1:nx,1:ny+1) :: nhat_j	! face normal j dir

	real(8), dimension(1:nx,1:ny) :: vol		! cell volume

	real(8), dimension(1:nx+1,1:ny) :: dinv_i	! cell distance inverse across i face
	real(8), dimension(1:nx,1:ny+1) :: dinv_j	! cell distance inverse across j face

	real(8), dimension(2,2,1:nx,1:ny) :: Linv	! gradient least sq inverse matrix

	real(8), dimension(0:nx+2,0:ny+2) :: u		! sln
	real(8), dimension(nx+1,ny+1) :: dudt		! sln 1st derivative du/dt

	real(8) :: dt								! time step (delta t)
	
	integer :: i,j,k							! reserve i,j,k for indexing

contains

!==============================================================================
! calculate time step based on stability restriction and CFL number
!==============================================================================
subroutine calc_dt
	
	real(8) :: dt1, dt2

	dt1 = cfl*h/c				! advection restriction
	dt2 = cfl*(h**2/(2*d))			! diffusion restriction
	dt = min(dt1,dt2)
	!dt = 0.001

end subroutine calc_dt

!==============================================================================
! generate or read in the grid/mesh
!==============================================================================
subroutine grid_setup

	! uniform grid
	if (pblm.eq.1) then
		! fill grid where data values will be at nodes
		! for FV, cell centers are at 1/2 indices (cell faces are at nodes)
		do j = 1,ny+1
		do i = 1,nx+1
			xn(i,j) = (i-1)*h
			yn(i,j) = (j-1)*h
		end do
		end do
	! g.dat
	else if (pblm.eq.2) then
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
	do j = 1,ny
	do i = 1,nx
		xc(i,j) = 0.25*(xn(i,j)+xn(i+1,j)+xn(i+1,j+1)+xn(i,j+1))
		yc(i,j) = 0.25*(yn(i,j)+yn(i+1,j)+yn(i+1,j+1)+yn(i,j+1))

		vol(i,j) = 0.5*abs((xn(i+1,j+1)-xn(i,j))*(yn(i,j+1)-yn(i+1,j)) &
			-(xn(i,j+1)-xn(i+1,j))*(yn(i+1,j+1)-yn(i,j)))
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
	! face based metrics
	! ======================================	
	! i faces
	do j = 1,ny
	do i = 1,nx+1
		xf_i(i,j) = 0.5*(xn(i,j)+xn(i,j+1))
		yf_i(i,j) = 0.5*(yn(i,j)+yn(i,j+1))

		area_i(i,j) = sqrt((yn(i,j+1)-yn(i,j))**2 + (xn(i,j+1)-xn(i,j))**2)

		nhat_i(1,i,j) = (yn(i,j+1)-yn(i,j)) / area_i(i,j)
		nhat_i(2,i,j) = -(xn(i,j+1)-xn(i,j)) / area_i(i,j)

		dinv_i(i,j) = 1/sqrt((xc(i,j)-xc(i-1,j))**2 + (yc(i,j)-yc(i-1,j))**2)
	end do
	end do

	! j faces
	do j = 1,ny+1
	do i = 1,nx
		xf_j(i,j) = 0.5*(xn(i,j)+xn(i+1,j))
		yf_j(i,j) = 0.5*(yn(i,j)+yn(i+1,j))

		area_j(i,j) = sqrt((yn(i,j)-yn(i+1,j))**2 + (xn(i,j)-xn(i+1,j))**2)

		nhat_j(1,i,j) = (yn(i,j)-yn(i+1,j)) / area_j(i,j)
		nhat_j(2,i,j) = -(xn(i,j)-xn(i+1,j)) / area_j(i,j)

		dinv_j(i,j) = 1/sqrt((xc(i,j)-xc(i,j-1))**2 + (yc(i,j)-yc(i,j-1))**2)
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
! subroutine for initializing solution (node centered)
!==============================================================================
subroutine sln_setup
use grid_data

	do j = 1,ny+1
	do i = 1,nx+1
		u(i,j) = exp(-300*((xn(i,j)-0.5)**2 + (yn(i,j)-0.5)**2))
	end do
	end do

	!call apply_boundary(u)

end subroutine sln_setup

!==============================================================================
! apply boundary conditions
!==============================================================================
subroutine apply_boundary
use grid_data

	do i = 0,nx+2
		u(i,1) = u(i,ny+1)    ! periodic BC (positive wavespeed)
		u(i,0) = u(i,ny)  ! ghost cell
		u(i,ny+2) = u(i,2)  ! ghost cell
	end do
	do j = 0,ny+2
		u(1,j) = u(nx+1,j)    ! periodic BC (positive wavespeed)
		u(0,j) = u(nx,j)  ! ghost cell
		u(nx+2,j) = u(2,j)  ! ghost cell
	end do	   

end subroutine apply_boundary

!==============================================================================
! dudt = RHS derivative calculation (spatial discretization)
!==============================================================================
subroutine ode_dudt
use grid_data

	! use algorithm from lecture 12 so not doubling the computational work
	! using simplifications for equi spaced cartesian grid
	!   normals are +-1 or 0 for nx or ny, cell distaces are just h (h=dy=dist)
	!   nx = n, ny = n; area = length of face in 2D = dy or dx = h
	! loop over i faces (i face means normal points in i / x dir) so area is dy
	!do j = 1,n
	!do i = 1,n+1
		!!c = c1*nx + c2*ny => c=c for nx=+1 (+i dir) and ny=0 (+j dir)
		!dudn = (u(i,j) - u(i-1,j)) / h; ! equidistant => dist(i to i-1) = h
		!flux = ((-c*(u(i,j) + u(i-1,j))*0.5) + d*dudn) * h;
		!dudt(i-1,j) = dudt(i-1,j) + flux
		!dudt(i,j) = dudt(i,j) - flux
	!end do
	!end do

	! now would need to loop over j faces...

	! but let's just use the uniform grid example method for now
	do j = 1,ny+1
	do i = 1,nx+1
		dudt(i,j) = ((-c/(2*h)) * (u(i+1,j)-u(i-1,j)+u(i,j+1)-u(i,j-1))) &
			+ ((d/(h**2)) * (u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1)-4*u(i,j)))
	end do
	end do

end subroutine ode_dudt

!==============================================================================
! Adams-Bashforth 2nd order for 2D
! 2D advection-diffusion
!	compact formula for normal derivative (diffusion 2nd deriv term in FV)
!	central differencing scheme (convection 1st deriv term FV/FD)
!==============================================================================
subroutine ode_ab2
use grid_data

	! store previous time step and current time step dudt
	real(8), dimension(nx+1,ny+1) :: dudtprev
	
	real(8) :: t
	integer :: tidx

	! initialize dudt for first time step
	call ode_dudt

	! time stepping in here so we can save data from any step
	! note: we already initialized at time tstart
	t = tstart + dt
	tidx = 2
	do while (t.le.tstop)
		! move current dudt (1) to previous dudt (2)
		do j = 1,ny+1
		do i = 1,nx+1
			dudtprev(i,j) = dudt(i,j)
		end do
		end do

		! calculate current dudt (1)
		call ode_dudt

		! calculate solution at time step t+dt using AB2 algorithm
		! and backfill into solution / update solution
		do j = 1,ny+1
		do i = 1,nx+1
			u(i,j) = u(i,j) + 0.5*h*dt*(3*dudt(i,j) - dudtprev(i,j))
		end do
		end do

		call apply_boundary

		! increment time - use a time index so we get to tstop
		! otherwise computer roundoff error causes us to quit early
		!t = t + dt
		t = tstart + (tidx*dt)
		tidx = tidx+1
	end do

end subroutine ode_ab2

!==============================================================================
! subroutine to print out the solution with corresponding 1/2 grid pt values to file
!==============================================================================
subroutine print_sln_to_file
use grid_data

	open(1, file = 'hw3data/slndata_3.dat', status='replace')
	!write(1,*) 'i,x,u'
	do j = 1,ny+1
	do i = 1,nx+1
		!write(1,"(2I3,3F32.16)") i,j,xval,yval,u(i,j)
		write(1,"(2I5,3E20.8)") i,j,xn(i,j),yn(i,j),u(i,j)
	end do
	end do
	close(1)

end subroutine print_sln_to_file

!==============================================================================
! print out a grid metric in a matrix form (only do for small nx,ny like 10x10)
!==============================================================================
subroutine print_grid
use grid_data

	do j = ny+1,0,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		do i = 0,nx+1
			write(*,"(A1,F4.2,A1,F4.2,A2)",advance="no") '(',xc(i,j),',',yc(i,j),') '
			!write(*,"(E15.8,A1)",advance="no") grid(i,j),' '
		end do

		write(*,*)  ! write out the new line
	end do

end subroutine print_grid

!==============================================================================
! print out a grid metric like i,j,grid_x(i,j),grid_y(i,j)
!==============================================================================
subroutine print_grid2
use grid_data

	! cells.dat matching
	! File contains i,j,xc(i,j),yc(i,j),vol(i,j),Linv(1,1),Linv(1,2),Linv(2,1),Linv(2,2)
	! for -interior- cells (for grid 'g.dat': (nx,ny)=(96,56))
	!do j=1,2
	!do i=1,nx
		!write(*,*) i,j,xc(i,j),yc(i,j)
	!end do
	!end do

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
	!do j=1,2
	!do i=1,nx
		!write(*,*) i,j,xf_j(i,j),yf_j(i,j),area_j(i,j),nhat_j(1,i,j),nhat_j(2,i,j) &
			!,dinv_j(i,j)
	!end do
	!end do

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

	call calc_dt
	call grid_setup
	call grid_metrics

	write(*,"(A4,F10.5)") 'h = ',h
	write(*,"(A5,F10.5)") 'dt = ',dt
	call print_grid2
	!call print_sln_to_file(grid,u)  ! write out init cond
	
	! adams-bashforth method handles the time stepping as well
	!   since it needs data from previous time steps
	!call sln_setup
	!call ode_ab2

	!call print_sln

	!call print_sln_to_file

end program cfd

