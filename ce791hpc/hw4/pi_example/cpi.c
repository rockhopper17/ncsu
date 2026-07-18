#include "mpi.h"
#include <stdio.h>
#include <math.h>
int main( int argc, char *argv[] )
{
    int myid, numprocs, i;
    double PI25DT = 3.141592653589793238462643;
    double mypi, pi, h, sum, x, mflops, time1, time2, total_time;
    int done=0;
    int n = 1000000;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    time1=MPI_Wtime();
    h   = 1.0 / (double) n;
    sum = 0.0;
    for (i = myid + 1; i <= n; i += numprocs) {
             x = h * ((double)i - 0.5);
             sum += (4.0 / (1.0 + x*x));
         }
    mypi = h * sum;
    MPI_Reduce(&mypi, &pi, 1, MPI_DOUBLE, MPI_SUM, 0,
       MPI_COMM_WORLD);
    time2=MPI_Wtime();
    total_time=time2-time1;
    mflops = 6*n*1e-6/total_time;
    if (myid == 0) {
        printf("pi is approximately %.16f, Error is %.16f\n",
                   pi, fabs(pi - PI25DT));
        printf("Mflops = %g\n",mflops);
      } 
    MPI_Finalize();
    return 0;
}
