! Andrew Navratil
! MAE 766 CFD - HW 1

!******************************************************************************
! module for reading/setting constants, inputs, grid data and metrics
!******************************************************************************
module grid_data
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	! constants	===============================
	! hard coding number of elements/nodes to avoid dynamic arrays
	integer, parameter :: hskip = 9			! num header lines to skip
	integer, parameter :: ndimn = 2			! num spatial dimensions
	integer, parameter :: nelem = 1559		! num elements
	integer, parameter :: npoin = 839		! num nodes/points
	integer, parameter :: nface = 117		! num boundary faces

	! global variables - grid ========================
	integer, dimension(nelem,3) :: elemmat	! connectivity matrix (3 nodes CCW)
	real(8), dimension(npoin,2) :: nodemat	! node coordinates
	! boundary faces: read 1st node -> 2nd node and comp domain is on left
	integer, dimension(nface,2) :: bdrymat	! boundary face nodes

	integer :: i,j,k						! reserve i,j,k for indexing

contains

!==============================================================================
! read in grid/mesh
!==============================================================================
subroutine grid_setup

	! open grid file and process
	open(11,file='grids/feflo.domn.bump',status='old')
	do i=1,hskip
		read(11,*)
	enddo
	! note: assumes elems/nodes/faces in order, skip num using k
	! read element nodes
	do i=1,nelem
		read(11,*) k,elemmat(i,1),elemmat(i,2),elemmat(i,3)
	end do
	! read node coordinates
	read(11,*)
	do i=1,npoin
		read(11,*) k,nodemat(i,1),nodemat(i,2)
	end do
	! skip sln value section
	read(11,*)
	do i=1,npoin
		read(11,*)
	end do
	! read boundary face nodes
	read(11,*)
	do i=1,nface
		read(11,*) k,bdrymat(i,1),bdrymat(i,2)
	end do
	close(11)

end subroutine grid_setup

!====================
end module grid_data
!====================

!******************************************************************************
! module for procedures
!******************************************************************************
module procedures
implicit none
contains

!==============================================================================
! print solution to tecplot
!==============================================================================
subroutine print_sln_tecplot
use grid_data

	open(1, file = 'data/hw1grid.plt', status='replace')
	write(1,*) 'TITLE=HW1 Unstructured Grid'
	write(1,*) 'VARIABLES=X,Y'
	write(1,"(A11,I5,A10,I5)",advance="no") 'ZONE NODES=',npoin,',ELEMENTS=',nelem
	write(1,*) ',DATAPACKING=POINT,ZONETYPE=FETRIANGLE'
	do i=1,npoin
		write(1,"(E20.8,A1,E20.8)") nodemat(i,1),' ',nodemat(i,2)
	end do
	do i=1,nelem
		write(1,"(I5,A1,I5,A1,I5)") elemmat(i,1),' ',elemmat(i,2),' ',elemmat(i,3)
	end do
	close(1)

end subroutine print_sln_tecplot

!==============================================================================
! print grid to screen
!==============================================================================
subroutine print_grid
use grid_data

	write(*,*) 'element nodes'
	do j=1,nelem
		write(*,"(4I5)") j,elemmat(j,1),elemmat(j,2),elemmat(j,3)
	end do
	write(*,*)

	write(*,*) 'node coordinates'
	do j=1,npoin
		write(*,"(I5,2E20.8)") j,nodemat(j,1),nodemat(j,2)
	end do
	write(*,*)
	
	write(*,*) 'boundary face nodes'
	do j=1,nface
		write(*,"(3I5)") j,bdrymat(j,1),bdrymat(j,2)
	end do
	write(*,*)

end subroutine print_grid

!====================
end module procedures
!====================

!******************************************************************************
! main cfd solver program
!******************************************************************************
program cfd
use grid_data
use procedures
implicit none

	call grid_setup

	call print_grid
	call print_sln_tecplot

end program cfd

