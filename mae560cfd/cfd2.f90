! Andrew Navratil
! MAE 560 CFD - HW 3 Problem 2 - 1D diffusion

!==============================================================================
! module for reading/setting inputs and constants
!==============================================================================
module inputs
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	integer, parameter :: sc = 2	! 1 = RK4, 2 = Crank-Nicolson			

	integer, parameter :: n = 100				! n cells => n+1 nodes/faces
	!integer, parameter :: n = 200				! n cells => n+1 nodes/faces
	real(8), parameter :: gridlen = 10.0		! 0<=x<=10
	real(8), parameter :: h = gridlen/n			! delta x for 1D
	real(8), parameter :: tstart = 2.0			! starting time
	real(8), parameter :: tstop = 4.0			! stopping time
	!real(8), parameter :: cfl = 0.4				! CFL number
	!real(8), parameter :: cfl = 1.0				! CFL number
	real(8), parameter :: cfl = 5.0				! CFL number
	
	real(8), parameter :: d = 0.1				! diffusion coefficient
	real(8), parameter :: x0 = 5.0				! dye injection pt (t=0)
	
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
		u(i) = (1/sqrt(4*PI*d*tstart))*exp((-(xval-x0)**2)/(4*d*tstart)) 
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
	u(1) = 0.0		! BC
	u(n) = 0.0		! BC (check more on next project - is n a ghost cell?)
	u(0) = u(n-1)   ! ghost cell
	u(n+1) = u(2)	! ghost cell

end subroutine apply_boundary

!==============================================================================
! calculate time step
!	with stability restriction and CFL number (cfl = d*dt/h^2)
!==============================================================================
subroutine calc_dt(dt)
use inputs
implicit none

	real(8), intent(out) :: dt		! time step

	dt = cfl * 0.5*(h**2/d)

end subroutine calc_dt

!==============================================================================
! RK4 (time integration scheme)
!==============================================================================
subroutine ode_rk4(t,dt,u)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(0:n+1), intent(in out) :: u

	integer :: i
	real(8), dimension(n) :: k0, k1, k2, k3
	real(8), dimension(0:n+1) :: utmp1, utmp2, utmp3

	! fill k0, which is du for RK k0
	! need copies of u for each RK k*
	call ode_dudt(t,dt,u,k0)

	! fill k1, which is du for RK k1
	do i = 1,n
		utmp1(i) = u(i) + 0.5*dt*k0(i)
	end do
	call apply_boundary(utmp1)
	call ode_dudt(t + 0.5*dt,dt,utmp1,k1)

	! fill k2, which is du for RK k2
	do i = 1,n
		utmp2(i) = u(i) + 0.5*dt*k1(i)
	end do
	call apply_boundary(utmp2)
	call ode_dudt(t + 0.5*dt,dt,utmp2,k2)

	! fill k3, which is du for RK k3
	do i = 1,n
		utmp3(i) = u(i) + dt*k2(i)
	end do
	call apply_boundary(utmp3)
	call ode_dudt(t + dt,dt,utmp3,k3)

	! calculate solution at time step t+dt using RK4 algorithm
	! and backfill into solution / update solution
	do i = 1,n
		u(i) = u(i) + (1.0/6.0)*dt*(k0(i) + 2.0*k1(i) + 2.0*k2(i) + k3(i))
		if (i.eq.n/2) then
			print *, 't = ', t, ' u = ', u(i)
		end if
	end do
	call apply_boundary(u)

end subroutine ode_rk4

!==============================================================================
! Crank-Nicholson (time scheme) + 2nd order central 2nd deriv (space scheme)
!==============================================================================
subroutine ode_cn(t,dt,u)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(0:n+1), intent(in out) :: u

	integer :: i
	real(8),dimension(n) :: a,b,rhs
	real(8),dimension(n) :: un

	do i = 1,n
		a(i) = h/dt + d/h  ! main diagonal
		b(i) = -d/(2*h)	  ! sub and sup diagonals
		rhs(i) = (d/(2*h)) * (u(i+1) - 2.0*u(i) + u(i-1)) + (h*u(i)/dt)
	end do

	! don't need to do anything with implicit BCs here since they are 0 for this pblm
	!   and the tridiag already assumes 0 at those locations
	call solve_tridiag(b,a,b,rhs,un,n)

	do i = 1,n
		u(i) = un(i)
		if (i.eq.n/2) then
			print *, 't = ', t, ' u = ', u(i)
		end if
	end do
	
	call apply_boundary(u)

end subroutine ode_cn

!==============================================================================
! subroutine for Thomas algorithm to solve tridiagonal matrix eqn Ax=b
! ported from Dr. Subbareddy
! looks like local variables do take precedence over constants in fortran
! so we should be good with n,d,c being the same
!==============================================================================
subroutine solve_tridiag(a,b,c,d,x,n)
      implicit none
!        a - sub-diagonal (means it is the diagonal below the main diagonal)
!        b - the main diagonal
!        c - sup-diagonal (means it is the diagonal above the main diagonal)
!        d - right hand side
!        x - the answer
!        n - number of equations

        integer,intent(in) :: n
        real(8),dimension(n),intent(in) :: a,b,c,d
        real(8),dimension(n),intent(out) :: x
        real(8),dimension(n) :: cp,dp
        real(8) :: m
        integer i

! initialize c-prime and d-prime
        cp(1) = c(1)/b(1)
        dp(1) = d(1)/b(1)
! solve for vectors c-prime and d-prime
         do i = 2,n
           m = b(i)-cp(i-1)*a(i)
           cp(i) = c(i)/m
           dp(i) = (d(i)-dp(i-1)*a(i))/m
         enddo
! initialize x
         x(n) = dp(n)
! solve for x from the vectors c-prime and d-prime
        do i = n-1, 1, -1
          x(i) = dp(i)-cp(i)*x(i+1)
        end do

end subroutine solve_tridiag

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
		! 2nd order central 2nd deriv FV (same as FD)
		dudt(i) = (d/(h**2)) * (u(i+1) - 2.0*u(i) + u(i-1))
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

	write(filename,"(A18,I1,A4)") &
		'hw3data/slndata_2_',sc,'.dat'
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
		if (sc.eq.1) then
			call ode_rk4(t,dt,u)
		else if (sc.eq.2) then
			call ode_cn(t,dt,u)
		end if

		! increment time
		t = t + dt
	end do

	print *, 'final solution'
	call print_sln(u)

	call print_sln_to_file(grid,u)

end program cfd

