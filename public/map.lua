local http_api = require('http_short_api')
local utils = require('utils')
local only = require('only')

local LIB_MATH_FLOOR	= math.floor
local LIB_MATH_POW	= math.pow
local LIB_MATH_SIN	= math.sin
local LIB_MATH_SQRT	= math.sqrt
local LIB_MATH_ABS	= math.abs
local LIB_MATH_TAN	= math.tan
local LIB_MATH_COS	= math.cos
local LIB_MATH_ATAN	= math.atan
local LIB_TABLE_REMOVE	= table.remove
local LIB_TABLE_INSERT	= table.insert
local LIB_STRING_FIND	= string.find
local LIB_STRING_SUB	= string.sub
local LIB_STRING_FORMAT	= string.format
local LIB_STRING_MATCH	= string.match
local EARTH_RADIUS      = 6378.137

module('map', package.seeall)

local M_PI = 3.14159265358979324
local M_A = 6378245.0
local M_EE = 0.00669342162296594323

--[[=================================CORRECT FUNCTION=======================================]]--

local function out_china(lat, lon)
	if (lon < 72.004 or lon > 137.8347) then
		return true
	end
	if (lat < 0.8293 or lat > 55.8271) then
		return true
	end
	return false
end

local function transform_lat(x, y)
	local ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * LIB_MATH_SQRT(LIB_MATH_ABS(x))
	ret = ret + (20.0 * LIB_MATH_SIN(6.0 * x * M_PI) + 20.0 * LIB_MATH_SIN(2.0 * x * M_PI)) * 2.0 / 3.0
	ret = ret + (20.0 * LIB_MATH_SIN(y * M_PI) + 40.0 * LIB_MATH_SIN(y / 3.0 * M_PI)) * 2.0 / 3.0
	ret = ret + (160.0 * LIB_MATH_SIN(y / 12.0 * M_PI) + 320 * LIB_MATH_SIN(y * M_PI / 30.0)) * 2.0 / 3.0

	return ret
end

local function transform_lon(x, y)
	local ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * LIB_MATH_SQRT(LIB_MATH_ABS(x))
	ret = ret + (20.0 * LIB_MATH_SIN(6.0 * x * M_PI) + 20.0 * LIB_MATH_SIN(2.0 * x * M_PI)) * 2.0 / 3.0
	ret = ret + (20.0 * LIB_MATH_SIN(x * M_PI) + 40.0 * LIB_MATH_SIN(x / 3.0 * M_PI)) * 2.0 / 3.0
	ret = ret + (150.0 * LIB_MATH_SIN(x / 12.0 * M_PI) + 300.0 * LIB_MATH_SIN(x / 30.0 * M_PI)) * 2.0 / 3.0

	return ret
end
--地球转火星
function correct_lonlat(ori_lon, ori_lat)
	ori_lon = tonumber(ori_lon)
	ori_lat = tonumber(ori_lat)
	if (out_china(ori_lat, ori_lon)) then
		return ori_lon, ori_lat
	end

	local lat = transform_lat(ori_lon - 105.0, ori_lat - 35.0)
	local lon = transform_lon(ori_lon - 105.0, ori_lat - 35.0)
	local ralat = ori_lat / 180.0 * M_PI
	local magic = LIB_MATH_SIN(ralat)
	magic = 1 - M_EE * magic * magic
	local sqrt_magic = LIB_MATH_SQRT(magic)
	lat = (lat * 180.0) / ((M_A * (1 - M_EE)) / (magic * sqrt_magic) * M_PI)
	lon = (lon * 180.0) / (M_A / sqrt_magic * LIB_MATH_COS(ralat) * M_PI)
	return ori_lon+lon, ori_lat+lat
end
--火星转地球算法

local  function delta(lat, lng) 
        local  a = 6378245.0;
        local  ee = 0.00669342162296594323;
        local  dLat = transform_lat(lng-105.0, lat-35.0);
        local  dLng = transform_lon(lng-105.0, lat-35.0);
        local  radLat = lat / 180.0 * M_PI;
        local  magic = math.sin(radLat);
        magic = 1 - ee*magic*magic;
        local  sqrtMagic = math.sqrt(magic);
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
        dLng = (dLng * 180.0) / (a / sqrtMagic * math.cos(radLat) * M_PI);
        return {lat = dLat, lng = dLng}
end
--算法1
local  function gcj2wgs(gcjLat, gcjLng) 
        if (out_china(gcjLat, gcjLng)) then
                return {lat = gcjLat, lng = gcjLng}
        end
        local  d = delta(gcjLat, gcjLng);
        return {lat = gcjLat - d['lat'], lng = gcjLng - d['lng']}
end
local  function wgs2gcj(wgsLat, wgsLng) 
        if (out_china(wgsLat, wgsLng)) then
                return {lat = wgsLat, lng = wgsLng}
        end
        local  d = delta(wgsLat, wgsLng);
        return {lat = wgsLat + d.lat, lng = wgsLng + d.lng}
end
--算法2
function gcj2wgs_exact(gcjLat, gcjLng) 
        local initDelta = 0.01
        local threshold = 0.000001
        local dLat ,dLng = initDelta,initDelta
        local mLat ,mLng = gcjLat-dLat, gcjLng-dLng
        local pLat ,pLng = gcjLat+dLat, gcjLng+dLng
        local wgsLat, wgsLng
        local i = 1
        for i = 1,30 do
                wgsLat = (mLat+pLat)/2
                wgsLng = (mLng+pLng)/2
                local  tmp = wgs2gcj(wgsLat, wgsLng)
                dLat = tmp.lat-gcjLat
                dLng = tmp.lng-gcjLng
                if ((math.abs(dLat) < threshold) and (math.abs(dLng) < threshold)) then
                        return wgsLat,wgsLng
                end
                if (dLat > 0) then
                        pLat = wgsLat
                else 
                        mLat = wgsLat
                end
                if (dLng > 0) then
                        pLng = wgsLng
                else 
                        mLng = wgsLng
                end
        end
        return wgsLat,wgsLng
end
--百度转火星
function bd_decrypt(bd_lat,bd_lon)
    local x = bd_lon - 0.0065
    local y = bd_lat - 0.006
    local z = math.sqrt(x * x + y * y) - 0.00002 * math.sin(y * M_PI)
    local theta = math.atan2(y, x) - 0.000003 * math.cos(x * M_PI)
    local tb = {}
    local gg_lon = z * math.cos(theta)
    local gg_lat = z * math.sin(theta)
    return gg_lat,gg_lon
end
--[[=================================MAPS FUNCTION=======================================]]--
--[[
生成以中心点为中心的四方形经纬度  
lat 纬度  
lon 精度  
raidus 半径（以米为单位）
]]--
function get_around(lat,lon,raidus)
        local latitude = lat;    
        local longitude = lon;    
    
        local degree = (24901 * 1609) / 360.0;    
        local raidusMile = raidus;    
    
        local dpmLat = 1 / degree;    
        local radiusLat = dpmLat * raidusMile;    
        local minLat = latitude - radiusLat;    
        local maxLat = latitude + radiusLat;    
    
        local mpdLng = degree * math.cos(latitude * (M_PI / 180));    
        local dpmLng = 1 / mpdLng;                 
        local radiusLng = dpmLng * raidusMile;     
        local minLon = longitude - radiusLng;      
        local maxLon = longitude + radiusLng;      
        return minLat, minLon, maxLat, maxLon 
end
function five_thousandths_grid_get(min_lat, min_lon, max_lat, max_lon)
	min_lat = math.floor(min_lat*1000) >= math.floor(min_lat*100)*10 + 5 and math.floor(min_lat*100)*10 + 5 or math.floor(min_lat*100)*10 
	max_lat = math.floor(max_lat*1000) >= math.floor(max_lat*100)*10 + 5 and math.floor(max_lat*100)*10 + 5 or math.floor(max_lat*100)*10 
	min_lon = math.floor(min_lon*1000) >= math.floor(min_lon*100)*10 + 5 and math.floor(min_lon*100)*10 + 5 or math.floor(min_lon*100)*10 
	max_lon = math.floor(max_lon*1000) >= math.floor(max_lon*100)*10 + 5 and math.floor(max_lon*100)*10 + 5 or math.floor(max_lon*100)*10 
        --min_lat, max_lat, min_lon, max_lon = math.floor(min_lat*1000),math.floor(max_lat*1000),math.floor(min_lon*1000),math.floor(max_lon*1000)
        local grid = {}
        local i = 1
        for lon = min_lon, max_lon, 5 do
                for lat = min_lat, max_lat, 5  do
                        grid[i] = lon .. "&" ..lat
                        i = i + 1
                end
        end
        return grid
end

function grid_get(min_lat, min_lon, max_lat, max_lon)
	min_lat = math.floor(min_lat*100)         
	max_lat = math.floor(max_lat*100) 
        min_lon = math.floor(min_lon*100) 
        max_lon = math.floor(max_lon*100) 
        --min_lat, max_lat, min_lon, max_lon = math.floor(min_lat*1000),math.floor(max_lat*1000),math.floor(min_lon*1000),math.floor(max_lon*1000)
        local grid = {}
        local i = 1
        for lon = min_lon, max_lon, 1 do
                for lat = min_lat, max_lat, 1  do
                        grid[i] = string.format("%d&%d", lon, lat)
                        i = i + 1
                end
        end
        return grid
end
-- <summary>
-- 计算两点之间的位置方向角
-- </summary>
-- <param name="dX1">开始点的x值</param>
-- <param name="dY1">开始点的y值</param>
-- <param name="dX2">结束点的x值</param>
-- <param name="dY2">结束点的y值</param>
function CalculateTwoPointsAngle(dX1, dY1, dX2, dY2)
	local dTolerance = 0.00001
	if LIB_MATH_ABS(dX1 - dX2) < dTolerance then
		if dY2 > dY1 then
			return 0.0
		else
			return 180.0
		end
	elseif  LIB_MATH_ABS(dY1 - dY2) < dTolerance then
		if dX2 > dX1 then
			return 90.0
		else
			return 270.0
		end
	else
		local dResult = (LIB_MATH_ATAN((dX2 - dX1) / (dY2 - dY1))) * 180.0 / M_PI
		if (dX1 < dX2) and (dY1 > dY2) then
			return dResult + 180.0
		elseif (dX1 > dX2) and (dY1 > dY2) then
			return dResult + 180.0
		elseif (dX1 > dX2) and (dY1 < dY2) then
			return dResult + 360.0
		else
			return dResult
		end
	end
end
--点到线的距离，A，B为map点，P为语镜点
function point_to_line_dist(Ax, Ay, Bx, By, Px, Py)
	local a = By - Ay
	local b = Ax - Bx
	local c = Bx * Ay - Ax * By
	local d = LIB_MATH_ABS(a * Px + b * Py + c) / LIB_MATH_SQRT(a * a + b * b)
	return d
end

function get_two_point_dist(F_lat, F_lon, T_lat, T_lon) ---先判断是否相同
        if F_lon == T_lon and  F_lat == T_lat then
		return 0
	end
	local dist = EARTH_RADIUS*math.acos(LIB_MATH_SIN(F_lat/57.2958)*LIB_MATH_SIN(T_lat/57.2958)+LIB_MATH_COS(F_lat/57.2958)*LIB_MATH_COS(T_lat/57.2958)*LIB_MATH_COS((F_lon-T_lon)/57.2958)) *1000
	if not dist or tostring(dist) == "nan" then 
	        dist = 0
	end
	--only.log('D', string.format("dist %d", dist))
        return dist
end
function compute_distance_point_to_line(cur_B, cur_L, next_B, next_L, mirr_B, mirr_L, length)
	local a = get_two_point_dist(mirr_B, mirr_L, cur_B, cur_L)
	local b = get_two_point_dist(mirr_B, mirr_L, next_B, next_L)
	local c = length or get_two_point_dist(cur_B, cur_L, next_B, next_L)
	local p = (a+b+c)/2
        local dist = 2*LIB_MATH_SQRT(LIB_MATH_ABS(p*(p - a)*(p-b)*(p -c)))/c
	--only.log('D', string.format("a %d b %d c %d", a, b, c))
	-->check overstep line
	return (math.abs(a*a-b*b) > c*c) and ((a > b) and b or a) or dist
end

function map_point_to_line_dist(cur_B, cur_L, next_B, next_L, mirr_B, mirr_L, length)
	local a = get_two_point_dist(mirr_B, mirr_L, cur_B, cur_L)
	local b = get_two_point_dist(mirr_B, mirr_L, next_B, next_L)
	local c = length or get_two_point_dist(cur_B, cur_L, next_B, next_L)
	local p = (a+b+c)/2
        local dist = 2*LIB_MATH_SQRT(LIB_MATH_ABS(p*(p - a)*(p-b)*(p -c)))/c
	--only.log('D', string.format("a %d b %d c %d", a, b, c))
	return dist, math.abs(a*a-b*b) > c*c
end
---计算点到线段的距离
function GetPointDistance(p1x, p1y, p2x, p2y)-- 地图线的两个端点 

	return LIB_MATH_SQRT((p1x-p2x)*(p1x-p2x)+(p1y-p2y)*(p1y-p2y))  
end
--点到线的距离，A，B为map点，P为语镜点
function GetNearestDistance(Ax, Ay, Bx, By, Px, Py)

	local AP,BP,AB,l,s = 1
	local AP=GetPointDistance(Ax,Ay,Px,Py)  
	if AP<=1 then 
		return 0 ,1 
	end
	local BP=GetPointDistance(Bx,By,Px,Py)  
	if BP<=1 then
		return 0 ,2
	end
	local AB=GetPointDistance(Ax,Ay,Bx,By)  
	if AB<=1  then --如果PA和PB坐标相同，则退出函数，并返回距离
		return AP ,3 
	end  
	if AP*AP>=BP*BP+AB*AB then --如果是钝角返回BP
		return BP,4
	end
	if BP*BP>=AP*AP+AB*AB  then --如果是钝角返回AP
		return AP,4
	end
	local l=(AP+BP+AB)/2      --周长的一半  
	local s=LIB_MATH_SQRT(l*(l-AP)*(l-BP)*(l-AB))   --海伦公式求面积，也可以用矢量求  
	return 2*s/AB, 5

end

function get_roadID_roadName_form_mapabc(latitude, longitude)
	local gaode_key = 'ebfae93ca717a7dc45f6f4962c6465993808dbdadd8b280f412c4e22db13145e647323bd421ac59c'
	local http_fmt = 'GET /sisserver?config=SPAS&enc=utf-8&spatialXml=%s&a_k=%s HTTP/1.0\r\nConnection: Keep-Alive\r\nHost:search1.mapabc.com:80\r\n\r\n'
	--local http_fmt = 'GET /sisserver?config=SPAS&enc=utf-8&spatialXml=%s&a_k=%s HTTP/1.0\r\nConnection: close\r\nHost: search1.mapabc.com:80\r\n\r\n'
	local xml_fmt = '<?xml version="1.0" encoding="utf-8"?>\n<spatial_request method="searchPoint">\n <x>%s</x>\n <Y>%s</Y>\n <poiNumber>0</poiNumber>\n <range>100</range>\n <pattern>0</pattern>\n <roadLevel>0</roadLevel>\n</spatial_request>'
	local xml_str = LIB_STRING_FORMAT(xml_fmt, tostring(longitude), tostring(latitude))

	local url_xml = utils.url_encode(xml_str)
	local get_request = LIB_STRING_FORMAT(http_fmt, url_xml, gaode_key)
	local ret = http_api.http({host = 'search1.mapabc.com', port = 80}, get_request, true)--fixme
	--only.log('D', ret)
	local road_name,road_id
	local k,q = LIB_STRING_FIND(tostring(ret),'<Road ver=')	
	if k then
		local road = LIB_STRING_SUB(ret,k,-4)
		--get roadName
		i, j = LIB_STRING_FIND(road, '<name>')
		k, q = LIB_STRING_FIND(road, '</name>')
		road_name = LIB_STRING_SUB(road, j + 1, k - 1)

		--get roadID
		i, j = LIB_STRING_FIND(road, '<id>')
		k, q = LIB_STRING_FIND(road, '</id>')
		road_id = LIB_STRING_SUB(road, j + 1, k - 1)
		if road_id == nil then
			return "0","new_road"
		else	
			return road_id,road_name
		end
	else
		return "0","newroad"
	end
end
