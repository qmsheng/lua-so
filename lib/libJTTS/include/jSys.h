#ifndef __J_SYS_H__
#define __J_SYS_H__

/* GENERATED FILE WARNING!  DO NOT EDIT jsys.h
*
* You must modify jsys.hw instead.
*
* And please, make an effort to stub jsys.hnw and jsys.h.in in the process.
*
* This is the Win32 specific version of jsys.h.  It is copied from
* jsys.hw by the jsys.dsp and libjsys.dsp projects. 
*/

/**
* @file jSys.h
* @brief jSys Platform Definitions
* @remark This is a generated header generated from include/jSys.h.in by
* ./configure, or copied from include/jSys.hw or include/jSys.hnw 
* for Win32 or Netware by those build environments, respectively.
*/

#if defined(WIN32) || defined(DOXYGEN)

/* Ignore most warnings (back down to /W3) for poorly constructed headers
*/
#if defined(_MSC_VER) && _MSC_VER >= 1200
#pragma warning(push, 3)
#endif

/* disable or reduce the frequency of...
*   C4057: indirection to slightly different base types
*   C4075: slight indirection changes (unsigned short* vs short[])
*   C4100: unreferenced formal parameter
*   C4127: conditional expression is constant
*   C4163: '_rotl64' : not available as an intrinsic function
*   C4201: nonstandard extension nameless struct/unions
*   C4244: int to char/short - precision loss
*   C4514: unreferenced inline function removed
*/
#pragma warning(disable: 4100 4127 4163 4201 4514; once: 4057 4075 4244)

/* Ignore Microsoft's interpretation of secure development
* and the POSIX string handling API
*/
#if defined(_MSC_VER) && _MSC_VER >= 1400
#ifndef _CRT_SECURE_NO_DEPRECATE
#define _CRT_SECURE_NO_DEPRECATE
#endif
#pragma warning(disable: 4996)
#endif

/* Has windows.h already been included?  If so, our preferences don't matter,
* but we will still need the winsock things no matter what was included.
* If not, include a restricted set of windows headers to our tastes.
*/
#ifndef _WINDOWS_
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef _WIN32_WINNT

/* Restrict the server to a subset of Windows NT 4.0 header files by default
*/
#define _WIN32_WINNT 0x0400
#endif
#ifndef NOUSER
#define NOUSER
#endif
#ifndef NOMCX
#define NOMCX
#endif
#ifndef NOIME
#define NOIME
#endif
#include <windows.h>
/* 
* Add a _very_few_ declarations missing from the restricted set of headers
* (If this list becomes extensive, re-enable the required headers above!)
* winsock headers were excluded by WIN32_LEAN_AND_MEAN, so include them now
*/
#define SW_HIDE             0
#ifndef _WIN32_WCE
#include <winsock2.h>
#include <mswsock.h>
#include <ws2tcpip.h>
#else
#include <winsock.h>
#endif
#endif /* !_WINDOWS_ */

/**
* @defgroup jsys_platform Platform Definitions
* @ingroup JSYS 
* @{
*/

#define JSYS_INLINE __inline
#define JSYS_HAS_INLINE          1
#if !defined(__GNUC__) && !defined(__attribute__)
#define __attribute__(__x)
#endif

#ifndef _WIN32_WCE
#define JSYS_HAVE_ARPA_INET_H    0
#define JSYS_HAVE_CONIO_H        1
#define JSYS_HAVE_CRYPT_H        0
#define JSYS_HAVE_CTYPE_H        1
#define JSYS_HAVE_DIRENT_H       0
#define JSYS_HAVE_ERRNO_H        1
#define JSYS_HAVE_FCNTL_H        1
#define JSYS_HAVE_IO_H           1
#define JSYS_HAVE_LIMITS_H       1
#define JSYS_HAVE_NETDB_H        0
#define JSYS_HAVE_NETINET_IN_H   0
#define JSYS_HAVE_NETINET_SCTP_H 0
#define JSYS_HAVE_NETINET_SCTP_UIO_H 0
#define JSYS_HAVE_NETINET_TCP_H  0
#define JSYS_HAVE_PTHREAD_H      0
#define JSYS_HAVE_SIGNAL_H       1
#define JSYS_HAVE_STDARG_H       1
#define JSYS_HAVE_STDINT_H       0
#define JSYS_HAVE_STDIO_H        1
#define JSYS_HAVE_STDLIB_H       1
#define JSYS_HAVE_STRING_H       1
#define JSYS_HAVE_STRINGS_H      0
#define JSYS_HAVE_SYS_SENDFILE_H 0
#define JSYS_HAVE_SYS_SIGNAL_H   0
#define JSYS_HAVE_SYS_SOCKET_H   0
#define JSYS_HAVE_SYS_SOCKIO_H   0
#define JSYS_HAVE_SYS_SYSLIMITS_H 0
#define JSYS_HAVE_SYS_TIME_H     0
#define JSYS_HAVE_SYS_TYPES_H    1
#define JSYS_HAVE_SYS_UIO_H      0
#define JSYS_HAVE_SYS_WAIT_H     0
#define JSYS_HAVE_UNISTD_H       0
#define JSYS_HAVE_STDDEF_H       1
#define JSYS_HAVE_PROCESS_H      1
#define JSYS_HAVE_TIME_H         1
#else
#define JSYS_HAVE_ARPA_INET_H    0
#define JSYS_HAVE_CONIO_H        0
#define JSYS_HAVE_CRYPT_H        0
#define JSYS_HAVE_CTYPE_H        0
#define JSYS_HAVE_DIRENT_H       0
#define JSYS_HAVE_ERRNO_H        0
#define JSYS_HAVE_FCNTL_H        0
#define JSYS_HAVE_IO_H           0
#define JSYS_HAVE_LIMITS_H       0
#define JSYS_HAVE_NETDB_H        0
#define JSYS_HAVE_NETINET_IN_H   0
#define JSYS_HAVE_NETINET_TCP_H  0
#define JSYS_HAVE_PTHREAD_H      0
#define JSYS_HAVE_SIGNAL_H       0
#define JSYS_HAVE_STDARG_H       0
#define JSYS_HAVE_STDINT_H       0
#define JSYS_HAVE_STDIO_H        1
#define JSYS_HAVE_STDLIB_H       1
#define JSYS_HAVE_STRING_H       1
#define JSYS_HAVE_STRINGS_H      0
#define JSYS_HAVE_SYS_SENDFILE_H 0
#define JSYS_HAVE_SYS_SIGNAL_H   0
#define JSYS_HAVE_SYS_SOCKET_H   0
#define JSYS_HAVE_SYS_SYSLIMITS_H 0
#define JSYS_HAVE_SYS_TIME_H     0
#define JSYS_HAVE_SYS_TYPES_H    0
#define JSYS_HAVE_SYS_UIO_H      0
#define JSYS_HAVE_SYS_WAIT_H     0
#define JSYS_HAVE_UNISTD_H       0
#define JSYS_HAVE_STDDEF_H       0
#define JSYS_HAVE_PROCESS_H      0
#define JSYS_HAVE_TIME_H         0
#endif

#define JSYS_USE_FLOCK_SERIALIZE           0 
#define JSYS_USE_SYSVSEM_SERIALIZE         0
#define JSYS_USE_FCNTL_SERIALIZE           0
#define JSYS_USE_PROC_PTHREAD_SERIALIZE    0 
#define JSYS_USE_PTHREAD_SERIALIZE         0 

#define JSYS_HAS_FLOCK_SERIALIZE           0
#define JSYS_HAS_SYSVSEM_SERIALIZE         0
#define JSYS_HAS_FCNTL_SERIALIZE           0
#define JSYS_HAS_PROC_PTHREAD_SERIALIZE    0
#define JSYS_HAS_RWLOCK_SERIALIZE          0

#define JSYS_HAS_LOCK_CREATE_NP            0

#define JSYS_PROCESS_LOCK_IS_GLOBAL        0

#define JSYS_USES_ANONYMOUS_SHM            0
#define JSYS_USES_FILEBASED_SHM            0
#define JSYS_USES_KEYBASED_SHM             0

#define JSYS_FILE_BASED_SHM      0
#define JSYS_MEM_BASED_SHM       0

#define JSYS_HAVE_CORKABLE_TCP   0
#define JSYS_HAVE_GETRLIMIT      0
#define JSYS_HAVE_ICONV          0
#define JSYS_HAVE_IN_ADDR        1
#define JSYS_HAVE_INET_ADDR      1
#define JSYS_HAVE_INET_NETWORK   0
#define JSYS_HAVE_IPV6           0
#define JSYS_HAVE_MEMMOVE        1
#define JSYS_HAVE_SETRLIMIT      0
#define JSYS_HAVE_SIGACTION      0
#define JSYS_HAVE_SIGSUSPEND     0
#define JSYS_HAVE_SIGWAIT        0
#define JSYS_HAVE_STRCASECMP     0
#define JSYS_HAVE_STRDUP         1
#define JSYS_HAVE_STRNCASECMP    0
#define JSYS_HAVE_STRSTR         1
#define JSYS_HAVE_MEMCHR         1
#define JSYS_HAVE_STRUCT_RLIMIT  0
#define JSYS_HAVE_UNION_SEMUN    0
#define JSYS_HAVE_SCTP           0

#ifndef _WIN32_WCE
#define JSYS_HAVE_STRICMP        1
#define JSYS_HAVE_STRNICMP       1
#define JSYS_PROCATTR_USER_SET_REQUIRES_PASSWORD 1
#else
#define JSYS_HAVE_STRICMP        0
#define JSYS_HAVE_STRNICMP       0
#define JSYS_PROCATTR_USER_SET_REQUIRES_PASSWORD 0
#endif

/** @} */

/* We don't include our conditional headers within the doxyblocks 
* or the extern "C" namespace 
*/

#if JSYS_HAVE_STDLIB_H
#include <stdlib.h>
#endif
#if JSYS_HAVE_STDIO_H
#include <stdio.h>
#endif
#if JSYS_HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#if JSYS_HAVE_STDDEF_H
#include <stddef.h>
#endif
#if JSYS_HAVE_TIME_H
#include <time.h>
#endif
#if JSYS_HAVE_PROCESS_H
#include <process.h>
#endif
#if JSYS_HAVE_IPV6
#include <ws2tcpip.h>
#endif
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif

	/**
	* @addtogroup jsys_platform
	* @ingroup JSYS 
	* @{
	*/

/* assert redefinition */
#define JASSERT		assert

	/*  JSYS Feature Macros */
#define JSYS_HAS_SHARED_MEMORY     1
#define JSYS_HAS_THREADS           1
#define JSYS_HAS_MMAP              1
#define JSYS_HAS_FORK              0
#define JSYS_HAS_RANDOM            1
#define JSYS_HAS_OTHER_CHILD       1
#define JSYS_HAS_DSO               1
#define JSYS_HAS_SO_ACCEPTFILTER   0
#define JSYS_HAS_UNICODE_FS        1
#define JSYS_HAS_PROC_INVOKED      1
#ifndef _WIN32_WCE
#define JSYS_HAS_SENDFILE          1
#define JSYS_HAS_USER              1
#define JSYS_HAS_LARGE_FILES       1
#define JSYS_HAS_XTHREAD_FILES     1
#else
#define JSYS_HAS_SENDFILE          0
#define JSYS_HAS_USER              0
#define JSYS_HAS_LARGE_FILES       0
#define JSYS_HAS_XTHREAD_FILES     0
#endif
#define JSYS_HAS_OS_UUID           1

	/* Win32 cannot poll [just yet] on files/pipes.
	*/
#define JSYS_FILES_AS_SOCKETS      0

	/* This macro indicates whether or not EBCDIC is the native character set.
	*/
#define JSYS_CHARSET_EBCDIC        0

	/* Is the TCP_NODELAY socket option inherited from listening sockets?
	*/
#define JSYS_TCP_NODELAY_INHERITED 1

	/* Is the O_NONBLOCK flag inherited from listening sockets?
	*/
#define JSYS_O_NONBLOCK_INHERITED  1

    /*thread priority*/
#ifdef _WIN32
#define JSYS_THR_PRI_MAX  15
#define JSYS_THR_PRI_MIN  0
#else 
#define JSYS_THR_PRI_MAX  127
#define JSYS_THR_PRI_MIN  0
#endif

    /* log prefix */
	/* Typedefs that JSYS needs. */
	typedef  char              JCHAR;
	typedef  unsigned char     JBYTE;
	typedef  JBYTE             JUCHAR;
	typedef  short             JINT16;
	typedef  unsigned short    JUINT16;

	typedef  int               JINT32;
	typedef  unsigned int      JUINT32;
	
	typedef unsigned short     JWORD;
	typedef  unsigned long     JDWORD ;
    typedef long               JLONG;
    typedef unsigned long      JULONG;

    typedef  unsigned int      JBOOL ;
	#define JTRUE								1 
	#define JFALSE							0
    
    typedef float               JFLOAT;
    typedef double              JDOUBLE;

	typedef  __int64           JINT64;
	typedef  unsigned __int64  JUINT64;

	typedef  size_t      JSIZE;
#if JSYS_HAVE_STDDEF_H
	typedef  ptrdiff_t   JSSIZE;
#else
	typedef  int         JSSIZE;
#endif
#if JSYS_HAS_LARGE_FILES
	typedef  __int64     JOFF;
#else
	typedef  int         JOFF;
#endif
	typedef  int         JSOCKLEN;
	typedef  JUINT64      JINO;

	/* As we don't want to break users who author for 1.2.x, we can't
	* present this type until they have included jsys_file_info.h
	* where it was originally declared in release 1.2.0.
	* Mask it from accedental misuse here.
	*/
#define jsys_ino_t jsys_ino_t__requires__jsys_file_info_h

	/* Are we big endian? */
	/* XXX: Fatal assumption on Alpha platforms */
#define JSYS_IS_BIGENDIAN	0

#ifdef WIN64
#define JSYS_SIZEOF_VOIDP   8
#else
#define JSYS_SIZEOF_VOIDP   4
#endif

	/* XXX These simply don't belong here, perhaps in jsys_portable.h
	* based on some JSYS_HAVE_PID/GID/UID?
	*/
	/*
#ifndef __GNUC__
	typedef  int         pid_t;
#endif
	typedef  int         uid_t;
	typedef  int         gid_t;
	*/
	/* Mechanisms to properly type numeric literals */

#ifndef __GNUC__
#define JSYS_INT64_C(val) (val##i64)
#define JSYS_UINT64_C(val) (val##Ui64)
#else
#define JSYS_INT64_C(val) (val##LL)
#define JSYS_UINT64_C(val) (val##ULL)
#endif

#if JSYS_HAVE_IPV6

	/* Appears in later flavors, not the originals. */
#ifndef in_addr6
#define  in6_addr    in_addr6
#endif

#ifndef WS2TCPIP_INLINE
#define IN6_IS_ADDR_V4MAPPED(a) \
	(   (*(const JUINT64 *)(const void *)(&(a)->s6_addr[0]) == 0) \
	&& (*(const JUINT32 *)(const void *)(&(a)->s6_addr[8]) == ntohl(0x0000ffff)))
#endif

#endif /* JSYS_HAS_IPV6 */

	/* Definitions that JSYS programs need to work properly. */

	/** 
	* Thread callbacks from JSYS functions must be declared with JSYS_THREAD_FUNC, 
	* so that they follow the platform's calling convention.
	* @example
	*/
	/** void* JSYS_THREAD_FUNC my_thread_entry_fn(jsys_thread_t *thd, void *data);
	*/
#define JSYS_THREAD_FUNC  __stdcall


#if defined(DOXYGEN) || !defined(WIN32)

	/**
	* The public JSYS functions are declared with JSYS_DECLARE(), so they may
	* use the most appropriate calling convention.  Public JSYS functions with 
	* variable arguments must use JSYS_DECLARE_NONSTD().
	*
	* @remark Both the declaration and implementations must use the same macro.
	* @example
	*/
	/** JSYS_DECLARE(rettype) jsys_func(args)
	* @see JSYS_DECLARE_NONSTD @see JSYS_DECLARE_DATA
	* @remark Note that when JSYS compiles the library itself, it passes the 
	* symbol -DJSYS_DECLARE_EXPORT to the compiler on some platforms (e.g. Win32) 
	* to export public symbols from the dynamic library build.\n
	* The user must define the JSYS_DECLARE_STATIC when compiling to target
	* the static JSYS library on some platforms (e.g. Win32.)  The public symbols 
	* are neither exported nor imported when JSYS_DECLARE_STATIC is defined.\n
	* By default, compiling an application and including the JSYS public
	* headers, without defining JSYS_DECLARE_STATIC, will prepare the code to be
	* linked to the dynamic library.
	*/
#define JSYS_DECLARE(type)            type 

	/**
	* The public JSYS functions using variable arguments are declared with 
	* JSYS_DECLARE_NONSTD(), as they must follow the C language calling convention.
	* @see JSYS_DECLARE @see JSYS_DECLARE_DATA
	* @remark Both the declaration and implementations must use the same macro.
	* @example
	*/
	/** JSYS_DECLARE_NONSTD(rettype) jsys_func(args, ...);
	*/
#define JSYS_DECLARE_NONSTD(type)     type

	/**
	* The public JSYS variables are declared with AP_MODULE_DECLARE_DATA.
	* This assures the appropriate indirection is invoked at compile time.
	* @see JSYS_DECLARE @see JSYS_DECLARE_NONSTD
	* @remark Note that the declaration and implementations use different forms,
	* but both must include the macro.
	* @example
	*/
	/** extern JSYS_DECLARE_DATA type jsys_variable;\n
	* JSYS_DECLARE_DATA type jsys_variable = value;
	*/
#define JSYS_DECLARE_DATA

#elif defined(JSYS_DECLARE_STATIC)
#define JSYS_DECLARE(type)            type __stdcall
#define JSYS_DECLARE_NONSTD(type)     type __cdecl
#define JSYS_DECLARE_DATA
#elif defined(JSYS_DECLARE_EXPORT)
#define JSYS_DECLARE(type)            __declspec(dllexport) type __stdcall
#define JSYS_DECLARE_NONSTD(type)     __declspec(dllexport) type __cdecl
#define JSYS_DECLARE_DATA             __declspec(dllexport)
#else
#define JSYS_DECLARE(type)            __declspec(dllimport) type __stdcall
#define JSYS_DECLARE_NONSTD(type)     __declspec(dllimport) type __cdecl
#define JSYS_DECLARE_DATA             __declspec(dllimport)
#endif

#ifdef WIN64
#define JSYS_SSIZE_T_FMT          "I64d"
#define JSYS_SIZE_T_FMT           "I64d"
#else
#define JSYS_SSIZE_T_FMT          "d"
#define JSYS_SIZE_T_FMT           "d"
#endif

#if JSYS_HAS_LARGE_FILES
#define JSYS_OFF_T_FMT            "I64d"
#else
#define JSYS_OFF_T_FMT            "d"
#endif

#define JSYS_PID_T_FMT            "d"

#define JSYS_INT64_T_FMT          "I64d"
#define JSYS_UINT64_T_FMT         "I64u"
#define JSYS_UINT64_T_HEX_FMT     "I64x"

	/* Local machine definition for console and log output. */
#define JSYS_EOL_STR              "\r\n"

	/* No difference between PROC and GLOBAL mutex */
#define JSYS_PROC_MUTEX_IS_GLOBAL      1

	typedef int JWAIT;

	/* struct iovec is needed to emulate Unix writev */
	/*
	struct iovec {
		char*      iov_base;
		JSIZE iov_len;
	};
	*/
	/* Nasty Win32 .h ommissions we really need */
#define STDIN_FILENO  0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#if JSYS_HAS_UNICODE_FS
	/* An arbitrary size that is digestable. True max is a bit less than 32000 */
#define JSYS_PATH_MAX 8192
#else /* !JSYS_HAS_UNICODE_FS */
#define JSYS_PATH_MAX MAX_PATH
#endif

	/** @} */

#ifdef __cplusplus
}
#endif

/* Done with badly written headers
*/
#if defined(_MSC_VER) && _MSC_VER >= 1200
#pragma warning(pop)
#pragma warning(disable: 4996)
#endif

#else  /*if OS is't windows*/

#include <assert.h>

#define JASSERT assert
/* log prefix */
        /* Typedefs that JSYS needs. */
        typedef  char              JCHAR;
        typedef  unsigned char     JBYTE;
        typedef  JBYTE             JUCHAR;
        typedef  short             JINT16;
        typedef  unsigned short    JUINT16;

        typedef  int               JINT32;
        typedef  unsigned int      JUINT32;

        typedef  unsigned long     JDWORD ;
    typedef long               JLONG;
    typedef unsigned long      JULONG;

    typedef  unsigned int      JBOOL ;
        #define JTRUE                                                           1
        #define JFALSE                                                  0

    typedef float               JFLOAT;
    typedef double              JDOUBLE;

        typedef  long long           JINT64;
        typedef  unsigned long long JUINT64;

        typedef  unsigned int      JSIZE;
#if JSYS_HAVE_STDDEF_H
        typedef  ptrdiff_t   JSSIZE;
#else
        typedef  int         JSSIZE;
#endif
#if JSYS_HAS_LARGE_FILES
        typedef  long long     JOFF;
#else
        typedef  int         JOFF;
#endif
        typedef  int         JSOCKLEN;
        typedef  JUINT64      JINO;


#endif /* WIN32 */

#endif /* JSYS_H */

