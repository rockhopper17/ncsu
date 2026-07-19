/*=================================================================
 * mexcallmatlab.c
 *
 * mexcallmatlab takes no inputs.  This routine first forms and
 * displays the following matrix (in MATLAB notation):
 *
 *      hankel(1:4,4:-1:1) + sqrt(-1)*toeplitz(1:4,1:4)
 *
 * Next it finds the eigenvalues and eigenvectors (using the MATLAB
 * function EIG), and displays the eigenvalue matrix.  Then it
 * calculates the inverse of the eigenvalues to demonstrate manipulation
 * of MATLAB results and how to deal with complex arithmetic.  Finally,
 * the program displays the inverse values.
 *
 * Copyright 1984-2017 The MathWorks, Inc.
 *================================================================*/

#include <math.h>
#include "mex.h"

#if MX_HAS_INTERLEAVED_COMPLEX
    #define XR(i,j) mxGetComplexDoubles(pa)[i+4*j].real
    #define XI(i,j) mxGetComplexDoubles(pa)[i+4*j].imag
#else
    #define XR(i,j) mxGetPr(pa)[i+4*j]
    #define XI(i,j) mxGetPi(pa)[i+4*j]
#endif

 static void fill_array(mxArray *pa)
{
    double tmp;
    int i,j,jj;
    /* Remember, MATLAB stores matrices in their transposed form,
       i.e., columnwise, like FORTRAN. */

    /* Fill real and imaginary parts of array. */
    for (j = 0; j < 4; j++) {
        for (i = 0; i <= j; i++) {
            XR(i,j) = 4 + i - j;
            XR(j,i) = XR(i,j);
            XI(i,j) = j - i + 1;
            XI(j,i) = XI(i,j);
        }
    }
    /* Reorder columns of xr. */
    for (j = 0; j < 2; j++) {
        for (i = 0; i < 4; i++) {
            tmp = XR(i,j);
            jj = 3 - j;
            XR(i,j) = XR(i,jj);
            XR(i,jj) = tmp;
        }
    }
}


/* Invert diagonal elements of complex matrix of order 4 */
static void invertd(mxArray *pa)
{
    double temp;
    int i;
    
    for(int i=0;i<4;i++) {
       temp = XR(i,i) * XR(i,i) + XI(i,i) *XI(i,i);
       XR(i,i) = XR(i,i)/temp;
       XI(i,i) = - XI(i,i)/temp;
    }
}

void 
mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray	*prhs[])
{
    mwSize m, n;
    mxArray *lhs[2], *x;
    (void) prhs;           /* unused parameter */
    
    m = n = 4;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 0) {
        mexErrMsgIdAndTxt( "MATLAB:mexcallmatlab:maxrhs",
                "No input arguments required.");
    } 
    if(nlhs > 1){
        mexErrMsgIdAndTxt( "MATLAB:mexcallmatlab:maxlhs",
                "Too many output arguments.");
    } 
    
    /* Allocate x matrix */
    x =  mxCreateDoubleMatrix(m, n, mxCOMPLEX);
    
    /* create values in some arrays -- remember, MATLAB stores matrices
       column-wise */
    fill_array(x);
    
    /* print out initial matrix */
    mexCallMATLAB(0,NULL,1, &x, "disp");
    
    /* calculate eigenvalues and eigenvectors */
    mexCallMATLAB(2, lhs, 1, &x, "eig");
    /* print out eigenvalue matrix */
    mexCallMATLAB(0,NULL,1, &lhs[1], "disp");
    
    /* take inverse of complex eigenvalues, just on diagonal */
    invertd(lhs[1]);
    /* and print these out */
    mexCallMATLAB(0,NULL,1, &lhs[1], "disp");
    
    /* Free allocated matrices */
    mxDestroyArray(x);
    mxDestroyArray(lhs[1]);
    plhs[0] = lhs[0];
}

/* LocalWords:  columnwise xr maxlhs
 */
