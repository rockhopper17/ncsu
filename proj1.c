/* Andrew Navratil */
/* MAE 495 Numerical Methods - Luo */
/* Cubic Spline Project */
/* Due 11/4/19 */

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <time.h>
#include <gsl/gsl_linalg.h>

int numiter;

/* vector norm (L2 norm) */
double norm(int n, double xv[])
{
	double retval = 0;

	for (int i = 0; i < n; i++)
		retval += xv[i]*xv[i];

	return sqrt(retval);
}

/* vector transposed multiplied by vector */
double vecTvecmult(int n, double vecT[], double vec[])
{
	int i;
	double retval;

	retval = 0.0;

	for (i = 0; i < n; i++)
		retval += vecT[i]*vec[i];
	
	return retval;
}

/* tridiagonal CG method A*p multiplier for cubic spline */
/* with equally spaced points */
/* see Luo lecture 3a slide 39 */
/* inputs: n = num pts - 2, h = pt spacing, p = CG method p vec */
/* output: A*p values where A is the c coeff matrix */
double *trimatvec(int n, double h, double p[])
{
	double *ap; /* ret val Ap vec */
	int i, j, idiag;

	ap = (double *) malloc (n * sizeof(double));

	/* not-a-knot gives values for c(1) and c(n-1) */
	ap[0] = 6*h * p[0];
	ap[n-1] = 6*h * p[n-1];
	/*ap[0] = h * p[0] + 2*h * p[1];*/
	/*ap[n-1] = 2*h * p[n-2] + h * p[n-1];*/

	/*for (i = 1; i < n-1; i++)*/
		/*ap[i] = 0.0;*/

	/* not-a-knot equal spacing specific A (or c) matrix */
	/* see whiteboard pic for matrix derivation */
	for (idiag = 1; idiag < n-1; idiag++)
	{
		ap[idiag] = 4*h * p[idiag];
		ap[idiag] += ((h * p[idiag-1]) + (h * p[idiag+1]));
	}

	return ap;
}

/* conjugate gradient method to solve Ax=b */
/* see Luo lecture 9 slide 5 */
/* inputs: n = num pts - 1, h = pt spacing, b = sln vector */
/* output: x = sln for c(1) through c(n-1) */
/* note: no longer pass A mat, we will use cubic spline tridiag multiplier */
/* note: values for c(0) and c(n) are set by calling code */
/*       depending on specific cubic spline being performed */
double *solcg(int n, double h, double b[])
{
	double *x, *r, *p, *ap;
	double alpha, beta, eps, rr, r0eps, reps;
	int i, k, maxit;

	x = (double *) malloc (n * sizeof(double)); /* c(1),..., c(n-1) */
	r = (double *) malloc (n * sizeof(double));
	p = (double *) malloc (n * sizeof(double));
	ap = (double *) malloc (n * sizeof(double));

	/* max iterations and convergence tolerence */
	maxit = 1e3;
	/*eps = 1e-6;*/
	eps = 1e-3;

	/* initialize x, r, p (for k=0) */
	for (k = 0; k < n; k++)
	{
		x[k] = 0.0; /* init guess: x = 0 */
		r[k] = -b[k]; /* Ax=0 so r=Ax-b=-b */
		p[k] = -r[k];
	}

	/* set baseline err tolerance */
	r0eps = eps * norm(n,r);

	/* perform cg loop */
	for (k = 1; k < maxit; k++)
	{
		/* save r(k-1) product since we need it after r(k+1) */
		rr = vecTvecmult(n,r,r); 
		ap = trimatvec(n,h,p); /* cubic spline specific multiplier */
		
		alpha = rr / vecTvecmult(n,p,ap);
		
		for (i = 0; i < n; i++)
			x[i] += alpha * p[i];

		for (i = 0; i < n; i++)
			r[i] += alpha * ap[i];

		free(ap);

		beta = vecTvecmult(n,r,r) / rr;

		for (i = 0; i < n; i++)
			p[i] = beta * p[i] - r[i];

		reps = norm(n,r);
		printf("iteration %d, r0eps=%f, reps=%f\n",k,r0eps,reps);

		if (reps < r0eps)
			break;
	}

	numiter = k;

	free(r);
	free(p);

	return x;
}

/* cubic spline interpolation using not-a-knot, equally spaced points */
/* inputs: n = num data pts - 1, x = knots (sample points), fx = values for f(x) */
/*         nint = num pts to eval, xint = x pts to eval (for plots) */
double *spline(int n, double x[], double fx[], int nint, double xint[])
{
	double *fxint; /* ret val: evaluation of spline at xint points */
	double *a, *b, *c, *d; /* coeffecients 0,1,2,3 */
	double *ctmp; /* temp c vector to hold result from tri diag solve (n-1 pts) */
	double h; /* spacing for equally spaced points */
	double *r; /* sln vector for c matrix */
	double xdiff; /* used to hold x-xi */
	int i, iint;

	fxint = (double *) malloc (nint * sizeof(double));

	a = (double *) malloc (n * sizeof(double));
	b = (double *) malloc (n * sizeof(double));
	c = (double *) malloc ((n+1) * sizeof(double));
	ctmp = (double *) malloc ((n-1) * sizeof(double));
	d = (double *) malloc (n * sizeof(double));

	/* assume x is ordered and equally spaced */
	h = x[1] - x[0];

	/* build the c sln vec r */
	r = (double *) malloc ((n-1) * sizeof(double));
	for (i = 0; i < n-1; i++)
	{
		/* r indexing actually starts at 1, not 0, for these values */
		/* r(0) in actual vector = r(1) from algorithm */
		r[i] = (3*fx[i+2] + 6*fx[i+1] + 3*fx[i]) / h;
	}

	/* use conjugate gradient solver for Ax=b */
	/* CG method will call the spline specific tridiag multiplier */
	ctmp = solcg(n-1,h,r);
	/*ctmp = (double[]){2.62864721485411,5.5132625994695,2.62864721485411};*/

	/* fill in the full c coeff vec */
	/* ctmp[0] = c[1], ctmp[n-2] = c[n-1] where num in ctmp = n-1 */
	c[0] = 2*ctmp[0] - ctmp[1];
	c[n] = 2*ctmp[n-2] - ctmp[n-3];

	for (i = 1; i < n; i++)
		c[i] = ctmp[i-1];

	/* calculate the coefficient vectors */
	/*b[0] = ((fx[0+1]-fx[0])/h) - ((h/3)*(2*c[0]+c[0+1]));*/
	for (i = 0; i < n; i++)
	{
		a[i] = fx[i];
		b[i] = ((fx[i+1]-fx[i])/h) - ((h/3)*(2*c[i]+c[i+1]));
		/*if (i > 0)*/
			/*b[i] = b[i-1] + 2*h*c[i-1] + 3*h*h*d[i-1];*/
		d[i] = (c[i+1]-c[i])/(3*h);
	}

	/* interpolate using cubic polynomials */
	i = 0; /* interval / cubic index into a,b,c,d */
	for (iint = 0; iint < nint; iint++)
	{
		/* increment i if we are into the next interval */
		if (xint[iint] >= x[i+1])
		{
			i++;

			/* bounds check in case xint goes beyond x */
			if (i > n+1)
				break; 
		}

		/* interpolating spline */
	   	/* si(x) = ai + bi(x-xi) + ci(x-xi)^2 + di(x-xi)^3 */ 
		xdiff = xint[iint]-x[i];
		fxint[iint] = a[i] + b[i]*xdiff + c[i]*pow(xdiff,2) + d[i]*pow(xdiff,3);
	}

	/* debugging */
	/* see Luo lect 3a slide 37 */
	double bnext = b[0] + 2*h*c[0] + 3*h*h*d[0];
	printf("first derivative continuity: b1=%f, bnext=%f\n",b[1],bnext);
	double cnext = c[0] + 3*h*d[0];
	printf("second derivative continuity: c1=%f, cnext=%f\n",c[1],cnext);
	printf("third derivative continuity: d0=%f, d1=%f,dn-1=%f,dn-2=%f\n",
			d[0],d[1],d[n-1],d[n-2]);

	free(a);
	free(b);
	free(c);
	free(ctmp);
	free(d);

	return fxint;
}

/* main */
int main()
{
	int i, j;
	int n; /* num data pts = n+1 */
	double *x; /* knot x values (data points) */
	double *fx; /* f(x) known values for knots */
	int nint; /* num data pts to interpolate at (finer than n) */
	double *xint; /* x values for interpolation */
	double *fxint; /* interpolated values for plotting */
	FILE *fout; /* used for saving data to file for plotting */
	char fname[50]; /* filename */
	int tc; /* test case */
	
	/* 1=sin, 2=runge */
	tc = 2;

	/* test input: using sin curve from 0 to 2pi */
	if (tc == 1)
	{
		n = 8; /* 9 data pts */
		x = (double *) malloc ((n+1) * sizeof(double));
		fx = (double *) malloc ((n+1) * sizeof(double));
		for (i = 0; i < n+1; i++)
		{
			x[i] = i*M_PI/4;
			fx[i] = sin(x[i]);
		}
		nint = 33; /* actual num of points to interpolate at */
		xint = (double *) malloc (nint * sizeof(double));
		for (i = 0; i < nint; i++)
		{
			xint[i] = i*M_PI/16;
		}

		/* call spline method to perform cubic not-a-know spline */
		fxint = (double *) malloc (nint * sizeof(double));
		fxint = spline(n, x, fx, nint, xint);

	}
	/* runge project pblm 2 */
	else if (tc == 2)
	{
		n = 4; /* 5 data pts */
		x = (double *) malloc ((n+1) * sizeof(double));
		fx = (double *) malloc ((n+1) * sizeof(double));
		for (i = 0; i < n+1; i++)
		{
			x[i] = -1 + (2*(double)i/(double)n);
			fx[i] = 1/(1+25*x[i]*x[i]);
		}
		nint = 33; /* actual num of points to interpolate at */
		xint = (double *) malloc (nint * sizeof(double));
		for (i = 0; i < nint; i++)
		{
			xint[i] = -1 + (2*(double)i/((double)nint-1));
		}

		/* call spline method to perform cubic not-a-know spline */
		fxint = (double *) malloc (nint * sizeof(double));
		fxint = spline(n, x, fx, nint, xint);
	}

	/* save xint and fxint to file for plotting */
	snprintf(fname, sizeof(fname), "spline%d.txt",n);
	fout = fopen(fname, "w+t");
	for (i = 0; i < nint; i++)
		fprintf(fout, "%f,%f\n",xint[i],fxint[i]);
	fclose(fout);

	free(x);
	free(fx);
	free(xint);
	free(fxint);

	return 0;
}
