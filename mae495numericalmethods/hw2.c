/* Andrew Navratil */
/* MAE 495 Numerical Methods */
/* HW 2 Due 10/9/19 */

#include <stdio.h>
#include <float.h>
#include <math.h>

/* not a thread safe program */

/* hw problem: 1->1-2(n=10),2->1-3(n=5), 3->2-1(n=2,3,4,5,6,7) */
const int hwcase = 3; 

const int n = 7; /* num rows/cols for nxn matrix */

double a[n][n]; /* coefficient matrix */
/* test from book */
/*double a[n][n] = {.2,-5,3,.4,0,-.5,1,7,-2,.3,*/
	/*.6,2,-4,3,.1,3,.8,2,-.4,3,.5,3,2,.4,1};*/
/* hw 1-2 */
/*double a[n][n] = {{4,-1,0,0,2},{-1,3,-1,0,.5},*/
	/*{0,-.4,2,-1,0},{0,0,-1,2,-1},{1,0,0,-1,5}};*/

/* test from atkinson book */
/*double a[n][n] = {.729,.81,.9,1,1,1,1.331,1.21,1.1};*/
/*double b[n] = {.6867,.8338,1};*/

double x[n]; /* solution vector */
double b[n]; /* constant vector */
double y[n]; /* forward sub solution vector */
double p[n][n]; /* pivot matrix */
double ainv[n][n]; /* inverse matrix */
double acopy[n][n]; /* matrix copy (refactor this sln later) */

/* create identity matrix */
void identity(double xm[n][n])
{
	for (int i = 0; i < n; i++)
		for (int j = 0; j < n; j++)
			if (i == j)
				xm[i][j] = 1;
			else
				xm[i][j] = 0;
}

/* create a[i][j] = max(i,j) matrix */
void maxij(double xm[n][n])
{
	for (int i = 0; i < n; i++)
		for (int j = 0; j < n; j++)
			xm[i][j] = (i > j) ? (double)i+1 : (double)j+1;
}

/* create all ones vector */
void allones(double xm[n])
{
	for (int i = 0; i < n; i++)
		xm[i] = 1;
}

/* create all ones alternating negative vector */
void allonesalt(double xm[n])
{
	for (int i = 0; i < n; i++)
		xm[i] = (i % 2) ? -1 : 1;
}

/* copy matrix */
void matcopy(double xmsrc[n][n], double xmdest[n][n])
{
	for (int i = 0; i < n; i++)
		for (int j = 0; j < n; j++)
			xmdest[i][j] = xmsrc[i][j];	
}

/* copy vector */
void veccopy(double xvsrc[n], double xvdest[n])
{
	for (int i = 0; i < n; i++)
		xvdest[i] = xvsrc[i];
}

/* multiply matrix by vector */
void matvecmult(double xm[n][n], double xv[n], double xvr[n])
{
	for (int i = 0; i < n; i++)
	{
		xvr[i] = 0;

		for (int j = 0; j < n; j++)
			xvr[i] += xm[i][j]*xv[j];
	}
}

/* factorial */
int factorial(int xv)
{
	int retval = 1;
	for (int i = xv; i > 1; i--)
		retval *= i;

	return retval;
}

/* vector norm (L2 norm) */
double norm(double xv[n])
{
	double retval = 0;

	for (int i = 0; i < n; i++)
		retval += xv[i]*xv[i];

	return sqrt(retval);
}

/* create hilbert matrix */
void makehilbert(double xm[n][n])
{
	for (int i = 0; i < n; i++)
		for (int j = 0; j < n; j++)
			xm[i][j] = 1/((double)i+(double)j+1);
}

/* create hilbert inverse */
/* using algorithm from Cleve Moler to avoid overflow */
/* https://blogs.mathworks.com/cleve/2017/06/07/hilbert-matrices-2/ */
void makehilbertinv(double xm[n][n])
{
	int pr, r;

	pr = n;
	for (int i = 1; i <= n; i++)
	{
		r = pr*pr;
		xm[i-1][i-1] = r/(2*i-1);

		for (int j = i+1; j <= n; j++)
		{
			r = -((n-j+1)*r*(n+j-1))/pow(j-1,2);
			xm[i-1][j-1] = r/(i+j-1);
			xm[j-1][i-1] = r/(i+j-1);
		}
		pr = ((n-i)*pr*(n+i))/pow(i,2);
	}

	/*for (int i = 1; i <= n; i++)*/
		/*for (int j = 1; j <= n; j++)*/
		/*{*/
			/*xmn = pow(-1,i+j)*factorial(n+i-1)*factorial(n+j-1);*/
			/*xmd = (i+j-1)*pow(factorial(i-1)*factorial(j-1),2);*/
			/*xmd *= factorial(n-i)*factorial(n-j);*/
			/*xm[i][j] = (double)xmn/(double)xmd;*/
		/*}*/
}

/* forward substitutioin */
void forwardsub(void)
{
	/* first multiply b by p */
	matvecmult(p,b,y); /* use y as temp */
	veccopy(y,b); /* put sln back into b */

	/* then do forward sub */	
	for (int i = 0; i < n; i++)
	{
		y[i] = b[i];
		
		for (int j = 0; j < i; j++)
			y[i] = y[i] - a[i][j]*y[j];
	}
}

/* backward substitutioin */
void backwardsub(void)
{
	for (int i = n-1; i >= 0; i--)
	{
		x[i] = y[i];
	
		/* note: error in slides: *y[j] -> *x[j] */	
		for (int j = i+1; j < n; j++)
			x[i] = x[i] - a[i][j]*x[j];

		x[i] = x[i]/a[i][i];
	}
}

/* LU decomposition with partial pivoting */
void lupdecomp(void)
{
	int maxidx;
	double maxval, tmpval;

	for (int j = 0; j < (n-1); j++)
	{
		/* pivoting */
		maxval = 0;
		for (int i = j; i < n; i++)
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
			for (int k = 0; k < n; k++)
			{
				tmpval = p[j][k];
				p[j][k] = p[maxidx][k];
				p[maxidx][k] = tmpval;

				tmpval = a[j][k];
				a[j][k] = a[maxidx][k];
				a[maxidx][k] = tmpval;
			}
		}

		/* perform the factorization */
		for (int i = j+1; i < n; i++)
		{
			a[i][j] = a[i][j]/a[j][j];

			for (int k = j+1; k < n; k++)
			{
				a[i][k] = a[i][k] - a[i][j]*a[j][k];
			}
		}
	}
}

/* calculate inverse of a */
void matinv(void)
{
	double ident[n][n];

	/* only need to call LU decomp once */
	lupdecomp();

	/* create identity matrix */
	identity(ident);

	/* save a copy of lu decomped a */
	/* so we can solve it multiple times */
	matcopy(a,acopy); /* matcopy takes src,dest */

	/* loop cols, set b to col of ident, solve */
	/* that sln is one column of inverse matrix */
	for (int k = 0; k < n; k++)
	{
		/* reset b for this col */
		for (int i = 0; i < n; i++)
			b[i] = ident[i][k];

		/* reset a back to original lu decomp */
		matcopy(acopy,a);

		/* solve */
		forwardsub();
		backwardsub();

		/* put sln x in i column of ainv*/
		for (int i = 0; i < n; i++)
			ainv[i][k] = x[i];
	}
}

/* main */
int main()
{
	/* note that ludecomp, forwardsub, backwardsub work on a,b,p,x,y globals */
	/* fix this another day */
	double xts[n], eabs[n];
	double erel;

	/* switch on which hw problem we are solving */
	/* use debugger to view final values */
	if (hwcase == 1)
	{
		identity(p);
		allones(b);
		maxij(a);

		lupdecomp();
		forwardsub();
		backwardsub();
	}
	else if (hwcase == 2)
	{
		identity(p);
		allones(b);

		matinv();
	}
	else if (hwcase == 3)
	{
		/* numerical sln (will be in x) */
		identity(p);
		allonesalt(b);
		makehilbert(a);
		lupdecomp();
		forwardsub();
		backwardsub();

		/* theoretical sln */
		/*identity(p);*/
		allonesalt(b);
		makehilbertinv(ainv);
		matvecmult(ainv,b,xts);

		/* absolute error */
		for (int i = 0; i < n; i++)
			eabs[i] = xts[i] - x[i];

		/* relative error */
		erel = norm(eabs)/norm(xts);
	}

	return 0;
}

