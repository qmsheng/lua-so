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
	char	szVoiceID[VOICEID_LEN];	// ʹ�õ���ɫ
	short	nDomain;	
	short	nPitch;
	short	nVolume;
	short	nSpeed;
	short	nPuncMode;
	short	nDigitMode;
	short	nEngMode;
	short	nTagMode;
	short   nTryTimes;			// ���Դ���,�˳�Ա������Զ�̺ϳ�
	short	nIdleTime;			// ��������ĵȴ�ʱ��, �˳�Ա������Զ�̺ϳ�
	int     bLoadBalance;		// ����ƽ��,�˳�Ա������Զ�̺ϳ�
	short	nVoiceStyle;		// �ʶ����
	short	nBackAudio;			// BACKAUDIO_NONE: �ޱ������֣�BACKAUDIO_MIN-BACKAUDIO_MAX: ����������ţ�����Դ��������"¼��������"�ж���
	short	nBackAudioVolume;	// �������ֵ�����
	unsigned short	wBackAudioFlag;		// �������ֵ�����
	short	nVoiceBufSize;		// �����ڲ��������Ĵ�С
	short	nInsertInfoSize;	// �������в�����Ϣ�ĸ���
	short	nReserved[6];		// ����
#ifndef _J_LOAD_BALANCE_
    //-------���ӻ�Ƶ�����������ٸ߾�����[11/10/2014 chenwenpeng]-------//
	short   nPitchInPrecision;	//�߾��Ȼ�Ƶ
	short   nVolumeInPrecision;	//�߾�������
	short	nSpeedInPrecision;	//�߾�������
#endif
} JTTS_CONFIG;

//JTTS_VOICEATTRIBUTE
typedef struct JTTS_VOICEATTRIBUTE_T
{
    char		szName[VOICENAME_LEN];	// ֻ��ΪӢ������
    char		szVoiceID[VOICEID_LEN];	// ��ɫ��Ψһ��ʶ
    short		nGender;				// GENDER_xxx
    short		nAge;					// AGE_xx
    unsigned int		dwDomainArray;			// �ɵ�λ���λ���ֱ��ʾDOMAIN_xxx
    unsigned int		nLanguage;				// ֧�ֵ�����, LANGUAGE_xxx
    char		szVendor[VENDOR_LEN];	// �ṩ����
    char		szDLLName[DLLNAME_LEN];	// ��Ӧ��DLL
    unsigned int		dwVersionMS;			// ����İ汾�ţ���Ӧ"3.75.0.31"��ǰ����
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


// ϵͳ֪ͨ��Ϣ���ص���������

// ϵͳ֪ͨ��Ϣ
#define WM_JTTS_NOTIFY			(WM_USER + 0x4999)

// �ص�����
typedef BOOL (TTSAPI * JTTS_CALLBACKPROC)(WORD wParam, LONG lParam, JTTS_HANDLE hUserData);
typedef BOOL (TTSAPI * JTTS_DATACALLBACKPROC)(JTTS_SESSION_HANDLE hSession, WORD wParam, LONG lParam, 
    unsigned char * pVoiceData, DWORD dwLen, 
    INSERTINFO* pInsertInfo, int nInsertInfo, 
    JTTS_HANDLE hUserData);

// WM_JTTS_NOTIFY / JTTS_CALLBACKPROC / JTTS_DATACALLBACKPROC��wParam�Ķ���
#define NOTIFY_BEGIN			0	// lParam: û��ʹ��
#define NOTIFY_END				1	// lParam: û��ʹ��
#define NOTIFY_SENTEND			2	// lParam: �Ѿ�������ֽ���
#define NOTIFY_SENTBEGIN		3	// lParam: ��Ҫ������λ�ã����ֽ������㣩
#define NOTIFY_MARK				4	// lParam: ���Mark����λ�úͳ���, �ο���GETMARKOFFSET��GETMARKLEN
#define NOTIFY_VISEME			5	// lParam: ��Ǵ�����Ϣ���ְ汾��δʹ��
#define NOTIFY_CHANGECONFIG		6	// ϵͳ����ʹ���봫��Config��ͬ������
#define NOTIFY_DATA				7	// ������ JTTS_DATACALLBACKPROC�����ݺϳ����ݺ�InsertInfo��Ϣ 
// lParam not use; dwLen��pVoiceData����; pVoiceData�������ݻ���; 
// nInsertInfo, pInsertInfo�ǲ������ݵ���Ŀ������

// Ϊ���ϰ汾���ݶ�����
#define NOTIFY_PROGRESS			2	
#define NOTIFY_PROGRESS2		3	

// ͨ��NOTIFY_MARK��lParam�õ������Mark String��ƫ�����ͳ���
#define GETMARKOFFSET(lParam)	(lParam >> 8)
#define GETMARKLEN(lParam)		(lParam & 0xFF)

//------------------------------------------------------------------------
// ϵͳ����
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Init(const char * pcszLibPath, const char * pcszSerialNo);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_End();

TTSAPIEXPORT int		TTSAPI jTTS_GetLangCount();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetLangAttribute(int nIndex, JTTS_LANGATTRIBUTE * pAttribute);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetLangAttributeByValue(int nValue, JTTS_LANGATTRIBUTE * pAttribute);

TTSAPIEXPORT int		TTSAPI jTTS_GetDomainCount();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetDomainAttribute(int nIndex, JTTS_DOMAINATTRIBUTE * pAttribute);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetDomainAttributeByValue(int nValue, JTTS_DOMAINATTRIBUTE * pAttribute);

//-------------------------------------------------------------
// ������Ϣ����
TTSAPIEXPORT int		TTSAPI jTTS_GetVoiceCount();
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetVoiceAttribute(int nIndex, JTTS_VOICEATTRIBUTE * pAttribute);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetVoiceAttributeByID(const char *pszVoiceID, JTTS_VOICEATTRIBUTE * pAttribute);
TTSAPIEXPORT BOOL	TTSAPI jTTS_IsVoiceSupported(const char *pszVoiceID);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_FindVoice(int nLanguage, int nGender, int nAge, char * szName, int nDomain, 
    char * pszVoiceID, WORD * pwMatchFlag);

TTSAPIEXPORT ERRCODE TTSAPI jTTS_PreLoad (const char *pszVoiceID);

//------------------------------------------------------------------------
// ���ú��� 
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Set(const JTTS_CONFIG * pConfig);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_Get(JTTS_CONFIG * pConfig);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_SetParam(JTTS_PARAM nParam, JTTS_PARAM_VALUE hParamValue);
TTSAPIEXPORT ERRCODE TTSAPI jTTS_GetParam(JTTS_PARAM nParam, JTTS_PARAM_VALUE *pParamValue);

//------------------------------------------------------------------------
// ���ź��� 

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
// ���ŵ��ļ����� 
TTSAPIEXPORT ERRCODE TTSAPI jTTS_PlayToFile(const char *pcszText, const char * pcszFileName, 
    UINT nFormat, const JTTS_CONFIG * pConfig, 
    DWORD dwFlag, JTTS_CALLBACKPROC lpfnCallback, 
    JTTS_HANDLE hUserData);

//-------------------------------------------------------------
// �ϳɹ��̵ײ㺯��
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
// ��̬���ú���
TTSAPIEXPORT ERRCODE TTSAPI jTTS_ReConfig();

#ifdef __cplusplus
}
#endif

#pragma pack( pop, jtts_ml_h )

#endif //_JTTS_ML_H_



