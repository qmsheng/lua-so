1) centos 6.5 test succed 
	must install imageMagic 
	yum install ImageMagick ImageMagick-devel.x86_64

lua_imageMagick库中两个公共函数

//获取图片的大小
//(
// char *filename 图片的名字和路径
//)
static int read_image_size(lua_State *L)

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

