test: parser.out libassgn6.a
	@echo "\n\nGenerating assembly files\n"
	./parser.out testFiles/ass6_21CS30016_21CS30053_test1.c assemblyFiles/ass6_21CS30016_21CS30053_test1.s > quadsOutput/ass6_21CS30016_21CS30053_quads1.out
	./parser.out testFiles/ass6_21CS30016_21CS30053_test2.c assemblyFiles/ass6_21CS30016_21CS30053_test2.s > quadsOutput/ass6_21CS30016_21CS30053_quads2.out
	./parser.out testFiles/ass6_21CS30016_21CS30053_test3.c assemblyFiles/ass6_21CS30016_21CS30053_test3.s > quadsOutput/ass6_21CS30016_21CS30053_quads3.out
	./parser.out testFiles/ass6_21CS30016_21CS30053_test4.c assemblyFiles/ass6_21CS30016_21CS30053_test4.s > quadsOutput/ass6_21CS30016_21CS30053_quads4.out
	./parser.out testFiles/ass6_21CS30016_21CS30053_test5.c assemblyFiles/ass6_21CS30016_21CS30053_test5.s > quadsOutput/ass6_21CS30016_21CS30053_quads5.out
	./parser.out testFiles/ass6_21CS30016_21CS30053_test6.c assemblyFiles/ass6_21CS30016_21CS30053_test6.s > quadsOutput/ass6_21CS30016_21CS30053_quads6.out


	@echo "\n\nCompiling assembly files\n"
	gcc assemblyFiles/ass6_21CS30016_21CS30053_test1.s -L. -lassgn6 -no-pie -o test1
	gcc assemblyFiles/ass6_21CS30016_21CS30053_test2.s -L. -lassgn6 -no-pie -o test2
	gcc assemblyFiles/ass6_21CS30016_21CS30053_test3.s -L. -lassgn6 -no-pie -o test3
	gcc assemblyFiles/ass6_21CS30016_21CS30053_test4.s -L. -lassgn6 -no-pie -o test4
	gcc assemblyFiles/ass6_21CS30016_21CS30053_test5.s -L. -lassgn6 -no-pie -o test5
	gcc assemblyFiles/ass6_21CS30016_21CS30053_test6.s -L. -lassgn6 -no-pie -o test6


	

parser.out: lex.yy.o y.tab.o ass6_21CS30016_21CS30053_translator.o ass6_21CS30016_21CS30053_target_translator.o
	g++ -g lex.yy.o y.tab.o ass6_21CS30016_21CS30053_translator.o ass6_21CS30016_21CS30053_target_translator.o -o parser.out

ass6_21CS30016_21CS30053_target_translator.o: ass6_21CS30016_21CS30053_target_translator.cxx ass6_21CS30016_21CS30053_translator.h
	g++ -c ass6_21CS30016_21CS30053_target_translator.cxx

ass6_21CS30016_21CS30053_translator.o: ass6_21CS30016_21CS30053_translator.cxx ass6_21CS30016_21CS30053_translator.h
	g++ -c ass6_21CS30016_21CS30053_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass6_21CS30016_21CS30053.l y.tab.h ass6_21CS30016_21CS30053_translator.h
	flex ass6_21CS30016_21CS30053.l

y.tab.c y.tab.h: ass6_21CS30016_21CS30053.y
	@echo "\n\n\t\t\t\t++++++++++++++++ TINYC ++++++++++++++++\n\n\n"
	bison -dty --report=all ass6_21CS30016_21CS30053.y

libassgn6.a: myl.o
	ar -rcs libassgn6.a myl.o

myl.o: myl.c myl.h
	gcc -c myl.c

clean:
	rm libassgn6.a myl.o parser.out ass6_21CS30016_21CS30053_translator.o ass6_21CS30016_21CS30053_target_translator.o lex.yy.* y.tab.* y.output assemblyFiles/*.s test? quadsOutput/*.out 
	@echo "\nCleaning Completed.\n\n"
