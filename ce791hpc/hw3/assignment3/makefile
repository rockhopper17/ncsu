ARCH = intel
include make_$(ARCH).inc

CSRC = matmul.c driver.c memory.c timer.c
COBJ = driver.o matmul.o memory.o timer.o

FSRC = driver.F matmul.F

FOBJ = driver.o matmul.o wtime.o


all: matmulc matmulf

matmulc: driver.c memory.c timer.c matmul.c
	${CC} ${CFLAGS} ${CPPFLAGS} -c driver.c
	${CC} ${CFLAGS} ${CPPFLAGS} -c memory.c
	${CC} ${CFLAGS} ${CPPFLAGS} -c timer.c
	${CC} ${CFLAGS} ${CPPFLAGS} -c matmul.c
	${CC} driver.o memory.o timer.o matmul.o -o matmulc ${LDFLAGS}

matmulf: driver.F matmul.F wtime.c
	${CC} ${CPPFLAGS} -c wtime.c
	${FF} ${FFLAGS} ${CPPFLAGS} -c driver.F
	${FF} ${FFLAGS} ${CPPFLAGS} -c matmul.F
	${FF} matmul.o driver.o wtime.o -o matmulf ${LDFLAGS}

matmulj: matmul.java
	javac -O matmul.java

clean:
	rm -rf matmulc matmulf *.f *.out *.err *.dat matmul.class *.o
