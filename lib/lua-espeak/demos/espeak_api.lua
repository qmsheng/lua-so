#!/usr/bin/env lua
-- -*- coding: utf-8 -*-

-- Writes speech to a audio file.
-- (c) 2007 Alexandre Erwin Ittner <aittner@netuno.com.br>
-- Distributed under the GPL v2 or later.

local espeak = require("espeak")
local wave_api = require("wave_api")

local hz = espeak.Initialize(espeak.AUDIO_OUTPUT_SYNCHRONOUS, 0)

if espeak.SetVoiceByName("zh") ~= espeak.EE_OK then
    print("Failed to set default voice.")
    return
end

if not arg[1] then
    print("Syntax: lua test_file.lua <filename>")
    espeak.Terminate()
    return 1
end

local afp = wave_api.init(false, 1, 1, hz, 16)

espeak.SetSynthCallback(function(wave, event)
	print(event.type)
    if event.type == espeak.EVENT_WORD
    or event.type == espeak.EVENT_SENTENCE
    or event.type == espeak.EVENT_END
    or event.type == espeak.EVENT_LIST_TERMINATED
    or event.type == espeak.EVENT_SAMPLERATE then
        afp:feed(wave)
    end
    return false    -- Do not stops the synthesis.
end)

espeak.Synth("小将，你在干什么呀。abc", 0, espeak.POS_CHARACTER, 0, nil)
espeak.Synchronize()

local size,data = afp:over()
local fd = io.open( arg[1], "w+" )
fd:write( data )
fd:close()

espeak.Terminate()

