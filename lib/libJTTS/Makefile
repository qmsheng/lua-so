CC_FLAG = -shared -fPIC
ALL_INCS = -I /usr/local/include/luajit-2.0/ -I /usr/include/ -I./src/Common -I./include -L./lib 
ALL_LIBS = -lluajit-5.1 -luuid


jTTS.so: 
	gcc $(CC_FLAG) -g   ./src/jTTS.cpp ./src/Common/Common.cpp -ljTTS_ML -ljTTS_Audio -lACE  -lACEXML -llog4cpp -lc -ldl -lpthread   $(ALL_INCS) $(ALL_LIBS) -o  $@ 

	sudo cp ./lib/libACE.so /lib64/libACE.so
	sudo cp ./lib/libACEXML.so  /lib64/libACEXML.so
	sudo cp ./lib/libjTTS_Audio.so /lib64/libjTTS_Audio.so
	sudo cp ./lib/libjTTS_ML.so /lib64/libjTTS_ML.so
	sudo cp ./lib/liblog4cpp.so /lib64/liblog4cpp.so
	sudo ln -s /lib64/liblog4cpp.so /lib64/liblog4cpp.so.5
	sudo ln -s /lib64/libACE.so /lib64/libACE-5.6.6.so

clean: 
	rm ./*.so
