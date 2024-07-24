LUAGUI_NAME = "bbsAPShop"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "BBS FM AP Shop Updater"

game_version = 1 --1 for 1.0.0.9 EGS, 2 for Steam
IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false
frame_count = 0
item_index = 1
shop_table = {188, 189, 190, 191, 192, 193, 194, 195, 196}
update = false

if os.getenv('LOCALAPPDATA') ~= nil then
    client_communication_path = os.getenv('LOCALAPPDATA') .. "\\KHBBSFMAP\\"
else
    client_communication_path = os.getenv('HOME') .. "/KHBBSFMAP/"
    ok, err, code = os.rename(client_communication_path, client_communication_path)
    if not ok and code ~= 13 then
        os.execute("mkdir " .. path)
    end
end

function value_in_table(check_table, check_value)
    for k,v in pairs(check_table) do
        if check_value == v then
            return true
        end
    end
    return false
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
    frame_count = (frame_count + 1) % 120
    if can_execute and frame_count == 0 then
        while file_exists(client_communication_path .. "AP_" .. tostring(item_index) .. ".item") do
            file = io.open(client_communication_path .. "AP_" .. tostring(item_index) .. ".item", "r")
            io.input(file)
            received_item_id = tonumber(io.read())
            io.close(file)
            if received_item_id >= 2270010000 and received_item_id <= 2270010210 then
                item_value = received_item_id % 2270010000
                item_value = item_value + 0x5B
                if not value_in_table(shop_table, item_value) then
                    shop_table[#shop_table] = item_value
                    update = true
                end
            end
        end
        if update then
            shop_address_pointer_address = {0x0, 0x29DC588}
            if ReadInt(shop_address_pointer_address[game_version]) > 0 then
                shop_address_pointer_offset_1 = 0x80
                shop_address_pointer_offset_2 = 0xE58
                shop_address = GetPointer(shop_address_pointer_address, shop_address_pointer_offset_1)
                shop_address = GetPointer(shop_address, shop_address_pointer_offset_2, true)
                WriteInt(shop_address, #shop_table, true)
                for i=1,88
                    if shop_table[i] ~= nil
                        WriteInt(shop_address + (i*4), shop_table[i])
                    else
                        WriteInt(shop_address + (i*4), 0)
                    end
                end
                update = false
            end
        end
    end
end