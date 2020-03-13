CC=cc
CFLAGS=-O2
CLIB=-lm

OBJ01= fasta_getseqs.o util.o

OBJ02= md5_seq.o


fasta_getseqs: $(OBJ01)
	$(CC) $(CFLAGS) -o $@ $(OBJ01) $(CLIB)


md5_seq: $(OBJ02) libsquid.a
	$(CC) $(CFLAGS) -o $@ $(OBJ02) md5.c sqio.c -L. -lsquid $(CLIB)


.PHONY: clean libsquid md5

libsquid:
	cd ../squid/squid-1.9g; \
      ./configure; \
      make; \
      cp *.h sqio.c libsquid.a ../../sequtil

md5:
	cd ../md5/drepper; \
      cp md5.[ch] ../../sequtil

clean:
	rm -f \
	$(OBJ01) fasta_getseqs \
	$(OBJ02) md5_seq gki.h gsi64.h gsi.h msa.h rk.h sqfuncs.h sqio.c squidconf.h squid.h sre_random.h ssi.h stockholm.h stopwatch.h vectorops.h version.h libsquid.a md5.c md5.h
	cd ../squid/squid-1.9g; make distclean

