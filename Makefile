all: mc_gp

mc_gp: mcgp.c
	gcc --std=c11 -W -Wall mcgp.c -o mc_gp

clean:
	rm -rf mc_gp.exe *.c~ *.o

