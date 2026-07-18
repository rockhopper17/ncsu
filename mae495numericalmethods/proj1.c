/* Andrew Navratil */
/* MAE 495 Numerical Methods - Luo */
/* Cubic Spline Project */
/* Due 11/4/19 */

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <time.h>

/* debug flag - comment out to turn off debug printf's */
#define DEBUG

const int numopts = 4; /* num of different num of points to try */

/* linear least squares fit */
/* inputs: y = L2 norm of errors, x = interval spacing */
/* outputs: writes log10 of x,y, and linear polynomial coeffs to file for plotting */
void leastsq(double y[numopts], double x[numopts])
{
	double a, b; /* polynomial coeffs 0,1 */
	double xi, yi, xyi, xi2; /* sums for least squares min calc */
	double lx, ly; /* hold value of log10 x and y */
	FILE *fout; /* used for saving values to file for plotting */
	int i;

	xi = 0;
	yi = 0;
	xyi = 0;
	xi2 = 0;

	fout = fopen("err.txt", "w+t");

	for (i = 0; i < numopts; i++)
	{
		lx = log10(x[i]);
		ly = log10(y[i]);

		xi += lx; /* sum of x values */
		yi += ly; /* sum of y values */
		xyi += lx*ly; /* sum of x*y values */
		xi2 += lx*lx; /* sum of x^2 values */

		fprintf(fout,"%lf,%lf\n",ly,lx); 
	}

	a = (xi2*yi - xyi*xi) / (numopts*xi2 - (xi*xi)); /* 0 (const) coeff */
	b = (numopts*xyi - xi*yi) / (numopts*xi2 - (xi*xi)); /* 1st order coeff */

#ifdef DEBUG
	printf("\nslope of log error = %lf\n",b);
#endif

	fprintf(fout,"%lf,%lf\n",b,a); 
	fclose(fout);
}


/* numerical integration: gauss quadrature */
double numintgauss(double xa, double xb, double d, double c, double b, double a)
{
	double x, v, intval; /* transformed x value, dx value (v), ret val */
	double p, r; /* polynomial and runge results */
	int i;
	
	/* Gauss points and weights: 4 point quadrature */
	double t[4] = {-0.86113631, -0.33998104, 0.33998104, 0.86113631};
	double w[4] = {0.3478548, 0.6521452, 0.6521452, 0.3478548};

	intval = 0;

	for (i = 0; i < 4; i++)
	{
		x = 0.5*(t[i]*(xb-xa)+xa+xb); /* transform x using gauss pt */
		v = 0.5*(xb-xa)*w[i]; /* transform dx and multiply by weight */
		p = d*pow(x,3) + c*pow(x,2) + b*x + a; /* polynomial eval w new x */
		r = 1/(1+25*pow(x,2)); /* runge eval w new x */
		intval += pow((p-r),2) * v; /* putting it all together */
	}

	return intval;
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

	free(a);
	free(b);
	free(d);
	free(r);

	return c;
}

/* cubic spline interpolation using not-a-knot */
/* inputs: n = num data pts - 1, x = knots (sample points), fx = values for f(x) */
/* outputs: L2 error norm and writes coeffs to data file for plotting */
double spline(int n, double x[], double fx[], char fname[50])
{
	double *a, *b, *c, *d; /* cubic polynomial coeffecients 0,1,2,3 */
	double *h; /* interval spacing (x[i+1] - x[i]) */
	FILE *fout; /* used for saving coefficients to file for plotting */
	double aval,bval,cval,dval; /* calculated coeffecients */
	double intsum; /* sum of gauss quadrature integrals */
	double sival; /* used to check cubic evaluated at end points */
	int i;

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

#ifdef DEBUG
	printf("\nfname = %s, n = %d\n",fname,n);
	double bnext = b[0] + 2*h[0]*c[0] + 3*h[0]*h[0]*d[0];
	printf("first derivative continuity: b1=%lf, bnext=%lf\n",b[1],bnext);
	double cnext = c[0] + 3*h[0]*d[0];
	printf("second derivative continuity: c1=%lf, cnext=%lf\n",c[1],cnext);
	printf("third derivative continuity: d0=%lf, d1=%lf\n\t\t\tdn-1=%lf,dn-2=%lf\n",
			d[0],d[1],d[n-1],d[n-2]);
#endif

	/* save x, fx, and calculated coeffs to file */
	/* calculate L2-norm of error using gauss quadrature for integral */
	fout = fopen(fname, "w+t");
	intsum = 0;
	for (i = 0; i < n; i++)
	{
		dval = d[i];
		cval = c[i] - 3*d[i]*x[i];
		bval = b[i] - 2*c[i]*x[i] + 3*d[i]*pow(x[i],2);
		aval = a[i] - b[i]*x[i] + c[i]*pow(x[i],2) - d[i]*pow(x[i],3);
		fprintf(fout, "%lf,%lf,%lf,%lf,%lf,%lf\n",x[i],fx[i],dval,cval,bval,aval);

		/* call guass quadrature to perform integral for error calc */
		intsum += numintgauss(x[i],x[i+1],dval,cval,bval,aval);
	}

	/* save last pt x and fx, and l2 error norm in 3rd column */
	/* todo: look at saving more sig figs in mantissa, currently 6 */
	intsum = sqrt(intsum);
	fprintf(fout,"%lf,%lf,%lf,%lf,%lf,%lf\n",x[i],fx[i],intsum,0.0,0.0,0.0); 
	fclose(fout);

#ifdef DEBUG
	printf("L2 error norm = %lf\n",intsum);
#endif

	free(a);
	free(b);
	free(c);
	free(d);
	free(h);

	return intsum;
}

/* main */
int main()
{
	int i, j;
	int n; /* num data pts = n+1, num intervals = n */
	double *x; /* knot x values (data points) */
	double *fx; /* f(x) known values for knots */
	double l2norm[numopts]; /* L2 error norms */
	double h[numopts]; /* interval spacing for each n */
	char fname[50]; /* filename */
	
	/* num intervals(num data pts): 4(5), 8(9), 16(17), 32(33) */
	double nvals[numopts] = {4,8,16,32}; /* num data pts = n + 1 */

	/* unit circle x and f(x) values */
	double l2normc;
	double sq2 = sqrt(2)/2;
	double xc[9] = {1, sq2, 0, -sq2, -1, -sq2, 0, sq2, 1};
	double fxc[9] = {0, sq2, 1, sq2, 0, -sq2, -1, -sq2, 0};
	double tc[9] = {0,1,2,3,4,5,6,7,8};

	for (j = 0; j < numopts; j++)
	{
		n = nvals[j]; 
		snprintf(fname, sizeof(fname), "spline%d.txt",n);

		/* build x and fx for runge func on interval -1 to 1 */
		/* could optimize this better for loop */
		/* maybe allocate largest possible one time */
		x = (double *) malloc ((n+1) * sizeof(double));
		fx = (double *) malloc ((n+1) * sizeof(double));
		for (i = 0; i < n+1; i++)
		{
			x[i] = -1 + (2*(double)i/(double)n);
			fx[i] = 1/(1+25*x[i]*x[i]); /* runge */
		}

		/* call cubic spline not-a-knot function */
		/* it will write coeffs to data file for plotting */
		l2norm[j] = spline(n, x, fx, fname);
		h[j] = x[1] - x[0]; /* assume equal spacing for runge */

		free(x);
		free(fx);
	}

	/* run linear least squares fit on log base 10 values */
	/* log10(error) vs log10(interval spacing) */
	/* func will write data to file for plotting */
	leastsq(l2norm,h);
	
	/* unit circle */
	/* see dd_splines.pdf: 7. a nonparametri version */
	n = 8;

	snprintf(fname, sizeof(fname), "spline%ducx.txt",n);
	l2normc = spline(n, tc, xc, fname);

	snprintf(fname, sizeof(fname), "spline%ducy.txt",n);
	l2normc = spline(n, tc, fxc, fname);

	return 0;
}
