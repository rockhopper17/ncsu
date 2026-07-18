#include <math.h>
#include <stdlib.h>
#include <stdio.h>
/* declare function prototypes */
#include "protos.h"

int main()
{
  int maxsize=800, minsize=25, ntimes;
  int i,j, size;
  double sum,mflops,start_time,finish_time,elapsed_time;
  FILE *outfile;
  char *outfilename ="matmulc.dat";
#ifdef ALLOC
/* allocate storage for matrix */
  double **a, **b, **c;
  a=alloc_dmatrix(maxsize,maxsize);
  b=alloc_dmatrix(maxsize,maxsize);
  c=alloc_dmatrix(maxsize,maxsize);
#else
  double a[maxsize][maxsize], b[maxsize][maxsize], c[maxsize][maxsize];
#endif

/* open output file */
  if (!(outfile = fopen(outfilename, "w")))
    {
 	printf("Cannot open output file: %s\n",outfilename);
 	exit(1);
    }
    fprintf (outfile,"#\tSIZE\tMFLOPS\n");
    ntimes = 1024;
    printf ("SIZE\tSUM\tMFLOPS\n");
/* initialize matrix */
     for (i=0; i<maxsize; i++)
      {
       for (j=0; j<maxsize; j++)
        {
        	a[i][j]=0.0;
        	b[i][j]=0.0;
        	c[i][j]=0.0;
        }
      }

/* double matrix size each time */
   for (size=minsize; size <= maxsize; size*=2)
   {
     sum =0.0;
/* initialize matrix */
     for (i=0; i<size; i++)
      {
       for (j=0; j<size; j++)
        {
        	a[i][j]=1.0;
        	b[i][j]=2.0;
        	c[i][j]=0.0;
        }
      }


/* we need to repeat ntimes to get more accurate timings */
/* set ntimes s.t it is large for small nn and small for large nn */

     start_time=wtime();

/* perform matmul for ntimes */
     for (i=0; i< ntimes; i++) 
     {
       matmul(maxsize, size, a, b, c);
       sum += c[size-1][size-1];
     }

     finish_time=wtime();

     elapsed_time=finish_time-start_time;

/* compute sum of matrix to avoid deadcode removal */
     for (i=0; i<size; i++)
     {
         for (j=0; j<size; j++) sum += c[i][j];
     }
     mflops = (double) (2*ntimes*size*size*size*1.e-6)/(elapsed_time);
     printf("%d\t%lf\t%lf\n",size,sum,mflops);
     fprintf(outfile,"%10ld\t%lf\n",size,mflops);
     ntimes = ntimes/4;
   }
   fclose(outfile);
   return 0;
}

