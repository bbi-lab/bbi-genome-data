/** md5test.c **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "md5.h"

#define BLOCK_SIZE	4096

int main( int argc, char **argv )
{
  int   i;
  int   n;
  int   len;
  int   numByte;
  int   numAlloc;
  char  nameFile[8192];
  char *buffer;

  unsigned char resbuf[16];

  FILE *fp;

  struct md5_ctx ctx;

  strcpy( nameFile, argv[1] );

  fp = fopen( nameFile, "r" );

  len      = 0;
  numAlloc = 0;
  buffer   = NULL;
  while( 1 )
  {
    if( numAlloc < ( len + BLOCK_SIZE ) )
    {
      numAlloc += 128 * BLOCK_SIZE;
      numByte = numAlloc * sizeof( char );
      buffer = realloc( buffer, numByte );
    }

    n = fread( buffer + len, 1, BLOCK_SIZE, fp );
    if( n == 0 )
    {
      break;
    }

    len += n;
  }

  fclose( fp );

/*
  md5_init_ctx( &ctx );
  md5_process_bytes( buffer, len, &ctx );
  md5_finish_ctx( &ctx, resbuf );
*/

  md5_buffer( buffer, (size_t)len, resbuf );

  fprintf( stdout, "%02hhx", resbuf[0] );
  for( i = 1; i < 16; ++i )
  {
    fprintf( stdout, " %02hhx", resbuf[i] );
  }
  fprintf( stdout, "\n" );

  return( 0 );
}


