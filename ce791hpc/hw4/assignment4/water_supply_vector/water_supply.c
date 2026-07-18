/************************************************************
 analyze water supply options for a town
 exercise taken from CE297 (Dr. John Baugh)
************************************************************/
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#define NTRIALS 10000000
/*********************************************************** 
 uc = cost (in $) per million gallons per day (mgd)
             for each source
 supply limit = maximum mgd for each source
 hc = hc of water from each source (lb/mgd)
 hc_limit = maximum total hc per mgd
 demand = total demand in mgd
 time1 = wall clock time at the beginning of execution
 time2 = wall clock time at the end of execution
**************************************************************/

double wtime()
{
  double t;
  static long sec=-1;
  struct timeval tv;
  gettimeofday(&tv, (void *)0);
  if (sec < 0) sec = tv.tv_sec;
  t = (tv.tv_sec - sec) + 1.0e-6*tv.tv_usec;
  return (t);
}

double *alloc_dvector(long size)
{
   double *m;
   m = (double *) malloc((unsigned) size*sizeof(double));
   if (!m) printf( "allocation failure in dvector()");
   return m;
}


int main()
{
/* static allocation of arrays generally faster */
  double *x1, *x2, *x3, *cost;
/* declare and initialize constant parameters */
  double uc1 = 500, uc2=1000, uc3=2000;
  double sl1=25, sl2=120, sl3=100;
  double hc1=200, hc2=2300, hc3=700;
  double rand_max_inv=1/(double) RAND_MAX;
  double hc_limit=1200, demand=150;
  long ntrials = NTRIALS;
/* declare other variables */
  double min_cost, avg_hc;
  double time1, time2, time3, time4;
  double time_obj, time_gen, time_tot, mflops_obj, mflops;
  long i, j, min_cost_index;
  unsigned int seed=567891;
/* initialize design variables subject to constralongs */
  x1=alloc_dvector(ntrials);
  x2=alloc_dvector(ntrials);
  x3=alloc_dvector(ntrials);
  cost=alloc_dvector(ntrials);
  time1=wtime();
  j=0;
  srand(seed);
  for (i=0; i<ntrials; i++) {
          x3[i] = 0;
          while (x3[i] > sl3 ||
                 x3[i] <= 0 ||
                 avg_hc >= hc_limit) {
                x1[i]=(double) rand()*rand_max_inv*sl1;
                x2[i]=(double) rand()*rand_max_inv*sl2;
                x3[i]=demand-x1[i] -  x2[i];
                avg_hc = (x1[i]*hc1
                               +x2[i]*hc2
                               +x3[i]*hc3)/demand;
                j++;
            }
    }
    time2=wtime();
/* time to generate alternatives */
    time_gen=time2-time1;
/* calculate cost */
    min_cost = 1e10;
    for (i=0; i<ntrials; i++) {
         cost[i] = uc1*x1[i] 
                     +uc2*x2[i]
                     +uc3*x3[i];
          } 
    time3=wtime();
    time_obj=time3-time2;
    for (i=0; i<ntrials; i++) {
           if (cost[i] <= min_cost) {
               min_cost = cost[i];
               min_cost_index = i;
            } 
     }
    mflops_obj = 5*ntrials*1e-6/time_obj;
    time4=wtime();
    time_tot=time4-time1;
    mflops = (double)(10*j+ntrials*5)*1e-6/time_tot;
    printf("Amount drawn from source1 = %lf mgd\n",
                  x1[min_cost_index]);
    printf("Amount drawn from source2 = %lf mgd\n",
                  x2[min_cost_index]);
    printf("Amount drawn from source3 = %lf mgd\n",
                  x3[min_cost_index]);
    printf("Minimum cost = %d dollars\n",(long) min_cost);
    printf("Time to generate alternatives  = %lf secs\n",time_gen);
    printf("Time to calculate objective = %lf secs\n",time_obj);
    printf("Mflop rating for Objective  calculation = %lf mflops\n",mflops_obj);
    printf("Mflop rating for entire code = %lf mflops\n",mflops);
    printf("Total time = %lf secs\n",time_tot);

}  /* end main */

