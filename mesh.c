/* Andrew Navratil
 * MAE 456 CFD */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include "mex.h"

/*****************************************************************************/
/* function: metrics */
/* inputs:
 * 	imx = max i value - num columns (int)
 * 	jmx = max j value - num rows (int)
 *  x = physical mesh x coordinates for computational mesh (2D array i,j)
 *  y = physical mesh y coordinates for computational mesh (2D array i,j)
 * */
/* outputs:
 * 	zx = metric derivative (dxsi/dx)/J = dy/deta (2D array i,j)  (xsi -> x/i dir)
 * 	zy = metric derivative (dxsi/dy)/J = -dx/deta (2D array i,j)
 * 	ex = metric derivative (deta/dx)/J = -dy/dxsi (2D array i,j)  (eta -> y/j dir)
 * 	ey = metric derivative (deta/dy)/J = dx/dxsi (2D array i,j)
 * 	xj = inverse Jacobian 1/J (2D array i,j)
 * 	*/
/* recall 2d array pointer arithmetic: access x[j=row][i=col] like x[j*imx + i] */
/*****************************************************************************/
static void mesh(double *zx, double *zy, double *ex, double *ey, double *xj,
		int imx, int jmx, double *x, double *y) {
	/* locals */
	int i,j;

	/* loop comp grid */
	for (j = 0; j < jmx; j++) {
		for (i = 0; i < imx; i++) {
			/* xsi */
			if (j == 0) {
				/* boundary: row 1, all cols */
				zx[0 + i] = -1.5*y[0 + i] + 2.0*y[1*imx + i] - 0.5*y[2*imx + i];
				zy[0 + i] = -(-1.5*x[0 + i] + 2.0*x[1*imx + i] - 0.5*x[2*imx + i]);
			}
			else if (j == (jmx-1)) {
				/* boundary: row jmx, all cols */
				zx[j*imx + i] = -1.5*y[j*imx + i] + 2.0*y[(j-1)*imx + i] - 0.5*y[(j-2)*imx + i];
				zy[j*imx + i] = -(-1.5*x[j*imx + i] + 2.0*x[(j-1)*imx + i] - 0.5*x[(j-2)*imx + i]);
			}
			else {
				/* interior points */
				zx[j*imx + i] = 0.5*(y[(j+1)*imx + i] - y[(j-1)*imx + i]);
				zy[j*imx + i] = -0.5*(x[(j+1)*imx + i] - x[(j-1)*imx + i]);
			}

			/* eta */
			if (i == 0) {
				/* boundary: col 1, all rows */
				ex[j*imx + 0] = -(-1.5*y[j*imx + 0] + 2.0*y[j*imx + 1] - 0.5*y[j*imx + 2]);
				ey[j*imx + 0] = -1.5*x[j*imx + 0] + 2.0*x[j*imx + 1] - 0.5*x[j*imx + 2];
			}
			else if (i == (imx-1)) {
				/* boundary: col imx, all rows */
				ex[j*imx + i] = -(-1.5*y[j*imx + i] + 2.0*y[j*imx + i-1] - 0.5*y[j*imx + i-2]);
				ey[j*imx + i] = -1.5*x[j*imx + i] + 2.0*x[j*imx + i-1] - 0.5*x[j*imx + i-2];
			}
			else {
				/* interior points */
				ex[j*imx + i] = -0.5*(y[j*imx + i+1] - y[j*imx + i-1]);
				ey[j*imx + i] = 0.5*(x[j*imx + i+1] - x[j*imx + i-1]);
			}

			/* Jacobian */
			xj[j*imx + i] = zx[j*imx + i]*ey[j*imx + i] - ex[j*imx + i]*zy[j*imx + i];
		}
	}	
}

/*****************************************************************************/
/* main */
/* simulate matlab code calling c functions */
/*****************************************************************************/
/*int main()*/
/*{*/
	/*int imx = 81;*/
	/*int jmx = 81;*/
	/*FILE *fp = fopen("grid-poisson-2015.txt","r");*/
	/*fscanf(fp,"%d %d", &imx, &jmx);*/

	/*double *x = (double *) malloc(imx * jmx * sizeof(double));*/
	/*double *y = (double *) malloc(imx * jmx * sizeof(double));*/
	/*double *zx = (double *) malloc(imx * jmx * sizeof(double));*/
	/*double *zy = (double *) malloc(imx * jmx * sizeof(double));*/
	/*double *ex = (double *) malloc(imx * jmx * sizeof(double));*/
	/*double *ey = (double *) malloc(imx * jmx * sizeof(double));*/
	/*double *xj = (double *) malloc(imx * jmx * sizeof(double));*/

	/*for (int j=0; j < jmx; j++)*/
		/*for (int i=0; i < imx; i++)*/
			/*fscanf(fp,"%lf %lf", &x[j*imx + i], &y[j*imx+i]);*/

	/*fclose(fp);*/

	/*metrics(zx, zy, ex, ey, xj, imx, jmx, x, y);*/

	/*free(x);*/
	/*free(y);*/
	/*free(ex);*/
	/*free(ey);*/
	/*free(zx);*/
	/*free(zy);*/
	/*free(xj);*/

	/*return 0;*/
/*}*/

/* gateway function for matlab, build with mex and call cfd
 * build in matlab: mex -g cfd.c -r2018a
 * call like this: [x, u] = cfd(nu, cn);
 * nlhs = num outputs, nrhs = num inputs
 * plhs = array of ptrs to outputs, prhs = array of ptrs to inputs */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	/* input variables from matlab */
	int imx, jmx;
	double *x, *y;
	
	/* output variables for matlab */
	double *ex, *ey, *zx, *zy, *xj;

	/* check for proper number of arguments */
	if (nrhs != 4) {
		mexErrMsgIdAndTxt( "MATLAB:cfd:invalidNumInputs", "Invalid number of input arguments.");
	} else if (nlhs > 5) {
		mexErrMsgIdAndTxt( "MATLAB:cfd:maxlhs","Too many output arguments.");
	}

	/* get inputs */
	imx = mxGetScalar(prhs[0]);
	jmx = mxGetScalar(prhs[1]);
	x = mxGetDoubles(prhs[2]);
	y = mxGetDoubles(prhs[3]);

	/* create outputs */
	plhs[0] = mxCreateDoubleMatrix( (mwSize)jmx, (mwSize)imx, mxREAL);
	plhs[1] = mxCreateDoubleMatrix( (mwSize)jmx, (mwSize)imx, mxREAL);
	plhs[2] = mxCreateDoubleMatrix( (mwSize)jmx, (mwSize)imx, mxREAL);
	plhs[3] = mxCreateDoubleMatrix( (mwSize)jmx, (mwSize)imx, mxREAL);
	plhs[4] = mxCreateDoubleMatrix( (mwSize)jmx, (mwSize)imx, mxREAL);
	ex = mxGetDoubles(plhs[0]);
	ey = mxGetDoubles(plhs[1]);
	zx = mxGetDoubles(plhs[2]);
	zy = mxGetDoubles(plhs[3]);
	xj = mxGetDoubles(plhs[4]);

	/* call metrics function */
	mesh(zx, zy, ex, ey, xj, imx, jmx, x, y);

	/*free(x);*/
	/*free(u);*/
	/* do we need to free up any of the mex created arrays here? */
	/* call mxDestroyArray somehow on this output variable? */

	return;
}
