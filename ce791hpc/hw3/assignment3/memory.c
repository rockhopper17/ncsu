#include <stdlib.h>
double **alloc_dmatrix(int nrows,int ncols) /* allocate double 2d matrix */
{
 int i;
 double **m;
/* allocate array for storing starting address of each row */
 m=(double **) malloc(nrows*sizeof(double *));
 if (!m) printf( "allocation failure in dmatrix()");
/* allocate storage for each row */
  for(i=0; i<nrows; i++) {
    m[i]=(double *) malloc(ncols*sizeof(double));
    if (!m[i]) printf("allocation failure in dmatrix()");
    }
 return m;
}

double *alloc_dvector(long size)
{
   double *m;
   m= (double *) malloc((unsigned) size*sizeof(double));
if (!m) printf( "allocation failure in dvector()");
    return m;
}

