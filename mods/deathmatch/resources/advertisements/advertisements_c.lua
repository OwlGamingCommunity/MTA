local AdvertisementsWindow = setmetatable({
    developmentMode = false,
    url = 'http://mta/local/advertisements.htm',

    setResults = function (self, results, page, totalPages)
        self:executeJavascript("vm.setResults('"..self.javascriptJsonEncode(results, true).."', "..page..", "..totalPages..");")
    end;

    setCurrentAdvertisement = function (self, result)
        self:executeJavascript("vm.setCurrentAdvertisement('"..self.javascriptJsonEncode(result, true).."');")
    end;

    canViewAdvertisements = function (self)
        return not getElementData(localPlayer, "adminjailed") 
            and getElementData(localPlayer, "jailed") ~= 1
            and getElementData(localPlayer, "dbid")
    end;

    pushInsufficientFunds = function (self, isFaction)
        self:executeJavascript('vm.setPushInsufficientFunds('..tostring(isFaction)..');')
    end;

    initUserData = function (self)
        local factions = {}
        for factionId in pairs(getElementData(localPlayer, "faction")) do
            if exports.factions:hasMemberPermissionTo(localPlayer, factionId, "make_ads") then
                factions[factionId] = exports.factions:getFactionName(factionId)
            end	
        end

        local isAdmin = exports.integration:isPlayerTrialAdmin(localPlayer)

        self:executeJavascript("vm.initUserData('"..self.javascriptJsonEncode(factions, true).."', "..tostring(isAdmin)..", "..getElementData(localPlayer, "dbid")..");")
    end;

    pushCooldown = function (self)
        self:executeJavascript('vm.pushCooldown();')
    end;
}, {
    __index = BrowserManager
})

addCommandHandler('ads', function ()
    if getElementData(localPlayer, "loggedin") ~= 1 then return false end

    -- Ensure the player should be able to see advertisements before opening.
    if not AdvertisementsWindow:isOpen() and not AdvertisementsWindow:canViewAdvertisements() then
        return
    end

    -- Open or close the advertisement window.
    AdvertisementsWindow:toggle()

    if AdvertisementsWindow:isOpen() then
        showCursor(true)
        guiSetInputMode('no_binds')
        addEventHandler("onClientBrowserDocumentReady", AdvertisementsWindow.browser, function () 
            AdvertisementsWindow:initUserData()
            triggerServerEvent('advertisements:fetch-page', localPlayer)
        end)
    else
        showCursor(false)
        guiSetInputMode('allow_binds')
    end
end, false, false)

--[[
    Server -> client events
]]
addEvent('advertisements:receive-page', true)
addEventHandler('advertisements:receive-page', root, function (results, page, totalPages)
    AdvertisementsWindow:setResults(results, page, totalPages)
end)

addEvent('advertisements:close-browser', true)
addEventHandler('advertisements:close-browser', root, function ()
    showCursor(false)
    guiSetInputMode('allow_binds')
    AdvertisementsWindow:close()
end)

addEvent('advertisements:push-insufficient-funds', true)
addEventHandler('advertisements:push-insufficient-funds', root, function (isFaction)
    AdvertisementsWindow:pushInsufficientFunds(isFaction)
end)

addEvent('advertisements:push-cooldown', true)
addEventHandler('advertisements:push-cooldown', root, function ()
    AdvertisementsWindow:pushCooldown()
end)

addEvent('advertisements:receive-single', true)
addEventHandler('advertisements:receive-single', root, function (result)
    AdvertisementsWindow:setCurrentAdvertisement(result)
end)

--[[
    Browser -> Client events
]]
addEvent('advertisements:fetch-page', true)
addEventHandler('advertisements:fetch-page', root, function (page, section) 
    triggerServerEvent('advertisements:fetch-page', localPlayer, page, section)
end)

addEvent('advertisements:fetch-single', true)
addEventHandler('advertisements:fetch-single', root, function (id)
    triggerServerEvent('advertisements:fetch-single', localPlayer, id)
end)

addEvent('advertisements:post-advertisement', true)
addEventHandler('advertisements:post-advertisement', root, function (advertisement)
    local advertisement = fromJSON(advertisement)

    triggerServerEvent('advertisements:post-advertisement', localPlayer, advertisement)
end)

addEvent('advertisements:push', true)
addEventHandler('advertisements:push', root, function (id)
    triggerServerEvent('advertisements:push', localPlayer, id)
end)

addEvent('advertisements:delete', true)
addEventHandler('advertisements:delete', root, function (id)
    triggerServerEvent('advertisements:delete', localPlayer, id)
end)