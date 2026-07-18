! Andrew Navratil
! CE 791 Mini project - 2D Groundwater Flow

!==============================================================================
! module for reading/setting constants, inputs, grid data and metrics
!==============================================================================
module grid_data
implicit none

	! constants	===============================
	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	real(8), parameter :: Lx = 1000., Ly = 500.		! x,y grid lengths
	real(8), parameter :: sx = 16*64, sy = 16*32	! total x,y nodes
	real(8), parameter :: dx = Lx/sx, dy = Ly/sy	! delta x, delta y
	
	real(8), parameter :: tstart = 0., tstop = 11.

	! experiment with different values (no cfl stability calculated)
	real(8), parameter :: dt = 0.001				! time step

	! K coeffs (see matlab code for calculation)
	real(8), parameter :: a = -0.001, b = -0.002, c = 0.000004, d = 2.0 

	real(8), parameter :: Ss = 0.1				! storage coefficient
	real(8), parameter :: Q0 = 0.001
	real(8), parameter :: omega = PI/300.

	logical, parameter :: doprint = .true.	! debug and file prints

	! global variables ========================
	integer nx,ny				! num x,y nodes (per proc)
	real(8), allocatable :: u(:,:),un(:,:),K(:,:)	! sln(k),sln(k+1),transmissivity
	real(8), allocatable :: xn(:,:),yn(:,:)		! grid x,y coordinates
	
	real(8) :: Q				! areal specific recharge (changes with time)
	real(8) :: t				! current time
	integer :: i,j				! reserve i,j for indexing

	! MPI variables ===========================
    real(8) time1, time2, mflops, errsq, ierr, sumsqerr
	integer nprocs,iam,leftproc,rightproc,comm1d,mpistatus,xtype,ytype
contains

!==============================================================================
! generate or read in the grid/mesh
!==============================================================================
subroutine grid_setup

	integer xbase,ybase
	xbase = iam*nx
	ybase = iam*ny

	! fill grid where data values will be at nodes (FD)
	do j = 1,ny
	do i = 1,nx
		xn(i,j) = (xbase+i-1)*dx
		yn(i,j) = (ybase+j-1)*dy
	end do
	end do

end subroutine grid_setup

!====================
end module grid_data
!====================

!==============================================================================
! module for procedures
!==============================================================================
module procedures
use grid_data
implicit none
contains

!==============================================================================
! initialize solution, transmissivity, and recharge values
!==============================================================================
subroutine sln_setup

	! init solution and K values (K doesn't change later)
	do j = 1,ny
	do i = 1,nx
		u(i,j) = 10.0-xn(i,j)/200.0
		K(i,j) = a*xn(i,j) + b*yn(i,j) + c*xn(i,j)*yn(i,j) + d
	end do
	end do

end subroutine sln_setup

!==============================================================================
! apply boundary conditions
!==============================================================================
subroutine apply_boundary
	
	! insulated / no flow upper and lower boundaries
	! homogeneous Neumann BCs => du/dy = 0
	! this means ghost node is just same value as cell above/below
	do i=1,nx
		u(i,ny) = u(i,ny-1)  	! upper
		u(i,1) = u(i,2)			! lower
	end do

	! constant head left and right boundaries
	! nonhomogeneous Dirichlet BCs => u = val
	do j=1,ny
		u(1,j) = 10.0			! left
		u(nx,j) = 5.0			! right
	end do

end subroutine apply_boundary

!==============================================================================
! fda = RHS calculation using FDA (essentially explicit forward euler) 
! combines the spatial and time discretization
!==============================================================================
subroutine fda

	real(8) :: dudtx,dudty

	! fill interior sln for next time step
	do j = 2,ny-1
	do i = 2,nx-1
		dudtx = (K(i+1,j)+K(i,j))*(u(i+1,j)+u(i,j))*(u(i+1,j)-u(i,j))
		dudtx = dudtx - (K(i,j)+K(i-1,j))*(u(i,j)+u(i-1,j))*(u(i,j)-u(i-1,j))
		dudtx = dudtx/(4*dx*dx)
	
		dudty = (K(i,j+1)+K(i,j))*(u(i,j+1)+u(i,j))*(u(i,j+1)-u(i,j))
		dudty = dudty - (K(i,j)+K(i,j-1))*(u(i,j)+u(i,j-1))*(u(i,j)-u(i,j-1))
		dudty = dudty/(4*dy*dy)
		
		un(i,j) = u(i,j) + (dt/Ss)*(dudtx+dudty+Q)
	end do
	end do

	! now copy back into current solution
	do j = 2,ny-1
	do i = 2,nx-1
		u(i,j) = un(i,j)
	end do
	end do

	! apply boundary conditions to current sln u
	call apply_boundary

end subroutine fda

!==============================================================================
! print out solution in a matrix form like viewing x-y axis
! ** only do for small nx,ny like 10x10
!==============================================================================
subroutine print_sln

	!do j = ny+1,0,-1
	! print the top right corner
	do j = ny,ny-5,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		!do i = 0,nx+1
		do i = nx-5,nx
			!write(*,"(A1,F6.4,A2)",advance="no") '(',u(i,j),') '
			write(*,"(A1,F10.4,A2)",advance="no") '(',u(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

end subroutine print_sln

!==============================================================================
! print solution to file with grid
!==============================================================================
subroutine print_sln_to_file

	character(len=50) :: filename
	
	write(filename,"(A17,I3.3,A4)") 'minidata/slndata_',int(t),'.txt'
	open(1, file = filename, status='replace')
	!open(1, file = 'minidata/slndata.txt', status='replace')
	!write(1,*) 'i,x,u'
	do j = 1,ny
	do i = 1,nx
		!write(1,"(2I3,3F32.16)") i,j,xval,yval,u(i,j)
		write(1,"(2I5,3E20.8)") i,j,xn(i,j),yn(i,j),u(i,j)
	end do
	end do
	close(1)

end subroutine print_sln_to_file

!====================
end module procedures
!====================

!******************************************************************************
! main solver program
!******************************************************************************
program gw

use grid_data
use procedures
implicit none
include "mpif.h"

	! initialize MPI and block size values
	call MPI_INIT(ierr)
	call MPI_COMM_RANK(MPI_COMM_WORLD, iam, ierr)
	call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
	!nprocs = 16
	!iam = 0
	nx = sx/nprocs
	ny = sy/nprocs

	allocate (xn(nx,ny),yn(nx,ny),u(nx,ny),un(nx,ny),K(nx,ny))

	! setup MPI topology	
	call MPI_CART_CREATE(MPI_COMM_WORLD, 1, nprocs, .false., &
		.true., comm1d, ierr)
	call MPI_COMM_RANK(comm1d, iam, ierr)
	call MPI_CART_SHIFT(comm1d, 0, 1, leftproc, rightproc, ierr)

	! initialize message passing parameters
	call MPI_TYPE_CONTIGUOUS(ny,MPI_REAL,coltype,ierr)  ! change to vector
	call MPI_TYPE_COMMIT(coltype,ierr)
	call MPI_TYPE_CONTIGUOUS(ny,MPI_REAL,coltype,ierr)
	call MPI_TYPE_COMMIT(coltype,ierr)

	if (iam.eq.0) then
		leftproc = MPI_PROC_null
	else
		leftproc = iam-1
	end if
	if (iam.eq.nprocs-1) then
		rightproc = MPI_PROC_NULL
	else
		rightproc = iam+1
	end if

	! start timer for mflops calculation
	time1 = MPI_Wtime()

	! setup grid and initialize solution (per block)
	call grid_setup
	call sln_setup
	
	if (doprint) then
		print *, 'initial solution'
		t = 0.0
		call print_sln
		call print_sln_to_file
	end if

	! time marching - iterate solution from start to stop time
	! we already initialized at time tstart, so add dt
	t = tstart + dt
	do while (t.le.tstop)
		! send to right neighbor and receive from left neighbor
		!call MPI_Sendrecv(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
				!h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
				!MPI_COMM_WORLD, status, ierr)
		! send to left neighbor and receive from right neighbor
		!call MPI_Sendrecv(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
				!h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
				!MPI_COMM_WORLD, status, ierr)

		! calculate solution for next time step
		Q = Q0*(1+sin(omega*t))
		call fda

		if (doprint) then	
			! print some sln values sometimes as we go along	
			if (mod(t,0.1).le.0.0001) then
				write(*,"(4E20.8)") t,u(10,10),u(nx/2,ny/2),u(nx-10,ny-10)
			end if

			! print solution at 10 days
			if (abs(t-10.0).le.0.0001) then
				call print_sln_to_file
			end if
			
			! print solution at 50 days
			if (abs(t-50.0).le.0.0001) then
				call print_sln_to_file
			end if
		end if
	
		! increment time
		t = t + dt
	end do

	if (doprint) then
		print *, 'final solution'
		call print_sln
		call print_sln_to_file
	end if

end program gw

