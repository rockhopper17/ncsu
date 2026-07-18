!================================================================
! common part
!================================================================
program main
include "mpif.h"

!================================================================
! initialize main parameters
!================================================================
integer, parameter :: CHUNKSIZE = 1000
!integer, parameter :: CHUNKSIZE = 10
integer, parameter :: REQUEST = 1
integer, parameter :: REPLY = 2
real(8), parameter :: EPS = 0.001
real(8), parameter :: PI = 4.D0*DATAN(1.D0)
integer, parameter :: iseed = 567891

!================================================================
! declare variables
!================================================================
integer iter,iters
integer nin,nout,i,nmax,ix,iy,ranks(1),tmp
logical isdone
real(8) x,y,pival,rand_max_inv,valtest,errval
real(8) rands(CHUNKSIZE),nextrand
integer myid,numprocs,manager,totalin,totalout,workerid
integer ierr,mpistatus(MPI_STATUS_SIZE),world_group,worker_group
integer world,workers,sender
real(8) time1, time2, total_time, mflops 
integer req

!================================================================
! initialize MPI
!================================================================
world = MPI_COMM_WORLD
call MPI_INIT(ierr)
call MPI_COMM_SIZE(world, numprocs, ierr)
call MPI_COMM_RANK(world, myid, ierr)

manager = numprocs-1 ! last proc is manager

!call MPI_BCAST(EPS,1,MPI_DOUBLE_PRECISION,0,MPI_COMM_WORLD,ierr)
call MPI_COMM_GROUP(world,world_group,ierr)

ranks(1) = manager
call MPI_GROUP_EXCL(world_group,1,ranks,worker_group,ierr)
call MPI_COMM_CREATE(world,worker_group,workers,ierr)

! now start timer for mflops calculation
time1 = MPI_Wtime()  

!================================================================
! manager
!================================================================
if (myid.eq.manager) then
	! generate random numbers and send to workers
	req = 1 ! init this greater than 0
	do while (req.gt.0)
		call MPI_RECV(req,1,MPI_INT,MPI_ANY_SOURCE,REQUEST, &
			world,mpistatus,ierr)
		sender = mpistatus(MPI_SOURCE)

		if (req.gt.0) then
			! rand() is not working, give seg faults, trying this
			call random_seed()
			call random_number(rands)

			!call seed(iseed)
			!!write(*,*) rands(8),rands(7),rands(9)
			!do i=1,CHUNKSIZE
				!write(*,*) i,rands(i)
				!rands(i) = rand()
				!!rands(i) = 77.0
				!write(*,*) rands(i),CHUNKSIZE,i,rand(),rand()
			!end do

			! send to worker
			!write (*,*) 'master before send'
			call MPI_SEND(rands,CHUNKSIZE,MPI_DOUBLE_PRECISION,sender,REPLY, &
				world,ierr)
			!write (*,*) 'master after send'
		end if
	end do

!================================================================
! worker
!================================================================
else
	req = 1
	isdone = .false.
	nin = 0
	nout = 0

	call MPI_SEND(req,1,MPI_INT,manager,REQUEST,world,ierr)
		!write (*,*) 'worker after send'
	call MPI_COMM_RANK(workers,workerid,ierr)
		!write (*,*) 'worker after comm rank'

	iter = 0;
	do while (isdone.ne..true.)
		iter = iter + 1
		req = 1
		!write (*,*) 'worker before recv'
		! ***need to change data type to MPI_DOUBLE_PRECISION (lecture had MPI_INT)
		call MPI_RECV(rands,CHUNKSIZE,MPI_DOUBLE_PRECISION,manager,REPLY, &
			world,mpistatus,ierr)
		!write (*,*) 'worker after recv'
			!do i=1,CHUNKSIZE
				!write(*,*) i,rands(i)
			!end do

		do i=1,CHUNKSIZE,2
			!write (*,*) 'rands(i)=',rands(i),' rands(i+1)=',rands(i+1)
			x = rands(i)*2-1
			y = rands(i+1)*2-1
			valtest = x*x+y*y
			!write (*,*) 'worker valtest = ',valtest,' x=',x,' y=',y
			if (valtest.lt.1.0) then
				nin = nin+1
			else
				nout = nout+1
			end if
		end do

		!write (*,*) 'worker nin=',nin,' nout=',nout
		call MPI_ALLREDUCE(nin,totalin,1,MPI_INT,MPI_SUM,workers,ierr)
		call MPI_ALLREDUCE(nout,totalout,1,MPI_INT,MPI_SUM,workers,ierr)

		pival = (4.0*totalin)/(totalin+totalout)
		errval = abs(pival-PI)
		!write (*,*) 'pival=',pival,' errval=',errval,' PI=',PI

		if (errval.lt.eps.or.totalin+totalout.gt.1E6) then
			isdone = .true.
			req = 0
		else
			isdone = .false.
			req = 1
		end if

		if (workerid.eq.0) then
			write(*,*) 'rpi = ',pival
			call MPI_SEND(req,1,MPI_INT,manager,REQUEST,world,ierr)
		elseif (req.eq.1) then
			call MPI_SEND(req,1,MPI_INT,manager,REQUEST,world,ierr)
		end if
	end do

	call MPI_COMM_FREE(workers,ierr)
end if

! stop timer
time2 = MPI_Wtime()
total_time = time2-time1

!================================================================
! compute Mflops and finalize
!================================================================
if (myid.eq.0) then
	! estimating 12 flops per point
	mflops = 12*dble(totalin+totalout)*1e-6/(total_time)
	write(*,*) 'npoints = ',totalin+totalout,' nin = ',totalin,' nout = ',totalout
	print *, 'numprocs =',numprocs
	print *, 'mflops =',mflops
end if

call MPI_GROUP_FREE(worker_group,ierr)
call MPI_FINALIZE(ierr)

end
