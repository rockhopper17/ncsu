! ==================================================================
! This code performs matrix-matrix multiplication
! defined by C = A*B where A, B, C are square matrices.
! Prints out the mflop rating associated with each size
! ==================================================================
! constant declarations
! ==================================================================
#define MAXSIZE 801
! ==================================================================
! matrix-matrix multiply
! ==================================================================
	program driver
	real*8 sum,mflops,time
	real*8 time1,time2
	external matmul
	integer size
#ifdef ALLOC
	real*8, allocatable, dimension(:,:) :: a,b,c
	allocate(a(MAXSIZE,MAXSIZE),b(MAXSIZE,MAXSIZE),c(MAXSIZE,MAXSIZE))
#else
	real*8 a(MAXSIZE,MAXSIZE),b(MAXSIZE,MAXSIZE),c(MAXSIZE,MAXSIZE)
#endif
!===================================================================
! open output file
!===================================================================
	open(10,file='matmulf.dat')
	write(10,*)'#   SIZE                MFLOPS'
	print *,'   SIZE          SUM                  MFLOPS'
	size=25
	ntimes=1024
        Do while (size <= 800)
	   sum = 0.d0
! ==================================================================
! initialize arrays
! ==================================================================
	   do j=1,size
            do i=1,size
	     a(i,j)=1.d0
	     b(i,j)=2.d0
	     c(i,j)=0.d0
	    enddo
	   enddo
! ==================================================================
! start timer
! ==================================================================
	   call wtime(time1)
           do i = 1,ntimes
           call matmul(MAXSIZE,a,b,c,size)
           sum = sum + c(size,size)
	   enddo
	   call wtime(time2)
! ==================================================================
! end timer
! ==================================================================
! ==================================================================
! compute sum to avoid dead code removal
! ==================================================================
           do j=1,size
	     do i = 1,size
              sum = sum + c(i,j)
	     enddo
	   enddo
	   time=time2-time1
	   mflops=dble(2*size*size*size*ntimes)*1.d-6/time
	   write(10,11)size,mflops
	   print *,'   ',size,'   ',sum,'   ',mflops
	   size=size*2
	   ntimes=ntimes/4
	enddo
	close(10)
11      format(i10,5x,f15.3)
	end
! ==================================================================

