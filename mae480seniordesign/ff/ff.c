#include <stdio.h>
#include <math.h>

/* debug flag - comment out to turn off debug printf's */
/*#define DEBUG*/

const int numPtsThrustCurve = 34;
const char *fname = "thrustcurve.txt";
const double dtbase = 0.001; /* time step after thrust times run out */
const int numsteps = (int)30/dtbase; /* max 30 seconds total num steps */
const int numstate = 3; /* num state space variables */

/* governing eqn for y velocity (1st order ode) */
/* https://web.mit.edu/16.unified/www/FALL/systems/Lab_Notes/traj.pdf */
double ode_dvydt(double vy, double thrust)
{
	double g = 9.81; /* gravity [m/s^2] */
	double rho = 1.225; /* density of air [kg/m^3] */
	double m = 0.663; /* mass of rocket with motor [kg] */
	double A = pow(0.0671*0.5,2)*M_PI; /* max diam = 6.71cm */
	double Cd = 0.58; /* drag coefficient */

	return -g - 0.5*rho*vy*fabs(vy)*Cd*A/m + thrust/m;
}

/* forward Euler method */
void ode_euler(double x[numstate], double dt)
{
	x[0] = x[0] + x[1]*dt;
	x[1] = x[1] + ode_dvydt(x[1],x[2])*dt;

#ifdef DEBUG
	printf("h=%lf, vy=%lf\n",x[0],x[1]);
#endif
}

/* RK4 method */
void ode_rk4(double x[numstate], double dt)
{
	int i;
	double f[4*numstate]; /* rk4 intermediate derivative values */
	double thrust;

	/* Runge-Kutta 4th order */
	thrust = x[2];
	f[0] = x[1]; /* y or height */
	f[1] = ode_dvydt(f[0],thrust); /* y vel */
	f[2] = x[1] + 0.5*dt*f[1];
	f[3] = ode_dvydt(f[2],thrust);
	f[4] = x[1] + 0.5*dt*f[3];
	f[5] = ode_dvydt(f[4],thrust);
	f[6] = x[1] + dt*f[5];
	f[7] = ode_dvydt(f[6],thrust);

	x[0] += (1.0/6.0)*dt*(f[0]+2*f[2]+2*f[4]+f[6]);
	x[1] += (1.0/6.0)*dt*(f[1]+2*f[3]+2*f[5]+f[7]);

#ifdef DEBUG
	printf("h=%lf, vy=%lf\n",x[0],x[1]);
#endif
}

int main()
{
	int i;

	double thrustTime[numPtsThrustCurve];
	double thrustForce[numPtsThrustCurve];
	double t,dt; /* time, time step */
	double thrust; /* force [N] */
	double x[numstate]; /* state space: y, vy */

	/* read thrust curve */
	FILE *fp = fopen(fname,"r");
	for (i=0; i < numPtsThrustCurve; i++)
		fscanf(fp,"%lf %lf", &thrustTime[i], &thrustForce[i]);
	fclose(fp);

	/* initial conditions */
	t = 0;
	x[0] = 0; /* y (height) */
	x[1] = 0; /* vy (vertical velocity) */
	x[2] = thrustForce[0]; /* thrust force */

	/* main integration loop */
	for (i = 0; i < numsteps && t <= (7.0 + thrustTime[numPtsThrustCurve-1]); i++)
	/*for (i = 0; i < numsteps && t <= 7.0; i++)*/
	{
		/* increment time and thrust */
		if (i < numPtsThrustCurve)
		{
			dt = thrustTime[i] - t;
			t = thrustTime[i];
			x[2] = thrustForce[i];
		}
		else
		{
			dt = dtbase;
			t += dt;
			x[2] = 0.0;
		}

		/* integrate */
		ode_rk4(x,dt);
		/*ode_euler(x,dt);*/

		/* break when rocket starts falling back down */
		/* this will be apogee */
		if (x[1] <= 0.0)
			break;
	}

	/* state space is now at apogee */
	printf("apogee = %lf, time=%lf, i=%d\n",x[0],t,i);

	return 0;
}
