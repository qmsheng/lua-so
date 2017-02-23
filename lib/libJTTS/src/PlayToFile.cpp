/*
 * 版权声明: 暂无
 * 文件名称: play2file.c
 * 创建者  : luokaihui
 * 创建日期: 2015/06/08
 * 文件描述: 灵云TTS SDK的文字转语音函数封装
 * 历史记录: 新创建
*/
#include "stdio.h"
#include "jOSTypes.h"
#include "jSys.h"
#include "jTTS_ML.h"
#include "Common.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <limits.h>

/*  三个有关 lua 的头文件   */
extern  "C"{

#include "luajit-2.0/lua.h"
#include "luajit-2.0/lualib.h"
#include "luajit-2.0/lauxlib.h" 

/*  库open函数的前置声明   */
int luaopen_lingyun_voice(lua_State *L); 

/* 名  称: mirrtalk_text_2_voice
 * 功  能: 把文字转换为语音文件,基于灵云SDK
 * 参  数: text, 要转换的文字
 *         output_file, 输出的语音文件名字
 *         service,  灵云TTS服务器地址和端口(ip:port)
 *         vol,      音量，取值范围0-9,默认为9
 *         speed,    合成语速，取值范围0-9，默认为5
 * 返回值: -1, 表示失败
 *          0, 表示成功
 * 修  改: 新生成函数luokaihui at 2015/06/08
*/
int mirrtalk_backend_text_2_voice(lua_State *L)//(char *text, char *output_file, char *service, int vol, int speed)
{ 
    char * text        =  (char *)luaL_checkstring(L, 1); 
    char * output_file =  (char *)luaL_checkstring(L, 2);
    char * service     =  (char *)luaL_checkstring(L, 3);
    int    vol         =  luaL_checknumber(L,4);
    int    speed       =  luaL_checknumber(L,5);

    /* 语音库标识符，灵云提供多个语音库，目前我们安装了一个 */
    const char *vId = "1C71A78E-AFC5-440A-9FDD-F8BD169E0186";

    ERRCODE err = ERR_NONE;
    
    /* 初始化jTTS */ 
    err = jTTS_Init(service, "");
    if (err != ERR_NONE){
        return -1;
    }
    

    /*
     * 语音合成配置参数结构体
     * typedef struct JTTS_CONFIG_T
     * {
     *     WORD wVersion;                    此结构的版本号。目前必须设置为 4
     *     WORD nCodePage;                   所设置的字符编码,系统内部缺省为 CODEPAGE_GBK
     *     char szVoiceID[VOICEID_LEN];      音库标识,系统内部缺省为中文女声音库
     *     short nDomain;                    领域设置,缺省为 DOMAIN_COMMON
     *     short nPitch;                     合成语音的基频,按照 0~9 分为 10 级,缺省值为 5。数字越大基频越高
     *     short nVolume;                    合成语音的音量,按照 0~9 分为 10 级,缺省值为 9。数字越大音量越大
     *     short nSpeed;                     合成语音的语速,按照 0~9 分为 10 级,缺省值为 5。数字越大语速越快
     *     short nPuncMode;                  标点和回车的设置,系统内部缺省为不阅读标点
     *     short nDigitMode;                 数字的阅读方式,分两种，一种是逐字阅读，一种是按数目阅读，缺省为根据上下自动选择
     *     short nEngMode;                   英文的阅读方式,默认自动判断
     *     short nTagMode;                   标签的处理方式(支持工程师不建议使用s3ml)
     *     short nTryTimes;                  在连接服务器时的重试次数,有效值为1-100。缺省为10。
     *     BOOL bLoadBalance;                在远程合成期间如果发生网络连接错误是否试另外的服务器。可以为
     *                                       TRUE或FALSE。缺省值为FALSE。
     *     short nVoiceStyle;                朗读风格,分两种风格,抑扬顿挫风格，平稳庄重风格
     *     short nBackAudio;                 背景音乐有无或者自定义
     *     short nBackAudioVolume;           背景音乐的音量,从小到大为 0~100,默认值为 50
     *     WORD wBackAudioFlag;              背景音乐是否循环播放,默认值为不循环播放
     *     short nVoiceBufSize;              数据的输出缓冲区大小,以 K 为单位。范围是 16~8192,也即从 16K~8M,默认值为
     *                                       128(K)。用户在获取数据时,每段的长度不会超过此缓冲区大小
     *     short nInsertInfoSize;            插入信息的输出缓冲区大小,表示多少条插入信息。范围是 1~1000,默认值为 100
     *     short nReserved[6];               保留的数据,必须设置为0
     *     }JTTS_CONFIG;
    */
    JTTS_CONFIG sConfig;

    /* 获取当前合成配置参数 */
    err = jTTS_Get(&sConfig);
    if (err != ERR_NONE){
        EndJtts();
        return -1;
    }

    memcpy(sConfig.szVoiceID, vId, strlen(vId));
    
    /* 字符集设置为utf-8 */
    sConfig.nCodePage =  65001;
    
    /* 设置音量 */
    sConfig.nVolume   =  vol%10;

    /* 设置语速 */
    sConfig.nSpeed    =  speed%10;

    /* 不解析标签 */
    sConfig.nTagMode  =  TAG_NONE;

    /* 公共领域 */
    sConfig.nDomain   =  0;
    
    /* 设置合成参数到服务器 */
    err =  jTTS_Set(&sConfig);
    if (err != ERR_NONE){
        EndJtts();
        return -1;
    }
    
    /* 语音合成函数说明
    *  ERRCODE TTSAPI jTTS_PlayToFile(
    *                    const char *pcszText,           指向待合成的文本缓冲区的指针
    *                    const char * pcszFileName,      指定的语音文件名
    *                    UINT nFormat,                   指定的输出语音的格式
    *                    FORMAT_WAV        0  WAV文件格式,语音采样率和每采样的位数由系统内部决定                
    *                    FORMAT_VOX_6K     1  6KHz,  4Bit  VOX格式, 也即Dialogic ADPAM格式
    *                    FORMAT_VOX_8K     2  8KHz,  4Bit  VOX格式, 也即Dialogic ADPAM格式
    *                    FORMAT_ALAW_8K    3  8KHz,  8Bit  ALaw格式
    *                    FORMAT_uLAW_8K    4  8KHz,  8Bit  uLaw格式
    *                    FORMAT_WAV_8K8B   5  8KHz,  8Bit  PCM格式
    *                    FORMAT_WAV_8K16B  6  8KHz,  16Bit PCM格式 
    *                    FORMAT_WAV_16K8B  7  16KHz, 8Bit  PCM格式 
    *                    FORMAT_WAV_16K16B 8  16KHz, 16Bit PCM格式  
    *                    FORMAT_WAV_11K8B  9  11KHz, 8Bit  PCM格式 
    *                    FORMAT_WAV_11K16B 10 11KHz, 16Bit PCM格式 
    *                    const JTTS_CONFIG * pConfig,    合成的参数,如果NULL,则使用默认配置中的语音合成参数
    *                    DWORD dwFlag,                   指定合成的一些方式
    *                    JTTS_CALLBACKPROC lpfnCallback, 回调函数地址
    *                    DWORD dwUserData                用户传入的自定义数据,回调时将回传给回调函数
    *                    );
    */

    /* 合成语音 */
    err = jTTS_PlayToFile(text, output_file, 0, NULL,
                          PLAYCONTENT_TEXT, NULL, (JTTS_HANDLE)0);
    if (err != ERR_NONE){
        EndJtts();
        return -1;
    }
   
    /* 结束语音合成，释放资源 */
    EndJtts();

    return 0;
}
static const luaL_Reg lingyun_voice_lib[] = {

   {"lingyun_text_2_voice", mirrtalk_backend_text_2_voice},

   {0,0}

};
 
/*  库打开时的执行函数（相当于这个库的 main 函数），执行完这个函数后， lua 中就可以加载这个 so 库了   */
int luaopen_libtext2voice(lua_State *L)
{

   /* 把那个结构体数组注册到mt（名字可自己取)库中去 */
   //luaL_newlib(L,lingyun_voice_lib);
   luaL_register(L, "lingyun_tts", lingyun_voice_lib);
   return 1;
} 
#if 0
int main(int argc, char **argv)
{   
    const char *input = "你好";
    const char *file  = "5.wav";
    const char *srv   = "192.168.1.9:3000";
    mirrtalk_backend_text_2_voice((char *)input, (char *)file, (char *)srv);
}
#endif 
}
