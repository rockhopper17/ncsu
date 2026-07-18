!******************************************************************************
! module for utility subroutines and functions
!******************************************************************************
module util
implicit none
contains

!=========================================
! solve Ax=b: Gauss elimination (direct)
!=========================================
subroutine sol_gauss(n,a,b,x)

	integer,intent(in) :: n
	real(8),dimension(n,n),intent(in) :: a
	real(8),dimension(n),intent(in) :: b
	real(8),dimension(n),intent(out) :: x

	real(8),dimension(n,n+1) :: ab
	real(8) :: mik
	integer :: i,j,k

	! combine a and b into a single matrix
	ab(:,1:n) = a
	ab(:,n+1) = b

	! forward elimination
	!do k = 1,n-1
		!do i = k+1,n
			!mik = ab(i,k)/ab(k,k)
			!do j = k,n+1
				!ab(i,j) = ab(i,j) - mik*ab(k,j)
			!end do
		!end do
	!end do
	do j = 1,n-1
		do i = j+1,n
			ab(i,j:n+1) = ab(i,j:n+1) - (ab(i,j)/ab(j,j))*ab(j,j:n+1)
		end do
	end do

	x = 0.0
	x(n) = ab(n,n+1)/ab(n,n)
	do i = n-1,1,-1
		x(i) = (ab(i,n+1)-dot_product(ab(i,i+1:n),x(i+1:n)))/ab(i,i)
	end do

end subroutine sol_gauss

!=========================================
! solve Ax=b: conjugate gradient method (basic)
! to be optimized with preconditioning
!=========================================
subroutine sol_cg(n,a,b,x)

	integer,intent(in) :: n
	real(8),dimension(n,n),intent(in) :: a
	real(8),dimension(n),intent(in) :: b
	real(8),dimension(n),intent(out) :: x
	
	real(8),dimension(n) :: r,p,ap
	real(8) :: alpha, rsqold, rsqnew, eps
	integer :: i,k

	eps = 1e-10	! convergence tolerance

	! initialize x, r, p
	do i = 1,n
		x(i) = 0.0		! init guess: x = 0
		r(i) = b(i)		! Ax=0 so r=b-Ax-b=b
		p(i) = r(i)
	end do

	rsqold = dot_product(r,r)

	! perform cg loop
	do k = 1,size(b)
		ap = matmul(a,p)

		alpha = rsqold / dot_product(p,ap)
		
		do i = 1,n
			x(i) = x(i) + (alpha * p(i))
		end do
		
		do i = 1,n
			r(i) = r(i) - (alpha * ap(i))
		end do

		rsqnew = dot_product(r,r)
		if (sqrt(rsqnew) < eps) then
			exit
		end if

		do i = 1,n
			p(i) = r(i) + p(i)*(rsqnew/rsqold)
		end do

		rsqold = rsqnew

	end do

end subroutine sol_cg

end module util
