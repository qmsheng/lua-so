--jiang z.s.
--api通用库函数,主要是针对业务
--2014-07-22

local utils     = require('utils')
local cutils    = require('cutils')
local cjson     = require('cjson')
local only      = require ('only')
local http_api  = require('http_short_api')
local redis_api = require('redis_pool_api')

module("appfun", package.seeall)


default_channel = "10086"

---- daokeIO2.0 type操作类型
----业务类型说明
DK_TYPE_CALL1      = 1
DK_TYPE_CALL2      = 2
DK_TYPE_VOICE      = 3
DK_TYPE_COMMAND    = 4 
DK_TYPE_GROUP      = 5
DK_TYPE_YES        = 6
DK_TYPE_NO         = 7
DK_TYPE_POWEROFF   = 8
DK_TYPE_PASSBY     = 9
DK_TYPE_REPLYVOICE = 10
---- daokeIO2.0 type操作类型


---- 经纬度基本单位
GPS_POINT_UNIT     = 10000000
---- 经纬度基本单位


----------------------------------------------------------------------
-- 语音指令自定义类型 actionType = 4
-- 1: 语音记事本
-- 2: 频道
-- 3: 发送新浪微博
-- 4: 微信
-- 5: app连线
-- 6: 密频道  2014-12-11

VOICE_COMMAND_NOTEPAD       = 1
VOICE_COMMAND_CHANNEL       = 2
VOICE_COMMAND_SINAWEIBO     = 3 
VOICE_COMMAND_WECHAT        = 4 
VOICE_COMMAND_APP_CONNECT   = 5
VOICE_COMMAND_SECRETCHANNEL = 6
VOICE_COMMAND_MAXVAL        = 6 
----------------------------------------------------------------------

----------------------------------------------------------------------
--频道自定义类型  actionType = 5 
-- 1: 频道
-- 2: 密频道  2014-12-11
GROUP_VOICE_CHANNEL = 1
GROUP_VOICE_SECRETCHANNEL = 2 
GROUP_VOICE_MAXVAL = 2
----------------------------------------------------------------------


----------------------------------------------------------------------
-----------微频道/密频道
CHANNEL_TYPE_MICRO    = 1     ----微频道
CHANNEL_TYPE_SECRET   = 2     ----密频道

-----------账户--设备--昵称--频道--订阅
CHANNEL_TYPE_APP_SECRET			=1		--appKey与secret关系保存
CHANNEL_TYPE_BUSINESS_IMEI		=2 		--企业设备appkey:imei保存
CHANNEL_TYPE_ACCOUNT_IMEI		=3 		--账户与设备绑定关系redis
CHANNEL_TYPE_ACCOUNT_NICKNAME	=4 		--账户昵称关联及语音保存
CHANNEL_TYPE_ACCOUNT_FOLLOW		=5 		--保存用户所关注的频道
WEIBO_SUBSCRIBE_VALUE			=6		--存用户订阅消息redis


-----------频道当前开放状态 0 公开  /  1非公开
CHANNEL_STATUS_OPEN  = 0
CHANNEL_STATUS_CLOSE = 1 
----------------------------------------------------------------------

----------2015-05-08--begin
VOICE_COMMAND_TYPE_SECRETCHANNEL = 10 
VOICE_COMMAND_TYPE_MAXVAL = 10

GROUP_VOICE_TYPE_SECRETCHANNEL = 10 
GROUP_VOICE_TYPE_MAXVAL = 10


---- 中间吐槽按键,系统默认值 2015-05-30
---- 一键报路况 10
DEFAULT_VOICE_TYPE_TRAFFIC = 10

---- 语音记事本 11 
DEFAULT_VOICE_TYPE_NOTEPAD = 11

---- 家人连线 12 
DEFAULT_VOICE_TYPE_APPCON  = 12

---- 车队 13 	
---- 周围道客 14 	
DEFAULT_VOICE_TYPE_NEARBYDAOKE  = 14 		
----------2015-05-08--end


---- 获取用户当前经纬度
function get_currentbl( accountid )
	local ok,gps_str = redis_api.cmd('private','get',accountid .. ":currentBL")
	if not ok or not gps_str then
		return false,nil,nil
	end
	local gps_info = utils.str_split(gps_str,",")
	if not gps_info or #gps_info ~= 2 then return false,nil,nil end

	local longitude = gps_info[1]
	local latitude = gps_info[2]

	if tonumber(longitude) == 0 or tonumber(latitude) == 0 then
		return false,nil,nil
	end
	return true, longitude,latitude
end


---- input lat,lon
---- return 
---- 1 true
---- tab
---- tab['cityCode'],tab['cityName']
function get_cityinfo_by_point(longitude,latitude)
	if (tonumber(longitude) or 0 )  == 0 then return false,nil end
	if (tonumber(latitude) or 0 )   == 0 then return false,nil end
	local grid = string.format("%d&%d", tonumber(longitude * 100), tonumber(latitude * 100)  )
	local ok, result = redis_api.cmd('mapGridOnePercent', 'get', grid )
	if not ok then
		only.log('E',string.format("conncet redis mapGridOnePercent get cityCode by grid %s failed!",grid))
		return false,nil
	end

	if not result then
		only.log('D',string.format("mapGridOnePercent get cityCode by grid %s failed!--->---",grid))
		return false,nil
	end

	local ok_status,city_info = pcall(cjson.decode,result)
	if not ok_status then
		only.log('D','get_cityinfo_by_point cjson decode failed')
		return false,nil
	end
	return true,city_info
end

----get city info by accountid
----1: true,false
----2: tab      nil
----            tab['cityCode'] tab['cityName']
function get_cityinfo_by_accountid(accountid)
	----根据UserID获取Citycode
	local ok_status, longitude ,latitude = get_currentbl(accountid)
	if not ok_status then
		return false,nil
	end
	return get_cityinfo_by_point(longitude ,latitude)
end

function number_to_chinese(num)
	if not num then return '' end
	if type(tonumber(num)) ~= "number" then return '' end
	local num_list = {[0] = '零',[1] = '幺',[2] = '二',[3] = '三',[4] = '四',[5] = '五',[6] = '六',[7] = '七',[8] = '八',[9] = '九'}
	local str = ''
	for i = 1, #tostring(num) do
		str = str .. num_list[tonumber(string.sub(num,i,i))]
	end
	return str
end


---- body_type
---- key-value
---- json
function general_request_web_api( server,  location , body_tab ,  key_value , max_timeout , is_cutils_http )
	if not server or not location or not body_tab then
		return false,'paramer is error'
	end
	local req_body = nil
	local req_type = nil
	if key_value then
		---- key_value
		req_body = utils.table_to_kv(body_tab)
		req_type = "application/x-www-form-urlencoded"
	else
		---- json
		req_body = utils.json_encode(body_tab)
		req_type = "application/json; charset=utf-8"
	end

	local req_data = utils.post_data(location, server , req_body, req_type )

	local ok, ret_data = nil
	if not is_cutils_http then
		ret_data = http_api.http( server, req_data, true , max_timeout )
		if not ret_data then
			return false,'http_get_failed'
		end
	else
		ok, ret_data = cutils.http( server.host,server.port ,req_data,#req_data )
		if not ok then
			return false,'cutils_http_post_failed'
		end
		if not ret_data then
			return false,'cutils_http_recv_failed'
		end
	end

	local ret_tab =  utils.parse_api_result(ret_data)
	if ret_tab then
		return true , ret_tab
	end
	return false,nil
end


function get_road_name( server, body_tab )
	local ok, tab = general_request_web_api( server,  "mapapi/v3/pointMatchRoad" , body_tab ,  true , 1500 )    
	if ok and tab then
		local tmp_road_name = tab['RN']
		if tmp_road_name and not string.match(tostring(tmp_road_name),"(%w+)") then
			return true , tostring(tmp_road_name)
		end
	end
	return false,nil
end


function get_daokenum_by_imei(imei)
	if not imei then return '' end
	if #tostring(imei) ~= 15 then  return '' end
	return  string.sub(tostring(imei),12,#tostring(imei)) 
end

function get_daokenum_chinese_by_imei(imei)
	if not imei then return '' end
	if #tostring(imei) ~= 15 then  return '' end
	return  number_to_chinese(string.sub(tostring(imei),12,#tostring(imei)) )
end

function get_nickname_by_accountid(accountid, is_daoke_num)
	if not accountid then return '' end
	if #accountid ~= 10 then 
		if is_daoke_num then
			return get_daokenum_by_imei(accountid)
		end
		return '' 
	end

	local ok_status,nickname = redis_api.cmd('private','get',accountid .. ':nickname')
	if ok_status and nickname and #nickname > 0 then
		return nickname
	end

	if is_daoke_num  then
		local ok,imei = redis_api.cmd('private','get',accountid .. ':IMEI')
		if ok and imei then
			return get_daokenum_by_imei(imei)
		end
	end
	return nickname or ''
end


---- 获取accountID对应的昵称,如果昵称存在字符,则使用IMEI后4位
function get_nickname_remove_char(accountid)
	if not accountid then return '' end
	if #accountid ~= 10 then 
		return get_daokenum_by_imei(accountid)
	end

	local ok_status,nickname = redis_api.cmd('private','get',accountid .. ':nickname')
	if ok_status and nickname  then
		if string.match(nickname or '',"%d+") == tostring(nickname) then
			---- 数字 
			return number_to_chinese(tostring(nickname))
		end

		---- 昵称包含字符,不使用nickname
		if not string.match(nickname,"%a+") then
			return nickname
		end
	end

	local ok,imei = redis_api.cmd('private','get',accountid .. ':IMEI')
	if ok and imei then
		return get_daokenum_by_imei(imei)
	end
	return ''
end

---- accountID
---- return 
----   boolean  status
----   string    city_code 
----   string    city_name
function get_city_info_by_accountid(accountid)
	local ok , longitude, latitude = get_currentbl(accountid)
	if not ok then
		return false,nil,nil
	end
	return get_city_info_by_bl(longitude,latitude)
end

---- input longitude, latitude
---- return 
----   boolean  status
----   string    city_code
----   string    city_name
function get_city_info_by_bl(longitude, latitude)
	if not longitude or not latitude then return false,nil,nil end
	local grid = string.format("%d&%d",tonumber(longitude) * 100, tonumber(latitude) * 100 )
	-- local ok , city_info = redis_api.cmd('mapGridOnePercentV2','hmget',grid , 'cityCode', 'cityName')
	-- if ok and city_info and #city_info==2 then
	-- 	return ok , city_info[1],city_info[2]
	-- end
	-- only.log('E',string.format("-- get city_code failed %s -----hget---" , grid ))
	-- return false,nil,nil

	local ok, result = redis_api.cmd('mapGridOnePercent', 'get', grid )
	if ok and result then
		local ok_status,city_info = pcall(cjson.decode,result)
		if ok_status then
			return true,city_info['cityCode'],city_info['cityName']
		end
	end
	only.log('W',string.format("err mapGridOnePercent get cityCode by grid %s failed!--->---",grid))
	return false,nil,nil
end



----通过帐号获取城市编码
----1 true
----2 cityCode
function get_city_code_by_accountid(accountid)
	return get_city_info_by_accountid(accountid)
end

----通过城市编码获取城市名称
----1 true
----2 cityName
function get_city_name_by_city_code(city_code)
	local ok,ret = redis_api.cmd('public','hget','cityInfoHash',tostring(city_code))
	if ok and ret then
		return true,ret
	end
	return false,nil
end

----通过城市编码获取城市在线用户列表
----1 true 
----2 accountID_tab
function get_city_online_user_tab(city_code)
	local ok,ret = redis_api.cmd('statistic','smembers',city_code .. ":cityOnlineUser")
	if ok and ret then
		return true,ret
	end
	return false,nil
end

----通过城市编码获取城市在线用户总数
---1 true
---2 accountID_count
function get_city_online_user_count(city_code)
	local ok,ret = redis_api.cmd('statistic','scard',city_code .. ":cityOnlineUser")
	if ok and ret then
		return true,ret
	end
	return false,nil
end

----通过帐号获取所在城市在线用户列表
----1 true
----2 accountID_tab
function get_current_city_online_user_tab(accountid)
	local ok,ret = get_city_code_by_accountid(accountid)
	if ok and ret then
		return get_city_online_user_tab(ret)
	end
	return false,nil
end

----通过帐号获取所在城市在线总数
----1 true
----2 accountID_count
function get_current_city_online_user_count( accountid )
	local ok,ret = get_city_code_by_accountid(accountid)
	if ok and ret then
		return get_city_online_user_count(ret)
	end
	return false,nil
end

function get_default_channel_idx( default_channel )
	local ok,idx = redis_api.cmd('private','get' , default_channel .. ":channelID")
	if ok and idx then
		return idx
	end
	return nil
end

----获取用户默认的频道ID
----1 true
----2 channelID
function get_current_default_channel_id( accountid )
	local ok,ret = redis_api.cmd('private','get' , accountid .. ":currentChannel:groupVoice")
	if ok and ret then
		return true,ret 
	end
	return true , get_default_channel_idx(default_channel)
end


function get_current_default_channel_name ( accountid )
	local ok,ret = redis_api.cmd('private','get' , accountid .. ":currentChannel:groupVoice")
	local tmp_channel_idx = nil
	if ok and ret then
		tmp_channel_idx = ret
	else
		tmp_channel_idx = get_default_channel_idx(default_channel)
	end

	local ok, name = redis_api.cmd('private','hget', tostring(tmp_channel_idx) .. ":userChannelInfo","channelName")
	if ok and name then
		return name
	end
	return nil
end

function get_channel_info( channelid , key  )
	local ok, name = redis_api.cmd('private','hget', tostring(channelid) .. ":userChannelInfo", key )
	if ok and name then
		return name
	end
	return nil
end

----获取频道的用户列表
----1 true
----2 accountID_tab
function get_channel_online_user_tab(channelid)
	local ok,ret = redis_api.cmd('statistic','smembers',channelid .. ":channelOnlineUser")
	if ok and ret then
		return true,ret
	end
	return false,nil
end

----获取频道的用户总数
----1 true
----2 accountID_count
function get_channel_online_user_count(channelid)
	local ok,ret = redis_api.cmd('statistic','scard',channelid .. ":channelOnlineUser")
	if ok and ret then
		return true,ret
	end
	return false,nil
end

----获取帐号的默认频道的用户列表
----1 true
----2 accountID_tab
function get_default_channel_online_user_tab_by_accountid(accountid)
	local ok,ret = get_current_default_channel_id(accountid)
	if ok and ret then
		return get_channel_online_user_tab(ret)
	end
	return false,nil
end

----获取帐号的默认频道的用户总数
----1 true
----2 accountID_count
function get_default_channel_online_user_count_by_accountid(accountid)
	local ok,ret = get_current_default_channel_id(accountid)
	if ok and ret then
		return get_channel_online_user_count(ret)
	end
	return false,nil
end

function get_default_channel_more_info( accountid )
	local ok, channelid = get_current_default_channel_id(accountid)
	if ok and channelid then
		---- only.log('D',"accountid:%s channelid:%s ", accountid , channelid )
		local ok, usercount = get_channel_online_user_count(channelid)
		if ok and usercount then

			---- only.log('D',"accountid:%s usercount:%s ", accountid , usercount )

			local channel_name = get_channel_info(channelid, "channelName")
			if channel_name then

				---- only.log('D',"accountid:%s channel_name:%s ", accountid , channel_name )

				return true, usercount , channel_name 
			end
		end
	end
	return nil
end


---- 根据file_url获取文件内容下发
function get_file_data_by_http(file_url, max_lenth)
	if not file_url then return false,'url is error' end 
	local tmp_domain = string.match(file_url,'http://[%w%.]+:?%d*/')
	if not tmp_domain then return false,'domain get failed' end 
	local domain = string.match(tmp_domain,'http://([%w%.]+:?%d*)/')
	local urlpath = string.sub(file_url,#tmp_domain,#file_url)
	if not urlpath then return false,'' end
	local host = domain
	local port = 80
	if string.find(domain,':') then
		host = string.match(domain,'([%w%.]+)')
		port = string.match(domain,':(%d+)')
		port = tonumber(port) or 80
	end
	return get_file_by_url(host, port , urlpath, max_lenth )
end

function get_file_by_url(host_name, host_port , file_url, max_lenth)

	local data_format =  'GET %s HTTP/1.0\r\n' ..
						'HOST:%s:%s\r\n\r\n'
	local req = string.format(data_format,file_url,host_name,host_port)
	local ok,ret = cutils.http(host_name ,host_port , req, #req, 1, max_lenth or 0)
	if not ok then
		only.log('E',string.format('-->--host:%s  port:%s get dfs data when send get request failed!', host_name, host_port ) )
		return false,'' 
	end
	local split = string.find(ret,'\r\n\r\n')
	if not split then
		return false , '' 
	end
	local head = string.sub(ret,1,split)
	local file_data = string.sub(ret,split+4,#ret)
	return true , file_data
end

function url2tomcat(server, body_tab  )
	local ok, tab = general_request_web_api( server,  "dfsapi/v2/url2tomcat" , body_tab ,  true , 1500 )    
	if ok and tab then
		return true,tab['url'],tab['fileID']
	end
	return false,nil
end

---- return value
---- 1: true / false  
---- 2: if true ,the value is file url
function txt2voice( server ,  body_tab )
	---- 最后一个参数true表示使用cutils请求
	local ok, tab = general_request_web_api( server,  "dfsapi/v2/txt2voice" , body_tab ,  true , 1500 , true )    
	if ok and tab then
		return true ,tab['url'],tab['fileID'],tab['fileSize']
	end
	return false,nil
end

function jtxt2voice( server ,  body_tab )
	---- 最后一个参数true表示使用cutils请求
	local ok, tab = general_request_web_api( server,  "dfsapi/v3/jtxt2voice" , body_tab ,  true , 1500 , true )    
	if ok and tab then
		return true ,tab['url'],tab['fileID'],tab['fileSize']
	end
	return false,nil
end

---- return value
---- 1: true / false  
---- 2: if true ,the value is file url
---- windows wsapi server text to speech 
function wstxt2voice( server, body_tab )
	local ok, tab = general_request_web_api( server,  "dfsapi/v2/wstxt2voice" , body_tab ,  true , 1500 , true )    
	if ok and tab then
		return true ,tab['url'],tab['fileID'],tab['fileSize']
	end
	return false,nil
end


---- 获取附近道客
function get_around_daoke(server , body_tab  )
	local ok, tab = general_request_web_api( server,  "mapapi/v2/getNearbyDaoke" , body_tab ,  true , 1500 )    
	if ok and tab then
		return true ,tab
	end
	return false,nil
end

---- 根据经纬度方向角,获取当前所在的路名以及前方道路,后方道路名称
function get_all_road_info( server, body_tab)
	local ok, tab = general_request_web_api( server,  "mapapi/v2/getCrossing" , body_tab ,  true , 1500 )    
	if ok and tab then
		if tostring(tab['resultSign']) == "1" then
			return true ,tab
		end
	end
	return false,nil
end

local function get_mileage( server, body_tab )
	local ok, tab = general_request_web_api( server,  "DataCore/autoGraph/getMonthMileageByAccount" , body_tab ,  true , 1500 )    
	if ok and tab then
		return tonumber(tab['RESULT']['actualMileage'])
	end
	return false
end


---- tab转表单形式
function keys_binary_to_req(host_ip, host_port , url_path, args, file_name, file_binary)

    local head_boundary = string.format("----WebKitFormBoundaryDcO1SS%dMTDfpuu%skkU",ngx.time(),  ngx.time() )

    local head_format =   'POST /%s HTTP/1.0\r\n' ..
    'Host:%s:%s\r\n' ..
    'Content-Length:%d\r\n' ..
    'Content-Type: multipart/form-data; boundary=' .. head_boundary .. '\r\n\r\n%s'

    local body_boundary = '--' .. head_boundary
    local body_suffix   = body_boundary .. '--'
    local body_prefix   = '%s\r\nContent-Disposition: form-data; name="%s"\r\n\r\n%s\r\n'

    local body_tab = {}
    for i , v in pairs(args) do
        table.insert(body_tab,string.format(body_prefix,body_boundary,i,v))
    end

    local body_data = table.concat(body_tab,"")
    if file_name and file_binary then
        body_data = body_data .. string.format('%s\r\nContent-Disposition: form-data; name="mmfilename"; filename="%s"\r\n' ..
        'Content-Type: application/octet-stream\r\n\r\n%s\r\n',
        body_boundary, file_name , file_binary)
    end
    body_data =  body_data .. body_suffix
    local req_data = string.format(head_format, url_path, host_ip, tostring(host_port), #body_data, body_data)
    return req_data
end
