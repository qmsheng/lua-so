//////////////////////////////////////////////////////////////////////////
///
/// \file     Common.h
/// \brief    Shared code for example
///
/// \author   SinoVoice
/// \since    Created: 2014-12-16 16:54:38
///           Updated: 2014-12-16 16:54:38
///
//////////////////////////////////////////////////////////////////////////

#ifndef __JTTS_EXAMPLE_COMMON_H__
#define __JTTS_EXAMPLE_COMMON_H__

#include "jOSTypes.h"
#include "jTTS_ML.h"

struct UserData
{
    FILE* pFile;
#if defined (WIN32) || defined (_WIN64)
    HANDLE hEvent;
#else
	pthread_cond_t* pCond;
#endif
};

void PrintHelp(const char* szSelfName,
               const char* szLibPath,
               const char* szSerialNo);

bool ParseArguments(int nArgc,
                    char *szArgList[],
                    const char*& pszSrcFile,
                    const char*& pszDstFile,
                    const char*& pszLibPath,
                    const char*& pszSerialNo,
                    const char*& pszVoiceName,
                    DWORD& nCodePage);

bool GetVoiceIdFromName(const char* pszVoiceName,
                        char* pszVoiceIdOut);

void EndJtts();

BOOL TTSAPI jTTS_DataCallBack(JTTS_SESSION_HANDLE hSession,
                              WORD wParam,
                              LONG lParam,
                              unsigned char * pVoiceData,
                              DWORD dwLen,
                              INSERTINFO* pInsertInfo,
                              int nInsertInfo,
                              JTTS_HANDLE hUserData);

BOOL TTSAPI jTTS_DataCallBackAsync(JTTS_SESSION_HANDLE hSession,
                                   WORD wParam,
                                   LONG lParam,
                                   unsigned char * pVoiceData,
                                   DWORD dwLen,
                                   INSERTINFO* pInsertInfo,
                                   int nInsertInfo,
                                   JTTS_HANDLE hUserData);

#endif
