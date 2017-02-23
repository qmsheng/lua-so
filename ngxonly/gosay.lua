local utils = require('utils')
local only = require('only')
local ngx = require('ngx')
local APP_CFG = require('cfg')
local perf = require('perf')

module('gosay', package.seeall)

local stat_log_file_time = { }
local stat_log_file_desc = { }

local cr_lf_tab = {
    ['\r\n'] = '[\\r\\n]',
    ['\n'] = '[\\n]',
}

function flush_stat_log(url_info)

    ---- 是否关闭日志 2014-08-13 jiang z.s. 
    ---- 避免日志文件太大,影响写日志文件性能
    if not APP_CFG["OWN_INFO"]["STATLOG"] then return true end


    local file_name = url_info['type_name']
    local log_path = ngx.var.LOG_FILE_PATH
    log_path = log_path or '/tmp/'
    if not stat_log_file_time[ file_name ] then
        stat_log_file_time[ file_name ] = os.date('%Y%m%d')
        local file_path = string.format('%sstatistic_%s_%s.log', log_path, file_name, stat_log_file_time[ file_name ])
        stat_log_file_desc[ file_name ] = assert(io.open(file_path, 'a'))
    end

    if stat_log_file_time[ name ] ~= os.date('%Y%m%d') then
        stat_log_file_desc[ file_name ]:close()
        stat_log_file_time[ file_name ] = os.date('%Y%m%d')
        local file_path = string.format('%sstatistic_%s_%s.log', log_path, file_name, stat_log_file_time[ file_name ])
        stat_log_file_desc[ file_name ] = assert(io.open(file_path, 'a'))
    end

    local cli_body, resp_body = url_info['client_body'], url_info['response_body']
    if cli_body then
        cli_body = string.gsub(cli_body, '%c%c?', cr_lf_tab)
    end
    if resp_body then
        resp_body = string.gsub(url_info['response_body'], '%c%c?', cr_lf_tab)
    end

    local api_name = ngx.var.API_NAME
    local lg = string.format("%s --> %s@%s---->%s:::%s___%s\n", os.date('%Y%m%d_%H%M%S'), url_info['app_key'], url_info['client_host'], api_name, cli_body, resp_body)

    stat_log_file_desc[ file_name ]:write(lg)
    stat_log_file_desc[ file_name ]:flush()

end

function respond_to_device(status, url_info, is_statlog)
    --[[
    if not status then
        ngx.status = ngx.HTTP_BAD_REQUEST
    else
        ngx.status = ngx.HTTP_OK
    end
    --]]

    if is_statlog then
        flush_stat_log(url_info)
    end
    
    if not status then
        perf.cost("WHOLE FAILURE", false)
    else
        perf.cost("WHOLE SUCCESS", false)
        ngx.status = ngx.HTTP_OK
    end

    ngx.say(url_info['response_body'])

    ngx.flush()
    ngx.exit(ngx.HTTP_OK)
end

function go_false(url_info, msg, result)
    local out_msg, info
    if not result then
        info = msg[2]
    else
        info = string.format(msg[2], result)
    end

    out_msg = string.format('{"ERRORCODE":"%s", "RESULT":"%s"}', msg[1], info )
    url_info['response_body'] = out_msg

    respond_to_device(false, url_info, true)

    return
end

function go_success(url_info, msg, result)
    local out_msg, info
    if not result then
        info = msg[2]
    else
        info = string.format(msg[2], result)
    end

    local star = string.sub(info, 1, 1)
    if star == '[' or star == '{' then
        out_msg = string.format('{"ERRORCODE":"%s", "RESULT":%s}', msg[1], info )
    else
        out_msg = string.format('{"ERRORCODE":"%s", "RESULT":"%s"}', msg[1], info )
    end

    url_info['response_body'] = out_msg

    respond_to_device(true, url_info, true)

    return
end

function go_success_without_log(url_info, msg, result)
    local out_msg, info
    if not result then
        info = msg[2]
    else
        info = string.format(msg[2], result)
    end

    local star = string.sub(info, 1, 1)
    if star == '[' or star == '{' then
        out_msg = string.format('{"ERRORCODE":"%s", "RESULT":%s}', msg[1], info )
    else
        out_msg = string.format('{"ERRORCODE":"%s", "RESULT":"%s"}', msg[1], info )
    end

    url_info['response_body'] = out_msg

    respond_to_device(true, url_info, false)

    return
end


---- 仅仅返回状态码
function respond_to_status(url_info, status)
    if not status or status == false then
        ngx.status = ngx.HTTP_BAD_REQUEST
        url_info['response_body']  = 'http 400'
    else
        ngx.status = ngx.HTTP_OK
        url_info['response_body']  = 'http 200'
    end

    flush_stat_log(url_info)
    ngx.flush()
    ngx.exit(ngx.status)
end


---- 返回状态码200 + json_str
function respond_to_json_str(url_info, json_str)
    url_info['response_body']  = json_str
    flush_stat_log(url_info)
    ngx.say(json_str)
    ngx.flush()
    ngx.exit(ngx.HTTP_OK)
end

---- 返回状态码200 + binary
function respond_to_binary(url_info, binary)
    flush_stat_log(url_info)
    ngx.say(binary)
    ngx.flush()
    ngx.exit(ngx.HTTP_OK)
end

---- 仅仅返回555 
function respond_to_httpstatus(url_info, httpstatus)
    ngx.status = httpstatus
    url_info['response_body']  = httpstatus
    flush_stat_log(url_info)
    ngx.flush()
    ngx.exit(ngx.status)
end
