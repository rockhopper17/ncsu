#include "fintrf.h"      
C======================================================================
C
#if 0
C     
C     convec.F
C     .F file needs to be preprocessed to generate .for equivalent
C     
#endif
C     
C     convec.f
C     Example for illustrating how to pass complex data from MATLAB
C     to FORTRAN (using COMPLEX data type) and back again.
C
C     Convolves two complex input vectors
C      
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2018 The MathWorks, Inc.
C     
C======================================================================
C     Computational subroutine

      subroutine convec(x,y,z,nx,ny)
      complex*16 x(*), y(*), z(*)
      mwSize nx, ny

C     Initialize the output array
      do 10 i=1,nx+ny-1
         z(i) = (0.0,0.0)
 10   continue

      do 30 i=1,nx
         do 20 j=1,ny
            z(i+j-1) = z(i+j-1) + x(i) * y(j)
 20      continue
 30   continue
      return
      end

C-----------------------------------------------------------------------
C     Gateway routine
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)

C     Declarations
      implicit none

C     mexFunction arguments:
      mwPointer plhs(*), prhs(*)
      integer nlhs, nrhs

C     Function declarations:
      mwPointer mxCreateDoubleMatrix
      mwPointer mxGetM, mxGetN
#if MX_HAS_INTERLEAVED_COMPLEX
      mwPointer mxGetComplexDoubles
      integer*4 status
      integer*4 mxCopyPtrToComplex16, mxCopyComplex16ToPtr
#else
      mwPointer mxGetPr, mxGetPi
#endif
      integer*4 mxIsComplex
      
C     Array information:
      mwPointer mx, nx, my, ny, nz
      mwSize row

      complex*16 x(100), y(100), z(199)

C-----------------------------------------------------------------------
C     Check for proper number of arguments. 
      if (nrhs .ne. 2) then
         call mexErrMsgIdAndTxt ('MATLAB:convec:nInput',
     +                           'Two inputs required.')
      elseif (nlhs .gt. 1) then
         call mexErrMsgIdAndTxt ('MATLAB:convec:nOutput',
     +                           'Too many output arguments.')
      endif

C     Validate inputs
      mx = mxGetM(prhs(1))
      nx = mxGetN(prhs(1))
      my = mxGetM(prhs(2))
      ny = mxGetN(prhs(2))

C     Check that inputs are row vectors.
      if(mx .ne. 1 .or. my .ne. 1) then
         call mexErrMsgIdAndTxt ('MATLAB:convec:NonRowVector',
     +                           'Inputs must be row vectors.')
C     Check size of the inputs.
      elseif(nx .gt. 100 .or. ny .gt. 100) then
         call mexErrMsgIdAndTxt ('MATLAB:convec:MaxElements',
     +                 'Inputs must have less than 100 elements.')
C     Check if inputs are complex.
      elseif ((mxIsComplex(prhs(1)) .ne. 1) .or.           
     +        (mxIsComplex(prhs(2)) .ne. 1)) then
         call mexErrMsgIdAndTxt ('MATLAB:convec:NonComplex',
     +                           'Inputs must be complex.')
      endif

C     Create the output array.
      row = 1
      nz = nx+ny-1
      plhs(1) = mxCreateDoubleMatrix(row, nz, 1)

C     Load the data into Fortran arrays(native COMPLEX data).
#if MX_HAS_INTERLEAVED_COMPLEX

      status = 
     +   mxCopyPtrToComplex16(mxGetComplexDoubles(prhs(1)),x,nx)
      if (status .ne. 1) then
            call mexErrMsgIdAndTxt (
     +              'MATLAB:convec:CopyingFailed',
     +              'Could not copy from prhs(1) to complex*16.')
      endif

      status =
     +   mxCopyPtrToComplex16(mxGetComplexDoubles(prhs(2)),y,ny)

      if (status .ne. 1) then
            call mexErrMsgIdAndTxt (
     +              'MATLAB:convec:CopyingFailed',
     +              'Could not copy from prhs(2) to complex*16.')
      endif
#else
      call mxCopyPtrToComplex16(mxGetPr(prhs(1)),
     +                          mxGetPi(prhs(1)),x,nx)
      call mxCopyPtrToComplex16(mxGetPr(prhs(2)),
     +                          mxGetPi(prhs(2)),y,ny)
#endif

C     Call the computational subroutine.
      call convec(x,y,z,nx,ny)

C     Load the output into a MATLAB array.
#if MX_HAS_INTERLEAVED_COMPLEX
      status =
     +   mxCopyComplex16ToPtr(z,mxGetComplexDoubles(plhs(1)),nz)
      if (status .ne. 1) then
            call mexErrMsgIdAndTxt (
     +              'MATLAB:convec:CopyingFailed',
     +              'Could not copy from complex*16 to plhs(1).')
      endif
#else
      call mxCopyComplex16ToPtr(z,mxGetPr(plhs(1)),
     +                          mxGetPi(plhs(1)),nz)

      return
#endif
      end
