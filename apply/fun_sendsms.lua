-- author:	zhouzhe
-- date:		2015.05.21
-- function:	send sms

local only		= require("only")
local utils		= require("utils")
local app_utils	= require("app_utils")
local socket		= require("socket")
local mysql_api 	= require("mysql_pool_api")
local math  		= require("math")

module("fun_sendsms", package.seeall)
local app_sendsms = "app_sendsms___sendsms"

local  sql_fmt   ={
	sql_update	= "UPDATE messageInfo SET returnCode = '%s', returnInfo = '%s' WHERE bizid = '%s' ",
	sql_insert	= "INSERT INTO messageInfo ( mobile,content,createTime,bizid,appKey,returnCode,"..
					"sendCount,remarks, platformInfo ) VALUES( '%s', '%s', %d, '%s', '%s', 'code', %d, '%s', '%s' )",
}
local send_sms_flag = "ss"
local uuid = utils.create_uuid

local CHUANGLAN = 1    
local PINGXINTONG = 2
local HUAXIN = 3  

local sms_str = {
	'【道客快分享】',
	'【帮忙拉】',
} 

--创蓝短信接口
function chuanglan(mobile,content,appKey,remarks,sms_type)
	-- only.log('D','chuanglan短信接口')
	local daoke_info = { 
		host        = "222.73.117.158",
		port        = 80,
		sms_user	   = "mirrtalk",
		sms_pass   = "Tch123456",
		sms_post   = "/msg/HttpBatchSendSM ",
	}

	local bangmangla_info = { 
		host        = "222.73.117.158",
		port        = 80,
		sms_user	   = "bmla88",
		sms_pass   = "Tch123456",
		sms_post   = "/msg/HttpBatchSendSM ",
	}

	local sms_info = {
		host        = nil,
		port        = nil,
		sms_user	= nil,
		sms_pass   = nil,
		sms_post   = nil,
		sms_body   = "account=%s&pswd=%s&mobile=%s&msg=%s&needstatus=true",
		sms_fmt    = "POST %sHTTP/1.0\r\nHost: %s:%d\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: %d \r\n\r\n%s",
	}

	for a,v in pairs(daoke_info) do 
		sms_info[a] = v
	end 

	if sms_type == 1 then 
		for a,v in pairs(daoke_info) do 
			sms_info[a] = v
		end 
	elseif sms_type == 2 then
		for a,v in pairs(bangmangla_info) do 
			sms_info[a] = v
		end
	end 

	sms_info.mobile = mobile
	sms_info.content = content
	sms_info.appKey = appKey
	sms_info.remarks = remarks
	local postfix= CHUANGLAN
	local ok, bizid, result, msg = socket_send(sms_info, postfix, sms_type)
	--only.log("D",string.format("chaunglan send sms return result : %s", result))
	
	local platformInfo = "chuanglan"
	--插入数据库信息
	local createtime = os.time()

	local sql_insert = string.format(sql_fmt.sql_insert,mobile,msg,createtime,bizid,appKey,1,remarks or "" , platformInfo )
	local ok_sql = mysql_api.cmd(app_sendsms,"insert",sql_insert)
	if not ok_sql then
		only.log("E","chaunglan mysql insert failed : %s " , sql_insert)
	end

	if not ok then
		only.log('E', string.format('chuanglan send sms failed [[ host:%s  port:%s  sms_post:%s ]]', sms_info.host, sms_info.port, sms_info.sms_post ))
		update_databases( false, bizid )
		return false
	end

	local res_tab = string.match(result, ",%d")

	if not res_tab then
		only.log("E","chuanglan return failed " )
		update_databases( false, bizid )
		return false
	end

	local res_status = tonumber(string.sub(res_tab,2,2))
	
	if tonumber(res_status) ~= 0 then
		local error_code = string.match(string.match(result, ",%d%d%d"), "%d%d%d")

		only.log("E",string.format("chaunglan send sms failed , errorCode : %s ", error_code) )

		if (tonumber(error_code) or 0 ) == 109 then
			only.log("E",string.format("chaunglan server amount is not enough"))
			update_databases( false, bizid , "短信通道账户余额不足")
			return false
		end

		update_databases( false, bizid )
		return false
	end
	return true, bizid
end

--pingxintong短信接口
function pingxintong( mobile, content, appKey, remarks, sms_type)
	-- only.log('D','pingxintong短信接口')
	local sms_info 	= {
		host 		= "www.pingxintong.com",
		port  		= 80,
		sms_user 	= "mirrtalk",
		sms_pass 	= "duanP@55w0rdxin",
		sms_post 	= "/api.php ",
		sms_body 	= "username=%s&password=%s&method=sendsms&mobile=%s&msg=%s",
		sms_fmt 		= "POST %sHTTP/1.0\r\nHost: %s:%d\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: %d \r\n\r\n%s",
	}

	sms_info.mobile 	= mobile
	sms_info.content = content
	sms_info.appKey 	= appKey
	sms_info.remarks = remarks
	local postfix = PINGXINTONG
	local ok, bizid, result, msg = socket_send(sms_info, postfix,sms_type)
	only.log("D",string.format("pingxintong send sms return result : %s", result))
	local platformInfo = "pingxintong"
	--插入数据库信息
	local createtime = os.time()
	local sql_insert = string.format(sql_fmt.sql_insert,mobile,msg,createtime,bizid,appKey,1,remarks or "" , platformInfo )
	local ok_sql = mysql_api.cmd(app_sendsms,"insert",sql_insert)
	if not ok_sql then
		only.log("E",string.format( "pingxintong mysql insert failed! sql_insert: %s ",  sql_insert) )
	end

	if not ok then 
		only.log('E',string.format('pingxintong send sms failed [[ host:%s port:%s sms_post:%s ]]',sms_info.host, sms_info.port, sms_info.sms_post ))
		update_databases( false, bizid )
		return false
	end

	local res_body = string.match(result, "\r\n\r\n(.+)")
	if not res_body then
		only.log("E","pingxintong match the return result failed ! [result]: %s ", result )
		update_databases( false, bizid )
		return false
	end

	local error_code = string.match(res_body, '<error>(.+)</error>') or 'no match code'
	only.log("D",string.format("pingxintong send sms return errorCode : %s", error_code))
	if tonumber(error_code) ~= 0 then
		if tonumber(error_code) == 6 then
			only.log("E",string.format("pingxintong server amount is not enough"))
			update_databases( false, bizid, '短信通道账户余额不足' )
		end
		update_databases( false, bizid )
		return false
	end

	return true, bizid
end

--华信短信接口
function huaxin(mobile,content,appKey,remarks,sms_type)
	-- only.log('D','huaxin短信接口')
	local sms_info = { 
		host        = "sh2.ipyy.com",
		port        = 80,
		sms_user	   = "zgfcs006",
		sms_pass   = "a654321",
		sms_post   = "/sms.aspx ",
		--action=send&userid=&account=账号&password=密码&mobile=15023239810,13527576163&content=内容&sendTime=&extno=
		sms_body   = "action=send&userid=&account=%s&password=%s&mobile=%s&content=%s&sendTime=&extno=",
		sms_fmt    = "POST %sHTTP/1.0\r\nHost: %s:%d\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: %d \r\n\r\n%s",
	}
	sms_info.mobile = mobile
	sms_info.content = content
	sms_info.appKey = appKey
	sms_info.remarks = remarks
	local postfix= HUAXIN
	local ok, bizid, result, msg = socket_send(sms_info, postfix,sms_type)
	only.log("D",string.format("huaxin send sms return result : %s", result))
	local platformInfo = "huaxin"
	--插入数据库信息
	local createtime = os.time()
	local sql_insert = string.format(sql_fmt.sql_insert,mobile,msg,createtime,bizid,appKey,1,remarks or "" , platformInfo )
	local ok_sql = mysql_api.cmd(app_sendsms,"insert",sql_insert)
	if not ok_sql then
		only.log("E","huaxin mysql insert failed : %s " , sql_insert)
	end

	if not ok then
		only.log('E', string.format('huaxin send sms failed [[ host:%s  port:%s  sms_post:%s ]]', sms_info.host, sms_info.port, sms_info.sms_post ))
		update_databases( false, bizid )
		return false
	end

	local str_match ={
		'message',
		'remainpoint',
		'taskID',
		'successCounts',
	}
	local res_tab = {}
	for a,v in pairs(str_match) do 
		table.insert(res_tab,string.match(result, "<"..v..">(.-)</"..v..">"))
	end 

	if #res_tab == 0  then
		only.log("E","huaxin return failed " )
		update_databases( false, bizid )
		return false
	end

	if not string.find(res_tab[1],'操作成功') then

		only.log("E",string.format("huaxin send sms failed , errorMessage : %s ", res_tab[1]) )

		if (tonumber(res_tab[2]) or 0 ) == 0 then
			only.log("E",string.format("huaxin server amount is not enough"))
			update_databases( false, bizid , "短信通道账户余额不足")
			return false
		end

		update_databases( false, bizid )
		return false
	end
	return true, bizid
end

function socket_send(sms_info, postfix, sms_type)
	local bizid = send_sms_flag .. uuid()
	local tab = {}
	tab["sms_pass"] = utils.url_encode(sms_info["sms_pass"])
	tab["sms_user"] = utils.url_encode(sms_info["sms_user"])
	local compose = '【道客快分享】'
	local sms_type = tonumber(sms_type)
	local compose = '【道客快分享】'
	if sms_type == 1 then 
		compose = sms_str[1]
	elseif sms_type == 2 then 
		compose = sms_str[2]
	end 

	if postfix == CHUANGLAN then 
		tab["content"] =  utils.url_encode(sms_info["content"])
	elseif postfix == PINGXINTONG then 
		tab["content"] =  utils.url_encode(sms_info["content"])..utils.url_encode(string.lower(compose))
	elseif postfix == HUAXIN then 
		tab["content"] =  utils.url_encode(string.lower(compose))..utils.url_encode(sms_info["content"])
	end

	--> construction data
	local body = string.format(sms_info.sms_body, tab["sms_user"], tab["sms_pass"], sms_info['mobile'], tab["content"])
	local data = string.format(sms_info.sms_fmt, sms_info["sms_post"], sms_info["host"], sms_info["port"], #body, body)
	
	--> send sms
	-- local startTime = socket.gettime()
	local tcp = socket.tcp()
	tcp:setoption("keepalive",true)
	tcp:settimeout(3,"b")

	local ret = tcp:connect(sms_info["host"],sms_info["port"])  
	if not ret then
		only.log("E",string.format("connect failed host : %s  port : %d" , sms_info["host"], sms_info["port"]))
		return false, bizid, "", utils.url_decode(tab["content"])
	end
	tcp:send(data)
	local result = tcp:receive("*a")
	tcp:close()
	local endTime = socket.gettime()

	-- local useTime = endTime - startTime
	-- only.log("D", string.format("socket useTime = %s",  useTime ))

	if (string.find(sms_info["content"],"'")) then
		-- only.log("W", "content paramater is error ! %s ", sms_info["content"])
		sms_info["content"] = string.gsub(sms_info['content'], "'","")
	end
	
	if not result then
		return false, bizid, "", utils.url_decode(tab["content"])
	else
		return true, bizid, result, utils.url_decode(tab["content"])
	end
end

function update_databases(status, bizid , remark )
	local sql_update = "" 
	if status then
		sql_update = string.format(sql_fmt.sql_update, "0", "发送成功" .. (remark or '') , bizid)
	else
		sql_update = string.format(sql_fmt.sql_update,"http failed", "发送失败" .. (remark or '') , bizid)
	end

	local ok,res = mysql_api.cmd(app_sendsms,"update",sql_update)
	if not ok then
		only.log("E","mysql update failed : %s " , sql_update)
	end
end

function check_parameter( mobile, content, appKey)
	if(not utils.is_number(tonumber(mobile))) or (string.len(mobile) ~= 11) or (string.sub(tostring(mobile), 1, 1) ~= '1') then
		only.log("E", "mobile error %s " , mobile ) 
		return false,"mobile is error"
	end

	local strlen = app_utils.str_count(content)
	if strlen > 60 then
		only.log("E", "content Length is too long, strlen: %s", strlen )
		return false, "SMS content is too long !"
	end

	if not appKey or #appKey < 5  then  
		only.log("E","appKey error ") 
		return false,"appKey is error"
	end
	return true
end

-- 平台名称列表
local platform_list = {
	 chuanglan, 		-- 1 :chuanglan平台编号
	-- pingxintong,  	-- 2 :pingxintong平台编号
	-- huaxin          -- 3 :huaxin平台编号
}

-- 发送短信入口
function send(mobile, content, appKey, remarks, times, sms_type)
	-- 参数检查
	local ok, result = check_parameter( mobile, content, appKey)
	if not ok then
		only.log('E', result )
		return false, result
	end
	only.log("D", string.format("mobile:%s, content:%s, appKey:%s", mobile,content,appKey ))
	times = tonumber(times)
	sms_type = tonumber(sms_type)
	
	if not times then 
		times = 2 
	end 
	if times < 1 then
		times = 2
	end
	if times > 5 then
		only.log("E", "send SMS times too many")
		return false, "send SMS times too many"
	end

	-- 如果没有输入platform随机发送短信,成功返回
	for times_k = 1, times do
		-- 随机抽取平台发送
		local plat_max = #platform_list
		local plat_No = utils.random_among(1, plat_max)
		local flags_num = 1
		-- 平台轮询发送短信,优先选定随机到的平台号发送
		for i=1, #platform_list do
			if flags_num == 1 then
				flags_num = 0
				local ok, bizid = platform_list[plat_No]( mobile, content, appKey, remarks , sms_type)
				if ok then
					update_databases(true, bizid )
					return true, bizid
				end
			end

			if flags_num == 0 and i ~= plat_No then
				local ok, bizid = platform_list[i]( mobile, content, appKey, remarks , sms_type)
				if ok then
					update_databases(true, bizid )
					return true, bizid
				end
			end
		end
	end
	only.log('E',string.format(" appKey: %s mobile: %s content:%s , all platform send sms failed ", appKey, mobile , content ))
	return false, "send sms failed"
end
