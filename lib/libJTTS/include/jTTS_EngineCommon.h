#ifndef _JTTS_ENGINE_COMMON_H_
#define _JTTS_ENGINE_COMMON_H_

#pragma pack( push, jtts_engine_common_h )
#pragma pack( 8 )

#ifdef __cplusplus
extern "C"
{
#endif

#if defined(WIN32) || defined(WIN64)
#define TTSAPI __stdcall
#else
#define TTSAPI
#endif

#define JTTS_VERSION4		0x0004	// version 4.0

//ERRCODE
typedef enum 
{
    ERR_NONE,			//	0
    ERR_ALREADYINIT,	//	1
    ERR_NOTINIT,		//	2 
    ERR_MEMORY,			//	3
    ERR_INVALIDHWND,	//	4
    ERR_INVALIDFUNC,	//	5
    ERR_OPENLIB,		//	6
    ERR_READLIB,		//	7
    ERR_PLAYING,		//	8
    ERR_DONOTHING,		//	9
    ERR_INVALIDTEXT,	//	10
    ERR_CREATEFILE,		//	11
    ERR_WRITEFILE,		//	12
    ERR_FORMAT,			//	13
    ERR_INVALIDSESSION,	//	14
    ERR_TOOMANYSESSION,	//	15
    ERR_MORETEXT,		//	16
    ERR_CONFIG,			//	17
    ERR_OPENDEVICE,		//	18
    ERR_RESETDEVICE,	//	19
    ERR_PAUSEDEVICE,	//	20
    ERR_RESTARTDEVICE,	//	21
    ERR_STARTTHREAD,	//	22
    ERR_BEGINOLE,		//	23
    ERR_NOTSUPPORT,		//	24
    ERR_SECURITY,		//	25
    ERR_CONVERT,		//	26
    ERR_PARAM,			//	27
    ERR_INPROGRESS,		//  28
    ERR_INITSOCK,		//	29
    ERR_CREATESOCK,		//	30
    ERR_CONNECTSOCK,	//	31
    ERR_TOOMANYCON,		//	32
    ERR_CONREFUSED,		//	33
    ERR_SEND,			//	34
    ERR_RECEIVE,		//	35
    ERR_SERVERSHUTDOWN,	//	36
    ERR_OUTOFTIME,		//	37
    ERR_CONFIGTTS,		//	38
    ERR_SYNTHTEXT,		//	39
    ERR_CONFIGVERSION,	//	40
    ERR_EXPIRED,		//	41
    ERR_NEEDRESTART,	//	42
    ERR_CODEPAGE,		//	43
    ERR_ENGINE,			//	44
    ERR_CREATEEVENT,	//	45
    ERR_PLAYMODE,		//	46
    ERR_OPENFILE,		//	47
    ERR_USERABORT,		//	48
    ERR_LICENSEFULL,	//	49
    ERR_LICENSEFILEINVALID,	//	50
    ERR_LICENSE,            //	51 
    ERR_LICENSEEXPIRED,		//	52
    ERR_SSMLINVALID,		// 53
    ERR_INVALIDPLAYHANDLE,	// 54
}ERRCODE;

//---------------------------------------------------------------------------
// 系统的设置选项

//支持多语种
//
//这里列出的是系统内建的语言定义，需要安装相应音库才能真正支持, 
//但目前并非所有语言都有相应的音库
//
//对于这里没有列出的语言，将来也可能会发布相应的音库，同时会分配一个数值，
//只要安装此音库后，就可以使用。对于没有列出的语言，如果想使用，可以直接使用数值
//
//可以通过Lang系列函数得到所有系统中定义的（包括将来扩展的）语言数值及其描述的信息
//
//对于系统中真正支持的语言，可以通过jTTS_GetVoiceCount, jTTS_GetVoiceAttribute函数
//得到所有安装的音库，并从其属性中知道其语言
//
#define LANGUAGE_MANDARIN				0	// 汉语普通话
#define LANGUAGE_CANTONESE				1	// 广东话
#define LANGUAGE_CHINESE				LANGUAGE_MANDARIN

#define LANGUAGE_US_ENGLISH				10	// 美国英语
#define LANGUAGE_BRITISH_ENGLISH		11	// 英国英语
#define LANGUAGE_ENGLISH				LANGUAGE_US_ENGLISH

#define LANGUAGE_FRENCH					20	// 法语
#define LANGUAGE_CANADIAN_FRENCH		21	// 加拿大法语

#define LANGUAGE_SPANISH				30	// 西班牙语
#define LANGUAGE_LATINAMERICAN_SPANISH	31	// 拉丁美洲西班牙语

#define LANGUAGE_PORTUGUESE				40	// 葡萄牙语
#define LANGUAGE_BRAZILIAN_PORTUGUESE	41	// 巴西葡萄牙语

#define LANGUAGE_DUTCH					50	// 荷兰语
#define LANGUAGE_BELGIAN_DUTCH			51	// 比利时荷兰语

#define LANGUAGE_GERMAN					60	// 德语
#define LANGUAGE_ITALIAN				70	// 意大利语
#define LANGUAGE_SWEDISH				80	// 瑞典语
#define LANGUAGE_NORWEGIAN				90	// 挪威语
#define LANGUAGE_DANISH					100	// 丹麦语
#define LANGUAGE_POLISH					110 // 波兰语
#define LANGUAGE_GREEK					120	// 希腊语
#define LANGUAGE_HUNGARIAN				130 // 匈牙利语
#define LANGUAGE_CZECH					140 // 捷克语
#define LANGUAGE_TURKISH				150 // 土耳其语

#define LANGUAGE_RUSSIAN				500	// 俄语

#define LANGUAGE_ARABIC					600	// 阿拉伯语

#define LANGUAGE_JAPANESE				700	// 日语
#define LANGUAGE_KOREAN					710 // 韩语

#define LANGUAGE_VIETNAMESE				720 // 越南语
#define LANGUAGE_MALAY					730	// 马来语
#define LANGUAGE_THAI					740 // 泰语

//支持多领域
// 
//这里列出的是系统内建的领域定义，需要安装相应音库的资源包才能真正支持。
//
//对于这里没有列出的领域，将来也可能会发布相应的资源包，同时会分配一个数值，
//只要安装此资源包后，就可以使用。对于没有列出的领域，如果想使用，可以直接使用数值
//
//可以通过Domain系列函数得到所有系统中定义的（包括将来扩展的）领域数值及其描述的信息
//
//对于系统中真正支持的领域，可以通过jTTS_GetDomainCount, jTTS_GetDomainAttribute函数
//得到所有安装的领域
#define DOMAIN_COMMON			0		// 通用领域，新闻
#define DOMAIN_FINANCE			1		// 金融证券
#define DOMAIN_WEATHER			2		// 天气预报
#define DOMAIN_SPORTS			3		// 体育赛事
#define DOMAIN_TRAFFIC			4		// 公交信息
#define DOMAIN_TRAVEL			5		// 旅游餐饮
#define DOMAIN_CARBORNE			6		//汽运
#define DOMAIN_QUEUE			7		//排队
#define DOMAIN_SONG				8		//点歌
#define DOMAIN_INSURANCE		9		//保险
#define DOMAIN_VOYAGE			10		//航空
#define DOMAIN_REVENUE			11		//税务
#define DOMAIN_ELECPOWER		12		//电力
#define DOMAIN_MESSAGE			13		//短信
#define DOMAIN_FINAINSU         14      //金融保险
#define DOMAIN_TELECOM          15      //电信 

#define DOMAIN_CUSTOM			28		// 一般定制领域

#define DOMAIN_MIN				0
#define DOMAIN_MAX				31

//支持的CODEPAGE
#define CODEPAGE_GB		        936		// 包括GB18030, GBK, GB2312
#define CODEPAGE_BIG5		    950
#define CODEPAGE_SHIFTJIS	    932
#define CODEPAGE_KCS			949
#define CODEPAGE_ISO8859_1		1252
#define CODEPAGE_UNICODE		1200
#define CODEPAGE_UNICODE_BIGE	1201	// BIG Endian
#define CODEPAGE_UTF8 			65001

// 支持的标记语言类型
#define TAG_AUTO				0x00	// 自动判断, 优先级SSML > S3ML > JTTS > NONE
#define TAG_JTTS				0x01	// 仅处理jTTS Tag，非结构文档，嵌入在普通文本中，如"\read=\"
#define TAG_SSML				0x02	// 按国际标准SSML解析， 对<voice gender=""/>jTTS引擎只负责female
#define TAG_NONE				0x03	// 不按标记语言解析，作为普通文本
#define TAG_S3ML				0x04	// 按SinoVoice Speech Synthesis Markup Language解析，在SSML基础上扩展
#define TAG_VTML				0x05	// 按Voice Transform Markup Language解析


//DigitMode
#define DIGIT_AUTO_NUMBER		0
#define DIGIT_TELEGRAM			1
#define DIGIT_NUMBER			2
#define DIGIT_AUTO_TELEGRAM		3
#define DIGIT_AUTO				DIGIT_AUTO_NUMBER

// PuncMode
#define PUNC_OFF				0	/* 不读符号，自动判断回车换行是否分隔符*/
#define PUNC_ON					1	/* 读符号，  自动判断回车换行是否分隔符*/
#define PUNC_OFF_RTN			2	/* 不读符号，强制将回车换行作为分隔符*/
#define PUNC_ON_RTN				3	/* 读符号，  强制将回车换行作为分隔符*/

// EngMode
#define ENG_AUTO				0	/* 自动方式 */
#define ENG_SAPI				1	/* 强制采用英文读法 */
#define ENG_LETTER				2	/* 强制单字母方式 */
#define ENG_LETTER_PHRASE		3	/* 强制采用字母＋自录音词汇的方式 */

//Gender
#define GENDER_FEMALE			0
#define GENDER_MALE				1
#define GENDER_NEUTRAL			2

//AGE
#define AGE_BABY				0		//0 - 3
#define AGE_CHILD				1		//3 - 12
#define AGE_YOUNG				2		//12 - 18
#define AGE_ADULT				3		//18 - 60
#define AGE_OLD					4		//60 -

//PITCH
#define PITCH_MIN				0
#define PITCH_MAX				9
#define PITCH_MIN_CLOUD			-1
#define PITCH_MAX_CLOUD         1000

//VOLUME
#define VOLUME_MIN				0
#define VOLUME_MAX				9
#define VOLUME_MIN_CLOUD		-1
#define VOLUME_MAX_CLOUD		1000

//SPEED
#define SPEED_MIN				0
#define SPEED_MAX				9
#define SPEED_MIN_CLOUD			-1
#define SPEED_MAX_CLOUD			1000

//AUDIOVOLUME
#define AUDIOVOLUME_MIN			0
#define AUDIOVOLUME_MAX			100

//BACKAUDIOFLAG
#define BACKAUDIOFLAG_REPEAT	0x01
#define BACKAUDIOFLAG_DEFAULT	0x00

//BACKAUDIO
#define BACKAUDIO_NONE			0		// 没有背景音乐
#define BACKAUDIO_MIN			1		// 最小的背景音乐序号
#define BACKAUDIO_MAX			10000	// 最大的背景音乐序号

//VOICESYTLE
#define VOICESTYLE_CADENCE		0		// 抑扬顿挫
#define VOICESTYLE_FLAT			1		// 平稳庄重

//VOICEBUFSIZE
#define VOICEBUFSIZE_DEFAULT	0		// Default: 256K
#define VOICEBUFSIZE_MIN		256		// 256K
#define VOICEBUFSIZE_MAX		8192	// 8M

//INSERTINFOSIZE
#define INSERTINFOSIZE_DEFAULT	0		// Default: 100
#define INSERTINFOSIZE_MIN		1
#define INSERTINFOSIZE_MAX		1000

//---------------------------------------------------------------------------

//jTTS_Play状态	
#define STATUS_NOTINIT	0
#define STATUS_READING	1
#define STATUS_PAUSE	2
#define STATUS_IDLE		3

//jTTS_PlayToFile的文件格式
#define FORMAT_WAV			0	// PCM Native (和音库一致，目前为16KHz, 16Bit)
#define FORMAT_VOX_6K		1	// OKI ADPCM, 6KHz, 4bit (Dialogic Vox)
#define FORMAT_VOX_8K		2	// OKI ADPCM, 8KHz, 4bit (Dialogic Vox)
#define FORMAT_ALAW_8K		3	// A律, 8KHz, 8Bit
#define FORMAT_uLAW_8K		4	// u律, 8KHz, 8Bit
#define FORMAT_WAV_8K8B		5	// PCM, 8KHz, 8Bit
#define FORMAT_WAV_8K16B	6	// PCM, 8KHz, 16Bit
#define FORMAT_WAV_16K8B	7	// PCM, 16KHz, 8Bit
#define FORMAT_WAV_16K16B	8	// PCM, 16KHz, 16Bit
#define FORMAT_WAV_11K8B	9	// PCM, 11.025KHz, 8Bit
#define FORMAT_WAV_11K16B	10	// PCM, 11.025KHz, 16Bit
#define FORMAT_G726_16KBIT	11	// G726, 8KHz, 2Bit
#define FORMAT_G726_24KBIT	12	// G726, 8KHz, 3Bit
#define FORMAT_G726_32KBIT	13	// G726, 8KHz, 4Bit
#define FORMAT_G726_40KBIT	14	// G726, 8KHz, 5Bit
/*
#define FORMAT_WAV_22K8B	11	// PCM, 22.050KHz, 8Bit
#define FORMAT_WAV_22K16B	12	// PCM, 22.050KHz, 16Bit
*/

#define FORMAT_FIRST		0
#define FORMAT_LAST			10

// jTTS_Play / jTTS_PlayToFile / jTTS_SessionStart 函数支持的dwFlag定义

// 此项仅对jTTS_PlayToFile适用
#define PLAYTOFILE_DEFAULT		0x0000	//默认值,写文件时只增加FORMAT_WAV_...格式的文件头
#define PLAYTOFILE_NOHEAD		0x0001	//所有的格式都不增加文件头
#define PLAYTOFILE_ADDHEAD		0x0002	//增加FORMAT_WAV_...格式和FORMAT_ALAW_8K,FORMAT_uLAW_8K格式的文件头

#define PLAYTOFILE_MASK			0x000F

// 此项仅对jTTS_Play适用
#define PLAY_RETURN				0x0000	// 如果正在播放，返回错误
#define PLAY_INTERRUPT			0x0010	// 如果正在播放，打断原来的播放，立即播放新的内容

#define PLAY_MASK				0x00F0

// 播放的内容
#define PLAYCONTENT_TEXT		0x0000	// 播放内容为文本
#define PLAYCONTENT_TEXTFILE	0x0100	// 播放内容为文本文件
#define PLAYCONTENT_AUTOFILE	0x0200	// 播放内容为文件，根据后缀名采用外界Filter DLL抽取
// 无法判断的当作文本文件

#define PLAYCONTENT_MASK		0x0F00

// 播放的模式，同时用于SessionStart
#define PLAYMODE_DEFAULT		0x0000	// 在jTTS_Play下缺省异步，在jTTS_PlayToFile下缺省同步
// jTTS_SessionStart下为主动获取数据方式
#define PLAYMODE_ASYNC			0x1000	// 异步播放，函数立即退出
#define PLAYMODE_SYNC			0x2000	// 同步播放，播放完成后退出

#define PLAYMODE_MASK			0xF000

// jTTS_FindVoice返回的匹配级别
#define MATCH_LANGUAGE			0	// 满足LANGUAGE，
#define MATCH_GENDER			1	// 满足LANGUAGE, GENDER
#define MATCH_AGE				2	// 满足LANGUAGE, GENDER, AGE
#define MATCH_NAME				3	// 满足LANGUAGE, GENDER，AGE，NAME
#define MATCH_DOMAIN			4	// 满足LANGUAGE, GENDER，AGE，NAME, DOMAIN，也即满足所有条件
#define MATCH_ALL				4	// 满足所有条件

// InsertInfo信息
#define INFO_MARK				0
#define INFO_VISEME				1

    //各种信息串的长度
#define VOICENAME_LEN			32
#define VOICEID_LEN				40
#define VENDOR_LEN				32
#define DLLNAME_LEN				256

#define ATTRNAME_LEN			32
#define XMLLANG_LEN				256

//JTTS_PARAM
typedef enum 
{
    PARAM_CODEPAGE,			// CODEPAGE_xxx
    PARAM_VOICEID,			// Voice ID
    PARAM_PITCH,			// PITCH_MIN - PITCH_MAX
    PARAM_VOLUME,		    // VOLUME_MIN - VOLUME_MAX
    PARAM_SPEED,			// SPEED_MIN - SPEED_MAX
    PARAM_PUNCMODE,			// PUNC_xxx
    PARAM_DIGITMODE,		// DIGIT_xxx
    PARAM_ENGMODE,			// ENG_xxx
    PARAM_TAGMODE,			// TAG_xxx
    PARAM_DOMAIN,		    // DOMAIN_xxx
    PARAM_TRYTIMES,         // 0-100
    PARAM_IDLETIME,         // 0-60 (s), default 10, 0 means 无限等待
    PARAM_LOADBALANCE,		// TRUE, FALSE
    PARAM_VOICESTYLE,		// VOICESTYLE_CADENCE, VOICESTYLE_FLAT
    PARAM_BACKAUDIO,		// BACKAUDIO_NONE, BACKAUDIO_MIN - BACKAUDIO_MAX
    PARAM_BACKAUDIOVOLUME,	// AUDIOVOLUME_MIN - AUDIOVOLUME_MAX
    PARAM_BACKAUDIOFLAG,	// BACKAUDIOFLAG_xxx
    PARAM_VOICEBUFSIZE,		// VOICEBUFSIZE_DEFAULT, or n (K)
    PARAM_INSERTINFOSIZE,	// INSERTINFOSIZE_DEFAULT, or n
	PARAM_PITCHPRECISION,	//PITCH_MIN - PITCH_CLOUD_MAX
	PARAM_VOLUMEPRECISION,	//VOLUME_MIN - VOLUME_CLOUD_MAX
	PARAM_SPEEDPRESISION,	//SPEED_MIN - SPEED_CLOUD_MAX
}
JTTS_PARAM;


// 插入信息
typedef struct INSERTINFO_T
{
    int nTag;		// 有二种：INFO_MARK, INFO_VISEME
    unsigned int dwValue; 	// 具体信息：
    // MARK时，高24位mark文本偏移，低8位文本长度
    // VISEME时，表示唇型
    unsigned int dwBytes;	// 在语音流的什么地方插入，必须按顺序增加
}
INSERTINFO;

// 会话句柄
typedef void * JTTS_SESSION_HANDLE;
typedef void * JTTS_PARAM_VALUE;
// 其他与指针相关的
typedef void * JTTS_HANDLE;

#ifdef __cplusplus
}
#endif

#pragma pack( pop, jtts_engine_common_h )

#endif //_JTTS_ENGINE_COMMON_H_
