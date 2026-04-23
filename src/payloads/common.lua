-- Target File: Scripts/Speech/common.lua
-- Purpose: Disables the player character's voice directory to mute their radio calls.
-- This ensures that no audio is played for the player's own voice lines.

-- [DCS MUTER INJECT START]
if base and base.common and base.common.role then
    if base.common.role.PLAYER then
        base.common.role.PLAYER.dir = 'DISABLED_Player'
    end
    if base.common.role.PLAYER_NAVY then
        base.common.role.PLAYER_NAVY.dir = 'DISABLED_Player'
    end
end
-- [DCS MUTER INJECT END]
