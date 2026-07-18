! ==================================================================
! Naive version of matrix multiply: C = A*B
! ==================================================================
	subroutine matmul(maxn,a,b,c,n)
! ==================================================================
	real*8 a(maxn,maxn),b(maxn,maxn),c(maxn,maxn)
	real*8 sum,scale
	do i=1,n
	  do j=1,n
	    c(i,j) = 0.d0
	    do k=1,n
              c(i,j) = c(i,j) + a(i,k)*b(k,j)
	    enddo
          enddo
        enddo
	return
	end
! ==================================================================
	
