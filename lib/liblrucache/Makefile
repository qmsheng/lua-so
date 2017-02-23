# 
# date: 2014/12/10
#

CPLUSFLAGS=-std=c++0x
CFLAGS=-I./ -I/usr/local/include/luajit-2.0/ -I/usr/include/ -fPIC -fno-builtin-memcmp -O

ALL_LIBS = -lluajit-5.1

TARGET=liblrucache.a
TARGET_TEST=cache_test

OBJ_DIR=./obj
SRC_DIR=./src
OBJ=$(addprefix $(OBJ_DIR)/, \
    cache.o \
    coding.o \
    hash.o \
    port_posix.o \
    ldb_cache.o \
    )

all: $(OBJ)
	ar -rs $(TARGET) $^
	#gcc -shared $(CFLAGS) -L./ $(SRC_DIR)/cache_test.c $(ALL_LIBS) -pthread -llrucache -o lrucache.so
	gcc -fPIC -I/usr/local/include/luajit-2.0/ -I./src -c src/lrucache.c -o obj/lrucache.o
	gcc -shared -fPIC -lluajit-5.1 -pthread -lstdc++ -o lrucache.so obj/lrucache.o liblrucache.a


$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cc
	@-if [ ! -d $(OBJ_DIR) ];then mkdir $(OBJ_DIR); fi
	g++ $(CFLAGS) $(CPLUSFLAGS) -c $< -o $@

test:
	gcc -L./ $(SRC_DIR)/cache_test.c -pthread -lstdc++ -llrucache -g2 -o $(TARGET_TEST)

clean:
	rm -rf $(TARGET) $(TARGET_TEST) $(OBJ_DIR) *.a nohup.out *.so

mc:
	@rm -f nohup.out
	nohup valgrind --tool=memcheck  --leak-check=full --verbose ./$(TARGET_TEST)&

lrucache.so:
	gcc -shared $(CFLAGS) -L./ $(SRC_DIR)/cache_test.c -pthread -lstdc++ -llrucache -o $@
	
.PHONY: all test clean mc
