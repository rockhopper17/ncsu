/**
 * mexcallmatlabwithtrap.c 
 *
 * This example demonstrates how to use mexCallMATLABWithTrap. 
 *
 * Copyright 2011 The MathWorks, Inc.
 */

#include "mex.h"

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray * exception = NULL;
    char * function_name;

    (void) plhs;      /* unused parameter */

    /* Check for proper number of input and output arguments */    
    if(nrhs !=1) { 
        mexErrMsgIdAndTxt( "MATLAB:mexcallmatlabwithtrap:invalidInput",
                           "Only one input argument allowed");
    } else if( mxGetClassID( prhs[0] ) != mxCHAR_CLASS ) {
        mexErrMsgIdAndTxt( "MATLAB:mexcallmatlabwithtrap:invalidInput",
                           "Input argument must be a string");
    }
 
    if(nlhs > 0) {
        mexErrMsgIdAndTxt( "MATLAB:mexcallmatlabwithtrap:maxlhs",
                           "Too many output arguments.");
    }

    function_name = mxArrayToString( prhs[0] );

    /* Invoke the function specified as the first input, which must take 
     * zero inputs and have zero outputs */
    exception = mexCallMATLABWithTrap(0, (mxArray **)NULL, 
                                      0, (mxArray **)NULL, function_name);

    if(exception != NULL) {
        /* Throw the MException returned by mexCallMATLABWithTrap
         * after cleaning up any dynamically allocated resources */
        mxFree( function_name );
        mexCallMATLAB(0, (mxArray **)NULL, 
                      1, &exception, "throw");
    }

    mexPrintf("%s called successfully\n", function_name);
    mxFree( function_name );
}
