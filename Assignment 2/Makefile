
	
a.out: main.o libass2_21CS30016.a
	gcc main.o -L. -lass2_21CS30016

main.o: main.c myl.h
	gcc -Wall -c main.c

libass2_21CS30016.a: ass2_21CS30016.o
	ar -rcs libass2_21CS30016.a ass2_21CS30016.o

ass2_21CS30016.o: ass2_21CS30016.c myl.h
	gcc -Wall -c ass2_21CS30016.c

clean:
	rm a.out main.o libass2_21CS30016.a ass2_21CS30016.o

