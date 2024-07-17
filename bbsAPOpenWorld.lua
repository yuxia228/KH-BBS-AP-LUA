LUAGUI_NAME = "bbsAPConnector"
LUAGUI_AUTH = "Sonicshadowsilver2"
LUAGUI_DESC = "BBS FM AP Open World"

game_version = 1 --1 for 1.0.0.9 EGS, 2 for Steam
IsEpicGLVersion = 0x6107D4
IsSteamGLVersion = 0x6107B4
IsSteamJPVersion = 0x610534
can_execute = false

worlds_unlocked_array = {1,0,0,0,0,0,0,0,0,0,0,0,0}

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


function read_world_item()
    ap_bits_address = {0x0, 0x10FA1D1C}
    world_item_byte_array = ReadArray(ap_bits_address[game_version], 2)
    world_item_bits_1 = toBits(world_item_byte_array[1], 8)
    world_item_bits_2 = toBits(world_item_byte_array[2], 8)
    worlds_unlocked_array[1] = 1 --LOD always unlocked
    worlds_unlocked_array[2] = world_item_bits_1[2]
    worlds_unlocked_array[3] = world_item_bits_1[3]
    worlds_unlocked_array[4] = world_item_bits_1[4]
    worlds_unlocked_array[5] = world_item_bits_1[5]
    worlds_unlocked_array[6] = world_item_bits_1[6]
    worlds_unlocked_array[7] = world_item_bits_1[7]
    worlds_unlocked_array[8] = world_item_bits_1[8]
    worlds_unlocked_array[9] = world_item_bits_2[1]
    worlds_unlocked_array[10] = world_item_bits_2[2]
    worlds_unlocked_array[11] = world_item_bits_2[3]
    worlds_unlocked_array[12] = world_item_bits_2[4]
    worlds_unlocked_array[13] = world_item_bits_2[5]
end

function read_number_of_wayfinders()
    key_item_stock_address = {0x0, 0x10FA2AAC}
    max_items = 25
    item_index = 0
    wayfinders = {}
    while ReadShort(key_item_stock_address[game_version] - (2 * item_index)) ~= 0 and item_index < max_items do
        item_value = ReadShort(key_item_stock_address[game_version] - (2 * item_index))
        if item_value == 0x1F1C or item_value == 0x1F1D or item_value == 0x1F20 then
            wayfinders[item_value] = 1
        end
        item_index = item_index + 1
    end
    return #wayfinders
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

function _OnInit()
    Now  = 0x817120
    Save = 0x10F9F7F0
    RoomNameText = 0xCB6ED2
    CharMod = 0x10F9DDCC
    TMTBGM = 0x86F0EC
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
        --Open All Worlds
        if ReadShort(Now+0x00) == 0x0111 then
            read_world_item()
            WriteInt(Save+0x2938,0x00002002 * worlds_unlocked_array[1]) --The Land of Departure
            WriteInt(Save+0x293C,0x00000102 * worlds_unlocked_array[2]) --Dwarf Woodlands
            WriteInt(Save+0x2940,0x00000102 * worlds_unlocked_array[3]) --Castle of Dreams
            WriteInt(Save+0x2944,0x00000102 * worlds_unlocked_array[4]) --Enchanted Dominion
            WriteInt(Save+0x2948,0x00000102 * worlds_unlocked_array[5]) --The Mysterious Tower
            WriteInt(Save+0x294C,0x00000102 * worlds_unlocked_array[6]) --Radiant Garden
            WriteInt(Save+0x2954,0x00000102 * worlds_unlocked_array[8]) --Olympus Coliseum
            WriteInt(Save+0x2958,0x00000102 * worlds_unlocked_array[9]) --Deep Space
            if ReadShort(Save+0x10) == 0x01 then
                WriteInt(Save+0x295C,0x00000802 * worlds_unlocked_array[10]) --Destiny Islands
            end
            WriteInt(Save+0x2960,0x00000102 * worlds_unlocked_array[11]) --Never Land
            WriteInt(Save+0x2964,0x00000102 * worlds_unlocked_array[12]) --Disney Town
            if read_number_of_wayfinders() >= 3 then
                WriteInt(Save+0x2968,0x00000102) --Keyblade Graveyard
            end
            --WriteInt(Save+0x2970,0x00000002) --Mirage Arena
            --WriteInt(Save+0x2815,0x01010101) --LoD, DW, CS, ED
            --WriteInt(Save+0x2819,0x01010101) --TMT, RG, Special, OC
            --WriteInt(Save+0x281D,0x01010001) --DS, DI, NL, DT
            --if ReadByte(Save+0x10) == 0x02 or ReadByte(Save+0x10) == 0x01 then
            --    WriteByte(Save+0x2821,0x0A) --KG (Terra and Aqua)
            --elseif ReadByte(Save+0x10) == 0x00 then
            --    WriteByte(Save+0x2821,0x01) --KG (Ventus)
            --end
            WriteByte(Save+0x22E,0x01) --The Land of Departure: Mountain Path (Destroyed) MAP
            WriteByte(Save+0x234,0x01) --The Land of Departure: Summit (Destroyed) MAP
            WriteInt(Save+0x2984,0x00000000) --Unlock The Land of Departure: Summit (Destroyed) Save Point on World Map
            if ReadByte(Save+0x10) == 0x01 then
                WriteByte(Save+0x13DA,0x01) --The Keyblade Graveyard: Badlands MAP
                WriteByte(Save+0x13DE,0x16) --The Keyblade Graveyard: Badlands EVENT
            end
            if ReadByte(Save+0x2917) == 0x00 then
                WriteByte(Save+0x2917,ReadByte(Save+0x2917)+8) --Unlock The Keyblade Graveyard: Fissure Save Point on World Map
            end
        end
        --Terra's Story
        if ReadByte(Save+0x10) == 0x02 then
            --Unlock All Worlds (New Game)
            if ReadShort(Now+0x10) == 0x0101 and ReadShort(Now+0x00) == 0x0111 then
                WriteByte(Save+0x2694,0x02) --Disney Town's Story Progression
                WriteInt(Save+0x29C0,0xFFFFFFFE) --Lock Disney Town's Save Point on World Map
                WriteShort(Save+0x26B4,0x9807) --Keyblade Graveyard's Story Progression
                WriteInt(Save+0x29F0,0xFFFFFFFE) --Lock Keyblade Graveyard's Save Points on World Map
                WriteByte(Save+0x13DA,0x01) --The Keyblade Graveyard: Badlands MAP
                WriteByte(Save+0x13DE,0x16) --The Keyblade Graveyard: Badlands EVENT
            end
            --Always Have All Worlds Opened
            WriteByte(Save+0x2938,0x02) --The Land of Departure
            if ReadByte(Save+0x2939) == 0x34 then
                WriteByte(Save+0x2939,0x01)
            end
            if ReadInt(Save+0x29E4) ~= 0 then -- Always Have The Land of Departure: Summit (Destroyed) Save Point Opened
                WriteInt(Save+0x29E4,0)
            end
            WriteByte(Save+0x293C,0x02 * worlds_unlocked_array[2]) --Dwarf Woodlands
            WriteByte(Save+0x2940,0x02 * worlds_unlocked_array[3]) --Castle of Dreams
            WriteByte(Save+0x2944,0x02 * worlds_unlocked_array[4]) --Enchanted Dominion
            WriteByte(Save+0x2948,0x02 * worlds_unlocked_array[5]) --The Mysterious Tower
            WriteByte(Save+0x294C,0x02 * worlds_unlocked_array[6]) --Radiant Garden
            WriteByte(Save+0x2954,0x02 * worlds_unlocked_array[8]) --Olympus Coliseum
            WriteByte(Save+0x2958,0x02 * worlds_unlocked_array[9]) --Deep Space
            WriteByte(Save+0x295C,0x00 * worlds_unlocked_array[10]) --Destiny Islands
            WriteByte(Save+0x2960,0x02 * worlds_unlocked_array[11]) --Never Land
            WriteByte(Save+0x2964,0x02 * worlds_unlocked_array[12]) --Disney Town
            if read_number_of_wayfinders() >= 3 then
                WriteByte(Save+0x2968,0x02) --Keyblade Graveyard
            end
            if ReadByte(Save+0x2969) == 0x15 then
                WriteByte(Save+0x2969,0x01)
            end
            --WriteByte(Save+0x2970,0x02) --Mirage Arena
            WriteInt(Save+0x2974,0x01010101)
            WriteInt(Save+0x2978,0x01010101)
            WriteInt(Save+0x297C,0x01010101)
            WriteShort(Save+0x2980,0x0101)
            --All Tutorials Viewed (Except Command Styles & Mini-Games)
            if ReadShort(Now+0) == 0x0201 then
                WriteInt(Save+0x4E13,0x03030303)
                WriteInt(Save+0x4E17,0x00030303)
                WriteInt(Save+0x4E1C,0x07000007)
                WriteShort(Save+0x4E20,0x0000)
                WriteInt(Save+0x4E25,0x00000707)
                WriteInt(Save+0x4E29,0x0F0F000B)
                WriteShort(Save+0x4E2D,0x1313)
            end
            --Start of Enchanted Dominion
            if ReadShort(Now+0) == 0x704 and ReadShort(Now+8) == 0x3D then
                if ReadByte(Save+0x2598) == 0 then
                    WriteByte(Save+0x2598,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Enchanted Dominion
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0904 then
                if ReadByte(Save+0x259C) == 0 then
                    WriteByte(Save+0x259C,1)
                    WriteInt(Now+0,0x00020804)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2945,0x0122)
                    WriteShort(Save+0x14,0x0804)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Castle of Dreams
            if ReadShort(Now+0) == 0x603 and ReadShort(Now+8) == 0x37 then
                if ReadByte(Save+0x2578) == 0 then
                    WriteByte(Save+0x2578,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Castle of Dreams 1
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0A03 then
                if ReadByte(Save+0x257C) == 0 then
                    WriteByte(Save+0x257C,1)
                    WriteInt(Now+0,0x00020803)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2941,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Castle of Dreams 2
            if ReadShort(Now+0) == 0x0B06 and ReadShort(Now+0x10) == 0x0A03 then
                if ReadByte(Save+0x257C) == 0 then
                    WriteByte(Save+0x257C,1)
                    WriteInt(Now+0,0x00020803)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2941,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Dwarf Woodlands
            if ReadShort(Now+0) == 0x402 and ReadShort(Now+8) == 0x35 then
                if ReadByte(Save+0x2558) == 0 then
                    WriteByte(Save+0x2558,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Dwarf Woodlands 1
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x00000402 then
                if ReadByte(Save+0x255C) == 0 then
                    WriteByte(Save+0x255C,1)
                    WriteInt(Now+0,0x00630402)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x293D,0x0122)
                    WriteShort(Save+0x14,0x0402)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Dwarf Woodlands 2
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x00000602 then
                if ReadByte(Save+0x255C) == 0 then
                    WriteByte(Save+0x255C,1)
                    WriteInt(Now+0,0x00630602)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x293D,0x0122)
                    WriteShort(Save+0x14,0x0602)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Dwarf Woodlands 3
            if ReadShort(Now+0) == 0x0B06 and ReadInt(Now+0x10) == 0x00000602 then
                if ReadByte(Save+0x255C) == 0 then
                    WriteByte(Save+0x255C,1)
                    WriteInt(Now+0,0x00630602)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x293D,0x0122)
                    WriteShort(Save+0x14,0x0602)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of The Mysterious Tower
            if ReadShort(Now+0) == 0x205 and ReadShort(Now+8) == 0x33 then
                if ReadByte(Save+0x25B8) == 0 then
                    WriteByte(Save+0x25B8,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of The Mysterious Tower
            if ReadShort(Now+0) == 0x3207 and ReadShort(Now+0x10) == 0x0405 then
                if ReadByte(Save+0x25BC) == 0 then
                    WriteByte(Save+0x25BC,1)
                    WriteInt(Now+0,0x00010405)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2949,0x0122)
                    WriteShort(Save+0x14,0x0405)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Radiant Garden
            if ReadShort(Now+0) == 0x306 and ReadShort(Now+8) == 0x39 then
                if ReadByte(Save+0x25D8) == 0 then
                    WriteByte(Save+0x25D8,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Radiant Garden
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0B06 then
                if ReadByte(Save+0x25DC) == 0 then
                    WriteByte(Save+0x25DC,1)
                    WriteInt(Now+0,0x00010C06)
                    WriteShort(Now+4,0x19)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x294D,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Disney Town
            if ReadShort(Now+0) == 0x40C and ReadShort(Now+8) == 0x50 then
                if ReadByte(Save+0x2698) == 0 then
                    WriteByte(Save+0x2698,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Disney Town 1
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x050C then
                WriteShort(Now+0,0x020C)
                WriteShort(Now+4,0x4E)
                WriteShort(Now+6,0x4E)
                WriteShort(Now+8,0x4E)
            end
            --End of Disney Town 2
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0B0C then
                if ReadByte(Save+0x269C) == 0 then
                    WriteByte(Save+0x269C,1)
                    WriteInt(Now+0,0x0033020C)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2965,0x0122)
                    WriteByte(Save+0x282C,ReadByte(Save+0x282C)+1) --Moogle Level
                    WriteShort(Save+0x14,0x020C)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Olympus Coliseum
            if ReadShort(Now+0) == 0x508 and ReadShort(Now+8) == 0x3F then
                if ReadByte(Save+0x2618) == 0 then
                    WriteByte(Save+0x2618,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Olympus Coliseum
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0408 then
                if ReadByte(Save+0x261C) == 0 then
                    WriteByte(Save+0x261C,1)
                    WriteInt(Now+0,0x00320208)
                    WriteShort(Now+4,0x02)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2955,0x0122)
                    WriteShort(Save+0x14,0x0208)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Deep Space
            if ReadShort(Now+0) == 0x109 and ReadShort(Now+8) == 0x1 then
                if ReadByte(Save+0x2638) == 0 then
                    WriteByte(Save+0x2638,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Deep Space
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0609 then
                if ReadByte(Save+0x263C) == 0 then
                    WriteByte(Save+0x263C,1)
                    WriteInt(Now+0,0x00010609)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2959,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Never Land
            if ReadShort(Now+0) == 0xB0B and ReadShort(Now+8) == 0x39 then
                if ReadByte(Save+0x2658) == 0 then
                    WriteByte(Save+0x2658,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Never Land
            if ReadShort(Now+0) == 0x3207 and ReadShort(Now+0x10) == 0x0D0B then
                if ReadByte(Save+0x265C) == 0 then
                    WriteByte(Save+0x265C,1)
                    WriteInt(Now+0,0x00010D0B)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2961,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Destiny Islands
            if ReadShort(Now+0) == 0x0111 and ReadByte(Save+0x2658) == 0x0A then
                WriteShort(Now+0,0x3207)
                WriteShort(Now+4,0x34)
                WriteShort(Now+6,0x34)
                WriteShort(Now+8,0x34)
                WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
            end
            --Xehanort Visit
            if ReadShort(Now+0) == 0x0111 and ReadByte(Save+0x2658) == 0x0B then
                WriteShort(Now+0,0x010D)
                WriteShort(Now+4,0x37)
                WriteShort(Now+6,0x37)
                WriteShort(Now+8,0x37)
                WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
            end
            --End of Xehanort Visit
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x000A010D then
                WriteInt(Now+0,0x0063010D)
                WriteShort(Now+4,0x01)
                WriteShort(Now+6,0x00)
                WriteShort(Now+8,0x16)
                WriteShort(Save+0x14,0x010D)
            end
            --Normal Land of Departure Text
            if ReadShort(Now+0) == 0x0111 and ReadShort(Save+0x2939) == 0x0020 then
                WriteString(RoomNameText+0xDC,"Eraqus")
            end
            --Master Eraqus Fight
            if ReadInt(Now+0) == 0x00631001 and ReadShort(Save+0x2939) == 0x0020 then
                WriteInt(Now+0,0x00000101)
                WriteShort(Now+4,0x41)
                WriteShort(Now+6,0x41)
                WriteShort(Now+8,0x41)
            end
            --End of The Land of Departure
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0801 then
                if ReadByte(Save+0x253C) == 0 then
                    WriteByte(Save+0x253C,1)
                    WriteInt(Now+0,0x00010F01)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2939,0x0222)
                    WriteInt(Save+0x2988,0x00000000)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Normal Summit -> Destroyed Summit (Post Master Eraqus Battle)
            if ReadByte(Save+0x293A) == 0x02 then
                if ReadShort(Now+0) == 0x0601 and ReadShort(Now+0x10) == 0x0111 then
                    WriteInt(Now+0,0x00631001)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                end
            end
            --Destroyed Land of Departure Text 1
            if ReadShort(Now+0) == 0x0111 and ReadShort(Save+0x2939) == 0x0222 then
                WriteString(RoomNameText+0xDC,"???   ")
            end
            --Destroyed Land of Departure Text 2
            if ReadByte(Now+0) == 0x01 and ReadShort(Save+0x2939) == 0x0222 then
                WriteString(RoomNameText+0xDC,"Summit")
            end
            --??? Fight
            if ReadInt(Now+0) == 0x00631001 and ReadShort(Now+0x20) == 0x1001 then
                if ReadShort(Save+0x2939) == 0x0222 then
                    WriteByte(Now+2,0x00)
                    WriteShort(Now+4,0x43)
                    WriteShort(Now+6,0x43)
                    WriteShort(Now+8,0x43)
                end
            end
            --The Keyblade Graveyard: Fissure Room Name
            if ReadShort(Save+0x26B4) == 0x9807 then
                WriteString(RoomNameText+0x9DD,"Seat of War") --Changes The Keyblade Graveyard: Fissure's Room Name
                WriteByte(RoomNameText+0x9E8,0x00) --Makes sure Room Name text doesn't overlap
            else
                WriteString(RoomNameText+0x9DD,"Fissure") --Fixes Room Name text back to normal
                WriteInt(RoomNameText+0x9E4,0x79654B00)
                WriteByte(RoomNameText+0x9E8,0x62)
            end
            --Start of The Keyblade Graveyard
            if ReadShort(Now+0) == 0x070D and ReadShort(RoomNameText+0x9DD) == 0x6553 then
                WriteInt(Now+0,0x0000020D)
                WriteShort(Now+4,0x46)
                WriteShort(Now+6,0x46)
                WriteShort(Now+8,0x46)
            end
            --[[Final Battle Requirements
            if ReadShort(Now+0) == 0x080D then 
                if ReadInt(Save+0x32B8) == 0x1F1F1F1C and ReadShort(Save+0x32BC) == 0x1F20 then
                    WriteShort(Now+0,0x080D)
                else
                    WriteInt(Now+0,0x0032070D)
                end
            end]]
            --Battle Level 10
            if ReadByte(Save+0x281B) >= 0x0A then
                WriteInt(Save+0x2815,0x0A0A0A0A) --LoD, DW, CS, ED
                WriteShort(Save+0x2819,0x0A0A) --TMT, RG
                WriteShort(Save+0x281C,0x0A0A) --OC, DS
                WriteInt(Save+0x281F,0x000A0A0A) --NL, DT, KG
            end
            --[[Enchanted Dominion Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0F04 then
                if ReadShort(EDChestsT1+0x281) == 0x3230 then
                    WriteString(EDChestsT1+0x280,"g01sb00")
                end
                if ReadShort(EDChestsT2+0xF1) == 0x3230 then
                    WriteString(EDChestsT2+0xF0,"g01sb00")
                end
            end
            if ReadShort(Now+0) == 0x1004 then
                if ReadShort(EDChestsT1+0x01) == 0x3230 then
                    WriteString(EDChestsT1+0x00,"g01sb00")
                end
            end
            if ReadShort(Now+0) == 0x1204 then
                if ReadShort(EDChestsT1+0x191) == 0x3230 then
                    WriteString(EDChestsT1+0x190,"g01sb00")
                end
                if ReadShort(EDChestsT2+0x01) == 0x3230 then
                    WriteString(EDChestsT2+0x00,"g01sb00")
                end
            end
            --Castle of Dreams Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0703 then
                if ReadShort(CoDChestsT1+1) == 0x3230 then
                    WriteString(CoDChestsT1+0,"g01cd00")
                end
                if ReadShort(CoDChestsT2+1) == 0x3230 then
                    WriteString(CoDChestsT2+0,"g01cd00")
                end
            end
            --Dwarf Woodlands Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0602 then
                if ReadShort(DWChestsT1+1) == 0x3230 then
                    WriteString(DWChestsT1+0,"g01sw00")
                end
                if ReadShort(CoDChestsT2+1) == 0x3230 then
                    WriteString(DWChestsT2+0,"g01sw00")
                end
            end
            --The Mysterious Tower Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0305 then
                if ReadShort(TMTChestsT+1) == 0x3230 then
                    WriteString(TMTChestsT+0,"g01yt00")
                end
            end
            --Radiant Garden Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0506 then
                if ReadShort(RGChestsT1+1) == 0x3230 then
                    WriteString(RGChestsT1+0,"g01rg00")
                end
                if ReadShort(RGChestsT2+1) == 0x3230 then
                    WriteString(RGChestsT2+0,"g01rg00")
                end
            end
            --Disney Town Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x020C then
                if ReadShort(DTChestsT1+1) == 0x3230 then
                    WriteString(DTChestsT1+0,"g01dc00")
                end
                if ReadShort(DTChestsT2+1) == 0x3230 then
                    WriteString(DTChestsT2+0,"g01dc00")
                end
            end
            --Olympus Coliseum Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0208 then
                if ReadShort(OCChestsT1+1) == 0x3230 then
                    WriteString(OCChestsT1+0,"g01he00")
                end
                if ReadShort(OCChestsT2+1) == 0x3230 then
                    WriteString(OCChestsT2+0,"g01he00")
                end
            end
            --Deep Space Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0209 then
                if ReadShort(DSChestsT1+1) == 0x3230 then
                    WriteString(DSChestsT1+0,"g01ls00")
                end
                if ReadShort(DSChestsT2+1) == 0x3230 then
                    WriteString(DSChestsT2+0,"g01ls00")
                end
            end
            --Never Land Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x070B then
                if ReadShort(NLChestsT1+0x6B1) == 0x3230 then
                    WriteString(NLChestsT1+0x6B0,"g01pp00")
                end
                if ReadShort(NLChestsT2+0X01) == 0x3230 then
                    WriteString(NLChestsT2+0x00,"g01pp00")
                end
            end
            if ReadShort(Now+0) == 0x060B then
                if ReadShort(NLChestsT1+0x01) == 0x3230 then
                    WriteString(NLChestsT1+0x00,"g01pp00")
                end
            end
            --The Keyblade Graveyard Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x020D then
                if ReadShort(KGChestsT1+1) == 0x3230 then
                    WriteString(KGChestsT1+0,"g01kg00")
                end
                if ReadShort(KGChestsT2+1) == 0x3230 then
                    WriteString(KGChestsT2+0,"g01kg00")
                end
            end]]
            end
        --Ventus's Story
        if ReadByte(Save+0x10) == 0x00 then
            --Unlock All Worlds (New Game)
            if ReadShort(Now+0x10) == 0x0101 and ReadShort(Now+0) == 0x0111 then
                WriteInt(Save+0x2990,0xFFFFFFFE) --Lock The Land of Departure: Summit Save Point on World Map
                WriteInt(Save+0x2994,0xFFFFFFFE) --Lock The Land of Departure: Forecourt Save Point on World Map
                WriteInt(Save+0x2998,0x02140000) -- Lock The Land of Departure: Forecourt Ruins
                WriteInt(Save+0x29D0,0xFFFFFFFE) --Lock The Mysterious Tower's Save Point on World Map
            end
            --Always Have All Worlds Opened
            WriteByte(Save+0x2938,0x02) --The Land of Departure
            if ReadByte(Save+0x2939) == 0x34 then
                    WriteByte(Save+0x2939,0x01)
                end
            WriteByte(Save+0x293C,0x02 * worlds_unlocked_array[2]) --Dwarf Woodlands
            WriteByte(Save+0x2940,0x02 * worlds_unlocked_array[3]) --Castle of Dreams
            WriteByte(Save+0x2944,0x02 * worlds_unlocked_array[4]) --Enchanted Dominion
            WriteByte(Save+0x2948,0x02 * worlds_unlocked_array[5]) --The Mysterious Tower
            WriteByte(Save+0x294C,0x02 * worlds_unlocked_array[6]) --Radiant Garden
            WriteByte(Save+0x2954,0x02 * worlds_unlocked_array[8]) --Olympus Coliseum
            WriteByte(Save+0x2958,0x02 * worlds_unlocked_array[9]) --Deep Space
            WriteByte(Save+0x295C,0x00 * worlds_unlocked_array[10]) --Destiny Islands
            WriteByte(Save+0x2960,0x02 * worlds_unlocked_array[11]) --Never Land
            WriteByte(Save+0x2964,0x02 * worlds_unlocked_array[12]) --Disney Town
            if read_number_of_wayfinders() >= 3 then
                WriteByte(Save+0x2968,0x02) --Keyblade Graveyard
            end
            if ReadByte(Save+0x2969) == 0x15 then
                WriteByte(Save+0x2969,0x01)
            end
            --WriteByte(Save+0x2970,0x02) --Mirage Arena
            WriteInt(Save+0x2974,0x01010101)
            WriteInt(Save+0x2978,0x01010101)
            WriteInt(Save+0x297C,0x01010101)
            WriteShort(Save+0x2980,0x0101)
            --All Tutorials Viewed (Except Command Styles & Mini-Games)
            if ReadShort(Now+0) == 0x0201 then
                WriteInt(Save+0x4E13,0x03030303)
                WriteInt(Save+0x4E17,0x07030303)
                WriteInt(Save+0x4E1D,0x07000007)
                WriteByte(Save+0x4E21,0x07)
                WriteShort(Save+0x4E26,0x0707)
                WriteInt(Save+0x4E29,0x0F0F000B)
                WriteShort(Save+0x4E2D,0x1313)
            end
            --Start of Enchanted Dominion
            if ReadShort(Now+0) == 0xF04 and ReadShort(Now+8) == 0x3C then
                if ReadByte(Save+0x2598) == 0 then
                    WriteByte(Save+0x2598,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --Start of Castle of Dreams
            if ReadShort(Now+0) == 0x103 and ReadShort(Now+8) == 0x3A then
                if ReadByte(Save+0x2578) == 0 then
                    WriteByte(Save+0x2578,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --Start of Dwarf Woodlands
            if ReadShort(Now+0) == 0xC02 and ReadShort(Now+8) == 0x3A then
                if ReadByte(Save+0x2558) == 0 then
                    WriteByte(Save+0x2558,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --Start of The Mysterious Tower
            if ReadShort(Now+0) == 0x205 and ReadShort(Now+8) == 0x36 then
                if ReadByte(Save+0x25B8) == 0 then
                    WriteByte(Save+0x25B8,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --Start of Disney Town
            if ReadShort(Now+0) == 0x20C and ReadShort(Now+8) == 0x55 then
                if ReadByte(Save+0x2698) == 0 then
                    WriteByte(Save+0x2698,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --Start of Olympus Coliseum
            if ReadShort(Now+0) == 0x508 and ReadShort(Now+8) == 0x40 then
                if ReadByte(Save+0x2618) == 0 then
                    WriteByte(Save+0x2618,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --Start of Deep Space
            if ReadShort(Now+0) == 0x609 and ReadShort(Now+8) == 0x1 then
                if ReadByte(Save+0x2638) == 0 then
                    WriteByte(Save+0x2638,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --Start of Never Land
            if ReadShort(Now+0) == 0x40B and ReadShort(Now+8) == 0x1 then
                if ReadByte(Save+0x2658) == 0 then
                    WriteByte(Save+0x2658,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --End of Dwarf Woodlands
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0702 then
                if ReadByte(Save+0x255C) == 0 then
                    WriteByte(Save+0x255C,1)
                    WriteInt(Now+0,0x00010702)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x18)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x293D,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Castle of Dreams 1
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x00000103 then
                if ReadByte(Save+0x257C) == 0 then
                    WriteByte(Save+0x257C,1)
                    WriteInt(Now+0,0x00630103)
                    WriteShort(Now+4,0x04)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2941,0x0122)
                    WriteShort(Save+0x14,0x0103)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Castle of Dreams 2
            if ReadShort(Now+0) == 0x3207 and ReadInt(Now+0x10) == 0x00000103 then
                if ReadByte(Save+0x257C) == 0 then
                    WriteByte(Save+0x257C,1)
                    WriteInt(Now+0,0x00630103)
                    WriteShort(Now+4,0x04)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2941,0x0122)
                    WriteShort(Save+0x14,0x0103)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Enchanted Dominion 1
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0204 then
                if ReadByte(Save+0x259C) == 0 then
                    WriteByte(Save+0x259C,1)
                    WriteInt(Now+0,0x00010604)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x18)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2945,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Enchanted Dominion 2
            if ReadShort(Now+0) == 0x3207 and ReadShort(Now+0x10) == 0x0204 then
                if ReadByte(Save+0x259C) == 0 then
                    WriteByte(Save+0x259C,1)
                    WriteInt(Now+0,0x00010604)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x18)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2945,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of Radiant Garden 1
            if ReadShort(Now+0) == 0x0306 and ReadShort(Now+0x10) == 0x0111 then
                WriteInt(Now+0,0x00013207)
                WriteShort(Now+4,0x37)
                WriteShort(Now+6,0x37)
                WriteShort(Now+8,0x37)
            end
            --Start of Radiant Garden 2
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x00013207 then
                if ReadByte(Save+0x25D8) == 0 then
                    WriteByte(Save+0x25D8,1)
                    WriteShort(Now+0,0x0306)
                    WriteShort(Now+4,0x40)
                    WriteShort(Now+6,0x40)
                    WriteShort(Now+8,0x40)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    end
                end
            end
            --End of Radiant Garden
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0306 then
                if ReadByte(Save+0x25DC) == 0 then
                    WriteByte(Save+0x25DC,1)
                    WriteInt(Now+0,0x00340306)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x294D,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Disney Town 1
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x0000020C then
                WriteShort(Now+0,0x020C)
                WriteShort(Now+4,0x54)
                WriteShort(Now+6,0x54)
                WriteShort(Now+8,0x54)
            end
            --End of Disney Town 2
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0B0C then
                if ReadByte(Save+0x269C) == 0 then
                    WriteByte(Save+0x269C,1)
                    WriteInt(Now+0,0x0033020C)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2965,0x0122)
                    WriteByte(Save+0x282C,ReadByte(Save+0x282C)+1) --Moogle Level
                    WriteShort(Save+0x14,0x020C)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Olympus Coliseum
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0508 then
                if ReadByte(Save+0x261C) == 0 then
                    WriteByte(Save+0x261C,1)
                    WriteInt(Now+0,0x00000508)
                    WriteShort(Now+4,0x19)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2955,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Deep Space
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0B09 then
                if ReadByte(Save+0x263C) == 0 then
                    WriteByte(Save+0x263C,1)
                    WriteInt(Now+0,0x00030909)
                    WriteShort(Now+4,0x19)
                    WriteShort(Now+6,0x18)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2959,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Never Land
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x0000010B then
                if ReadByte(Save+0x265C) == 0 then
                    WriteByte(Save+0x265C,1)
                    WriteInt(Now+0,0x0063010B)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2961,0x0122)
                    WriteShort(Save+0x14,0x010B)
                    WriteShort(Save+0x19DE,0x0000)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Start of The Mysterious Tower
            if ReadShort(Now+0) == 0x0105 and ReadShort(Now+0x10) == 0x0111 then
                WriteShort(Now+0,0x0205)
                WriteShort(Now+4,0x36)
                WriteShort(Now+6,0x36)
                WriteShort(Now+8,0x36)
            end
            --End of The Mysterious Tower
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0105 then
                if ReadByte(Save+0x25BC) == 0 then
                    WriteByte(Save+0x25BC,1)
                    WriteInt(Now+0,0x00010405)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2949,0x0122)
                    WriteShort(Save+0x14,0x0405)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Land of Departure & Destiny Islands 1
            if ReadShort(Now+0) == 0x0111 and ReadByte(Save+0x2658) == 0x0A then
                WriteShort(Save+0x19DE,0x01)
                WriteShort(Now+8,0x01)
            end
            --Land of Departure & Destiny Islands 2
            if ReadShort(Now+0) == 0x0205 and ReadShort(Save+0x19DE) == 0x0001 then
                WriteInt(Now+0,0x0000010D)
                WriteShort(Now+4,0x40)
                WriteShort(Now+6,0x40)
                WriteShort(Now+8,0x40)
                WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
            end
            --Land of Departure & Destiny Islands 3
            if ReadShort(Now+0) == 0x0111 and ReadByte(Save+0x2658) == 0x0B then
                WriteInt(Now+0,0x00000101)
                WriteShort(Now+4,0x48)
                WriteShort(Now+6,0x48)
                WriteShort(Now+8,0x48)
                WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
            end
            --Land of Departure & Destiny Islands 4
            if ReadShort(Now+0) == 0x010A and ReadShort(Now+8) == 0x0038 then
                WriteShort(Save+0x2939,0x0222)
                WriteShort(Save+0x19DE,0x0000)
                WriteInt(Save+0x2990,0x00000000)
            end
            --Normal Summit -> Destroyed Summit (Post Destiny Islands)
            if ReadShort(Now+0) == 0x0601 and ReadShort(Save+0x2939) == 0x0222 then
                WriteInt(Now+0,0x00631001)
                WriteShort(Now+4,0x01)
                WriteShort(Now+6,0x00)
                WriteShort(Now+8,0x16)
            end
            --Destroyed Land of Departure Text 1
            if ReadShort(Now+0) == 0x0111 then
                WriteString(RoomNameText+0xDC,"???   ")
            end
            --Destroyed Land of Departure Text 2
            if ReadByte(Now+0) == 0x01 then
                WriteString(RoomNameText+0xDC,"Summit")
            end
            --??? Fight
            if ReadInt(Now+0) == 0x00631001 and ReadShort(Now+0x20) == 0x1001 then
                WriteByte(Now+2,0x00)
                WriteShort(Now+4,0x49)
                WriteShort(Now+6,0x49)
                WriteShort(Now+8,0x49)
            end
            --Pre-Vanitas I Fight 1
            if ReadInt(Now+0) == 0x0063010D and ReadByte(Save+0x26B8) == 0 then
                WriteInt(Now+0,0x00003207)
                WriteShort(Now+4,0x3A)
                WriteShort(Now+6,0x3A)
                WriteShort(Now+8,0x3A)
            end
            --Pre-Vanitas I Fight 2
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x00003207 then
                if ReadByte(Save+0x26B8) == 0 then
                    WriteByte(Save+0x26B8,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                    WriteByte(Save+0x2821,ReadByte(Save+0x2821)+1)
                    WriteInt(Now+0,0x0000010D)
                    WriteShort(Now+4,0x35)
                    WriteShort(Now+6,0x35)
                    WriteShort(Now+8,0x35)
                end
            end
            --Post Vanitas I Fight
            if ReadShort(Now+0) == 0x3207 and ReadShort(Now+0x10) == 0x010D then
                if ReadByte(Save+0x26BC) == 0 then
                    WriteByte(Save+0x26BC,1)
                    WriteInt(Now+0,0x0063010D)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x14,0x010D)
                    WriteInt(Save+0x2A04,0x00000000)
                    WriteByte(Save+0x2821,10)
                    WriteByte(Save+0x13DA,0x01) --The Keyblade Graveyard: Badlands MAP
                    WriteByte(Save+0x13DE,0x16) --The Keyblade Graveyard: Badlands EVENT
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --The Keyblade Graveyard: Fissure Room Name
            if ReadByte(Save+0x26B5) < 0x08 then
                WriteString(RoomNameText+0x9DD,"Seat of War") --Changes The Keyblade Graveyard: Fissure's Room Name
                WriteByte(RoomNameText+0x9E8,0x00) --Makes sure Room Name text doesn't overlap
            else
                WriteString(RoomNameText+0x9DD,"Fissure") --Fixes Room Name text back to normal
                WriteInt(RoomNameText+0x9E4,0x79654B00)
                WriteByte(RoomNameText+0x9E8,0x62)
            end
            --Start of The Keyblade Graveyard
            if ReadShort(Now+0) == 0x070D and ReadShort(RoomNameText+0x9DD) == 0x6553 then
                WriteInt(Now+0,0x0000020D)
                WriteShort(Now+4,0x42)
                WriteShort(Now+6,0x42)
                WriteShort(Now+8,0x42)
            end
            --Start of Final Battles
            if ReadShort(Now+0) == 0x080D and ReadShort(Save+0x26BC) == 0 then
                WriteByte(Save+0x2821,10)
            end
            --[[Final Battle Requirements
            if ReadShort(Now+0) == 0x080D then 
                if ReadInt(Save+0x32B8) == 0x1F1F1F1C and ReadShort(Save+0x32BC) == 0x1F20 then
                    WriteShort(Now+0,0x080D)
                else
                    WriteInt(Now+0,0x0032070D)
                end
            end]]
            --Battle Level 10
            if ReadByte(Save+0x281B) >= 0x0A then
                WriteInt(Save+0x2815,0x0A0A0A0A) --LoD, DW, CS, ED
                WriteShort(Save+0x2819,0x0A0A) --TMT, RG
                WriteShort(Save+0x281C,0x0A0A) --OC, DS
                WriteInt(Save+0x281F,0x000A0A0A) --NL, DT, KG
            end
            --[[Dwarf Woodlands Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0A02 then
                if ReadShort(DWChestsV1+0x611) == 0x3230 then
                    WriteString(DWChestsV1+0x610,"g01sw00")
                end
                if ReadShort(DWChestsV2+0x01) == 0x3230 then
                    WriteString(DWChestsV2+0x00,"g01sw00")
                end
            end
            if ReadShort(Now+0) == 0x0B02 then
                if ReadShort(DWChestsV1+0x01) == 0x3230 then
                    WriteString(DWChestsV1+0x00,"g01sw00")
                end
            end
            --Castle of Dreams Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0103 then 
                if ReadShort(CoDChestsV1+1) == 0x3230 then
                    WriteString(CoDChestsV1+0,"g01cd00")
                end
                if ReadShort(CoDChestsV2+1) == 0x3230 then
                    WriteString(CoDChestsV2+0,"g01cd00")
                end
            end
            --Enchanted Dominion Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0804 then
                if ReadShort(EDChestsV1+1) == 0x3230 then
                    WriteString(EDChestsV1+0,"g01sb00")
                end
                if ReadShort(EDChestsV2+1) == 0x3230 then
                    WriteString(EDChestsV2+0,"g01sb00")
                end
            end
            --Radiant Garden Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0506 then
                if ReadShort(DWChestsV1+0x6C1) == 0x3230 then
                    WriteString(RGChestsV1+0x6C0,"g01rg00")
                end
                if ReadShort(RGChestsV2+0x01) == 0x3230 then
                    WriteString(RGChestsV2+0x00,"g01rg00")
                end
                if ReadShort(RGChestsV3+0x01) == 0x3230 then
                    WriteString(RGChestsV3+0x00,"g01rg00")
                end
            end
            if ReadShort(Now+0) == 0x0806 then
                if ReadShort(RGChestsV1+0x01) == 0x3230 then
                    WriteString(RGChestsV1+0x00,"g01rg00")
                end
            end
            --Disney Town Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x020C then
                if ReadShort(DTChestsV1+1) == 0x3230 then
                    WriteString(DTChestsV1+0,"g01dc00")
                end
            end
            --Olympus Coliseum Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0208 then
                if ReadShort(OCChestsV1+1) == 0x3230 then
                    WriteString(OCChestsV1+0,"g01he00")
                end
                if ReadShort(OCChestsV2+1) == 0x3230 then
                    WriteString(OCChestsV2+0,"g01he00")
                end
            end
            --Deep Space Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0509 then
                if ReadShort(DSChestsV1+0x01) == 0x3230 then
                    WriteString(DSChestsV1+0x00,"g01ls00")
                end
                if ReadShort(DSChestsV2+0x01) == 0x3230 then
                    WriteString(DSChestsV2+0x00,"g01ls00")
                end
            end
            if ReadShort(Now+0) == 0x0909 then
                if ReadShort(DSChestsV1+0x10D1) == 0x3230 then
                    WriteString(DSChestsV1+0x10D0,"g01ls00")
                end
            end
            --Never Land Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x070B then
                if ReadShort(NLChestsV1+1) == 0x3230 then
                    WriteString(NLChestsV1+0,"g01pp00")
                end
                if ReadShort(NLChestsV2+1) == 0x3230 then
                    WriteString(NLChestsV2+0,"g01pp00")
                end
            end
            --The Mysterious Tower Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0305 then
                if ReadShort(TMTChestsV+1) == 0x3230 then
                    WriteString(TMTChestsV+0,"g01yt00")
                end
            end
            --The Keyblade Graveyard Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x020D then
                if ReadShort(KGChestsV1+1) == 0x3230 then
                    WriteString(KGChestsV1+0,"g01kg00")
                end
                if ReadShort(KGChestsV2+1) == 0x3230 then
                    WriteString(KGChestsV2+0,"g01kg00")
                end
            end]]
            end
        --Aqua's Story
        if ReadByte(Save+0x10) == 0x01 then
            --Unlock All Worlds (New Game)
            if ReadShort(Now+0x10) == 0x0101 and ReadShort(Now+0) == 0x0111 then
                WriteShort(Save+0x2875,0x04C0) --Makes The Mysterious Tower not "clear" when entering Final Episode
            end
            --Always Have All Worlds Opened
            WriteByte(Save+0x2938,0x02) --The Land of Departure
            if ReadByte(Save+0x2939) == 0x34 then
                WriteByte(Save+0x2939,0x01)
            end
            WriteByte(Save+0x293C,0x02 * worlds_unlocked_array[2]) --Dwarf Woodlands
            WriteByte(Save+0x2940,0x02 * worlds_unlocked_array[3]) --Castle of Dreams
            WriteByte(Save+0x2944,0x02 * worlds_unlocked_array[4]) --Enchanted Dominion
            WriteByte(Save+0x2948,0x02 * worlds_unlocked_array[5]) --The Mysterious Tower
            WriteByte(Save+0x294C,0x02 * worlds_unlocked_array[6]) --Radiant Garden
            WriteByte(Save+0x2954,0x02 * worlds_unlocked_array[8]) --Olympus Coliseum
            WriteByte(Save+0x2958,0x02 * worlds_unlocked_array[9]) --Deep Space
            WriteByte(Save+0x295C,0x00 * worlds_unlocked_array[10]) --Destiny Islands
            if ReadShort(Save+0x25F5) == 0x0000 then
                WriteByte(Save+0x295D,0x08)
            else
                WriteByte(Save+0x295D,0x01)
            end
            WriteByte(Save+0x2960,0x02 * worlds_unlocked_array[11]) --Never Land
            WriteByte(Save+0x2964,0x02 * worlds_unlocked_array[12]) --Disney Town
            if read_number_of_wayfinders() == 3 then
                WriteByte(Save+0x2968,0x02) --Keyblade Graveyard
            end
            if ReadByte(Save+0x2969) == 0x15 then
                WriteByte(Save+0x2969,0x01)
            end
            --WriteByte(Save+0x2970,0x02) --Mirage Arena
            WriteInt(Save+0x2974,0x01010101)
            WriteInt(Save+0x2978,0x01010101)
            WriteInt(Save+0x297C,0x01010101)
            WriteShort(Save+0x2980,0x0101)
            WriteInt(Save+0x29F0,0x00000000) --Unlock The Keyblade Graveyard: Badlands Save Point on World Map
            WriteString(RoomNameText+0x77C,"Realm of Darkness")
            WriteByte(RoomNameText+0x78D,0x00)
            WriteInt(Save+0x2990,0x00000000) --Unlock The Land of Departure: Forecourt Save Point on World Map
            WriteInt(Save+0x298C,0x00000000) --Unlock The Land of Departure: Summit Save Point on World Map
            --All Tutorials Viewed (Except Command Styles & Mini-Games)
            if ReadShort(Now+0) == 0x0201 then
                WriteInt(Save+0x4E13,0x03030303)
                WriteInt(Save+0x4E17,0x00030303)
                WriteInt(Save+0x4E1B,0x07000007)
                WriteInt(Save+0x4E20,0x07070000)
                WriteInt(Save+0x4E26,0x0B000007)
                WriteInt(Save+0x4E2B,0x13130F0F)
            end
            --Start of Enchanted Dominion
            if ReadShort(Now+0) == 0x604 and ReadShort(Now+8) == 0x3B then
                if ReadByte(Save+0x2598) == 0 then
                    WriteByte(Save+0x2598,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Castle of Dreams
            if ReadShort(Now+0) == 0xA03 and ReadShort(Now+8) == 0x3D then
                if ReadByte(Save+0x2578) == 0 then
                    WriteByte(Save+0x2578,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Dwarf Woodlands
            if ReadShort(Now+0) == 0xB02 and ReadShort(Now+8) == 0x3C then
                if ReadByte(Save+0x2558) == 0 then
                    WriteByte(Save+0x2558,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of The Mysterious Tower
            if ReadShort(Now+0) == 0x205 and ReadShort(Now+8) == 0x34 then
                if ReadByte(Save+0x25B8) == 0 then
                    WriteByte(Save+0x25B8,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Radiant Garden
            if ReadShort(Now+0) == 0x306 and ReadShort(Now+8) == 0x4A then
                if ReadByte(Save+0x25D8) == 0 then
                    WriteByte(Save+0x25D8,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Disney Town
            if ReadShort(Now+0) == 0x20C and ReadShort(Now+8) == 0x5F then
                if ReadByte(Save+0x2698) == 0 then
                    WriteByte(Save+0x2698,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Olympus Coliseum
            if ReadShort(Now+0) == 0x108 and ReadShort(Now+8) == 0x41 then
                if ReadByte(Save+0x2618) == 0 then
                    WriteByte(Save+0x2618,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Deep Space
            if ReadShort(Now+0) == 0x309 and ReadShort(Now+8) == 0x3F then
                if ReadByte(Save+0x2638) == 0 then
                    WriteByte(Save+0x2638,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Never Land
            if ReadShort(Now+0) == 0x80B and ReadShort(Now+8) == 0x3B then
                if ReadByte(Save+0x2658) == 0 then
                    WriteByte(Save+0x2658,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --Start of Realm of Darkness
            if ReadShort(Now+0) == 0x1407 and ReadShort(Now+8) == 0x4D then
                if ReadByte(Save+0x25F8) == 0 then
                    WriteByte(Save+0x25F8,1)
                    WriteByte(Save+0x2815,ReadByte(Save+0x2815)+1)
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)+1)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)+1)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)+1)
                    WriteByte(Save+0x2819,ReadByte(Save+0x2819)+1)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)+1)
                    end
                    WriteByte(Save+0x281B,ReadByte(Save+0x281B)+1)
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)+1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)+1)
                    WriteByte(Save+0x281E,ReadByte(Save+0x281E)+1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)+1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)+1)
                end
            end
            --End of Castle of Dreams
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x00000703 then
                if ReadByte(Save+0x257C) == 0 then
                    WriteByte(Save+0x257C,1)
                    WriteInt(Now+0,0x00320703)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2941,0x0122)
                    WriteShort(Save+0x14,0x0703)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Dwarf Woodlands 1
            if ReadShort(Now+0) == 0x0111 and ReadInt(Now+0x10) == 0x00000A02 then
                if ReadByte(Save+0x255C) == 0 then
                    WriteByte(Save+0x255C,1)
                    WriteInt(Now+0,0x00630A02)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x293D,0x0122)
                    WriteShort(Save+0x14,0x0A02)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Dwarf Woodlands 2
            if ReadShort(Now+0) == 0x3207 and ReadInt(Now+0x10) == 0x00000A02 then
                if ReadByte(Save+0x255C) == 0 then
                    WriteByte(Save+0x255C,1)
                    WriteInt(Now+0,0x00630A02)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x293D,0x0122)
                    WriteShort(Save+0x14,0x0A02)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Dwarf Woodlands 3
            if ReadShort(Now+0) == 0x0B06 and ReadInt(Now+0x10) == 0x00000A02 then
                if ReadByte(Save+0x255C) == 0 then
                    WriteByte(Save+0x255C,1)
                    WriteInt(Now+0,0x00630A02)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x293D,0x0122)
                    WriteShort(Save+0x14,0x0A02)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Enchanted Dominion 1
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0904 then
                if ReadByte(Save+0x259C) == 0 then
                    WriteByte(Save+0x259C,1)
                    WriteInt(Now+0,0x00020804)
                    WriteShort(Now+4,0x02)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2945,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Enchanted Dominion 2
            if ReadShort(Now+0) == 0x3207 and ReadShort(Now+0x10) == 0x0904 then
                if ReadByte(Save+0x259C) == 0 then
                    WriteByte(Save+0x259C,1)
                    WriteInt(Now+0,0x00020804)
                    WriteShort(Now+4,0x02)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2945,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Enchanted Dominion 3
            if ReadShort(Now+0) == 0x0B06 and ReadShort(Now+0x10) == 0x0904 then
                if ReadByte(Save+0x259C) == 0 then
                    WriteByte(Save+0x259C,1)
                    WriteInt(Now+0,0x00020804)
                    WriteShort(Now+4,0x02)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2945,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Radiant Garden
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0306 then
                if ReadByte(Save+0x25DC) == 0 then
                    WriteByte(Save+0x25DC,1)
                    WriteInt(Now+0,0x00000306)
                    WriteShort(Now+4,0x19)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x294D,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --[[Quicker Fruitball
            if ReadShort(Now+0) == 0x0E0C and ReadInt(Timer+0) == 0x4628C000 then
                WriteInt(Timer+0,0x45610000)
            end]]
            --End of Disney Town 1
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x030C then
                WriteShort(Now+0,0x020C)
                WriteShort(Now+4,0x5E)
                WriteShort(Now+6,0x5E)
                WriteShort(Now+8,0x5E)
            end
            --End of Disney Town 2
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0B0C then
                if ReadByte(Save+0x269C) == 0 then
                    WriteByte(Save+0x269C,1)
                    WriteInt(Now+0,0x0033020C)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2965,0x0122)
                    WriteByte(Save+0x282C,ReadByte(Save+0x282C)+1) --Moogle Level
                    WriteShort(Save+0x14,0x020C)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Olympus Coliseum
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0108 then
                if ReadByte(Save+0x261C) == 0 then
                    WriteByte(Save+0x261C,1)
                    WriteInt(Now+0,0x00330108)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x00)
                    WriteShort(Save+0x2955,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Deep Space
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0909 then
                if ReadByte(Save+0x263C) == 0 then
                    WriteByte(Save+0x263C,1)
                    WriteInt(Now+0,0x00320909)
                    WriteShort(Now+4,0x19)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2959,0x0122)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --End of Never Land
            if ReadShort(Now+0) == 0x3207 and ReadShort(Now+0x10) == 0x080B then
                if ReadByte(Save+0x265C) == 0 then
                    WriteByte(Save+0x265C,1)
                    WriteInt(Now+0,0x0001080B)
                    WriteShort(Now+4,0x19)
                    WriteShort(Now+6,0x19)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x2961,0x0122)
                    WriteShort(Save+0x14,0x080B)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
            end
            --Destiny Islands 1
            if ReadShort(Now+0) == 0x0111 and ReadByte(Save+0x2658) == 0x0A then
                WriteShort(Now+0,0x3207)
                WriteShort(Now+4,0x42)
                WriteShort(Now+6,0x42)
                WriteShort(Now+8,0x42)
                WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
            end
            --Destiny Islands 2
            if ReadShort(Now+0) == 0x3207 and ReadShort(Now+0x10) == 0x020A then
                WriteInt(Now+0,0x000A0111)
                WriteShort(Now+4,0x00)
                WriteShort(Now+6,0x00)
                WriteShort(Now+8,0x00)
            end
            --Start of The Mysterious Tower 1
            if ReadShort(Now+0) == 0x0205 and ReadShort(Now+0x10) == 0x0111 then
                WriteShort(Now+0,0x3207)
                WriteShort(Now+4,0x43)
                WriteShort(Now+6,0x43)
                WriteShort(Now+8,0x43)
            end
            --Start of The Mysterious Tower 2
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x3207 then
                if ReadShort(Save+0x2949) == 0x0001 then
                    WriteShort(Now+0,0x0205)
                    WriteShort(Now+4,0x34)
                    WriteShort(Now+6,0x34)
                    WriteShort(Now+8,0x34)
                end
            end
            --End of The Mysterious Tower 1
            if ReadShort(Now+0) == 0x3207 and ReadInt(Now+0x10) == 0x00010405 then
                if ReadShort(Save+0x2949) == 0x0021 then
                    WriteInt(Now+0,0x00010405)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                    WriteShort(Save+0x14,0x0405)
                    WriteString(TMTBGM+0,"124dp_amb")
                    WriteByte(Save+0x2816,ReadByte(Save+0x2816)-2)
                    WriteByte(Save+0x2817,ReadByte(Save+0x2817)-2)
                    WriteByte(Save+0x2818,ReadByte(Save+0x2818)-2)
                    if ReadByte(Save+0x26BC) == 0 then
                        WriteByte(Save+0x281A,ReadByte(Save+0x281A)-2)
                    end
                    WriteByte(Save+0x281C,ReadByte(Save+0x281C)-1)
                    WriteByte(Save+0x281D,ReadByte(Save+0x281D)-1)
                    WriteByte(Save+0x281F,ReadByte(Save+0x281F)-1)
                    WriteByte(Save+0x2820,ReadByte(Save+0x2820)-1)
                end
            end
            --End of The Mysterious Tower 2
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x0405 then
                if ReadShort(Save+0x2949) == 0x0021 then
                    if ReadByte(Save+0x25BC) == 0 then
                        WriteByte(Save+0x25BC,1)
                        WriteShort(Now+0,0x3207)
                        WriteShort(Now+4,0x44)
                        WriteShort(Now+6,0x44)
                        WriteShort(Now+8,0x44)
                        WriteShort(Save+0x2949,0x0122)
                        WriteString(TMTBGM+0,"019iensid_f")
                        WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                    end
                end
            end
            --Normal Land of Departure -> Destroyed Land of Departure
            if ReadByte(Save+0x294A) == 0x01 then
                WriteByte(Save+0x293A,0x02)
            end
            --Normal Summit -> Destroyed Summit (Post The Mysterious Tower)
            if ReadByte(Save+0x293A) == 0x02 then
                if ReadShort(Now+0) == 0x0601 and ReadShort(Now+0x10) == 0x0111 then
                    WriteInt(Now+0,0x00631001)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x00)
                    WriteShort(Now+8,0x16)
                end
                WriteInt(Save+0x2984,0x00000000)
            end
            --Destroyed Land of Departure Text 1
            if ReadShort(Now+0) == 0x0111 then
                WriteString(RoomNameText+0xDC,"???   ")
            end
            --Destroyed Land of Departure Text 2
            if ReadByte(Now+0) == 0x01 then
                WriteString(RoomNameText+0xDC,"Summit")
            end
            --??? Fight
            if ReadInt(Now+0) == 0x00631001 and ReadShort(Now+0x20) == 0x1001 then
                WriteByte(Now+2,0x00)
                WriteShort(Now+4,0x50)
                WriteShort(Now+6,0x50)
                WriteShort(Now+8,0x50)
            end
            --The Keyblade Graveyard: Fissure Room Name
            if ReadByte(Save+0x26B4) < 0x04 then
                WriteString(RoomNameText+0x9DD,"Seat of War") --Changes The Keyblade Graveyard: Fissure's Room Name
                WriteByte(RoomNameText+0x9E8,0x00) --Makes sure Room Name text doesn't overlap
            else
                WriteString(RoomNameText+0x9DD,"Fissure") --Fixes Room Name text back to normal
                WriteInt(RoomNameText+0x9E4,0x79654B00)
                WriteByte(RoomNameText+0x9E8,0x62)
            end
            --Start of The Keyblade Graveyard
            if ReadShort(Now+0) == 0x070D and ReadShort(RoomNameText+0x9DD) == 0x6553 then
                WriteInt(Now+0,0x0000020D)
                WriteShort(Now+4,0x3B)
                WriteShort(Now+6,0x3B)
                WriteShort(Now+8,0x3B)
            end
            --[[Final Battle Requirements
            if ReadShort(Now+0) == 0x080D then 
                if ReadInt(Save+0x32B8) == 0x1F1F1F1C and ReadShort(Save+0x32BC) == 0x1F20 then
                    WriteShort(Now+0,0x080D)
                else
                    WriteInt(Now+0,0x0032070D)
                end
            end]]
            --
            --Start of Final Episode
            if ReadShort(Now+0) == 0x0105 and ReadShort(Now+8) == 0x0038 then
                WriteInt(Now+0,0x00000205)
                WriteShort(Now+4,0x37)
                WriteShort(Now+6,0x37)
                WriteShort(Now+8,0x37)
                WriteByte(Save+0x26BC,1)
                if ReadByte(Save+0x25D4) == 0x00 then
                    WriteByte(Save+0x2916,ReadByte(Save+0x2916)+5)
                else
                    WriteByte(Save+0x2916,ReadByte(Save+0x2916)+1)
                end
            end
            --Final Episode
            if ReadByte(Save+0x26BC) == 1 then
                if ReadByte(Save+0x294A) == 0x00 and ReadByte (Save+0x25B4) == 0x00 then
                    WriteByte(Save+0x2949,0x01)
                end
                WriteInt(Save+0x29B8,0x00000000)
                WriteInt(Save+0x29CC,0x00000000)
                WriteInt(Save+0x29F4,0x00000000) --Re-opens Seat of War
                WriteInt(Save+0x29F8,0x00000000) --Re-opens Twister Trench
                WriteInt(Save+0x29FC,0x00000000) --Re-opens Fissure
                WriteByte(Save+0x281A,0x0A) --Forces Radiant Garden's Battle Level to 10
                WriteByte(CharMod+0,0x02) --Changes Character from Armored Aqua to Normal Aqua
                if ReadByte(Save+0x25D4) >= 0x7F then
                    WriteInt(Save+0x29BC,0x00000000)
                end
            else
                WriteInt(Save+0x29B8,0xFFFFFFFE)
            end
            --Final Episode Room Names
            if ReadByte(Save+0x26BC) == 0x01 then
                if ReadByte(Now+0) == 0x06 then
                    WriteString(RoomNameText+0x41D,"Entryway") --Fixes Room Name text back to normal
                    WriteInt(RoomNameText+0x425,0x6E654300)
                    WriteInt(RoomNameText+0x429,0x6C617274)
                    WriteInt(RoomNameText+0x42D,0x75715320)
                    WriteInt(RoomNameText+0x431,0x00657261)
                    WriteString(RoomNameText+0x478,"Front Doors") --Fixes Room Name text back to normal
                    WriteInt(RoomNameText+0x483,0x72755000)
                    WriteInt(RoomNameText+0x487,0x63696669)
                    WriteShort(RoomNameText+0x48B,0x7461)
                else
                    WriteString(RoomNameText+0x41D,"Central Square (Night)") --Changes Radiant Garden: Entryway's Room Name
                    WriteByte(RoomNameText+0x433,0x00) --Makes sure Room Name text doesn't overlap
                end
            end
            --Final Episode Radiant Garden (if you never entered the world) 1
            if ReadByte(Save+0x26BC) == 0x01 and ReadByte(Save+0x25D4) == 0x00 then
                WriteString(RoomNameText+0x478,"Central Square (Day)") --Changes Radiant Garden: Front Doors's Room Name
                WriteByte(RoomNameText+0x48C,0x00) --Makes sure Room Name text doesn't overlap
            end
            --Final Episode Radiant Garden (if you never entered the world) 2
            if ReadShort(Now+0) == 0x0A06 and ReadByte(Save+0x25D4) == 0x00 then
                WriteInt(Now+48,0x00000306)
            end
            if ReadShort(Now+0) == 0x0A06 and ReadShort(Now+48) == 0x0306 then
                WriteInt(Now+0,0x00000306)
                WriteShort(Now+4,0x4A)
                WriteShort(Now+6,0x4A)
                WriteShort(Now+8,0x4A)
            end
            --Final Episode Keyblade Graveyard
            if ReadShort(Now+0) == 0x080D and ReadByte(Save+0x26BC) == 0x01 then
                WriteInt(Now+0,0x0000070D)
                WriteShort(Now+4,0x00)
                WriteShort(Now+6,0x00)
                WriteShort(Now+8,0x16)
            end
            --Final Terra-Xehanort
            if ReadShort(Now+0) == 0x0206 and ReadShort(Now+0x10) == 0x0111 then
                WriteInt(Now+0,0x00000D06)
                WriteShort(Now+4,0x4E)
                WriteShort(Now+6,0x4E)
                WriteShort(Now+8,0x4E)
            end
            --Start of Realm of Darkness
            if ReadShort(Now+0) == 0x010A and ReadShort(Save+0x25F5) == 0x0000 then
                WriteShort(Now+0,0x1407)
                WriteShort(Now+4,0x4D)
                WriteShort(Now+6,0x4D)
                WriteShort(Now+8,0x4D)
                WriteByte(Save+0x295D,0x01)
            end
            --Entering Realm of Darkness 1
            if ReadShort(Now+48) == 0xFF0A and ReadShort(Save+0x25F5) == 0x0001 then
                WriteInt(Now+48,0x00631407)
                WriteShort(Now+4,0x00)
                WriteShort(Now+6,0x01)
                WriteShort(Now+8,0x00)
                WriteShort(Save+0x14,0x1407)
            end
            --Entering Realm of Darkness 2
            if ReadShort(Now+48) == 0xFF0A and ReadShort(Save+0x25F5) > 0x0008 then
                WriteInt(Now+48,0x00631607)
                WriteShort(Now+4,0x00)
                WriteShort(Now+6,0x00)
                WriteShort(Now+8,0x00)
                WriteShort(Save+0x14,0x1607)
            end
            --Leaving Realm of Darkness 1
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x1407 then
                WriteShort(Now+0x10,0111)
                WriteByte(Now+2,0x0A)
                WriteByte(Save+0x16,0x0A)
            end
            --Leaving Realm of Darkness 2
            if ReadShort(Now+0) == 0x0111 and ReadShort(Now+0x10) == 0x1607 then
                WriteShort(Now+0x10,0x0111)
                WriteByte(Now+2,0x0A)
                WriteByte(Save+0x16,0x0A)
            end
            --End of Realm of Darkness
            if ReadShort(Now+0) == 0x1807 and ReadShort(Now+0x10) == 0x1707 then
                if ReadByte(Save+0x25FC) == 0 then
                    WriteByte(Save+0x25DB,1)
                    WriteByte(Save+0x2658,ReadByte(Save+0x2658)+1)
                end
                WriteInt(Now+0,0x00021607)
                WriteShort(Now+4,0x00)
                WriteShort(Now+6,0x00)
                WriteShort(Now+8,0x00)
                WriteShort(Save+0x14,0x1607)
                WriteByte(Save+0x25F5,0x0F)
            end
            --Dark Hide Fight
            if ReadByte(Save+0x25F5) == 0x0F then
                if ReadShort(Now+0) == 0x1707 and ReadShort(Now+0x10) == 0x1607 then
                    WriteShort(Now+0,0x1707)
                    WriteShort(Now+4,0x01)
                    WriteShort(Now+6,0x01)
                    WriteShort(Now+8,0x01)
                end
            end
            --Secret Episode Ending
            if ReadByte(Save+0x25FC) == 1 then
                if ReadShort(Now+0) == 0x040A and ReadShort(Now+48) == 0xFF81 then
                    WriteShort(Now+48,0x00001807)
                end
            end
            --Battle Report (if Secret Episode is finished) 1
            if ReadShort(Now+0) == 0x1807 and ReadShort(Now+0x10) == 0x040A then
                WriteInt(Now+4,0x00520052)
                WriteShort(Now+8,0x52)
            end
            --Battle Report (if Secret Episode is finished) 2
            if ReadShort(Now+0) == 0x1807 and ReadShort(Now+48) == 0x1807 then
                WriteShort(Now+48,0xFF81)
                WriteShort(Save+0x14,0x1607)
            end
            --Battle Level 10
            if ReadByte(Save+0x281E) >= 0x0A then
                WriteInt(Save+0x2815,0x0A0A0A0A) --LoD, DW, CS, ED
                WriteInt(Save+0x2819,0x0A0A0A0A) --TMT, RG, RoD, OC
                WriteByte(Save+0x281D,0x0A) --DS
                WriteInt(Save+0x281F,0x000A0A0A) --NL, DT, KG
            end
            --[[Castle of Dreams Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0503 then
                if ReadShort(CoDChestsA1+1) == 0x3230 then
                    WriteString(CoDChestsA1+0,"g01cd00")
                end
                if ReadShort(CoDChestsA2+1) == 0x3230 then
                    WriteString(CoDChestsA2+0,"g01cd00")
                end
                if ReadShort(CoDChestsA3+1) == 0x3230 then
                    WriteString(CoDChestsA3+0,"g01cd00")
                end
            end
            --Dwarf Woodlands Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0602 then
                if ReadShort(DWChestsA1+0x01) == 0x3230 then
                    WriteString(DWChestsA1+0x00,"g01sw00")
                end
                if ReadShort(DWChestsA2+0x01) == 0x3230 then
                    WriteString(DWChestsA2+0x00,"g01sw00")
                end
            end
            if ReadShort(Now+0) == 0x0B02 then
                if ReadShort(DWChestsA1+0x21) == 0x3230 then
                    WriteString(DWChestsA1+0x20,"g01sw00")
                end
            end
            --Enchanted Dominion Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0104 then
                if ReadShort(EDChestsA1+1) == 0x3230 then
                    WriteString(EDChestsA1+0,"g01sb00")
                end
                if ReadShort(EDChestsA2+1) == 0x3230 then
                    WriteString(EDChestsA2+0,"g01sb00")
                end
            end
            --The Mysterious Tower Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0305 then
                if ReadShort(TMTChestsA+1) == 0x3230 then
                    WriteString(TMTChestsA+0,"g01yt00")
                end
            end
            --Radiant Garden Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0A06 then
                if ReadShort(RGChestsA1+0x01) == 0x3230 then
                    WriteString(RGChestsA1+0x00,"g01rg00")
                end
                if ReadShort(RGChestsA2+0x01) == 0x3230 then
                    WriteString(RGChestsA2+0x00,"g01rg00")
                end
            end
            if ReadShort(Now+0) == 0x0806 then
                if ReadShort(RGChestsA1+0x41) == 0x3230 then
                    WriteString(RGChestsA1+0x40,"g01rg00")
                end
            end
            --Disney Town Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x020C then
                if ReadShort(DTChestsA1+1) == 0x3230 then
                    WriteString(DTChestsA1+0,"g01dc00")
                end
            end
            --Olympus Coliseum Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0208 then
                if ReadShort(OCChestsA1+1) == 0x3230 then
                    WriteString(OCChestsA1+0,"g01he00")
                end
                if ReadShort(OCChestsA2+1) == 0x3230 then
                    WriteString(OCChestsA2+0,"g01he00")
                end
            end
            --Deep Space Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x0209 then
                if ReadShort(DSChestsA1+0xB1) == 0x3230 then
                    WriteString(DSChestsA1+0xB0,"g01ls00")
                end
                if ReadShort(DSChestsA2+0x01) == 0x3230 then
                    WriteString(DSChestsA2+0x00,"g01ls00")
                end
            end
            if ReadShort(Now+0) == 0x0E09 then
                if ReadShort(DSChestsA1+0x01) == 0x3230 then
                    WriteString(DSChestsA1+0x00,"g01ls00")
                end
            end
            --Never Land Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x070B then
                if ReadShort(NLChestsA1+1) == 0x3230 then
                    WriteString(NLChestsA1+0,"g01pp00")
                end
                if ReadShort(NLChestsA2+1) == 0x3230 then
                    WriteString(NLChestsA2+0,"g01pp00")
                end
            end
            --The Keyblade Graveyard Large Chests -> Small Chests
            if ReadShort(Now+0) == 0x020D then
                if ReadShort(KGChestsA1+1) == 0x3230 then
                    WriteString(KGChestsA1+0,"g01kg00")
                end
                if ReadShort(KGChestsA2+1) == 0x3230 then
                    WriteString(KGChestsA2+0,"g01kg00")
                end
            end]]
        end
    end
end