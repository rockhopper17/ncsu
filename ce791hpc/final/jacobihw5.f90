!================================================================
! jacobi for 1-D Laplacian
!================================================================
	program jacobi
!================================================================
	include "mpif.h"
!================================================================

!================================================================
! initialize main parameters
!================================================================
	Integer, Parameter :: size=1000, nit = 1000000
	!real(8), Parameter :: h0 = 1.d0, hL = 0.1d0 ! version 0
	real(8), Parameter :: h0 = 1.0, hL = 0.0 ! version 1 BCs
	real(8), Parameter :: x0 = 0.0, xL = 10.0 ! version 1 x domain (0-10m)
	real(8), Parameter :: dx = (xL-x0)/size ! compute grid spacing / delta x
	real(8), parameter :: a = 0.007, b = -0.07, c = 0.2 ! k consts
	real(8), parameter :: c0 = -0.0055, c1 = 0.5 ! analytical sln consts
	real(8), parameter :: qarea = 100 ! avg cross sectional area
	integer, parameter :: ndims = 1 ! version 4 topology funcs
	integer, parameter :: version = 5 ! version switch: 0,1,2,3,4,5

!================================================================
! declare variables
!================================================================
    real(8), allocatable :: h(:), hnew(:), k(:)
    real(8) time1, time2, mflops, errsq, error, sumsqerr
	integer nprocs,i,iam,n,left,right,j
	integer count,tag1,tag2
	integer status(MPI_STATUS_SIZE)
	integer comm1d 
	integer status_array(MPI_STATUS_SIZE, 4), req(4)
	real(8) :: xval, fanal, Q, dhdx
	integer :: dims(ndims)
	logical :: isoperiodic(ndims), reorder
	character(len=50) :: filename

!================================================================
! initialize MPI
!================================================================
	call MPI_INIT(ierr)
	call MPI_COMM_RANK(MPI_COMM_WORLD, iam, ierr)
	call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)

!================================================================
! assume size is perfectly divisible by nprocs
!================================================================
	n = size/nprocs

!================================================================
! allocate arrays
!================================================================
	allocate (h(0:n+1),hnew(0:n+1),k(0:n+1))

	! version 4 topology operation
	if (version.eq.4) then
		isoperiodic(1) = .false.
		reorder = .true.
		dims(0) = nprocs
	
		! this isn't working
		!call MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dims, isoperiodic, &
			!reorder, comm1d, ierr)
		! using this version from Gropp book	
		call MPI_CART_CREATE(MPI_COMM_WORLD, 1, nprocs, .false., &
			.true., comm1d, ierr)
		call MPI_COMM_RANK(comm1d, iam, ierr)
		call MPI_CART_SHIFT(comm1d, 0, 1, left, right, ierr)
	end if

!================================================================
! start timer
!================================================================
        time1=MPI_Wtime()

!================================================================
! initialize message passing parameters
!================================================================
	count=1
	tag1=1
	tag2=2
	!left=iam-1
	!right=iam+1
	if (iam.eq.0) then
		left = MPI_PROC_null
	else
		left = iam-1
	end if
	if (iam.eq.nprocs-1) then
		right = MPI_PROC_NULL
	else
		right = iam+1
	end if

!================================================================
!initalize h and k values
!================================================================
	if (iam.eq.0) then
		h(0) = h0
	end if
	if (iam.eq.nprocs-1) then
		h(n+1) = hL
	end if

	xval = (iam*n) * dx
	k(0) = a*xval**2 + b*xval + c
	xval = ((iam+1)*n + 1) * dx
	k(n+1) = a*xval**2 + b*xval + c

	do i=1,n
		h(i) = 0.d0

		xval = (iam*n + i) * dx
		k(i) = a*xval**2 + b*xval + c
	enddo

!================================================================
!start iterations
!================================================================
	do j=1,nit
		!=======================================================
		! version 1
		!=======================================================
		if (version.eq.1) then
		! version 1 unsafe
		!! send my first grid point
		!call MPI_Send(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
				!MPI_COMM_WORLD, ierr)
		!! MPI_Ssend check for deadlock
		!!call MPI_Ssend(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
				!!MPI_COMM_WORLD, ierr)
		!! receive into right ghost buffer
		!call MPI_Recv(h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
			   !MPI_COMM_WORLD, status, ierr)
		!! send my last grid point
		!call MPI_Send(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
			   !MPI_COMM_WORLD, ierr)
		!! MPI_Ssend check for deadlock
		!!call MPI_Ssend(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
			   !!MPI_COMM_WORLD, ierr)
		!! receive into left ghost buffer
		!call MPI_Recv(h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
				!MPI_COMM_WORLD, status, ierr)

		! version 1 safe
		! paired send/recv by processor to avoid deadlocks
		if (mod(iam,2).eq.0.0) then
			call MPI_Send(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
				   MPI_COMM_WORLD, ierr)
			call MPI_Recv(h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
				   MPI_COMM_WORLD, status, ierr)
			call MPI_Send(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
					MPI_COMM_WORLD, ierr)
			call MPI_Recv(h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
					MPI_COMM_WORLD, status, ierr)
		else
			call MPI_Recv(h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
					MPI_COMM_WORLD, status, ierr)
			call MPI_Send(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
					MPI_COMM_WORLD, ierr)
			call MPI_Recv(h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
				   MPI_COMM_WORLD, status, ierr)
			call MPI_Send(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
				   MPI_COMM_WORLD, ierr)
		end if

		!=======================================================
		! version 2
		!=======================================================
		else if (version.eq.2) then
		! send to right neighbor and receive from left neighbor
		call MPI_Sendrecv(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
				h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
				MPI_COMM_WORLD, status, ierr)
		! send to left neighbor and receive from right neighbor
		call MPI_Sendrecv(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
				h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
				MPI_COMM_WORLD, status, ierr)

		!=======================================================
		! version 3
		!=======================================================
		else if (version.eq.3) then
			! if not proc 0, send first grid point to left neighbor
			if (iam.ne.0) then
				call MPI_Send(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
						MPI_COMM_WORLD, ierr)
			end if
			! if not last proc, send last grid point to right neighbor
			if (iam.ne.nprocs-1) then
				call MPI_Send(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
					   MPI_COMM_WORLD, ierr)
			end if
			
			! compute interior
			do i=2,n-1
				hnew(i) = ((k(i+1)+k(i))*h(i+1) + (k(i)+k(i-1))*h(i-1)) / &
				(k(i+1) + 2*k(i) + k(i-1))
			enddo

			! if not proc 0, receive from left neighbor into left ghost cell
			if (iam.ne.0) then
				call MPI_Recv(h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
						MPI_COMM_WORLD, status, ierr)
			end if
			! if not last proc, receive from right neighbor into right ghost cell
			if (iam.ne.nprocs-1) then
				call MPI_Recv(h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
					   MPI_COMM_WORLD, status, ierr)
			end if

			! compute end points
			i = 1
			hnew(i) = ((k(i+1)+k(i))*h(i+1) + (k(i)+k(i-1))*h(i-1)) / &
			(k(i+1) + 2*k(i) + k(i-1))
			i = n
			hnew(i) = ((k(i+1)+k(i))*h(i+1) + (k(i)+k(i-1))*h(i-1)) / &
			(k(i+1) + 2*k(i) + k(i-1))
			
			!update old values
			do i=1,n
				h(i)=hnew(i)
			enddo

			!reinitalize boundary conditions
			if (iam.eq.0) h(0)=h0
			if (iam.eq.nprocs-1) h(n+1)=hL

		!=======================================================
		! version 4
		!=======================================================
		else if (version.eq.4) then

		! send to left neighbor and receive from right neighbor
		call MPI_Sendrecv(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
				h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
				comm1d, status, ierr)
		! send to right neighbor and receive from left neighbor
		call MPI_Sendrecv(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
				h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
				comm1d, status, ierr)

		!=======================================================
		! version 5
		!=======================================================
		else if (version.eq.5) then

			call MPI_Irecv(h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
					MPI_COMM_WORLD, req(1), ierr)
			call MPI_Irecv(h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
				   MPI_COMM_WORLD, req(2), ierr)
			call MPI_Isend(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
				   MPI_COMM_WORLD, req(3), ierr)
			call MPI_Isend(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
					MPI_COMM_WORLD, req(4), ierr)

			call MPI_WAITALL(4, req, status_array, ierr)

		!=======================================================
		end if
		!=======================================================
		
		! version 0,1,2,4,5 computation of interior (all but ver 3)
		if (version.ne.3) then
			!calculate new values of h
			do i=1,n
				!hnew(i)=(h(i-1)+h(i+1))/2.d0 ! version 0
				hnew(i) = ((k(i+1)+k(i))*h(i+1) + (k(i)+k(i-1))*h(i-1)) / &
				(k(i+1) + 2*k(i) + k(i-1))
			enddo
			!update old values
			do i=1,n
				h(i)=hnew(i)
			enddo
			!reinitalize boundary conditions
			if (iam.eq.0) h(0)=h0
			if (iam.eq.nprocs-1) h(n+1)=hL
		end if

		! average leakage flux calculation (only do this one time)
		! approximate dh/dx using 2nd order central diff
		!Q = 0
		!do i = 1,n
			!!dhdx = 0.5*(h(i+1) - h(i-1))
			!dhdx = (h(i) - h(i-1))
			!Q = Q + k(i) * qarea * dhdx * dx
		!enddo
	enddo
!================================================================
!end iterations
!================================================================

!================================================================
!end timer
!================================================================
        time2=MPI_Wtime()
		total_time=time2-time1

!================================================================
! calculate error using analytical solution
!================================================================
        errsq=0.d0
		do i=1,n
           !hanal=h0+(hL-h0)*(iam*n+i)/(size+1) ! version 0

		   xval = (iam*n + i) * dx 
		   fanal = (2/sqrt(4*a*c-b*b))*atan((2*a*xval+b)/sqrt(4*a*c-b*b))
           hanal = c0*fanal + c1

           errsq = errsq + (h(i)-hanal)**2
		   !print *, "errsq = ",errsq
        enddo
        call MPI_REDUCE(errsq,sumsqerr,1,MPI_DOUBLE_PRECISION,MPI_SUM,0, &
                           MPI_COMM_WORLD,ierr)
	
!================================================================
! print results
!================================================================

		! write out solution to file for processing in matlab
		write(filename,"(A8,I1,A4)") 'slndata_',iam,'.txt'
		open(1,file = filename, status='replace')
		do i = 1,n
			write(1,"(I5,2E20.8)") i,k(i),h(i)
		end do
		close(1)

	if (iam == 0) then
		!print *, "sumsqerr = ",sumsqerr
		error=sqrt(sumsqerr)/dble(size) ! can only do this on proc 0

		!mflops = 2*dble(nit)*dble(size)*1e-6/(total_time) ! version 0
		mflops = 8*dble(nit)*dble(size)*1e-6/(total_time) ! versions 1-5

			print *, "nprocs =",nprocs
			print *, "error =",error
			print *, 'mflops =',mflops
			print *, 'Total time =',total_time
			
			!print *, 'Q =',Q
	endif
	call MPI_FINALIZE(ierr)
end
