      program main
!     use mpi
!     Use the following include if the mpi module is not available
      include "mpif.h"
      real(8), parameter :: PI25DT = 3.141592653589793238462643d0
      real(8)  mypi, pi, h, sum, x, f, a, time1, time2, total_time
      integer n, myid, numprocs, i, ierr, ntimes, j
!     function to integrate
! this is a statement function (obsolete - move to an internal function)
      f(a) = 4.d0 / (1.d0 + a*a)

      call MPI_INIT(ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, numprocs, ierr)

	  ! start timer
      time1=MPI_Wtime()

!    calculate the interval size
      n = 1000000
      h = 1.0d0/n
	  
	  ! outer loop to perform multiple trials
	  !ntimes=1024  ! too big to fit in int when multiplied by 3*n*nprocs
	  ntimes=100
      do j = 1,ntimes

		  sum  = 0.0d0
		  do i = myid+1, n, numprocs
			 x = h * (dble(i) - 0.5d0)
			 sum = sum + f(x)
		  enddo
		  mypi = h * sum
	!    collect all the partial sums
		  call MPI_REDUCE(mypi,pi,1,MPI_DOUBLE_PRECISION,MPI_SUM,0, &
							   MPI_COMM_WORLD,ierr)

	  ! end outer num trials loop
      enddo

	  ! end timer
      time2=MPI_Wtime()

	  ! calculate avg time per trial: time2-time1 gives total time
	  total_time=(time2-time1)/ntimes

!    node 0 prints the answer.
      if (myid.eq.0) then
         print *, 'pi is ', pi, ' error is', abs(pi - PI25DT)

		! 4 flops per loop (x has *-, sum has +, f(a) has / and *+)
        mflops = 4*n*1e-6/(total_time)
      
		  !print *, n,' ',ntimes,' ',numprocs,' ',3*n*ntimes*numprocs
		print *, 'mflops =',mflops
        print *, 'total time =',total_time

      endif
     call MPI_FINALIZE(ierr)
     end
