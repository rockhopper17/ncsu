/* this is a simple code that performs the vector operation vaxpy
defined by A = A + B*C where A, B, C are vectors this code is a good
test for memory bandwidth limitations (2 fp operations for 4 memory
accesses), and cache size.
The code prints out the mflop rating for each processor */
/* begin vector.c */

#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#define MAXBLOCKS (1024*1024)
#define MINBLOCKS 1
#define BLOCKSIZE 1
#define MAXSIZE (1050*1050)
#define MAXTIMES 100000
#define MINTIMES 10
#define MINVOLUME (8192*1024)
#define MIN(x,y) (((x) < (y)) ? (x) : (y))

double wtime()
{
  double t;
  static int sec=-1;
  struct timeval tv;
  gettimeofday(&tv, (void *)0);
  if (sec < 0) sec = tv.tv_sec;
  t = (tv.tv_sec - sec) + 1.0e-6*tv.tv_usec;
  return (t);
}

#ifndef ALLOC

/* static allocation - generally faster */

double av[MAXSIZE],bv[MAXSIZE],cv[MAXSIZE];

#endif

int main()
{

double time, Mflops, avsum;
double tstart,tend, elapsed;

FILE *outfile;
char *outfilename ="flops_c.dat";
long i, j, k, l, nn, ntimes;

#ifdef ALLOC

/* dynamically allocate arrays */

double *av;
double *bv;
double *cv;


if (!(av = (double *) malloc((unsigned) MAXSIZE*sizeof(double))))
    {
    perror("can't malloc av");
    exit(2);
    }

if (!(bv = (double *) malloc((unsigned) MAXSIZE*sizeof(double))))
    {
    perror("can't malloc bv");
    exit(2);
    }

if (!(cv = (double *) malloc((unsigned) MAXSIZE*sizeof(double))))
    {
    perror("can't malloc cv");
    exit(2);
    }

#endif

/* open output file */
if (!(outfile = fopen(outfilename, "w")))
 {
 printf("Cannot open output file: %s\n",outfilename);
 exit(1);
 }

fprintf(outfile,"#      SIZE(words)    MFLOPS\n");

/* fill vectors with dummy values */

 for (k=0; k< MAXSIZE; k++) 
 {
     av[k]=(double) 0;
     bv[k]=(double) k;
     cv[k]=(double) k;
 }

 for (l=MINBLOCKS; l <= MAXBLOCKS; l*=2) 
 {

        nn = l*BLOCKSIZE;


        tstart = wtime();

        avsum = 0;

/* we need to repeat ntimes to get more accurate timings */
/* set ntimes s.t it is large for small nn and small for large nn */
        ntimes = MIN(MINVOLUME/nn + MINTIMES,MAXTIMES);

        for(i=0; i <= ntimes; i++) 
        {

               for (j=0; j < nn; j++) 
               {
#ifdef POINTER
                      *(av+j) += *(bv+j)*(*(cv+j));
#else
                        av[j] +=bv[j]*cv[j];
#endif
               }  /* end of j loop */

/* need this statement to avoid deadcode removal */

               avsum += av[nn-1]; 

         }  /* end of i loop */

   tend = wtime();

   elapsed = tend-tstart;

   printf("avsum: %g\n", avsum);

   time = elapsed;

   Mflops = ( (double) nn*ntimes*2)/( (double) 1000*1000 )/time;

   printf("ntimes: %ld, size: %ld, time: %lf, Mflops: %lf\n",
	ntimes, nn, time, Mflops );
   fprintf(outfile,"%10ld        %lf\n",nn,Mflops);

 }            /*end of l loop */

fclose(outfile);
exit(0);

}  /* end main */

