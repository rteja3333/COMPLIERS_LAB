BASE=ass5_21CS30016_21CS30053
DIR=./test-outputs

a.out: lex.yy.o $(BASE).tab.o $(BASE)_translator.o
	g++ lex.yy.o $(BASE).tab.o $(BASE)_translator.o -lfl

$(BASE)_translator.o: $(BASE)_translator.h $(BASE)_translator.cxx
	g++ -c $(BASE)_translator.h
	g++ -c $(BASE)_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

$(BASE).tab.o: $(BASE).tab.c
	g++ -c $(BASE).tab.c

lex.yy.c: $(BASE).l $(BASE).tab.h $(BASE)_translator.h
	flex $(BASE).l

$(BASE).tab.c: $(BASE).y
	bison -dtv $(BASE).y

$(BASE).tab.h: $(BASE).y
	bison -dtv $(BASE).y

$(BASE).c:
	touch $(BASE).c

test: a.out
	mkdir -p $(DIR)
	./a.out < test-inputs/$(BASE)_test1.c > test-outputs/$(BASE)_test1.out
	./a.out < test-inputs/$(BASE)_test2.c > test-outputs/$(BASE)_test2.out
	./a.out < test-inputs/$(BASE)_test3.c > test-outputs/$(BASE)_test3.out
	./a.out < test-inputs/$(BASE)_test4.c > test-outputs/$(BASE)_test4.out
	./a.out < test-inputs/$(BASE)_test5.c > test-outputs/$(BASE)_test5.out
	@echo "\nTest outputs generated and written to ./test-outputs.\n"

clean:
	rm -f lex.yy.c *.tab.c *.tab.h *.output *.o a.out *.gch test-outputs/*_test*.out
