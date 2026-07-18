#include <math.h>
#include <stdio.h>
/* naive version of matrix multiplication C=A*B */
void matmul(int maxsize, int size, double **a, double **b, double **c)
{
int i,j,k;
double scale;
  for (i=0; i<size; i++) /* number of rows */
  {
      for (j=0; j<size; j++) /* along each row */
      {
        c[i][j] = 0.0;
        for (k=0; k<size; k++) /* across row for a, and down column for b */
        {
          c[i][j] += a[i][k]*b[k][j];

        }
       }
   }
}

