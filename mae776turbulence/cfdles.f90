! Andrew Navratil
! MAE 776 Turbulence - LES project part 1

!******************************************************************************
! read in velocity data and compute statistics
!******************************************************************************
module velocity_data
implicit none

	! *** constants ***
	integer, parameter :: npts = 10743	! num data points (lines in file)
	integer, parameter :: ndim = 2		! num spatial dimensions (2=u,v)

	! *** global variables ***
	real(8) :: t(npts)				! time 
	real(8) :: u(npts,ndim)			! velocity 
	real(8) :: ufluc(npts,ndim)		! fluctuation
	
	real(8) :: tmin,tmax,trange				
	real(8) :: umin(ndim),umax(ndim),urange(ndim)
	real(8) :: uflucmin(ndim),uflucmax(ndim),uflucrange(ndim)
	real(8) :: uavg(ndim),usqavg(ndim)  ! expectation (time avg for discrete)
	real(8) :: uvar(ndim)				! variance
	real(8) :: ustd(ndim)				! standard deviation ('rms')
	real(8) :: covar					! covariance (Reynolds stress) (u1-u2)
	real(8) :: corel					! correlation coefficient (u1-u2)

	! dynamic arrays for pdfs *** getting malloc errors periodically, forget this
	integer,allocatable :: updf(:,:)	! pdf (creating with max num bins)

	integer :: i,j,k					! reserve i,j,k for indexing

contains

!=== read data file ===
subroutine data_import

	! read file - data for a single point over time: t u(t) v(t)
	open(11,file='data/singlepointdata',status='old')
	do i = 1,npts
		read(11,*) t(i),u(i,1),u(i,2)  ! u(i,1)=u vel, u(i,2)=v vel
	enddo

end subroutine data_import

!=== calculate statistics ===
subroutine calc_stats

	! calculate time values
	tmin = minval(t)
	tmax = maxval(t)
	trange = tmax - tmin

	! calculate statistics values
	do j = 1,ndim	
		umin(j) = minval(u(:,j))
		umax(j) = maxval(u(:,j))
		urange(j) = umax(j) - umin(j)
		uavg(j) = sum(u(:,j)) / npts
		uvar(j) = (sum(u(:,j)**2)/npts) - uavg(j)**2
		ustd(j) = sqrt(uvar(j))
	end do

	! calculate variances
	covar = (sum(u(:,1)*u(:,2))/npts) - (uavg(1)*uavg(2))
	corel = covar / sqrt(uvar(1)*uvar(2))
	
	! calculate fluctuations (normalized by std)
	do j = 1,ndim	
		do i = 1,npts
			ufluc(i,j) = (u(i,j)-uavg(j))/ustd(j)
		end do
		uflucmin(j) = minval(ufluc(:,j))
		uflucmax(j) = maxval(ufluc(:,j))
		uflucrange(j) = uflucmax(j) - uflucmin(j)
	end do
	
end subroutine calc_stats

end module velocity_data

!******************************************************************************
! procedures
!******************************************************************************
module procedures
use velocity_data
implicit none
contains

!=== calculate pdf for ufluc/ustd ===
subroutine calc_pdf1
	
	!integer, intent(in) :: jdim
	integer :: nbins,bidx
	real(8) :: du

	!do nbins = 50,800,50
	do nbins = 5,20,5
		allocate(updf(nbins,ndim))
		do j = 1,ndim
			do i = 1,nbins
				updf(i,j) = 0
				!print *,updf(i,j)  ! gdb not printing this correctly
			end do
		end do

		do j = 1,ndim
			du = uflucrange(j)/nbins

			do i = 1,npts
				bidx = floor((ufluc(i,j)-uflucmin(j))/du)
				updf(bidx,j) = updf(bidx,j) + 1
			end do
		end do

		call print_pdf(nbins)
		deallocate(updf)
		print *,'wtf'

	end do

end subroutine calc_pdf1

!=== print the current pdf to file for tecplot ===
subroutine print_pdf(nbins)

	integer,intent(in) :: nbins

	do j = 1,ndim
		do i = 1,nbins
			write(*,"(A2,I3,A1,I1,A4,I5)") 'u(',i,',',j,') = ',updf(i,j)
		end do
	end do

end subroutine print_pdf

!=== print out the raw data (top 100) ===
subroutine print_raw_data

	write(*,*) 'raw data'
	do i = 1,100
		write(*,"(3E20.8)") t(i),u(i,1),u(i,2)
	end do

end subroutine print_raw_data

!=== print out some stats ===
subroutine print_stats

	write(*,*) 'pblms 1,2'
	write(*,"(A10,F8.1)") 'u avg = ',uavg(1)
	write(*,"(A10,F8.1)") 'v avg = ',uavg(2)
	write(*,"(A10,F8.1)") 'u var = ',uvar(1)
	write(*,"(A10,F8.1)") 'v var = ',uvar(2)
	write(*,"(A10,F8.1)") 'u std = ',ustd(1)
	write(*,"(A10,F8.1)") 'v std = ',ustd(2)
	write(*,"(A10,F8.1)") 'covar = ',covar
	write(*,"(A10,F8.2)") 'corel R = ',corel

end subroutine print_stats

end module procedures

!******************************************************************************
! main program
!******************************************************************************
program cfdles
use velocity_data
use procedures
implicit none

	call data_import
	call calc_stats
	call calc_pdf1

	!call print_raw_data
	call print_stats
	!call print_sln_tecplot

end program cfdles

