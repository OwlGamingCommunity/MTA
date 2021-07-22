--MAXIME
local messageLimit = 20
local threadLimit = 100
function getOneSMSThread(fromPhone, threadIndex)
    local thread = {}
    local query = mysql:query("SELECT *, TIME_TO_SEC(TIMEDIFF(NOW(), `date`)) AS `secdiff` FROM `phone_sms` WHERE (`from`='"..fromPhone.."' AND `to`='"..threadIndex.."') OR (`from`='"..threadIndex.."' AND `to`='"..fromPhone.."') ORDER BY `date` DESC LIMIT "..messageLimit)
    while true do
        local row = mysql:fetch_assoc(query)
        if not row then break end
        table.insert(thread, row)
    end
    return thread
end

function fetchSMS(fromPhone, forceUpdate, forceUpdateContactList1)
    fromPhone = tonumber(fromPhone)
    local SMSs = {}
    if fromPhone then
        if forceUpdateContactList1 then
            forceUpdateContactList(source, fromPhone)
        end

        local query = mysql:query("SELECT *, TO_SECONDS(`date`) AS `datesec` FROM `phone_sms` WHERE `from`='"..fromPhone.."' OR `to`='"..fromPhone.."' ORDER BY `date` DESC ")
        while true do
            local row = mysql:fetch_assoc(query)
            if not row then break end
            table.insert(SMSs, row)
        end
    end

    triggerClientEvent(source, "phone:receiveSMSFromServer", source, fromPhone, SMSs, forceUpdate)
end
addEvent("phone:fetchSMS", true)
addEventHandler("phone:fetchSMS", root, fetchSMS)

function fetchOneSMSThread(fetchForPhone, messageSentTo, outGoing, forceUpdateContactList1, limit)
    fetchForPhone = tonumber(fetchForPhone)
    messageSentTo = tonumber(messageSentTo)
    local SMSs = {}
    if fetchForPhone and messageSentTo then
        if forceUpdateContactList1 then
            forceUpdateContactList(source, fetchForPhone)
        end
        
        if limit and tonumber(limit) then
            limit = "LIMIT "..limit
        else
            limit = "LIMIT 10"
        end
        local query = mysql:query("SELECT *, TO_SECONDS(`date`) AS `datesec` FROM `phone_sms` WHERE (`from`='"..fetchForPhone.."' AND `to`='"..messageSentTo.."') OR (`from`='"..messageSentTo.."' AND `to`='"..fetchForPhone.."') ORDER BY `date` DESC "..limit)
        while query do
            local row = mysql:fetch_assoc(query)
            if not row then break end
            table.insert(SMSs, row)
        end
    end
    --outputDebugString("fetchOneSMSThread / "..getPlayerName(source))
    triggerClientEvent(source, "phone:receiveOneSMSThreadFromServer", source, fetchForPhone, messageSentTo, SMSs, outGoing)
end
addEvent("phone:fetchOneSMSThread", true)
addEventHandler("phone:fetchOneSMSThread", root, fetchOneSMSThread)

function sendSMS(from, to, content, private, showChatNotification)
    from = tonumber(from)
    to = tonumber(to)
    private = tonumber(private) == 1 and 1 or 0
    if not from or not to or not content or string.len(content) < 1 then
        return false
    end

    mysql:query_insert_free("INSERT INTO `phone_sms` SET `from`='"..from.."', `to`='"..to.."', `content`='"..exports.global:toSQL(content).."', private="..private)
    local loggedElements = {source, "ph"..tostring(from), "ph"..tostring(to) }

    if showChatNotification then
        outputChatBox("SMS to #" .. to .. ": " .. content, source, 120, 255, 80)
    end

    local alertUser = true
    if not isNumberAHotline(to) then
        local t_powerOn, t_ringtone, t_isSecret, t_isInPhonebook, t_boughtBy = getPhoneSettings(to, true)
        if not t_powerOn then --not existed
            local notExisted = "Delivery has failed to these recipients: #"..to..". Number does not exist."
            mysql:query_insert_free("INSERT INTO `phone_sms` SET `from`='"..to.."', `to`='"..from.."', `content`='"..exports.global:toSQL(notExisted).."' ")
            triggerEvent("phone:fetchOneSMSThread", source, from, to, true)

            exports['logs']:dbLog(source, 30, loggedElements, content)
            return false
        end

        if t_powerOn == 0 then 
            alertUser = false
        end
    end

    local found, target = searchForPhone(to)
    if found and target then
        triggerEvent("phone:fetchOneSMSThread", target, to, from)
        table.insert(loggedElements, target)
        if alertUser then
            triggerClientEvent(target, "newSMSReceived", resourceRoot, from, to, content)
        end
    end
    triggerEvent("phone:fetchOneSMSThread", source, from, to, true)

    exports['logs']:dbLog(source, 30, loggedElements, content)
end
addEvent("phone:sendSMS", true)
addEventHandler("phone:sendSMS", root, sendSMS)

for i = 1, 20 do
    addCommandHandler( "sms" .. tostring( i == 1 and "" or i ), function(thePlayer, theCommand, to, ...)
        if getElementData(thePlayer, "loggedin") ~= 1 then return end

        -- find the item with the matching id
        -- /sms is the first phone, /sms2 the second phone etc.
        to = tonumber(to)
        if to and ... then
            local count = 0
            local items = exports['item-system']:getItems(thePlayer)
            for _, v in ipairs(items) do
                if v[1] == 2 then -- it's a phone
                    count = count + 1
                    if count == i then
                        local from = v[2]
                        local message = table.concat({...}, " ")
                        local power = getPhoneSettings(from,  true)
                        if power and power ~= 0 then 
                            triggerEvent("phone:sendSMS", thePlayer, from, to, message, 0, true)
                            return
                        else
                            outputChatBox("Your phone needs to be powered on to be able to SMS.", thePlayer, 255, 0, 0)
                        end
                    end
                end
            end
        else
            outputChatBox("SYNTAX: /" .. theCommand .. " [Phone Number] [Message]", thePlayer, 255, 194, 14)
        end
    end)
end

function startRingingSMS(fromPhone, smsTone, volume)
    local phoneSettings = {getPhoneSettings(fromPhone, true)}
    turnedOn = phoneSettings[1]
    smsTone = phoneSettings[8]
    volume = phoneSettings[9]

    if turnedOn ~= 0 then 
        for _,nearbyPlayer in ipairs(exports.global:getNearbyElements(source, "player"), 10) do
            triggerClientEvent(nearbyPlayer, "startRinging", source, 2, smsTone, volume)
        end
        if smsTone > 1 then
            triggerEvent('sendAme', source, "'s cellphone starts to ring.")
        end
        outputChatBox("Your phone #"..fromPhone.." has received a new text message.", source) 
    end
end
addEvent("phone:startRingingSMS", true)
addEventHandler("phone:startRingingSMS", root, startRingingSMS)

function updateSMSViewedState(fromPhone, threadIndex)
    if mysql:query_free("UPDATE `phone_sms` SET `viewed`=1 WHERE `from`='"..threadIndex.."' AND `to`='"..fromPhone.."' ") then
        triggerEvent("phone:fetchOneSMSThread", source, fromPhone, threadIndex)
    end
end
addEvent("phone:updateSMSViewedState", true)
addEventHandler("phone:updateSMSViewedState", root, updateSMSViewedState)


function cleanUpOldSMS()
    mysql:query_free("DELETE FROM `phone_sms` WHERE DATEDIFF(NOW(),`date`) > 7  ")
end
addEventHandler("onResourceStart", resourceRoot, cleanUpOldSMS)
