//////////////////////////////////////////////////////////////////////////
///
/// \file     Common.cpp
/// \brief    Shared code for example
///
/// \author   SinoVoice
/// \since    Created: 2014-12-16 16:54:38
///           Updated: 2014-12-16 16:54:38
///
//////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>

#include "jOSTypes.h"
#include "jSys.h"
#include "jTTS_ML.h"

#include "Common.h"

void PrintHelp(const char* szSelfName,
               const char* szLibPath,
               const char* szSerialNo)
{
    printf("Usage :\n"
           "\t%s <szVoiceName> <dwCodePage> <szFromFile> <szToFile> "
           "[szLibPath] [szSerialNo]\n", szSelfName);

    // print valid voice id
    ERRCODE err = jTTS_Init(szLibPath, szSerialNo);
    if (ERR_NONE == err || ERR_ALREADYINIT == err)
    {
        printf("\nValid voice ID is followed :\n");
        int nVoiceCount = jTTS_GetVoiceCount();
        for (int i = 0; i < nVoiceCount; i++)
        {
            JTTS_VOICEATTRIBUTE attr;
            ERRCODE err = jTTS_GetVoiceAttribute(i, &attr);
            if (err != ERR_NONE)
            {
                printf("\tjTTS_GetVoiceAttribute failed . err = %d\n", err);
                continue;
            }
            printf("\t%s\n", attr.szName);
        }
        EndJtts();
    }

    // print valid code page
    printf("\nValid code page is followed :\n");
    printf("\t%5d ----- %s\n", 936,
           "CODEPAGE_GB (Include GB18030, GBK, GB2312)");
    printf("\t%5d ----- %s\n", 950, "CODEPAGE_BIG5");
    printf("\t%5d ----- %s\n", 932, "CODEPAGE_SHIFTJIS");
    printf("\t%5d ----- %s\n", 949, "CODEPAGE_KCS");
    printf("\t%5d ----- %s\n", 1252, "CODEPAGE_ISO8859_1");
    printf("\t%5d ----- %s\n", 1200, "CODEPAGE_UNICODE");
    printf("\t%5d ----- %s\n", 1201, "CODEPAGE_UNICODE_BIGE (BIG Endian)");
    printf("\t%5d ----- %s\n", 65001, "CODEPAGE_UTF8");
    printf("\n");
}

bool ParseArguments(int nArgc,
                    char *szArgList[],
                    const char*& pszSrcFile,
                    const char*& pszDstFile,
                    const char*& pszLibPath,
                    const char*& pszSerialNo,
                    const char*& pszVoiceName,
                    DWORD& nCodePage)
{
    if (nArgc > 6)
        pszSerialNo = szArgList[6];
    if (nArgc > 5)
        pszLibPath = szArgList[5];
    if (nArgc < 5)
        return false;

    pszSrcFile = szArgList[3];
    pszDstFile = szArgList[4];
    pszVoiceName = szArgList[1];
    nCodePage = atoi(szArgList[2]);
    return true;
}

bool GetVoiceIdFromName(const char* szName, char* szOutVoiceId)
{
    int nVoiceCount = jTTS_GetVoiceCount();
    printf("Voice Count : %d \n", nVoiceCount);
    for (nVoiceCount -= 1; nVoiceCount >= 0; nVoiceCount--)
    {
        JTTS_VOICEATTRIBUTE attr;
        ERRCODE err = jTTS_GetVoiceAttribute(nVoiceCount, &attr);
        if (err != ERR_NONE)
        {
            printf("jTTS_GetVoiceAttribute failed . err = %d\n", err);
            return false;
        }
        if (stricmp(szName, attr.szName) == 0)
        {
            strcpy(szOutVoiceId, attr.szVoiceID);
            return true; // success
        }
    }
    return false;
}

void EndJtts()
{
    ERRCODE err = jTTS_End();
    if (err != ERR_NONE)
        printf("jTTS_End failed. err = %d\n", err);
    else
        printf("jTTS_End success.\n");
}

BOOL TTSAPI jTTS_DataCallBack(JTTS_SESSION_HANDLE hSession,
                              WORD wParam,
                              LONG lParam,
                              unsigned char * pVoiceData,
                              DWORD dwLen,
                              INSERTINFO* pInsertInfo,
                              int nInsertInfo,
                              JTTS_HANDLE hUserData)
{
    FILE* fp = (FILE*)hUserData;
    if (fp == NULL) return false;

    switch (wParam)
    {
    case NOTIFY_DATA:
        printf("jTTS_DataCallBack get data: Size=%d\n", dwLen);
        if (dwLen > 0 && pVoiceData != NULL)
        {
            if (fwrite(pVoiceData, 1, dwLen, fp) != dwLen)
            {
                printf("jTTS_DataCallBack failed to write data to file .\n");
                break;
            }
        }
        break;
    default:
        break;
    }

    return true;
}

BOOL TTSAPI jTTS_DataCallBackAsync(JTTS_SESSION_HANDLE hSession,
                                   WORD wParam,
                                   LONG lParam,
                                   unsigned char * pVoiceData,
                                   DWORD dwLen,
                                   INSERTINFO* pInsertInfo,
                                   int nInsertInfo,
                                   JTTS_HANDLE hUserData)
{
    UserData* pUserData = (UserData*)hUserData;
    FILE* fp = pUserData->pFile;
    if (fp == NULL) return false;

    switch (wParam)
    {
    case NOTIFY_DATA:
        printf("Got data: Size=%d\n", dwLen);
        if (dwLen > 0 && pVoiceData != NULL)
        {
            if (fwrite(pVoiceData, 1, dwLen, fp) != dwLen)
            {
                printf("Failed to write data to file .\n");
                break;
            }
        }
        break;
    case NOTIFY_END:
#if defined (WIN32) || defined (_WIN64)
		SetEvent(pUserData->hEvent);
#else
		pthread_cond_signal(pUserData->pCond);
#endif
        break;
    default:
        break;
    }

    return true;
}
