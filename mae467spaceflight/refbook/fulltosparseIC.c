/*=================================================================
* fulltosparseIC.c
* This example demonstrates how to populate a sparse
* matrix.  For the purpose of this example, you must pass in a
* non-sparse 2-dimensional argument of type double.
*
* This example uses interleaved complex representation for complex numbers,
* Please refer to fulltosparse.c for an example which uses separate complex.
*
* Use the following command to build MEX file using interleaved complex:
* mex -R2018a fulltosparseIC.c
*
* This is a MEX-file for MATLAB.
* Copyright 2017 The MathWorks, Inc.
* All rights reserved.
*=================================================================*/


#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"

#define IsNonZero(d) ((d)!=0.0)

void
mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    #if MX_HAS_INTERLEAVED_COMPLEX
        /* Declare variable */
        mwSize m,n;
        mwSize nzmax;
        mwIndex *irs,*jcs,j,k;
        int cmplx;
        double percent_sparse;

        /* Check for proper number of input and output arguments */
        if (nrhs != 1) {
            mexErrMsgIdAndTxt( "MATLAB:fulltosparseIC:invalidNumInputs",
                    "One input argument required.");
        }
        if(nlhs > 1){
            mexErrMsgIdAndTxt( "MATLAB:fulltosparseIC:maxlhs",
                    "Too many output arguments.");
        }

        /* Check data type of input argument  */
        if (!(mxIsDouble(prhs[0]))){
            mexErrMsgIdAndTxt( "MATLAB:fulltosparseIC:inputNotDouble",
                    "Input argument must be of type double.");
        }

        if (mxGetNumberOfDimensions(prhs[0]) != 2){
            mexErrMsgIdAndTxt( "MATLAB:fulltosparseIC:inputNot2D",
                    "Input argument must be two dimensional\n");
        }

        /* Get the size and pointers to input data */
        m  = mxGetM(prhs[0]);
        n  = mxGetN(prhs[0]);

        cmplx = mxIsComplex(prhs[0]);

        /* Allocate space for sparse matrix
         * NOTE:  Assume at most 20% of the data is sparse.  Use ceil
         * to cause it to round up.
         */

        percent_sparse = 0.2;
        nzmax=(mwSize)ceil((double)m*(double)n*percent_sparse);

        plhs[0] = mxCreateSparse(m,n,nzmax,cmplx);

        irs = mxGetIr(plhs[0]);
        jcs = mxGetJc(plhs[0]);

        if(cmplx) {
            mxComplexDouble * pc, *sc;
            pc = mxGetComplexDoubles(prhs[0]);
            sc = mxGetComplexDoubles(plhs[0]);

            /* Copy nonzeros */
            k = 0;
            for (j=0; (j<n); j++) {
                mwSize i;
                jcs[j] = k;
                for (i=0; (i<m ); i++) {
                    if (IsNonZero(pc[i].real) || IsNonZero(pc[i].imag)) {

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
                            mxSetComplexDoubles(plhs[0], mxRealloc(sc, nzmax*sizeof(mxComplexDouble)));

                            mxSetIr(plhs[0], mxRealloc(irs, nzmax*sizeof(mwIndex)));

                            sc  = mxGetComplexDoubles(plhs[0]);
                            irs = mxGetIr(plhs[0]);
                        }
                        sc[k].real = pc[i].real;
                        sc[k].imag = pc[i].imag;
                        irs[k] = i;
                        k++;
                    }
                }
                pc += m;
            }
            jcs[n] = k;
        }
        // If input matrix contains only real numbers.
        else {
            double *pr, *sr;
            pr = mxGetDoubles(prhs[0]);
            sr  = mxGetDoubles(plhs[0]);

            /* Copy nonzeros */
            k = 0;
            for (j=0; (j<n); j++) {
                mwSize i;
                jcs[j] = k;
                for (i=0; (i<m ); i++) {
                    if (IsNonZero(pr[i])) {

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
                            mxSetDoubles(plhs[0], mxRealloc(sr, nzmax*sizeof(double)));
                            mxSetIr(plhs[0], mxRealloc(irs, nzmax*sizeof(mwIndex)));

                            sr  = mxGetDoubles(plhs[0]);
                            irs = mxGetIr(plhs[0]);
                        }
                        sr[k] = pr[i];
                        irs[k] = i;
                        k++;
                    }
                }
                pr += m;
            }
            jcs[n] = k;
        }
    /* If the mex file was not built using interleaved complex flag, display
     * an error and exit.
     */
    #else
        mexErrMsgIdAndTxt( "MATLAB:fulltosparseIC:invalidBuild",
        "This example supports interleaved complex representation only."
        "\nPlease use interleaved complex flag with the mex command."
        "\n\nPlease use following command to compile using interleaved complex:"
        "\nmex -R2018a fulltosparseIC.c");
    #endif
}
