#include "mex.h"

/*
 * mexfeval.c : Example MEX-file code emulating the functionality of the
 *              MATLAB command FEVAL
 *
 *              
 * Copyright 1984-2017 The MathWorks, Inc.
 */


void
mexFunction( int nlhs, mxArray *plhs[],
	     int nrhs, const mxArray *prhs[] )
{
  if(nrhs==0)
    mexErrMsgIdAndTxt( "MATLAB:mexfeval:minrhs",
            "Not enough input arguments.");

  if(!mxIsChar(prhs[0]))
    mexErrMsgIdAndTxt( "MATLAB:mexfeval:invalidInput",
            "Variable must contain a string.");
  
  else {
    /*
     * overloaded functions could be a problem
     */
    mxArray **in;
    
    char *fcn;
    size_t buflen=mxGetN(prhs[0])+1;
    int status, i;

    fcn=(char *)mxCalloc(buflen,sizeof(char));
    status=mxGetString(prhs[0],fcn,(mwSize)buflen);

    if (status != 0) {
        mexErrMsgIdAndTxt( "MATLAB:mexfeval:mxGetString",
                           "Failed to copy input string into allocated memory.");
    }
    
    in=(mxArray **)mxCalloc(nrhs-1,sizeof(mxArray *));
    
    for(i=0;i<nrhs-1;i++) 
      in[i]=mxDuplicateArray(prhs[i+1]);

    status=mexCallMATLAB(nlhs,plhs,nrhs-1,in,fcn);

    if (status != 0) {
        mexErrMsgIdAndTxt( "MATLAB:mexfeval:mexCallMATLAB",
                           "mexCallMATLAB failed."); 
    }

    mxFree(fcn);
    for(i=0;i<nrhs-1;i++) 
      mxDestroyArray(in[i]);
    mxFree(in);
    
  }
}
