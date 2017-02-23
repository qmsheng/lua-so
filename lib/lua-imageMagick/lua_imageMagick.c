/*
 * 版权声明: 暂无
 * 文件名称: lua_imageMagick.c
 * 创建者  : qiumaosheng
 * 创建日期: 2015/10/17
 * 文件描述: 给图片添加水印效果
 * 历史记录: 新创建
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <magick/MagickCore.h>
#include <magick/methods.h>
#include <magick/magick-type.h>
#include <magick/exception.h>
#include <magick/image.h>


/*  三个有关 lua 的头文件   */


#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

//获取图片的大小
//(
// char *filename 图片的名字和路径
//)
static int read_image_size(lua_State *L)
{
    ExceptionInfo *exception;
    Image *images;
    ImageInfo *image_info;

    const char *filename =  (char *)luaL_checkstring(L, 1);
    if ( filename == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"filename is NULL");
        return 2;
    }
    exception=AcquireExceptionInfo();
    image_info=CloneImageInfo((ImageInfo *) NULL);
    (void) strcpy(image_info->filename,filename);
    images=ReadImage(image_info,exception);
    if (exception->severity != UndefinedException)
        CatchException(exception);
    if (images == (Image *) NULL) {
        lua_pushnil(L);
        lua_pushstring(L,"read image error");
        return 2;
    }
    lua_pushboolean(L,1);
    size_t width = images->page.width;
    size_t height = images->page.height;
    lua_pushnumber(L,width);
    lua_pushnumber(L,height);
    images = DestroyImage(images);
    image_info = DestroyImageInfo(image_info);
    exception = DestroyExceptionInfo(exception);
    return 3;
}

//读取图片文件
Image *ReadImageInfo(ImageInfo *image_info, char *filename, ExceptionInfo *exception)
{
    Image *images;
    (void) strcpy(image_info->filename,filename);
    images=ReadImage(image_info,exception);
    if (exception->severity != UndefinedException)
        CatchException(exception);
    if (images == (Image *) NULL)
        return NULL;
    return images;
}

//增加水印效果
// (
// char *src, 要添加水印的图像
// char *logo, 往图片上添加的logo
// char *result, 添加后生成的图片
// char *text, 网图片上添加的文字
// int logo_x, logo的位置坐标
// int logo_y, logo的位置坐标
// int text_x, 文字的位置坐标 值为-1则计算默认值
// int text_y, 文字的位置坐标 值为-1则计算默认值
// char *font, 文字的字体
// double fontSize, 文字的大小
// char *fontColor  文字的颜色--暂未添加该功能
// )

static int picture_watermark(lua_State *L) 
{ 
    ExceptionInfo *exception;
    Image *src_image, *logo_image;
    ImageInfo *image_info;
    DrawInfo *draw_info;

    char *src = (char *)luaL_checkstring(L, 1);
    if ( src == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"src is NULL");
        return 2;
    }
    char *logo = (char *)luaL_checkstring(L, 2);
    if ( logo == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"logo is NULL");
        return 2;
    }

    char *result = (char *)luaL_checkstring(L, 3);
    if ( result == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"result image is NULL");
        return 2;
    }

    char *text =  (char *)luaL_checkstring(L, 4);
    if ( text == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"text is NULL");
        return 2;
    }

    int logo_x = luaL_checkint(L, 5);
    int logo_y = luaL_checkint(L, 6);
    int text_x = luaL_checkint(L, 7);
    int text_y = luaL_checkint(L, 8);

    char *font = (char *)luaL_checkstring(L, 9 );
    if ( font == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"font is NULL");
        return 2;
    }
    double fontSize = luaL_checkint(L, 10);   
       // char *fontColor = ;

    draw_info = AcquireDrawInfo();
    exception=AcquireExceptionInfo();
    image_info=CloneImageInfo((ImageInfo *) NULL);

    src_image = ReadImageInfo(image_info, src, exception);
    if ( src_image == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"read src image error");
        return 2;
    }

    logo_image = ReadImageInfo(image_info, logo, exception);
    if ( logo_image == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L,"read logo image error");
        return 2;
    }

    if(text_x == -1 && text_y == -1 )
    {
        text_x = logo_x + logo_image->page.width+5;
        text_y = logo_y + logo_image->page.height/2;
    }

    MagickBooleanType status = CompositeImage(src_image,SrcOverCompositeOp,logo_image,logo_x,logo_y);
    if ( status == MagickFalse)
    {
        lua_pushnil(L);
        lua_pushstring(L,"CompositeImage error");
        return 2;
    }

    draw_info->encoding="utf-8";
    draw_info->pointsize=fontSize;
    draw_info->text=text;
    draw_info->font=font;
  
    draw_info->stroke.opacity=0.1F;
    
    char offset[50] = {0};
    sprintf(offset,"100x100+%d+%d",text_x,text_y);

    draw_info->geometry=offset;

    status = AnnotateImage(src_image,draw_info);
    if ( status == MagickFalse)
    {
        lua_pushnil(L);
        lua_pushstring(L,"AnnotateImage error");
        return 2;
    }

    (void) strcpy(src_image->filename,result);
    status = WriteImage(image_info,src_image);
    if ( status == MagickFalse)
    {
        lua_pushnil(L);
        lua_pushstring(L,"WriteImage error");
        return 2;
    }

    draw_info->pointsize=0;
    draw_info->text=NULL;
    draw_info->font=NULL;
    draw_info->geometry = NULL;
    draw_info->encoding = NULL;

    draw_info = DestroyDrawInfo(draw_info);
    src_image = DestroyImage(src_image);
    logo_image = DestroyImage(logo_image);
    image_info = DestroyImageInfo(image_info);
    exception = DestroyExceptionInfo(exception);

    lua_pushboolean(L,1);
    return 1;
}

static const luaL_Reg lib[] = {
   {"pictureWaterMark", picture_watermark},
   {"readImageSize", read_image_size},
   {NULL,NULL}
};
 
/*  库打开时的执行函数（相当于这个库的 main 函数），执行完这个函数后， lua 中就可以加载这个 so 库了   */
int luaopen_lua_imageMagick(lua_State *L)
{
   /* 把那个结构体数组注册到mt（名字可自己取)库中去 */
   luaL_register(L, "lib_lua_imageMagick", lib);
   return 1;
} 

