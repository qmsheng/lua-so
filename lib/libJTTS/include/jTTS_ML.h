#ifndef _JTTS_ML_H_
#define _JTTS_ML_H_

#include <stdio.h> 
#include "jTTS_EngineCommon.h"

#pragma pack( push, jtts_ml_h )
#pragma pack( 8 )

#ifdef __cplusplus
extern "C"
{
#endif

#if defined(WIN32) || defined(WIN64)
#define TTSAPI __stdcall
#define TTSAPIEXPORT
#else
#define TTSAPI
#define TTSAPIEXPORT __attribute ((visibility("default")))
#endif

typedef struct JTTS_CONFIG_T
{
	unsigned short	wVersion;		// JTTS_VERSION4
	unsigned short	nCodePage;
	char	szVoiceID[VOICEID_LEN];	// 使用的音色
	short	nDomain;	
	short	nPitch;
	short	nVolume;
	short	nSpeed;
	short	nPuncMode;
	short	nDigitMode;
	short	nEngMode;
	short	nTagMode;
	short   nTryTimes;			// 重试次数,此成员仅用于远程合成
	short	nIdleTime;			// 网络操作的等待时间, 此成员仅用于远程合成
	int     bLoadBalance;		// 负载平衡,此成员仅用于远程合成
	short	nVoiceStyle;		// 朗读风格
	short	nBackAudio;			// BACKAUDIO_NONE: 无背景音乐，BACKAUDIO_MIN-BACKAUDIO_MAX: 背景音乐序号，在资源管理中心"录音管理器"中定义
	short	nBackAudioVolume;	// 背景音乐的音量
	unsigned short	wBackAudioFlag;		// 背景音乐的属性
	short	nVoiceBufSize;		// 设置内部缓冲区的大小
	short	nInsertInfoSize;	// 缓冲区中插入信息的个数
	short	nReserved[6];		// 保留
#ifndef _J_LOAD_BALANCE_
    //-------增加基频、音量、语速高精度数[11/10/2014 chenwenpeng]-------//
	short   nPitchInPrecision;	//高精度基频
	short   nVolumeInPrecision;	//高精度音量
	short	nSpeedInPrecision;	//高精度语速
#endif
} JTTS_CONFIG;

//JTTS_VOICEATTRIBUTE
typedef struct JTTS_VOICEATTRIBUTE_T
{
    char		szName[VOICENAME_LEN];	// 只能为英文名称
    char		szVoiceID[VOICEID_LEN];	// 音色的唯一标识
    short		nGender;				// GENDER_xxx
    short		nAge;					// AGE_xx
    unsigned int		dwDomainArray;			// 由低位向高位，分别表示DOMAIN_xxx
    unsigned int		nLanguage;				// 支持的语言, LANGUAGE_xxx
    char		szVendor[VENDOR_LEN];	// 提供厂商
    char		szDLLName[DLLNAME_LEN];	// 对应的DLL
    unsigned int		dwVersionMS;			// 引擎的版本号，对应"3.75.0.31"的前两节
    // e.g. 0x00030075 = "3.75"
    unsigned int		dwVersionLS;			// e.g. 0x00000031 = "0.31"
}
JTTS_VOICEATTRIBUTE;


typedef struct JTTS_LANGATTRIBUTE_T
{
    int	  nValue;
    char  szName[ATTRNAME_LEN];
    char  szEngName[ATTRNAME_LEN];
    char  szXmlLang[XMLLANG_LEN];
}
JTTS_LANGATTRIBUTE;

typedef struct JTTS_DOMAINATTRIBUTE_T
{
    int   nValue;
    char  szName[ATTRNAME_LEN];
    char  szEngName[ATTRNAME_LEN];
}
JTTS_DOMAINATTRIBUTE;

typedef struct JTTS_COUNTERS_T
{	
    int nSession;
}
JTTS_COUNTERS;


// 系统通知消息及回调函数部分

// 系统通知消息
#define WM_JTTS_NOTIFY			(WM_USER + 0x4999)

// 回调函数
typedef BOOL (TTSAPI * JTTS_CALLBACKPROC)(WORD wParam, LONG lParam, JTTS_HANDLE hUserData);
typedef BOOL (TTSAPI * JTTS_DATACALLBACKPROC)(JTTS_SESSION_HANDLE hSession, WORD wParam, LONG lParam, 
    unsigned char * pVoiceData, DWORD dwLen, 
    INSERTINFO* pInsertInfo, int nInsertInfo, 
    JTTS_HANDLE hUserData);

// WM_JTTS_NOTIFY / JTTS_CALLBACKPROC / JTTS_DATACALLBACKPROC中wParam的定义
#define NOTIFY_BEGIN			0	// lParam: 没有使用
#define NOTIFY_END				1	// lParam: 没有使用
#define NOTIFY_SENTEND			2	// lParam: 已经读完的字节数
#define NOTIFY_SENTBEGIN		3	// lParam: 将要读到的位置（以字节数计算）
#define NOTIFY_MARK				4	// lParam: 标记Mark串的位置和长度, 参考宏GETMARKOFFSET和GETMARKLEN
#define NOTIFY_VISEME			5	// lParam: 标记唇型信息，现版本中未使用
#define NOTIFY_CHANGECONFIG		6	// 系统主动使用与传入Config不同的配置
#define NOTIFY_DATA				7	// 仅用于 JTTS_DATACALLBACKPROC，传递合成数据和InsertInfo信息 
// lParam not use; dwLen是pVoiceData长度; pVoiceData语音数据缓冲; 
// nInsertInfo, pInsertInfo是插入数据的数目和内容

// 为和老版本兼容而保留
#define NOTIFY_PROGRESS			2	
#define NOTIFY_PROGRESS2		3	

// 通过NOTIFY_MARK的lParam得到具体的Mark String的偏移量和长度
#define GETMARKOFFSET(lParam)	(lParam >> 8)
#define GETMARKLEN(lParam)		(lParam & 0xFF)

//------------------------------------------------------------------------
// 系统函数
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Init(const char * pcszLibPath, const char * pcszSerialNo);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_End();

TTSAPIEXPORT int		TTSAPI jTTS_GetLangCount();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetLangAttribute(int nIndex, JTTS_LANGATTRIBUTE * pAttribute);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetLangAttributeByValue(int nValue, JTTS_LANGATTRIBUTE * pAttribute);

TTSAPIEXPORT int		TTSAPI jTTS_GetDomainCount();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetDomainAttribute(int nIndex, JTTS_DOMAINATTRIBUTE * pAttribute);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetDomainAttributeByValue(int nValue, JTTS_DOMAINATTRIBUTE * pAttribute);

//-------------------------------------------------------------
// 音库信息函数
TTSAPIEXPORT int		TTSAPI jTTS_GetVoiceCount();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetVoiceAttribute(int nIndex, JTTS_VOICEATTRIBUTE * pAttribute);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetVoiceAttributeByID(const char *pszVoiceID, JTTS_VOICEATTRIBUTE * pAttribute);
TTSAPIEXPORT BOOL	TTSAPI jTTS_IsVoiceSupported(const char *pszVoiceID);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_FindVoice(int nLanguage, int nGender, int nAge, char * szName, int nDomain, 
    char * pszVoiceID, WORD * pwMatchFlag);

TTSAPIEXPORT ERRCODE TTSAPI jTTS_PreLoad (const char *pszVoiceID);

//------------------------------------------------------------------------
// 设置函数 
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Set(const JTTS_CONFIG * pConfig);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Get(JTTS_CONFIG * pConfig);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_SetParam(JTTS_PARAM nParam, JTTS_PARAM_VALUE hParamValue);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetParam(JTTS_PARAM nParam, JTTS_PARAM_VALUE *pParamValue);

//------------------------------------------------------------------------
// 播放函数 

// Simple interface (Single thread and device interface)

TTSAPIEXPORT ERRCODE TTSAPI jTTS_SetPlay(UINT uDeviceID, HWND hwnd, JTTS_CALLBACKPROC lpfnCallback, JTTS_HANDLE hUserData);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Play(const char * pcszText, DWORD dwFlag);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Stop();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Pause();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Resume();
TTSAPIEXPORT int     TTSAPI jTTS_GetStatus();

// Comlete interface

/* @name jTTS_PlayCreate() Create a play handle
* @return Handle of play, used in subsequence interface, and must be destroied by using jTTS_PlayDestroy.
*/
DWORD   TTSAPI jTTS_PlayCreate();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlayDestroy(DWORD dwHandle);

TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlaySetPlay(DWORD dwHandle, UINT uDeviceID, HWND hwnd, JTTS_CALLBACKPROC lpfnCallback, JTTS_HANDLE hUserData);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlayPlay(DWORD dwHandle, const char * pcszText, DWORD dwFlag);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlayStop(DWORD dwHandle);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlayPause(DWORD dwHandle);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlayResume(DWORD dwHandle);
TTSAPIEXPORT int     TTSAPI jTTS_PlayGetStatus(DWORD dwHandle);

//------------------------------------------------------------------------
// 播放到文件函数 
TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlayToFile(const char *pcszText, const char * pcszFileName, 
    UINT nFormat, const JTTS_CONFIG * pConfig, 
    DWORD dwFlag, JTTS_CALLBACKPROC lpfnCallback, 
    JTTS_HANDLE hUserData);

//-------------------------------------------------------------
// 合成过程底层函数
TTSAPIEXPORT ERRCODE TTSAPI jTTS_SessionStart(const char * pcszText, JTTS_SESSION_HANDLE * phSession, 
    UINT nFormat, const JTTS_CONFIG *pConfig, DWORD dwFlag, 
    int * pnBitsPerSample, int * pnSamplesPerSec);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_SessionGetData(JTTS_SESSION_HANDLE hSession, int nBufIndex, unsigned char ** ppVoiceData, 
    DWORD * pdwLen, int nReserveLen, INSERTINFO** ppInsertInfo,
    int* pnInsertInfo);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_SessionStop(JTTS_SESSION_HANDLE hSession);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_SessionGetReadBytes(JTTS_SESSION_HANDLE hSession, DWORD * pdwBytes);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_SessionExec(JTTS_SESSION_HANDLE hSession, JTTS_DATACALLBACKPROC lpfnDataCallback, JTTS_HANDLE hUserData);

//---------------------------------------------------------------
// 动态配置函数
TTSAPIEXPORT ERRCODE TTSAPI jTTS_ReConfig();

#ifdef __cplusplus
}
#endif

#pragma pack( pop, jtts_ml_h )

#endif //_JTTS_ML_H_



