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
#include <time.h>
#include <uuid/uuid.h>

/*  三个有关 lua 的头文件   */
extern  "C"{

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

/*  库open函数的前置声明   */
int luaopen_jText2Voice(lua_State *L); 


static int get_temp_filename(int type, char *out_filename)
{
    char str[37] = {0};
    uuid_t uuid;
    uuid_generate_time(uuid);
    uuid_unparse(uuid,str);
    switch(type)
    {
        case 1:
            sprintf(out_filename,"/tmp/dfs_tmp_%s.wav",str);
            return 0;
        case 2:
            sprintf(out_filename,"/tmp/dfs_tmp_%s.mp3",str);
            return 0;
        case 3:
            sprintf(out_filename,"/tmp/dfs_tmp_%s.amr",str);
            return 0;
        default:
            return 1;
    }
}

static int get_file_size(char *file_name)
{
    struct stat st;
    if(stat(file_name,&st) == 0 )
    {
        return st.st_size;
    }
    return -1;
}

/* 名  称: mirrtalk_text_2_voice
 * 功  能: 把文字转换为语音文件,基于灵云SDK
 * 参  数: service,  灵云TTS服务器地址和端口(ip:port)
 *         text, 要转换的文字
 *         vol,      音量，取值范围0-9,默认为9
 *         speed,    合成语速，取值范围0-9，默认为5

 * 返回值 
 * 1:  1 succed / nil  failed
 * 2:  succed : out buffer  / failed : failed message 
 * 3:  succed : buffer length / failed : nil
*/


int text_2_voice_C(lua_State *L) //(char *service, char *text, int vol, int speed)
{ 

    int args = lua_gettop(L);
    if( args < 2)
    {
        lua_pushnil(L);
        lua_pushstring(L,"args count is error");
        lua_pushnumber(L,0);
        return 1;
    }

    const char *service =  (char *)luaL_checkstring(L, 1);
    const char *text    =  (char *)luaL_checkstring(L, 2); 
        /* 语音库标识符，灵云提供多个语音库，目前我们安装了一个 */
    const char *vId = (char *)luaL_checkstring(L, 3);
    int volume = 9 ;
    int speed = 7 ;


    if( args == 3 )
    {
        volume = lua_tointeger(L, 4 );
    }
    else if ( args == 4 )
    {
        volume = lua_tointeger(L, 5 );
        speed  = lua_tointeger(L, 6 );
    }




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
        lua_pushnil(L);
        lua_pushstring(L,"jTTS_Get config failed");
        lua_pushnumber(L,0);
        return 3;
    }

    memcpy(sConfig.szVoiceID, vId, strlen(vId));
    
    /* 字符集设置为utf-8 */
    sConfig.nCodePage =  65001;
    
    /* 设置音量 */
    sConfig.nVolume   =  volume % 10;

    /* 设置语速 */
    sConfig.nSpeed    =  speed % 10;

    /* 不解析标签 */
    sConfig.nTagMode  =  TAG_NONE;

    /* 公共领域 */
    sConfig.nDomain   =  0;
    
    /* 设置合成参数到服务器 */
    err =  jTTS_Set(&sConfig);
    if (err != ERR_NONE){
        EndJtts();

        lua_pushnil(L);
        lua_pushstring(L,"jTTS_Set config failed");
        lua_pushnumber(L,0);

        return 3;
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


#define CURRENT_MAX_PATH  64

    char output_file[CURRENT_MAX_PATH]  = {0};
    get_temp_filename(1,output_file);

    /* 合成语音 */
    err = jTTS_PlayToFile(text, output_file, 0, NULL,
                          PLAYCONTENT_TEXT, NULL, (JTTS_HANDLE)0);
    if (err != ERR_NONE){
        EndJtts();

        lua_pushnil(L);
        lua_pushfstring(L,"jTTS_PlayToFile failed %d ",err);
        lua_pushnumber(L,0);

        return 3;
    }

    int out_length = get_file_size(output_file);
    if(out_length < 0 )
    {
        EndJtts();

        lua_pushnil(L);
        lua_pushfstring(L,"jTTS_PlayToFile succed but get file length failed %d ",err);
        lua_pushnumber(L,0);
        return 3;
    }

    char *out_buffer = NULL;
    out_buffer = (char*)malloc(out_length);
    chmod(output_file,777);
    int fd = open(output_file,O_RDONLY);
    if(fd < 0 )
    {
        free(out_buffer);
        EndJtts();
        lua_pushnil(L);
        lua_pushfstring(L,"jTTS_PlayToFile succed but open file failed %d ",errno);
        lua_pushnumber(L,0);
        return 3;
    }

    char *tmp_buffer = out_buffer;
    int tmp_length = out_length;
    int ret = 0 ;
    while(tmp_length > 0 )
    {
        ret = read(fd ,tmp_buffer ,tmp_length);
        if(ret > 0 )
        {
            tmp_length -= ret;
            tmp_buffer += ret;
        }
        else if(ret == 0 )
        {
            break;
        }
        else
        {
            free(out_buffer);
            close(fd);
            lua_pushnil(L);
            lua_pushfstring(L,"jTTS_PlayToFile succed but read file failed %d ",errno);
            lua_pushnumber(L,0);
            return 3;
        }
    }
   

    close(fd);
    unlink(output_file);

    lua_pushnumber(L,1);
    lua_pushlstring(L,out_buffer,out_length);
    lua_pushnumber(L,out_length);

    free(out_buffer);

    /* 结束语音合成，释放资源 */
    EndJtts();

    return 3;
}
static const luaL_Reg text_2_voice_lib[] = {
   {"text2voice", text_2_voice_C},
   {NULL,NULL}
};
 
/*  库打开时的执行函数（相当于这个库的 main 函数），执行完这个函数后， lua 中就可以加载这个 so 库了   */
int luaopen_jTTS(lua_State *L)
{
   /* 把那个结构体数组注册到mt（名字可自己取)库中去 */
   luaL_register(L, "libJTTS", text_2_voice_lib);
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
