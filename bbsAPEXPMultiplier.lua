LUAGUI_NAME = "bbsAPEXPMultiplier"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "BBS FM AP EXP Multiplier"

game_version = 1 --1 for 1.0.0.9 EGS, 2 for Steam
IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false

exp_mult = 10
mult_applied = false

-------------------------------------------------------------------------
function _OnInit()
    if ReadByte(IsEpicGLVersion) == 0xFF then
        game_version = 1
        ConsolePrint("EGS Version Detected")
        can_execute = true
    end
    if ReadByte(IsSteamGLVersion) == 0xFF then
        game_version = 2
        ConsolePrint("Steam Version Detected")
        can_execute = true
    end
end

function _OnFrame()
    if can_execute then
        to_next_level_table_address = {0x649724, 0x6485F4}
        if not exp_mult ~= 1 and ReadInt(to_next_level_table_address[game_version]) == 90 then
            for i=1,99 do
                to_next_level_address = to_next_level_table_address[game_version] + ((i-1)*4)
                WriteInt(to_next_level_address, math.ceil(ReadInt(to_next_level_address)/exp_mult))
            end
        end
    end
end