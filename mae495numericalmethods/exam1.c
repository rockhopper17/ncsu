/* Andrew Navratil */
/* MAE 495 Numerical Methods */
/* Midterm Exam Due 10/23/19 */

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <time.h>

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

/* symmetric matrix vector multiplication */
/* mat stored as upper tri row major order in a */
/* a1 a2 a3 a4 */
/* *  a5 a6 a7 */
/* *  *  a8 a9 */
/* *  *  *  a10*/
/* doing this for general SPD case */
/* can optmize further for tridiag or even single value in diags */
double *symmatvec(int n, double a[], double x[])
{
	double *b, bval;
	int i, j, idiag;

	b = (double *) malloc (n * sizeof(double));

	for (i = 0; i < n; i++)
		b[i] = 0.0;

	/* walk upper diag only accessing each element once */
	/* but do the corresponding mult/sum as if full matrix */
	/* add the item for the row then the col (see whiteboard pic) */
	i = 0;
	for (idiag = 0; idiag < n; idiag++)
	{
		for (j = idiag; j < n; j++)
		{
			if (j != idiag) b[idiag] += a[i]*x[j];
			b[j] += a[i++]*x[idiag]; /* increment i here only */
		}
	}

	return b;
}

/* tridiagonal with single value matrix vector multiplication */
/* hard coded values for exam */
double *trimatvec(int n, double x[])
{
	double *b, bval;
	int i, j, idiag;

	b = (double *) malloc (n * sizeof(double));

	for (i = 0; i < n; i++)
		b[i] = 0.0;

	for (idiag = 0; idiag < n; idiag++)
	{
		b[idiag] += 2 * x[idiag];

		if (idiag == 0)
			b[idiag] += -1 * x[idiag+1];
		else if (idiag == (n-1))
			b[idiag] += -1 * x[idiag-1];
		else
			b[idiag] += ((-1 * x[idiag-1]) + (-1 * x[idiag+1]));
	}

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
	/*eps = 1e-5;*/

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
		if (n < 2000)
			ap = symmatvec(n,a,p); /* only save matrix-vector product */
		else
			ap = trimatvec(n,p); /* optimized for exam */
		
		alpha = rr / vecTvecmult(n,p,ap);
		
		for (i = 0; i < n; i++)
			x[i] += alpha * p[i];

		for (i = 0; i < n; i++)
			r[i] += alpha * ap[i];

		free(ap);

		beta = vecTvecmult(n,r,r) / rr;

		for (i = 0; i < n; i++)
			p[i] = beta * p[i] - r[i];
		
		printf("iteration %d\n",k);

		if (norm(n,r) < r0eps)
			break;
	}

	numiter = k;

	free(r);
	free(p);

	return x;
}

/* main */
int main()
{
	int n, N, i, j, idiag, pblm;
	double *a, *x, *b, *ih;
	clock_t t;
	double time_taken, h;
	FILE *fout;
	char fname[50];

	/* exam problem number: 2-2 = 2, 2-3 = 3 */
	pblm = 3; 

	/* exam problem 2-2 */
	if (pblm == 2)
	{
		n = 3;

		/* construct the test A mat in upper tri form only */
		N = (n * (n + 1)) / 2; /* num elements in upper tri */
		a = (double *) malloc (N * sizeof(double));
		i = 0;
		for (idiag = 0; idiag < n; idiag++)
			for (j = idiag; j < n; j++)
				a[i++] = 2 - (j - idiag);

		/* construct the test b vec */
		b = (double *) malloc (n * sizeof(double));
		for (i = 0; i < n; i++)
			b[i] = 1;

		/* perform congjuage gradient to solve Ax=b */
		x = (double *) malloc (n * sizeof(double));
		t = clock();
		x = solcg(n, a, b);
		t = clock() - t;
		
		time_taken = ((double)t)/CLOCKS_PER_SEC; // in seconds 

		free(a);
		free(x);
		free(b);
	}
	else if (pblm == 3)
	{
		/*n = 20;*/
		/*n = 200;*/
		/*n = 2e3;*/
		/*n = 2e4;*/
		/*n = 2e5;*/
		n = 2e6; /* takes long time */

		/* construct the test A mat in upper tri form only */
		if (n < 2000)
		{
			N = (n * (n + 1)) / 2; /* num elements in upper tri */
			a = (double *) malloc (N * sizeof(double));
			i = 0;
			for (idiag = 0; idiag < n; idiag++)
				for (j = idiag; j < n; j++)
				{
					if (j == idiag)
						a[i++] = 2;
					else if (j == idiag+1)
						a[i++] = -1;
					else
						a[i++] = 0.0;
				}
		}
		else
		{
			/* not used for tridiag (large n) */
		   	/* pass empty value for function, refactor later */
			a = (double *) malloc (1 * sizeof(double)); 
		}

		/* construct the test b vec */
		b = (double *) malloc (n * sizeof(double));
		ih = (double *) malloc (n * sizeof(double));
		h = (2 * M_PI) / (n + 1);
		for (i = 0; i < n; i++)
		{
			ih[i] = (i+1)*h; /* save for plot */
			b[i] = h*h * sin((i+1)*h);
		}

		/* perform congjuage gradient to solve Ax=b */
		x = (double *) malloc (n * sizeof(double));
		t = clock();
		x = solcg(n, a, b);
		t = clock() - t;
		
		time_taken = ((double)t)/CLOCKS_PER_SEC; // in seconds 
		printf("n = %d: num iterations = %d, time taken =  %lf sec\n",n,numiter,time_taken);

		/* save x vs ih to file for plot in matlab */
		if (n < 2000)
		{
			snprintf(fname, sizeof(fname), "pblm3n%d.txt",n);
			fout = fopen(fname, "w+t");
			for (i = 0; i < n; i++)
				fprintf(fout, "%f,%f\n",ih[i],x[i]);
			fclose(fout);
		}

		free(a);
		free(x);
		free(b);
	}

	return 0;
}
