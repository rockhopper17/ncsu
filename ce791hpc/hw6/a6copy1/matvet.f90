!================================================================
! common part
!================================================================
program main
include "mpif.h"

!================================================================
! initialize main parameters
!================================================================
integer, parameter :: MAX_ROWS = 1000
integer, parameter :: MAX_COLS = 1000

!================================================================
! declare variables
!================================================================
integer rows, cols
real(8) :: a(MAX_ROWS,MAX_COLS), b(MAX_COLS), c(MAX_ROWS)
real(8) :: buffer(MAX_COLS), ans
integer myid,master,numprocs,ierr,mpistatus(MPI_STATUS_SIZE)
integer i,j,numsent,sender
integer anstype,row
real(8) time1, time2, total_time, mflops 
character(len=50) :: filename

!================================================================
! initialize MPI
!================================================================
call MPI_INIT(ierr)
call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ierr)
call MPI_COMM_SIZE(MPI_COMM_WORLD, numprocs, ierr)
master = 0
rows = 100
cols = 100
row = 0

time1=MPI_Wtime()  ! start timer for mflops calculation

!================================================================
! master
!================================================================
if (myid.eq.master) then
	! initialize matrix A, vector b, and dispatch work
	do j=1,cols
		b(j) = 1.0
		do i=1,rows
			a(i,j) = i
		end do
	end do
	numsent = 0

	! send b to each slave process
	call MPI_BAST(b,cols,MPI_DOUBLE_PRECISION,master,MPI_COMM_WORLD,ierr)

	! send a single row to each slave process; tag with row number
	do i=1,min(numprocs-1,rows)
		do j=1,cols
			buffer(j)=a(i,j)  ! collect row i into buffer(1:cols)
		end do
		call MPI_SEND(buffer,cols,MPI_DOUBLE_PRECISION,i,i,MPI_COMM_WORLD,ierr)
		numsent = numsent + 1
	end do

	! now iterate all rows to receive responses
	! and to send the rest of the rows that weren't sent yet
	! since usually numprocs-1 < rows
	do i=1,rows
		call MPI_RECV(ans,1,MPI_DOUBLE_PRECISION,MPI_ANY_SOURCE,MPI_ANY_TAG, &
			MPI_COMM_WORLD,mpistatus,ierr)
		sender = mpistatus(MPI_SOURCE)
		anstype = mpistatus(MPI_TAG)  ! tag value is the row number too
		c(anstype) = ans

		! send another row if not all sent yet
		if (numsent.lt.rows) then
			do j=1,cols
				buffer(j)=a(numsent+1,j)
			end do
			! send to sender, which is the proc that just returned an answer
			call MPI_SEND(buffer,cols,MPI_DOUBLE_PRECISION,sender,numsent+1, &
				MPI_COMM_WORLD,ierr)
			numsent = numsent + 1
		else
			! tell sender (slave proc) that there is no more work
			call MPI_SEND(MPI_BOTTOM,0,MPI_DOUBLE_PRECISION,sender,0, &
				MPI_COMM_WORLD,ierr)
		end if
	end do
	!================================================================
	! compute Mflops and finalize
	!================================================================
	time2 = MPI_Wtime()
	total_time = time2-time1

	! one += and one * per matrix entry when calculating dot product
	! not sure if we should count all the buffer assignments
	! but let's assume the matrix ops far outweigh those and they're just memory ops
	! no overall iteration, so just execute a few times to get sense of avg mflops
	mflops = 2*dble(cols)*dble(rows)*1e-6/(total_time)
	print *, 'mflops =',mflops


!================================================================
! slave
!================================================================
else
	! receive b from master
	call MPI_BAST(b,cols,MPI_DOUBLE_PRECISION,master,MPI_COMM_WORLD,ierr)

	! ensure we have data to process, then process
	!do while (myid.le.rows.and.row.le.rows)  ! this checks row before it's set...
	! Gropp book didn't do this, so taking it back out
	do while (myid.le.rows)  ! removing that condition
		call MPI_RECV(buffer,cols,MPI_DOUBLE_PRECISION,master,MPI_ANY_TAG, &
			MPI_COMM_WORLD,mpistatus,ierr)
		row = mpistatus(MPI_TAG)

		! computer dot product and return answer to master
		! row 0 means no more work, otherwise compute
		if (row.ne.0) then
			ans = 0.0
			do j=1,cols
				ans = ans + buffer(j)*b(j)
			end do
			call MPI_SEND(ans,1,MPI_DOUBLE_PRECISION,master,row, &
				MPI_COMM_WORLD,ierr)
		end if
	end do
end if


call MPI_FINALIZE(ierr)
end
