
all: cJSON.c test.c
	gcc -Wall -shared -fPIC cJSON.c -o libcjson.so -lm

test:test.c
	gcc cJSON.c test.c -o test -lm
testjson:testjson.c
	gcc cJSON.c testjson.c -o testjson -lm

help:
	echo "get from http://sourceforge.net/projects/cjson/"
	echo "Last Update: 2013-08-14"
