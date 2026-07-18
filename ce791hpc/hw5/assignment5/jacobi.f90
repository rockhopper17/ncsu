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
	Integer, Parameter :: size=10000, nit = 100000
	real(8), Parameter :: h0 = 1.d0, hL = 0.1d0

!================================================================
! declare variables
!================================================================
    real(8), allocatable :: h(:), hnew(:)
    real(8) time1, time2, mflops, errsq, error, sumsqerr
	integer nprocs,i,iam,n,left,right,k
	integer count,tag1,tag2
	integer status(MPI_STATUS_SIZE)

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
	allocate (h(0:n+1),hnew(0:n+1))

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
	left=iam-1
	right=iam+1

!================================================================
!initalize h values
!================================================================
        if (iam.eq.0) h(0)=h0
        if (iam.eq.nprocs-1) h(n+1)=hL
	do i=1,n
	  h(i)=0.d0
	enddo

!================================================================
!start iterations
!================================================================
	do k=1,nit
	  if (iam.ne.nprocs-1) then ! if I am not the last processor
! send my last grid point
		call MPI_Send(h(n), count, MPI_DOUBLE_PRECISION, right, tag1, &
     		  MPI_COMM_WORLD, ierr)
          endif
	  if (iam.ne.0) then ! if I am not the first processor
! receive into left ghost buffer
		call MPI_Recv(h(0), count, MPI_DOUBLE_PRECISION, left, tag1, &
         	   MPI_COMM_WORLD, status, ierr)
	  endif
	  if (iam.ne.0) then ! if I am not the first processor
! send my first grid point
		call MPI_Send(h(1), count, MPI_DOUBLE_PRECISION, left, tag2, &
     		   MPI_COMM_WORLD, ierr)
          endif
	  if (iam.ne.nprocs-1) then ! if I am not the last processor
! receive into right ghost buffer
		call MPI_Recv(h(n+1), count, MPI_DOUBLE_PRECISION, right, tag2, &
         	  MPI_COMM_WORLD, status, ierr)
	  endif
!calculate new values of h
	  do i=1,n
	      hnew(i)=(h(i-1)+h(i+1))/2.d0
	  enddo
!update old values
	  do i=1,n
	   h(i)=hnew(i)
	  enddo
!reinitalize boundary conditions
          if (iam.eq.0) h(0)=h0
          if (iam.eq.nprocs-1) h(n+1)=hL
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
           hanal=h0+(hL-h0)*(iam*n+i)/(size+1)
           errsq=errsq+(h(i)-hanal)**2
        enddo
        call MPI_REDUCE(sumsqerr,errsq,1,MPI_DOUBLE_PRECISION,MPI_SUM,0, &
                           MPI_COMM_WORLD,ierr)
        error=sqrt(sumsqerr)/dble(size)
!================================================================
! print results
!================================================================
        mflops = 2*dble(nit)*dble(size)*1e-6/(total_time)
        if (iam == 0) then
	 print *, "error =",error
         print *, 'mflops =',mflops
         print *, 'Total time =',total_time
        endif
	call MPI_FINALIZE(ierr)
	end
