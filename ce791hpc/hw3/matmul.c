#include <math.h>
#include <stdio.h>
#include "mkl.h"

/* change name of matmul# function to matmul depending on which one to execute */

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

/* loop restructure (Dowd Severance p159-160 */
void matmul2(int maxsize, int size, double **a, double **b, double **c)
{
	int i,j,k;
	double scale;

	for (i=0; i<size; i++) /* number of rows */
	{
		for (j=0; j<size; j++) /* along each row */
		{
			c[i][j] = 0.0;
		}
	}

	for (k=0; k<size; k++) /* across row for a, and down column for b */
	{
		for (i=0; i<size; i++) /* number of rows */
		{
			scale = b[i][k];

			for (j=0; j<size; j++) /* along each row */
			{
				c[i][j] += a[k][j]*scale;
			}
		}
	}
}

/* blocking (Dowd Severance p161-165 */
void matmul3(int maxsize, int size, double **a, double **b, double **c)
{
	int i,ii,j,jj,k,kk,blocksize;

	/* initialize c */
	for (i=0; i<size; i++)
	{
		for (j=0; j<size; j++)
		{
			c[i][j] = 0.0;
		}
	}

	/* tried to do Dowd Severance methods, but couldn't get it to work */
	/*for (i=0; i<size; i++) */
	/*{*/
		/*for (j=0; j<size; j++) */
		/*{*/
			/*c[i][j] = 0.0;*/

			/*for (k=0; k<size/2; k++) */
			/*{*/
				/*c[i][j] += a[i][k]*b[k][j];*/
			/*}*/
		/*}*/
	/*}*/
	/*for (i=0; i<size; i++) */
	/*{*/
		/*for (j=0; j<size; j++) */
		/*{*/
			/*c[i][j] = 0.0;*/

			/*for (k=size/2; k<size; k++) */
			/*{*/
				/*c[i][j] += a[i][k]*b[k][j];*/
			/*}*/
		/*}*/
	/*}*/

	/* method from reading algorithms on the internet */	
	/* tried multiple ways to get this blocking to work */
	/* but none resulted in a very fast algorithm */
	blocksize = 5;
	for (i=0; i<size; i+=blocksize)
	{
		for (j=0; j<size; j+=blocksize)
		{
			for (k=0; k<size; k+=blocksize)
			{
				for (ii = i; ii < i+blocksize; ii++)
				{
					for (jj = j; jj < j+blocksize; jj++)
					{
						for (kk = k; kk < k+blocksize; kk++)
						{
							c[ii][jj] += a[ii][kk] * b[kk][jj];
						}
					}
				}
			}
		}
	}
}

/* intel mkl library dgemm */
void matmul4(int maxsize, int size, double **a, double **b, double **c)
{
	int m, n, k;
	double alpha, beta;

	/* alpha * a[mxk] * b[kxn] = beta * c[mxn] */
	m = size;
	n = size;
	k = size;
	alpha = 1.0; /* scale a*b */
	beta = 1.0; /* scale c */

	cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
				m, n, k, alpha, *a, k, *b, n, beta, *c, n);
}

