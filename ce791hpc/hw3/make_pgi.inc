CC = pgcc
CFLAGS = -O3 -w -I/usr/local/apps/acml/acml4.3.0/pgi64/include
FF = pgf90
FFLAGS = -O3 -fast -Mfree -I/usr/local/apps/acml/acml4.3.0/pgi64/include
CPPFLAGS = -DALLOC
CPPFLAGS_OPT = -DBLAS -DACML
LDFLAGS = 
#LDFLAGS_BLAS = -L/soft/acml/5.3.0/pgi64/lib -lacml
#LDFLAGS_BLASC = -L/soft/acml/5.3.0/pgi64/lib -lacml
LDFLAGS_BLAS = -L/usr/local/apps/acml/acml4.3.0/pgi64/lib -lacml -lacml_mv
LDFLAGS_BLASC = -L/usr/local/apps/acml/acml4.3.0/pgi64/lib -lacml -lacml_mv
# CPP location
CPP = /lib/cpp -traditional -P
