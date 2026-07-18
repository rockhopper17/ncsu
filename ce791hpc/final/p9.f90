! Andrew Navratil
! CE 791 Final Exam - Problem 9

program p9
implicit none
include "mpif.h"

	! === constants	===
	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	integer, parameter :: n = 1e6
	
	! === variables ===
	integer i,j,k,iter
    real(8) cr

	character(len=50) :: filename

	! === MPI variables ===
    real(8) time1,time2,total_time,ierr
	integer nprocs,iam,minid

	! grid data displayed in pdf assumes y=100 is bottom row, y=400 is top row
	! to view it like x-y grid with origin in bottom left corner
	real(8), dimension(5) :: xgrid
	real(8), dimension(4) :: ygrid,tgrid
	real(8), dimension(4,5,4) :: obsvals ! observation data: k,x,y
	real(8) cs,val1,val2,x0,y0,m0,curc,minc
	real(8), dimension(2) :: mincl,mincg,x0minl,y0minl,m0minl
	real(8), allocatable :: x0min(:), y0min(:), m0min(:)

	xgrid = (/ 100, 300, 500, 700, 900 /)
	ygrid = (/ 100, 200, 300, 400 /)
	tgrid = (/ 30,60,90,120 /)
	obsvals(1,:,1) = (/0.0000 ,0.0000 ,0.0000 ,0.0000 ,0.0000 /)
	obsvals(1,:,2) = (/0.0000 ,0.0000 ,0.0000 ,0.0000 ,0.0000 /)
	obsvals(1,:,3) = (/0.0611 ,9.0783 ,1.6974 ,0.0004 ,0.0000 /)
	obsvals(1,:,4) = (/0.0114 ,1.7028 ,0.3154 ,0.0001 ,0.0000 /)
	obsvals(2,:,1) = (/0.0000 ,0.0000 ,0.0000 ,0.0000 ,0.0000 /)
	obsvals(2,:,2) = (/0.0013 ,0.1883 ,0.9862 ,0.1882 ,0.0013 /)
	obsvals(2,:,3) = (/0.0158 ,2.3119 ,11.9102 ,2.3336 ,0.0153 /)
	obsvals(2,:,4) = (/0.0000 ,0.0067 ,0.0359 ,0.0068 ,0.0000 /)
	obsvals(3,:,1) = (/0.0000 ,0.0046 ,0.0740 ,0.1290 ,0.0241 /)
	obsvals(3,:,2) = (/0.0015 ,0.2217 ,3.5988 ,6.4052 ,1.2005 /)
	obsvals(3,:,3) = (/0.0003 ,0.0427 ,0.6870 ,1.1862 ,0.2238 /)
	obsvals(3,:,4) = (/0.0000 ,0.0000 ,0.0005 ,0.0009 ,0.0002 /)
	obsvals(4,:,1) = (/0.0001 ,0.0125 ,0.3435 ,1.8402 ,1.8562 /)
	obsvals(4,:,2) = (/0.0001 ,0.0189 ,0.5285 ,2.7696 ,2.8031 /)
	obsvals(4,:,3) = (/0.0000 ,0.0004 ,0.0124 ,0.0651 ,0.0654 /)
	obsvals(4,:,4) = (/0.0000 ,0.0000 ,0.0000 ,0.0000 ,0.0000 /)

	!=========================================================	

	! initialize MPI
	call MPI_INIT(ierr)
	call MPI_COMM_RANK(MPI_COMM_WORLD, iam, ierr)
	call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)

	allocate(x0min(0:nprocs-1),y0min(0:nprocs-1),m0min(0:nprocs-1))

	! start timer for mflops calculation
	time1 = MPI_Wtime()

	! generate random numbers and distribute to procs cyclically
	call random_seed()

	! calculate sums, distribute workload among all procs
	minc = 1e15
	do iter = iam+1,n,nprocs
	    call random_number(cr)
		x0 = floor(cr*1000)
	    call random_number(cr)
		y0 = floor(cr*500)
	    call random_number(cr)
		m0 = floor(cr*100)
		!write(*,*) x0,y0,m0

		! loop each time step and x,y location in observation data
		do k = 1,4
		do i = 1,5
		do j = 1,4
			val1 = (xgrid(i)-x0-5*tgrid(k))**2 / (4*100*tgrid(k))
			val2 = (ygrid(j)-y0-2*tgrid(k))**2 / (4*10*tgrid(k))
			cs = (10e5*m0)/(8*(PI*tgrid(k))**(1.5)*sqrt(100.*10.))
			cs = cs*exp(-val1-val2-0.001*tgrid(k))
!print *,'obs=',obsvals(k,i,j),' cs=',cs
			curc = curc + (obsvals(k,i,j) - cs)**2
		end do
		end do
		end do

		!print *, minc
		if (curc.lt.minc) then
			x0minl = x0
			y0minl = y0
			m0minl = m0
			minc = curc
			print *,minc,x0,iam
		end if

		mincl(1) = minc
		mincl(2) = dble(iam)
	end do

    !call MPI_ALLREDUCE(mincl,mincg,1,MPI_2DOUBLE_PRECISION,&
        !MPI_MINLOC,MPI_COMM_WORLD,ierr)

	call MPI_GATHER(x0minl,1,MPI_DOUBLE_PRECISION, &
		x0min,1,MPI_DOUBLE_PRECISION,0,MPI_COMM_WORLD,ierr)
	call MPI_GATHER(y0minl,1,MPI_DOUBLE_PRECISION, &
		y0min,1,MPI_DOUBLE_PRECISION,0,MPI_COMM_WORLD,ierr)
	call MPI_GATHER(m0minl,1,MPI_DOUBLE_PRECISION, &
		m0min,1,MPI_DOUBLE_PRECISION,0,MPI_COMM_WORLD,ierr)

	! end timer
	time2 = MPI_Wtime()
	total_time = time2-time1

	! print data and execution time to final.out file
	if (iam.eq.0) then
		do i=0,nprocs-1
			print *, x0min(i),y0min(i),m0min(i)
		end do
		minid = mincg(2)
		print *, 'minid=',minid
		print *, 'min x0=',x0min(minid),' min y0=',y0min(minid),' min m0=',m0min(minid)
		print *, 'nprocs =',nprocs
		print *, 'total time =',total_time
	end if

	! finalize MPI
	call MPI_FINALIZE(ierr)

end program p9

