default: test dft dht

dht: dht.c
	cc -o dht dht.c -lfftw3 -I/opt/local/include -L/opt/local/lib

dft: dft.c
	cc -o dft dft.c -lfftw3 -I/opt/local/include -L/opt/local/lib

test: test.c
	cc -o test test.c -lfftw3 -I/opt/local/include -L/opt/local/lib

clean:
	rm -f test dft dht
