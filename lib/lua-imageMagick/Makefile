
CC_FLAG = -shared -fPIC
ALL_INCS = -I /usr/local/include/luajit-2.0/ -I/usr/include/ImageMagick -I /usr/include/ -I -I./include -L./lib 
ALL_LIBS = -lluajit-5.1 -std=c99 -lMagickWand -lMagickCore
lua_imageMagick.so: 
	gcc $(CC_FLAG)   lua_imageMagick.c $(ALL_INCS) $(ALL_LIBS) -o  $@ 

clean: 
	rm  -rf *.so

