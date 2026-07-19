/*=================================================================
* fulltosparse.c
* This example demonstrates how to populate a sparse
* matrix.  For the purpose of this example, you must pass in a
* non-sparse 2-dimensional argument of type double.
*
* This example uses separate complex representation for complex numbers,
* Please refer to fulltosparseIC.c for an example which uses interleaved complex.
*
* Use the following command to build MEX file using separate complex:
* mex -R2017b fulltosparse.c
*
* This is a MEX-file for MATLAB.  
* Copyright 1984-2017 The MathWorks, Inc.
* All rights reserved.
*=================================================================*/


#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"

#define IsNonZero(d) ((d)!=0.0)


void mexFunction(
		 int nlhs,       mxArray *plhs[],
		 int nrhs, const mxArray *prhs[]
		 )
{
    /* If the mex file was built using interleaved complex flag, display
     * an error and exit.
     */
    #if MX_HAS_INTERLEAVED_COMPLEX
        mexErrMsgIdAndTxt( "MATLAB:fulltosparse:invalidBuild",
            "This example supports separate complex representation only."
            "\nPlease do not use interleaved complex flag with mex command."
            "\n\nPlease use following command to compile using separate complex:"
            "\nmex -R2017b fulltosparse.c");
    #else
        /* Declare variable */
        mwSize m,n;
        mwSize nzmax;
        mwIndex *irs,*jcs,j,k;
        int cmplx;
        double *pr,*pi,*si,*sr;
        double percent_sparse;

        /* Check for proper number of input and output arguments */
        if (nrhs != 1) {
            mexErrMsgIdAndTxt( "MATLAB:fulltosparse:invalidNumInputs",
                    "One input argument required.");
        }
        if(nlhs > 1){
            mexErrMsgIdAndTxt( "MATLAB:fulltosparse:maxlhs",
                    "Too many output arguments.");
        }

        /* Check data type of input argument  */
        if (!(mxIsDouble(prhs[0]))){
            mexErrMsgIdAndTxt( "MATLAB:fulltosparse:inputNotDouble",
                    "Input argument must be of type double.");
        }

        if (mxGetNumberOfDimensions(prhs[0]) != 2){
            mexErrMsgIdAndTxt( "MATLAB:fulltosparse:inputNot2D",
                    "Input argument must be two dimensional\n");
        }

        /* Get the size and pointers to input data */
        m  = mxGetM(prhs[0]);
        n  = mxGetN(prhs[0]);
        pr = mxGetPr(prhs[0]);
        pi = mxGetPi(prhs[0]);
        cmplx = (pi==NULL ? 0 : 1);

        /* Allocate space for sparse matrix
         * NOTE:  Assume at most 20% of the data is sparse.  Use ceil
         * to cause it to round up.
         */

        percent_sparse = 0.2;
        nzmax=(mwSize)ceil((double)m*(double)n*percent_sparse);

        plhs[0] = mxCreateSparse(m,n,nzmax,cmplx);
        sr  = mxGetPr(plhs[0]);
        si  = mxGetPi(plhs[0]);
        irs = mxGetIr(plhs[0]);
        jcs = mxGetJc(plhs[0]);

        /* Copy nonzeros */
        k = 0;
        for (j=0; (j<n); j++) {
            mwSize i;
            jcs[j] = k;
            for (i=0; (i<m ); i++) {
                if (IsNonZero(pr[i]) || (cmplx && IsNonZero(pi[i]))) {

                    /* Check to see if non-zero element will fit in
                     * allocated output array.  If not, increase percent_sparse
                     * by 10%, recalculate nzmax, and augment the sparse array
                     */
                    if (k>=nzmax) {
                        mwSize oldnzmax = nzmax;
                        percent_sparse += 0.1;
                        nzmax = (mwSize)ceil((double)m*(double)n*percent_sparse);

                        /* make sure nzmax increases at least by 1 */
                        if (oldnzmax >= nzmax) {
                            nzmax = oldnzmax+1;
                        }

                        mxSetNzmax(plhs[0], nzmax);
                        mxSetPr(plhs[0], mxRealloc(sr, nzmax*sizeof(double)));
                        if(si != NULL) {
                            mxSetPi(plhs[0], mxRealloc(si, nzmax*sizeof(double)));
                        }
                        mxSetIr(plhs[0], mxRealloc(irs, nzmax*sizeof(mwIndex)));

                        sr  = mxGetPr(plhs[0]);
                        si  = mxGetPi(plhs[0]);
                        irs = mxGetIr(plhs[0]);
                    }
                    sr[k] = pr[i];
                    if (cmplx) {
                        si[k]=pi[i];
                    }
                    irs[k] = i;
                    k++;
                }
            }
            pr += m;
            pi += m;
        }
        jcs[n] = k;
    #endif
}
