-- DCS Pilot Muter Hook
-- This script is loaded by the GUI state and handles injecting the muter payload 
-- into the simulation environment when a mission starts.

local MuterHook = {}

function MuterHook.onMissionLoadEnd()
    -- Path to the payload file in the tech mod folder
    local payloadPath = lfs.writedir() .. "Mods/tech/DCS-Muter/Scripts/MuterPayload.lua"
    
    local f = io.open(payloadPath, "r")
    if f then
        local payload = f:read("*all")
        f:close()
        
        -- Inject the payload into the "server" (simulation) environment
        if net and net.dostring_in then
            net.dostring_in("server", payload)
            net.log("[DCS-Muter] Payload dynamically injected into simulation environment.")
        else
            net.log("[DCS-Muter] ERROR: net.dostring_in is not available.")
        end
    else
        net.log("[DCS-Muter] ERROR: Could not find payload at " .. payloadPath)
    end
end

-- Register the callback
DCS.setUserCallbacks(MuterHook)

net.log("[DCS-Muter] Hook initialized.")
