/* Andrew Navratil */
/* MAE 495 Numerical Methods */
/* Midterm Exam Due 10/23/19 */

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <time.h>

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

/* symmetric matrix vector multiplication */
/* mat stored as upper tri row major order in a */
/* a1 a2 a3 a4 */
/* *  a5 a6 a7 */
/* *  *  a8 a9 */
/* *  *  *  a10*/
double *symmatvec(int n, double a[], double x[])
{
	double *b, bval;
	int i, j, idiag;

	b = (double *) malloc (n * sizeof(double));

	for (i = 0; i < n; i++)
		b[i] = 0.0;

	/* walk upper diag only accessing each a element once */
	/* but do the corresponding mult/sum as if full symm mat */
	/* add the item for the row then the col (see whiteboard pic) */
	i = 0;
	for (idiag = 0; idiag < n; idiag++)
	{
		for (j = idiag; j < n; j++)
		{
			/* do mult once to get bval on stack since a,x on heap */
			/*bval = a[i++]*x[j]; [> increment i here, only place <]*/
			/*if (j != idiag) b[idiag] += bval;*/
			/*b[j] += bval;*/
			if (j != idiag) b[idiag] += a[i]*x[j];
			b[j] += a[i++]*x[idiag];
		}
	}

	/*for (i = 0; i < n; i++)*/
		/*for (j = 0; j < n; j++)*/
			/*b[i] += a[i*n+j]*x[j];*/

	return b;
}

/* conjugate gradient method to solve Ax=b */
/* see Luo lecture 9 slide 5 */
double *solcg(int n, double a[], double b[])
{
	double *x, *r, *p, *ap;
	double alpha, beta, eps, rr, r0eps;
	int i, k, maxit;

	x = (double *) malloc (n * sizeof(double)); /* retval */
	r = (double *) malloc (n * sizeof(double));
	p = (double *) malloc (n * sizeof(double));
	ap = (double *) malloc (n * sizeof(double));

	/* max iterations and convergence tolerence */
	maxit = 1e6;
	eps = 1e-6;

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
		rr = vecTvecmult(n,r,r);
		ap = symmatvec(n,a,p);
		
		alpha = rr / vecTvecmult(n,p,ap);
		
		for (i = 0; i < n; i++)
			x[i] += alpha * p[i];

		for (i = 0; i < n; i++)
			r[i] += alpha * ap[i];

		free(ap);

		beta = vecTvecmult(n,r,r) / rr;

		for (i = 0; i < n; i++)
			p[i] = beta * p[i] - r[i];
		
		if (norm(n,r) < r0eps)
			break;
	}

	free(r);
	free(p);

	return x;
}

/* main */
int main()
{
	int n, i, j, idiag, pblm;
	double *a, *x, *b;
	clock_t t;

	pblm = 2; /* exam problem number: 2-2 = 2, 2-3 = 3 */

	/* exam problem 2-2 */
	if (pblm == 2)
	{
		n = 3;

		x = (double *) malloc (n * sizeof(double));
		b = (double *) malloc (n * sizeof(double));

		/* construct the test A mat */
		int N = (n * (n + 1)) / 2; /* num elements in upper tri */
		a = (double *) malloc (N * sizeof(double));
		i = 0;
		for (idiag = 0; idiag < n; idiag++)
			for (j = idiag; j < n; j++)
				a[i++] = 2 - (j - idiag);

		/*a = (double *) malloc (n*n * sizeof(double));*/
		/*for (i = 0; i < n; i++)*/
			/*for (j = 0; j < n; j++)*/
			/*{*/
				/*if (i == j)*/
					/*a[i*n+j] = 2;*/
				/*else if (i == (j-1) || i == (j+1))*/
					/*a[i*n+j] = 1;*/
				/*else*/
					/*a[i*n+j] = 0;*/
			/*}*/

		/* construct the test b vec */
		for (i = 0; i < n; i++)
			b[i] = 1;

		/* perform congjuage gradient to solve Ax=b */
		t = clock();
		x = solcg(n, a, b);
		t = clock() - t;
		
		double time_taken = ((double)t)/CLOCKS_PER_SEC; // in seconds 

		free(a);
		free(x);
		free(b);
	}

	return 0;
}
