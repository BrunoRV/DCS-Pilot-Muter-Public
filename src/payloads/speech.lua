-- Target File: Scripts/Speech/speech.lua
-- Purpose: Overrides the 'make' function to force a short duration for player radio messages.
-- This effectively mutes the player's voice while ensuring the game still processes the radio events.

-- [DCS MUTER INJECT START]
local _original_make = make

function make(message)
    local result = _original_make(message)
    
    -- If the event is triggered by the player character, override the audio playback duration to simulate a short radio silence
    if result and message and message.sender == base.world.getPlayer() then
        result.duration = 1.0
    end
    
    return result
end
-- [DCS MUTER INJECT END]
