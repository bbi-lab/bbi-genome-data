/** fasta_getseqs.c **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include "util.h"


typedef struct
{
  char *name;
} ListString;


static ListString *xreadList( char *nameFile, int *fnumString, int *fstatus );
static int  xgetSeq( char *nameFastaFile, ListString *nameSeq, int numName, int *fstatus );


int main( int argc, char **argv )
{
  int status;
  int numName;

  char nameFos[8192];
  char nameFastaFile[8192];

  ListString *nameSeq;

  if( argc == 3 )
  {
    strcpy( nameFos, argv[1] );
    strcpy( nameFastaFile, argv[2] );
  }
  else
  {
    printf( "enter FOS name: " );
    gets( nameFos );
    printf( "enter FASTQ filename: " );
    gets( nameFastaFile );
  }

  nameSeq = xreadList( nameFos, &numName, &status );
  IF_STATUS_MAIN( "bad status: xreadList" );

  xgetSeq( nameFastaFile, nameSeq, numName, &status );
  IF_STATUS_MAIN( "bad status: xgetSeq" );

  return( 0 );
}


static ListString *xreadList( char *nameFile, int *fnumString, int *fstatus )
{
  int i;
  int iline, nline;

  size_t lline;

  char *pline;

  FILE *ifp;
  ListString *listString;

  ifp = fopen( nameFile, "r" );
  if( ifp == NULL )
  {
    sprintf( _msg_, "unable to open file %s", nameFile );
    EMSG( _msg_ );
    *fstatus = -1;
    return( NULL );
  }

  nline = 0;
  lline = 0;
  pline = NULL;
  while( getline( &pline, &lline, ifp ) >= 0 )
  {
    ++nline;
  }

  listString = (ListString *)calloc( nline, sizeof( ListString ) );
  if( listString == NULL )
  {
    EMSG( "unable to allocate memory" );
    *fstatus = -1;
    return( NULL );
  }

  rewind( ifp );

  iline = 0;
  while( getline( &pline, &lline, ifp ) >= 0 )
  {
    for( i = 0; pline[i] != '\0' && pline[i] != '\n'; ++i );
    pline[i] = '\0';
    listString[iline].name = mstrcpy( pline );
    ++iline;
  }

  fclose( ifp );

  sprintf( _msg_, "%d names read from %s", iline, nameFile );
  IMSG( _msg_ );

  *fnumString = iline;

  *fstatus = 0;

  return( listString );
}


static int xcmpSortListString( const void *fa, const void *fb )
{
  ListString *a;
  ListString *b;

  a = (ListString *)fa;
  b = (ListString *)fb;

  return( strcmp( a->name, b->name ) );
}


static int xcmpSearchListString( const void *fa, const void *fb )
{
  char *a;
  ListString *b;

  a = (char *)fa;
  b = (ListString *)fb;

  return( strcmp( a, b->name ) );
}


static int xgetSeq( char *nameFile, ListString *nameSeq, int numName, int *fstatus )
{
  int i;
  int nread;
  int flag;

  size_t lline;

  char *pline;
  char *tline;

  FILE *ifp;
  ListString *lptr;

  ifp = fopen( nameFile, "r" );
  if( ifp == NULL )
  {
    sprintf( _msg_, "unable to open file %s", nameFile );
    EMSG( _msg_ );
    *fstatus = 0;
    return( 0 );
  }

  qsort( nameSeq, numName, sizeof( ListString ), xcmpSortListString );

  nread = 0;
  lline = 0L;
  pline = NULL;
  while( getline( &pline, &lline, ifp ) >= 0 )
  {
    if( pline[0] == '>' )
    {
      if( nread == numName )
      {
        fclose( ifp );
        *fstatus = 0;
        return( 0 );
      }
      tline = mstrcpy( pline );
      flag = 0;
      for( i = 0; tline[i] != ' '  &&
                  tline[i] != '\t' &&
                  tline[i] != '\0' &&
                  tline[i] != '\n'; ++i );
      tline[i] = '\0';
      lptr = bsearch( &(tline[1]), nameSeq, numName, sizeof( ListString ), xcmpSearchListString );
      if( lptr != NULL )
      {
        flag = 1;
        printf( "%s", pline );
        ++nread;
      }
      free( tline );
      continue;
    }

    if( flag )
    {
      printf( "%s", pline );
    }
  }

  fclose( ifp );

  *fstatus = 0;

  return( 0 );
}


