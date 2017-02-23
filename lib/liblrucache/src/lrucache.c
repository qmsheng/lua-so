#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <pthread.h>

#include "ldb_cache.h"


static int cache_init(lua_State *L) 
{
	size_t cache_size = luaL_checkint(L, 1);
	size_t max_value_len = -1;
	int par_count = lua_gettop(L);
	if(par_count < 1)
	{
		lua_pushnil(L);
		lua_pushstring(L, "parameter must input cache_size");
		return 2;
	}
	if(2 == par_count )
	{
		max_value_len = luaL_checkint(L, 2);
	}
	leveldb_cache_t *lcache = leveldb_cache_create_lru(cache_size, max_value_len);
	if(!lcache)
	{
		lua_pushnil(L);
		lua_pushstring(L, "leveldb_cache_create_lru failed");
		return 2;
	}

	lua_pushinteger(L, (size_t)lcache);
	lua_pushstring(L, "");
	return 2;
}


/*
---- 1 cache address ( size_t )
---- 2 cache key (string)
---- 3 cache value
*/

static int cache_setvalue(lua_State *L)
{
	int par_count = lua_gettop(L);
	if(par_count != 4)
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_setvalue]parameter must input cache_address, key, value");
		return 2;
	}

	size_t cache_address = luaL_checkint(L, 1);

	leveldb_cache_t *lcache =  (leveldb_cache_t*)cache_address;
	if(!lcache)
	{
		lua_pushnil(L);
		lua_pushstring(L, "cache_setvalue cache_address is error");
		return 2;
	}

	const char *key = luaL_checkstring(L, 2);
	const char *val = luaL_checkstring(L, 3);
	if(strlen(key) < 1 )
	{
		lua_pushnil(L);
		lua_pushstring(L, "cache_setvalue cache key length is error");
		return 2;
	}

	size_t val_length = luaL_checkint(L, 4);
	if(strlen(val) > val_length )
	{
		lua_pushnil(L);
		lua_pushstring(L, "cache_setvalue cache value length is error");
		return 2;
	}

	bool ret = leveldb_cache_insert(lcache, key, strlen(key), val, val_length );
	lua_pushinteger(L, (size_t)ret);
	lua_pushstring(L,"");
	return 2;
}



static int cache_getvalue(lua_State *L)
{
	int par_count = lua_gettop(L);
	if(par_count != 2 )
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getvalue]parameter must input cache_address, key");
		return 2;
	}

	size_t cache_address = luaL_checkint(L, 1);
	leveldb_cache_t *lcache =  (leveldb_cache_t*)cache_address;
	if(!lcache)
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getvalue]cache_setvalue cache_address is error");
		return 2;
	}

	const char *key = luaL_checkstring(L, 2);
	if(strlen(key) < 1 )
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getvalue]cache_setvalue cache key length is error");
		return 2;
	}

	void *handle = leveldb_cache_fix(lcache, key, strlen(key));
	if(!handle)
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getvalue]cache_setvalue leveldb_cache_fix failed");
		return 2;
	}
	// get value.
	size_t vlen = 0;
	char *val = (char *)leveldb_cache_value(lcache, handle, &vlen);

	lua_pushinteger(L,1);
	lua_pushlstring(L,val,vlen);
	
	// unfix entry.
	leveldb_cache_unfix(lcache, handle);

	return 2;
}


static int cache_removevalue(lua_State *L)
{

	int par_count = lua_gettop(L);
	if(par_count != 2 )
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_removevalue]parameter must input cache_address, key");
		return 2;
	}

	size_t cache_address = luaL_checkint(L, 1);
	leveldb_cache_t *lcache =  (leveldb_cache_t*)cache_address;
	if(!lcache)
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_removevalue]cache_setvalue cache_address is error");
		return 2;
	}

	const char *key = luaL_checkstring(L, 2);
	leveldb_cache_erase(lcache, key, strlen(key));

	lua_pushinteger(L,1);
	lua_pushstring(L, "");
	return 2;
}

static int cache_destory(lua_State *L)
{
	int par_count = lua_gettop(L);
	if(par_count != 1 )
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_destory]parameter must input cache_address");
		return 2;
	}

	size_t cache_address = luaL_checkint(L, 1);
	leveldb_cache_t *lcache =  (leveldb_cache_t*)cache_address;
	if(!lcache)
	{
		lua_pushnil(L);
		lua_pushstring(L, "[cache_destory]cache_destory cache_address is error");
		return 2;
	}

	leveldb_cache_destroy(lcache);

	lua_pushinteger(L,1);
	lua_pushstring(L, "");
	return 2;
}

static int cache_getsize(lua_State *L)
{
	int par_count = lua_gettop(L);
	if(par_count != 1 )
	{
		lua_pushnil(L);
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getsize] parameter must input cache_address");
		return 3;
	}

	size_t cache_address = luaL_checkint(L, 1);
	leveldb_cache_t *lcache =  (leveldb_cache_t*)cache_address;
	if(!lcache)
	{
		lua_pushnil(L);
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getsize]cache_address is error");
		return 3;
	}

	// get value.
	size_t value = (size_t)leveldb_get_size(lcache);

	lua_pushinteger(L,1);
	lua_pushinteger(L,value);
	lua_pushstring(L, "");
	return 3;
}


static int cache_getcapacity(lua_State *L)
{
	int par_count = lua_gettop(L);
	if(par_count != 1 )
	{
		lua_pushnil(L);
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getcapacity] parameter must input cache_address");
		return 3;
	}

	size_t cache_address = luaL_checkint(L, 1);
	leveldb_cache_t *lcache =  (leveldb_cache_t*)cache_address;
	if(!lcache)
	{
		lua_pushnil(L);
		lua_pushnil(L);
		lua_pushstring(L, "[cache_getcapacity]cache_address is error");
		return 3;
	}

	// get value.
	size_t value = (size_t)leveldb_get_capacity(lcache);

	lua_pushinteger(L,1);
	lua_pushinteger(L,value);
	lua_pushstring(L, "");
	return 3;
}

static const luaL_Reg lib[] = {
    {"init", cache_init},
    {"setValue", cache_setvalue},
    {"getValue", cache_getvalue},
    {"removeValue", cache_removevalue},
    {"removeAll", cache_destory},
    {"getSize", cache_getsize},
    {"getCapacity", cache_getcapacity},
    {NULL, NULL}
};


int luaopen_lrucache(lua_State *L) {
    luaL_register(L, "lrucache", lib);
    return 0;
}
