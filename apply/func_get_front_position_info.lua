local json = require('cjson')
local redis = require('redis')
local utils = require('utils')
local cutils = require('cutils')
local only = require('only')
--local gosay = require('gosay')
local map = require('map')
local cfg = require('map_cfg')
local msg = require('msg')
--local ngx = require('ngx')
--local safe = require('safe')
local point_func = require('map_point_func')
--local point_match_road = point_func.handle()
local path = cfg.path
local poiType = cfg.poiType
local http_api = require('http_short_api')
local redis_pool_api = require('redis_pool_api')
local adjust_lon_lat = map.correct_lonlat
local ISQUIT = 'quit'
local CON    = 'con'
local url_tab = { 
        type_name = 'map',
        app_key = '',
        client_host = '',
        client_body = '',
}
module("func_get_front_position_info",package.seeall)

local function check_parameter(args)
        if not args['accountID'] then
                only.log('D',"accountID is nil\n")
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_ARG'], "accountID")
				return ISQUIT
        end

        local key = args['accountID']  ..":personalPOI"
	local ok = redis_pool_api.cmd('mapFrontInfo', 'del', key) --FIXME
	if not ok then
	        local info = string.format("fail to del key %s from redis mapFrontInfo", key)
	        only.log('E', info)
	        --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], info)
			return ISQUIT	
	end

	
	if not args['latitude'] then
                only.log('D',"latitude is nil\n")
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_ARG'], "latitude")
				return ISQUIT
        end
        if not args['longitude'] then
                only.log('D',"longitude is nil\n")
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_ARG'], "longitude")
				return ISQUIT
        end
	if tonumber(args["longitude"]) < 72.004 or tonumber(args["longitude"])  > 137.8347 then
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_ARG'],"requrie longitude out of china")
				return ISQUIT
        end
        
        if tonumber(args["latitude"]) < 0.8293 or tonumber(args["latitude"]) > 55.8271 then
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_ARG'],"requrie latitude out of china")
				return ISQUIT
        end
        if not args['direction'] then
        	only.log('D',"direction is nil\n")
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_ARG'], "direction")
				return ISQUIT
        elseif tonumber(args['direction']) == -1 then
        	only.log('D',"direction is -1\n")
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_ARG'],"direction -1")
				return ISQUIT
	end
	return CON
end

local function determine_location(args)
        local tb = {longitude = args['longitude'], latitude = args['latitude'], direction = args['direction'], matchType = args['matchType'], returnSign = "3"}
	local res = point_func.handle(url_tab, tb)
	if not res['roadRootID'] then
               	--gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], "failed to get roadRootID")
				return ISQUIT
	end
	only.log('D', string.format("roadRootID %s aheadNodeID %s forward %s", res['roadRootID'], res['aheadNodeID'], res['forward']))
	return res  
end

local function get_data_from_redis(key, mapRoadNumber)
        local ok, data = redis_pool_api.cmd('mapRoad0' .. mapRoadNumber, 'get', key)
	if ok and data then
		return data 
        else
                local info = string.format("failed to get %s from mapRoad%d redis", key, mapRoadNumber)
                only.log('E', info)
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], info)
				return ISQUIT
        end
end

local function get_roadSegment_from_roadRootID(road_info)
        local map_road_number = road_info['mapRoadNumber']    
        local key = string.format("%s:roadRootInfo", road_info['roadRootID'])   
        only.log('D', string.format("get roadRootInfo key %s, redis number  %d",key, map_road_number))
	local data  = get_data_from_redis(key, road_info['mapRoadNumber'])
	if data == ISQUIT then 
		return ISQUIT
	end
        --将redis获取到的数据存到表中
        local ok, road_root = pcall(json.decode,data)
        --only.log('D',data)
        if not ok or not road_root then
                local info = string.format("failed to decode  %s from mapRoad%d", key, map_road_number)
                only.log('E', info)
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], info)
				return ISQUIT
        end
	return road_root['RS']['FS'], road_root['RST']
	--[[
	---roadSegmentType 1,单线双行 2 双线单行
        if road_root['RST'] == "2"  or  (road_root['RST'] == "1" and not next(road_root['RS']['SS'])) then
                only.log('D', "one road")
                return road_root['RS']['FS'], 1        
		end
       	-- 双线处理 
       	for k,v in pairs(road_root['RS']['FS']) do
       	        ---判断firstSegment是否含有当前GPS点的roadID
		if v['RID'] == roadID then
       	                for k1,v1 in pairs(v['nodes']) do
       	                        if v1['nodeID'] == pastNodeID then
       	                                --当下一个节点非next节点时，那说明肯定是在secondSegment,因为roadRootIDInfo是按顺序来的
       	                                if v['nodes'][k1+1] and v['nodes'][k1+1]['nodeID'] == aheadNodeID then --FIXME
       	                                        only.log('D', "two road type 1")
       	                                        return road_root['RS']['FS'], 2        
       	                                else
       	                                        only.log('D', "two road type 2")
       	                                        return road_root['RS']['SS'], 2        
       	                                end
       	                        end
       	                
       	                end
       	        end
       	end
       	only.log('D', "two road type 3")
       	--应对当firstSegment没有这个roadID时
       	return road_root['RS']['SS'], 2
	]]--
end

local function get_pois_from_redis(mget_tab, mapPosition, key)
        local ok,data = redis_pool_api.cmd(mapPosition, 'hgetall', key) --FIXME
        if not ok then
                local info = string.format("failed to redis hgetall %s from mapPosition", key)
                only.log('E', info)
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], info)
				return ISQUIT
        end
        --only.log('D', string.format("key  %s", key))
        if data and next(data) then
                --only.log('D', string.format("key  %s  poi %s ", key, data))
                if mget_tab then 
                        table.insert(mget_tab, data)
                else
                        mget_tab = {data}        
                end
        end 
end

local function direction_sub(cur_dir,last_dir)
        local angle_sub
        if  cur_dir >= 270 and (last_dir >=0 and last_dir <= 90 ) then
                angle_sub = cur_dir - (360 + last_dir)
        
        elseif  (cur_dir >= 0 and cur_dir <= 90 ) and last_dir >= 270 then
                angle_sub = 360 + cur_dir - last_dir
        else
                angle_sub = cur_dir - last_dir
        end
        return math.abs(angle_sub)
end

local function get_point_POI(point_dir, poi_type_get, pois, potionType, poiInfo)

	local angle_sub1 = direction_sub(point_dir, poiInfo['direction1'])
	local angle_sub2 = nil
	if poiInfo['direction2'] then
		angle_sub2 = direction_sub(point_dir, poiInfo['direction2'])
	end
	local angle_sign = 0
	if angle_sub1 < 30 then
		angle_sign = 1
	elseif angle_sub2 and angle_sub2 < 30 then
		angle_sign = 2
	end
	--only.log('D', string.format("dir1 %d dir2 %d ", angle_sub1, angle_sub2 or 111)) 
	if string.match(poi_type_get, poiInfo['positionType']) then
                if angle_sign ~= 0 then
        		if angle_sign == 1 then
        			poiInfo['direction'] = poiInfo['direction1']
        		else
        			poiInfo['direction'] = poiInfo['direction2']
        		end
			--only.log('D', string.format("dir1 %.3f dir2 %.3f", poiInfo['direction1'], poiInfo['direction2'] or 111))
        		poiInfo['direction1'] = nll
        		poiInfo['direction2'] = nll
        		if pois[potionType] then
               		        table.insert(pois[potionType], poiInfo)
               		else 
               		        pois[potionType] = {poiInfo}        
               		end
        	end
        end
end

local function get_poi_from_roads(roads, nodes, point_dir, city_code)
        only.log('D',"###$$$>>>> get roads and nodes POI")
        local mget_tab, ok, data = {} 
        local i = 1
        for i = 1, 2 do
                local mapPosition = i==1 and "mapPosition0" or "mapPosition1"
                for k,v in pairs(roads) do
                        if get_pois_from_redis(mget_tab, mapPosition, string.format("%s:nodePOI", v)) == ISQUIT then 
							return ISQUIT 
						end
                end
                for k,v in pairs(nodes) do
                        if get_pois_from_redis(mget_tab, mapPosition, string.format("%s:nodePOI", v)) == ISQUIT then
							return ISQUIT
					end

        end
        if not next(mget_tab) then
                return {}
	end
        local pois = {}
        local poi_type_get = table.concat(poiType, "|")
        for k,v in pairs(mget_tab) do            
                for k1, v1 in pairs(v) do
                	ok, v1 = pcall(json.decode,v1)
			if not ok then
               			only.log('E', "failed to decode poi table")
               			--gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], "failed to decode poi table")
						return ISQUIT
			end
			for k2, v2 in pairs(v1) do
				v2['appKey'] = nil
                                if string.match(poi_type_get, v2['positionType']) then
					if v2['direction1'] and v2['positionType'] ~= "1221000" then --FIXME(吐槽是否按方向下发)
                                                get_point_POI(point_dir, poi_type_get, pois, k1, v2)

					else
						if pois[k1] then
        	                       		        table.insert(pois[k1], v2)
        	                       		else 
        	                       		        pois[k1] = {v2}        
        	                       		end
					end
                                end
			end 
                end
        end
        return pois
end
end
local function get_straight_roadIds_from_forward_road_direction(cur_dir_roadRootID, road_info, point_dir)
        only.log('D',"###$$$>>>> get roads from ahead 4 kilometre")
        local roadID, ahead_node_id = road_info['roadID'], road_info['aheadNodeID']
        local sum_distance = road_info['aheadDistance'] or 0
        only.log('D', "base_distance" .. sum_distance)
	local road_sign, node_sign, roads, nodes 
	--获取当前roadID，ahead_node_ID在roadRootInfo中的位置（road_sign和node_sign）
	local v
	for i=1, #(cur_dir_roadRootID)  do
	        v= cur_dir_roadRootID[i]
	        if v['RID'] == roadID then --FIXME
                        road_sign = i
                        roads = {roadID}
			only.log('D', "roadID  " .. roadID)
                        v = v['nodes']
                        for j=1, #(v) do
                                if v[j]['nodeID'] == ahead_node_id then
                                        node_sign = j
                                        nodes = {ahead_node_id}
                                        break
                                end
                        end
                end
                if node_sign then break end
        end
        --判断是否找到路或者节点        
	if not road_sign or not node_sign then
	        local info = string.format("road  %s match roadRootID %s is nil",roadID, road_info['roadRootID'])
        	only.log('E', info)
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], info)
				return ISQUIT
	end
        only.log('D', string.format("roadSign %d nodeSign %d", road_sign, node_sign))
	local cur_road_info, end_sign        
	for i = road_sign, #(cur_dir_roadRootID) do
	        cur_road_info = cur_dir_roadRootID[i]
	        ---添加roadID
	        if i ~= road_sign then
	                table.insert(roads, cur_road_info['RID'])
			only.log('D', string.format("roadID  %s",cur_road_info['RID']))
	                sum_distance = sum_distance + cur_road_info['LEN']
	                if sum_distance > cfg['forward_distance'] then
	                        end_sign = 1
	                end
	        end
	        --添加nodeID
	        local tmp =  i==road_sign and node_sign+1 or 1 
                local road_nodes = cur_road_info['nodes']
                for j = tmp, #(road_nodes) do
                        table.insert(nodes, road_nodes[j]['nodeID'])
                        if (i == road_sign or end_sign) and j ~= #(road_nodes) then
                                sum_distance = sum_distance + road_nodes[j]['length']
                                if sum_distance > cfg['forward_distance'] then
	                        	end_sign = 2
	                                break
	                        end        
                        end
                end
                if end_sign then break end
	end
	only.log('D', string.format("end nodeID is %s", nodes[#(nodes)]))
	only.log('D', string.format("sum_distance  %d  roads %d nodes %d", sum_distance, #(roads), #(nodes)))	
	return get_poi_from_roads(roads, nodes, point_dir, road_info['cityCode'])
end

local function get_straight_roadIds_from_backward_road_direction(cur_dir_roadRootID, road_info, point_dir)
        only.log('D',"###$$$>>>> get roads from backward 4 kilometre")
        local roadID, ahead_node_id = road_info['roadID'], road_info['aheadNodeID']
        local sum_distance = road_info['aheadDistance'] or 0
        only.log('D', "base_distance " .. sum_distance)
	local road_sign, node_sign, roads, nodes 
	--获取当前roadID，ahead_node_ID在roadRootInfo中的位置（road_sign和node_sign）
	local v
	for i=#(cur_dir_roadRootID), 1, -1  do
	        v= cur_dir_roadRootID[i]
                only.log('D', v['RID'])
	        if v['RID'] == roadID then --FIXME
                        road_sign = i
                        roads = {roadID}
                        v = v['nodes']
                        for j = #v, 1, -1 do
                                if v[j]['nodeID'] == ahead_node_id then
                                        node_sign = j
                                        nodes = {ahead_node_id}
                                        break
                                end
                        end
                end
                if node_sign then break end
        end
        --判断是否找到路或者节点        
	if not road_sign or not node_sign then
	        local info = string.format("road  %s match roadRootID %s is nil",roadID, road_info['roadRootID'])
        	only.log('E', info)
                --gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], info)
				return ISQUIT
	end
        only.log('D', string.format("roadSign %d nodeSign %d", road_sign, node_sign))
	local cur_road_info, end_sign
	for i = road_sign , 1, -1 do
	        cur_road_info = cur_dir_roadRootID[i]
	        ---添加roadID
	        if i ~= road_sign then
	                table.insert(roads, cur_road_info['RID'])
                        only.log('D', "roadID  " .. cur_road_info['RID'])
	                sum_distance = sum_distance + cur_road_info['LEN']
	                if sum_distance > cfg['forward_distance'] then
	                        end_sign = 1
	                end
	        end
	        --添加nodeID
                local road_nodes = cur_road_info['nodes']
                local tmp =  i==road_sign and node_sign-1 or #(road_nodes) 
                for j = tmp, 1, -1 do
			if not road_nodes[j] or  not road_nodes[j]['nodeID'] then --FIXME
                       		break	
			end
			table.insert(nodes, road_nodes[j]['nodeID'])
		       	--首次开始和结束
                       	if (i == road_sign or end_sign) and j ~= #(road_nodes) then
                       	        sum_distance = sum_distance + road_nodes[j]['length']
                       	        if sum_distance > cfg['forward_distance'] then
	               	                end_sign = 2
		       			break
	               	        end        
                       	end
                end
                if end_sign then break end
	end
	only.log('D', string.format("end nodeID is %s", nodes[#(nodes)]))
	only.log('D', string.format("sum_distance  %d  roads %d nodes %d", sum_distance, #(roads), #(nodes)))	
	return get_poi_from_roads(roads, nodes, point_dir, road_info['cityCode'])   
end

local function personal_poi_store_to_redis(key, pois)
        only.log('D', key)
        for k,v in pairs(pois) do
                ok, v = pcall(json.encode,v)
		if not ok then
               		only.log('E', "failed to encode poi table")
               		--gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'], "failed to encode poi table")
					return ISQUIT
		end
                ok = redis_pool_api.cmd('mapFrontInfo', 'hset', key, k, v) --FIXME
                if not ok then
                        local info = string.format("failed to hset %s filed %s value %s from mapFrontInfo", key, k, v)
                        only.log('E', info)
                        --gosay.go_false(url_tab, msg['MSG_DO_REDIS_FAILED'])
						return ISQUIT
                end
        end
end

 function entry(args)

        -->check args
        if check_parameter(args)==ISQUIT then 
			return nil
		end
	    -->do api
        local road_info = determine_location(args)
		if road_info == ISQUIT then 
			return nil
		end
        --roadType 是指roadRootID存储是单行路还是双行路 1单 2双 
        local cur_dir_roadRootID, roadType  = get_roadSegment_from_roadRootID(road_info)
        if not next(cur_dir_roadRootID) or cur_dir_roadRootID == ISQUIT then --FIXME
		only.log('D', "get roadRootID front info error")
        	--gosay.go_success(url_tab, msg['MSG_SUCCESS_WITH_RESULT'], "get roadRootID front info error")
			return nil 
		end
        local pois
        if roadType == 2 then
                pois = get_straight_roadIds_from_forward_road_direction(cur_dir_roadRootID, road_info, tonumber(args['direction']))
        else
		if road_info['forward'] == "1" then
                        pois = get_straight_roadIds_from_forward_road_direction(cur_dir_roadRootID, road_info, tonumber(args['direction']))                
		else
                        pois = get_straight_roadIds_from_backward_road_direction(cur_dir_roadRootID, road_info, tonumber(args['direction']))
                end

        end
		if pois == ISQUIT then 
			return nil 
		end
        if personal_poi_store_to_redis(string.format("%s:personalPOI",args['accountID']), pois) == ISQUIT then
			return nil
		end

        local ok, result = pcall(json.encode,pois)
        only.log('D',result)
        --only.log('D',"###$$$>>>> API finish\n")
        if ok then
		--gosay.go_success(url_tab, msg['MSG_SUCCESS_WITH_RESULT'], result)
		return result
		else
		--gosay.go_false(url_tab, msg['MSG_ERROR_REQ_CODE'],"result json encode error")
		return nil 
		end
end

