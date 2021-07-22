--[[
All config values stored here for ease of use.
New jail system by: Chaos for OwlGaming
]]
pd_offline_jail = false -- PD Offline Jailing enabled or disabled. Reminder: Always enabled for admins.
pd_update_access = 59 -- Allows this faction ID to update/remove offline prisoners
hourLimit = 0 -- 0 is infinite, otherwise this is the max they can jail in hours
onlineRatio = 0.1 -- 10% of time entered is to be spent online
offlineRatio = 0.9 -- 90% of time entered is to be spent offline

gateDim = 880
gateInt = 3
objectID = 2930

speakerDimensions = { [812] = true, [851] = true, [857] = true, [861] = true, [862] = true, [880] = true, [881] = true, [882] = true }
speakerInt = 3
speakerOutX, speakerOutY, speakerOutZ = -1046.16015625, -723.65625, 32.0078125

-- Skins, ID = clothing:id
-- Male Skins
bMale = 305
bMaleID = 22638
wMale = 305
wMaleID = 22639
aMale = 305
aMaleID = 22639

-- Female Skins
bFemale = 69
bFemaleID = 22640
wFemale = 69
wFemaleID = 22641
aFemale = 69
aFemaleID = 22641


cells = {
-- [codeName] = x, y, z, int, dim, 1 = OnlineTimer - 0 = OfflineTimer, locationCode
    ["1A"] = { 1049.2900390625, 1253.2626953125, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["2A"] = { 1049.3837890625, 1245.22265625, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["3A"] = { 1049.0947265625, 1235.3291015625, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["4A"] = { 1049.25390625, 1230.033203125, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["5A"] = { 1049.345703125, 1225.0263671875, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["6A"] = { 1049.2900390625, 1253.2626953125, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["7A"] = { 1049.2900390625, 1253.2626953125, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["8A"] = { 1049.3837890625, 1245.22265625, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["9A"] = { 1049.09375, 1239.6826171875, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["10A"] = { 1048.8310546875, 1235.080078125, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["11A"] = { 1049.2548828125, 1229.6875, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["12A"] = { 1049.544921875, 1224.658203125, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["1B"] = { 1024.697265625, 1252.55078125, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["2B"] = { 1024.41796875, 1244.0576171875, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["3B"] = { 1024.2490234375, 1238.84375, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["4B"] = { 1024.904296875, 1233.6982421875, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["5B"] = { 1024.4345703125, 1228.958984375, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["6B"] = { 1024.87109375, 1223.779296875, 1491.3601074219, 3, 880, type = 0, location = "Prison" },
    ["7B"] = { 1024.697265625, 1252.55078125, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["8B"] = { 1024.41796875, 1244.0576171875, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["9B"] = { 1024.2490234375, 1238.84375, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["10B"] = { 1024.904296875, 1233.6982421875, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["11B"] = { 1024.4345703125, 1228.958984375, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["12B"] = { 1024.87109375, 1223.779296875, 1495.5241699219, 3, 880, type = 0, location = "Prison" },
    ["1S"] = { 1483.5419921875, 1532.4033203125, 10.85150718689, 3, 812, type = 0, location = "Prison" },
    ["2S"] = { 1488.5341796875, 1532.455078125, 10.85150718689, 3, 812, type = 0, location = "Prison" },
    ["3S"] = { 1492.6748046875, 1532.3017578125, 10.85150718689, 3, 812, type = 0, location = "Prison" },
    -- PD
    ["PD1"] = { 1078.060546875, 1320.9462890625, 11.257937431335, 4, 2193, type = 0, location = "PD" },
    ["PD2"] = { 1083.09765625, 1320.55859375, 11.257937431335, 4, 2193, type = 0, location = "PD" },
    ["PD3"] = { 1088.5927734375, 1320.6669921875, 11.257937431335, 4, 2193, type = 0, location = "PD" },
    -- HP
    ["HP1"] = { 968.0068359375, 300.5751953125, 935.06091308594, 22, 3326, type = 0, location = "HP" },
    ["HP2"] = { 963.6513671875, 300.681640625, 935.06091308594, 22, 3326, type = 0, location = "HP" },
    ["HP3"] = { 959.0390625, 300.7958984375, 935.06091308594, 22, 3326, type = 0, location = "HP" },
}

arrestCols = {
    -- x, y, z, radius, int, dim
    ["Prison"] = {1432.146484375, 1496.7099609375, 10.878900527954, 12, 3, 851}, -- Main prison
    ["PD"] = {1077.232421875, 1327.0654296875, 11.257937431335, 12, 4, 2193}, -- PD
    ["HP"] = {969.390625, 306.9423828125, 936.46716308594, 12, 22, 3326} -- HP
}

releaseLocations = { -- This could probably be combined with above but ayy lmao? //Chaos
    -- x, y, z, int, dim
    ["Prison"] = {-1049.0595703125, -448.2744140625, 35.867908477783, 0, 0}, -- Main prison
    ["PD"] = {1544.5283203125, -1669.046875, 13.558586120605, 0, 0}, -- PD
    ["HP"] = {633.3251953125, -566.7724609375, 16.3359375, 0, 0} -- HP
}

gates = {
  -- ["cell"] = { openx, openy, openz, openRx, openRy, openRz, closedx, closedy, closedz, closedRx, closedRy, closedRz }
    ["1A"] = { 1047.1, 1253.2, 1493, 0, 0, 0, 1047.1, 1254.9, 1493, 0, 0, 0 },
    ["2A"] = { 1047.1, 1244.7, 1493, 0, 0, 0, 1047.1, 1246.4, 1493, 0, 0, 0 },
    ["3A"] = { 1047.1, 1239.7, 1493, 0, 0, 0, 1047.1, 1241.4, 1493, 0, 0, 0 },
    ["4A"] = { 1047.1, 1234.7, 1493, 0, 0, 0, 1047.1, 1236.4, 1493, 0, 0, 0 },
    ["5A"] = { 1047.1, 1229.7, 1493, 0, 0, 0, 1047.1, 1231.4, 1493, 0, 0, 0 },
    ["6A"] = { 1047.1, 1224.7, 1493, 0, 0, 0, 1047.1, 1226.4, 1493, 0, 0, 0 },
    ["7A"] = { 1047.1, 1253.2, 1497.1, 0, 0, 0, 1047.1, 1254.9, 1497.1, 0, 0, 0 },
    ["8A"] = { 1047.1, 1244.7, 1497.1, 0, 0, 0, 1047.1, 1246.4, 1497.1, 0, 0, 0 },
    ["9A"] = { 1047.1, 1239.7, 1497.1, 0, 0, 0, 1047.1, 1241.4, 1497.1, 0, 0, 0 },
    ["10A"] = { 1047.1, 1234.7, 1497.1, 0, 0, 0, 1047.1, 1236.4, 1497.1, 0, 0, 0 },
    ["11A"] = { 1047.1, 1229.7, 1497.1, 0, 0, 0, 1047.1, 1231.4, 1497.1, 0, 0, 0 },
    ["12A"] = { 1047.1, 1224.7, 1497.1, 0, 0, 0, 1047.1, 1226.4, 1497.1, 0, 0, 0 },
    ["1B"] = { 1027.2, 1254.8, 1493, 0, 0, 0, 1027.2, 1253.1, 1493, 0, 0, 0 },
    ["2B"] = { 1027.2, 1246.2, 1493, 0, 0, 0, 1027.2, 1244.5, 1493, 0, 0, 0 },
    ["3B"] = { 1027.2, 1241.2, 1493, 0, 0, 0, 1027.2, 1239.5, 1493, 0, 0, 0 },
    ["4B"] = { 1027.2, 1236.2, 1493, 0, 0, 0, 1027.2, 1234.5, 1493, 0, 0, 0 },
    ["5B"] = { 1027.2, 1231.2, 1493, 0, 0, 0, 1027.2, 1229.5, 1493, 0, 0, 0 },
    ["6B"] = { 1027.2, 1226.3, 1493, 0, 0, 0, 1027.2, 1224.6, 1493, 0, 0, 0 },
    ["7B"] = { 1027.2, 1254.8, 1497.1, 0, 0, 0, 1027.2, 1253.1, 1497.1, 0, 0, 0 },
    ["8B"] = { 1027.2, 1246.2, 1497.1, 0, 0, 0, 1027.2, 1244.5, 1497.1, 0, 0, 0 },
    ["9B"] = { 1027.2, 1241.2, 1497.1, 0, 0, 0, 1027.2, 1239.5, 1497.1, 0, 0, 0 },
    ["10B"] = { 1027.2, 1236.2, 1497.1, 0, 0, 0, 1027.2, 1234.5, 1497.1, 0, 0, 0 },
    ["11B"] = { 1027.2, 1231.2, 1497.1, 0, 0, 0, 1027.2, 1229.5, 1497.1, 0, 0, 0 },
    ["12B"] = { 1027.2, 1226.3, 1497.1, 0, 0, 0, 1027.2, 1224.6, 1497.1, 0, 0, 0 },
}

local temp = {} -- Initialize Cols
for k, v in pairs( arrestCols ) do
  local sphere = createColSphere(v[1], v[2], v[3], v[4])
  setElementDimension(sphere, v[6])
  setElementInterior(sphere, v[5])
  setElementData(sphere, "location", k)
  temp[k] = sphere
end
arrestCols = temp
temp = nil

function isCloseTo( thePlayer, targetPlayer )
  if exports.integration:isPlayerTrialAdmin(thePlayer) then
    return true
  end

  if exports.factions:isPlayerInFaction(thePlayer, pd_update_access) then
    return true
  end

  if targetPlayer then
    local dx, dy, dz = getElementPosition(thePlayer)
    local dx1, dy1, dz1 = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(dx, dy, dz, dx1, dy1, dz1) < ( 30 ) then
      if getElementDimension(thePlayer) == getElementDimension(targetPlayer) then
        return true
      end
    end
  end
    return false
end

function isInArrestColshape( thePlayer )
    for k,v in pairs(arrestCols) do
        if isElementWithinColShape( thePlayer, v ) and (getElementDimension( thePlayer ) == getElementDimension( v )) then
            return k
        end
    end

    return false
end

function getCells( arrestLocation )
    local temp = {}
    for k,v in pairs(cells) do
        if v.location == arrestLocation then
            temp[k] = v
        end
    end
    return temp
end

function cleanMath(number)
    if type(number) == "boolean" then
        return
    end
    local currenttime = getRealTime()
    local currentTime = currenttime.timestamp
    local remainingtime = tonumber(number) - currentTime
    local hours = (remainingtime /3600)
    local days = math.floor(hours/24)
    local remaininghours = hours - days*24
    local hours = ("%.1f"):format(hours - days*24)

    if remainingtime<0 then
        return "Awaiting", "Release", tonumber(remainingtime)
    end

    if days>99 then
      return "Life", "Sentence", tonumber(remainingtime)
    end

    return days, hours, tonumber(remainingtime)
end
