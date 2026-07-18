! Andrew Navratil
! MAE 560 CFD - HW 3 Problem 3 - 2D advection-diffusion

!==============================================================================
! module for reading/setting inputs and constants
!==============================================================================
module inputs
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	integer, parameter :: n = 100				! n cells => n+1 nodes/faces (nx=ny=n)
	real(8), parameter :: gridlen = 1.0			! Lx=Ly=1
	real(8), parameter :: h = gridlen/n			! delta x and delta y
	real(8), parameter :: tstart = 0.0			! starting time
	!real(8), parameter :: tstop = 0.5			! stopping time
	real(8), parameter :: tstop = 5.0			! stopping time
	real(8), parameter :: cfl = 1.0				! CFL number

	real(8), parameter :: c = 1.0				! wave speed (c1=u=c2=v=c=1)
	real(8), parameter :: d = 0.005				! diffusion coefficient (kappa in hw)

end module inputs

!==============================================================================
! module for procedures
!==============================================================================
module procedures
implicit none
contains

!==============================================================================
! subroutine for generating/reading grid/mesh
!==============================================================================
subroutine grid_setup(grid)
use inputs
implicit none

	real(8), dimension(n+1,n+1,2), intent(out) :: grid

	integer :: i,j

	! fill grid where data values will be at nodes
	! for FV, cell centers are at 1/2 indices (cell faces are at nodes)
	do j = 1,n+1
	do i = 1,n+1
		grid(i,j,1) = (i-1)*h
		grid(i,j,2) = (j-1)*h
	end do
	end do

end subroutine grid_setup

!==============================================================================
! subroutine for initializing solution
!==============================================================================
subroutine sln_setup(u,grid)
use inputs
implicit none

	real(8), dimension(0:n+1,0:n+1), intent(out) :: u
	real(8), dimension(n+1,n+1,2), intent(in) :: grid

	integer :: i,j
	real(8) :: xval, yval, r2

	do j = 1,n+1
	do i = 1,n+1
		xval = grid(i,j,1)
		yval = grid(i,j,2)
		
		r2 = (xval-0.5)**2 + (yval-0.5)**2
		
		u(i,j) = exp(-300*r2)
	end do
	end do

	call apply_boundary(u)

end subroutine sln_setup

!==============================================================================
! apply boundary conditions
!==============================================================================
subroutine apply_boundary(u)
use inputs
implicit none
	real(8), dimension(0:n+1,0:n+1), intent(in out) :: u
	
	integer :: i,j

	! periodic boundary condition and fill ghost cells
	! look into this more soon - we don't calculate T(Lx,y)
	!    but we do calculate T(0,y) corresponds to u(1,j)
	! corners don't matter, never used
	do i = 0,n+1
		u(i,n) = u(i,1)    ! this is the BC given in HW (possibly?)
		u(i,0) = u(i,n-1)  ! ghost cell
		u(i,n+1) = u(i,2)  ! ghost cell
	end do
	do j = 0,n+1
		u(n,j) = u(1,j)    ! this is the BC given in HW (possibly?)
		u(0,j) = u(n-1,j)  ! ghost cell
		u(n+1,j) = u(2,j)  ! ghost cell
	end do	   

end subroutine apply_boundary

!==============================================================================
! calculate time step based on stability restriction and CFL number
!==============================================================================
subroutine calc_dt(dt)
use inputs
implicit none

	real(8), intent(out) :: dt		! time step
	
	real(8) :: dt1, dt2

	dt1 = cfl*h/abs(c)			! advection restriction
	dt2 = cfl * (h**2/(2*d))	! diffusion restriction
	!dt = min(dt1,dt2)
	dt = 0.001

end subroutine calc_dt

!==============================================================================
! Adams-Bashforth 2nd order for 2D
! 2D advection-diffusion
!	compact formula for normal derivative (diffusion 2nd deriv term in FV)
!	central differencing scheme (convection 1st deriv term FV/FD)
!==============================================================================
subroutine ode_ab2(dt,u)
use inputs
implicit none

	real(8), intent(in) :: dt
	real(8), dimension(0:n+1,0:n+1), intent(in out) :: u

	! store previous time step and current time step dudt
	real(8), dimension(n,n,2) :: dudt
	
	real(8) :: t
	integer :: i,j

	! initialize dudt for first time step
	! let's see if passing dudt can work like this for 2d array portion of 3d
	!    looks good so far from debugging..
	call ode_dudt(tstart,dt,u,dudt(:,:,1))

	! time stepping in here so we can save data from any step
	t = tstart + dt
	do while (t.le.tstop)
		! move current dudt (1) to previous dudt (2)
		do j = 1,n
		do i = 1,n
			dudt(i,j,2) = dudt(i,j,1)
		end do
		end do

		! calculate current dudt (1)
		call ode_dudt(t,dt,u,dudt(:,:,1))

		! calculate solution at time step t+dt using AB2 algorithm
		! and backfill into solution / update solution
		do j = 1,n
		do i = 1,n
			u(i,j) = u(i,j) + 0.5*h*dt*(3*dudt(i,j,1) - dudt(i,j,2))
		end do
		end do

		call apply_boundary(u)

		t = t + dt
	end do

end subroutine ode_ab2

!==============================================================================
! dudt = RHS derivative calculation (spatial discretization)
!==============================================================================
subroutine ode_dudt(t,dt,u,dudt)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(0:n+1,0:n+1), intent(in) :: u
	real(8), dimension(n,n), intent(out) :: dudt

	integer :: i,j

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
	do j = 1,n
	do i = 1,n
		dudt(i,j) = ((-c/(2*h)) * (u(i+1,j)-u(i-1,j)+u(i,j+1)-u(i,j-1))) &
			+ ((d/(h**2)) * (u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1)-4*u(i,j)))
	end do
	end do

end subroutine ode_dudt

!==============================================================================
! subroutine to print out the solution with corresponding 1/2 grid pt values to file
!==============================================================================
subroutine print_sln_to_file(grid,u)
use inputs
implicit none

	real(8), dimension(n+1,n+1,2), intent(in) :: grid
	real(8), dimension(0:n+1,0:n+1), intent(in) :: u
	character(len=50) :: filename
	integer :: i,j
	real(8) :: xval, yval

	open(1, file = 'hw3data/slndata_3.dat', status='replace')
	!write(1,*) 'i,x,u'
	do j = 1,n
	do i = 1,n
		xval = grid(i,j,1)+0.5*h
		yval = grid(i,j,2)+0.5*h
		!write(1,"(2I3,3F32.16)") i,j,xval,yval,u(i,j)
		write(1,"(2I3,3E20.8)") i,j,xval,yval,u(i,j)
	end do
	end do
	close(1)

end subroutine print_sln_to_file

!==============================================================================
! subroutine to print out the solution to console
!==============================================================================
subroutine print_sln(u)
use inputs
implicit none

	real(8), dimension(0:n+1,0:n+1), intent(in) :: u
	integer :: i,j

	do i = 0,n+1
		write(*,"(I3,A1)",advance="no") i,' '  ! advacne=no will not write newline

		do j = 0,n+1
			!write(*,"(F8.4,A1)",advance="no") u(i,j),' '
			write(*,"(E15.8,A1)",advance="no") u(i,j),' '
		end do

		write(*,*)  ! write out the new line
	end do

end subroutine print_sln

!====================
end module procedures
!====================

!******************************************************************************
! main cfd solver program
!******************************************************************************
program cfd
use inputs
use procedures
implicit none

	real(8), dimension(n+1,n+1,2) :: grid	! grid 2D: (1) is i/x, (2) is j/y
	real(8), dimension(0:n+1,0:n+1) :: u	! sln 2D
	real(8) :: dt							! time step (delta t)

	call grid_setup(grid)
	call sln_setup(u,grid)
	call calc_dt(dt)

	write(*,"(A4,F10.5)") 'h = ',h
	write(*,"(A5,F10.5)") 'dt = ',dt
	call print_sln(u)
	!call print_sln_to_file(grid,u)  ! write out init cond
	
	! adams-bashforth method handles the time stepping as well
	!   since it needs data from previous time steps
	call ode_ab2(dt,u)

	call print_sln(u)

	call print_sln_to_file(grid,u)

end program cfd

