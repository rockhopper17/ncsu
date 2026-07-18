ARCH = intel
include make_$(ARCH).inc

all: fmatvet fmc

fmatvet: matvet.f90
	${FF} ${FFLAGS} matvet.f90 -o fmatvet ${LDFLAGS}

fmc: mc.f90
	${FF} ${FFLAGS} mc.f90 -o fmc ${LDFLAGS}

clean:
	rm -rf fmatvet fmc *.o *.class *.err *.out

