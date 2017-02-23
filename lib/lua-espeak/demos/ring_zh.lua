
require "espeak"

local text = "你妹"

espeak.Initialize(espeak.AUDIO_OUTPUT_PLAYBACK, 500)

if espeak.SetVoiceByName("zh") ~= espeak.EE_OK then
    print("Failed to set default voice.")
    return
end

espeak.Synth(text, 0, espeak.POS_WORD, 0, nil)

espeak.Synchronize()
espeak.Terminate()

