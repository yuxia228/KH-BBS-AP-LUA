LUAGUI_NAME = "bbsAPConnector"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "BBS FM AP Connector"

game_version = 1 --1 for 1.0.0.9 EGS, 2 for Steam
IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false

worlds_unlocked_array = {1,0,0,0,0,0,0,0,0,0,0,0,0}

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

function toBits(num, zeroes)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    for i=1,8 do
        if t[i] == nil then
            t[i] = 0
        end
    end
    for i=1,zeroes do
        if t[i] == nil then
            t[i] = 0
        end
    end
    return t
end

function toNum(bits)
    --returns a number previously represented by bits
    num = 0
    for i=1,#bits do
        if bits[i] == 1 then
            num = num + (2^(i-1))
        end
    end
    return num
end

function write_key_item(item_value)
    --Writes key item to the player's inventory
    key_item_stock_address = {0x0, 0x10FA2AAC}
    max_items = 25
    item_index = 0
    duplicate = false
    while ReadShort(key_item_stock_address[game_version] - (2 * item_index)) ~= 0 and item_index < max_items and not duplicate do
        if ReadShort(key_item_stock_address[game_version] - (2 * item_index)) == item_value then
            duplicate = true
        end
        item_index = item_index + 1
    end
    if item_index < max_items and not duplicate then
        WriteShort(key_item_stock_address[game_version] - (2 * item_index), item_value)
    end
end

function write_command(command_value)
    --Writes command to the player's inventory
    command_stock_address = {0x0, 0x10FA2C88}
    max_commands = 99
    command_index = 0
    while ReadShort(command_stock_address[game_version] + (10 * command_index)) ~= 0 and command_index < max_commands do
        command_index = command_index + 1
    end
    if command_index < max_commands then
        WriteShort(command_stock_address[game_version] + (10 * command_index) + 0, command_value) --Write Command
        WriteShort(command_stock_address[game_version] + (10 * command_index) + 2, 1) --Write Level
        WriteShort(command_stock_address[game_version] + (10 * command_index) + 4, 0) --Write Experience
        WriteShort(command_stock_address[game_version] + (10 * command_index) + 6, 0) --Write Ability
        WriteShort(command_stock_address[game_version] + (10 * command_index) + 8, 0) --Write Flags
    end
end

function write_dlink(dlink_value)
    --Writes d-link to the player's inventory
    dlinks_address = {0x0, 0x10FA4EB4}
    dlink_index = 0
    duplicate = false
    while ReadShort(dlinks_address[game_version] + (8 * dlink_index)) ~= 0 do
        if ReadShort(dlinks_address[game_version] + (8 * dlink_index)) == dlink_value then
            duplicate = true
        end
        dlink_index = dlink_index + 1
    end
    if not duplicate then
        WriteShort(dlinks_address[game_version] + (8 * dlink_index) + 0, dlink_value) --Write D-Link
        WriteShort(dlinks_address[game_version] + (8 * dlink_index) + 2, 0x8000) --Write ??
        WriteShort(dlinks_address[game_version] + (8 * dlink_index) + 4, 0) --Write ??
        WriteShort(dlinks_address[game_version] + (8 * dlink_index) + 6, 0) --Write ??
    end
end

function write_ability(ability_offset)
    --Write ability to the player's ability array
    abilities_address = {0x0, 0x10FA4554}
    ability_byte_1 = ReadByte(abilities_address[game_version] + (ability_offset-1) * 4)
    ability_byte_2 = ReadByte((abilities_address[game_version] + (ability_offset-1) * 4)+1)
    ability_bits_1 = toBits(ability_byte_1, 8)
    ability_bits_2 = toBits(ability_byte_2, 8)
    number_permanantly_available = toNum({ability_bits_1[7], ability_bits_1[8], ability_bits_2[1]})
    if number_permanantly_available < 7 then
        number_permanantly_available = number_permanantly_available + 1
    end
    number_permanantly_available_bits = toBits(number_permanantly_available, 3)
    ability_bits_1[7] = number_permanantly_available_bits[1]
    ability_bits_1[8] = number_permanantly_available_bits[2]
    ability_bits_2[1] = number_permanantly_available_bits[3]
    ability_bits_2[7] = 1
    ability_byte_1 = toNum(ability_bits_1)
    ability_byte_2 = toNum(ability_bits_2)
    WriteByte(abilities_address[game_version] + (ability_offset-1) * 4, ability_byte_1)
    WriteByte((abilities_address[game_version] + (ability_offset-1) * 4)+1, ability_byte_2)
end

function write_command_style(command_style_offset)
    --Writes command style to a players command style array
    command_style_address = {0x0, 0x10FA45CC}
    WriteByte(command_stock_address[game_version]+command_style_offset, 0x05)
end

function write_worlds(worlds_array)
    world_open_address = {0x0, 0x10F9F7F0 + 0x2938}
    world_open_values = {
        0x00002002, --LOD
        0x00000102, --DW
        0x00000102, --COD
        0x00000102, --ED
        0x00000102, --MT
        0x00000102, --RG
        0x00000000, --Unused
        0x00000102, --OC
        0x00000102, --DS
        0x00000802, --DI
        0x00000102, --NL
        0x00000102, --DT
        0x00000102  --KG
        }
    for world_offset, world_value in pairs(worlds_array) do
        if world_value == 0 then
            WriteInt(world_open_address[game_version] + (4 * (world_offset-1)), 0)
        elseif ReadInt(world_open_address[game_version] + (4 * (world_offset-1))) ~= world_open_values[world_offset] then
            WriteInt(world_open_address[game_version] + (4 * (world_offset-1)), world_open_values[world_offset])
        end
    end
end

function write_check_number(value)
    check_number_address = {0x0, 0x10FA1D20}
    WriteInt(check_number_address[game_version], value)
end

function write_max_hp(value)
    max_hp_pointer_address = {0x0, 0x10F9DDC0}
    max_hp_pointer_offset_1 = 0x118
    max_hp_pointer_offset_2 = 0x398
    max_hp_pointer_offset_3 = 0xA4
    max_hp_pointer = GetPointer(max_hp_pointer_address[game_version], max_hp_pointer_offset_1)
    max_hp_pointer = GetPointer(max_hp_pointer, max_hp_pointer_offset_2, true)
    max_hp_pointer = GetPointer(max_hp_pointer, max_hp_pointer_offset_3, true)
    WriteInt(max_hp_pointer, value, true)
end

function write_deck_capacity(value)
    deck_capacity_address = {0x0, 0x10F9DE66}
    WriteByte(deck_capacity_address[game_version], math.min(value, 8))
end

function write_world_item(world_offset)
    if world_offset <= 12 then
        ap_bits_address = {0x0, 0x10FA1D1C}
        address_offset = math.floor(world_offset / 8)
        bit_num = (world_offset % 8) + 1
        ap_byte = ReadByte(ap_bits_address[game_version] + address_offset)
        ap_bits = toBits(ap_byte, 8)
        ap_bits[world_offset+1] = 1
        WriteByte(ap_bits_address[game_version] + address_offset, toNum(ap_bits))
    end
end

function write_victory_item()
    ap_bits_address = {0x0, 0x10FA1D1D}
    ap_byte = ReadByte(ap_bits_address[game_version])
    ap_bits = toBits(ap_byte, 8)
    ap_bits[6] = 1
    WriteByte(ap_bits_address[game_version], toNum(ap_bits))
end

function read_check_number()
    check_number_address = {0x0, 0x10FA1D20}
    return ReadInt(check_number_address[game_version])
end

function read_max_hp()
    max_hp_pointer_address = {0x0, 0x10F9DDC0}
    max_hp_pointer_offset_1 = 0x118
    max_hp_pointer_offset_2 = 0x398
    max_hp_pointer_offset_3 = 0xA4
    max_hp_pointer = GetPointer(max_hp_pointer_address[game_version], max_hp_pointer_offset_1)
    max_hp_pointer = GetPointer(max_hp_pointer, max_hp_pointer_offset_2, true)
    max_hp_pointer = GetPointer(max_hp_pointer, max_hp_pointer_offset_3, true)
    return ReadInt(max_hp_pointer, true)
end

function read_deck_capacity()
    deck_capacity_address = {0x0, 0x10F9DE66}
    return WriteByte(deck_capacity_address[game_version])
end

function read_chest_location_ids()
    location_ids = {}
    chests_opened_address = {0x0, 0x10FA2B7C}
    chests_opened_array = ReadArray(chests_opened_address[game_version], 26)
    for chest_index, chest_byte in pairs(chests_opened_array) do
        chest_bits = toBits(chest_byte, 8)
        for i=1,8 do
            if chest_bits[i] == 1 then
                location_ids[#location_ids] = 2271200000 + ((chest_index-1)*10) + i
            end
        end
    end
    return location_ids
end

function receive_items()
    i = read_check_count() + 1
    while file_exists(client_communication_path .. "AP_" .. tostring(i) .. ".item") do
        file = io.open(client_communication_path .. "AP_" .. tostring(i) .. ".item", "r")
        io.input(file)
        received_item_id = tonumber(io.read())
        io.close(file)
        if received_item_id == 2270000000 then
            write_victory_item()
        elseif received_item_id >= 2270010000 and received_item_id <= 2270010209 then
            item_value = received_item_id % 2270010000
            write_command(item_value)
        elseif received_item_id >= 2270020000 and received_item_id <= 2270020014 then
            item_value = received_item_id % 2270020000
            write_command_style(item_value)
        elseif received_item_id >= 2270030000 and received_item_id <= 2270030029 then
            item_value = received_item_id % 2270030000
            write_ability(item_value)
        elseif received_item_id >= 2270040001 and received_item_id <= 2270047967 then
            item_value = received_item_id % 2270040000
            write_key_item(item_value)
        elseif received_item_id >= 2270050000 and received_item_id <= 2270050013 then
            item_value = received_item_id % 2270050000
            write_world_item(item_value)
        elseif received_item_id == 2270060000 then
            write_max_hp(read_max_hp() + 5)
        elseif received_item_id == 2270060001 then
            write_deck_capacity(read_deck_capacity() + 1)
        end
        i = i + 1
    end
    write_check_number(i-1)
end

function send_items()
    chest_location_ids = read_chest_location_ids()
    for location_index, location_id in pairs(chest_location_ids) do
        if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
            file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
            io.output(file)
            io.write("")
            io.close(file)
        end
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
    write_worlds({1,0,0,0,0,0,0,0,0,0,1,0,0})
    send_items()
end