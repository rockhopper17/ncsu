#include "fintrf.h"
C======================================================================
C
C     complexAdd.F
C     This function accepts two complex double arrays of same size
C     and returns the sum of the complex numbers.
C
C     This is a MEX-file for MATLAB.
C     Copyright 2018 The MathWorks, Inc.
C
C======================================================================

C-----------------------------------------------------------------------
C
C   Subroutine to validate inputs and number of outputs passed to
C   function.
C
      subroutine validate(nlhs, plhs, nrhs, prhs)
      implicit none
      integer  nlhs, nrhs
      mwPointer mxGetM, mxGetN
      integer  mxIsComplex, mxIsDouble
      mwpointer  plhs(*), prhs(*)

      if (nrhs .ne. 2) then
         call mexErrMsgIdAndTxt ('MATLAB:complexAdd:nInput',
     +                           'Two input required.')
      endif

      if (nlhs .gt. 1) then
         call mexErrMsgIdAndTxt ('MATLAB:complexAdd:nOutput',
     +                           'Maximum One output supported.')
      endif

      if (((mxIsComplex(prhs(1))) .ne. 1) .or.
     +    ((mxIsComplex(prhs(2))) .ne. 1)) then

         call mexErrMsgIdAndTxt ('MATLAB:complexAdd:NonComplex',
     +                           'Inputs must be complex Doubles.')
      endif

      if ((mxIsDouble(prhs(1))) .ne. 1 .or.
     +    (mxIsDouble(prhs(2))) .ne. 1) then

         call mexErrMsgIdAndTxt ('MATLAB:complexAdd:NonDouble',
     +                           'Inputs must be complex Doubles.')
      endif

      if ((mxGetM(prhs(1))) .ne. (mxGetM(prhs(2))) .or.
     +    (mxGetN(prhs(1))) .ne. (mxGetN(prhs(2)))) then
         call mexErrMsgIdAndTxt (
     +                           'MATLAB:complexAdd:dimensionmismatch',
     +                           'Inputs must be of same dimensions.')
      endif
      end

C   Subroutine to perform addition of matrices.
C
#if MX_HAS_INTERLEAVED_COMPLEX
      subroutine addMatrix(prhs1,prhs2,plhs1,nl)
      implicit none
      mwpointer  prhs1,prhs2,plhs1
      mwSize     nl
      complex*16 complexDataFirstMatrix(nl)
      complex*16 complexDataSecondMatrix(nl)
      complex*16 complexDataResult(nl)
      integer*4  i, status
      integer*4  mxCopyPtrToComplex16, mxCopyComplex16ToPtr
      real*8     realVal1, realVal2, complexVal1, complexVal2
C-----------------------------------------------------------------------
      status =
     +   mxCopyPtrToComplex16(prhs1, complexDataFirstMatrix, nl)

      if (status.ne. 1) then
         call mexErrMsgIdAndTxt ('MATLAB:complexAdd:copyingfailed',
     +        'Could not copy first input matrix.')
      endif

      status =
     + mxCopyPtrToComplex16(prhs2, complexDataSecondMatrix, nl)

      if (status.ne. 1) then
         call mexErrMsgIdAndTxt ('MATLAB:complexAdd:copyingfailed',
     +        'Could not copy second input matrix.')
      endif

      do 100 i=1,nl
        complexDataResult(i) = complexDataFirstMatrix(i) +
     +     complexDataSecondMatrix(i)
 100  continue

      status =
     +  mxCopyComplex16ToPtr(complexDataResult, plhs1, nl)

      if (status.ne. 1) then
         call mexErrMsgIdAndTxt ('MATLAB:complexAdd:copyingfailed',
     +        'Could not copy result matrix.')
      endif

      end
#else
      subroutine addMatrix(prhsreal1, prhsreal2,
     +           prhsimag1, prhsimag2, plhsreal, plhsimag, nl)
      implicit none
      mwPointer prhsimag1, prhsimag2, plhsimag
      mwPointer prhsreal1, prhsreal2, plhsreal
      mwSize     nl
      integer*4  i
      real*8 firstMatrixRealPart(nl)
      real*8 secondMatrixRealPart(nl)
      real*8 resultMatrixRealPart(nl)
      real*8 firstMatrixComplexPart(nl)
      real*8 secondMatrixComplexPart(nl)
      real*8 resultMatrixComplexPart(nl)

      call mxCopyPtrToReal8(prhsreal1, firstMatrixRealPart, nl)
      call mxCopyPtrToReal8(prhsreal2, secondMatrixRealPart, nl)
      call mxCopyPtrToReal8(prhsimag1, firstMatrixComplexPart, nl)
      call mxCopyPtrToReal8(prhsimag2, secondMatrixComplexPart, nl)
      do 200 i=1,nl
          resultMatrixRealPart(i) =
     +        firstMatrixRealPart(i) + secondMatrixRealPart(i)
          resultMatrixComplexPart(i) =
     +        firstMatrixComplexPart(i) + secondMatrixComplexPart(i)
 200  continue
      call mxCopyReal8ToPtr(resultMatrixRealPart, plhsreal, nl)
      call mxCopyReal8ToPtr(resultMatrixComplexPart, plhsimag, nl)
      end
#endif


C-----------------------------------------------------------------------
C     Gateway routine
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
      integer  nlhs, nrhs
      mwPointer mxGetM, mxGetN
C-----------------------------------------------------------------------
      mwpointer  plhs(*), prhs(*)
      mwpointer  mxCreateNumericMatrix
      mwSize     nl, mxGetNumberOfElements
      integer    vi, mxGetClassId

#if MX_HAS_INTERLEAVED_COMPLEX
      mwpointer  mxGetComplexDoubles, prhs1, prhs2, plhs1

      call validate(nlhs, plhs, nrhs, prhs)
      vi = mxGetClassId(prhs(1))
      plhs(1) = mxCreateNumericMatrix(mxGetM(prhs(1)),
     +                mxGetN(prhs(1)),vi,1)

      plhs1 = mxGetComplexDoubles(plhs(1))
      prhs1 = mxGetComplexDoubles(prhs(1))
      prhs2 = mxGetComplexDoubles(prhs(2))

      nl = mxGetNumberOfElements(prhs(1))
      call addMatrix(prhs1,prhs2,plhs1,nl)
#else
      mwPointer mxGetPi, prhsimag1, prhsimag2, plhsimag
      mwPointer mxGetPr, prhsreal1, prhsreal2, plhsreal

      call validate(nlhs, plhs, nrhs, prhs)
      vi = mxGetClassId(prhs(1))
      plhs(1) = mxCreateNumericMatrix(mxGetM(prhs(1)),
     +                mxGetN(prhs(1)),vi,1)
      prhsreal1 = mxGetPr(prhs(1))
      prhsreal2 = mxGetPr(prhs(2))
      plhsreal = mxGetPr(plhs(1))
      prhsimag1 = mxGetPi(prhs(1))
      prhsimag2 = mxGetPi(prhs(2))
      plhsimag = mxGetPi(plhs(1))

      nl = mxGetNumberOfElements(prhs(1))
      call addMatrix(prhsreal1, prhsreal2,
     +           prhsimag1, prhsimag2, plhsreal, plhsimag, nl)
#endif

      return
      end
