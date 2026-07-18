! ==================================================================
! This is a simple code that performs the vector operation vaxpy
! defined by A = A + B*C where A, B, C are vectors. A good
! test for memory bandwidth limitations (2 fp operations for 4 memory
! accesses), and cache size.
! Prints out the mflop rating associated with each size
! ==================================================================
! constant declarations
! ==================================================================
#define MAXBLOCKS 1024*1024
#define MINBLOCKS 1
#define BLOCKSIZE 1
#define MAXSIZE 1050*1050
#define MAXTIMES 100000
#define MINTIMES 10
#define MINVOLUME 8192*1024
! ==================================================================
! vector-vector multiply
! ==================================================================
	Program vector
	real(8) avsum,mflops,time
	real(8) time1,time2
#ifdef ALLOC
	real(8), allocatable, dimension(:) :: a,b,c
	allocate(a(MAXSIZE),b(MAXSIZE),c(MAXSIZE), stat=istat)
	if (istat.ne.0)  print *,'Error in allocating a,b,c'
#else
	real(8) a(MAXSIZE),b(MAXSIZE),c(MAXSIZE)
#endif
! ==================================================================
! initialize arrays
! ==================================================================
	do i=1,MAXSIZE
	   a(i)=0.d0
	   b(i)=dble(i)
	   c(i)=dble(i)
	enddo
!===================================================================
! open output file
!===================================================================
	open(10,file='flops_fortran.dat')
	write(10,*)'#   SIZE (words)       MFLOPS'
	k=1
	do while (k.le.MAXBLOCKS)
           nn=k*BLOCKSIZE
! ==================================================================
! initialize arrays
! ==================================================================
	   ntimes=min(MINVOLUME/nn+MINTIMES,MAXTIMES)
! ==================================================================
! start timer
! ==================================================================
	   call wtime(time1)
	   avsum=0.d0
	   do i=1,ntimes
	      do j=1,nn
	         a(j)=a(j)+b(j)*c(j)
	      enddo
	      avsum=avsum+a(nn)
	   enddo
	   call wtime(time2)
! ==================================================================
! end timer
! ==================================================================
	   time=time2-time1
	   mflops=dble(nn*ntimes*2)/(time*1.d6)
	   write(10,11)nn,mflops
	   write(*,10)
	   write(*,*)'size =',nn
	   write(*,*)'avsum =',avsum
	   write(*,*)'time =',time
	   write(*,*)'mflops =',mflops
	   write(*,10)
           k=k*2
	enddo
	close(10)
10	format(70('=')/)
11      format(i10,5x,f15.3)
	end
! ==================================================================


