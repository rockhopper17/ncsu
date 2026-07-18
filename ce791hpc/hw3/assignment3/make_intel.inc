CC = icc
CFLAGS = -Ofast -w -I/usr/local/intel/mkl/include
FF = ifort
FFLAGS = -Ofast -I/usr/local/intel/mkl/include
CPPFLAGS = -DALLOC 
CPPFLAGS_OPT = -DBLAS -DINTEL
LDFLAGS = 
LDFLAGS_BLAS = -L/usr/local/intel/mkl/lib/intel64 -lmkl_core -lmkl_intel_lp64 -lmkl_sequential
LDFLAGS_BLASC = -L/usr/local/intel/mkl/lib/intel64 -lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lpthread -ldl -lm
#-L/usr/local/intel/compiler70/ia32/lib -lIEPCF90 -lF90 -lintrins
# CPP location
CPP = /lib/cpp -traditional -P
