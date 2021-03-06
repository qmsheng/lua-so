local gosay = require('gosay')
local only = require('only')
local utils = require('utils')
local app_utils = require('app_utils')
local msg = require('msg')
local redis_api = require('redis_pool_api')
local perf = require('perf')

module('safe', package.seeall)

-- caz the access range is reverse
ACCESS_USER_INFO = -1
ACCESS_REAL_TIME_INFO = -2
ACCESS_COLLECT_INFO = -3
ACCESS_DRIVING_INFO = -4
ACCESS_WEIBO_INFO = -5
ACCESS_CROWD_INFO = -6
--绑定解绑设备---2015/4/11--
ACCESS_BINDMIRRTALK_INFO = -7 


local appKey_list = 
{
    [616515395] = "club android",  ----2015-04-24
    [3987311677] = "club (ios)",    ----2015-04-24
    [2982095115] = "myshop android",    ---- 2015-04-24
    [968020642] = "myshop ios",         ---- 2015-04-24 
    [2064302565] = "weixin",
    [286302235] = "weme app",
    [2582535051] =  "八桂物流" ,
    [1612210697] = "道客时速(getLocation)",
    [1928121659] = "CAA",
    [1027395982] = "DJ",
    [3555943163] = "feeding" ,
    [984810830] = "道客商城" ,
    [1220182788] = "帮忙拉项目",
    [184269830] = "WEME_IOSappkey",
    [3656465532] = "TJ",
    [984810830] = "web",
}


function sign_check(args, url_info, auth_argc, access_flag)

    -->> check appKey
    if (not utils.is_number( args["appKey"] )) or #args["appKey"] > 10 then
        gosay.go_false(url_info, msg["MSG_ERROR_REQ_ARG"], 'appKey')
    end
    -->> check sign
    local ok, app_key_info = redis_api.cmd("public", "hmget", args['appKey'] .. ':appKeyInfo', 'secret', 'level', (tostring(args[auth_argc]) or '') .. ':accessToken')
    if not ok then
        gosay.go_false(url_info, msg["MSG_DO_REDIS_FAILED"])
    end
    if #app_key_info==0 then
        gosay.go_false(url_info, msg["MSG_ERROR_REQ_FAILED_GET_SECRET"])
    end
    local ok_sign = app_utils.gen_sign(args, app_key_info[1])
    if args["sign"] ~= ok_sign then
        gosay.go_false(url_info, msg["MSG_ERROR_REQ_SIGN"])
    end

    if args[auth_argc] then

        -- -1 refers the internal api
        if tonumber(app_key_info[2]) == -1 then
            return true
        end

        ---- modify by jiang z.s. 2015-04-24 
        if appKey_list[tonumber(args['appKey'])] then
            return true
        end

        -- this is accountID
        if type(args[auth_argc]) == 'table' then
            -- type is table
            for _, v in ipairs(args[auth_argc]) do
                local ok, ret = redis_pool_api.cmd('public', 'sismember', args['appKey'] .. ':authorizeIMEI', v)
                if not (ok and ret) then
                    gosay.go_false(url_info, msg["MSG_ERROR_ACCESS_TOKEN_NO_AUTH"])
                end
            end
        else


            if #args[auth_argc] == 10 then
                if not args['accessToken'] then
                    gosay.go_false(url_info, msg["MSG_ERROR_REQ_ARG"], 'accessToken')
                end

                local token, time, range = string.match(app_key_info[3] or '', '(.+)_(.+)_(.+)')
                -- check the token
                if token ~= args['accessToken'] then
                    gosay.go_false(url_info, msg["MSG_ERROR_ACCESS_TOKEN_NOT_MATCH"])
                end

                -- check the time
                if tonumber(time) < os.time() then
                    ----modify by jiang z.s. 2014-11-06 
                    redis_api.cmd("public", "hdel", args["appKey"] .. ':appKeyInfo', args[auth_argc] .. ':accessToken')
                    gosay.go_false(url_info, msg["MSG_ERROR_ACCESS_TOKEN_EXPIRE"])
                end

                -- check the range
                if string.sub(range or '', access_flag, access_flag) ~= '1' then
                    gosay.go_false(url_info, msg["MSG_ERROR_ACCESS_TOKEN_NO_AUTH"])
                end
            else
                -- this is IMEI
                local ok, ret = redis_pool_api.cmd('statistic', 'sismember', args['appKey'] .. ':businessIMEI', args[auth_argc])
                if not (ok and ret) then
                    gosay.go_false(url_info, msg["MSG_ERROR_ACCESS_TOKEN_NO_AUTH"])
                end
            end

        end



    end
end

------> only use for handle
function main_call(F, ...)
    -- local info = { pcall(F, ...) }
    -- if not info[1] then
    --     only.log("E", info[2])
    --     gosay.respond_to_device(false, nil)
    -- end
    perf.init()
    F( ... )
end
