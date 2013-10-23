default: test

test: test.c
	cc -std=gnu99 -o test test.c -lfftw3 -lm -I/opt/local/include -L/opt/local/lib

clean:
	rm -f test
