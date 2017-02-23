/*
wav音频：WAV格式头文件信息

一、综述
WAVE文件作为多媒体中使用的声波文件格式之一，它是以RIFF格式为标准的。
RIFF是英文Resource Interchange File Format的缩写，每个WAVE文件的头四个
字节便是“RIFF”。
WAVE文件是由若干个Chunk组成的。按照在文件中的出现位置包括：
RIFF WAVE Chunk, Format Chunk, Fact Chunk(可选), Data Chunk。具体见下图：

------------------------------------------------
| RIFF WAVE Chunk |
| ID = 'RIFF' |
| RiffType = 'WAVE' |
------------------------------------------------
| Format Chunk |
| ID = 'fmt ' |
------------------------------------------------
| Fact Chunk(optional) |
| ID = 'fact' |
------------------------------------------------
| Data Chunk |
| ID = 'data' |
------------------------------------------------
图1 Wav格式包含Chunk示例


其中除了Fact Chunk外，其他三个Chunk是必须的。每个Chunk有各自的ID，位
于Chunk最开始位置，作为标示，而且均为4个字节。并且紧跟在ID后面的是Chunk大
小（去除ID和Size所占的字节数后剩下的其他字节数目），4个字节表示，低字节
表示数值低位，高字节表示数值高位。下面具体介绍各个Chunk内容。
PS：
所有数值表示均为低字节表示低位，高字节表示高位。


二、具体介绍
RIFF WAVE Chunk
==================================
|      |所占字节数| 具体内容 |
==================================
|  ID  |  4 Bytes | 'RIFF'   |
----------------------------------
| Size |  4 Bytes |          |
----------------------------------
| Type |  4 Bytes | 'WAVE'   |
----------------------------------
图2 RIFF WAVE Chunk 12 Bytes


以'FIFF'作为标示，然后紧跟着为size字段，该size是整个wav文件大小减去ID
和Size所占用的字节数，即FileLen - 8 = Size。然后是Type字段，为'WAVE'，表
示是wav文件。
结构定义如下：

struct RIFF_HEADER
{
	char szRiffID[4]; // 'R','I','F','F'
	DWORD dwRiffSize;
	char szRiffFormat[4]; // 'W','A','V','E'
};


Format Chunk
====================================================================
|               | 字节数  | 具体内容 |
====================================================================
|       ID      | 4 Bytes | 'fmt '   |
--------------------------------------------------------------------
|       Size    | 4 Bytes | 数值为16或18，18则最后又附加信息 |
-------------------------------------------------------------------- 
|    FormatTag  | 2 Bytes | 编码方式，一般为0x0001 | 
-------------------------------------------------------------------- 
|    Channels   | 2 Bytes | 声道数目，1--单声道；2--双声道 | 
-------------------------------------------------------------------- 
| SamplesPerSec | 4 Bytes | 采样频率 | 
-------------------------------------------------------------------- 
| AvgBytesPerSec| 4 Bytes | 每秒所需字节数 |===> WAVE_FORMAT
-------------------------------------------------------------------- 
|   BlockAlign  | 2 Bytes | 数据块对齐单位(每个采样需要的字节数) | 
-------------------------------------------------------------------- 
| BitsPerSample | 2 Bytes | 每个采样需要的bit数 | 
-------------------------------------------------------------------- 
|               | 2 Bytes | 附加信息（可选，通过Size来判断有无） | 
-------------------------------------------------------------------- 
图3 Format Chunk  24/26 Bytes


以'fmt '作为标示。一般情况下Size为16，此时最后附加信息没有；如果为18
则最后多了2个字节的附加信息。主要由一些软件制成的wav格式中含有该2个字节的
附加信息。

结构定义如下：
struct WAVE_FORMAT
{
	WORD wFormatTag;
	WORD wChannels;
	DWORD dwSamplesPerSec;
	DWORD dwAvgBytesPerSec;
	WORD wBlockAlign;
	WORD wBitsPerSample;
};
struct FMT_BLOCK
{
	char szFmtID[4]; // 'f','m','t',' '
	DWORD dwFmtSize;
	WAVE_FORMAT wavFormat;
};


Fact Chunk
==================================
|      |所占字节数| 具体内容 |
==================================
|  ID  |  4 Bytes |  'fact'  |
----------------------------------
| Size |  4 Bytes | 数值为4  |
----------------------------------
| data |  4 Bytes |          |
----------------------------------
图4 Fact Chunk 12 Bytes

Fact Chunk是可选字段，一般当wav文件由某些软件转化而成，则包含该Chunk。
结构定义如下：
struct FACT_BLOCK
{
	char szFactID[4]; // 'f','a','c','t'
	DWORD dwFactSize;
};


Data Chunk
==================================
|      |所占字节数| 具体内容 |
==================================
|   ID |  4 Bytes |  'data'  |
----------------------------------
| Size |  4 Bytes |          |
----------------------------------
| data |          |          |
----------------------------------
图5 Data Chunk 8 Bytes


Data Chunk是真正保存wav数据的地方，以'data'作为该Chunk的标示。然后是
数据的大小。紧接着就是wav数据。根据Format Chunk中的声道数以及采样bit数，
wav数据的bit位置可以分成以下几种形式：
---------------------------------------------------------------------
| 单声道   | 取样1 | 取样2 | 取样3 | 取样4 |
|          |--------------------------------------------------------
| 8bit量化 | 声道0 | 声道0 | 声道0 | 声道0 |
---------------------------------------------------------------------
| 双声道   |     取样1 |   取样2   |   取样3   |   取样4   |
|          |--------------------------------------------------------
| 8bit量化 | 声道0(左) | 声道1(右) | 声道0(左) | 声道1(右) |
---------------------------------------------------------------------

|                             取样1   | 取样2 |
|  单声道   |--------------------------------------------------------
| 16bit量化 | 声道0      | 声道0      | 声道0      | 声道0      |
|           | (低位字节) | (高位字节) | (低位字节) | (高位字节) |
---------------------------------------------------------------------
|                             取样1   | 取样2 |
|  双声道   |--------------------------------------------------------
| 16bit量化 | 声道0(左)  | 声道0(左)  | 声道1(右)  | 声道1(右)  |
|           | (低位字节) | (高位字节) | (低位字节) | (高位字节) |
---------------------------------------------------------------------
图6 wav数据bit位置安排方式


Data Chunk头结构定义如下：
struct DATA_BLOCK
{
	char szDataID[4]; // 'd','a','t','a'
	DWORD dwDataSize;
};

三、读取wave文件
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main()
{
	char* wavname="123.wav"; 
	FILE *wavfp;
	wavfp=fopen(wavname,"rb");
	long int length,f=0,t=0;
	unsigned char buf;
	int bits,byts,channel,fps;
	double *data_lef,*data_rig; //left and right channel data
	long filelen,fileheadlen,datalen;
	if(wavfp==NULL)
	{
		printf("WAV文件未正确读入\n");
		exit(0);
	}
	int i=0,w=0;

	printf("标志位：\t");  //RIFF
	while(i<4) {{fread(&buf,1,1,wavfp); printf("%c",buf);}i++;}

	printf("\n");printf("文件长度：\t");
	{fread(&length,4,1,wavfp);printf("%d",length);i=i+4;}

	printf("\n");printf("标志位：\t"); //WAVE
	while(i<12) {{fread(&buf,1,1,wavfp);printf("%c",buf);} i++;}

	printf("\n");printf("标志位：\t"); //fmt
	while(i<16) {{fread(&buf,1,1,wavfp);printf("%c",buf);} i++;}

	printf("\n");printf("过渡字节：\t");
	{fread(&length,4,1,wavfp);printf("%d",length);f=length;i=i+4;}
	printf("\n");printf("格式类别：\t");
	{fread(&length,2,1,wavfp);printf("%d",length);i=i+2;}
	printf("\n");printf("通道数：\t");
	{fread(&length,2,1,wavfp);printf("%d",length); channel=length;if(length==1) printf("(单通道)"); if(length==2) printf("(双通道)"); i=i+2;}
	printf("\n");printf("采样率：\t");
	{fread(&length,4,1,wavfp);fps=length;printf("%d(每秒样本数)",length);i=i+4;}
	printf("\n");printf("音频传送速率：\t");
	{fread(&length,4,1,wavfp);printf("%d",length);i=i+4;}
	printf("\n");

	length=0;
	printf("数据块调整数：\t");
	{fread(&length,2,1,wavfp);printf("%d",length);i=i+2;}
	printf("\n");printf("样本数据位数：\t");
	{fread(&length,2,1,wavfp);bits=length;printf("%d",length);i=i+2;}
	printf("\n");

	if(f==18)
	{
		t=2;printf("附加信息：\t");{fread(&length,2,1,wavfp);printf("%d",length);i=i+2;}
		printf("\n");
	}

	f=0;
	fread(&buf,1,1,wavfp);
	if(buf=='f')                      //if "fact" Fact Chunk 可选
	{
		printf("fact标志：\t");
		printf("%c",buf);
		i++;
		while(i<40+t){{fread(&buf,1,1,wavfp);printf("%c",buf);}i++;}

		printf("\n");
		printf("fact size:\t");
		{
			fread(&length,4,1,wavfp);
			printf("%d",length);
			i=i+4;
		}
		printf("\n");
		printf("fact data:\t");
		while(i<48+t){{fread(&buf,1,1,wavfp);printf("%c",buf);}i++;}
		t+=12;
		fread(&buf,1,1,wavfp);
		printf("\n");
	}

	//printf("***  %d  ***\n\n")
	printf("数据标志符：\t"); //data
	printf("%c",buf);

	i++;
	while(i<40+t){{fread(&buf,1,1,wavfp); printf("%c",buf);}i++;}

	printf("\n");
	printf("语音长度：\t");
	{
		fread(&length,4,1,wavfp);
		printf("%d",length);
		datalen=length/2;
		i=i+4;
	}
	printf("\n");
	//printf("***  %d  ***\n\n",i);

	//get wave file data
	length=0.5*datalen/channel;
	data_lef=(double*)malloc(sizeof(double)*datalen/4);
	data_rig=(double*)malloc(sizeof(double)*datalen/4);
	byts=bits/8;	 
	for (i=0;i<length;i++)   
	{   
		fread(&data_lef[i], byts, 1, wavfp);
		fread(&data_rig[i], byts, 1, wavfp);
		if (f<abs(data_lef[i])) f=abs(data_lef[i]); //use f as max value of left channel
		if (t<abs(data_rig[i])) t=abs(data_rig[i]); //use t as max value of right channel
		//printf("%d\n",data_lef[i]);
	}
	//**文件长度和文件头长度 
	fseek(wavfp,0,SEEK_END);      //移动至文件结尾处
	filelen=ftell(wavfp);         //读取当前位置
	fseek(wavfp,0,SEEK_SET);      //返回文件开头处
	printf("文件总长度为：%d\n", filelen);
	fileheadlen = filelen - datalen;
	printf("文件头长度：%d\n", fileheadlen);
	fclose(wavfp);   
	wavfp = NULL;
	return 0;
}

