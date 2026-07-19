/*=================================================================
 * mxgetproperty.c 
 *
 * This example demonstrates how to use mxGetProperty and mxSetProperty.  The input
 * to this function is a handle graphics handle.  mxgetproperty.c gets the
 * Color property of the handle that was passed into the function. It
 * then changes the colors, and uses mxSetProperty to set the Color property
 * of the handle to the new color values.
 *
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2016 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/

#include "mex.h"

#define RED   0
#define GREEN 1
#define BLUE  2

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
		 const mxArray *prhs[])
{
    mxArray *color_array_ptr;
    mxArray       *value;
    double        *color; 
    const char    *className;
    (void) plhs;      /* unused parameters */

    /* Assume that the first input argument is a graphics
       handle. Check to make sure the input is a double and that only
       one input is specified.*/
    
    if(nrhs != 1)
        mexErrMsgIdAndTxt( "MATLAB:mxgetproperty:minrhs",
                "Not enough input arguments.");
    
    /* Check for the correct number of outputs */
    if(nlhs > 1) {
        mexErrMsgIdAndTxt( "MATLAB:mxgetproperty:maxlhs",
                "Too many output arguments.");
    }
        
   /* Check to make sure input argument is a object */
        
    className = mxGetClassName(prhs[0]);
     if(strncmp(className,"matlab.graphics",15)) {
        mexErrMsgIdAndTxt( "MATLAB:mxgetproperty:inputMustBeObject",
                "Must be called with a valid graphics handle.\n");
     }
    
    /* Get the "Color" property associated with this handle. */
    color_array_ptr = mxGetProperty(prhs[0],0,"Color");
    
    if (color_array_ptr == NULL)
      mexErrMsgIdAndTxt( "MATLAB:mxgetproperty:errGettingHandleProperty",
              "Could not get this handle property");
    
   /* Make copy of "Color" propery */
    value = mxDuplicateArray(color_array_ptr);
    
    /* The returned "Color" property is a 1-by-3 matrix of 
       primary colors. */ 
    color = mxGetPr(value);
    
    /* Change the color values */
    color[RED] = (1 + color[RED]) /2;
    color[GREEN] = color[GREEN]/2;
    color[BLUE] = color[BLUE]/2;
    
    /* Reset the "Color" property to use the new color. */
    mxSetProperty(mxDuplicateArray(prhs[0]),0,"Color",value);
}
