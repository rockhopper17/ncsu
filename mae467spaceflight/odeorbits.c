#include <stdlib.h>
#include <math.h>
#include "mex.h"

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

/* icval == 1: orig inner planets with rocket to mars from mae361 */
static	const int		n = 6;				/* number of bodies total */
static	const int		ndim = 2;			/* num dimensions (2D: x,y) */
static 	const double	deltaT = 1*3600;	/* step time in hrs * sec/hr = sec */
static 	const int		runtime = 30;		/* num seconds to run scenario */
static	const int		N = 2*365*(24*3600)/deltaT;  /* num steps days * (hrs/day * s/hr) */
/* mass values [kg] */
static	const double	m[] = {1.9885e30,3.302e23,4.869e24,5.974e24,6.419e23,358};	

/* icval == 2: ex 2.2 2D */
/*static	const int		n = 2;				[> number of bodies total <]*/
/*static	const int		ndim = 2;			[> num dimensions (2D: x,y) <]*/
/*static 	const double	deltaT = 0.025;		[> step time in seconds <]*/
/*static 	const int		runtime = 480;		[> num seconds to run scenario <]*/
/*static	const int		N = runtime / deltaT;	[> total number of iterations to run integration <]*/
/*static	const double	m[] = {1e26,1e26};	[> mass values [kg] <]*/

/* icval == 3: ex 2.2 full 3D */
/*static	const int		n = 2;				[> number of bodies total <]*/
/*static	const int		ndim = 3;			[> num dimensions (2D: x,y) <]*/
/*static 	const double	deltaT = 0.025;		[> step time in seconds <]*/
/*static 	const int		runtime = 480;		[> num seconds to run scenario <]*/
/*static	const int		N = runtime / deltaT;	[> total number of iterations to run integration <]*/
/*static	const double	m[] = {1e26,1e26};	[> mass values [kg] <]*/

/* HW2 */ 
/*static	const int		n = 2;*/
/*static	const int		ndim = 3;*/
/*static 	const double	deltaT = 0.25;*/
/*static 	const int		runtime = 4*3600;*/
/*static	const int		N = runtime / deltaT;*/
/*static	const double	m[] = {5.974e24,1000};*/

/* additional constants */
static	const double	G = 6.67259e-20;	/* universal gravitational constant (km^3/kg/s^2) */
static 	const int		nvals = 2*n*ndim;	/* total number of values in x and f arrays (state space vector) */

/* todo: init all variables used as statics so they aren't reinitialized on each call to functions */
/* see if this will be too big for stack or not */

/* todo: convert logic to using the mu and r^3 vesion of 2nd order ode */

static void orbits_state(double f[], double x2[]) {
	/*for (int i = 0; i < nvals; i++) {*/
		/*f[i] = x2[i]/2;*/
	/*}*/
    /*% f holds the state equations, which are dot and double dot values*/
    /*% velocity / first derivatives (x dot, y dot, z dot] go in the first half of f*/
    /*% acceleration / second derivatives are calculated below*/
	
	int i,j,k;
	double sumk, sumj;
	
	/*% distance between bodies and corresponding unit vectors*/
	/*% r(i,j) = distance from ith body to jth body*/
	/*% e(i,j,[x/y/z]) = unit vector for x/y/z dir from ith body to jth body*/
	double r[n][n] = {0}; 
	double e[n][n][ndim] = {0}; 
	
	for (i = 0; i < n*ndim; i++)
		f[i] = x2[n*ndim + i];
	for (i = n*ndim; i < nvals; i++)
		f[i] = 0;

	for (i = 0; i < n; i++) {
		for (j = 0; j < n; j++) {
			/*%r(i,j) = norm( x((i-1)*ndim+[1:ndim]) - x((j-1)*ndim+[1:ndim]) );*/
			/*%e(i,j,[1:ndim]) = (x((j-1)*ndim+[1:ndim]) - x((i-1)*ndim+[1:ndim])) / r(i,j);*/
			/*%if i == j we are on the same body, so just keep the 0 value alredy in there*/
			if (i != j) {
				sumk = 0;
				for (k = 0; k < ndim; k++)
					sumk += pow(x2[i*ndim+k] - x2[j*ndim+k], 2);
				r[i][j] = sqrt(sumk);
				
				/*%could still have distance = 0, for example rocket following earth for awhile*/
				if (r[i][j] != 0) {
					for (k = 0; k < ndim; k++)
						e[i][j][k] = (x2[j*ndim+k] - x2[i*ndim+k]) / r[i][j];
				}
			}
		}
	}

    /*% acceleration / second derivatives [x double dot, y double dot]*/
    /*% derived from Newton: F = m1 a1 = G m1 m2 / r^2 => a1 = G m2 / r^2*/
	for (i = 0; i < n; i++) {
		/*%f(ndim*n+((i-1)*ndim+[1:ndim])) = sum(G*m.*e(i,:,1:ndim)./r(i,:).^2,'omitnan');*/
		for (k = 0; k < ndim; k++) {
			sumj = 0;
			for (j = 0; j < n; j++) {
				if (i != j && r[i][j] != 0)
					sumj += ((G * m[j] * e[i][j][k]) / pow(r[i][j], 2));
			}
			f[ndim*n+(i*ndim+k)] = sumj;
		}
	}
}

/* todo: pass function pointer to call instead of hard coded orbits_state */
static void rk4(double xnew[], double xt[]) {
	int i;
	double f1[nvals], f2[nvals], f3[nvals], f4[nvals];
	double x2[nvals];

	/* init x2 */
	for (i = 0; i < nvals; i++)
		x2[i] = xt[i];

	/* perform rk4 steps */
	orbits_state(f1, x2);

	for (i = 0; i < nvals; i++)
		x2[i] = xt[i] + (0.5 * deltaT * f1[i]);
	orbits_state(f2, x2);

	for (i = 0; i < nvals; i++)
		x2[i] = xt[i] + (0.5 * deltaT * f2[i]);
	orbits_state(f3, x2);

	for (i = 0; i < nvals; i++)
		x2[i] = xt[i] + (deltaT * f3[i]);
	orbits_state(f4, x2);

	/* set output variable xnew */
	for (i = 0; i < nvals; i++)
		xnew[i] = xt[i] + (deltaT / 6) * (f1[i] + 2*f2[i] + 2*f3[i] + f4[i]);
}

static void odeorbits(double *t, double *x, double xt[]) {
	int i,j;
	double xnew[nvals];

	/* initialize x2 with x0 values */
	/*for (i = 0; i < nvals; i++)*/
		/*x2[i] = x0[i];*/

	/* initialize t and x */
	/* access x[r][c] like x[r * nvals + c] */
	t[0] = 0;
	for (j = 0; j < nvals; j++)
		/**(x + j*sizeof(double)) = xt[j];*/
		x[0*nvals + j] = xt[j];

	/* loop all time values and call rk4 */
	for (i = 1; i < N; i++) {
		rk4(xnew, xt);

		t[i] = i * deltaT;

		for (j = 0; j < nvals; j++) {
			/**(x + i*nvals*sizeof(double) + j*sizeof(double)) = xnew[j];*/
			x[i*nvals + j] = xnew[j];
			xt[j] = xnew[j];
		}

		/* inject impulsive delta V for inner sol rocket scenario*/
		/*if (i == 8000) {*/
			/*xt[22] += 2.75;  [> add a 3 km/s burn in x dir <]*/
			/*xt[23] -= 3.5;  [> add a 3 km/s burn in x dir <]*/
		/*}*/
	}	
}

/* main */
/*int main()*/
/*{*/
	/*double xt[] = {0,0,0,3000,0,0,10,20,30,0,40,0};*/

	/*double *t = (double *) malloc(N * sizeof(double));*/
	/*double *x = (double *) malloc(N * nvals * sizeof(double));*/

	/*odeorbits(t, x, xt);*/

	/*free(t);*/
	/*free(x);*/

	/*return 0;*/
/*}*/

/* gateway function for matlab, build with mex and call orbits_state
 * nlhs = num outputs, nrhs = num inputs
 * plhs = array of ptrs to outputs, prhs = array of ptrs to inputs */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	/* locals */
	double xt[nvals];
	double *t, *x, *xtptr;
	size_t m,n;

	/* check for proper number of arguments */
	if (nrhs != 1) {
		mexErrMsgIdAndTxt( "MATLAB:odeorbits:invalidNumInputs", "One input argument required.");
	} else if (nlhs > 2) {
		mexErrMsgIdAndTxt( "MATLAB:odeorbits:maxlhs","Too many output arguments.");
	}

	/* check to make sure the first input argument is a real matrix */
	if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
	  mexErrMsgIdAndTxt( "MATLAB:odeorbits:invalidX", "First input argument must be a real matrix.");
	}

	/* check the dimensions of xt, it must match nvals */
	m = mxGetM(prhs[0]);
	n = mxGetN(prhs[0]);
	if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxIsSparse(prhs[0]) ||
	(MAX(m,n) != nvals) || (MIN(m,n) != 1)) {
		mexErrMsgIdAndTxt( "MATLAB:odeorbits:invalid_xt", "odeorbits requires that xt be a 2*n*ndim x 1 vector.");
	}

	/* get input */
	xtptr = mxGetDoubles(prhs[0]);
	for (int i = 0; i < nvals; i ++)
		xt[i] = xtptr[i];

	/* create output matrices */
	plhs[0] = mxCreateDoubleMatrix( (mwSize)1, (mwSize)N, mxREAL);
	t = mxGetDoubles(plhs[0]);
	plhs[1] = mxCreateDoubleMatrix( (mwSize)1, (mwSize)N*nvals, mxREAL);
	x = mxGetDoubles(plhs[1]);

	/*double *t = (double *) malloc(N * sizeof(double));*/
	/*double *x = (double *) malloc(N * nvals * sizeof(double));*/

	odeorbits(t, x, xt);

	/*free(t);*/
	/*free(x);*/
	/* do we need to free up any of the mex created arrays here? */
	/* call mxDestroyArray somehow on this output variable? */

	return;
}
