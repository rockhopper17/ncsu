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
	Integer, Parameter :: size=1000, nit = 5e4
	!real(8), Parameter :: h0 = 1.d0, hL = 0.1d0 ! version 0
	real(8), Parameter :: h0 = 1.0, hL = 0.0 ! version 1 BCs
	real(8), Parameter :: x0 = 0.0, xL = 10.0 ! version 1 x domain (0-10m)
	real(8), Parameter :: dx = (xL-x0)/size ! compute grid spacing / delta x
	real(8), parameter :: a = 0.007, b = -0.07, c = 0.2 ! k consts
	real(8), parameter :: c0 = -0.0055, c1 = 0.5 ! analytical sln consts
	real(8), parameter :: qarea = 100 ! avg cross sectional area
	integer, parameter :: ndims = 1 ! version 4 topology funcs

!================================================================
! declare variables
!================================================================
    real(8), allocatable :: h(:), hnew(:), k(:)
    real(8) time1, time2, mflops, errsq, error, sumsqerr
	integer nprocs,i,iam,n,left,right,j,m
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
		! send to right neighbor and receive from left neighbor
		call MPI_Sendrecv(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
				h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
				MPI_COMM_WORLD, status, ierr)
		! send to left neighbor and receive from right neighbor
		call MPI_Sendrecv(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
				h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
				MPI_COMM_WORLD, status, ierr)

		! red-black Gauss-Seidel (0=red,1=black)
		! with GS, don't need hnew, just updating h directly
		do m=0,1
			do i = m,n,2
				!h(i)=(h(i-1)+h(i+1))/2.d0
				h(i) = ((k(i+1)+k(i))*h(i+1) + (k(i)+k(i-1))*h(i-1)) / &
				(k(i+1) + 2*k(i) + k(i-1))
			enddo
		end do

		!reinitalize boundary conditions
		if (iam.eq.0) h(0)=h0
		if (iam.eq.nprocs-1) h(n+1)=hL

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
