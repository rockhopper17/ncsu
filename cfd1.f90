! Andrew Navratil
! MAE 560 CFD - HW 3 Problem 1 - 1D advection

!==============================================================================
! module for reading/setting inputs and constants
!==============================================================================
module inputs
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	integer, parameter :: ic = 1	! 1 = square, 2 = sin, 3 = Gaussian
	integer, parameter :: sc = 2	! 1 = central, 2 = upwind			

	integer, parameter :: n = 100				! n cells => n+1 nodes/faces (nx=ny=n)
	real(8), parameter :: gridlen = 1.0			! periodic domain of unit length
	real(8), parameter :: h = gridlen/n			! delta x for 1D
	real(8), parameter :: tstart = 0.0			! starting time
	real(8), parameter :: tstop = 1.0			! stopping time
	!real(8), parameter :: cfl = 0.4			! CFL number
	real(8), parameter :: cfl = 1.0			! CFL number
	!real(8), parameter :: cfl = 1.3			! CFL number
	!real(8), parameter :: cfl = 5.0			! CFL number
	
	real(8), parameter :: c = 1.0				! wave speed (c or a)
	!real(8), parameter :: ksin = 1.0			! k value for sin 
	real(8), parameter :: ksin = 5.0			! k value for sin
	!real(8), parameter :: ksin = 10.0			! k value for sin

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
! note: subroutines modify input variables
!		functions only return a single value
!		modules are for global data or putting subroutines in another file
!			or for generating explicit interfaces for procedures (subroutine/func)
! https://www.tutorialspoint.com/fortran/fortran_arrays.htm
subroutine grid_setup(grid)
use inputs
implicit none

	! grid (1D is just array for x values)
	real(8), dimension(n+1), intent(out) :: grid

	! local variables
	integer :: i

	! fill grid where data values will be at nodes
	! for FV, cell centers are at 1/2 indices (cell faces are at nodes)
	do i = 1,n+1
		grid(i) = (i-1)*h
	end do

end subroutine grid_setup

!==============================================================================
! subroutine for initializing solution
!==============================================================================
subroutine sln_setup(u,grid)
use inputs
implicit none

	real(8), dimension(0:n+1), intent(out) :: u
	real(8), dimension(n+1), intent(in) :: grid

	integer :: i
	real(8) :: xval

	! initialize solution based on init cond (ic)
	do i = 1,n
		xval = grid(i)
		! square wave
		if (ic.eq.1) then
			if (xval.ge.0.25.and.xval.le.0.75) then
				u(i) = 1.0
			else
				u(i) = 0.0
			end if
		! sine wave
		else if (ic.eq.2) then
			u(i) = sin(2.0*PI*ksin*xval)
		! Gaussian
		else if (ic.eq.3) then
			u(i) = exp(-50.0*((xval-0.5)**2))
		end if
	end do

	call apply_boundary(u)

end subroutine sln_setup

!==============================================================================
! apply boundary conditions
!==============================================================================
subroutine apply_boundary(u)
use inputs
implicit none
	real(8), dimension(0:n+1), intent(in out) :: u
	
	! periodic boundary condition and fill ghost cells
	u(n) = u(1)		! BC (check more on next project - is n a ghost cell?)
	u(0) = u(n-1)   ! ghost cell
	u(n+1) = u(2)	! ghost cell

end subroutine apply_boundary

!==============================================================================
! calculate time step
!	with stability restriction and CFL number (cfl = c*dt/h)
!==============================================================================
subroutine calc_dt(dt)
use inputs
implicit none

	real(8), intent(out) :: dt		! time step

	dt = cfl * h/abs(c)

end subroutine calc_dt

!==============================================================================
! RK3 (time integration scheme)
!==============================================================================
subroutine ode_rk3(t,dt,u)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(0:n+1), intent(in out) :: u

	integer :: i
	real(8), dimension(n) :: k0, k1, k2
	real(8), dimension(0:n+1) :: utmp1, utmp2

	! fill k0, which is dudt for RK k0
	! need copies of u for each RK k*
	call ode_dudt(t,dt,u,k0)

	! fill k1, which is dudt for RK k1
	do i = 1,n
		utmp1(i) = u(i) + 0.5*dt*k0(i)
	end do
	call apply_boundary(utmp1)
	call ode_dudt(t + 0.5*dt,dt,utmp1,k1)

	! fill k2, which is dudt for RK k2
	do i = 1,n
		utmp2(i) = u(i) + 2.0*dt*k1(i) - dt*k0(i)
	end do
	call apply_boundary(utmp2)
	call ode_dudt(t + dt,dt,utmp2,k2)

	! calculate solution at time step t+dt using RK3 algorithm
	! and backfill into solution / update solution
	do i = 1,n
		u(i) = u(i) + (1.0/6.0)*dt*(k0(i) + 4.0*k1(i) + k2(i))
	end do
	call apply_boundary(u)

end subroutine ode_rk3

!==============================================================================
! dudt = RHS derivative calculation (spatial discretization)
!==============================================================================
subroutine ode_dudt(t,dt,u,dudt)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(0:n+1), intent(in) :: u
	real(8), dimension(n), intent(out) :: dudt

	integer :: i

	do i = 1,n
		! central FV (same as FD)
		if (sc.eq.1) then
			dudt(i) = (-c/(2*h)) * (u(i+1) - u(i-1))
		! 1st order upwind FV (same as backwards FD for +c)
		else if (sc.eq.2) then
			dudt(i) = (-c/h) * (u(i) - u(i-1))
		end if
	end do

end subroutine ode_dudt

!==============================================================================
! subroutine to print out the solution with corresponding 1/2 grid pt values to file
!==============================================================================
subroutine print_sln_to_file(grid,u)
use inputs
implicit none

	real(8), dimension(n+1), intent(in) :: grid
	real(8), dimension(0:n+1), intent(in) :: u
	character(len=50) :: filename
	integer :: i
	real(8) :: xval

	write(filename,"(A18,I1,A1,I1,A4)") &
		'hw3data/slndata_1_',ic,'_',sc,'.dat'
	open(1, file = filename, status='replace')
	!write(1,*) 'i,x,u'
	do i = 1,n
		!write(1,"(I3,2F20.16)") i,xval,u(i)
		write(1,"(I3,2E20.8)") i,grid(i),u(i)
	end do
	close(1)

end subroutine print_sln_to_file

!==============================================================================
! subroutine to print out the solution to console
!==============================================================================
subroutine print_sln(u)
use inputs
implicit none

	real(8), dimension(0:n+1), intent(in) :: u
	integer :: i

	do i = 0,n+1
		write(*,"(I3,E20.8)") i,u(i)
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

	integer :: i

	real(8), dimension(n+1) :: grid			! grid 1D
	real(8), dimension(0:n+1) :: u			! sln 1D
	real(8) :: t							! time val
	real(8) :: dt							! time step (delta t)
	
	call grid_setup(grid)
	print *,'h = ',h
	print *,'grid'
	write(*,"(F20.16)") grid
	
	call sln_setup(u,grid)
	print *, 'initial solution'
	call print_sln(u)
	
	call calc_dt(dt)
	print *, 'dt = ',dt

	! time marching - iterate solution from start to stop time
	! note: we already initialized at time tstart
	t = tstart + dt
	do while (t.le.tstop)
		!print *, t
		
		! perform time integration
		call ode_rk3(t,dt,u)

		! increment time
		t = t + dt
	end do

	print *, 'final solution'
	call print_sln(u)

	call print_sln_to_file(grid,u)

end program cfd

