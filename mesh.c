/* Andrew Navratil
 * MAE 456 CFD */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <ctype.h>
/*#include "mex.h"*/

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
/* function: tecplot */
/* inputs:
 *  x = physical mesh x coordinates for computational mesh (2D array i,j)
 *  y = physical mesh y coordinates for computational mesh (2D array i,j)
 *  m = metric derivative to plot
 *  mname = name of metric, used in plot and file name
 * */
/* outputs:
 * 	plt file for use in Tecplot, saved to filesystem
 * 	*/
/*****************************************************************************/
static void tecplot(double x[jmx][imx], double y[jmx][imx], double m[jmx][imx], char *mname) {
	char fname[10];
	snprintf(fname, sizeof(fname), "%s.plt", mname);
	
	FILE *fout = fopen(fname, "w+t");

	fprintf(fout, "VARIABLES=\"X\",\"Y\",\"%c%c\"\n", toupper(mname[0]), toupper(mname[1]));
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
	int timx, tjmx;
	FILE *fp = fopen(fname,"r");
	fscanf(fp,"%d %d", &timx, &tjmx); /* not using - size hard coded for performance */

	double x[jmx][imx], y[jmx][imx];
	double zx[jmx][imx], zy[jmx][imx], ex[jmx][imx], ey[jmx][imx], xj[jmx][imx];

	for (int j=0; j < jmx; j++)
		for (int i=0; i < imx; i++)
			fscanf(fp,"%lf %lf", &x[j][i], &y[j][i]);

	fclose(fp);

	/* get metric derivatives */
	metrics(x, y, zx, zy, ex, ey, xj);

	/* output for tecplot */
	tecplot(x, y, zx, "zx");
	tecplot(x, y, zy, "zy");
	tecplot(x, y, ex, "ex");
	tecplot(x, y, ey, "ey");
	tecplot(x, y, xj, "xj");

	return 0;
}
