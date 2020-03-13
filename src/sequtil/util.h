/** util.h **/

/*
** The master file location is
**
**   whim:/users/bge/src/util/util.[ch]
**
** Version: 151214
*/

#ifndef UTIL_H

/*
** MFREE		frees heap memory
**
** emsg			writes standard format error messages
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>
#include <math.h>
#include <errno.h>


#define ___MXMSG___	8192

static char _msg_[___MXMSG___];


#ifndef VEMSG
#define MSG( a, b )     ___XMSG___( a, b, __FILE__, __func__, __LINE__ )
#define EMSG( b )       ___XMSG___( "ERROR", b, __FILE__, __func__, __LINE__ )
#define WMSG( b )       ___XMSG___( "WARN", b, __FILE__, __func__, __LINE__ )
#define IMSG( b )       ___XMSG___( "INFO", b, __FILE__, __func__, __LINE__ )
#define DMSG( b )       ___XMSG___( "DIAG", b, __FILE__, __func__, __LINE__ )
#define RMSG( b )       ___XMSG___( "REPT", b, __FILE__, __func__, __LINE__ )
#else
#define MSG( a, b )     ___XVMSG___( a, b, __FILE__, __func__, __LINE__ )
#define EMSG( b )       ___XVMSG___( "ERROR", b, __FILE__, __func__, __LINE__ )
#define WMSG( b )       ___XVMSG___( "WARN", b, __FILE__, __func__, __LINE__ )
#define IMSG( b )       ___XVMSG___( "INFO", b, __FILE__, __func__, __LINE__ )
#define DMSG( b )       ___XVMSG___( "DIAG", b, __FILE__, __func__, __LINE__ )
#define RMSG( b )       ___XVMSG___( "REPT", b, __FILE__, __func__, __LINE__ )
#endif

/*
 *  * ** Safer sprintf to _msg_.
 *   * */
#define mprintf(...)    { int _ist_; _ist_ = snprintf( _msg_, ___MXMSG___, __VA_ARGS__ ); if( _ist_ == ___MXMSG___ ) { EMSG( "string exceeds buffer size" ); exit( -1 ); } }



static int ___XMSG___( char *typeError, char *messageError, const char nameFile[], const char nameFunc[], int numLine )
{
  fprintf( stderr,
           "%s: %s (%d): %s\n",
           typeError,
           ( strcmp( nameFunc, "main" ) != 0 ) ? nameFunc : nameFile,
           numLine,
           messageError );

  return( 0 );
}

static int ___XVMSG___( char *typeError, char *messageError, const char nameFile[], const char nameFunc[], int numLine )
{
  fprintf( stderr,
           "%s: %s in %s (%d): %s\n",
           typeError,
           nameFunc,
           nameFile,
           numLine,
           messageError );

  return( 0 );
}


#define IF_STATUS_MAIN(...) \
  if( status != 0 ) { \
    int _ist_; \
    char ___estr___[___MXMSG___]; \
    _ist_ = snprintf( ___estr___, ___MXMSG___, __VA_ARGS__ ); \
    if( _ist_ == ___MXMSG___ ) \
    { \
       EMSG( "string exceeds buffer size" ); \
       exit( -1 ); \
    } \
    fprintf( stderr, \
             "ERROR: %s (%d): %s\n", \
             __FILE__, \
             __LINE__, \
             ___estr___ ); \
    return( -1 ); }

#define IF_STATUS_ZERO(...) \
  if( status != 0 ) { \
    int _ist_; \
    char ___estr___[___MXMSG___]; \
    _ist_ = snprintf( ___estr___, ___MXMSG___, __VA_ARGS__ ); \
    if( _ist_ == ___MXMSG___ ) \
    { \
       EMSG( "string exceeds buffer size" ); \
       exit( -1 ); \
    } \
    fprintf( stderr, \
             "ERROR: %s (%d): %s\n", \
             __func__, \
             __LINE__, \
             ___estr___ ); \
    *fstatus = -1; \
    return( 0 ); }

#define IF_STATUS_NULL(...) \
  if( status != 0 ) { \
    int _ist_; \
    char ___estr___[___MXMSG___]; \
    _ist_ = snprintf( ___estr___, ___MXMSG___, __VA_ARGS__ ); \
    if( _ist_ == ___MXMSG___ ) \
    { \
       EMSG( "string exceeds buffer size" ); \
       exit( -1 ); \
    } \
    fprintf( stderr, \
             "ERROR: %s (%d): %s\n", \
             ( strcmp( __func__, "main" ) == 0 ) ? __FILE__ : __func__, \
             __LINE__, \
             ___estr___ ); \
    *fstatus = -1; \
    return( NULL ); }


char *mstrcpy( char *string );

#endif

#define UTIL_H
