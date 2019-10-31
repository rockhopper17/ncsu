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

/* tridiagonal Ax=b solver using Thomas algorithm */
/* modified for cubic spline not-a-knot */
/* includes c[0] and c[n] */
/* inputs: n = num data pts - 1, h = interval spacing (x[i+1] - x[i]) */
/*         fx = f(x) at known pts */
/* outputs: c = sln vec */
double *soltri(int n, double *h, double *fx)
{
	int i,j;
	double *c; /* ret val */
	double *a, *b, *d; /* above/below/diag tri diagonals */
	double *r; /* const vec for c matrix: Ac=r */

	c = (double *) malloc ((n+1) * sizeof(double)); /* c[0],...,c[n] */
	a = (double *) malloc ((n-1) * sizeof(double));
	b = (double *) malloc ((n-1) * sizeof(double));
	d = (double *) malloc ((n-1) * sizeof(double));
	r = (double *) malloc ((n-1) * sizeof(double));

	/* fill tridiagonals and const vec */
	for (i = 0; i < n-1; i++)
	{
		if (i == 0)
		{
			b[0] = 0;
			d[0] = (h[1]+h[0])*(h[0]+2*h[1])/h[1];
			a[0] = (h[1]+h[0])*(h[1]-h[0])/h[1];
		}
		else if (i == n-2)
		{
			b[n-2] = (h[n-2]+h[n-1])*(h[n-2]-h[n-1])/h[n-2];
			d[n-2] = (2*h[n-2]+h[n-1])*(h[n-1]+h[n-2])/h[n-2];
			a[n-2] = 0;
		}
		else
		{
			b[i] = h[i];
			d[i] = 2*(h[i]+h[i+1]);
			a[i] = h[i+1];
		}

		/* r[0] = r1 */
		r[i] = 3*((fx[i+2]-fx[i+1])/h[i+1] - (fx[i+1]-fx[i])/h[i]);
	}

	/* put into upper triangular form */
	for (i = 1; i < n-1; i++)
	{
		d[i] = d[i] - (b[i] / d[i-1]) * a[i-1];
		r[i] = r[i] - (b[i] / d[i-1]) * r[i-1];
	}

	/* compute unknowns (c) using back substitution */
	c[n-1] = r[n-2] / d[n-2];
	for (i = n-3; i >= 0; i--) {
		c[i+1] = (r[i] - a[i]*c[i+1+1]) / d[i];
	}

	/* c0,cn for not-a-knot */
	c[0] = ( (h[1]+h[0])*c[1] - h[0]*c[2] ) / h[1];
	c[n] = ( (h[n-1]+h[n-2])*c[n-1] - h[n-1]*c[n-2] ) / h[n-2];

	return c;
}

/* cubic spline interpolation using not-a-knot, equally spaced points */
/* inputs: n = num data pts - 1, x = knots (sample points), fx = values for f(x) */
/*         nint = num pts to eval, xint = x pts to eval (for plots) */
double *spline(int n, double x[], double fx[], int nint, double xint[])
{
	double *fxint; /* ret val: evaluation of spline at xint points */
	double *a, *b, *c, *d; /* cubic polynomial coeffecients 0,1,2,3 */
	double *h; /* interval spacing (x[i+1] - x[i]) */
	double xdiff; /* used to hold x-xi */
	int i, iint;

	fxint = (double *) malloc (nint * sizeof(double));

	a = (double *) malloc (n * sizeof(double));
	b = (double *) malloc (n * sizeof(double));
	c = (double *) malloc ((n+1) * sizeof(double)); /* c has one extra */
	d = (double *) malloc (n * sizeof(double));
	h = (double *) malloc (n * sizeof(double));

	/* build interval spacing h */
	for (i = 0; i < n; i++)
		h[i] = x[i+1] - x[i];

	/* solve for c coefficients */
	c = soltri(n, h, fx);

	/* calculate a,b,d coeffs from c's */
	for (i = 0; i < n; i++)
	{
		a[i] = fx[i];
		b[i] = ((fx[i+1]-fx[i])/h[i]) - ((h[i]/3)*(2*c[i]+c[i+1]));
		d[i] = (c[i+1]-c[i])/(3*h[i]);
	}

/* debugging */
double bnext = b[0] + 2*h[0]*c[0] + 3*h[0]*h[0]*d[0];
printf("first derivative continuity: b1=%f, bnext=%f\n",b[1],bnext);
double cnext = c[0] + 3*h[0]*d[0];
printf("second derivative continuity: c1=%f, cnext=%f\n",c[1],cnext);
printf("third derivative continuity: d0=%f, d1=%f,dn-1=%f,dn-2=%f\n",
		d[0],d[1],d[n-1],d[n-2]);

	/* interpolate using cubic polynomials */
	i = 0; /* interval / cubic index into a,b,c,d */
	for (iint = 0; iint < nint; iint++)
	{
		/* increment i if we are into the next interval */
		if (xint[iint] > x[i+1])
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

	free(a);
	free(b);
	free(c);
	free(d);
	free(h);

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

		/* call spline method to perform cubic not-a-knot spline */
		fxint = (double *) malloc (nint * sizeof(double));
		fxint = spline(n, x, fx, nint, xint);

	}
	/* runge project pblm 2 */
	else if (tc == 2)
	{
		n = 4; /* num data pts - 1: 4(5), 9(10), 16(17), 32(33) */
		x = (double *) malloc ((n+1) * sizeof(double));
		fx = (double *) malloc ((n+1) * sizeof(double));
		for (i = 0; i < n+1; i++)
		{
			x[i] = -1 + (2*(double)i/(double)n);
			fx[i] = 1/(1+25*x[i]*x[i]);
		}
		nint = n*10; /* num of points to interpolate at */
		xint = (double *) malloc (nint * sizeof(double));
		for (i = 0; i < nint; i++)
		{
			xint[i] = -1 + (2*(double)i/((double)nint));
		}

		/* call spline method to perform cubic not-a-knot spline */
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
