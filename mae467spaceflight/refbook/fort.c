/*=========================================================
 * fort.c
 * auxiliary routines for conversion between
 * separate complex MATLAB (R2017b and earlier)
 * and FORTRAN complex data structures.
 *
 * To build myfnc.c MEX file:
 * mex -R2017b myfnc.c
 *
 * Copyright 1984-2017 The MathWorks, Inc.
 *=======================================================*/
#include "mex.h"
#include "stddef.h"

/*
 * Convert MATLAB complex matrix to Fortran complex storage.
 * Z = mat2fort(X,ldz,ndz) converts MATLAB's mxArray X to Fortran's
 * complex*16 Z(ldz,ndz).  The parameters ldz and ndz determine the
 * storage allocated for Z, while mxGetM(X) and mxGetN(X) determine
 * % the amount of data copied.
 */

double* mat2fort(
        const mxArray *X,
        ptrdiff_t ldz,
        ptrdiff_t ndz
        )
{
    ptrdiff_t incz;
    size_t i,j;
    size_t m,n;
    int cmplxflag;
    double *Z,*zp;
    double *xr;
    
    double *xi;
    
    Z = (double *) mxCalloc(2*ldz*ndz, sizeof(double));
    m = mxGetM(X);
    n = mxGetN(X);
    zp = Z;
    incz = 2*(ldz-m);
    xr = mxGetPr(X);
    xi = mxGetPi(X);
    cmplxflag = (xi != NULL);
    for (j = 0; j < n; j++) {
        if (cmplxflag) {
            for (i = 0; i < m; i++) {
                *zp++ = *xr++;
                *zp++ = *xi++;
            }
        } else {
            for (i = 0; i < m; i++) {
                *zp++ = *xr++;
                zp++;
            }
        }
        zp += incz;
    }
    return(Z);
   
}


/*
 * Convert Fortran complex storage to MATLAB real and imaginary parts.
 * X = fort2mat(Z,ldz,m,n) copies Z to X, producing a complex mxArray
 * with mxGetM(X) = m and mxGetN(X) = n.
 */

mxArray* fort2mat(
        double *Z,
        ptrdiff_t ldz,
        mwSize m,
        mwSize n
        )
{
    size_t i,j;
    ptrdiff_t incz;
    double *zp;
    mxArray *X;
    double *xi, *xr;
    
    X = mxCreateDoubleMatrix(m,n,mxCOMPLEX);
    xr = mxGetPr(X);
    xi = mxGetPi(X);
    zp = Z;
    incz = 2*(ldz-m);
    for (j = 0; j < n; j++) {
        for (i = 0; i < m; i++) {
            *xr++ = *zp++;
            *xi++ = *zp++;
        }
        zp += incz;
    }
    return(X);
}

