/* Andrew Navratil */
/* MAE 560 - HW 1 - Due 9/1/2020 */

#include <stdio.h>
#include <math.h>

/* debug flag - comment out to turn off debug printf's */
/*#define DEBUG*/

const int num_eqns = 3; /* num of first order ODEs */
const int num_dt = 1; /* num of time steps to test */

/* governing eqn / equation of motion (1st order ode) */
double ode_dydt(double t, double y[num_eqns], int eqn)
{
	/*return -0.5 * y;  [> Moin book ex 4.1 <]*/
	/*return -2 * y;  [> pblm 1 <]*/
	/*return -(2.0 + 0.01*t*t) * y;  [> pblm 2 <]*/

	/* pblm 3a */
	/*if (eqn == 0)*/
	/*{*/
		/*return y[1];*/
	/*}*/
	/*else if (eqn == 1)*/
	/*{*/
		/*return -16.35 * y[0];*/
	/*}*/
	/*else*/
	/*{*/
		/*return 0;  [> just to avoid compiler warning <]*/
	/*}*/

	/* pblm 3b */
	/*if (eqn == 0)*/
	/*{*/
		/*return y[1];*/
	/*}*/
	/*else if (eqn == 1)*/
	/*{*/
		/*return (-4 * y[1]) - (16.35 * y[0]);*/
	/*}*/
	/*else*/
	/*{*/
		/*return 0;  [> just to avoid compiler warning <]*/
	/*}*/

	/* pblm 4a */
	/* y[0] = x, y[1] = y, y[2] = z */
	double sigma = 10, b = 8/3;
	/*double r = 20; [> pblm 4a <]*/
	double r = 28; /* pblm 4b,c */
	if (eqn == 0) /* dx/dt */
	{
		return sigma*(y[1] - y[0]);
	}
	else if (eqn == 1) /* dy/dt */
	{
		return r*y[0] - y[1] - y[0]*y[2];
	}
	else if (eqn == 2) /* dz/dt */
	{
		return y[0]*y[1] - b*y[2];
	}
	else
	{
		return 0;  /* just to avoid compiler warning */
	}
}

/* implicit (backward) Euler method */
/*double ode_euler_imp(double t, double y, double dt)*/
void ode_euler_imp(double t, double dt, double y[num_eqns], double yn[num_eqns])
{
	/*return y / (1.0 + 2.0*dt); [> pblm 1 <]*/
	/*return y / (1.0 + (2.0 + 0.01*t*t)*dt); [> pblm 2 <]*/

	/* pblm 3a */
	/*yn[0] = (y[0] + y[1]*dt) / (1 + dt*dt * 16.35); */
	/*yn[1] = y[1] + dt*(-16.35*yn[0]);*/
	
	/* pblm 3b */
	yn[0] = (y[0] + y[1]*dt + (y[1]*dt*dt/(1+4*dt))) * 1/(1 + (16.35*dt*dt/(1+4*dt)));
	yn[1] = (y[1] - 16.35*yn[0]*dt)/(1+4*dt);
}

/* explicit (forward) Euler method */
void ode_euler_exp(double t, double dt, double y[num_eqns], double yn[num_eqns])
{
	for (int i = 0; i < num_eqns; i++)
	{
		yn[i] = y[i] + (dt * ode_dydt(t,y,i));
	}
}

/* modified Euler method (RK2) */
/*double ode_rk2(double t, double y, double dt)*/
/*{*/
	/*double f1, f2;*/

	/*f1 = ode_dydt(t,y);*/
	/*f2 = ode_dydt(t + 0.5*dt,y + 0.5*dt * f1);*/
	/*return y + (dt * f2);*/
/*}*/

/* RK4 method */
/*double ode_rk4(double t, double y, double dt)*/
void ode_rk4(double t, double dt, double y[num_eqns], double yn[num_eqns])
{
	int i;
	double f1[num_eqns], f2[num_eqns], f3[num_eqns], f4[num_eqns];
	double ytmp[num_eqns], ytmp2[num_eqns], ytmp3[num_eqns];

	for (i = 0; i < num_eqns; i++)
	{
		f1[i] = ode_dydt(t,y,i);
		ytmp[i] = y[i] + 0.5*dt*f1[i];
	}
	for (i = 0; i < num_eqns; i++)
	{
		f2[i] = ode_dydt(t + 0.5*dt, ytmp, i);
		ytmp2[i] = y[i] + 0.5*dt*f2[i];
	}
	for (i = 0; i < num_eqns; i++)
	{
		f3[i] = ode_dydt(t + 0.5*dt, ytmp2, i);
		ytmp3[i] = y[i] + dt*f3[i];
	}
	for (i = 0; i < num_eqns; i++)
	{
		f4[i] = ode_dydt(t + dt, ytmp3, i);
	}

	for (i = 0; i < num_eqns; i++)
	{
		yn[i] = y[i] + (dt/6.0)*(f1[i] + 2.0*f2[i] + 2.0*f3[i] + f4[i]);
	}
}

/***********************************************/
/* main */
/***********************************************/
int main()
{
	int i, n;
	double y[num_eqns], yn[num_eqns], t, dt;
	/*double yinit = 1, tinit = 0, tmax = 20; [> Moin book ex 4.1 <]*/
	/*double dtvals[3]= {0.1, 1.0, 4.2}; */
	/*double yinit = 4.0, tinit = 0, tmax = 15.0; [> pblm 1 & 2 <]*/
	/*double dtvals[3]= {0.1, 0.5, 1.0};*/
	/*double y0init = 0.175, y1init = 0.0, tinit = 0, tmax = 6.0; [> pblm 3: 10deg=.175rad <]*/
	double tinit = 0, tmax = 25; /* pblm 4 */
	/*double dtvals[num_dt]= {0.15, 0.5, 1.0}; [> pblms 1,2,3 <]*/
	FILE *fout; /* save data to file for plotting in matlab or tecplot */
	char fname[50]; /* filename */

	for (n = 0; n < num_dt; n++)
	{
		/* pblms 1,2,3 */
		/*y[0] = y0init;*/
		/*y[1] = y1init;*/
		/*dt = dtvals[n];*/

		/* pblm 4a,b */
		y[0] = 1; /* x */
		y[1] = 1; /* y */
		y[2] = 1; /* z */
	
		/* pblm 4c1,4c2 */
		y[0] = 6; /* x */
		/*y[1] = 6; [> y 4c1 <]*/
		y[1] = 6.01; /* y 4c2 */
		y[2] = 6; /* z */
		
		dt = 0.005;
		
		printf("\n\ndt=%lf\n\n",dt);

		/*snprintf(fname, sizeof(fname), "hw1data/pblm3bi-%d.txt",n);  [> explicit euler <]*/
		/*snprintf(fname, sizeof(fname), "hw1data/pblm3bii-%d.txt",n);  [> implicit euler <]*/
		/*snprintf(fname, sizeof(fname), "hw1data/pblm2iii-%d.txt",n);  [> rk2 <]*/
		/*snprintf(fname, sizeof(fname), "hw1data/pblm4c2iv-%d.txt",n);  [> rk4 <]*/

		/*fout = fopen(fname, "w+t");*/

		for (t = tinit; t <= tmax; t += dt)
		{
			/* pblms 1,2,3 */
			/*printf("t=%lf\ty0=%.15lf\ty1=%.15lf\n",t,y[0],y[1]); */
			/*fprintf(fout,"%lf,%lf\n",t,y[0]);*/
		
			/* pblm 4 */
			/*printf("fmod=%lf,t=%lf\n",fmod(t,1),t);*/
			/*if (fmod(t,1.0) >= 1)  [> not working, figure out later <]*/
			/*{*/
				printf("t=%lf\tx=%.15lf\ty=%.15lf\tz=%.15lf\n",t,y[0],y[1],y[2]);
			/*}*/
			/*fprintf(fout,"%lf,%.15lf,%.15lf,%.15lf\n",t,y[0],y[1],y[2]);*/
	
			/*y = ode_euler_exp(t,y,dt); [> explicit euler <]*/
			/*y = ode_euler_imp(t,y,dt); [> implicit euler <]*/
			/*y = ode_rk2(t,y,dt); [> rk2 <]*/
			/*y = ode_rk4(t,y,dt); [> rk4 <]*/
		
			/*ode_euler_exp(t,dt,y,yn); [> explicit euler <]*/
			/*ode_euler_imp(t,dt,y,yn); [> implicit euler <]*/
			ode_rk4(t,dt,y,yn); /* rk4 */

			for (i = 0; i < num_eqns; i++)
			{
				y[i] = yn[i];
			}
		}

		/*fclose(fout);*/
	}

	return 0;
}

