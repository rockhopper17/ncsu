/* Andrew Navratil */
/* MAE 495 Numerical Methods */
/* HW 2 Due 10/9/19 */

#include <stdio.h>
#include <float.h>
#include <math.h>

const int n = 5; /* num rows/cols for nxn matrix */
/*double a[n][n]; [> coefficient matrix <]*/
double x[n]; /* solution vector */
double b[n]; /* constant vector */
double y[n]; /* forward sub solution vector */
/*double u[n][n]; [> upper diag <]*/
/*double l[n][n]; [> lower diag <]*/
double p[n][n]; /* pivot matrix */
double ainv[n][n]; /* inverse matrix */
double acopy[n][n]; /* matrix copy */

/*double a[n][n] = {1,2,3,4,5,6,7,8,0};*/
/*double u[n][n] = {1,2,3,4,5,6,7,8,0};*/
/*double a[n][n] = {2,1,1,0,4,3,3,1,8,7,9,5,6,7,9,8};*/
/*double a[n][n] = {4, -2, -3, 6, -6, 7, 6.5, -6, 1, 7.5, 6.25, 5.5, -12, 22, 15.5, -1};*/
double a[n][n] = {.2,-5,3,.4,0,-.5,1,7,-2,.3,.6,2,-4,3,.1,3,.8,2,-.4,3,.5,3,2,.4,1};

/*double a[n][n] = {.729,.81,.9,1,1,1,1.331,1.21,1.1};*/
/*double b[n] = {.6867,.8338,1};*/

/* create identity matrix */
void identity(double xm[n][n])
{
	int i, j;

	for (i = 0; i < n; i++)
		for (j = 0; j < n; j++)
			if (i == j)
				xm[i][j] = 1;
			else
				xm[i][j] = 0;
}

/* create a[i][j] = max(i,j) matrix */
void maxij(double xm[n][n])
{
	int i, j;

	for (i = 0; i < n; i++)
		for (j = 0; j < n; j++)
			xm[i][j] = (i > j) ? (double)i+1 : (double)j+1;
}

/* create all ones vector */
void allones(double xm[n])
{
	int i;

	for (i = 0; i < n; i++)
		xm[i] = 1;
}

/* forward substitutioin */
void forwardsub(void)
{
	int i, j;

	/* first multiply b by p */
	for (i = 0; i < n; i++)
	{
		y[i] = 0;

		for (j = 0; j < n; j++)
			y[i] += p[i][j]*b[j];
	}
	for (i = 0; i < n; i++)
		b[i] = y[i];

	/* then do forward sub */	
	for (i = 0; i < n; i++)
	{
		y[i] = b[i];
		
		for (j = 0; j < i; j++)
			y[i] = y[i] - a[i][j]*y[j];
	}
}

/* backward substitutioin */
void backwardsub(void)
{
	int i, j;

	for (i = n-1; i >= 0; i--)
	{
		x[i] = y[i];
	
		/* note: error in slides: *y[j] -> *x[j] */	
		for (j = i+1; j < n; j++)
			x[i] = x[i] - a[i][j]*x[j];

		x[i] = x[i]/a[i][i];
	}
}

/* LU decomposition with partial pivoting */
void lupdecomp(void)
{
	int i, j, k, maxidx;
	double maxval, tmpval;

	for (j = 0; j < (n-1); j++)
	{
		/* pivoting */
		maxval = 0;
		for (i = j; i < n; i++)
		{
			if (fabs(a[i][j]) > maxval)
			{
				maxval = fabs(a[i][j]);
				maxidx = i;
			}
		}

		/* swap rows if pivoting required */
		if (maxidx != j)
		{
			for(k = 0; k < n; k++)
			{
				tmpval = p[j][k];
				p[j][k] = p[maxidx][k];
				p[maxidx][k] = tmpval;

				tmpval = a[j][k];
				a[j][k] = a[maxidx][k];
				a[maxidx][k] = tmpval;
				
				/*if (k >= j)*/
				/*{*/
					/*tmpval = u[j][k];*/
					/*u[j][k] = u[maxidx][k];*/
					/*u[maxidx][k] = tmpval;*/
				/*}*/
				
				/*if (k < j)*/
				/*{*/
					/*tmpval = l[j][k];*/
					/*l[j][k] = l[maxidx][k];*/
					/*l[maxidx][k] = tmpval;*/
				/*}*/
			}
		}

		/* perform the factorization */
		for (i = j+1; i < n; i++)
		{
			a[i][j] = a[i][j]/a[j][j];
			/*l[i][j] = u[i][j]/u[j][j];*/

			for (k = j+1; k < n; k++)
			{
				a[i][k] = a[i][k] - a[i][j]*a[j][k];
				/*u[i][k] = u[i][k] - l[i][j]*u[j][k];*/
			}
		}
	}
}

/* calculate inverse of a */
void matinv(void)
{
	int i, j, k;
	double ident[n][n];

	/* only need to call LU decomp once */
	lupdecomp();

	/* create identity matrix */
	identity(ident);

	/* save a copy of lu decomped a so we can solve it multiple times */
	for (i = 0; i < n; i++)
		for (j = 0; j < n; j++)
			acopy[i][j] = a[i][j];	

	/* loop cols, set b to col of ident, solve */
	/* that sln is one column of inverse matrix */
	for (k = 0; k < n; k++)
	{
		/* reset b for this col */
		for (i = 0; i < n; i++)
			b[i] = ident[i][k];

		/* reset a back to original lu decomp before solving again */
		for (i = 0; i < n; i++)
			for (j = 0; j < n; j++)
				a[i][j] = acopy[i][j];	

		/* solve */
		forwardsub();
		backwardsub();

		/* put sln x in j column of ainv*/
		for (i = 0; i < n; i++)
			ainv[i][k] = x[i];
	}
}

/* main */
int main()
{
	identity(p);
	
	/*maxij(a);*/
	/*allones(b);*/

	/*lupdecomp();*/

	/*forwardsub();*/
	/*backwardsub();*/
	
	a[n][n] = {.2,-5,3,.4,0,-.5,1,7,-2,.3,.6,2,-4,3,.1,3,.8,2,-.4,3,.5,3,2,.4,1};
	matinv();

	return 0;
}

