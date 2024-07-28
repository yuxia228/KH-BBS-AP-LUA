LUAGUI_NAME = "bbsAPRemoveItem"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "BBS FM AP Remove Item"

game_version = 1 --1 for 1.0.0.9 EGS, 2 for Steam
IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false

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
    queue_address = {0x0, 0x10FA2A4A}
    i = 0
    while ReadShort(queue_address[game_version] + (i*4)) ~= 0 and i < 24 do
        if ReadShort(queue_address[game_version] + (i*4)+2) == 0x1F1B then
            WriteInt(queue_address[game_version], 0x0)
        end
        i = i + 1
    end
end