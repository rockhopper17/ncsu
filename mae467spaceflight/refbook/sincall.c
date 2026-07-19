/*=====================================================================
 * sincall.c
 *
 * example for illustrating how to use mexCallMATLAB
 * 
 * creates an mxArray and passes its associated  pointers (in this demo,
 * only pointer to its real part, pointer to number of rows, pointer to
 * number of columns) to subfunction fill() to get data filled up, then 
 * calls mexCallMATLAB to calculate sin function and plot the result.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2013 The MathWorks, Inc.
 *===================================================================*/
#include "mex.h"
#define MAX 1000

/* subroutine for filling up data */
void fill( double *pr, mwSize *pm, mwSize *pn, mwSize max )
{
    mwSize i;  
    /* you can fill up to max elements, so (*pr)<=max */
    *pm = max/2;
    *pn = 1;
    for (i=0; i < (*pm); i++) 
      pr[i]=i*(4*3.14159/max);
}

/* gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    mwSize m, n, max=MAX;
    mxArray *rhs[1], *lhs[1];
    mxArray *inplot[2];          /* input to plot function */

    (void) nlhs; (void) plhs;    /* unused parameters */
    (void) nrhs; (void) prhs;

    rhs[0] = mxCreateDoubleMatrix(max, 1, mxREAL);

    /* pass the pointers and let fill() fill up data */
    fill(mxGetPr(rhs[0]), &m, &n, MAX);
    mxSetM(rhs[0], m);
    mxSetN(rhs[0], n);

    inplot[0] = mxDuplicateArray(rhs[0]);   

    /* get the sin wave */
    mexCallMATLAB(1, lhs, 1, rhs, "sin");

    inplot[1] = mxDuplicateArray(lhs[0]);
    
    /* plot(rhs, sin(rhs)) */
    mexCallMATLAB(0, NULL, 2, inplot, "plot");

    /* cleanup allocated memory */
    mxDestroyArray(rhs[0]);
    mxDestroyArray(lhs[0]);
    mxDestroyArray(inplot[0]);
    mxDestroyArray(inplot[1]);
    
    return;
}
