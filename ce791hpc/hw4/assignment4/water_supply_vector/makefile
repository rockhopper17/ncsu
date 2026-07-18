all: water_supplyf water_supplyc water_supplyj

water_supplyf: water_supply.f wtime.c
	ifort -Ofast -free -c water_supply.f
	icc -Ofast -c wtime.c
	ifort -Ofast wtime.o water_supply.o -o water_supplyf

water_supplyc: water_supply.c
	icc -Ofast -c water_supply.c
	icc -Ofast water_supply.o -o water_supplyc

water_supplyj: water_supply.java
	javac -nowarn -O water_supply.java

clean:
	rm -rf *.o water_supplyf water_supplyc *.class *.out *.err
