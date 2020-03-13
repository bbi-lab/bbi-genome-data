/** util.c **/

/*
** The master file location is
**
**   whim:/users/bge/src/util/util.[ch]
**
** Version 20151214
*/

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <fenv.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/wait.h>
#include <time.h>
#include <regex.h>
#include <ctype.h>
#include "util.h"


#define MAX_ARG		8192
#define MAXCOL		128




char *mstrcpy( char *string )
{
  int i;
  int numByte;
  char *cptr;

  if( string == NULL )
  {
    return( NULL );
  }

  i = 0;
  while( string[i] != '\0' )
  {
    ++i;
  }

  numByte = ( i + 1 ) * sizeof( char );
  cptr = ( char *)malloc( numByte );
  if( cptr == NULL )
  {
    fprintf( stderr,
             "mstrcpy: unable to allocate memory\n" );
    return( NULL );
  }

  memcpy( cptr, string, numByte );

  return( cptr );
}


