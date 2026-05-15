-- DCS Pilot Muter Payload
-- This script runs in the simulation environment (server) to mute the player's voice.

(function()
    -- Safely access the global environment
    local env = _G
    if env.base then env = env.base end
    
    -- 1. Mute Player Voice Directory (from original common.lua payload)
    if env.common and env.common.role then
        if env.common.role.PLAYER then 
            env.common.role.PLAYER.dir = 'DISABLED_Player' 
        end
        if env.common.role.PLAYER_NAVY then 
            env.common.role.PLAYER_NAVY.dir = 'DISABLED_Player' 
        end
    end

    -- 2. Override 'make' function for radio messages (from original speech.lua payload)
    -- We use base.world.getPlayer() to identify the player message.
    if env.make then
        local _original_make = env.make
        env.make = function(message)
            local result = _original_make(message)
            
            -- If we can verify this is a player message, force short duration
            if result and message and message.sender and env.world and message.sender == env.world.getPlayer() then
                result.duration = 1.0
            end
            
            return result
        end
    end
end)()
