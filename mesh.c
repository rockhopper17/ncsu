/* Andrew Navratil
 * MAE 456 CFD */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <ctype.h>

/*****************************************************************************/
/* constants */
/*****************************************************************************/
static	const char	*fname = "grid-poisson-2015.txt";  /* physical mesh file name */
static	const int	imx = 81; /* max i value / num columns */
static	const int	jmx = 81; /* max j value / num rows */

/*****************************************************************************/
/* function: metrics */
/* inputs:
 *  x = physical mesh x coordinates for computational mesh (2D array i,j)
 *  y = physical mesh y coordinates for computational mesh (2D array i,j)
 * */
/* outputs:
 * 	zx = metric derivative (dxsi/dx)/J = dy/deta (2D array i,j)  (xsi -> x/i/col dir)
 * 	zy = metric derivative (dxsi/dy)/J = -dx/deta (2D array i,j)
 * 	ex = metric derivative (deta/dx)/J = -dy/dxsi (2D array i,j)  (eta -> y/j/row dir)
 * 	ey = metric derivative (deta/dy)/J = dx/dxsi (2D array i,j)
 * 	xj = inverse Jacobian 1/J (2D array i,j)
 * 	*/
/* note: C array is row major order, Fortran is column major order */
/*****************************************************************************/
static void metrics(double x[jmx][imx], double y[jmx][imx],
		double zx[jmx][imx], double zy[jmx][imx], double ex[jmx][imx], double ey[jmx][imx], double xj[jmx][imx]) {
	/* loop comp grid */
	for (int j = 0; j < jmx; j++) {
		for (int i = 0; i < imx; i++) {
			/* xsi */
			if (j == 0) {
				/* boundary: row 1, all cols */
				zx[j][i] = -1.5*y[j][i] + 2.0*y[j+1][i] - 0.5*y[j+2][i];
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
				ey[j][i] = 0.5*(x[j][i+1] - x[j][i-1]);
			}

			/* Jacobian */
			xj[j][i] = zx[j][i]*ey[j][i] - ex[j][i]*zy[j][i];
		}
	}	
}

/*****************************************************************************/
/* function: phideriv */
/* inputs:
 *  phi = velocity potential function data
 * */
/* outputs:
 * 	phiz = dphi/dxsi
 * 	phie = dphi/deta
 * 	*/
/*****************************************************************************/
static void phideriv(double phi[jmx][imx], double phiz[jmx][imx], double phie[jmx][imx]) {
	/* loop comp grid */
	for (int j = 0; j < jmx; j++) {
		for (int i = 0; i < imx; i++) {
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
			else {
				/* interior points */
				phiz[j][i] = 0.5*(phi[j][i+1] - phi[j][i-1]);
			}
		}
	}	
}

/*****************************************************************************/
/* function: vpesolve */
/* inputs:
 * 	phiz = dphi/dxsi
 * 	phie = dphi/deta
 * 	zx = metric derivative (dxsi/dx)/J = dy/deta (2D array i,j)  (xsi -> x/i/col dir)
 * 	zy = metric derivative (dxsi/dy)/J = -dx/deta (2D array i,j)
 * 	ex = metric derivative (deta/dx)/J = -dy/dxsi (2D array i,j)  (eta -> y/j/row dir)
 * 	ey = metric derivative (deta/dy)/J = dx/dxsi (2D array i,j)
 * 	xj = inverse Jacobian 1/J (2D array i,j)
 * */
/* outputs:
 * 	u = u velocity (dphi/dx) = (dxsi/dx)(dphi/dxsi) + (deta/dx)(dphi/deta)
 * 	v = v velocity (dphi/dy) = (dxsi/dy)(dphi/dxsi) + (deta/dy)(dphi/deta)
 * 	*/
/*****************************************************************************/
static void vpesolve(double phiz[jmx][imx], double phie[jmx][imx],
		double zx[jmx][imx], double zy[jmx][imx], double ex[jmx][imx], double ey[jmx][imx], double xj[jmx][imx],
		double u[jmx][imx], double v[jmx][imx]) {
	/* loop comp grid */
	for (int j = 0; j < jmx; j++) {
		for (int i = 0; i < imx; i++) {
			u[j][i] = (zx[j][i]*phiz[j][i] + ex[j][i]*phie[j][i]) / xj[j][i];
			v[j][i] = (zy[j][i]*phiz[j][i] + ey[j][i]*phie[j][i]) / xj[j][i];
		}
	}	
}

/*****************************************************************************/
/* function: tecplot */
/* inputs:
 *  x = physical mesh x coordinates for computational mesh (2D array i,j)
 *  y = physical mesh y coordinates for computational mesh (2D array i,j)
 *  m = metric derivative / vpe matrix to plot
 *  mname = name of metric or phi, used in plot and file name
 * */
/* outputs:
 * 	plt file for use in Tecplot, saved to filesystem
 * 	*/
/*****************************************************************************/
static void tecplot(double x[jmx][imx], double y[jmx][imx], double m[jmx][imx], char *mname) {
	char fname[10];
	snprintf(fname, sizeof(fname), "%s.plt", mname);
	
	FILE *fout = fopen(fname, "w+t");

	fprintf(fout, "VARIABLES=\"X\",\"Y\",\"%s\"\n", mname);
	fprintf(fout, "ZONE	 F=POINT\n");
	fprintf(fout, "I=%d, J=%d\n", imx, jmx);

	for (int j=0; j < jmx; j++)
		for (int i=0; i < imx; i++)
			fprintf(fout,"%.15lf\t%.15lf\t%.15lf\n", x[j][i], y[j][i], m[j][i]);

	fclose(fout);
}

/*****************************************************************************/
/* main */
/*****************************************************************************/
int main()
{
	/* read in physical mesh from file */
	int timx, tjmx;
	FILE *fp = fopen(fname,"r");
	fscanf(fp,"%d %d", &timx, &tjmx); /* not using - size hard coded for performance */

	/* variables for mesh, derivatives, vpe */
	double x[jmx][imx], y[jmx][imx];
	double zx[jmx][imx], zy[jmx][imx], ex[jmx][imx], ey[jmx][imx], xj[jmx][imx];
	double phi[jmx][imx];
	double phiz[jmx][imx], phie[jmx][imx];
	double u[jmx][imx], v[jmx][imx];

	/* fill physical mesh x,y */
	for (int j=0; j < jmx; j++)
		for (int i=0; i < imx; i++)
			fscanf(fp,"%lf %lf", &x[j][i], &y[j][i]);

	fclose(fp);

	/* fill phi based on test function phi = 10x - 5y */
	for (int j=0; j < jmx; j++)
		for (int i=0; i < imx; i++)
			phi[j][i] = 10.0*x[j][i] - 5.0*y[j][i];

	/* get metric derivatives */
	metrics(x, y, zx, zy, ex, ey, xj);

	/* get phi derivatives in comp space */
	phideriv(phi, phiz, phie);

	/* solve vpe for u,v velocities */
	vpesolve(phiz, phie, zx, zy, ex, ey, xj, u, v);

	/* output for tecplot */
	tecplot(x, y, zx, "ZX");
	tecplot(x, y, zy, "ZY");
	tecplot(x, y, ex, "EX");
	tecplot(x, y, ey, "EY");
	tecplot(x, y, xj, "XJ");
	tecplot(x, y, xj, "XJ");
	tecplot(x, y, phi, "PHI");
	tecplot(x, y, u, "U");
	tecplot(x, y, v, "V");

	/* todo: get max difference from analytic result and printf (so abs(10-u) and abs(-5-v)) */

	return 0;
}
