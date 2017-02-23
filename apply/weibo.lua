local utils    = require('utils')
local app_utils = require('app_utils')
local cutils   = require('cutils')
local cjson    = require('cjson')
local http_api = require('cutils').http
local redis_api = require('redis_pool_api')
local only      = require("only")

-- local main_cache = require('main_cache')

module('weibo', package.seeall)

local weibo_api_list = {
	["online"]      = "weiboapi/v2/sendMultimediaOnlineWeibo",
	["personal"]    = "weiboapi/v2/sendMultimediaPersonalWeibo",
	["group"]       = "weiboapi/v2/sendMultimediaGroupWeibo",
	["onlineGroup"] = "weiboapi/v2/sendMultimediaOnlineGroupWeibo",		----区域在线集团微博
	["city"]        = "weiboapi/v2/sendMultimediaOnlineCityWeibo",

	["groupv2"]    ="weiboapi/v2/sendGroupWeibo",
	["personalv2"] = "weiboapi/v2/sendPersonalWeibo",
	["cityv2"]     = "weiboapi/v2/sendCityWeibo",
}

function send_weibo( server, wb_type, wb_args, appkey, secret )

	local path = weibo_api_list[ wb_type ] 
	if not path then
		return false, string.format("No this weibo api : {%s}", wb_type)
	end
	
	if not wb_args["appKey"] or not wb_args['sign'] then
		wb_args["appKey"] = appkey
		wb_args['sign']   = app_utils.gen_sign(wb_args, secret)
	end

	local data = utils.compose_http_form_request(server, path, nil, wb_args, nil, nil)

	local ok, ret = http_api(server['host'], server['port'], data, #data)
	if ok and ret then
		local body = string.match(ret, '{.*}')
		if body then
			local ok, jo = pcall(cjson.decode, body)
			if ok then
				if jo["ERRORCODE"] == "0" then
					return true,jo["RESULT"]
				end
				only.log('E',string.format("http request data :\n%s" , data))
				only.log('E', ret)
				return false,jo["RESULT"]
			end
		end
	end

	only.log('E',string.format("http request data :\n%s" , data))
	only.log('E', ret)

	return false,"SYSTEM_ERROR"
end



-->[多媒体个人微博]<--
--[[----------------->
* multimediaURL,multimediaFile:	`前者为多媒体文件的URL地址,后者为多媒体文件流,此二者必选其一`
* receiverAccountID:		`接收者的IMEI或accountID`
* interval:			`微博有效时间长度,单位为秒`
* level:			`微博的优先级    0-99.0:优先级最高，99:优先级最低`
* content:			`微博的文本内容`
* senderType:			`添加发送类型区分微博来源 1:WEME    2:system    3:other`
--]]----------------->

-->[多媒体集团微博]<--
--[[----------------->
* multimediaURL,multimediaFile:	`前者为多媒体文件的URL地址,后者为多媒体文件流,此二者必选其一`
* groupID:			`发送的集团编号`
* interval:			`微博有效时间长度,单位为秒`
* level:			`微博的优先级    0-99.0:优先级最高，99:优先级最低`
* content:			`微博的文本内容`
* senderType:			`添加发送类型区分微博来源 1:WEME    2:system    3:other`
--]]----------------->

-->[多媒体城市微博]<--
--[[----------------->
* multimediaURL,multimediaFile:	`前者为多媒体文件的URL地址,后者为多媒体文件流,此二者必选其一`
* regionCode:			`城市编号`
* interval:			`微博有效时间长度,单位为秒`
* level:			`微博的优先级    0-99.0:优先级最高，99:优先级最低`
* content:			`微博的文本内容`
* senderType:			`添加发送类型区分微博来源 1:WEME    2:system    3:other`
--]]----------------->

-->[多媒体在线用户微博]<--
--[[----------------->
* multimediaURL,multimediaFile:	`前者为多媒体文件的URL地址,后者为多媒体文件流,此二者必选其一`
* interval:			`微博有效时间长度,单位为秒`
* level:			`微博的优先级    0-99.0:优先级最高，99:优先级最低`
* content:			`微博的文本内容`
* senderType:			`添加发送类型区分微博来源 1:WEME    2:system    3:other`
--]]----------------->



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------jiang z.s. ---------------------------------

---- 目前所有的合同协议用户,都绑定IMEI,所以针对IMEI长度的accountID,不许要判断,直接返回true

----大类序号	大类名称
SYS_WB_ALL_MSG      = 1 	----1	 	总开关
SYS_WB_AROUND_VOICE = 2 	----2	 	获取周围吐槽
SYS_WB_AD           = 3 	----3	 	广告
SYS_WB_DRIVIEW      = 4 	----4	 	Driview
SYS_WB_CRAZY        = 5 	----5	 	正点时钟
SYS_WB_CHANNEL      = 6   ----6 		频道,DJ 


--1~32   	32位系统使用
--33~xxx  N位,给所有业务使用


------  用户订阅消息系统类型
USER_SUBSCRIBED_INFO = { clearTime = 0 }

----- 用户订阅消息重新加载最大超时时间
USER_RELOAD_TIME = 300

USER_SUBSCRIBED_DEFAULT = "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"


function get_data__with_redis( accountid )
	local ok_status,ok_val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
	local cur_inited = false
	if not ok_val or (ok_val and #tostring(ok_val) ~= 512 ) then
		cur_inited = false
		cur_val = USER_SUBSCRIBED_DEFAULT
	else
		cur_inited = true
		cur_val = ok_val
	end
	return cur_inited,cur_val
end


-- function get_data_with_nginx_share_dict( accountid )
-- 	local cache_init = string.format("%s:isInit",accountid)
-- 	local cache_key = string.format("%s:userMsgSubscribed",accountid)
-- 	local key_init = main_cache.get( cache_init )
-- 	local key_val  = main_cache.get( cache_key )
-- 	if key_init == "1" and key_val and #key_val == 512 then
-- 		only.log('D',string.format("get info from ngx.share %s is init ", accountid ) )
-- 		return key_init, key_val
-- 	elseif key_init == "0" then
-- 		only.log('D',string.format("get info from ngx.share %s not init ", accountid ) )
-- 		return key_init, key_val
-- 	end
-- 	local cur_inited = "0"
-- 	local cur_val = USER_SUBSCRIBED_DEFAULT
-- 	local key_init,key_val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
-- 	if key_init and key_val and #tostring(key_val) == 512 then
-- 		only.log('D',string.format("get info from redis %s", accountid ) )
-- 		cur_inited = "1"
-- 		cur_val = key_val
-- 		main_cache.set( cache_init , cur_inited ,30 )
-- 		main_cache.set( cache_key , cur_val ,30 )
-- 	else
-- 		main_cache.set( cache_init , cur_inited ,30 )
-- 	end
-- 	return cur_inited,cur_val
-- end

function get_data_with_lua_cache( accountid )

	if ngx.time() - USER_SUBSCRIBED_INFO.clearTime > USER_RELOAD_TIME * 10 then
		---- 清理lua模块内部数据
		for key, val in pairs(USER_SUBSCRIBED_INFO) do
			if type(val) == "table" and ngx.time() - val['time'] > USER_RELOAD_TIME * 10  then
				only.log('W',string.format(" accountid:%s Clear lua cache ", key )) 
				USER_SUBSCRIBED_INFO[key] = nil
			end
		end
		USER_SUBSCRIBED_INFO.clearTime = ngx.time()
	end

	local cur_info = USER_SUBSCRIBED_INFO[tostring(accountid)]
	if not cur_info or ( cur_info and  ngx.time() -  (tonumber(cur_info.time) or 0) > USER_RELOAD_TIME ) then
		local cur_val = nil
		local cur_inited = nil
		local ok_status,ok_val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
		if not ok_val or (ok_val and #tostring(ok_val) ~= 512 ) then
			cur_inited = false
			cur_val = USER_SUBSCRIBED_DEFAULT
		else
			cur_inited = true
			cur_val = ok_val
		end

		USER_SUBSCRIBED_INFO[tostring(accountid)] = {  time = ngx.time(),  init = cur_inited , value = cur_val }
		return cur_inited, cur_val
	else
		return cur_info.init , cur_info.value
	end
end


----------------2014-11-18 --------------
----   使用cache的方式  
----		使用cache的方式
----		0 直接读取redis
----		1 使用nginx.share.DICT  (LRU)
----		2 使用lua模块
app_cache_type  = 2

-- 返回参数
-- 1) true表示初始化过
-- 2) false表示未初始化过
function get_msg_subscribed( accountid )
	if #accountid ~= 10 then
		return false , USER_SUBSCRIBED_DEFAULT
	end
	
	if not app_cache_type or app_cache_type == 0 then
		return get_data__with_redis(accountid)
	-- elseif app_cache_type == 1 then
	-- 	return get_data_with_nginx_share_dict(accountid)
	else
		return get_data_with_lua_cache(accountid)
	end
end

---- check_system_subscribed_msg
---- return 
---- true  	可以发送微博
---- false	屏蔽微博
---- WEME 判断用户是否开启以下功能
function check_system_subscribed_msg( accountid , weibo_type )
	if not weibo_type then return true end
	if not accountid or #accountid ~= 10 then return true end
	-- local ok_status,ok_val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
	-- if not ok_status or not ok_val or #ok_val < weibo_type then return  true end

	---- 2014-10-30  增加nginx缓存,避免读取redis过快
	local ok_status , ok_val = get_msg_subscribed(accountid)
	if not ok_status then return true end   ---- 未初始化过

	if weibo_type == WB_TYPE_ALL_MSG and tostring(string.sub(ok_val,1,1)) == "1" then
		return true
	elseif weibo_type ~= WB_TYPE_ALL_MSG then
		if tostring(string.sub(ok_val,1,1)) == "1"  and tostring(string.sub(ok_val,tonumber(weibo_type),tonumber(weibo_type))) == "1"  then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------------------------------------------------
------------- 以下内容,请严格按照当前方式,定义常量   注意添加备注,日期等 ---------------------------------------------
-------------  同时需要更新表`app_weibo`.`subscribedTypeInfo`, 注意subscribedType -------------------------
------------------------------[CrazyAPI index:(34  ~  96) ]-----------------------------------------------------------

-- 34		分享驾驶信息
-- 35		汤姆猫自动回复
-- 36		最近道客
-- 37		当前驾驶方向与状态
-- 38		PM2.5
-- 39		新闻
-- 40		在线用户提醒
-- 41		夜驾提醒	

CRAZY_APP_SHARE_DRI_INFO       = 34 	----------志玲报时速
CRAZY_APP_AUTO_REPLY_BY_TOMCAT = 35 
CRAZY_APP_VICINITY_DK          = 36 
CRAZY_APP_CURRENT_DRI_INFO     = 37
CRAZY_APP_PM_2_5               = 38 
CRAZY_APP_NEWS                 = 39 
CRAZY_APP_REPORT_ONLINEUSER    = 40 
CRAZY_APP_DRI_AT_NINGHT        = 41

CRAZY_APP_FIRST_SPEED          =  47       -------- 路况优先 , 用户未设置,则默认为关闭状态  2014-10-30



------------- 以上内容,请严格按照当前方式,定义常量   注意添加备注,日期等 ---------------------------------------------
--------------------------------------------------------------------------------------------------------------------------


---- [正点时钟]判断用户是否开启以下功能
function check_crazy_subscribed_msg( accountid,  app_type  )
	if not app_type then return true end

	 -- local ok_status, ok_val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
	 -- if not ok_status or not ok_val or #ok_val < app_type then return  true end

	---- 2014-10-30  增加nginx缓存,避免读取redis过快
	local ok_status , ok_val = get_msg_subscribed(accountid)
	if not ok_status then return true end   ---- 未初始化过
	if app_type < 32 then 
		error( string.format("[weibo]weibo_type is error:%s ", app_type ) )
		return false 
	end

	if tostring(string.sub(ok_val,1,1)) == "1" 							---- 系统总开关
		and tostring(string.sub(ok_val,5,5)) == "1" 						---- [系统]正点时钟
		and tostring(string.sub(ok_val,33,33)) == "1" 					---- [用户订阅]总开关
		and tostring(string.sub(ok_val,tonumber(app_type),tonumber(app_type))) == "1"  then
		return true
	end
	return false
end


---- accountID  
---- app_type 
---- default_close  
-------- true   默认关闭
-------- false  默认打开
function check_subscribed_msg_default ( accountid,  app_type , default_close )
	if not app_type then return true end

	---- 2014-10-30  增加nginx缓存,避免读取redis过快
	local ok_status , ok_val = get_msg_subscribed(accountid)

	---- 用户未设置过,则默认为关闭状态
	if default_close and not ok_status then
		---- 未初始化为false, 关闭状态也为false
		return false
	end

	if not ok_status then return true end   ---- 未初始化过

	if app_type < 32 then 
		error( string.format("[weibo]weibo_type is error:%s ", app_type ) )
		return false 
	end

	if tostring(string.sub(ok_val,1,1)) == "1" 							---- 系统总开关
		and tostring(string.sub(ok_val,33,33)) == "1" 					---- [用户订阅]总开关
		and tostring(string.sub(ok_val,tonumber(app_type),tonumber(app_type))) == "1"  then
		return true
	end
	return false
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

---- [city weibo]判断用户是否开启以下功能, judge the tj(appKey: 3656465532 ) flag in 161
function check_weibo_tj_msg( accountid, app_key)

	if app_key ~= '3656465532' then
		return true
	end

	-- local status, val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
	-- if not status or not val then return true end

	---- 2014-10-30  增加nginx缓存,避免读取redis过快
	local ok_status , ok_val = get_msg_subscribed(accountid)
	if not ok_status then return true end   ---- 未初始化过


	if tostring(string.sub(ok_val, 1, 1)) == "1" 							---- 系统总开关
		and tostring(string.sub(ok_val, 2, 2)) == "1" then 					---- [用户订阅]总开关
		return true
	end
	return false
end




local appkey_tab = {
	appkey1209071138 = 163,	---- 语镜道客customizationapp--三句话日志
}

local function  get_apptype_by_appkey(app_key)
	return appkey_tab["appkey" .. tostring(app_key) ]
end

function check_thirdapp_subscribed_msg( accountid, app_key )
	-- local ok_status,ok_val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
	-- if not ok_status or not ok_val or #ok_val < app_type then return  true end

	---- 2014-10-30  增加nginx缓存,避免读取redis过快
	local ok_status , ok_val = get_msg_subscribed(accountid)
	if not ok_status then return true end   ---- 未初始化过

	local app_type = get_apptype_by_appkey(app_key)
	if not app_type then return true end

	if app_type < 32 then 
		error( string.format("[weibo]weibo_type is error:%s ", app_type ) )
		return false 
	end
	if tostring(string.sub(ok_val,1,1)) == "1" 							---- 系统总开关
		and tostring(string.sub(ok_val,33,33)) == "1" 					---- User总开关
		and tostring(string.sub(ok_val,tonumber(app_type),tonumber(app_type))) == "1"  then
		return true
	end
	return false
end

-- 没有分大类的情况下,则直接判断1,33,x
function check_detail_subscribed_msg( accountid , app_type )

	if not app_type then return true end

	-- local ok_status,ok_val = redis_api.cmd('private','get', accountid .. ':userMsgSubscribed')
	-- if not ok_status or not ok_val or #ok_val < app_type then return  true end

	---- 2014-10-30  增加nginx缓存,避免读取redis过快
	local ok_status , ok_val = get_msg_subscribed(accountid)
	if not ok_status then return true end   ---- 未初始化过

	if app_type < 32 then 
		error( string.format("[weibo]weibo_type is error:%s ", app_type ) )
		return false 
	end
	if tostring(string.sub(ok_val,1,1)) == "1" 						---- 系统总开关
		and tostring(string.sub(ok_val,33,33)) == "1" 				---- User总开关
		and tostring(string.sub(ok_val,tonumber(app_type),tonumber(app_type))) == "1"  then
		return true
	end
	return false
end

---- 165  用户微博消息提醒成长值
function check_share_subscribed_msg(accountid)
        return check_detail_subscribed_msg(accountid,165)
end
