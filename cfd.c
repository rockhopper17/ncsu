/* Andrew Navratil
 * MAE 456 CFD */

#include <stdlib.h>
#include <math.h>
#include "mex.h"

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

/*****************************************************************************/
/* constants */
/*****************************************************************************/

/* 1D wave eqn parameters */
static	const double	c = 1.0;  /* wave speed */

/* distance for wave to travel for leading edge to stop at 0.85 */
static	const double	dist = 0.6;
static	const double	tlen = dist / c;  /* distance / speed */

/* 1D mesh spatial parameters */
static	const double	xlen = 1.0;
/*static 	const double	dx = 0.01;*/
static 	const double	dx = 0.0001; /* used for implicit example */
static	const int		numi = (xlen / dx) + 1;

/*****************************************************************************/
/* function: cfd */
/* inputs:
 *  nu = CFL number
 *  cn = case number: 1 = back diff, 2 = cent diff, 3 = cent diff - implicit
 *                    4 = Lax-Wendroff
 * */
/* outputs:
 * 	x = spatial mesh
 * 	u = solution values
 * 	*/
/*****************************************************************************/
static void cfd(double *x, double *u, double nu, int cn) {
	/* locals */
	int i,n;

	/* temporary sln array for u at time n+1 */
	double utmp[numi];

	/* tridiag Thomas algorithm variables (keeping numi elements for ease of indexing) */
	double a[numi], d[numi], b[numi], C[numi];
	const int M = numi - 2;

	/* 1D mesh time parameters: restricted by c and nu */
	double	dt = nu * dx / c; /* stability restriction */
	int		numt = tlen / dt;

	/* generate 1D mesh */
	for (i = 0; i < numi; i++)
		x[i] = i * dx;

	/* initialize solution for square wave */
	for (i = 0; i < numi; i++) {
		if (x[i] >= 0.1 && x[i] <= 0.25)
			u[i] = 1.0;
		else
			u[i] = 0.0;
	}

	/* boundary conditions */
	utmp[0] = utmp[numi-1] = 0.0;

	/* case 1: backward spatial diff, forward time, explicit */
	if (cn == 1) {
		/* CFL 1.3 is unstable, so change the number of steps to run */
		if (nu == 1.3)
			numt = 20;

		/* main time loop */
		for (n = 0; n < numt; n++) {
			/* loop mesh and perform diff filling temp sln */
			for (i = 1; i < (numi - 1); i++)
				utmp[i] = u[i] - nu * (u[i] - u[i-1]);

			/* copy temp solution to full solution */
			for (i = 0; i < numi; i++)
				u[i] = utmp[i];	
		}	
	}	
	/* case 2: central spatial diff, forward time, explicit */
	else if (cn == 2) {
		/* reset numt to get something to plot */
		/*numt = 2;*/

		for (n = 0; n < numt; n++) {
			/* loop mesh and perform diff filling temp sln */
			for (i = 1; i < (numi - 1); i++)
				utmp[i] = u[i] - (nu/2) * (u[i+1] - u[i-1]);

			/* copy temp solution to full solution */
			for (i = 0; i < numi; i++)
				u[i] = utmp[i];	
		}	
	}
	/* case 3: central spatial diff, implicit */
	/* implementing Thomas algorithm for tridiag matrix solve (Tannehill 4.1.4) */
	/* FDA: a*u[i+1] + d*u[i] + b*u[i-1] = C[i]
	 * where a = nu/2, d = 1, b = -nu/2 (unknown coeffs at time n+1)
	 *       C = u[i] (known sln value at time n) */
	else if (cn == 3) {
		for (n = 0; n < numt; n++) {
			/* fill diagonals and known C in original tridiagonal matrix form */
			for (i = 0; i < numi; i++) {
				/* diagonals */
				a[i] = nu/2;
				d[i] = 1;
				b[i] = -nu/2;

				/* known sln values at time n */
				/* utmp is sln at time n+1, u is sln at time n */
				if (i == 0 || i == (M+1)) 
					C[i] = utmp[i]; /* boundary conditions */
				else if (i == 1)
					C[1] = u[1] - b[0]*utmp[0];
				else if (i == M)
					C[M] = u[M] - a[M+1]*utmp[M+1];
				else
					C[i] = u[i];
			}

			/* put into upper diagonal form */
			for (i = 2; i <= M; i++) {
				d[i] = d[i] - (b[i] / d[i-1]) * a[i-1];
				C[i] = C[i] - (b[i] / d[i-1]) * C[i-1];
			}

			/* compute unknowns in C using back substitution */
			utmp[M] = C[M] / d[M];
			for (i = M-1; i >= 1; i--) {
				utmp[i] = (C[i] - a[i] * utmp[i+1]) / d[i];
			}

			/* copy temp solution to full solution */
			for (i = 0; i < numi; i++)
				u[i] = utmp[i];	
		}
	}
	/* case 4: Lax-Wendroff scheme */
	else if (cn == 4) {
		/* CFL 1.3 is unstable, so change the number of steps to run */
		if (nu == 1.3)
			numt = 20;

		/* main time loop */
		for (n = 0; n < numt; n++) {
			/* loop mesh and perform diff filling temp sln */
			for (i = 1; i < (numi - 1); i++)
				utmp[i] = u[i] - (nu/2) * (u[i+1] - u[i-1]) + (pow(nu,2) / 2) * (u[i+1] - 2*u[i] + u[i-1]);

			/* copy temp solution to full solution */
			for (i = 0; i < numi; i++)
				u[i] = utmp[i];	
		}
	}
}

/*****************************************************************************/
/* main */
/* simulate matlab code calling cfd */
/*****************************************************************************/
/*int main()*/
/*{*/
	/*double nu = 0.4;*/
	/*int cn = 3;*/
	/*double *x = (double *) malloc(numi * sizeof(double));*/
	/*double *u = (double *) malloc(numi * sizeof(double));*/

	/*cfd(x, u, nu, cn);*/

	/*free(x);*/
	/*free(u);*/

	/*return 0;*/
/*}*/

/* gateway function for matlab, build with mex and call cfd
 * build in matlab: mex -g cfd.c -r2018a
 * call like this: [x, u] = cfd(nu, cn);
 * nlhs = num outputs, nrhs = num inputs
 * plhs = array of ptrs to outputs, prhs = array of ptrs to inputs */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	/* input variables from matlab */
	double nu;
	int cn;
	
	/* output variables for matlab */
	double *x, *u;

	/* check for proper number of arguments */
	if (nrhs != 2) {
		mexErrMsgIdAndTxt( "MATLAB:cfd:invalidNumInputs", "Two input arguments required.");
	} else if (nlhs > 2) {
		mexErrMsgIdAndTxt( "MATLAB:cfd:maxlhs","Too many output arguments.");
	}

	/* get input CFL number and case number */
	nu = mxGetScalar(prhs[0]);
	cn = mxGetScalar(prhs[1]);

	/* create output matrices for mesh and solution */
	plhs[0] = mxCreateDoubleMatrix( (mwSize)1, (mwSize)numi, mxREAL);
	x = mxGetDoubles(plhs[0]);
	plhs[1] = mxCreateDoubleMatrix( (mwSize)1, (mwSize)numi, mxREAL);
	u = mxGetDoubles(plhs[1]);

	/* call cfd function */
	cfd(x, u, nu, cn);

	/*free(x);*/
	/*free(u);*/
	/* do we need to free up any of the mex created arrays here? */
	/* call mxDestroyArray somehow on this output variable? */

	return;
}
