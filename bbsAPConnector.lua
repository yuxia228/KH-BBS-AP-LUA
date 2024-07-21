LUAGUI_NAME = "bbsAPConnector"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "BBS FM AP Connector"

game_version = 1 --1 for 1.0.0.9 EGS, 2 for Steam
IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false
frame_count = 0

function define_world_progress_location_bits()
    world_progress_location_bits = {}
    world_progress_location_bits[0] = {} --Ventus
    world_progress_location_bits[1] = {} --Aqua
    world_progress_location_bits[2] = {} --Terra
    for k=0,2 do
        for i=1,14 do
            world_progress_location_bits[k][i] = {}
            for j=1,16 do
                world_progress_location_bits[k][i][j] = {}
            end
        end
    end
    --Ventus
    --The Land of Departure
    world_progress_location_bits[0][1][14]  = {2271020000, 2271020001} --Max HP Increase, Fever Pitch
    world_progress_location_bits[0][1][16]  = {2271020002, 2271020003, 2271020004, 2271020005} --Aqua D-Link, Terra D-Link, Xehanort's Letter, Keyblade Board
    --Dwarf Woodlands
    world_progress_location_bits[0][2][12]  = {2271020100} --Max HP Increase
    world_progress_location_bits[0][2][15]  = {2271020100} --Deck Capacity Increase, Firestorm, Snow White D-Link, Treasure Trove
    --Castle of Dreams
    world_progress_location_bits[0][3][10]  = {2271020200, 2271020201, 2271020202, 2271020203} --Diamond Dust, Cinderella D-Link, Stroke of Midnight, Castle Board
    --Enchanted Dominion
    world_progress_location_bits[0][4][14]  = {2271020300, 2271020301, 2271020302} --Max HP Increase, Thunderbolt, Fairy Stars
    --Mysterious Tower
    world_progress_location_bits[0][5][4]   = {2271020400, 2271020401} --Donald D-Link, Goofy D-Link
    --Radiant Garden
    world_progress_location_bits[0][6][3]   = {2271020500} --Disney Town Pass
    world_progress_location_bits[0][6][12]  = {2271020501} --Honey Pot Board
    world_progress_location_bits[0][6][6]   = {2271020502, 2271020503} --Max HP Increase, Cyclone
    world_progress_location_bits[0][6][8]   = {2271020504} --Reversal
    world_progress_location_bits[0][6][11]  = {2271020505} --Frolic Flame
    --Olympus Coliseum
    world_progress_location_bits[0][8][7]   = {2271020700} --Max HP Increase
    world_progress_location_bits[0][8][10]  = {2271020701} --Deck Capacity Increase
    world_progress_location_bits[0][8][13]  = {2271020702, 2271020703, 2271020704} --Air Slide, Zack D-Link, Mark of a Hero
    --Deep Space
    world_progress_location_bits[0][9][5]   = {2271020800} --Wingblade
    world_progress_location_bits[0][9][11]  = {2271020801, 2271020802} --Max HP Increase, Deck Capacity Increase
    world_progress_location_bits[0][9][12]  = {2271020803, 2271020804, 2271020805} --Experiment 626 D-Link, Hyperdrive, Spaceship Board
    --Neverland
    world_progress_location_bits[0][11][11] = {2271021000} --Glide
    world_progress_location_bits[0][11][13] = {2271021001, 2271021002, 2271021003, 2271021004} --Deck Capacity Increase, Peter Pan D-Link, Pixie Petal, Skull Board
    --Disney Town
    world_progress_location_bits[0][12][6]  = {2271021100} --Toon Board
    --Keyblade Graveyard
    world_progress_location_bits[0][13][8]  = {2271021200, 2271021201, 2271021202, 2271021203} --Max HP Increase, Deck Capacity Increase, High Jump, Mickey D-Link
    world_progress_location_bits[0][13][11] = {2271021204, 2271021205} --Lost Memory, Xehanort's Report 9
    
    --Aqua
    --Land of Departure
    world_progress_location_bits[1][1][3]   = {2271120000, 2271120001} --Max HP Increase, Spellweaver
    world_progress_location_bits[1][1][5]   = {2271120002, 2271120003, 2271120004} --Ventus D-Link, Terra D-Link, Keyblade Board
    --Dwarf Woodlands
    world_progress_location_bits[1][2][8]   = {2271120100} --Deck Capacity Increase
    world_progress_location_bits[1][2][10]  = {2271120101, 2271120102} --Snow White D-Link, Treasure Trove
    --Castle of Dreams
    world_progress_location_bits[1][3][4]   = {2271120200} --Map
    world_progress_location_bits[1][3][10]  = {2271120201} --Thunderbolt
    world_progress_location_bits[1][3][16]  = {2271120202, 2271120203, 2271120204, 2271120205, 2271120206} --Max HP Increase, Deck Capacity Increase, Cinderella D-Link, Stroke of Midnight, Castle Board
    --Enchanted Dominion
    world_progress_location_bits[1][4][8]   = {2271120300} --High Jump
    world_progress_location_bits[1][4][11]  = {2271120301, 2271120302} --Max HP Increase, Firestorm
    world_progress_location_bits[1][4][12]  = {2271120303, 2271120304} --Fairy Stars, Xehanort's Report 6
    --Mysterious Tower
    world_progress_location_bits[1][5][2]   = {2271120400, 2271120401, 2271120402} --Donald D-Link, Goofy D-Link, Xehanort's Report 4
    --Radiant Garden
    world_progress_location_bits[1][6][3]   = {2271120500, 2271120501} --Mickey D-Link, Destiny's Embrace
    world_progress_location_bits[1][6][6]   = {2271120502, 2271120503, 2271120504} --Max HP Increase, Bladecharge, Disney Town Pass
    world_progress_location_bits[1][6][10]  = {2271120505} --Honey Pot Board
    world_progress_location_bits[1][6][9]   = {2271120506} --Deck Capacity Increase
    --Olympus Coliseum
    world_progress_location_bits[1][8][8]   = {2271120700} --Max HP Increase
    world_progress_location_bits[1][8][10]  = {2271120701} --Deck Capacity Increase
    world_progress_location_bits[1][8][13]  = {2271120702} --Diamond Dust
    world_progress_location_bits[1][8][14]  = {2271120703, 2271120704} --Zack D-Link, Mark of a Hero
    --Deep Space
    world_progress_location_bits[1][9][10]  = {2271120800} --Air Slide
    world_progress_location_bits[1][9][11]  = {2271120801} --Max HP Increase
    world_progress_location_bits[1][9][16]  = {2271120802, 2271120803, 2271120804, 2271120805} --Deck Capacity Increase, Experiment 626 D-Link, Hyperdrive, Spaceship Board
    --Neverland
    world_progress_location_bits[1][11][6]  = {2271121000} --Doubleflight
    world_progress_location_bits[1][11][8]  = {2271121001, 2271121002} --Max HP Increase, Ghost Drive
    world_progress_location_bits[1][11][9]  = {2271121003, 2271121004, 2271121005, 2271121006} --Peter Pan D-Link, Pixie Petal, Stormfall, Skull Board
    --Disney Town
    world_progress_location_bits[1][12][5]  = {2271121100, 2271121101} --Balloon Letter, Toon Board
    --Keyblade Graveyard
    world_progress_location_bits[1][13][8]  = {2271121200} --Max HP Increase
    world_progress_location_bits[1][13][9]  = {2271121201} --Xehanort's Report 7
    
    --Terra
    --Land of Departure
    world_progress_location_bits[2][1][11]  = {2271220000, 2271220001} --Max HP Increase, Critical Impact
    world_progress_location_bits[2][1][4]   = {2271220002, 2271220003, 2271220004} --Ventus D-Link, Aqua D-Link, Keyblade Board
    world_progress_location_bits[2][1][8]   = {2271220005} --Max HP Increase
    world_progress_location_bits[2][1][10]  = {2271220006, 2271220007} --Chaos Ripper, Xehanort's Report 8
    --Dwarf Woodlands
    world_progress_location_bits[2][2][6]   = {2271220100} --Air Slide
    world_progress_location_bits[2][2][10]  = {2271220101, 2271220102} --Max HP Increase, Firestorm
    world_progress_location_bits[2][2][12]  = {2271220103} --Treasure Trove
    --Castle of Dreams
    world_progress_location_bits[2][3][11]  = {2271220200} --Counter Hammer
    world_progress_location_bits[2][3][8]   = {2271220201, 2271220202} --Max HP Increase, Deck Capacity Increase
    world_progress_location_bits[2][3][13]  = {2271220203, 2271220204, 2271220205} --Cinderella D-Link, Stroke of Midnight, Royal Board
    --Enchanted Dominion
    world_progress_location_bits[2][4][7]   = {2271220300} --Maleficent D-Link
    world_progress_location_bits[2][4][9]   = {2271220301, 2271220302, 2271220303} --Deck Capacity Increase, Diamond Dust, Fairy Stars
    --Radiant Garden
    world_progress_location_bits[2][6][1]   = {2271220500} --Honey Pot Board
    world_progress_location_bits[2][6][9]   = {2271220501, 2271220502, 2271220503} --Max HP Increase, Rockbreaker, Disney Town Pass
    world_progress_location_bits[2][6][12]  = {2271220504, 2271220505, 2271220506} --Deck Capacity Increase, Dark Volley, Xehanort's Report 2
    --Olympus Coliseum
    world_progress_location_bits[2][8][8]   = {2271220700, 2271220701} --Max HP Increase, Sonic Impact
    world_progress_location_bits[2][8][12]  = {2271220702, 2271220703, 2271220704} --Deck Capacity Increase, Zack D-Link, Mark of a Hero
    --Deep Space
    world_progress_location_bits[2][9][9]   = {2271220800} --Max HP Increase
    world_progress_location_bits[2][9][10]  = {2271220801, 2271220802, 2271220803, 2271220804} --Thunderbolt, Experiment 626 D-Link, Hyperdrive, Spaceship Board
    --Destiny Islands
    world_progress_location_bits[2][10][1]  = {2271220900} --Ends of the Earth
    --Neverland
    world_progress_location_bits[2][11][6]  = {2271221000, 2271221001} --Bladecharge, Peter Pan D-Link
    world_progress_location_bits[2][11][9]  = {2271221002} --Deck Capacity Increase
    world_progress_location_bits[2][11][10] = {2271221003, 2271221004} --Pixie Petal, Skull Board
    --Disney Town
    world_progress_location_bits[2][12][7]  = {2271221100, 2271221101} --Hi-Potion and Toon Board
    --Keyblade Graveyard
    world_progress_location_bits[2][13][3]  = {2271221200} --Dark Impulse
    world_progress_location_bits[2][13][10] = {2271221201} --Max HP Increase
    world_progress_location_bits[2][13][15] = {2271221201} --Story Complete
    
    return world_progress_location_bits
end

world_progress_location_bits = define_world_progress_location_bits()

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

function version_choice(array, choice)
    a = array
    return a[choice]
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
    command_value = command_value + 0x5B
    if command_value >= 0xBC and command_value <= 0xD2 then --Item Command
        command_index = 0
        while ReadShort(command_stock_address[game_version] + (10 * command_index)) ~= command_value and command_index < max_commands do
            command_index = command_index + 1
        end
        if command_index < max_commands then
            num_available = ReadShort(command_stock_address[game_version] + (10 * command_index) + 2)
            WriteShort(command_stock_address[game_version] + (10 * command_index) + 2, math.min(num_available + 1, 99))
            return
        end
    end
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
    dlink_offset = {}
    dlink_offset[0]  = 0x0
    dlink_offset[1]  = 0x8
    dlink_offset[2]  = 0x10
    dlink_offset[3]  = 0x38
    dlink_offset[4]  = 0x40
    dlink_offset[5]  = 0x28
    dlink_offset[6]  = 0x20
    dlink_offset[7]  = 0x18
    dlink_offset[8]  = 0x30
    dlink_offset[9]  = 0x48
    dlink_offset[10] = -0x10
    dlink_offset[11] = -0x18
    dlink_offset[12] = -0x8
    dlinks_address = {0x0, 0x10FA4ECC}
    duplicate = false
    if not duplicate then
        WriteShort(dlinks_address[game_version] + dlink_offset[dlink_value] + 0, dlink_value + 0x163) --Write D-Link
        WriteShort(dlinks_address[game_version] + dlink_offset[dlink_value] + 2, 0x8000) --Write ??
        WriteShort(dlinks_address[game_version] + dlink_offset[dlink_value] + 4, 0) --Write ??
        WriteShort(dlinks_address[game_version] + dlink_offset[dlink_value] + 6, 0) --Write ??
    end
end

function write_ability(ability_offset)
    --Write ability to the player's ability array
    abilities_address = {0x0, 0x10FA4554}
    ability_byte_1 = ReadByte(abilities_address[game_version] + (ability_offset) * 4)
    ability_byte_2 = ReadByte((abilities_address[game_version] + (ability_offset) * 4)+1)
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
    WriteByte(abilities_address[game_version] + (ability_offset) * 4, ability_byte_1)
    WriteByte((abilities_address[game_version] + (ability_offset) * 4)+1, ability_byte_2)
end

function write_command_style(command_style_offset)
    --Writes command style to a players command style array
    command_style_address = {0x0, 0x10FA45CC}
    WriteByte(command_style_address[game_version]+command_style_offset, 0x05)
end

function write_worlds()
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
    for world_offset, world_value in pairs(worlds_unlocked_array) do
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
        ap_bits[bit_num] = 1
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

function write_ap_item_text()
    dummy_id_text_address = {0x0, 0xD65550}
    WriteArray(dummy_id_text_address[game_version], {0x41,0x50,0x20,0x49,0x74,0x65,0x6D,0x00})
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
    return ReadByte(deck_capacity_address[game_version])
end

function read_chest_location_ids()
    location_ids = {}
    chests_opened_address = {0x0, 0x10FA2B7C}
    location_add_array = {2271000000, 2271100000, 2271200000}
    chests_opened_array = ReadArray(chests_opened_address[game_version], 26)
    for chest_index, chest_byte in pairs(chests_opened_array) do
        chest_bits = toBits(chest_byte, 8)
        for i=1,8 do
            if chest_bits[i] == 1 then
                location_ids[#location_ids + 1] = location_add_array[read_current_character() + 1] + ((chest_index-1)*10) + i
            end
        end
    end
    return location_ids
end

function read_sticker_location_ids()
    location_ids = {}
    stickers_found_address = {0x0, 0x10FA2B9C}
    location_add_array = {2271010000, 2271110000, 2271210000}
    stickers_opened_array = ReadArray(stickers_found_address[game_version], 3)
    for sticker_index, sticker_byte in pairs(stickers_opened_array) do
        sticker_bits = toBits(sticker_byte, 8)
        for i=1,8 do
            if sticker_bits[i] == 1 then
                location_ids[#location_ids + 1] = location_add_array[read_current_character() + 1] + ((sticker_index-1)*10) + i
            end
        end
    end
    return location_ids
end

function read_world_progress_location_ids()
    world_progress_address = {0x0, 0x10FA1D24}
    final_story_address = {0x0, 0x10FA1EA6}
    location_ids = {}
    world_progress_index = 0
    while world_progress_index < 14 do
        world_progress_value = ReadShort(world_progress_address[game_version] + (0x20 * world_progress_index))
        world_progress_bits = toBits(world_progress_value, 16)
        for i=1,16 do
            if world_progress_bits[i] > 0 then
                for k,v in pairs(world_progress_location_bits[read_current_character()][world_progress_index+1][i]) do
                    location_ids[#location_ids + 1] = v
                end
            end
        end
        world_progress_index = world_progress_index + 1
    end
    if ReadShort(final_story_address[game_version] >= 0x000F then
        location_ids[#location_ids + 1] = 2271021206
    end
    return location_ids
end

function read_current_character()
    current_character_address = {0x0, 0x10F9F800}
    return ReadByte(current_character_address[game_version])
end

function victorious()
    ap_bits_address = {0x0, 0x10FA1D1D}
    ap_byte = ReadByte(ap_bits_address[game_version])
    ap_bits = toBits(ap_byte, 8)
    if ap_bits[6] == 1 then
        return true
    else
        return false
    end
end

function character_selected_or_save_loaded()
    if can_execute then
        if ReadInt(version_choice({0x0, 0x81711F}, game_version)) ~= 0xFFFFFF00 then --Not on Title Screen
            if ReadInt(version_choice({0x0, 0x81711F}, game_version)) ~= 0xD0100 then
                if ReadInt(version_choice({0x0, 0x81711F}, game_version)) ~= 0x20100 or ReadInt(version_choice({0x0, 0x817123}, game_version)) ~= 0x100 or ReadShort(version_choice({0x0, 0x817127}, game_version)) ~= 0x100 then
                    return true
                end
            end
        end
    end
end

function receive_items()
    i = read_check_number() + 1
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
        elseif received_item_id >= 2270070000 and received_item_id <= 2270070012 then
            item_value = received_item_id % 2270070000
            write_dlink(item_value)
        end
        i = i + 1
    end
    write_check_number(i-1)
end

function removed_starting_wayfinder()
    ap_bits_address = {0x0, 0x10FA1D1D}
    ap_byte = ReadByte(ap_bits_address[game_version])
    ap_bits = toBits(ap_byte, 8)
    return ap_bits[7] == 1
end

function remove_starting_wayfinder()
    if not removed_starting_wayfinder() then
        key_item_stock_address = {0x0, 0x10FA2AAC}
        ap_bits_address = {0x0, 0x10FA1D1D}
        wayfinder_value = {0x1F1C, 0x1F1F, 0x1F20}
        max_items = 25
        item_index = 0
        while ReadShort(key_item_stock_address[game_version] - (2 * item_index)) ~= 0 and item_index < max_items do
            item_value = ReadShort(key_item_stock_address[game_version] - (2 * item_index))
            if item_value == wayfinder_value[read_current_character() + 1] then
                WriteShort(key_item_stock_address[game_version] - (2 * item_index), 0x0000)
                ap_byte = ReadByte(ap_bits_address[game_version])
                ap_bits = toBits(ap_byte, 8)
                ap_bits[7] = 1
                ap_byte = toNum(ap_bits)
                WriteByte(ap_bits_address[game_version], ap_byte)
            end
            item_index = item_index + 1
        end
    end
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
    sticker_location_ids = read_sticker_location_ids()
    for location_index, location_id in pairs(sticker_location_ids) do
        if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
            file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
            io.output(file)
            io.write("")
            io.close(file)
        end
    end
    world_progress_location_ids = read_world_progress_location_ids()
    for location_index, location_id in pairs(world_progress_location_ids) do
        if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
            file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
            io.output(file)
            io.write("")
            io.close(file)
        end
    end
    if victorious() then
        if not file_exists(client_communication_path .. "victory") then
            file = io.open(client_communication_path .. "victory", "w")
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
    if character_selected_or_save_loaded() then
        write_ap_item_text()
        remove_starting_wayfinder()
        frame_count = (frame_count + 1) % 30
        if frame_count == 0 then
            receive_items()
            send_items()
        end
    end
end