#include <fintrf.h>
C
C yprimefg.F - Gateway function for yprime.F
C
C This is an example of the FORTRAN code required for interfacing
C a .MEX file to MATLAB.
C
C This subroutine is the main gateway to MATLAB.  When a MEX function
C is executed MATLAB calls the MEXFUNCTION subroutine in the corresponding
C MEX file.  
C
C Copyright 1984-2018 The MathWorks, Inc.
C 
C
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C
      mwPointer plhs(*), prhs(*)

C-----------------------------------------------------------------------
C

      integer nlhs, nrhs
C
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      mwPointer mxCreateDoubleMatrix

#if MX_HAS_INTERLEAVED_COMPLEX
      mwPointer mxGetDoubles
#else	  
      mwPointer mxGetPr
#endif

C-----------------------------------------------------------------------
C

      mwPointer mxGetM, mxGetN
C
C Keep the above subroutine, argument, and function declarations for use
C in all your Fortran Mex Files.
C
C---------------------------------------------------------------------
C
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      mwPointer ypp, tp, yp

C-----------------------------------------------------------------------
C
      mwPointer m, n
      mwSize  nel
      real*8 rypp(4), rtp, ryp(4)

#if defined MSWIND
C For Windows only!
C This resets the floating point exception to allow divide by zero,
C overflow and invalid numbers. 
C
      integer(2) control
      call getControlFPQQ(control)
      control = control .or. FPCW$ZERODIVIDE
      control = control .or. FPCW$INVALID
      control = control .or. FPCW$OVERFLOW
      call setControlFPQQ(control)
#endif
C
C Validate input and output arguments.
C
      if (nrhs .ne. 2) then
            call mexErrMsgTxt('YPRIME requires two input arguments')
      elseif (nlhs .gt. 1) then
            call mexErrMsgTxt('YPRIME requires one output argument')
      endif
C
C Validate input arguments to make sure Y has dimensions 1 x 4 or 4 x 1.
C
      m = mxGetM(prhs(2))
      n = mxGetN(prhs(2))
C
      if ((max(m,n) .ne. 4) .or. (min(m,n) .ne. 1)) then
        call mexErrMsgTxt('YPRIME requires that Y be a 4 x 1 vector')
      endif
C
C Create a new matrix to store result.
C
      plhs(1) = mxCreateDoubleMatrix(m,n,0)
C
C Get pointers to input and result arrays.
C
#if MX_HAS_INTERLEAVED_COMPLEX
      ypp = mxGetDoubles(plhs(1))
C
      tp = mxGetDoubles(prhs(1))
      yp = mxGetDoubles(prhs(2))
#else
      ypp = mxGetPr(plhs(1))
C
      tp = mxGetPr(prhs(1))
      yp = mxGetPr(prhs(2))
#endif

C
C Copy input arguments to local arrays.
      nel = 1
      call mxCopyPtrToReal8(tp, rtp, nel)
      nel = 4
      call mxCopyPtrToReal8(yp, ryp, nel)
C
C Perform computations on input arrays.
C
      call yprime(rypp,rtp,ryp)
C
C Copy result from local array to output array.
      nel = 4
      call mxCopyReal8ToPtr(rypp, ypp, nel)
C
      return
      end
