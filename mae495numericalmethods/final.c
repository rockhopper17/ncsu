#include <stdio.h>
#include <math.h>

/* debug flag - comment out to turn off debug printf's */
/*#define DEBUG*/

/* problem 2: function to integrate */
double fpblm2(double x)
{
	return 4/(1+x*x);
}

/* integration: composite trapezoidal method */
/* func call to fpblm2 */
double trapz(double a, double b, int n)
{
	int i;
	double h = (b-a)/n;
	double retval = fpblm2(a) + fpblm2(b);

	for (i=1; i < n; i++)
	{
		retval += 2*fpblm2(a+i*h);
	}

	retval *= (h/2);

	return retval;
}

/* integration: composite simpsons method */
/* func call to fpblm2 */
double simp(double a, double b, int n)
{
	int i;
	double h = (b-a)/n;
	double retval = fpblm2(a) + fpblm2(b);

	for (i=1; i < n; i+=2)
	{
		retval += 4*fpblm2(a+i*h);
	}

	for (i=2; i < (n-1); i+=2)
	{
		retval += 2*fpblm2(a+i*h);
	}

	retval *= (h/3);

	return retval;
}

/* integration: gauss quadrature */
/* func call to fpblm2 */
double gauss(double a, double b, int n)
{
	int i, j;
	double xa, xb, x, dx; /* subinterval endpoints, transformed x and dx */
	const int numpts = 2; /* num gauss pts */
	double h = (b-a)/n;
	double retval = 0;
	
	/* Gauss points and weights */
	double t[2] = {-0.57735027, 0.57735027};
	double w[2] = {1, 1};
	/*double t[4] = {-0.86113631, -0.33998104, 0.33998104, 0.86113631};*/
	/*double w[4] = {0.3478548, 0.6521452, 0.6521452, 0.3478548};*/

	/* loop all subintervals */
	for (i=0; i < n; i++)
	{
		xa = a+(i*h); /* subinterval endpoint */
		xb = a+((i+1)*h); /* subinterval endpoint */
		dx = 0.5*(xb-xa); /* transformed dx */

		/* loop gauss points */
		for (j=0; j < numpts; j++)
		{
			x = 0.5*(t[j]*(xb-xa)+xa+xb); /* transformed x using gauss pt */

			retval += (fpblm2(x) * dx * w[j]); /* eval func at new x, times dx*w */
		}
	}

	return retval;
}


/* governing eqn / equation to solve (1st order ode) */
double ode_dydt(double t, double y)
{
	return -10*y + cos(t) + 10*sin(t);
}

/* forward Euler method */
double ode_euler(double t, double y, double h)
{
	double yn;

	yn = y + (h * ode_dydt(t,y));

	return yn;
}

/* modified Euler method (RK2) */
double ode_eulermod(double t, double y, double h)
{
	double yn, f1, f2;

	f1 = ode_dydt(t,y);
	f2 = ode_dydt(t+h/2,y+0.5*h*f1);
	yn = y + (h * f2);

	return yn;
}

/* RK4 method */
double ode_rk4(double t, double y, double h)
{
	int i;
	double yn, f1, f2, f3, f4;

	f1 = ode_dydt(t,y);
	f2 = ode_dydt(t+h/2,y+h*f1/2);
	f3 = ode_dydt(t+h/2,y+h*f2/2);
	f4 = ode_dydt(t+h,y+h*f3);

	yn = y + (h/6) * (f1 + f2 + f3 + f4);

	return yn;
}

/* main */
int main()
{
	int i, n, imax;
	double en = 0;
	double preven;
	double I, enratio;

	double t, yn, h;
	double hvals[5]= {0.1, 0.05, 0.02, 0.01, 0.005};
	double y = 0; /* y(0) init */

	int pblm = 5; /* which problem to solve */

	if (pblm == 2)
	{
		/* pblm2 */
		for (n=4; n <=128; n*=2)
		{
			/*I = trapz(0,1.2,n);*/
			/*I = simp(0,1.2,n);*/
			I = gauss(0,1.2,n);

			preven = en;
			en = 4*atan(1.2) - I;

			printf("n=%d\tIn=%.16f\ten=%.16lf\t",n,I,en);
			if (n > 4)
			{
				enratio = preven/en;
				printf("enratio=%.16lf",enratio);
			}
			printf("\n");
		}
	}
	else if (pblm == 5)
	{
		/* pblm5 */
		for (n=0; n < 5; n++)
		{
			h = hvals[n] * M_PI;
			t = 0;
			imax = 1/hvals[n];

			for (i=0; i <= imax; i++)
			{
				/*yn = ode_euler(t,y,h);*/
				/*yn = ode_eulermod(t,y,h);*/
				yn = ode_rk4(t,y,h);
				y = yn;
				t += h;
			}

			preven = en;
			en = sin(M_PI) - y;

			printf("t=%lf\ty=%.16f\ten=%.16lf\t",t,y,en);
			if (n > 0)
			{
				enratio = preven/en;
				printf("enratio=%.16lf",enratio);
			}
			printf("\n");
		}
	}

	return 0;
}
