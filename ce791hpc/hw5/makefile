ARCH = intel
include make_$(ARCH).inc

all: cjacobi fjacobi

cjacobi: jacobi.c
	${CC} ${CFLAGS} ${CPPFLAGS} jacobi.c -o cjacobi ${LDFLAGS}

fjacobi: jacobi.f90
	${FF} ${FFLAGS} jacobi.f90 -o fjacobi ${LDFLAGS}

jjacobi: jacobi.java
	javac -classpath $(HOME)/mpiJava/lib/classes jacobi.java


clean:
	rm -rf cjacobi fjacobi *.o *.class *.err *.out

