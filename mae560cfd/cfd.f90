! Andrew Navratil
! MAE 560 CFD - HW 3 Problems 1,2 - 1D advection and diffusion

!==============================================================================
! module for reading/setting inputs and constants
!==============================================================================
module inputs
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	! problem 1
	!integer, parameter :: pblm = 1
	!integer, parameter :: ic = 3	! 1 = square, 2 = sin, 3 = Gaussian
	!integer, parameter :: sc = 2	! 1 = central, 2 = upwind			

	!integer, parameter :: n = 101				! n nodes => n-1 cells (node centered scheme)
	!real(8), parameter :: xlen = 1.0			! periodic domain of unit length
	!!real(8), parameter :: xlen = 5.0			! periodic domain of unit length
	!real(8), parameter :: dx = xlen/(n-1)		! delta x or h
	!real(8), parameter :: tstart = 0.0			! starting time
	!real(8), parameter :: tstop = 1.0			! stopping time
	!!real(8), parameter :: tstop = 0.5			! stopping time
	!!real(8), parameter :: cfl = 1.5				! CFL number for RK3 central
	!real(8), parameter :: cfl = 0.8				! CFL number for RK3 upwind
	
	real(8), parameter :: c = 1.0				! wave speed (c or a)
	real(8), parameter :: ksin = 1.0			! k value for sin (ic=2)
	!!real(8), parameter :: ksin = 5.0			! k value for sin (ic=2)
	!!real(8), parameter :: ksin = 10.0			! k value for sin (ic=2)
	
	! problem 2
	! don't forget to comment/uncomment out line in sln_setup (div by 0 on tstart)
	integer, parameter :: pblm = 2
	integer, parameter :: ic = 1				! 1 = 100 cells, 2 = 200 cells
	integer, parameter :: sc = 1				! 1 = RK4, 2 = Crank-Nicholson			

	integer, parameter :: n = 101				! n nodes => n-1 cells
	!integer, parameter :: n = 201				! n nodes => n-1 cells
	real(8), parameter :: xlen = 10.0			! 0<=x<=10
	real(8), parameter :: dx = xlen/(n-1)		! delta x or h
	real(8), parameter :: tstart = 2.0			! starting time
	real(8), parameter :: tstop = 4.0			! stopping time
	!real(8), parameter :: cfl = 0.4				! CFL number
	real(8), parameter :: cfl = 5.0				! large CFL number for CN
	
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
! https://www.tutorialspoint.com/fortran/fortran_arrays.htm
subroutine grid_setup(x)
use inputs
implicit none

	! grid (1D is just array for x values)
	real(8), dimension(n), intent(out) :: x

	! local variables
	integer :: i

	! fill grid where data values will be at nodes
	! for FV, cell centers are at 1/2 indices (cell faces are at nodes)
	!if (pblm.eq.1) then
		do i = 1,n
			x(i) = (i-1)*dx
		end do
	!end if

end subroutine grid_setup

!==============================================================================
! subroutine for initializing solution
!==============================================================================
subroutine sln_setup(u,x)
use inputs
implicit none

	real(8), dimension(0:n+1), intent(out) :: u
	real(8), dimension(n), intent(in) :: x

	integer :: i
	real(8) :: xval

	! initialize solution based on init cond (ic)
	do i = 1,n
		if (pblm.eq.1) then
			! square wave
			if (ic.eq.1) then
				if (x(i).ge.0.25.and.x(i).le.0.75) then
					u(i) = 1.0
				else
					u(i) = 0.0
				end if
			! sine wave
			else if (ic.eq.2) then
				u(i) = sin(2.0*PI*ksin*x(i))
			! Gaussian
			else if (ic.eq.3) then
				u(i) = exp(-50.0*((x(i)-0.5)**2))
			end if
		else if (pblm.eq.2) then
			! Cexact for dye injection diffusion eqn
			u(i) = (1/sqrt(4*PI*d*tstart))*exp((-(x(i)-x0)**2)/(4*d*tstart)) 
		end if
	end do

end subroutine sln_setup

!==============================================================================
! apply boundary conditions
!==============================================================================
subroutine apply_boundary(u)
use inputs
implicit none
	real(8), dimension(0:n+1), intent(in out) :: u

	! set boundary conditions	
	if (pblm.eq.1) then
		u(1) = u(n)		! periodic BC (wave moving right)
	else if (pblm.eq.2) then
		u(1) = 0.0			! fixed BC
		u(n) = 0.0			! fixed BC
	end if

	! fill in ghost cells
	u(0) = u(n-1)
	u(n+1) = u(2)

end subroutine apply_boundary

!==============================================================================
! calculate time step
!	with stability restriction and CFL number (cfl = c*dt/dx)
!==============================================================================
subroutine calc_dt(dt)
use inputs
implicit none

	real(8), intent(out) :: dt		! time step

	! pblm 1: 1D advection
	if (pblm.eq.1) then
		dt = cfl * (dx/c)
	! pblm 2: 1D diffusion
	else if (pblm.eq.2) then
		dt = cfl * (dx**2/d)
	end if

end subroutine calc_dt

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

	! pblm 1: 1D advection
	if (pblm.eq.1) then
		do i = 1,n
			! central FV (same as FD)
			if (sc.eq.1) then
				!print *,'here'
				dudt(i) = (-c/(2*dx)) * (u(i+1) - u(i-1))
			! 1st order upwind FV for +c (same as backwards FD)
			else if (sc.eq.2) then
				dudt(i) = (-c/(dx)) * (u(i) - u(i-1))
			end if
		end do
	! pblm 2: 1D diffusion
	else if (pblm.eq.2) then
		do i = 1,n
			! 2n order central 2nd deriv FV (same as FD)
			dudt(i) = (d/(dx**2)) * (u(i+1) - 2.0*u(i) + u(i-1))
		end do
	end if

end subroutine ode_dudt

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

end subroutine ode_rk3

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
		utmp2(i) = u(i) + 0.5*dt*k1(i)
	end do
	call apply_boundary(utmp2)
	call ode_dudt(t + 0.5*dt,dt,utmp2,k2)

	! fill k3, which is dudt for RK k3
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
		a(i) = dx/dt + d/dx  ! main diagonal
		b(i) = -d/(2*dx)	  ! sub and sup diagonals
		rhs(i) = (d/(2*dx)) * (u(i+1) - 2.0*u(i) + u(i-1)) + (dx*u(i)/dt)
	end do

	call solve_tridiag(b,a,b,rhs,un,n)

	do i = 1,n
		u(i) = un(i)
		if (i.eq.(n-1)/2) then
			print *, 't = ', t, ' u = ', u(i)
		end if
	end do

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
! subroutine to print out the solution to a file with grid
!==============================================================================
subroutine print_sln_to_file(x,u)
use inputs
implicit none

	real(8), dimension(n), intent(in) :: x
	real(8), dimension(0:n+1), intent(in) :: u
	character(len=50) :: filename
	integer :: i

	write(filename,"(A16,I1,A1,I1,A1,I1,A4)") &
		'hw3data/slndata_',pblm,'_',ic,'_',sc,'.dat'
	open(1, file = filename, status='replace')
	do i = 1,n
		write(1,"(I3,2E20.8)") i,x(i),u(i)
		!write(1,"(I3,2F20.16)") i,x(i),u(i)
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
		!write(*,"(I3,F20.16)") i,u(i)
		!print *, 'i = ', i, ' u = ', u(i)
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

	integer :: i,tidx
	real(8), dimension(n) :: x				! grid
	real(8), dimension(0:n+1) :: u			! sln
	real(8) :: t							! time val
	real(8) :: dt							! time step (delta t)
	
	call grid_setup(x)
	write(*,"(A5,F8.5)") 'dx = ',dx
	write(*,"(F20.16)") x
	
	call sln_setup(u,x)
	call apply_boundary(u)
	print *, 'initial solution'
	call print_sln(u)
	
	call calc_dt(dt)
	write(*,"(A5,F8.5)") 'dt = ',dt

	! time marching - iterate solution from start to stop time
	! note: we already initialized at time tstart
	write(*,"(2E20.8)") tstart,u(1)
	t = tstart + dt
	tidx = 2
	do while (t.le.tstop)
		!print *,t,' ',tstop
		!print *, t
		
		! apply boundary conditions / fill ghost cells
		call apply_boundary(u)
		
		! perform time integration
		if (pblm.eq.1) then
			call ode_rk3(t,dt,u)
		else if (pblm.eq.2) then
			if (sc.eq.1) then
				call ode_rk4(t,dt,u)
			else if (sc.eq.2) then
				call ode_cn(t,dt,u)
			end if
		end if

		write(*,"(2E20.8)") t,u(1)

		! increment time - use a time index so we get to tstop
		! otherwise computer roundoff error causes us to quit early
		!t = t + dt
		t = tstart + (tidx*dt)
		tidx = tidx+1
	end do

	print *, 'final solution'
	call print_sln(u)

	call print_sln_to_file(x,u)

end program cfd

