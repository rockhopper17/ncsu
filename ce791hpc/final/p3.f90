! Andrew Navratil
! CE 791 Final Exam - Problem 3 Simpson Rule Integration

program p3
implicit none
include "mpif.h"

	! === constants	===
	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	integer, parameter :: a = 0.0, b = 1.0

	integer, parameter :: n = 1e6  ! num subintervals
	integer, parameter :: numtrials = 1024  ! num trials for benchmarking
	
	! === variables ===
	real(8)  mysum1, mysum2, totalsum1, totalsum2, h, fint, x
	integer i,j,k,numops

	character(len=50) :: filename

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

	! calculate interval size
	h = 1.0d0/n

	! outer loop to run numtrials for benchmarking
	do j = 1,numtrials
		mysum1 = 0.d0
		mysum2 = 0.d0
		
		! calculate sums, distribute workload among all procs
		do i = iam+1,n,nprocs
			x = h*i
			if (mod(i,2).eq.0) then
				mysum2 = mysum2 + f(x)  ! evens
			else
				mysum1 = mysum1 + f(x)  ! odds
			end if
		end do

		! collect all the partial sums (root proc is 0)
		call MPI_REDUCE(mysum1,totalsum1,1,MPI_DOUBLE_PRECISION, &
			MPI_SUM,0,MPI_COMM_WORLD,ierr)
		call MPI_REDUCE(mysum2,totalsum2,1,MPI_DOUBLE_PRECISION, &
			MPI_SUM,0,MPI_COMM_WORLD,ierr)

		! perform the simpson's rule integration version
		fint = (dble(b-a)/dble(3.*n))
		fint = fint * (f(dble(a))+4.*totalsum1+2.*totalsum2+f(dble(b)))
	end do

	! end timer
	time2 = MPI_Wtime()
	avgtime = (time2-time1)/numtrials

	! print mflops and execution time to final.out file
	if (iam.eq.0) then
		write(*,*) 'value of integral is ',fint,' error to pi is ',abs(fint-PI)
		numops = 12 ! +,-,/,*,*,3+,2* in loop, and /,*+ in f
        mflops = numops*n*1e-6/avgtime
		
		write(*,*) 'nprocs =',nprocs
		write(*,*) 'mflops =',mflops
		write(*,*) 'avg time (per trial) =',avgtime
	end if

	! finalize MPI
	call MPI_FINALIZE(ierr)

contains

!====================================
function f(x)
	real(8) x,f

	f = 4.d0/(1.d0 + x*x)

end function f

!====================================
end program p3

