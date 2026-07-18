! Andrew Navratil
! CE 791 Final Exam - Problem 4 Sum

program p4
implicit none
include "mpif.h"

	! === constants	===
	integer, parameter :: numtrials = 1024  ! num trials for benchmarking

	! === variables ===
	integer x,totalsum,sumcheck 
	integer i,j,k,numops

	! === MPI variables ===
    real(8) time1,time2,avgtime,mflops,ierr
	integer nprocs,iam

	!=========================================================	

	! initialize MPI
	call MPI_INIT(ierr)
	call MPI_COMM_RANK(MPI_COMM_WORLD, iam, ierr)
	call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)

	! start timer for mflops calculation
	time1 = MPI_Wtime()

	! outer loop to run numtrials for benchmarking
	do j = 1,numtrials
		x = iam+1

		call MPI_REDUCE(x,totalsum,1,MPI_INT, &
			MPI_SUM,0,MPI_COMM_WORLD,ierr)
	end do

	! end timer
	time2 = MPI_Wtime()
	avgtime = (time2-time1)/numtrials

	! print mflops and execution time to final.out file
	if (iam.eq.0) then
		sumcheck = nprocs*(nprocs+1)/2
		write(*,*) 'reduction sum = ',totalsum
		write(*,*) 'sum check on 0 = ',sumcheck
		numops = 1
        mflops = numops*nprocs*1e-6/avgtime
		
		write(*,*) 'nprocs =',nprocs
		write(*,*) 'mflops =',mflops
		write(*,*) 'avg time (per trial) =',avgtime
	end if

	! finalize MPI
	call MPI_FINALIZE(ierr)

end program p4

