! Andrew Navratil
! MAE 766 CFD - Project 2: DG for 2D compressible Euler 

!******************************************************************************
! module for reading/setting constants, inputs, grid data and metrics
!******************************************************************************
module grid_data
implicit none

	! constants	===============================
	integer, parameter :: ndim = 2			! num spatial dimensions (2 = x,y)
	integer, parameter :: nnodes = 3		! num nodes per element (3 = triangles)
	integer, parameter :: nbdrynds = 2		! num nodes per bdry face (2 for triangles)
	integer, parameter :: nbdrydata = 3		! num data columnes (BCs,zone)
	integer, parameter :: nfq = 3			! num flow quantities to calculate

	real(8),parameter,dimension(ndim) :: uinf = [1.0,0.0] ! freestream velocity (given)
	real(8),parameter :: cylrad = 0.5		! cylinder radius (from node 1 for all)
	
	!character(len=50), parameter :: gridfile = 'grids/feflo.domn.bump'
	!character(len=50), parameter :: tecfile = 'data/bump.plt'
	!integer, parameter :: hskip = 9			! num header lines to skip
	!integer, parameter :: nelem = 1559		! num elements
	!integer, parameter :: npts = 839		! num nodes/points
	!integer, parameter :: nbdry = 117		! num boundary faces

	!character(len=50), parameter :: gridfile = 'grids/feflo.domn.cylinder.coarse'
	!character(len=50), parameter :: tecfile = 'data/cylinder_coarse.plt'
	!integer, parameter :: hskip = 7			! num header lines to skip
	!integer, parameter :: nelem = 128		! num elements
	!integer, parameter :: npts = 80			! num nodes/points
	!integer, parameter :: nbdry = 32		! num boundary faces
	
	!character(len=50), parameter :: gridfile = 'grids/feflo.domn.cylinder.medium'
	!character(len=50), parameter :: tecfile = 'data/cylinder_medium.plt'
	!integer, parameter :: hskip = 7			! num header lines to skip
	!integer, parameter :: nelem = 512		! num elements
	!integer, parameter :: npts = 288		! num nodes/points
	!integer, parameter :: nbdry = 64		! num boundary faces
	
	!character(len=50), parameter :: gridfile = 'grids/feflo.domn.cylinder.fine'
	!character(len=50), parameter :: tecfile = 'data/cylinder_fine.plt'
	!integer, parameter :: hskip = 7			! num header lines to skip
	!integer, parameter :: nelem = 2048		! num elements
	!integer, parameter :: npts = 1088		! num nodes/points
	!integer, parameter :: nbdry = 128		! num boundary faces
	
	character(len=50), parameter :: gridfile = 'grids/feflo.domn.cylinder.vfine'
	character(len=50), parameter :: tecfile = 'data/cylinder_vfine.plt'
	integer, parameter :: hskip = 7			! num header lines to skip
	integer, parameter :: nelem = 8192		! num elements
	integer, parameter :: npts = 4224		! num nodes/points
	integer, parameter :: nbdry = 256		! num boundary faces

	! global variables ========================
	real(8), dimension(ndim,npts) :: nodes				! node coordinates
	integer, dimension(nnodes,nelem) :: elemnodes		! connectivity matrix
	integer, dimension(nbdrynds+nbdrydata,nbdry) :: bdrynodes 	! bdry face nodes

	real(8), dimension(nnodes,ndim,nelem) :: dBdx	! basis func spatial 1st derivs
	real(8), dimension(nelem) :: vol				! element volume (area in 2D)
	
	real(8), dimension(ndim+1,nbdry) :: bdrynhat	! bdry face unit normals + area
	
	real(8), dimension(npts) :: phi,phisln			! velocity potential (A*phi=R)
	real(8), dimension(nfq,npts) :: flowq,flowqsln	! flow quantities (velocity ux,uy)

	real(8), dimension(npts,npts) :: lhsvpe	! LHS for vpe / A / global stiffness matrix
	real(8), dimension(npts) :: rhsvpe		! RHS for vpe / R / load vector

	integer :: i,j,k					! reserve i,j,k for indexing

contains

!=========================================
! read in grid/mesh
!=========================================
subroutine grid_setup

	! open grid file and process
	! still need to make this dynamic for ndim,nelem
	open(11,file=gridfile,status='old')
	do i=1,hskip
		read(11,*)
	enddo
	! note: assumes elems/nodes/faces in order, skip num using k
	! read element nodes
	do i=1,nelem
		read(11,*) k,elemnodes(1:nnodes,i)
	end do
	! read node coordinates
	read(11,*)
	do i=1,npts
		read(11,*) k,nodes(1:ndim,i)
	end do
	! given solution value section
	read(11,*)
	do i=1,npts
		read(11,*) k,phisln(i),flowqsln(1:nfq,i)
	end do
	! read boundary face nodes
	read(11,*)
	do i=1,nbdry
		read(11,*) k,bdrynodes(1:nbdrynds+nbdrydata,i)
	end do
	close(11)

end subroutine grid_setup

!=========================================
! calculate grid metrics
!=========================================
subroutine grid_metrics

	real(8) :: ecoord(nnodes,ndim)  ! elem coord(local node num, x or y)
	real(8) :: bcoord(nbdrynds,ndim)! bdry coord(local node num, x or y)
	real(8) :: D					! Jacobian (2 x area)
	real(8) :: dx,dy,fa				! bdry face delta-x, delta-y, area

	! linear Lagrange basis functions for triangles
	! using Barycentric coordinates and Bi = lambdai
	do i = 1,nelem
		! get spatial coordinates for each node of element
		! ex: x1 = coord(1,1), y3 = coord(2,3)
		do j = 1,nnodes
			do k = 1,ndim
				ecoord(j,k) = nodes(k,elemnodes(j,i))
			end do
		end do

		! elemental basis function derivatives
		! using Barycentric coordinates & linear Lagrange => b_i = lambda_i
		! D is Jacobian = 2 x triangle area
		D = (ecoord(3,2)-ecoord(1,2))*(ecoord(2,1)-ecoord(1,1))
		D = D - ((ecoord(1,2)-ecoord(2,2))*(ecoord(1,1)-ecoord(3,1)))
		dbdx(1,1,i) = (ecoord(2,2)-ecoord(3,2))/D  ! a1/D = (y2-y3)/D = dlam1/dx
		dbdx(2,1,i) = (ecoord(3,2)-ecoord(1,2))/D  ! a2/D = (y3-y1)/D = dlam2/dx
		dbdx(3,1,i) = (ecoord(1,2)-ecoord(2,2))/D  ! a3/D = (y1-y2)/D = dlam3/dx
		dbdx(1,2,i) = (ecoord(3,1)-ecoord(2,1))/D  ! b1/D = (x3-x2)/D = dlam1/dy
		dbdx(2,2,i) = (ecoord(1,1)-ecoord(3,1))/D  ! b2/D = (x1-x3)/D = dlam2/dy
		dbdx(3,2,i) = (ecoord(2,1)-ecoord(1,1))/D  ! b3/D = (x2-x1)/D = dlam3/dy
		vol(i) = D/2
	end do

	! loop boundary faces and store geometry data
	do i = 1,nbdry
		! get spatial coordinates for each node of bdry face
		do j = 1,nbdrynds
			do k = 1,ndim
				bcoord(j,k) = nodes(k,bdrynodes(j,i))
			end do
		end do

		! unit normals (outward facing) + area (len)
		dx = bcoord(2,1)-bcoord(1,1)
		dy = bcoord(2,2)-bcoord(1,2)
		fa = sqrt(dx*dx + dy*dy)
		bdrynhat(1,i) = dy/fa	! nx
		bdrynhat(2,i) = -dx/fa	! ny
		bdrynhat(3,i) = fa		! area (len)
	end do

end subroutine grid_metrics

!====================
end module grid_data
!====================

!******************************************************************************
! module for procedures
!******************************************************************************
module procedures
implicit none
contains

!=========================================
! assemble global stiffness matrix / LHS for vpe
!=========================================
subroutine build_lhs
use grid_data

	integer :: en(nnodes)		! local element nodes
	real(8) :: a				! local elemental stiffmatrix entry

	! initialize matrix
	lhsvpe = 0.0

	! build global stiffness matrix A (LHS) element by element
	! integration of dBi*dBj over element results in elemental stiffness matrix
	! entries for local nodes, a(i,j)^(e), which are then mapped to corresponding
	! global node and added to global stiffness matrix A(I,J)
	do k = 1,nelem
		! get the global node numbers for current element
		do j = 1,nnodes
			en(j) = elemnodes(j,k)
		end do

		! loop all combos of i,j
		do j = 1,nnodes
			do i = 1,nnodes
				! calculate elemental stiffness matrix entry
				! a(i,j) = ((dlami/dx)(dlamj/dx) + (dlami/dy)(dlamj/dy))*area
				a = (dbdx(i,1,k)*dbdx(j,1,k) + dbdx(i,2,k)*dbdx(j,2,k))*vol(k)

				! add to sum for corresponding node at global level
				lhsvpe(en(i),en(j)) = lhsvpe(en(i),en(j)) + a
			end do
		end do
	end do

end subroutine build_lhs

!=========================================
! assemble global load vector / RHS for vpe
!=========================================
subroutine build_rhs
use grid_data

	real(8) :: vn,fa,r	! normal velocity, face area, local load vector entry

	! initialize matrix
	rhsvpe = 0.0

	! build global load vector R (RHS)
	! this requires integrating g=Vn (velocity normal) over the boundary
	! and applying the boundary conditions
	! BC 2 => solid wall (Vn=0) (already set to 0)
	! BC 4 => freestream (uinf provided)
	do i = 1,nbdry
		if (bdrynodes(3,i).eq.4) then
			vn = uinf(1)*bdrynhat(1,i) + uinf(2)*bdrynhat(2,i)
			fa = bdrynhat(3,i)
			r = vn*fa*0.5

			rhsvpe(bdrynodes(1,i)) = rhsvpe(bdrynodes(1,i)) + r
			rhsvpe(bdrynodes(2,i)) = rhsvpe(bdrynodes(2,i)) + r
		end if
	end do

end subroutine build_rhs

!=========================================
! calculate flow quantities: velocity, pressure
! 	also fill surface velocity data
!=========================================
subroutine calc_flowq
use grid_data

	real(8) :: u,v		! local elemental velocity Vx,Vy
	real(8) :: vmag,vmagfree  ! velocity magnitude, freestream vel mag
	real(8) :: w(npts)	! sum of weights for each connecting element
	real(8) :: x,y		! coordinate values for a node
	real(8) :: h		! grid spacing (mean vol)
	real(8) :: errtotal					! error value (L2 norm across all nodes)
	real(8) :: totalvol,gridspacing		! total volume, grid spacing (mean vol)
	real(8) :: ua,va,vmaga	! analytic solutions

	! initialize
	flowq = 0.0
	w = 0.0

	! compute velocity at nodes with a weighted sum over connected elements
	do k = 1,nelem
		! reset local velocity vars
		u = 0.0
		v = 0.0

		! loop element nods and build elemental velocity (const for linear basis)
		do j = 1,nnodes
			! get the global node number for current node
			i = elemnodes(j,k)

			! calculate contribution to element velocity from this node
			u = u + phi(i)*dbdx(j,1,k)
			v = v + phi(i)*dbdx(j,2,k)
		end do

		! add to current weighted velocity sum for each node of this element
		do j = 1,nnodes
			i = elemnodes(j,k)

			flowq(1,i) = flowq(1,i) + u*vol(k)
			flowq(2,i) = flowq(2,i) + v*vol(k)

			! add weight to total for this node
			w(i) = w(i) + vol(k)
		end do

		! add element volume to total h for grid spacing calculation later
		gridspacing = gridspacing + vol(k)
	end do

	! complete the calculation by dividing by the sum of the weights
	! calculate pressure coefficient
	! calculate error and avg element size for grid convergence study
	errtotal = 0.0						! aggregate of errors to analytical
	totalvol = sum(vol)					! total volume
	gridspacing = totalvol/nelem		! get mean vol as grid spacing metric
	do i = 1,npts
		flowq(1,i) = flowq(1,i)/w(i)
		flowq(2,i) = flowq(2,i)/w(i)

		! reusing u and v for node velocity and freestrem vel magnitudes
		vmag = sqrt(flowq(1,i)**2 + flowq(2,i)**2)
		vmagfree = sqrt(uinf(1)**2 + uinf(2)**2)

		! calculate Cp
		flowq(3,i) = 1 - (vmag/vmagfree)**2

		! calculate error to analytical (see Hirsch p559)
		x = nodes(1,i)
		y = nodes(2,i)

		! error calc using phi	
		!anasln = uinf(1)*x*(x*x+y*y+cylrad*cylrad)/(x*x+y*y)
		!errtotal = errtotal + ((phi(i)-anasln)**2 * w(i))
	
		! error calc using vel mag
		ua = uinf(1)*(1-(cylrad**2 * (x*x-y*y))/((x*x+y*y)**2))
		va = -2*uinf(1)*cylrad**2*x*y/(x*x+y*y)**2
		vmaga = sqrt(ua*ua+va*va)
		errtotal = errtotal + ((vmag-vmaga)**2 * w(i))  ! weighted
		!errtotal = errtotal + ((vmag-vmaga)**2)		! unweighted
	end do

	errtotal = sqrt(errtotal)	! finish L2 norm calc for error

	! output to console
	write(*,"(A15,F8.5)") 'errtotal = ',errtotal
	write(*,"(A15,F8.5)") 'gridspacing = ',gridspacing
	write(*,"(A15,F8.5)") 'log(E) = ',log(errtotal)
	write(*,"(A15,F8.5)") 'log(h) = ',log(gridspacing)

end subroutine calc_flowq

!=========================================
! print to txt
!=========================================
subroutine print_txt
use grid_data

	open(17, file = 'data/tmp.txt', status='replace')

	do i = 1,npts
		do j = 1,npts
			write(17,"(E20.8)",advance="no") lhsvpe(i,j)
		end do
		write(17,"(E20.8)") rhsvpe(i)
	end do

	close(17)
		
end subroutine print_txt

!=========================================
! print solution to tecplot
!=========================================
subroutine print_sln_tecplot
use grid_data

	open(17, file = tecfile, status='replace')
	write(17,*) 'TITLE=FEM DATA'
	write(17,*) 'VARIABLES=X,Y,PHI,U,V'
	write(17,"(A11,I5,A10,I5)",advance="no") 'ZONE NODES=',npts,',ELEMENTS=',nelem
	write(17,*) ',DATAPACKING=POINT,ZONETYPE=FETRIANGLE'
	do i=1,npts
		write(17,"(5E20.8)") &
			nodes(1,i),nodes(2,i),phi(i),flowq(1,i),flowq(2,i)
			!nodes(1,i),nodes(2,i),phisln(i),flowqsln(1,i),flowqsln(2,i)
	end do
	do i=1,nelem
		write(17,"(3I5)") elemnodes(1,i),elemnodes(2,i),elemnodes(3,i)
	end do
	close(17)

end subroutine print_sln_tecplot

!=========================================
! print surface velocity values to tecplot: bump bottom
!=========================================
subroutine print_surfvel_btm_tec
use grid_data

	real(8) :: x,vmag	! x-coord,velocity magnitude

	open(17, file = 'data/bump_surfvel_btm.plt', status='replace')
	write(17,*) 'TITLE=SURFACE VELOCITY BOTTOM'
	write(17,*) 'VARIABLES=x,vmag'

	! just need first node from bdry face as faces shared nodes to get all
	! zones: 1=btm left,2=bump,3=btm right,4=right,5=top,6=left
	! k=80 to get last node on bottom, and k=109 to get last node on top
	! or just hard code the first and last for bottom
	do k = 1,nbdry
		!zone = bdrynodes(5,k)
		!if (zone.eq.1 .or. zone.eq.2 .or. zone.eq.3 .or. zone.eq.5 &
			!.or. k.eq.80 .or. k.eq.109) then
		if (k.ge.1 .and. k.le.81) then
			i = bdrynodes(1,k)  ! global node num for first bdry face node
			x = nodes(1,i)		! x-coord of node

			vmag = sqrt(flowq(1,i)**2 + flowq(2,i)**2)

			write(17,"(2E20.8)") x,vmag
		end if
	end do

	close(17)

end subroutine print_surfvel_btm_tec

!=========================================
! print surface velocity values to tecplot: bump top
!=========================================
subroutine print_surfvel_top_tec
use grid_data

	real(8) :: x,vmag	! x-coord,velocity magnitude

	open(17, file = 'data/bump_surfvel_top.plt', status='replace')
	write(17,*) 'TITLE=SURFACE VELOCITY TOP'
	write(17,*) 'VARIABLES=x,vmag'

	do k = 1,nbdry
		if (k.ge.89 .and. k.le.109) then
			i = bdrynodes(1,k)  ! global node num for first bdry face node
			x = nodes(1,i)		! x-coord of node

			vmag = sqrt(flowq(1,i)**2 + flowq(2,i)**2)

			write(17,"(2E20.8)") x,vmag
		end if
	end do

	close(17)

end subroutine print_surfvel_top_tec

!=========================================
! print surface velocity values to tecplot: cylinder
!=========================================
subroutine print_surfvel_cyl_tec
use grid_data

	real(8) :: x,y,theta,vmag	! x,y,deg coord,velocity magnitude
	!real(8),dimension(2,nbdry) :: surfvel ! hold vel for odering to get plot curve right

	open(17, file = 'data/bump_surfvel_cyl.plt', status='replace')
	write(17,*) 'TITLE=SURFACE VELOCITY CYLINDER'
	write(17,*) 'VARIABLES=theta,vmag'

	!surfvel = 0.0

	do k = 1,nbdry
		if (bdrynodes(4,k).eq.0) then
			i = bdrynodes(2,k)  ! global node num for second bdry face node
								! so we get correct line connection on plot
			x = nodes(1,i)		! x-coord of node
			y = nodes(2,i)		! y-coord of node

			theta = atand(y/x)	! theta 
			if (theta.lt.0.0) then
			end if

			! 2nd/3rd quadrants
			if (x.lt.0.0) then
				theta = theta + 180
			! 4th quadrant
			else if (x.ge.0.0 .and. y.lt.0.0) then
				theta = theta + 360
			end if

			vmag = sqrt(flowq(1,i)**2 + flowq(2,i)**2)

			write(17,"(2E20.8)") theta,vmag
		end if
	end do

	close(17)

end subroutine print_surfvel_cyl_tec

!==============================================================================
! print out [lhs,rhs] in a matrix form like viewing x-y axis
!==============================================================================
subroutine print_ab
use grid_data

	real(8), dimension(npts,npts+1) :: ab ! combine lhs and rhs into single matrix
	integer :: nump = 5	! number of rows and cols to print in each corner
	ab(:,1:npts) = lhsvpe
	ab(:,npts+1) = rhsvpe

	! print the top left and right corners
	do i = 1,nump
		write(*,"(I5,A1)",advance="no") i,' '

		do j = 1,nump
			write(*,"(A1,F8.5,A2)",advance="no") '(',ab(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do j = npts+1-nump,npts+1
			write(*,"(A1,F8.5,A2)",advance="no") '(',ab(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

	! print the bottom left and right corners
	do i = npts-nump,npts
		write(*,"(I5,A1)",advance="no") i,' '

		do j = 1,nump
			write(*,"(A1,F8.5,A2)",advance="no") '(',ab(i,j),') '
		end do
		write(*,"(A3)",advance="no") '...'
		do j = npts+1-nump,npts+1
			write(*,"(A1,F8.5,A2)",advance="no") '(',ab(i,j),') '
		end do

		write(*,*)  ! write out the new line
	end do

	write(*,*)

end subroutine print_ab


!====================
end module procedures
!====================

!******************************************************************************
! main cfd solver program
!******************************************************************************
program cfd
use grid_data
use procedures
use util
implicit none

	! pre-processing: control file, grid setup (no control file yet)
	call grid_setup
	call grid_metrics

	! call FEM solver
	call build_lhs
	call build_rhs

	! debug: print lhs and rhs to txt for matlab analysis
	! LHS should be SPD matrix (sparse, symmetric, positivte definite)
	!call print_txt

	! debug: print [lhs,rhs] to console (corners of matrix)
	!call print_ab

	! solve linear system - congjugate gradient (no pre-conditioning)
	! calls method from module in another file (util.f90)
	!call sol_gauss(npts,lhsvpe,rhsvpe,phi)
	call sol_cg(npts,lhsvpe,rhsvpe,phi)

	! post-processing
	call calc_flowq
	!call print_sln_tecplot

	! bump surface velocities
	!call print_surfvel_btm_tec
	!call print_surfvel_top_tec

	! cylinder surface velocities
	call print_surfvel_cyl_tec

end program cfd

