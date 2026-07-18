! Andrew Navratil
! CE 791 Mini project - 2D Groundwater Flow

!******************************************************************************
! main solver program for 2D Groundwater Finite Difference
!******************************************************************************
program gw
implicit none
include "mpif.h"

	! === constants	===
	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	real(8), parameter :: Lx = 1000., Ly = 500.		! x,y grid lengths
	!real(8), parameter :: Lx = 10., Ly = 5.		! x,y grid lengths

	! 1D blocks will be groups of columns, so want the total num cols (sx)
	! to be divisible by num procs (2,4,8,16 -> 16), keep it close to dx=1
	! num rows (sy) can stay even, for dy=1
	! we will print ghost nodes which are the boundaries for full grid
	real(8), parameter :: sx = 16*64, sy = 499.		! total x,y nodes
	!real(8), parameter :: sx = 10, sy = 5.		! total x,y nodes

	real(8), parameter :: dx = Lx/(sx+1), dy = Ly/(sy+1)	! delta x, delta y
	
	!real(8), parameter :: tstart = 0., tstop = 10.
	!real(8), parameter :: tstart = 0., tstop = 100.
	real(8), parameter :: tstart = 0., tstop = 1000.

	! experiment with different values (no cfl stability calculated)
	real(8), parameter :: dt = 0.001				! time step

	! K coeffs (see matlab code for calculation)
	real(8), parameter :: a = -0.001, b = -0.002, c = 0.000004, d = 2.0 

	real(8), parameter :: Ss = 0.1				! storage coefficient
	real(8), parameter :: Q0 = 0.001			! recharge coeff
	real(8), parameter :: omega = PI/300.		! used in recharge calc

	logical, parameter :: doprint = .false.	! debug and file prints

	! === variables ===
	real(8), allocatable :: u(:,:),un(:,:)		! sln(k),sln(k+1)
	real(8), allocatable :: K(:,:)				! transmissivity
	
	integer nx,ny,xbase		! num x,y nodes and start col per block/proc
	real(8) xval, yval		! x,y coordinate values
	real(8) dudtx,dudty		! du/dt x,y portions

	real(8) Q				! areal specific recharge (changes with time)

	real(8) t						! current time
	integer i,j,tidx,jstart,jend	! reserve i,j for indexing
	integer numops					! count of ops for mflops
	
	character(len=50) :: filename	! filename for printing solution

	! === MPI variables ===
    real(8) time1,time2,total_time,mflops,ierr
	integer nprocs,iam,leftproc,rightproc,comm1d,mpistatus
	integer coltype,rowtype,tag1,tag2

	!=========================================================	

	! initialize MPI
	call MPI_INIT(ierr)
	call MPI_COMM_RANK(MPI_COMM_WORLD, iam, ierr)
	call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
	!nprocs = 16
	!iam = 0

	! setup MPI topology	
	call MPI_CART_CREATE(MPI_COMM_WORLD, 1, nprocs, .false., &
		.true., comm1d, ierr)
	call MPI_COMM_RANK(comm1d, iam, ierr)
	call MPI_CART_SHIFT(comm1d, 0, 1, leftproc, rightproc, ierr)
	
	! calculate block num cols per proc, num rows stays same for 1D
	nx = sx/nprocs
	ny = sy
	xbase = iam*nx

	! allocate memory for solution and K
	allocate (u(0:ny+1,0:nx+1),un(0:ny+1,0:nx+1))
	allocate (K(0:ny+1,0:nx+1))

	! initialize message passing parameters
	! sln u changed to u(i,j) = u(y,x) so x-y columns correlate to
	! columns in the u variable too for contiguous memory access
	call MPI_TYPE_CONTIGUOUS(ny+2,MPI_DOUBLE_PRECISION,coltype,ierr)
	call MPI_TYPE_COMMIT(coltype,ierr)
	! for 2D domain decomposition (to do)
	!call MPI_TYPE_VECTOR(nx+2,1,ny+2,MPI_DOUBLE_PRECISION,rowtype,ierr)
	!call MPI_TYPE_COMMIT(rowtype,ierr)
	
	tag1 = 1
	tag2 = 2
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

	! init solution and K values (K doesn't change later) (per block)
	do j = 0,nx+1
	do i = 0,ny+1
		xval = (xbase+j)*dx
		yval = i*dy
		
		u(i,j) = 10.0-xval/200.0
		!u(i,j) = 10.0-xval/2.0
		K(i,j) = a*xval + b*yval + c*xval*yval + d
			
		!write(*,"(3I5,4E20.8)") iam,i,j,xval,yval,u(i,j),K(i,j)
	end do
	end do

	! reset upper and lower rows using Neumann boundary condition
	! left,right boundary conditions already a product of the init sln eqn
	do j=1,nx
		u(ny+1,j) = u(ny,j)  	! upper
		u(0,j) = u(1,j)			! lower
	end do

	! start timer for mflops calculation
	if (iam.eq.0) then
		time1 = MPI_Wtime()
	end if

	! time marching - iterate solution from start to stop time
	! we already initialized at time tstart, so add dt
	t = tstart + dt
	tidx = 2
	do while (t.le.tstop)
		! send first col to left neighbor
		! receive last col from right neighbor
		call MPI_Sendrecv(u(0,1), 1, coltype, leftproc, tag1, &
				u(0,nx+1), 1, coltype, rightproc, tag1, &
				comm1d, mpistatus, ierr)
		! send last col to right neighbor
		! receive first col from left neighbor
		call MPI_Sendrecv(u(0,nx), 1, coltype, rightproc, tag2, &
				u(0,0), 1, coltype, leftproc, tag2, &
				comm1d, mpistatus, ierr)

		! calculate solution for next time step
		Q = Q0*(1+sin(omega*t))
		do j = 1,nx
		do i = 1,ny
			dudtx = (K(i,j+1)+K(i,j))*(u(i,j+1)+u(i,j))*(u(i,j+1)-u(i,j))
			dudtx = dudtx - (K(i,j)+K(i,j-1))*(u(i,j)+u(i,j-1))*(u(i,j)-u(i,j-1))
			dudtx = dudtx/(4*dx*dx)
			
			dudty = (K(i+1,j)+K(i,j))*(u(i+1,j)+u(i,j))*(u(i+1,j)-u(i,j))
			dudty = dudty - (K(i,j)+K(i-1,j))*(u(i,j)+u(i-1,j))*(u(i,j)-u(i-1,j))
			dudty = dudty/(4*dy*dy)
		
			un(i,j) = u(i,j) + (dt/Ss)*(dudtx+dudty+Q)
		end do
		end do

		! now copy back into current solution
		do j = 1,nx
		do i = 1,ny
			u(i,j) = un(i,j)
		end do
		end do

		! insulated / no flow upper and lower boundaries
		! homogeneous Neumann BCs => du/dy = 0
		! this means ghost node is just same value as cell above/below
		do j=1,nx
			u(ny+1,j) = u(ny,j)  	! upper
			u(0,j) = u(1,j)			! lower
		end do

		! constant head left and right boundaries
		! nonhomogeneous Dirichlet BCs => u = val
		if (iam.eq.0) then
			do i=0,ny+1
				u(i,0) = 10.0			! left
			end do
		elseif (iam.eq.nprocs-1) then
			do i=0,ny+1
				u(i,nx+1) = 5.0			! right
			end do
		end if

		! print some sln values sometimes as we go along if doprint=true
		!if (doprint) then	
			!if (mod(t,0.1).le.0.0001) then
				!write(*,"(I3,4E20.8)") iam,t,u(10,10),u(ny/2,nx/2),u(ny-10,nx-10)
				!write(*,"(I3,4E20.8)") iam,t,u(1,1),u(ny/2,nx/2),u(ny-1,nx-1)
			!end if
		!end if
	
		! increment time
		!t = t + dt
		t = tstart + (tidx*dt)
		tidx = tidx+1
	end do

	! end timer
	if (iam.eq.0) then
		time2 = MPI_Wtime()
		total_time = time2-time1
	end if

	! print the final solution to file
	if (doprint) then
		write(filename,"(A17,I2.2,A1,I4.4,A4)") & 
			'minidata/slndata_',iam,'_',int(t),'.txt'
		open(1, file = filename, status='replace')

		! print the first ghost col at x=0 if proc 0
		! print the last ghost col at x=nx+1 if proc nprocs-1
		! always print the ghost rows at y=0,y=ny+1
		jstart = 1
		jend = nx
		if (iam.eq.0) then
			jstart = 0
		elseif (iam.eq.nprocs-1) then
			jend = nx+1
		end if 

		do j = jstart,jend
		do i = 0,ny+1
			!xval = (xbase+j)*dx
			!yval = i*dy
			
			write(1,"(E20.8)") u(i,j)
			!write(1,"(2I5,3E20.8)") i,j,xval,yval,u(i,j)
			!write(*,"(3I5,3E20.8)") iam,i,j,xval,yval,u(i,j)
		end do
		end do

		close(1)
	end if

	! print mflops and execution time to gw.out file
	if (iam.eq.0) then
		numops = 14+14+5
        mflops = dble(numops)*dble(nx*ny)*(tidx-2)*nprocs*1e-6/total_time
		
		write(*,*) 'nprocs =',nprocs
		write(*,*) 'mflops =',mflops
		write(*,*) 'total time =',total_time
	end if

	! finalize MPI
	call MPI_FINALIZE(ierr)

end program gw

