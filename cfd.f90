! Andrew Navratil
! MAE 560 CFD - HW 3

!==============================================================================
! module for reading/setting inputs and constants
!==============================================================================
module inputs
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	! problem 1
	integer, parameter :: pblm = 1
	integer, parameter :: ic = 2	! 1 = square, 2 = sin, 3 = Gaussian
	integer, parameter :: sc = 1	! 1 = central, 2 = upwind			

	integer, parameter :: n = 101				! n nodes => n-1 cells
	real(8), parameter :: gridlen = 1.0			! periodic domain of unit length
	real(8), parameter :: h = gridlen/(n-1)		! delta x for 1D
	real(8), parameter :: tstart = 0.0			! starting time
	real(8), parameter :: tstop = 1.0			! stopping time
	real(8), parameter :: cfl = 0.4			! CFL number
	!real(8), parameter :: cfl = 1.0			! CFL number
	!real(8), parameter :: cfl = 1.3			! CFL number
	!real(8), parameter :: cfl = 5.0			! CFL number
	
	real(8), parameter :: c = 1.0				! wave speed (c or a)
	!real(8), parameter :: ksin = 1.0			! k value for sin (ic=2)
	real(8), parameter :: ksin = 5.0			! k value for sin (ic=2)
	!real(8), parameter :: ksin = 10.0			! k value for sin (ic=2)

	! problem 2: don't forget to uncomment out line in sln_setup
	!integer, parameter :: pblm = 2
	!integer, parameter :: ic = 1
	!integer, parameter :: sc = 1	! 1 = RK4, 2 = Crank-Nicholson			

	!integer, parameter :: n = 100				! n cells => n+1 nodes/faces
	!integer, parameter :: n = 200				! n cells => n+1 nodes/faces
	!real(8), parameter :: gridlen = 10.0		! 0<=x<=10
	!real(8), parameter :: h = gridlen/n			! delta x for 1D
	!real(8), parameter :: tstart = 2.0			! starting time
	!real(8), parameter :: tstop = 4.0			! stopping time
	!real(8), parameter :: cfl = 1.0				! CFL number
	
	real(8), parameter :: d = 0.1				! diffusion coefficient
	real(8), parameter :: x0 = 5.0				! dye injection pt (t=0)
	
	! problem 3
	!integer, parameter :: pblm = 3
	!integer, parameter :: ic = 1
	!integer, parameter :: sc = 1

	!integer, parameter :: n = 100				! n cells => n+1 nodes/faces (nx=ny=n)
	!real(8), parameter :: gridlen = 1.0			! Lx=Ly=1
	!real(8), parameter :: h = gridlen/n			! delta x and delta y
	!real(8), parameter :: tstart = 0.0			! starting time
	!real(8), parameter :: tstop = 0.5			! stopping time
	!real(8), parameter :: cfl = 1.0				! CFL number

	!real(8), parameter :: c = 1.0				! wave speed (c1=u=c2=v=c=1)
	!real(8), parameter :: d = 0.1				! diffusion coefficient (kappa in hw)

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
subroutine grid_setup_1D(grid)
use inputs
implicit none

	! grid (1D is just array for x values)
	real(8), dimension(n+1), intent(out) :: grid

	! local variables
	integer :: i

	! fill grid where data values will be at nodes, start at x=0
	!   for FV, cell centers are at 1/2 indices (cell faces are at nodes)
	do i = 1,n+1
		grid(i) = (i-1)*h
	end do

end subroutine grid_setup_1D

!==============================================================================
! subroutine for initializing solution
!==============================================================================
subroutine sln_setup_1D(u,grid)
use inputs
implicit none

	real(8), dimension(-1:n+2), intent(out) :: u
	real(8), dimension(n+1), intent(in) :: grid

	integer :: i
	real(8) :: xval

	! initialize solution based on init cond (ic)
	! sln index i corresponds to grid location of i+1/2 (avg value over that cell)
	if (pblm.eq.1) then
		! square wave
		if (ic.eq.1) then
			do i = 1,n
				xval = grid(i)
				if (xval.ge.0.25.and.xval.le.0.75) then
					u(i) = 1.0
				else
					u(i) = 0.0
				end if
			end do
		! sine wave
		else if (ic.eq.2) then
			do i = 1,n
				xval = grid(i) + 0.5*h
				u(i) = sin(2.0*PI*ksin*xval)
			end do
		! Gaussian
		else if (ic.eq.3) then
			do i = 1,n
				xval = grid(i) + 0.5*h
				u(i) = exp(-50.0*((xval-0.5)**2))
			end do
		end if
	else if (pblm.eq.2) then
		! Cexact for dye injection diffusion eqn
		do i = 1,n
			xval = grid(i) + 0.5*h
			! comment out for pblm1 due to tstart=0 gives div by 0 compile error
			!u(i) = (1/sqrt(4*PI*d*tstart))*exp((-(xval-x0)**2)/(4*d*tstart)) 
		end do
	end if

	call apply_boundary(u)

end subroutine sln_setup_1D

!==============================================================================
! apply boundary conditions
!==============================================================================
subroutine apply_boundary(u)
use inputs
implicit none
	real(8), dimension(-1:n+2), intent(in out) :: u
	
	! periodic boundary condition
	if (pblm.eq.1) then
		u(0) = u(n-1)
		u(n+1) = u(2)
		u(-1) = u(n-2) ! not used
		u(n+2) = u(3) ! not used
	! fixed boundary condition
	else if (pblm.eq.2) then
		u(0) = 0.0
		u(n+1) = 0.0
		u(-1) = 0.0
		u(n+2) = 0.0
	end if

end subroutine apply_boundary

!==============================================================================
! subroutine for generating/reading grid/mesh
!==============================================================================
!subroutine grid_setup_2D(grid)
!use inputs
!implicit none

	!real(8), dimension(n+1,n+1,2), intent(out) :: grid

	!integer :: i,j

	!! fill grid where data values will be at nodes
	!! for FV, cell centers are at 1/2 indices (cell faces are at nodes)
	!do j = 1,n+1
	!do i = 1,n+1
		!grid(i,j,1) = (i-1)*h
		!grid(i,j,2) = (j-1)*h
	!end do
	!end do

!end subroutine grid_setup_2D

!==============================================================================
! subroutine for initializing solution
!==============================================================================
!subroutine sln_setup_2D(u,grid)
!use inputs
!implicit none

	!real(8), dimension(-1:n+2,-1:n+2), intent(out) :: u
	!real(8), dimension(n+1,n+1,2), intent(in) :: grid

	!integer :: i,j 
	!real(8) :: xval, yval, r2

	!! pblm 3: 2D advection diffusion
	!if (pblm.eq.3) then
		!do j = 1,n+1
		!do i = 1,n+1
			!xval = grid(i,j,1)
			!yval = grid(i,j,2)
			
			!r2 = (xval-0.5)**2 + (yval-0.5)**2
			
			!u(i,j) = exp(-300*r2)
		!end do
		!end do
	!end if

	!call apply_boundary_2D(u)

!end subroutine sln_setup_2D

!==============================================================================
! calculate time step
!	with stability restriction and CFL number (cfl = c*dt/h)
!==============================================================================
subroutine calc_dt(dt)
use inputs
implicit none

	real(8), intent(out) :: dt		! time step

	! pblm 1: 1D advection
	if (pblm.eq.1) then
		dt = cfl*h/abs(c)
	! pblm 2: 1D diffusion
	else if (pblm.eq.2) then
		dt = cfl * 0.5*(h**2/d)
		!dt = abs(cfl*h/(2*d))
		!dt = 0.0001
	end if

end subroutine calc_dt

!==============================================================================
! RK3 (time integration scheme)
!==============================================================================
subroutine ode_rk3(t,dt,u)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(-1:n+2), intent(in out) :: u

	integer :: i
	real(8), dimension(n) :: k0, k1, k2
	real(8), dimension(-1:n+2) :: utmp1, utmp2

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
! RK4 (time integration scheme)
!==============================================================================
subroutine ode_rk4(t,dt,u)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(-1:n+2), intent(in out) :: u

	integer :: i
	real(8), dimension(n) :: k0, k1, k2, k3
	real(8), dimension(-1:n+2) :: utmp1, utmp2, utmp3

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
	real(8), dimension(-1:n+2), intent(in out) :: u

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
! Adams-Bashforth 2nd order for 2D
! 2D advection-diffusion
!	compact formula for normal derivative (diffusion 2nd deriv term in FV)
!	central differencing scheme (convection 1st deriv term FV/FD)
!==============================================================================
!subroutine ode_ab2(dt,u)
!use inputs
!implicit none

	!real(8), intent(in) :: dt
	!real(8), dimension(-1:n+2,-1:n+2), intent(in out) :: u

	!! store previous time step and current time step dudt
	!real(8), dimension(n,n,2) :: dudt
	
	!real(8) :: t
	!integer :: i,j

	!! initialize dudt for first time step
	!call ode_dudt_2D(tstart,dt,u,dudt(:,:,1))

	!! time stepping in here so we can save data from any step
	!t = tstart + dt
	!do while (t.le.tstop)
		!! move current dudt (1) to previous dudt (2)
		!do i = 1,n
		!do i = 1,n
			!dudt(i,j,2) = dudt(i,j,1)
		!end do
		!end do

		!! calculate current dudt (1)
		!call ode_dudt_2D(t,dt,u,dudt(:,:,1))

		!! calculate solution at time step t+dt using AB2 algorithm
		!! and backfill into solution / update solution
		!do i = 1,n
		!do i = 1,n
			!u(i,j) = u(i,j) + 0.5*h*(3*dudt(i,j,1) - dudt(i,j,2))
		!end do
		!end do

		!call apply_boundary(u)

		!t = t + dt
	!end do

!end subroutine ode_ab2

!==============================================================================
! dudt = RHS derivative calculation (spatial discretization)
!==============================================================================
subroutine ode_dudt(t,dt,u,dudt)
use inputs
implicit none

	real(8), intent(in) :: t
	real(8), intent(in) :: dt
	real(8), dimension(-1:n+2), intent(in) :: u
	real(8), dimension(n), intent(out) :: dudt

	integer :: i

	! pblm 1: 1D advection
	if (pblm.eq.1) then
		do i = 1,n
			! central FV (same as FD)
			if (sc.eq.1) then
				dudt(i) = (-c/(2*h)) * (u(i+1) - u(i-1))
			! 1st order upwind FV (same as backwards FD for +c)
			else if (sc.eq.2) then
				dudt(i) = (-c/h) * (u(i) - u(i-1))
			end if
		end do
	! pblm 2: 1D diffusion
	else if (pblm.eq.2) then
		do i = 1,n
			! 2nd order central 2nd deriv FV (same as FD)
			dudt(i) = (d/(h**2)) * (u(i+1) - 2.0*u(i) + u(i-1))
		end do
	end if

end subroutine ode_dudt

!==============================================================================
! dudt = RHS derivative calculation (spatial discretization)
!==============================================================================
!subroutine ode_dudt_2D(t,dt,u,dudt)
!use inputs
!implicit none

	!real(8), intent(in) :: t
	!real(8), intent(in) :: dt
	!real(8), dimension(-1:n+2,-1:n+2), intent(in) :: u
	!real(8), dimension(n,n), intent(out) :: dudt

	!integer :: i,j

	!! pblm 3: 2D advection diffusion
	!if (pblm.eq.3) then
		!! use algorithm from lecture 12 so not doubling the computational work
		!! using simplifications for equi spaced cartesian grid
		!!   normals are +-1 or 0 for nx or ny, cell distaces are just h (h=dy=dist)
		!!   nx = n, ny = n; area = length of face in 2D = dy or dx = h
		!! loop over i faces (i face means normal points in i / x dir) so area is dy
		!!do j = 1,n
		!!do i = 1,n+1
			!!!c = c1*nx + c2*ny => c=c for nx=+1 (+i dir) and ny=0 (+j dir)
			!!dudn = (u(i,j) - u(i-1,j)) / h; ! equidistant => dist(i to i-1) = h
			!!flux = ((-c*(u(i,j) + u(i-1,j))*0.5) + d*dudn) * h;
			!!dudt(i-1,j) = dudt(i-1,j) + flux
			!!dudt(i,j) = dudt(i,j) - flux
		!!end do
		!!end do

		!! now would need to loop over j faces...

		!! but let's just use the uniform grid example method for now
		!do j = 1,n
		!do i = 1,n
			!!dudt(i,j) = -( (c/(2*h)) * (u(i+1,j)-u(i-1,j)+u(i,j+1)-u(i,j-1))) 
				!!+ ( (d/(h**2)) * (u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1)-4*u(i,j)))
		!end do
		!end do
	!end if

!end subroutine ode_dudt

!==============================================================================
! subroutine to print out the solution with corresponding 1/2 grid pt values to file
!==============================================================================
subroutine print_sln_to_file(grid,u)
use inputs
implicit none

	real(8), dimension(n+1), intent(in) :: grid
	real(8), dimension(-1:n+2), intent(in) :: u
	character(len=50) :: filename
	integer :: i

	write(filename,"(A16,I1,A1,I1,A1,I1,A4)") &
		'hw3data/slndata_',pblm,'_',ic,'_',sc,'.dat'
	open(1, file = filename, status='replace')
	!write(1,*) 'i,x,u'
	do i = 1,n
		write(1,"(I3,2F20.16)") i,grid(i)+0.5*h,u(i)
	end do
	close(1)

end subroutine print_sln_to_file

!==============================================================================
! subroutine to print out the solution to console
!==============================================================================
subroutine print_sln(u)
use inputs
implicit none

	real(8), dimension(-1:n+2), intent(in) :: u
	integer :: i

	do i = -1,n+2
		write(*,"(I3,F20.16)") i,u(i)
		!print *, 'i = ', i, ' u = ', u(i)
	end do
end subroutine print_sln

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

	!================================================
	! pblm1 and pblm2
	! comment all this out for pblm 3, find better way later
	!================================================
	real(8), dimension(n+1) :: grid			! grid 1D
	real(8), dimension(-1:n+2) :: u			! sln 1D
	real(8) :: t							! time val
	real(8) :: dt							! time step (delta t)
	
	call grid_setup_1D(grid)
	print *,'h = ',h
	print *,'grid'
	write(*,"(F20.16)") grid
	
	call sln_setup_1D(u,grid)
	print *, 'initial solution'
	call print_sln(u)
	
	call calc_dt(dt)
	print *, 'dt = ',dt

	! time marching - iterate solution from start to stop time
	! note: we already initialized at time tstart
	t = tstart + dt
	do while (t.le.tstop)
		print *, t
		
		! perform time integration
		! pblm 1 and pblm 2 are 1D
		if (pblm.eq.1) then
			call ode_rk3(t,dt,u)
		else if (pblm.eq.2) then
			if (sc.eq.1) then
				call ode_rk4(t,dt,u)
			else if (sc.eq.2) then
				call ode_cn(t,dt,u)
			end if
		end if

		! increment time
		t = t + dt
	end do

	print *, 'final solution'
	call print_sln(u)

	call print_sln_to_file(grid,u)

	!================================================
	! pblm 3
	!================================================
	!real(8), dimension(n+1,n+1,2) :: grid	! grid 2D: (1) is i/x, (2) is j/y
	!real(8), dimension(-1:n+2,-1:n+2) :: u	! sln 2D
	!real(8) :: dt							! time step (delta t)

	!call grid_setup_2D(grid)
	!call sln_setup_2D(u,grid)
	!call calc_dt(dt)

	!! adams-bashforth method handles the time stepping as well
	!!   since it needs data from previous time steps
	!call ode_ab2(dt,u)

	!call print_sln_to_file_2D(grid,u)

end program cfd

