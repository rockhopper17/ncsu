! Andrew Navratil
! CE 791 Final Exam - Problem 5 6-digit combinations

program p5
implicit none
include "mpif.h"

	! === constants	===

	! === variables ===
	integer mycount, totalcount
	integer d1,d2,d3,d4,d5,d6,dsum
	logical docount

	! === MPI variables ===
    real(8) time1,time2,avgtime,ierr
	integer nprocs,iam

	!=========================================================	

	! initialize MPI
	call MPI_INIT(ierr)
	call MPI_COMM_RANK(MPI_COMM_WORLD, iam, ierr)
	call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)

	! start timer for mflops calculation
	time1 = MPI_Wtime()

	! loop for each of the 6 digits, note 1st one can't be 0
	mycount = 0.d0
	!do d1 = 1,9
	d1 = iam+1  ! written specifically for 9 procs
	do d2 = 0,9
	do d3 = 0,9
	do d4 = 0,9
	do d5 = 0,9
	do d6 = 0,9
		! the 6 digit number is d1d2d3d4d5d6
		docount = .true.
		dsum = 0.d0

		! check if any two consecutive digits are the same
		if (d1.eq.d2.or.d2.eq.d3.or.d3.eq.d4.or.d4.eq.d5.or.d5.eq.d6) then
			docount = .false.
		end if

		! check if sum of digits is 7,11,13
		dsum = d1+d2+d3+d4+d5+d6
		if (dsum.eq.7.or.dsum.eq.11.or.dsum.eq.13) then
			docount = .false.
		end if

		if (docount) then
			mycount = mycount + 1
		end if
	end do
	end do
	end do
	end do
	end do
	!end do

	! aggregate counts
	call MPI_REDUCE(mycount,totalcount,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD,ierr)

	! print mflops and execution time to final.out file
	if (iam.eq.0) then
		write(*,*) 'num combinations = ',totalcount
		
		write(*,*) 'nprocs =',nprocs
		write(*,*) 'avg time (per trial) =',avgtime
	end if

	! finalize MPI
	call MPI_FINALIZE(ierr)

end program p5

