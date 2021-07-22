local function convert( chars, dist, inv )
    return string.char( ( string.byte( chars ) - 32 + ( inv and -dist or dist ) ) % 95 + 32 )
end

local function crypt(str,k,inv)
    local enc= "";
    for i=1,#str do
        if (#str-k[5] >= i or not inv) then
            for inc=0,3 do
                if(i%4 == inc)then
                    enc = enc .. convert(string.sub(str,i,i),k[inc+1],inv);
                    break
                end
            end
        end
    end
    -- does this look dumb to you yet?
    if (not inv) then
        for i=1,k[5] do
            enc = enc .. string.char(math.random(32,126));
        end
    end
    return enc
end

local function getSerialTable(player)
    local tab = {}
    local serial = getPlayerSerial(player)
    for i=1, 5 do
        table.insert(tab,string.byte(string.sub(serial, i, i)))
    end
    return tab
end

function encryptString(string, player)
    return crypt(string,getSerialTable(player))
end

function decryptString(string, player)
    return crypt(string,getSerialTable(player), true)
end
