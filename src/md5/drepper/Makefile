#CC= /net/gs/vol1/home/bge/src/gcc/install/bin/gcc
CC= gcc
CFLAGS= -O
CLIB= -lm

OBJ01= md5.o md5test.o

md5test: $(OBJ01)
	$(CC) $(CFLAGS) -o $@ $(OBJ01) $(CLIB)


clean:
	rm -rf md5test $(OBJ01)

