ARCH = intel
include make_$(ARCH).inc

CSRC = cpi.c
COBJ = cpi.o

FSRC = fpi.f
FOBJ = fpi.o


all: cpi fpi

cpi: cpi.c
	${CC} ${CFLAGS} ${CPPFLAGS} -c cpi.c
	${CC} ${CFLAGS} cpi.o -o cpi ${LDFLAGS}

fpi: fpi.f90
	${FF} ${FFLAGS} -c fpi.f90
	${FF} ${FFLAGS} fpi.o -o fpi ${LDFLAGS}

jpi:
	javac -classpath $(HOME)/mpiJava/lib/classes jpi.java

clean:
	rm -rf cpi fpi *.o *.class core *.out *.err

