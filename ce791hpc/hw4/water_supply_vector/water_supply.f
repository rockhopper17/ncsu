! program to perform enumeration for a water supply problem
	Program water_supply
        use ifport
		!use mpi
      include "mpif.h"
!declare variables
	integer, parameter :: ntrials = 10000000, iseed=567891
	real(8) x1(ntrials), x2(ntrials), x3(ntrials), cost(ntrials)
	real(8) sl1, sl2, sl3, hc1, hc2, hc3, demand, uc1, uc2, uc3, hardness
        real(8) time1, time2, time3, time4
        real(8) min_cost, time_obj, time_gen, elapsed_time, mflops
        integer min_cost_index

      	integer n, myid, numprocs, ierr, ntimes
		integer i,j,k
		real(8) min_cost_global

	sl1=25; sl2=120; sl3=100; hc1=200; hc2=2300; hc3=700
	demand=150; uc1=500; uc2=1000; uc3=2000

      call MPI_INIT(ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, numprocs, ierr)

	  ! start timer - want to run for entire computation
      time1=MPI_Wtime()

! generate trial values
	!call wtime(time1)

	  ! outer loop to perform multiple trials
	  !ntimes=1024  ! too big to fit in int when multiplied by 3*n*nprocs
	  ntimes=10
      do k = 1,ntimes
!==================================
        j = 0
        call seed(iseed)
	do i=1,ntrials
	!do i=myid+1,ntrials,numprocs  
                x3(i) = -1
		do while (x3(i) > sl3 .or. x3(i) < 0 .or. &
                   hardness > 1200)
                   x1(i)=rand()*sl1
                   x2(i)=rand()*sl2
		   x3(i)=demand-x1(i)-x2(i)
		   hardness=(hc1*x1(i)+hc2*x2(i)+hc3*x3(i))/demand
                   j=j+1
                enddo
        enddo

	!    collect all the partial sums
! look into this later, MPI_Gather maybe
		  !call MPI_REDUCE(x1(i)uu,pi,1,MPI_DOUBLE_PRECISION,MPI_SUM,0, &
							   !MPI_COMM_WORLD,ierr)
	!call wtime(time2)
	!time_gen=time2-time1
!calculate cost
	do i=1,ntrials
	    cost(i)=uc1*x1(i)+uc2*x2(i)+uc3*x3(i)
        enddo
	!call wtime(time3)
	!time_obj=time3-time2
	min_cost=1e10
	do i=myid+1,ntrials,numprocs
            if (cost(i) < min_cost) then
               min_cost=cost(i)
               min_cost_index=i
            endif
        enddo

! use MPI_MIN on min_cost
call MPI_REDUCE(min_cost,min_cost_global,1,MPI_DOUBLE_PRECISION,MPI_MIN,0,MPI_COMM_WORLD,ierr)

	  ! end outer num trials loop
      enddo

	  ! end timer
      time2=MPI_Wtime()

	  ! calculate avg time per trial: time2-time1 gives total time
	  elapsed_time=(time2-time1)/ntimes

	!call wtime(time4)
	!elapsed_time=time4-time1

!    node 0 prints the answer.
      if (myid.eq.0) then
        !mflops_obj=5*ntrials*1e-6/time_obj
        mflops = dble(10*j+ntrials*5)*1e-6/elapsed_time

	!print *, 'amount drawn from source1 =',x1(min_cost_index)
	!print *, 'amount drawn from source2 =',x2(min_cost_index)
	!print *, 'amount drawn from source3 =',x3(min_cost_index)
	print *,'Minimum cost = ',nint(min_cost_global),' dollars'
	!print *,'Time to generate alternatives  = ',time_gen,' secs'
	!print *,'Time to calculate objective  = ',time_obj,' secs'
	!print *,'Mflop rating for Objective calculation = ',mflops_obj,' mflops'
	print *,'Mflop rating for entire code = ',mflops,' mflops'
	print *,'Total time = ',elapsed_time,' secs'
    
	endif
     call MPI_FINALIZE(ierr)
	end
