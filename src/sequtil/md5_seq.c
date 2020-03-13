/* md5_seq.c */

/*
** Calculate md5 check sum of sequences in a fasta file.
**
** Requires
**
**   o  md5_seq.c (this file)
**   o  md5.[ch] (in this directory)
**   o  squid (squid v1.9g from Sean Eddy: http://eddylab.org/software.html)
**   o  build md5_seq:
**        o  build squid library (configure; make)
**        o  copy md5_seq.c md5.[ch] to squid source code directory
**        o  run 'cc -O2 -o md5_seq -L. sqio.c md5_seq.c md5.c -lsquid -lm'
**   o  run md5_seq
**        $ md5_seq <fasta sequence filename>
**   o  output
**      <sequence name> (<sequence_length>) <md5 checksum>
**
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#ifndef SEEK_SET
#include <unistd.h>
#endif

#include "squid.h"
#include "msa.h"
#include "ssi.h"

#include "md5.h"

int main( int argc, char **argv )
{
  int i;
  FILE *fp;
  char *filename;
  char *buf;
  int   len;
  SSIOFFSET off;

  unsigned char resbuf[16];
  struct md5_ctx ctx;

  SQFILE *dbfp;
  SQINFO  info;

  if( argc != 2 )
  {
    fprintf( stderr, "Usage: md5_seq <fasta_filename>\n" );
    return( -1 );
  }

  filename = argv[1];

  if( ( dbfp = SeqfileOpen( filename, SQFILE_FASTA, NULL ) ) == NULL )
  {
    Die("unable to open file %s", filename);
  }

  while( ReadSeq( dbfp, dbfp->format, &buf, &info ) )
  {
    SSIGetFilePosition( dbfp->f, SSI_OFFSET_I32, &off );

    md5_buffer( buf, (size_t)info.len, resbuf );
    fprintf( stdout, "%s (%d) ", info.name, info.len );
    for( i = 0; i < 16; ++i )
    {
      fprintf( stdout, "%02hhx", resbuf[i] );
    }
    fprintf( stdout, "\n" );

    FreeSequence(buf, &info);
  }
  SeqfileClose(dbfp);

  return( 0 );
}

