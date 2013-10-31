default: dft dht

dht: dht.c
	cc -o dht dht.c -lfftw3 -lm -I/opt/local/include -L/opt/local/lib

dft: dft.c
	cc -o dft dft.c -lfftw3 -lm -I/opt/local/include -L/opt/local/lib

# retire this
#
#test: test.c
#	cc -o test test.c -lfftw3 -I/opt/local/include -L/opt/local/lib

clean:
	rm -f dft dht

# ToDo: use more intelligent makefile syntax, after brushing-up
