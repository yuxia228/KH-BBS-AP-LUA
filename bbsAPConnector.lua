LUAGUI_NAME = "bbsAPConnector"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "BBS FM AP Connector"

game_version = 1 --1 for 1.0.0.9 EGS, 2 for Steam
IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false

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
    if can_execute then
    end
end

function _OnFrame()
    write_worlds({1,0,0,0,0,0,0,0,0,0,1,0,0})
end