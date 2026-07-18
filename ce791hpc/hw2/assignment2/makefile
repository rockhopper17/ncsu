ARCH = intel
include make_$(ARCH).inc

all: vecbenchc vecbenchf vecbenchj

vecbenchc: vecbench.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c vecbench.c
	$(CC) $(LDFLAGS) vecbench.o -o vecbenchc

vecbenchf: vecbench.F
	$(FF) $(FFLAGS) $(CPPFLAGS) -c vecbench.F
	$(CC) $(CFLAGS) $(CPPFLAGS) -c wtime.c
	$(FF) $(LDFLAGS) vecbench.o wtime.o -o vecbenchf

vecbenchj: vecbench.java
	javac -O -nowarn vecbench.java

clean:
	rm -f *.o vecbenchc vecbenchf *.class *.dat
