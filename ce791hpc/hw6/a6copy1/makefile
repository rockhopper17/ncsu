ARCH = intel
include make_$(ARCH).inc

all: fmatvet

fmatvet: matvet.f90
	${FF} ${FFLAGS} matvet.f90 -o fmatvet ${LDFLAGS}

clean:
	rm -rf fmatvet *.o *.class *.err *.out

