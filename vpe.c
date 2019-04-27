/* Andrew Navratil */
/* MAE 456 CFD */
/* Final Project: VPE (2D steady compressible adiabatic irrotational (=> isentropic)) sln */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <ctype.h>

/*****************************************************************************/
/* constants */
/*****************************************************************************/
/*static	const char	*fname = "grid-poisson-2015.txt";  [> physical mesh file name <]*/
/*static	const int	imx = 81; [> max i value / num columns <]*/
/*static	const int	jmx = 81; [> max j value / num rows <]*/

/*static	const char	*fname = "grid-bumps.txt";  [> physical mesh file name <]*/
/*static	const char	*ftitle = "bumps"; [> used in file name and title for tecplot <]*/
/*static	const int	imx = 201; [> max i value / num columns <]*/
/*static	const int	jmx = 51; [> max j value / num rows <]*/
/*static	const int	meshtype = 1; [> rectangular mesh <]*/

static	const char	*fname = "grid-SD7003.txt";  /* physical mesh file name */
static	const char	*ftitle = "sd7003"; /* used in file name and title for tecplot */
static	const int	imx = 200; /* max i value / num columns */
static	const int	jmx = 81; /* max j value / num rows */
static	const int	meshtype = 2; /* o-type mesh */

/* mach numbers to analyze */
/*static	const double	mach = 0.1;*/
static	const double	mach = 0.12;
/*static	const double	mach = 0.16;*/
/*static	const double	mach = 0.25;*/
/*static	const double	mach = 0.5;*/
/*static	const double	mach = 0.56;*/
/*static	const double	mach = 0.57; */

/* omega for SOR (successive overelaxation) */
/*static	const double	omega = .5; */
/*static	const double	omega = 1.1; */
static	const double	omega = 1.5; 
/*static	const double	omega = 1.75; */

static	const int	maxsteps = 1e7; /* max number of iteration steps */
/*static	const double	resnormratiomin = 1e-4; [> convergence value for residual test <]*/
static	const double	resnormratiomin = 1e-3; /* convergence value for residual test */
static	const int	convshow = 100; /* tabulate/print resnormratio every convshow'th interval */
static	double	conviter[maxsteps/convshow + 1]; /* array to hold iteration number */
static	double	convresrat[maxsteps/convshow + 1]; /* array to hold res norm ratio */
static	int	cvsteps = maxsteps/convshow + 1; /* wil be reset to actual count */

/* final project constants */
static	const double	gmma = 1.4; /* stp air ratio of specific heats */
static	const double	R = 287;  /* stp air gas constant [J/kg K] */
static	const double	pinf = 101325; /* stp pressure [Pa] */
static	const double	Tinf = 300; /* stp temperature [K] */
static	const double	rhoinf = pinf / (R * Tinf); /* stp density [kg/m^3] */
/*static	const double	machnums[3] = {0.01, 0.5, 0.8}; [> mach numbers <]*/
static	double	ainf; /* freestream speed of sound */
static	double	uinf; /* freestream velocity in x dir (vinf=0) */

/*****************************************************************************/
/* local statics (NOT thread safe, make structs with mutex for parallel processing) */
/* using statics instead of parameters for overall optimization */
/* note: C array is row major order, Fortran is column major order */
/*****************************************************************************/
static	double phi[jmx][imx]; /* velocity potential equation data */
static	double u[jmx][imx]; /* vel in x dir where u = dphi/dx */
static	double v[jmx][imx]; /* vel in y dir where v = dphi/dy */
static	double rho[jmx][imx]; /* density */
static	double a[jmx][imx][9]; /* coefficient matrix for 9 point stencil in a dual cell */

static	double vel[jmx][imx]; /* total velocity */
static	double m[jmx][imx]; /* mach number */
static	double cp[imx]; /* Cp at slip surface (j==0) */

/* physical mesh
 * import grid into physical mesh */
static	double x[jmx][imx]; /*  physical mesh x coordinates */
static	double y[jmx][imx]; /*  physical mesh y coordinates */

/* computational mesh
 * need relationship between changes in physical space and changes in computational space
 * so map derivatives using total derivative (see notes from 3/20/2019)
 * dx = dx/dxsi * dxsi + dx/deta * deta
 * dy = dy/dxsi * dxsi + dy/deta * deta
 * giving
 * dxsi = dxsi/dx * dx + dxsi/dy * dy
 * deta = deta/dx * dx + deta/dy * dy 
 * Jacobian = determinant for inverse matrix used to calculate comp space derivs from 
 * physical space derivs, J = 1/(dx/dsi * dy/deta - dx/deta * dy/dxsi) */
static	double zx[jmx][imx]; /* metric derivative (dxsi/dx)/J = dy/deta (xsi -> x/i/col dir) */
static	double zy[jmx][imx]; /* metric derivative (dxsi/dy)/J = -dx/deta */
static	double ex[jmx][imx]; /* metric derivative (deta/dx)/J = -dy/dxsi (eta -> y/j/row dir) */
static	double ey[jmx][imx]; /* metric derivative (deta/dy)/J = dx/dxsi */
static	double xj[jmx][imx]; /* inverse Jacobian 1/J where Jacobian is matrix determinant */

static	double phiz[jmx][imx]; /* vpe deriv in comp space: dphi/dxsi */
static	double phie[jmx][imx]; /* vpe deriv in comp space: dphi/deta */

static	double xmz[jmx][imx]; /* mach component in xsi dir */
static	double xme[jmx][imx]; /* mach component in eta dir */

/* residuals */
static	double resinit[jmx][imx]; /* initial residual, used for freestream subtraction to
									 reduce geometric conservation-law errors */
static	double resnorm = 0.0;	/* L2 Norm for convergence testing */

/*****************************************************************************/
/* function: metrics
 * 	calculates computational space derivatives from physical space derivatives
 * 	using finite difference approximations
 * inputs:
 * 	none - uses statics x, y
 * outputs:
 * 	none - calculates zx, zy, ex, ey, xj
 * 	*/
/*****************************************************************************/
static void metrics(void) {
	/* locals */
	int i, j;

	/* loop comp grid */
	for (j = 0; j < jmx; j++) {
		for (i = 0; i < imx; i++) {
			/* xsi */
			if (j == 0) {
				/* boundary: row 1, all cols */
				zx[j][i] = -1.5*y[j][i] + 2.0*y[j+1][i] - 0.5*y[j+2][i];
				
				/* kutta condition for this grid */
				if (i == (imx-4))
					zy[j][i] = (x[j][i] - x[j][i-1]);
				else if (i == (imx-5))
					zy[j][i] = (x[j][i+1] - x[j][i]);
				else
					zy[j][i] = -(-1.5*x[j][i] + 2.0*x[j+1][i] - 0.5*x[j+2][i]);
			}
			else if (j == (jmx-1)) {
				/* boundary: row jmx, all cols */
				zx[j][i] = 1.5*y[j][i] - 2.0*y[j-1][i] + 0.5*y[j-2][i];
				zy[j][i] = -(1.5*x[j][i] - 2.0*x[j-1][i] + 0.5*x[j-2][i]);
			}
			else {
				/* interior points */
				zx[j][i] = 0.5*(y[j+1][i] - y[j-1][i]);
				zy[j][i] = -0.5*(x[j+1][i] - x[j-1][i]);
			}

			/* eta */
			if (i == 0) {
				/* boundary: col 1, all rows */
				ex[j][i] = -(-1.5*y[j][i] + 2.0*y[j][i+1] - 0.5*y[j][i+2]);
				ey[j][i] = -1.5*x[j][i] + 2.0*x[j][i+1] - 0.5*x[j][i+2];
			}
			else if (i == (imx-1)) {
				/* boundary: col imx, all rows */
				ex[j][i] = -(1.5*y[j][i] - 2.0*y[j][i-1] + 0.5*y[j][i-2]);
				ey[j][i] = 1.5*x[j][i] - 2.0*x[j][i-1] + 0.5*x[j][i-2];
			}
			else {
				/* interior points */
				ex[j][i] = -0.5*(y[j][i+1] - y[j][i-1]);
				
				/* kutta condition for this grid */
				if (i == (imx-4))
					ey[j][i] = (y[j][i] - y[j][i-1]);
				else if (i == (imx-5))
					ey[j][i] = (y[j][i+1] - y[j][i]);
				else
					ey[j][i] = 0.5*(x[j][i+1] - x[j][i-1]);
			}

			/* Jacobian */
			xj[j][i] = zx[j][i]*ey[j][i] - ex[j][i]*zy[j][i];
		}
	}	
}

/*****************************************************************************/
/* function: phideriv
 * 	calculates vpe derivatives in computational space using FDAs
 * inputs:
 *  none - uses phi
 * outputs:
 * 	none - calculates phiz (dphi/dxsi), phie (dphi/deta)
 * 	*/
/*****************************************************************************/
static void phideriv(void) {
	/* locals */
	int i, j;

	/* loop comp grid */
	for (j = 0; j < jmx; j++) {
		for (i = 0; i < imx; i++) {
			/* dphi/deta (y/j/row dir) */
			if (j == 0) {
				/* boundary: row 1, all cols */
				phie[j][i] = -1.5*phi[j][i] + 2.0*phi[j+1][i] - 0.5*phi[j+2][i];
			}
			else if (j == (jmx-1)) {
				/* boundary: row jmx, all cols */
				phie[j][i] = 1.5*phi[j][i] - 2.0*phi[j-1][i] + 0.5*phi[j-2][i];
			}
			else {
				/* interior points */
				phie[j][i] = 0.5*(phi[j+1][i] - phi[j-1][i]);
				/*phie[j][i] = (phi[j][i] - phi[j-1][i]);*/
			}

			/* dphi/dxsi (x/i/col dir) */
			if (i == 0) {
				/* boundary: col 1, all rows */
				phiz[j][i] = -1.5*phi[j][i] + 2.0*phi[j][i+1] - 0.5*phi[j][i+2];
			}
			else if (i == (imx-1)) {
				/* boundary: col imx, all rows */
				phiz[j][i] = 1.5*phi[j][i] - 2.0*phi[j][i-1] + 0.5*phi[j][i-2];
			}
			/* kutta condition for this grid */
			else if (i == (imx-4) && j == 0) {
				phiz[j][i] = (phi[j][i] - phi[j][i-1]);
			}
			/* kutta condition for this grid */
			else if (i == (imx-5) && j == 0) {
				phiz[j][i] = (phi[j][i+1] - phi[j][i]);
			}
			else {
				/* interior points */
				phiz[j][i] = 0.5*(phi[j][i+1] - phi[j][i-1]);
				/*phiz[j][i] = (phi[j][i] - phi[j][i-1]);*/
			}
		}
	}	
}

/*****************************************************************************/
/* function: matrixcoeff
 * 	calculate 9 point stencil matrix coefficients
 * inputs:
 *  none - uses metric derivs and rho
 * outputs:
 * 	none - calculates a matrix
 * 	*/
/*****************************************************************************/
static void matrixcoeff(void) {
	/* locals */
	int i, j;
	double g11[imx-1], g12[imx-1], h12[jmx-1], h22[jmx-1], rhopz[imx], rhope[jmx];
	double zxavg, zyavg, exavg, eyavg, xjavg, rhoavg;
	double b11, b12, b22;
	double xmface, xnui, xnuip;

	/* xsi/x/col dir => g's */
	for (j = 1; j < (jmx-1); j++) {
		for (i = 0; i < (imx-1); i++) {
			rhopz[i] = 0.5*(rho[j][i] + rho[j][i+1]);
		}
		rhopz[imx-1] = rhopz[imx-2];

		for (i = 0; i < (imx-1); i++) {
			/* M&C transonic density correction */
			xmface = 0.5*(xmz[j][i] + xmz[j][i+1]);
			xnui = fmax(0.0, 1.0 - 1.0/(pow(xmz[j][i],2) + 1e-8));
			xnuip = fmax(0.0, 1.0 - 1.0/(pow(xmz[j][i+1],2) + 1e-8));
			if (xmface > 0)
				rhoavg = rhopz[i] - xnui*(rhopz[i] - rhopz[(int)fmax(0,i-1)]);
			else
				rhoavg = rhopz[i] + xnui*(rhopz[i+1] - rhopz[i]);

			zxavg = 0.5 * (zx[j][i] + zx[j][i+1]);
			zyavg = 0.5 * (zy[j][i] + zy[j][i+1]);
			exavg = 0.5 * (ex[j][i] + ex[j][i+1]);
			eyavg = 0.5 * (ey[j][i] + ey[j][i+1]);
			xjavg = 0.5 * (xj[j][i] + xj[j][i+1]);
			b11 = (pow(zxavg,2) + pow(zyavg,2)) / xjavg;
			b12 = (zxavg*exavg + zyavg*eyavg) / xjavg;
			g11[i] = rhoavg * b11;
			g12[i] = rhoavg * b12;
		}

		/* a(1-9) for interior points only */
		for (i = 1; i < (imx-1); i++) {
			a[j][i][1-1] = 0.25*g12[i-1];
			a[j][i][3-1] = -0.25*g12[i-1];
			a[j][i][7-1] = -0.25*g12[i];
			a[j][i][9-1] = 0.25*g12[i];
			a[j][i][2-1] = g11[i-1];
			a[j][i][8-1] = g11[i];
			a[j][i][6-1] = 0.25*(g12[i] - g12[i-1]);
			a[j][i][4-1] = -0.25*(g12[i] - g12[i-1]);
			a[j][i][5-1] = -(g11[i] + g11[i-1]);
		}
	}	

	/* eta/y/row dir => h's */
	for (i = 1; i < (imx-1); i++) {
		for (j = 0; j < (jmx-1); j++) {
			rhope[j] = 0.5*(rho[j][i] + rho[j+1][i]);
		}
		rhope[jmx-1] = rhope[jmx-2];

		for (j = 0; j < (jmx-1); j++) {
			/* M&C transonic density correction */
			xmface = 0.5*(xme[j][i] + xme[j+1][i]);
			xnui = fmax(0.0, 1.0 - 1.0/(pow(xme[j][i],2) + 1e-8));
			xnuip = fmax(0.0, 1.0 - 1.0/(pow(xme[j+1][i],2) + 1e-8));
			if (xmface > 0)
				rhoavg = rhope[j] - xnui*(rhope[j] - rhope[(int)fmax(0,j-1)]);
			else
				rhoavg = rhope[j] + xnui*(rhope[j+1] - rhope[j]);

			zxavg = 0.5 * (zx[j][i] + zx[j+1][i]);
			zyavg = 0.5 * (zy[j][i] + zy[j+1][i]);
			exavg = 0.5 * (ex[j][i] + ex[j+1][i]);
			eyavg = 0.5 * (ey[j][i] + ey[j+1][i]);
			xjavg = 0.5 * (xj[j][i] + xj[j+1][i]);
			b12 = (zxavg*exavg + zyavg*eyavg) / xjavg;
			b22 = (pow(exavg,2) + pow(eyavg,2)) / xjavg;
			h12[j] = rhoavg * b12;
			h22[j] = rhoavg * b22;
		}

		/* a(1-9) for interior points only */
		for (j = 1; j < (jmx-1); j++) {
			a[j][i][1-1] = a[j][i][1-1] + 0.25*h12[j-1];
			a[j][i][3-1] = a[j][i][3-1] - 0.25*h12[j];
			a[j][i][7-1] = a[j][i][7-1] - 0.25*h12[j-1];
			a[j][i][9-1] = a[j][i][9-1] + 0.25*h12[j];
			a[j][i][2-1] = a[j][i][2-1] - 0.25*(h12[j] - h12[j-1]);
			a[j][i][8-1] = a[j][i][8-1] + 0.25*(h12[j] - h12[j-1]);
			a[j][i][6-1] = a[j][i][6-1] + h22[j];
			a[j][i][4-1] = a[j][i][4-1] + h22[j-1];
			a[j][i][5-1] = a[j][i][5-1] - (h22[j] + h22[j-1]);
		}
	}
}

/*****************************************************************************/
/* function: applyboundary
 * 	apply boundary conditions
 * inputs:
 * 	btype: the boundary type to apply - 1=wall/farfield, 2=wakecut phi, 3=wakecut u,v,rho
 * 	uses phi
 * outputs:
 * 	none - updates phi on boundaries only
 * 	*/
/*****************************************************************************/
static void applyboundary(int btype) {
	/* locals */
	int i, j;
	double dphidz[imx];
	double b12, b22, t1, t2;

	/* wall */
	if (btype == 1) {
		/* boundary: row 0, all cols */
		j = 0;

		for (i = 1; i < (imx-1); i++) {
			dphidz[i] = 0.5*(phi[j][i+1] - phi[j][i-1]); /* lagged derivative!! */
		}

		for (i = 1; i < (imx-1); i++) {
			b12 = (zx[j][i] * ex[j][i] + zy[j][i] * ey[j][i]);
			b22 = (pow(ex[j][i],2) + pow(ey[j][i],2));
			phi[j][i] = (-b12 * dphidz[i] - (2.0*phi[j+1][i] - 0.5*phi[j+2][i])*b22) / (-1.5*b22);
			/*printf("bdry %lf\n",phi[j][i]);*/
		}

		/* boundary: row jmx-1, all cols */
		j = jmx-1;
		if (meshtype == 1) {
			/* wall condition */
			for (i = 1; i < (imx-1); i++) {
				dphidz[i] = 0.5*(phi[j][i+1] - phi[j][i-1]); /* lagged derivative!! */
			}

			for (i = 1; i < (imx-1); i++) {
				b12 = (zx[j][i] * ex[j][i] + zy[j][i] * ey[j][i]);
				b22 = (pow(ex[j][i],2) + pow(ey[j][i],2));
				phi[j][i] = (-b12 * dphidz[i] + (2.0*phi[j-1][i] - 0.5*phi[j-2][i])*b22) / (1.5*b22);
				/*printf("bdry 2 %lf\n",phi[j][i]);*/
			}
		}
		else if (meshtype == 2) {
			/* farfield boundary */
			for (i = 1; i < (imx-1); i++) {
				phi[j][i] = uinf * x[j][i];
			}
		}

		/* airfoil 0-type wakecut boundary conditions */
		if (meshtype == 2) {
			/* move the first column back and last column forward */
			for (j = 0; j < jmx; j++) {
				/*phi[j][0] = phi[j][imx-3];*/
				/*phi[j][imx-1] = phi[j][2];*/
				phi[j][0] = phi[j][imx-2];
				phi[j][imx-1] = phi[j][1];
			}

			/* kutta condition */
			/* apply at point 1,1 and 1,imx */
			/* want v=0 => dphi/dy = (dxsi/dy * dphi/dxsi + deta/dy*dphi/deta) = 0 */
			/*	  v[j][i] = (zy[j][i]*phiz[j][i] + ey[j][i]*phie[j][i]) / xj[j][i];*/
			/*    phie[j][i] = -1.5*phi[j][i] + 2.0*phi[j+1][i] - 0.5*phi[j+2][i];*/
				
				/*phiz[j][i] = (phi[j][i] - phi[j][i-1]);*/
			j = 0;
			i = imx-4;
			t1 = zy[j][i] * phi[j][i-1];
			t2 = ey[j][i] * (-2.0*phi[j+1][i] + 0.5*phi[j+2][i]);
			phi[j][i] = (t1 + t2) / (zy[j][i] - 1.5*ey[j][i]);
		
				/*phiz[j][i] = (phi[j][i+1] - phi[j][i]);*/
			j = 0;
			i = imx-5;
			t1 = zy[j][i] * phi[j][i+1];
			t2 = ey[j][i] * (2.0*phi[j+1][i] - 0.5*phi[j+2][i]);
			phi[j][i] = (t1 + t2) / (zy[j][i] + 1.5*ey[j][i]);
			/* ensure phi derivs come out to zero in TE cell */	
			/*phi[0][imx-3] = (2.0*phi[j+1][imx-3] - 0.5*phi[j+2][imx-3]) / 1.5;*/
		}
	}
	/*wake cut phi*/
	/*else if (btype == 2) {*/
		/*for (j = 0; j < jmx; j++) {*/
		/*for (j = 1; j < jmx; j++) {*/
			/*phi[j][0] = phi[j][imx-3];*/
			/*phi[j][imx-1] = phi[j][2];*/
			/*phi[j][0] = phi[j][imx-2];*/
			/*phi[j][imx-1] = phi[j][1];*/
		/*}*/
		/*phi[0][0] = 0;*/
		/*phi[0][imx-1] = 0;*/


	/*}*/
	/*wake cut u,v,rho*/
	else if (btype == 3) {
		for (j = 0; j < jmx; j++) {
			/*u[j][0] = u[j][imx-3];*/
			/*v[j][0] = v[j][imx-3];*/
			/*rho[j][0] = rho[j][imx-3];*/
			/*u[j][imx-1] = u[j][2];*/
			/*v[j][imx-1] = v[j][2];*/
			/*rho[j][imx-1] = rho[j][2];*/
			u[j][0] = u[j][imx-2];
			v[j][0] = v[j][imx-2];
			rho[j][0] = rho[j][imx-2];
			u[j][imx-1] = u[j][1];
			v[j][imx-1] = v[j][1];
			rho[j][imx-1] = rho[j][1];
		}
	}
}

/*****************************************************************************/
/* function: flowprops
 * 	calculates flow properties velocity and density from the velocity potential
 * inputs:
 * 	none - used mach, ainf and calls phideriv
 * outputs:
 * 	none - calculates static variables u, v, rho
 * 	*/
/*****************************************************************************/
static void flowprops() {
	/* locals */
	int i, j;
	double msq, lmsq, term, la, vdotnz, vdotne;

	/* first calculate phi derivatives in comp space */
	phideriv();

	/* loop comp grid */
	for (j = 0; j < jmx; j++) {
		for (i = 0; i < imx; i++) {
			/* calculate u, v, rho from phi in computational space converted back to physical space */
			/* u = dphi/dx = (dxsi/dx * dphi/dxsi) + (deta/dx * dphi/deta) */
			u[j][i] = (zx[j][i]*phiz[j][i] + ex[j][i]*phie[j][i]) / xj[j][i];

			/* v = dphi/dy = (dxsi/dy * dphi/dxsi) + (deta/dy * dphi/deta) */
			v[j][i] = (zy[j][i]*phiz[j][i] + ey[j][i]*phie[j][i]) / xj[j][i];

			/* intermediary numbers for the term in rho and a calcs */
			msq = pow(mach,2);
			lmsq = (pow(u[j][i],2) + pow(v[j][i],2)) / pow(ainf,2);
			term = (1 + ( ((gmma-1)/2) * (msq - lmsq) ) );

			/* rho = f(u,v,mach,ainf) */
			rho[j][i] = rhoinf * pow(term, (1/(gmma-1)));
			/*printf("i=%d, j=%d, msq=%lf, lmsq=%lf, rho=%lf\n",i,j,msq,lmsq,rho[j][i]);*/

			/* calculate mach components in xsi and eta directions for M&C transonic correction */
			vdotnz = (u[j][i]*zx[j][i] + v[j][i]*zy[j][i]) / sqrt(pow(zx[j][i],2) + pow(zy[j][i],2));
			vdotne = (u[j][i]*ex[j][i] + v[j][i]*ey[j][i]) / sqrt(pow(ex[j][i],2) + pow(ey[j][i],2));

			la = ainf * sqrt(term); /* local speed of sound */

			xmz[j][i] = vdotnz / la;
			xme[j][i] = vdotne / la;
		}
	}	
}

/*****************************************************************************/
/* function: rescalc
 * 	calculate residual entry for cell i,j
 * inputs:
 * 	i = col index for center of cell
 * 	j = row index for center of cell
 * 	uses a, phi
 * outputs:
 * 	res = residual of vpe for cell (9 half-points stencil) at i,j
 * 	*/
/*****************************************************************************/
static double rescalc(int i, int j) {
	return a[j][i][2]*phi[j+1][i-1] + a[j][i][5]*phi[j+1][i] + a[j][i][8]*phi[j+1][i+1]
		+ a[j][i][1]*phi[j][i-1] + a[j][i][4]*phi[j][i] + a[j][i][7]*phi[j][i+1]
		+ a[j][i][0]*phi[j-1][i-1] + a[j][i][3]*phi[j-1][i] + a[j][i][6]*phi[j-1][i+1];
}

/*****************************************************************************/
/* function: rescalcrelax
 * 	calculate residual entry for cell i,j minues the center
 * 	for solving the vpe for phi(i,j) in relaxation
 * inputs:
 * 	i = col index for center of cell
 * 	j = row index for center of cell
 * 	uses a, phi
 * outputs:
 * 	res = residual of vpe for cell outer portion (8 half-points stencil) at i,j
 * 	*/
/*****************************************************************************/
static double rescalcrelax(int i, int j) {
	return a[j][i][2]*phi[j+1][i-1] + a[j][i][5]*phi[j+1][i] +a[j][i][8]*phi[j+1][i+1]
		+ a[j][i][1]*phi[j][i-1] + a[j][i][7]*phi[j][i+1]
		+ a[j][i][0]*phi[j-1][i-1]+ a[j][i][3]*phi[j-1][i]+ a[j][i][6]*phi[j-1][i+1];
}

/*****************************************************************************/
/* function: rescalcall
 * 	calculate residual and return the L2 norm
 * inputs:
 * 	none - uses phi
 * outputs:
 * 	resnorm = L2 norm of residual for vpe
 * 	*/
/*****************************************************************************/
static double rescalcall(void) {
	/* locals */
	int i, j;
	double res, resnorm = 0.0;

	/* only loop interior points */
	for (j = 1; j < (jmx-1); j++) {
		for (i = 1; i < (imx-1); i++) {
			res = rescalc(i, j) - resinit[j][i];
			resnorm += pow(res,2);
			/*printf("i=%d, j=%d, res=%lf, resnomr=%lf\n",i,j,res,resnorm);*/
		}
	}

	return sqrt(resnorm);
}

/*****************************************************************************/
/* function: relax
 * 	perform relaxation - SOR symmetric overrelaxation
 * inputs:
 * 	none - uses phi, resinit, omega
 * 	calls rescalc
 * outputs:
 * 	none - updates phi
 * 	*/
/*****************************************************************************/
static void relax(void) {
	/* locals */
	int i, j;
	double phitmp, res, kernel;

	/* FSOR on interior points only */
	for (j = 1; j < (jmx-1); j++) {
		for (i = 1; i < (imx-1); i++) {
			kernel = (resinit[j][i] - rescalcrelax(i,j)) / a[j][i][5-1];
			/*printf("%lf %lf %lf\n",resinit[j][i],phi[j][i],kernel);*/
			phitmp = phi[j][i];
			phi[j][i] = phitmp + omega*(kernel - phitmp);
		}
	}

	/* BSOR on interior points only */
	for (i = 1; i < (imx-1); i++) {
		for (j = 1; j < (jmx-1); j++) {
			kernel = (resinit[j][i] - rescalcrelax(i,j)) / a[j][i][5-1];
			/*printf("%lf %lf %lf\n",resinit[j][i],phi[j][i],kernel);*/
			phitmp = phi[j][i];
			phi[j][i] = phitmp + omega*(kernel - phitmp);
		}
	}
}

/*****************************************************************************/
/* function: tecplot */
/* inputs:
 * 	none - uses x,y,u,v,vel, ftitle,mach
 * */
/* outputs:
 * 	plt file for use in Tecplot, saved to filesystem
 * 	*/
/*****************************************************************************/
static void tecplot(void) {
	/* locals */
	int i, j, cv;
	char fname[50];

	/* save out tecplot file */
	snprintf(fname, sizeof(fname), "VEL_%s_%.2lf.plt",ftitle,mach);
	
	FILE *fout = fopen(fname, "w+t");

	fprintf(fout, "TITLE=\"Mach %.2lf velocity data for %s \"\n",mach,ftitle);
	fprintf(fout, "VARIABLES=X,Y,U,V,VEL,M\n");
	fprintf(fout, "ZONE	 F=POINT\n");
	fprintf(fout, "I=%d, J=%d\n", imx, jmx);

	for (j = 0; j < jmx; j++)
		for (i = 0; i < imx; i++)
			fprintf(fout,"%.15lf\t%.15lf\t%.15lf\t%.15lf\t%.15lf\t%.15lf\n",
					x[j][i], y[j][i], u[j][i], v[j][i], vel[j][i], m[j][i]);

	fclose(fout);

	/* save out convergence history */	
	snprintf(fname, sizeof(fname), "ConvHistory_%s_%.2lf.txt",ftitle,mach);
	
	fout = fopen(fname, "w+t");

	fprintf(fout, "Iteration\tResidual Norm Ratio\n");
	for (cv = 0; cv < cvsteps; cv++)
		fprintf(fout, "%.15lf\t%.15lf\n",conviter[cv],convresrat[cv]);

	fclose(fout);
	
	/* save out Cp */	
	snprintf(fname, sizeof(fname), "PressCoeff_%s_%.2lf.txt",ftitle,mach);
	
	fout = fopen(fname, "w+t");

	fprintf(fout, "x/c\tCp\n");
	j = 0;
	for (i = 0; i < imx; i++)
		fprintf(fout, "%.15lf\t%.15lf\n",x[j][i]/x[j][imx-1],cp[i]);
	
	fclose(fout);
}

/*****************************************************************************/
/* main */
/*****************************************************************************/
int main()
{
	/* locals */
	int i, j, n, midx;
	int cv = 0;
	int p;
	double resnorm = 0.0, resnorminit = 0.0, resnormratio = 1.0;

	/* initialize freestream speed of sound and velocity */
	ainf = sqrt(gmma * R * Tinf);
	uinf = mach * ainf;

	/******************************************************/
	/* preprocessing */
	/******************************************************/

	/* read in physical mesh from file */
	int timx, tjmx;
	FILE *fp = fopen(fname,"r");
	fscanf(fp,"%d %d", &timx, &tjmx); /* not using - size hard coded for performance */

	/* fill physical mesh x,y */
	for (j=0; j < jmx; j++)
		for (i=0; i < imx; i++)
			fscanf(fp,"%lf %lf", &x[j][i], &y[j][i]);

	fclose(fp);

	/* if doing airfoil and o-type mesh, need to renumber mesh for boundaries */
	if (meshtype == 2) {
		/* now move the old i=1,imx boundaries */
		for (j=0; j < jmx; j++) {
			/*printf("x0=%lf,ximx-3=%lf,ximx-1=%lf,x2=%lf\n",x[j][0],x[j][imx-3],x[j][imx-1],x[j][2]);*/
			/*x[j][0] = x[j][imx-3];*/
			/*y[j][0] = y[j][imx-3];*/
			/*x[j][imx-1] = x[j][2];*/
			/*y[j][imx-1] = y[j][2];*/
			/*x[j][0] = x[j][imx-2];*/
			/*y[j][0] = y[j][imx-2];*/
			/*x[j][imx-1] = x[j][1];*/
			/*y[j][imx-1] = y[j][1];*/
		}
		/*for (j=0; j < jmx; j++) {*/
			/*for (i=0; i < imx; i++) {*/
				/*if (i == 0) {*/
					/*x[j][i] = x[j][imx-3];*/
					/*y[j][i] = y[j][imx-3];*/
				/*}*/
				/*else if (i == (imx-1)) {*/
					/*x[j][i] = x[j][2];*/
					/*y[j][i] = y[j][2];*/
				/*}*/
				/*else {*/
					/*x[j][i] = x[j][i-1];*/
					/*y[j][i] = y[j][i-1];*/
				/*}*/
			/*}*/
		/*}*/

		/* rotate to put TE at end */
		/*double xnew[jmx][imx], ynew[jmx][imx];*/
		/*for (j=0; j < jmx; j++) {*/
			/*for (i = 0; i < 4; i++) {*/
				/*xnew[j][i] = x[j][imx-4+i];*/
				/*ynew[j][i] = y[j][imx-4+i];*/
			/*}*/
		/*}*/
		/*for (j=0; j < jmx; j++) {*/
			/*for (i=4; i < imx; i++) {*/
				/*xnew[j][i] = x[j][i-4];*/
				/*ynew[j][i] = y[j][i-4];*/
			/*}*/
		/*}*/

		/*for (j=0; j < jmx; j++) {*/
			/*for (i=0; i < imx; i++) {*/
				/*x[j][i] = xnew[j][i];*/
				/*y[j][i] = ynew[j][i];*/
			/*}*/
		/*}*/


	}

	/* initialize phi (horiz veloc only, so vinf=0) */
	for (j=0; j < jmx; j++)
		for (i=0; i < imx; i++)
			phi[j][i] = uinf * x[j][i];

	/* calculate metric derivatives */
	metrics();

	/* initialize u,v,rho */
	flowprops();

	/* calculate matrix coefficients */
	matrixcoeff();

	/* calculate initial residual */
	for (j=1; j < (jmx-1); j++)
		for (i=1; i < (imx-1); i++) {
			resinit[j][i] = rescalc(i,j);
			/*printf("%lf\n",resinit[j][i]);*/
		}

	/* apply boundary conditions: 1=wall/farfield, 2=wakecut phi, 3=wakecut u,v,rho */
	/*if (meshtype == 2) applyboundary(2);*/
	applyboundary(1);

	/* recalculate u,v,rho */
	flowprops();

	/* if o-type, now need to apply periodic bc fix to u,v,rho */
	if (meshtype == 2) applyboundary(3);

	/* recalculate matrix coefficients */
	matrixcoeff();

	/******************************************************/
	/* iterate on residual error until converged or maxsteps reached */
	/******************************************************/
	for (n = 0; n < maxsteps; n++) {
	/*for (n = 0; n < 5; n++) {*/
		/* calculate residual and get L2 norm */
		resnorm = rescalcall();

		/* test for convergence */
		if (n == 0)	resnorminit = resnorm;

		resnormratio = resnorm / resnorminit;
		if(n % convshow == 0) {
		/*if (1) {*/
			/* calculate total velocity and mach num for plots */
			/*for (j = 0; j < jmx; j++) {*/
				/*for (i = 0; i < imx; i++) {*/
					/*vel[j][i] = sqrt(pow(u[j][i],2) + pow(v[j][i],2));*/
					/*m[j][i] = vel[j][i] / ainf;*/
				/*}*/
			/*}*/
	
			printf("iteration %d, residual norm ratio %.8lf\n",n,resnormratio);
			/*for (i=0;i<imx;i++) {*/
				/*printf("i=%d,phi=%.8lf, u=%.8lf, v=%.8lf\n",i,phi[0][i],u[0][i],v[0][i]);*/
			/*}*/
			/*printf("phi=%.8lf, u=%.8lf, v=%.8lf\n",phi[0][0],u[0][0],v[0][0]);*/
			printf("phi=%.8lf, u=%.8lf, v=%.8lf\n",phi[0][imx-5],u[0][imx-5],v[0][imx-5]);
			printf("phi=%.8lf, u=%.8lf, v=%.8lf\n",phi[0][imx-4],u[0][imx-4],v[0][imx-4]);
			conviter[cv++] = n;  /* save current iteration and resnormratio for */
			convresrat[cv] = resnormratio;  /* plotting convergence history */
		}
		
		if (resnormratio < resnormratiomin) {
			printf("final iteration %d, residual norm ratio %.8lf\n",n,resnormratio);
			printf("phi(0=%.8lf, u=%.8lf, v=%.8lf\n",phi[0][0],u[0][0],v[0][0]);
			printf("phi(0=%.8lf, u=%.8lf, v=%.8lf\n",phi[0][imx-1],u[0][imx-1],v[0][imx-1]);
			conviter[cv++] = n;  
			convresrat[cv] = resnormratio;  

			cvsteps = cv;
		   	break; /* break if convergence level achieved */
		}

		/* perform relaxation */
		relax();

		/* reapply boundary conditions */
		/*if (meshtype == 2) applyboundary(2);*/
		applyboundary(1);

		/* recalculate u,v,rho */
		flowprops();

		/* if o-type, now need to apply periodic bc fix to u,v,rho */
		if (meshtype == 2) applyboundary(3);

		/* recalculate matrix coefficients */
		matrixcoeff();
	}

	/* calculate total velocity and mach num for plots */
	for (j = 0; j < jmx; j++) {
		for (i = 0; i < imx; i++) {
			vel[j][i] = sqrt(pow(u[j][i],2) + pow(v[j][i],2));
			m[j][i] = vel[j][i] / ainf;
		}
	}
	

	/* calculate Cp on slip surface */
	j = 0;
	for (i = 0; i < imx; i++) {
		p = rho[j][i] * R * Tinf; /* local pressure */
		cp[i] = (p - pinf) / (0.5 * rho[j][i] * pow(vel[j][i],2));
	}

	/* call tecplot to save data out to plt file, conv history and Cp to txt file */
	tecplot();

	return 0;
}
