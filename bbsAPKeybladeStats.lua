LUAGUI_NAME = "bbsAPKeybladeStats"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "Kingdom Hearts BBS AP Integration"

game_version = 1 --1 for ESG 1.0.0.9, 2 for Steam 1.0.0.9

local keyblade_stats_base_address = {0x0, 0x818AEC}

IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false
frame_count = 0

if os.getenv('LOCALAPPDATA') ~= nil then
    client_communication_path = os.getenv('LOCALAPPDATA') .. "\\KHBBSFMAP\\"
else
    client_communication_path = os.getenv('HOME') .. "/KHBBSFMAP/"
    ok, err, code = os.rename(client_communication_path, client_communication_path)
    if not ok and code ~= 13 then
        os.execute("mkdir " .. path)
    end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function read_keyblade_stats()
    if file_exists(client_communication_path .. "keyblade_stats.cfg") then
        file = io.open(client_communication_path .. "keyblade_stats.cfg", "r")
        io.input(file)
        keyblade_stats = split(io.read(),",")
        io.close(file)
        return keyblade_stats
    elseif file_exists(client_communication_path .. "Keyblade Stats.cfg") then
        file = io.open(client_communication_path .. "Keyblade Stats.cfg", "r")
        io.input(file)
        keyblade_stats = split(io.read(),",")
        io.close(file)
        return keyblade_stats
    else
        return nil
    end
end

function write_keyblade_stats(keyblade_stats)
    i = 1
    j = 0
    while i <= #keyblade_stats do
        str = tonumber(keyblade_stats[i])
        mgc  = tonumber(keyblade_stats[i+1])
        WriteByte(keyblade_stats_base_address[game_version] + (12 * j), str)
        WriteByte(keyblade_stats_base_address[game_version] + (12 * j) + 1, mgc)
        i = i + 2
        j = j + 1
    end
end

function main()
    keyblade_stats = read_keyblade_stats()
    if keyblade_stats ~= nil and not finished then
        write_keyblade_stats(keyblade_stats)
        finished = true
    end
end

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
    if frame_count == 0 and canExecute then
        main()
    end
    frame_count = (frame_count + 1) % 30
end