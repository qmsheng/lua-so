#ifndef __J_OS_TYPES_H__
#define __J_OS_TYPES_H__


#if defined (WIN32) || defined(_J_WIN32_) || defined(_WIN64)
/*windows.h Óë winsock2.hË³Ðò²»ÄÜµßµ¹*/
#include <winsock2.h>
#include <Windows.h>

#include <Mmsystem.h>
#include <winuser.h>

typedef HMODULE JDLLHMODULE;
#else

typedef void * JDLLHMODULE;
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#include <pthread.h>
#include <unistd.h>

#define _MAX_PATH 	256
#define MAX_PATH  	256
#define MAX_PATH 256
#define	TRUE 				1
#define FALSE 			0

#define DEBUG_STR printf(__FILE__" (%d)\n", __LINE__)
#define DEBUG_PRINT printf 
//#define NULL 0
//define datatype
typedef unsigned char 	BYTE, byte;
typedef unsigned short  WORD;
typedef wchar_t  WCHAR;
typedef unsigned int  DWORD;
typedef DWORD * LPDWORD;
typedef int							BOOL;
typedef long						LONG;
typedef unsigned long 	ULONG;
typedef unsigned int 		UINT;
typedef UINT * LPUINT;
typedef unsigned short  USHORT;
typedef unsigned long 	HWND;
#ifdef _Solaris64_
typedef void * 	HANDLE;
#else
typedef void *	HANDLE;
#endif
typedef char		TCHAR;					//Temparily define
typedef void		*LPVOID;	
typedef const char	*LPCTSTR;

typedef char * LPSTR;
typedef const char * LPCSTR;

typedef unsigned char UCHAR;
typedef long WPARAM;
typedef long LPARAM;

#define CALLBACK
//#define WAVE_MAPPER		0xFFFF
#define INFINITE            0xFFFFFFFF  // Infinite timeout
#define WAIT_OBJECT_0   0L
#define USES_CONVERSION
#define ASSERT assert

#define T2A(x) x
#define _T(x) x
#define ZeroMemory(Destination,Length) memset((Destination),0,(Length))
#define _tcscpy strcpy
#define _tcscat strcat
#define _tcslen strlen

//WAVE'S FORMAT
typedef struct {
    WORD  wFormatTag;
    WORD  nChannels;
    DWORD nSamplesPerSec;
    DWORD nAvgBytesPerSec;
    WORD  nBlockAlign;
    WORD  wBitsPerSample;
    WORD  cbSize;
} WAVEFORMATEX, *LPWAVEFORMATEX;
typedef const WAVEFORMATEX * LPCWAVEFORMATEX;

typedef struct waveformat_tag {
    WORD    wFormatTag:16;        /* format type */
    WORD    nChannels:16;         /* number of channels (i.e. mono, stereo, etc.) */
    DWORD   nSamplesPerSec:32;    /* sample rate */
    DWORD   nAvgBytesPerSec:32;   /* for buffer estimation */
    WORD    nBlockAlign:16;       /* block size of data */
    WORD    wBitsPerSample:16;
} WAVEFORMAT;

/* specific waveform format structure for PCM data */
typedef struct pcmwaveformat_tag {
    WAVEFORMAT  wf;
    
} PCMWAVEFORMAT;

//Socket programm, It'll make bug, Be sure to modify later
typedef int SOCKET;
#define SOCKET_ERROR 		-1
#define INVALID_SOCKET -1 
#define INVALID_HANDLE_VALUE (HANDLE)-1 

// 
// added by fab 
// -------- begin -----------
#define __stdcall 

//typedef struct _GUID
//{
//    unsigned long Data1;
//    unsigned short Data2;
//    unsigned short Data3;
//    unsigned char Data4[8];
//} GUID;
typedef char* LPTSTR;


#define LOBYTE(w)           ((BYTE)(w))
#define HIBYTE(w)           ((BYTE)(((WORD)(w) >> 8) & 0xFF))
#define LOBYTE(w)           ((BYTE)(w))
#define HIBYTE(w)           ((BYTE)(((WORD)(w) >> 8) & 0xFF))

typedef DWORD WSAEVENT;
// typedef int SOCKET;
typedef fd_set FD_SET;

typedef unsigned int * PUINT;
typedef struct sockaddr SOCKADDR;
typedef struct sockaddr_in SOCKADDR_IN;
typedef struct sockaddr * LPSOCKADDR;
typedef struct sockaddr_in * LPSOCKADDR_IN;

#define GetCurrentDirectory(nSize, szDir) getcwd(szDir, nSize) 
// #define SetCurrentDirectory(szDir) chdir(szDir) 

// 
#define stricmp strcmpi 

typedef void * HMODULE;

// 
#include <wchar.h>
#include <stdio.h>
#include <stdarg.h>

typedef LONG LPARAM;
#define memicmp strncasecmp 
typedef unsigned long UINT_PTR;
#define _vsnprintf vsnprintf 
#define _snprintf snprintf
#define wsprintf sprintf
typedef struct  _FILETIME
{
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
}	FILETIME;

#include <sys/types.h>
#include <dirent.h>
typedef struct _WIN32_FIND_DATAA {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    char   cFileName[ MAX_PATH ];
    char   cAlternateFileName[ 14 ];
}WIN32_FIND_DATA, *PWIN32_FIND_DATA, *LPWIN32_FIND_DATA;

#define FILE_ATTRIBUTE_DIRECTORY            0x00000010  

typedef struct 
{
    DIR *pDir;
    char szFileName[MAX_PATH];
    char szExt[10];
}FIND_FILE_HANDLE, *PFIND_FILE_HANDLE;

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#define WAVE_FORMAT_PCM 1 

/* MMTIME data structure */
typedef struct mmtime_tag
{
    UINT            wType;      /* indicates the contents of the union */
    union
    {
        DWORD       ms;         /* milliseconds */
        DWORD       sample;     /* samples */
        DWORD       cb;         /* byte count */
        DWORD       ticks;      /* ticks in MIDI stream */

        /* SMPTE */
        struct
        {
            BYTE    hour;       /* hours */
            BYTE    min;        /* minutes */
            BYTE    sec;        /* seconds */
            BYTE    frame;      /* frames  */
            BYTE    fps;        /* frames per second */
            BYTE    dummy;      /* pad */
#ifdef _WIN32
            BYTE    pad[2];
#endif
        } smpte;

        /* MIDI */
        struct
        {
            DWORD songptrpos;   /* song pointer position */
        } midi;
    } u;
} MMTIME, *PMMTIME, *NPMMTIME, *LPMMTIME;

typedef struct wavehdr_tag {
    char *       lpData;                 /* pointer to locked data buffer */
    DWORD       dwBufferLength;         /* length of data buffer */
    DWORD       dwBytesRecorded;        /* used for input only */
    DWORD       dwUser;                 /* for client's use */
    DWORD       dwFlags;                /* assorted flags (see defines) */
    DWORD       dwLoops;                /* loop control counter */
    struct wavehdr_tag *lpNext;     /* reserved for driver */
    DWORD       reserved;               /* reserved for driver */
} WAVEHDR, *PWAVEHDR, *NPWAVEHDR, *LPWAVEHDR;

typedef void * HWAVEOUT;
typedef HWAVEOUT * LPHWAVEOUT;

typedef UINT        MMRESULT;   /* error return code, 0 means no error */

#define STATUS_PENDING ((DWORD )0x00000103L)
#define STILL_ACTIVE STATUS_PENDING 

typedef void *(* THREAD_PROC_IN_LINUX) (void *);
// socket 
#include <netdb.h>
// socket types 
//
#define WINSOCK_API_LINKAGE 
#define WSAAPI 
#define WINAPI 
#define PASCAL 
#define FAR 
#define VOID void 
#define WINBASEAPI 
#define WSA_INFINITE ((DWORD)-1L) 
#define WSA_INVALID_EVENT ((WSAEVENT)NULL)

// typedef DWORD WSAEVENT;
typedef struct WSAData {
    WORD                    wVersion;
    WORD                    wHighVersion;
    char                    szDescription[10+1];
    char                    szSystemStatus[10+1];
    unsigned short          iMaxSockets;
    unsigned short          iMaxUdpDg;
    char FAR *              lpVendorInfo;
} WSADATA, FAR * LPWSADATA;

typedef int SOCKET;
//
#define MAKEWORD(low,high)   ((WORD)((BYTE)(low)) | (((WORD)(BYTE)(high))<<8))

// socket functions 
// 
#define Sleep(n) usleep(n * 1000)
typedef DWORD * LPDWORD;
inline DWORD GetTickCount(void)
{
	return (DWORD)time(NULL);	
} 

typedef VOID( *TIMERPROC)( HWND hwnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime); 




// for cn 
#define _cdecl 
char * strlwr (char *szText);
int strnicmp (const char *str1, const char *str2, size_t nCount);


/****************************************************************************

                String resource number bases (internal use)

****************************************************************************/

#define MMSYSERR_BASE          0
#define WAVERR_BASE            32
#define MIDIERR_BASE           64
#define TIMERR_BASE            96
#define JOYERR_BASE            160
#define MCIERR_BASE            256
#define MIXERR_BASE            1024

#define MCI_STRING_OFFSET      512
#define MCI_VD_OFFSET          1024
#define MCI_CD_OFFSET          1088
#define MCI_WAVE_OFFSET        1152
#define MCI_SEQ_OFFSET         1216

/****************************************************************************

                        General error return values

****************************************************************************/
/* general error return values */
#define MMSYSERR_NOERROR      0                    /* no error */
#define MMSYSERR_ERROR        (MMSYSERR_BASE + 1)  /* unspecified error */
#define MMSYSERR_BADDEVICEID  (MMSYSERR_BASE + 2)  /* device ID out of range */
#define MMSYSERR_NOTENABLED   (MMSYSERR_BASE + 3)  /* driver failed enable */
#define MMSYSERR_ALLOCATED    (MMSYSERR_BASE + 4)  /* device already allocated */
#define MMSYSERR_INVALHANDLE  (MMSYSERR_BASE + 5)  /* device handle is invalid */
#define MMSYSERR_NODRIVER     (MMSYSERR_BASE + 6)  /* no device driver present */
#define MMSYSERR_NOMEM        (MMSYSERR_BASE + 7)  /* memory allocation error */
#define MMSYSERR_NOTSUPPORTED (MMSYSERR_BASE + 8)  /* function isn't supported */
#define MMSYSERR_BADERRNUM    (MMSYSERR_BASE + 9)  /* error value out of range */
#define MMSYSERR_INVALFLAG    (MMSYSERR_BASE + 10) /* invalid flag passed */
#define MMSYSERR_INVALPARAM   (MMSYSERR_BASE + 11) /* invalid parameter passed */
#define MMSYSERR_HANDLEBUSY   (MMSYSERR_BASE + 12) /* handle being used */
                                                   /* simultaneously on another */
                                                   /* thread (eg callback) */
#define MMSYSERR_INVALIDALIAS (MMSYSERR_BASE + 13) /* specified alias not found */
#define MMSYSERR_BADDB        (MMSYSERR_BASE + 14) /* bad registry database */
#define MMSYSERR_KEYNOTFOUND  (MMSYSERR_BASE + 15) /* registry key not found */
#define MMSYSERR_READERROR    (MMSYSERR_BASE + 16) /* registry read error */
#define MMSYSERR_WRITEERROR   (MMSYSERR_BASE + 17) /* registry write error */
#define MMSYSERR_DELETEERROR  (MMSYSERR_BASE + 18) /* registry delete error */
#define MMSYSERR_VALNOTFOUND  (MMSYSERR_BASE + 19) /* registry value not found */
#define MMSYSERR_NODRIVERCB   (MMSYSERR_BASE + 20) /* driver does not call DriverCallback */
#define MMSYSERR_MOREDATA     (MMSYSERR_BASE + 21) /* more data to be returned */
#define MMSYSERR_LASTERROR    (MMSYSERR_BASE + 21) /* last error in range */



#define MM_WOM_OPEN         0x3BB           /* waveform output */
#define MM_WOM_CLOSE        0x3BC
#define MM_WOM_DONE         0x3BD

#define MM_WIM_OPEN         0x3BE           /* waveform input */
#define MM_WIM_CLOSE        0x3BF
#define MM_WIM_DATA         0x3C0

/* wave callback messages */
#define WOM_OPEN        MM_WOM_OPEN
#define WOM_CLOSE       MM_WOM_CLOSE
#define WOM_DONE        MM_WOM_DONE
#define WIM_OPEN        MM_WIM_OPEN
#define WIM_CLOSE       MM_WIM_CLOSE
#define WIM_DATA        MM_WIM_DATA

/* device ID for wave device mapper */
#define WAVE_MAPPER     ((UINT)-1)

/****************************************************************************

                          Driver callback support

****************************************************************************/

/* flags used with waveOutOpen(), waveInOpen(), midiInOpen(), and */
/* midiOutOpen() to specify the type of the dwCallback parameter. */

#define CALLBACK_TYPEMASK   0x00070000l    /* callback type mask */
#define CALLBACK_NULL       0x00000000l    /* no callback */
#define CALLBACK_WINDOW     0x00010000l    /* dwCallback is a HWND */
#define CALLBACK_TASK       0x00020000l    /* dwCallback is a HTASK */
#define CALLBACK_FUNCTION   0x00030000l    /* dwCallback is a FARPROC */


/* types for wType field in MMTIME struct */
#define TIME_MS         0x0001  /* time in milliseconds */
#define TIME_SAMPLES    0x0002  /* number of wave samples */
#define TIME_BYTES      0x0004  /* current byte offset */
#define TIME_SMPTE      0x0008  /* SMPTE time */
#define TIME_MIDI       0x0010  /* MIDI time */
#define TIME_TICKS      0x0020  /* Ticks within MIDI stream */


#if 0
MMRESULT waveOutOpen(LPHWAVEOUT phwo, UINT uDeviceID,
                            LPCWAVEFORMATEX pwfx, DWORD dwCallback, DWORD dwInstance, DWORD fdwOpen)


MMRESULT waveOutClose(HWAVEOUT hwo)

MMRESULT waveOutPrepareHeader(HWAVEOUT hwo, LPWAVEHDR pwh, UINT cbwh)


MMRESULT waveOutUnprepareHeader(HWAVEOUT hwo, LPWAVEHDR pwh, UINT cbwh)


MMRESULT waveOutWrite(HWAVEOUT hwo, LPWAVEHDR pwh, UINT cbwh)


MMRESULT waveOutPause(HWAVEOUT hwo)


MMRESULT waveOutRestart(HWAVEOUT hwo)


MMRESULT waveOutReset(HWAVEOUT hwo)


MMRESULT waveOutBreakLoop(HWAVEOUT hwo)

MMRESULT waveOutGetPosition(HWAVEOUT hwo, LPMMTIME pmmt, UINT cbmmt)


MMRESULT waveOutGetPitch(HWAVEOUT hwo, LPDWORD pdwPitch)


MMRESULT waveOutSetPitch(HWAVEOUT hwo, DWORD dwPitch)


MMRESULT waveOutGetPlaybackRate(HWAVEOUT hwo, LPDWORD pdwRate)

MMRESULT waveOutSetPlaybackRate(HWAVEOUT hwo, DWORD dwRate)


MMRESULT waveOutGetID(HWAVEOUT hwo, LPUINT puDeviceID)
#endif

//////////////////////////////////////////////////////////////////////////

//
typedef void * HINSTANCE;

// 
inline DWORD GetLastError ( void )
{
    return 0x123456;
}

#include <dlfcn.h>

int strcmpi(const char* sz1, const char* sz2);
int MulDiv(int nNumber, int nNumberator, int nDenominator);
bool CheckFileExtention(char *szFile1, char *szExtention);
HANDLE FindFirstFile ( const char * lpFileName, LPWIN32_FIND_DATA lpFindFileData );

BOOL FindNextFile ( HANDLE hFindFile, LPWIN32_FIND_DATA lpFindFileData );

BOOL FindClose ( HANDLE hFindFile );
#define stricmp strcmpi 

inline BOOL IsBadStringPtr(const char * pszStr, int nStrLen)
{
        if ( NULL == pszStr )
	    return TRUE;
	return FALSE;
}

inline BOOL IsBadWritePtr(const void * pObject, int nObjectLen)
{	
	if ( NULL == pObject )
	     return TRUE;
	return FALSE;
}

inline BOOL IsBadReadPtr(const void * pObject, int nObjectLen)
{	
        if ( NULL == pObject)
	     return TRUE;
	return FALSE;
}

#define FARPROC void *
inline BOOL IsBadCodePtr(const FARPROC  pProc)
{	
        if ( NULL == pProc )
	     return TRUE;
	return FALSE;
}



#endif
#include "jSys.h"

void  JOSLayerInit();
void  JOSLayerFini();

#define jmax(a, b) ((a) >= (b)?(a): (b))
#define jmin(a, b) ((a) <= (b)?(a): (b))

#endif

