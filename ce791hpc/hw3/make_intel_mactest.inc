//CC = icc
CC = gcc
CFLAGS = -Ofast -w -I/usr/local/intel/mkl/include
//CFLAGS_macos = -Ofast -w -DMKL_ILP64 -m64 -I${MKLROOT}/include
FF = ifort
FFLAGS = -Ofast -I/usr/local/intel/mkl/include
CPPFLAGS = -DALLOC 
CPPFLAGS_OPT = -DBLAS -DINTEL
LDFLAGS = 
LDFLAGS_macos = ${MKLROOT}/lib/libmkl_intel_ilp64.a ${MKLROOT}/lib/libmkl_sequential.a ${MKLROOT}/lib/libmkl_core.a -lpthread -lm -ldl
LDFLAGS_BLAS = -L/usr/local/intel/mkl/lib/intel64 -lmkl_core -lmkl_intel_lp64 -lmkl_sequential
LDFLAGS_BLASC = -L/usr/local/intel/mkl/lib/intel64 -lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lpthread -ldl -lm
#-L/usr/local/intel/compiler70/ia32/lib -lIEPCF90 -lF90 -lintrins
# CPP location
CPP = /lib/cpp -traditional -P
