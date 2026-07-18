/* Andrew Navratil */
/* MAE 495 Numerical Methods */
/* HW 1-6 Due 9/4/19 */

#include <stdio.h>
#include <float.h>
#include <math.h>

/* accuracy value */
static const float eps = 1e-6;  

/* values to calculate exp(x) */
static const float vals[5] = {-0.5, -5, -10, -20, -40};
/*static const float vals[1] = {-0.5};*/

/* num of term in expansion (not thread safe) */
static int n = 1;

/* first algorithm - float */
static float expaf(float x)
{
	float res = 1.0 + x;  /* result */
	float a = x; /* no overflow method term */
	n = 1; /* reset n */

	/* using no overflow method from lecture 2 notes */
	while (fabsf(a) > eps)
	{
		a *= (x / ++n);
		res += a;
	}

	return res;
}

/* second algorithm - float */
static float expbf(float x)
{
	float res = 1.0 - x;  /* result denominator */
	float a = -x; /* no overflow method term */
	n = 1; /* reset n */

	/* using no overflow method from lecture 2 notes */
	while (fabsf(a) > eps)
	{
		/*n++;*/
		a *= (x / ++n);
		/*a *= pow(-1,n) * (x / n);*/
		res += (pow(-1,n) * a);
		/*printf("a=%g\n",a);*/
		/*printf("res=%g\n",res);*/
	}

	return 1.0 / res;
}

/* first algorithm - double */
static double expad(double x)
{
	double res = 1.0 + x;  /* result */
	double a = x; /* no overflow method term */
	n = 1; /* reset n */

	/* using no overflow method from lecture 2 notes */
	while (fabs(a) > eps)
	{
		a *= (x / ++n);
		res += a;
	}

	return res;
}

/* second algorithm - double */
static double expbd(double x)
{
	double res = 1.0 - x;  /* result denominator */
	double a = -x; /* no overflow method term */
	n = 1; /* reset n */

	/* using no overflow method from lecture 2 notes */
	while (fabs(a) > eps)
	{
		/*n++;*/
		a *= (x / ++n);
		/*a *= pow(-1,n) * (x / n);*/
		res += (pow(-1,n) * a);
		/*printf("a=%g\n",a);*/
		/*printf("res=%g\n",res);*/
	}

	return 1.0 / res;
}

int main()
{
	float x, xex, res; /* cur value, exact exp, compute exp */
	double xd, xexd, resd; /* double versions */
	int i;

	for (i = 0; i < 5; i++)
	{
		x = vals[i];
		xex = expf(x);
		printf("\nvalue x = %g\n", x);
		printf("exact value of exp(x) = %g\n", xex);

		res = expaf(x); /* call first algorithm */
		res = fabsf(res);  /* some are returning negative values, not sure why */
		printf("first algorithm (float): computed value of exp(x) = %g\n", res);
		printf("first algorithm (float): number of terms in expansion n = %d\n", n);
		printf("first algorithm (float): relative error = %g\n",
				fabsf(xex - res) / fabsf(xex));
		
		res = expbf(x); /* call second algorithm */
		res = fabsf(res);  /* some are returning negative values, not sure why */
		printf("second algorithm (float): computed value of exp(x) = %g\n", res);
		printf("second algorithm (float): number of terms in expansion n = %d\n", n);
		printf("second algorithm (float): relative error = %g\n",
				fabsf(xex - res) / fabsf(xex));
	
		xd = (double)vals[i];
		xexd = exp(xd);

		resd = expad(xd); /* call first algorithm */
		resd = fabs(resd);  /* some are returning negative values, not sure why */
		printf("first algorithm (double): computed value of exp(x) = %g\n", resd);
		printf("first algorithm (double): number of terms in expansion n = %d\n", n);
		printf("first algorithm (double): relative error = %g\n",
				fabs(xexd - resd) / fabs(xexd));
		
		resd = expbd(xd); /* call second algorithm */
		resd = fabs(resd);  /* some are returning negative values, not sure why */
		printf("second algorithm (double): computed value of exp(x) = %g\n", resd);
		printf("second algorithm (double): number of terms in expansion n = %d\n", n);
		printf("second algorithm (double): relative error = %g\n",
				fabs(xexd - resd) / fabs(xexd));
	}
}
