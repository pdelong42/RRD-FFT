default: test

test: test.c
	cc -std=gnu99 -o test test.c -lfftw3 -lm

clean:
	rm -f test
