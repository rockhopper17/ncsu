! Andrew Navratil
! MAE 560 HW4 - 2D Steady State Laplace and Poisson

!==============================================================================
! module for reading/setting constants, inputs, grid data and metrics
!==============================================================================
module grid_data
implicit none

	real(8), parameter :: PI = 4.D0*DATAN(1.D0)

	! constants	===============================
	integer, parameter :: niter = 1E6			! max num of iterations
	
	! testing *** hard code number of cells for performance
	! look in dat file for numbers (will be nx+1,ny+1 values)
	!integer, parameter :: pblm = 1				! uniform test
	!integer, parameter :: nx = 10				! nx cells => nx+1 nodes
	!integer, parameter :: ny = 10				! ny cells => ny+1 nodes
	!integer, parameter :: pblm = 17			! grids/g.dat test
	!integer, parameter :: nx = 96				! nx cells => nx+1 nodes
	!integer, parameter :: ny = 56				! ny cells => ny+1 nodes

	! Laplace **********************	
	!integer, parameter :: pblm = 2				! uniform grid 11x11
	!integer, parameter :: nx = 11				! nx cells => nx+1 nodes
	!integer, parameter :: ny = 11				! ny cells => ny+1 nodes
	!character(len=50) :: filename = 'hw4data/ss_laplace_11.txt'
	!integer, parameter :: nx = 21				! nx cells => nx+1 nodes
	!integer, parameter :: ny = 21				! ny cells => ny+1 nodes
	!character(len=50) :: filename = 'hw4data/ss_laplace_21.txt'

	!integer, parameter :: iteropt = 1			! Jacobi = 1
	!real(8), parameter :: omega = 1.0			! default relaxation parameter
	!character(len=50) :: filename2 = 'hw4data/jacobi_11_res.txt'
	!character(len=50) :: filename2 = 'hw4data/jacobi_21_res.txt'
	!integer, parameter :: iteropt = 2			! GS/SOR = 2
	!real(8), parameter :: omega = 1.0			! relaxation parameter for GS
	!character(len=50) :: filename2 = 'hw4data/gs_11_res.txt'
	!character(len=50) :: filename2 = 'hw4data/gs_21_res.txt'
	!integer, parameter :: iteropt = 2			! GS/SOR = 2
	!real(8), parameter :: omega = 1.8			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_11_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_21_res.txt'

	!real(8), parameter :: Lx = 2.0				! 0 < x < Lx
	!real(8), parameter :: Ly = 1.0				! 0 < y < Ly
	!real(8), parameter :: tol = 1E-6			! absolute residual tolerance

	! Poisson **********************	
	!integer, parameter :: pblm = 3				! uniform grid 50x50
	!integer, parameter :: nx = 50				! nx cells => nx+1 nodes
	!integer, parameter :: ny = 50				! ny cells => ny+1 nodes
	!character(len=50) :: filename = 'hw4data/ss_poisson_50.txt'
	integer, parameter :: pblm = 17			! g.dat curvilinear grid
	integer, parameter :: nx = 96				! nx cells => nx+1 nodes
	integer, parameter :: ny = 56				! ny cells => ny+1 nodes
	character(len=50) :: filename = 'hw4data/ss_poisson_g.txt'
	
	!integer, parameter :: iteropt = 1			! Jacobi = 1
	!real(8), parameter :: omega = 1.0			! default relaxation parameter
	!character(len=50) :: filename2 = 'hw4data/jacobi_50_res.txt'
	!character(len=50) :: filename2 = 'hw4data/jacobi_g_res.txt'
	!integer, parameter :: iteropt = 2			! GS/SOR = 2
	!real(8), parameter :: omega = 1.0			! relaxation parameter for GS
	!character(len=50) :: filename2 = 'hw4data/gs_50_res.txt'
	!character(len=50) :: filename2 = 'hw4data/gs_g_res.txt'
	integer, parameter :: iteropt = 2			! GS/SOR = 2
	!real(8), parameter :: omega = 0.25			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_025_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_025_res.txt'
	!real(8), parameter :: omega = 0.5			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_050_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_050_res.txt'
	!real(8), parameter :: omega = 0.75			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_075_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_075_res.txt'
	!real(8), parameter :: omega = 1.25			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_125_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_125_res.txt'
	!real(8), parameter :: omega = 1.5			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_150_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_150_res.txt'
	!real(8), parameter :: omega = 1.75			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_175_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_175_res.txt'
	!real(8), parameter :: omega = 2			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_200_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_200_res.txt'
	!real(8), parameter :: omega = 2.25			! relaxation parameter for SOR (NA)
	!real(8), parameter :: omega = 1.9			! relaxation parameter for SOR (optimal)
	!character(len=50) :: filename2 = 'hw4data/sor_50_190_res.txt'
	!character(len=50) :: filename2 = 'hw4data/sor_g_190_res.txt'
	real(8), parameter :: omega = 1.8			! relaxation parameter for SOR
	!character(len=50) :: filename2 = 'hw4data/sor_50_180_res.txt'
	character(len=50) :: filename2 = 'hw4data/sor_g_180_res.txt'
	
	real(8), parameter :: Lx = 1.0				! 0 < x < Lx
	real(8), parameter :: Ly = 1.0				! 0 < y < Ly
	real(8), parameter :: tol = 1E-4			! relative residual tolerance

	! global variables ========================

	! using 1 pair of ghost cells
	real(8), dimension(1:nx+1,1:ny+1) :: xn		! grid node x-coordinates
	real(8), dimension(1:nx+1,1:ny+1) :: yn		! grid node y-coordinates

	real(8), dimension(0:nx+1,0:ny+1) :: xc		! cell center x-coordinates
	real(8), dimension(0:nx+1,0:ny+1) :: yc		! cell center y-coordinates

	real(8), dimension(1:nx+1,1:ny) :: xf_i		! face center i dir x-coordinates
	real(8), dimension(1:nx+1,1:ny) :: yf_i		! face center i dir y-coordinates
	real(8), dimension(1:nx,1:ny+1) :: xf_j		! face center j dir x-coordinates
	real(8), dimension(1:nx,1:ny+1) :: yf_j		! face center j dir y-coordinates
	
	real(8), dimension(1:nx+1,1:ny) :: area_i	! face area i dir 
	real(8), dimension(1:nx,1:ny+1) :: area_j	! face area j dir 

	real(8), dimension(2,1:nx+1,1:ny) :: nhat_i	! face normal i dir
	real(8), dimension(2,1:nx,1:ny+1) :: nhat_j	! face normal j dir

	real(8), dimension(1:nx,1:ny) :: vol		! cell volume

	real(8), dimension(1:nx+1,1:ny) :: dinv_i	! cell distance inverse across i face
	real(8), dimension(1:nx,1:ny+1) :: dinv_j	! cell distance inverse across j face

	real(8), dimension(2,2,1:nx,1:ny) :: Linv	! gradient least sq inverse matrix

	real(8), dimension(0:nx+1,0:ny+1) :: u		! sln(k) (current) cell centered
	real(8), dimension(0:nx+1,0:ny+1) :: un		! sln(k+1) (next) cell centered

	integer :: i,j,k							! reserve i,j,k for indexing
	real(8) :: res = 0.0						! residual for convergence
	real(8) :: x0 = 0.0							! centroid of entire grid x coord
	real(8) :: y0 = 0.0							! centroid of entire grid y coord

contains

!==============================================================================
! generate or read in the grid/mesh
!==============================================================================
subroutine grid_setup

	real(8) :: dx,dy			! delta x,y for uniform grids
	
	! uniform grid
	if (pblm.eq.1.or.pblm.eq.2.or.pblm.eq.3) then
		dx = Lx/nx
		dy = Ly/ny
		write(*,*) dx,dy

		! fill grid values at nodes
		! for FV, cell centers are at 1/2 indices (cell faces are at nodes)
		do j = 1,ny+1
		do i = 1,nx+1
			xn(i,j) = (i-1)*dx
			yn(i,j) = (j-1)*dy
		end do
		end do
	! g.dat
	else if (pblm.eq.17) then
		! nx,ny,Lx,Ly still hard coded by manually checking file
		open(11,file='grids/g.dat',status='old')
		read(11,*)
		do j=1,ny+1
		do i=1,nx+1
			read(11,*) xn(i,j),yn(i,j)
		enddo
		enddo
		close(11)
	end if

end subroutine grid_setup


!==============================================================================
! calculate grid metrics
!==============================================================================
subroutine grid_metrics

	! ======================================	
	! cell based metrics
	! ======================================	
	
	! calculate centroid of mesh for Poisson problem
	x0 = 0.0
	y0 = 0.0

	! cell center, volume
	do j = 1,ny
	do i = 1,nx
		xc(i,j) = 0.25*(xn(i,j)+xn(i+1,j)+xn(i+1,j+1)+xn(i,j+1))
		yc(i,j) = 0.25*(yn(i,j)+yn(i+1,j)+yn(i+1,j+1)+yn(i,j+1))

		vol(i,j) = 0.5*abs((xn(i+1,j+1)-xn(i,j))*(yn(i,j+1)-yn(i+1,j)) &
			-(xn(i,j+1)-xn(i+1,j))*(yn(i+1,j+1)-yn(i,j)))
		!write(*,*) i,j,vol(i,j)

		x0 = x0 + xc(i,j)
		y0 = y0 + yc(i,j)
	end do
	end do

	! finish centroid calculation
	x0 = x0/(nx*ny)
	y0 = y0/(nx*ny)
	write(*,*) x0, y0

	! linear extrapolation calculation for ghost cells
	do i = 1,nx
		xc(i,0) = xc(i,1) - (xc(i,2)-xc(i,1))
		yc(i,0) = yc(i,1) - (yc(i,2)-yc(i,1))

		xc(i,ny+1) = xc(i,ny) + (xc(i,ny)-xc(i,ny-1))
		yc(i,ny+1) = yc(i,ny) + (yc(i,ny)-yc(i,ny-1))
	end do

	do j = 0,ny+1
		xc(0,j) = xc(1,j) - (xc(2,j)-xc(1,j))
		yc(0,j) = yc(1,j) - (yc(2,j)-yc(1,j))

		xc(nx+1,j) = xc(nx,j) + (xc(nx,j)-xc(nx-1,j))
		yc(nx+1,j) = yc(nx,j) + (yc(nx,j)-yc(nx-1,j))
	end do

	! ======================================	
	! face based metrics (see quadrilateral cell map in FV2D-geometry-exsercise.pdf)
	! values are computed for 2 faces extending from (i,j) node (bottom left corner)
	! area_i(i,j) = S(i-1/2,j); area_j(i,j) = S(i,j-1/2)
	! nhat ...
	! dinv_i(i,j) = inv dist xc(i-1,j) to xc(i,j)
	! dinv_j(i,j) = inv dist xc(i,j-1) to xc(i,j)
	! ======================================	
	! i faces
	do j = 1,ny
	do i = 1,nx+1
		xf_i(i,j) = 0.5*(xn(i,j)+xn(i,j+1))
		yf_i(i,j) = 0.5*(yn(i,j)+yn(i,j+1))

		area_i(i,j) = sqrt((yn(i,j+1)-yn(i,j))**2 + (xn(i,j+1)-xn(i,j))**2)

		nhat_i(1,i,j) = (yn(i,j+1)-yn(i,j)) / area_i(i,j)
		nhat_i(2,i,j) = -(xn(i,j+1)-xn(i,j)) / area_i(i,j)

		dinv_i(i,j) = 1/sqrt((xc(i,j)-xc(i-1,j))**2 + (yc(i,j)-yc(i-1,j))**2)
	end do
	end do

	! j faces
	do j = 1,ny+1
	do i = 1,nx
		xf_j(i,j) = 0.5*(xn(i,j)+xn(i+1,j))
		yf_j(i,j) = 0.5*(yn(i,j)+yn(i+1,j))

		area_j(i,j) = sqrt((yn(i+1,j)-yn(i,j))**2 + (xn(i+1,j)-xn(i,j))**2)

		nhat_j(1,i,j) = (yn(i,j)-yn(i+1,j)) / area_j(i,j)
		nhat_j(2,i,j) = -(xn(i,j)-xn(i+1,j)) / area_j(i,j)

		dinv_j(i,j) = 1/sqrt((xc(i,j)-xc(i,j-1))**2 + (yc(i,j)-yc(i,j-1))**2)
	end do
	end do

end subroutine grid_metrics

!====================
end module grid_data
!====================

!==============================================================================
! module for procedures
!==============================================================================
module procedures
implicit none
contains

!==============================================================================
! subroutine for initializing solution (cell centered)
!==============================================================================
subroutine sln_setup
use grid_data

	do j=1,ny
	do i=1,nx
		u(i,j) = 0.0
	end do
	end do

end subroutine sln_setup

!==============================================================================
! apply boundary conditions and fill ghost cells
!==============================================================================
subroutine apply_boundary
use grid_data

	! Laplace
	if (pblm.eq.2) then
		! don't need to worry about corners, never used
		do i=1,nx
			! insulated upper and lower boundaries
			! homogeneous Neumann BCs => du/dy = 0
			! this means ghost cell is just same value as cell above/below
			u(i,ny+1) = u(i,ny)  	! upper
			u(i,0) = u(i,1)			! lower
		end do
		do j=1,ny
			! set values of temperature at left and right side
			! Dirichlet BCs - 1 homogeneous and 1 nonhomogeneous
			u(0,j) = 0.0			! left
			u(nx+1,j) = yc(nx+1,j)  ! right (cell centered sln => yc not yn)
		end do	   
	! Poisson
	else 
		do i=1,nx
			! homogeneous Dirichlet BCs => u=0 at j=0,ny+1 boundaries
			u(i,ny+1) = 0.0
			u(i,0) = 0.0
		end do
		do j=1,ny
			! homogeneous Neumann BCs => du/dx = 0 at i=0,nx+1 boundaries
			! ghost cell is just same value as cell on right(1) or left(nx)
			u(0,j) = u(1,j)
			u(nx+1,j) = u(nx,j)
		end do	   
	end if

end subroutine apply_boundary

!==============================================================================
! Jacobi (1) / SOR (2) / Gauss-Seidel (2) iteration method
! set omega=1 in constants at top for GS
!==============================================================================
subroutine ss_iter
use grid_data

	real(8) :: sigma,a1,a2,a3,a4,uold,ucur,f,resinit

	! save residual & num iter
	open(2, file = filename2, status='replace')

	! iterate solution
	do k=1,niter
		res = 0.0

		! apply boundary conditions to current solution u
		call apply_boundary

		do j=1,ny
		do i=1,nx
			! terms from rearrangement of discretization
			a1 = area_i(i,j) * dinv_i(i,j)
			a2 = area_i(i+1,j) * dinv_i(i+1,j)
			a3 = area_j(i,j) * dinv_j(i,j)
			a4 = area_j(i,j+1) * dinv_j(i,j+1)
			sigma = a1+a2+a3+a4

			! save current sln value into old/prev
			uold = u(i,j)

			! Laplace has no source term
			if (pblm.eq.2) then
				f = 0.0
			! Poisson has source term
			else
				f = exp(-35*((xc(i,j)-x0)**2+(yc(i,j)-y0)**2))
				!write(*,*) f
			end if

			! discretization rearrangement
			! (au's) - sigma*u = f*vol => u = (au's - f*vol)/sigma
			! integrate over volume, divergence eqn transforms LHS to area
			! RHS (source term f(x,y,t)) still integrated over volume
			ucur = (a1*u(i-1,j)+a2*u(i+1,j)+a3*u(i,j-1)+a4*u(i,j+1)-f*vol(i,j))/sigma

			! Jacobi
			if (iteropt.eq.1) then
				un(i,j) = ucur
			! SOR/GS
			else if (iteropt.eq.2) then
				! perform relaxation and update current solution as we go along
				! SOR/GS uses recently updated values from i-1,j-1
				ucur = (1-omega)*uold + omega*ucur
				u(i,j) = ucur
			end if

			! residual calculation for convergence
			res = res + (ucur-uold)**2
		end do
		end do

		! Jacobi copy new solution to current solution
		if (iteropt.eq.1) then
			do j=1,ny
			do i=1,nx
				u(i,j) = un(i,j)
			end do
			end do
		end if

		! Laplace absolute residual 
		if (pblm.eq.2) then
			res = sqrt(res/(nx*ny))
		! Poisson relative residual 
		else
			if (k.eq.1) then
				resinit = sqrt(res)
				write(*,*) resinit
			else
				!write(*,*) sqrt(res)
				res = sqrt(res)/resinit
			end if
		end if

		! don't write resinit for Poisson (ok not to write k=1 for Laplace too)
		if (k.ne.1) then		
			write(*,*) k,res
			write(2,"(I8,E20.8)") k,res
		end if

		! break if convergence tolerance achieved
		if (res.le.tol.and.k.ne.1) then
			close(2)
			exit
		end if
	end do

end subroutine ss_iter

!==============================================================================
! print solution (values at cell centers) to file with grid (cell center coords)
!==============================================================================
subroutine print_sln_to_file
use grid_data

	open(1, file = filename, status='replace')
	do j = 1,ny
	do i = 1,nx
		write(1,"(2I5,3E20.8)") i,j,xc(i,j),yc(i,j),u(i,j)
	end do
	end do
	close(1)

end subroutine print_sln_to_file

!==============================================================================
! print out solution in a matrix form like viewing x-y axis
! ** only do for small nx,ny like 10x10
!==============================================================================
subroutine print_sln
use grid_data

	!do j = ny+1,0,-1
	! print the top right corner
	do j = ny+1,ny-5,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		!do i = 0,nx+1
		do i = nx-5,nx+1
			!write(*,"(A1,F6.4,A2)",advance="no") '(',u(i,j),') '
			write(*,"(A1,F10.4,A2)",advance="no") '(',u(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

end subroutine print_sln

!==============================================================================
! print out a grid metric or solution in a matrix form like viewing x-y axis
! ** only do for small nx,ny like 10x10
!==============================================================================
subroutine print_grid
use grid_data

	!do j = ny+1,0,-1
	! print the top right corner
	do j = ny+1,ny-5,-1
		write(*,"(I5,A1)",advance="no") j,' '  ! advance=no will not write newline

		!do i = 0,nx+1
		do i = nx-5,nx+1
			write(*,"(A1,F4.2,A1,F4.2,A2)",advance="no") '(',xc(i,j),',',yc(i,j),') '
			!write(*,"(E15.8,A1)",advance="no") grid(i,j),' '
		end do

		write(*,*)  ! write out the new line
	end do

end subroutine print_grid

!==============================================================================
! print out a grid metric like i,j,grid_x(i,j),grid_y(i,j)
!==============================================================================
subroutine print_grid2
use grid_data

	! cells.dat matching
	! File contains i,j,xc(i,j),yc(i,j),vol(i,j),Linv(1,1),Linv(1,2),Linv(2,1),Linv(2,2)
	! for -interior- cells (for grid 'g.dat': (nx,ny)=(96,56))
	do j=1,2
	do i=1,nx
		write(*,*) i,j,xc(i,j),yc(i,j)
	end do
	end do

	! I-faces.dat matching
	! File contains i,j,xf_i(i,j),yf_i(i,j),area_i(i,j),nhat_i(1,i,j),nhat_i(1:2,i,j),
	! dinv_i(i,j) for I-faces (for grid 'g.dat': (nx,ny)=(96,56))
	do j=1,2
	do i=1,nx+1
		write(*,*) i,j,xf_i(i,j),yf_i(i,j),area_i(i,j),nhat_i(1,i,j),nhat_i(2,i,j) &
			,dinv_i(i,j)
	end do
	end do

	! J-faces.dat matching
	! File contains i,j,xf_j(i,j),yf_j(i,j),area_j(i,j),nhat_j(1,i,j),nhat_j(1:2,i,j),
	! dinv_j(i,j) for J-faces (for grid 'g.dat': (nx,ny)=(96,56))
	do j=1,2
	do i=1,nx
		write(*,*) i,j,xf_j(i,j),yf_j(i,j),area_j(i,j),nhat_j(1,i,j),nhat_j(2,i,j) &
			,dinv_j(i,j)
	end do
	end do

end subroutine print_grid2

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
	call grid_metrics

	call sln_setup

	call ss_iter
	
	call print_grid
	call print_sln
	call print_sln_to_file

end program cfd

