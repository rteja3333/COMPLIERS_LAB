out_ass3_21CS30016_21CS30053.txt: a.out
	./a.out<ass3_21CS30016_21CS30053_test.c>out_ass3_21CS30016_21CS30053.txt

a.out:lex.yy.c ass3_21CS30016_21CS30053.c
	gcc lex.yy.c ass3_21CS30016_21CS30053.c

lex.yy.c: lex1.l 
	lex lex1.l 

clean:
	rm lex.yy.c a.out out_ass3_21CS30016_21CS30053.txt