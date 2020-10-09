! Andrew Navratil
! MAE 560 CFD - HW 3

!================================================
! module containing scheme interfaces
!================================================
module interface_defs
	! interface to time integration schemes
	! inputs: t = current time, dt = time step, u = sln val at time t
	!		  sptr = function pointer to space discretization
	! outputs: sln val at time t+dt
	! https://stackoverflow.com/questions/8612466/how-to-alias-a-function-name-in-fortran
	interface
		real function time_scheme(t,dt,uval,stencil,sptr)
		!use inputs
		implicit none
			real(8), intent(in) :: t
			real(8), intent(in) :: dt
			real(8), intent(in) :: uval
			real(8), dimension(2), intent(in) :: stencil
			procedure(space_scheme), pointer, intent(in) :: sptr
		end function time_scheme
	end interface

	! interface to space discretization schemes
	! inputs: t = current time, dt = time step, u = sln val at time t
	!		  sptr = function pointer to space discretization
	! outputs: sln val at time t+dt
	! https://stackoverflow.com/questions/8612466/how-to-alias-a-function-name-in-fortran
	interface
		real function space_scheme(t,uval,stencil)
		!use inputs
		implicit none
			real(8), intent(in) :: t
			real(8), intent(in) :: uval
			real(8), dimension(2), intent(in) :: stencil
		end function space_scheme
	end interface
end module interface_defs


!================================================
! module for reading/setting inputs and constants
!================================================
module inputs
use interface_defs
implicit none

	! problem 1
	integer, parameter :: pblm = 1				
	real(8), parameter :: c = 1.0				! wave speed (c or a)
	integer, parameter :: numpts = 100			! num grid points
	real(8), parameter :: xlen = 1.0			! periodic domain of unit length
	real(8), parameter :: dx = xlen/numpts		! h or delta x
	real(8), parameter :: tstart = 0.0			! starting time
	real(8), parameter :: tstop = 5.0			! stopping time (no convergence calcs)
	
	integer, parameter :: ic = 1				! init cond 1 = square wave
	real(8), parameter :: nu = 1.0				! CFL number
	
	integer, parameter :: stencil_num = 2

end module inputs

!================================================
! module containing time and space discretization schemes
!================================================
module schemes

contains

	!================================================
	! RK3 (time integration scheme)
	! 	doing this on individual points only creates single k values
	! 	so hopefully they are only put on the stack for performance
	! 	no need to store an entire array for k's on the heap
	!================================================
	real function time_rk3(t,dt,uval,stencil,sptr)
	use inputs
	use interface_defs
	implicit none

		real(8), intent(in) :: t
		real(8), intent(in) :: dt
		real(8), intent(in) :: uval
		real(8), dimension(stencil_num), intent(in) :: stencil
		procedure(space_scheme), pointer, intent(in) :: sptr

		real(8) :: k0, k1, k2		! RK intermediate values			

		k0 = sptr(t,uval,stencil)
		k1 = sptr(t + 0.5*dt, uval + 0.5*dt*k0, stencil)
		k2 = sptr(t + dt, uval + 2*dt*k1 - dt*k0, stencil)

		time_rk3 = uval + (1/6)*dt*(k0 + 4*k1 + k2)

	end function time_rk3

	!================================================
	! 2nd order central diff (spatial discretization scheme)
	! 1st order backwardds diff
	! to do: look at playing with passing only a stencil instead of full sln
	!================================================
	real function space_backwards(t,uval,stencil)
	use inputs
	use interface_defs
	implicit none

		real(8), intent(in) :: t
		real(8), intent(in) :: uval
		real(8), dimension(stencil_num), intent(in) :: stencil

		space_backwards = (-c/dx) * (stencil(2) - stencil(1))

	end function space_backwards

end module schemes

!************************************************
! main cfd solver program
!************************************************
program cfd
use inputs
use interface_defs
use schemes
implicit none

	! local variables
	integer :: i
	real(8), dimension(numpts) :: x		! grid
	real(8), dimension(numpts) :: u		! sln
	real(8) :: t						! time val
	real(8) :: dt						! delta t or time step
	
	real(8), dimension(stencil_num) :: stencil

	procedure(time_scheme), pointer :: tptr
	procedure(space_scheme), pointer :: sptr

	tptr => time_rk3
	sptr => space_backwards

	call grid_setup(x)
	print *, x
	
	call sln_setup(u,x)
	print *, u
	
	call calc_dt(dt)
	print *, dt

	! iterate solution to stopping point
	t = tstart
	do while (t.le.tstop)
		print *, t
		do i = 2, numpts
			stencil(1) = u(i-1)
			stencil(2) = u(i)

			u(i) = tptr(t,dt,u(i),stencil,sptr)
			print *, 'i = ', i, ' u = ', u(i)
		end do

		t = t + dt
	end do

	!print *, u

end program cfd

!================================================
! subroutine for generating/reading grid/mesh
!================================================
! note: subroutines modify input variables
!		functions only return a single value
!		modules are for global data or putting subroutines in another file
! https://www.tutorialspoint.com/fortran/fortran_arrays.htm
subroutine grid_setup(x)
use inputs
implicit none

	! grid (1D is just array for x values)
	real(8), dimension(numpts), intent(out) :: x

	! local variables
	integer :: i

	! fill grid
	if (pblm.eq.1) then
		do i = 1, numpts
			x(i) = i*dx
		end do
	end if

end subroutine grid_setup

!================================================
! subroutine for initializing solution
!================================================
subroutine sln_setup(u,x)
use inputs
implicit none

	real(8), dimension(numpts), intent(out) :: u	! sln
	real(8), dimension(numpts), intent(in) :: x		! grid

	! local variables
	integer :: i
	real(8) :: xval

	! initialize solution based on init cond (ic)
	if (pblm.eq.1) then
		! square wave
		if (ic.eq.1) then
			do i = 1, numpts
				xval = x(i)
				print *,xval
				if (xval.ge.0.25.and.xval.le.0.75) then
					u(i) = 1.0
				else
					u(i) = 0.0
				end if
			end do
		end if
	end if

end subroutine sln_setup

!================================================
! apply boundary conditions
!================================================
!subroutine apply_boundary(u,x)
!use inputs
!implicit none
	!! nothing to do
!end subroutine apply_boundary

!================================================
! calculate time step
!================================================
subroutine calc_dt(dt)
use inputs
implicit none

	real(8), intent(out) :: dt		! time step

	dt = nu*dx/abs(c)	! stability restriction based on CFL num
end subroutine calc_dt


