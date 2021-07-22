local screen_width, screen_height = guiGetScreenSize()
local lBrowserManagement, wBrowserManagement

local res = { 1280, 1080, 900, 520 }
local browser_elem_width, browser_elem_height = 0, 0
for _, width in ipairs(res) do
    browser_elem_height = math.ceil(width * 9 / 16)
    browser_elem_width = width
    if screen_width > browser_elem_width + 10 or screen_height > browser_elem_height + 60 then
        break
    end
end

function loadBrowserTexture(data, reference)
    local width, height = browser_elem_width, browser_elem_height
    local bUnblock
    local wBrowser = guiCreateWindow((screen_width - width - 10) / 2, (screen_height - height - 60) / 2, width + 10, height + 60, "Projector #" .. tostring(data.id), false)
    guiWindowSetSizable(wBrowser, false)
    guiSetVisible(wBrowser, false)

    -- label to manage browsers
    guiSetVisible(lBrowserManagement, true)
    addEventHandler("onClientElementDestroy", wBrowser, function()
        guiSetInputEnabled(false)
        setTimer(function()
            -- do we have any browser still visible?
            guiSetVisible(lBrowserManagement, #getElementsByType("gui-browser", resourceRoot) > 0)
        end, 200, 1)
    end, false)

    -- gui browser
    local guiBrowser = guiCreateBrowser(5, 25, width, height, false, false, false, wBrowser)
    local realBrowser = guiGetBrowser(guiBrowser)
    addEventHandler("onClientBrowserCreated", guiBrowser, function()
        loadBrowserURL(source, data.url:sub(5))
        setBrowserVolume(source, 0)
    end)

    addEventHandler("onClientBrowserLoadingStart", realBrowser, function()
        setElementData(wBrowser, "blocked", nil, false)
        guiSetEnabled(getElementData(realBrowser, "bUnblock"), false)
    end)

    addEventHandler("onClientBrowserResourceBlocked", realBrowser, function(url, domain, reason)
        if reason == 0 then
            local blocked = getElementData(wBrowser, "blocked") or {}
            blocked[domain] = true
            setElementData(wBrowser, "blocked", blocked, false)

            guiSetEnabled(getElementData(realBrowser, "bUnblock"), true)
        end
    end)

    -- some element data
    setElementData(realBrowser, "window", wBrowser, false) -- we're not using getElementParent but instead this element data; which allows us to call destroyElement with the window instead
    setElementData(realBrowser, "data", data, false)
    setElementData(realBrowser, "reference", reference, false)

    createBrowserButtons(realBrowser)

    -- return a placeholder unless the url is whitelisted
    if isBrowserDomainBlocked(data.url:sub(5), true) == false then
        -- we're using a gui browser instead of a browser here in case we want to allow the users to interact with it.
        setElementData(realBrowser, "loaded", true, false)
        return realBrowser
    else
        setElementData(realBrowser, "loaded", false, false)
        outputDebugString("not streaming browser texture since " .. data.url:sub(5) .. " is not allowed (yet)")
        return dxCreateTexture("browser_placeholder.jpg", "argb", true, "clamp", "2d", 1)
    end
end

function createBrowserButtons(realBrowser)
    local width, height = browser_elem_width, browser_elem_height
    local wBrowser = getElementData(realBrowser, "window")
    local guiBrowser = getElementParent(realBrowser)
    local data = getElementData(realBrowser, "data")
    local reference = getElementData(realBrowser, "reference")
    local canModify = exports.global:hasItem(localPlayer, 4, reference.dimension) or exports.global:hasItem(localPlayer, 5, reference.dimension) or exports.global:hasItem(localPlayer, 248, data.id) or (exports.integration:isPlayerAdmin(client) and exports.global:isAdminOnDuty(client)) or exports.integration:isPlayerScripter(localPlayer)

    local existingButtons = getElementData(realBrowser, "buttons") or {}
    for _, v in ipairs(existingButtons) do
        if isElement(v) then
            destroyElement(v)
        end
    end

    local buttons = {}

    -- "closing" the browser window
    local x = width - 80
    local input_height = 25
    local bClose = guiCreateButton(x, height + 30, 75, input_height, "Close", false, wBrowser)
    addEventHandler("onClientGUIClick", bClose, function(button, state)
        if button == "left" and state == "up" then
            -- do not destroy the window or the browser here, just hide it.
            focusBrowser(nil)
            guiSetVisible(wBrowser, false)
            guiSetInputEnabled(false)
        end
    end, false)
    table.insert(buttons, bClose)

    -- reloading the current page
    x = x - 80
    local bReload = guiCreateButton(x, height + 30, 75, input_height, "Reload", false, wBrowser)
    addEventHandler("onClientGUIClick", bReload, function(button, state)
        if button == "left" and state == "up" then
            loadBrowserURL(realBrowser, getBrowserURL(realBrowser))
        end
    end, false)
    table.insert(buttons, bReload)

    x = x - 130
    local bUnblock = guiCreateButton(x, height + 30, 125, input_height, "Unblock Resources", false, wBrowser)
    addEventHandler("onClientGUIClick", bUnblock, function(button, state)
        if button == "left" and state == "up" then
            local blocked = getElementData(wBrowser, "blocked") or {}
            local t = {}
            for domain in pairs(blocked) do table.insert(t, domain) end
            requestBrowserDomains(t, false, function(accepted)
                if accepted then
                    loadBrowserURL(realBrowser, getBrowserURL(realBrowser))
                    setElementData(wBrowser, "blocked", nil, false)
                    guiSetEnabled(bUnblock, false)
                end
            end)
        end
    end, false)
    table.insert(buttons, bUnblock)

    -- extra functionality for google docs presentations
    local match = string.match(data.url:sub(5), "https://docs%.google%.com/presentation/d/([a-zA-Z0-9]+)/embed")
    if match then
        triggerServerEvent("frames:browser:requestSync", resourceRoot, data.id)

        if canModify then
            guiSetEnabled(guiBrowser, false) -- no interaction
            setElementData(guiBrowser, "state:presentation", match, false)

            x = x - 100
            local bPresentation = guiCreateButton(x, height + 30, 95, input_height, "Presentation", false, wBrowser)
            addEventHandler("onClientGUIClick", bPresentation, function()
                showPresentationControls(realBrowser)
                triggerEvent("onClientGUIClick", bClose, "left", "up")
            end, false)
            table.insert(buttons, bPresentation)
        end
    end

    -- url change
    if canModify then
        local eURL = guiCreateEdit(5, height + 30, x - 10, input_height, data.url:sub(5), false, wBrowser)
        addEventHandler("onClientGUIAccepted", eURL, function()
            local text = guiGetText(eURL) or ""
            if text:sub(1, 7) == "http://" or text:sub(1, 8) == "https://" then

                triggerServerEvent("frames:updateURL", resourceRoot, data.id, "cef+" .. text)
            else
                outputChatBox("URL needs to start with http:// or https://.", 255, 0, 0)
            end
        end)
        table.insert(buttons, eURL)
    end

    setElementData(realBrowser, "buttons", buttons, false)
    setElementData(realBrowser, "bUnblock", bUnblock, false)

    return true, bUnblock
end

--

local function showBrowser(browser)
    local data = getElementData(browser, "data")
    local url = data.url:sub(5)
    requestBrowserDomains({url}, true, function(accepted)
        if accepted then
            local window = getElementData(browser, "window")
            createBrowserButtons(browser)
            guiSetVisible(window, true)
            guiSetInputEnabled(true)

            if not getElementData(browser, "loaded") then
                setElementData(browser, "loaded", true, false)
                setTimer(loadBrowserURL, 50, 1, browser, url)

                local existing = loaded[data.id]
                if existing then
                    if getElementType(existing.texture) ~= "webbrowser" then
                        destroyElement(existing.texture)
                        existing.texture = browser
                        dxSetShaderValue(existing.shader, 'Tex0', browser)
                    end
                end
            end
        else
            outputDebugString("showBrowser: did not accept texture request")
        end
    end)
end

function showBrowserManagementGUI()
    if isElement(wBrowserManagement) then
        destroyElement(wBrowserManagement)
        wBrowserManagement = nil
    else
        local browsers = getElementsByType("gui-browser", resourceRoot)
        if #browsers == 1 then
            showBrowser(guiGetBrowser(browsers[1]))
        else
            local width, height = 350, 200
            wBrowserManagement = guiCreateWindow(screen_width - width, screen_height - height, width, height, "Browser Textures", false)
            guiWindowSetSizable(wBrowserManagement, false)

            local bClose = guiCreateButton(5, height - 25, screen_width - 10, 25, "Close", false, wBrowserManagement)
            addEventHandler("onClientGUIClick", bClose, function(button, state)
                if button == "left" and state == "up" then
                    showBrowserManagementGUI()
                end
            end, false)

            local grid = guiCreateGridList(5, 25, width - 10, height - 55, false, wBrowserManagement)

            local cID = guiGridListAddColumn(grid, "Projector", 0.2)
            local cURL = guiGridListAddColumn(grid, "URL", 0.75)

            for _, b in ipairs(browsers) do
                local browser = guiGetBrowser(b)
                local data = getElementData(browser, "data") or {}

                local row = guiGridListAddRow(grid)
                guiGridListSetItemText(grid, row, cID, data.id and ("#" .. tostring(data.id)) or "", false, false)
                guiGridListSetItemData(grid, row, cID, browser)

                local url = getBrowserURL(browser)
                if not url or url == "" then
                    url = data.url:sub(5)
                end
                guiGridListSetItemText(grid, row, cURL, url, false, false)

                -- hide browser window tho
                local window = getElementData(browser, "window")
                if guiGetVisible(window) then
                    guiSetVisible(window, false)
                    guiSetInputEnabled(false)
                end
            end

            addEventHandler("onClientGUIDoubleClick", grid, function(button, state)
                if button == "left" and state == "up" then
                    local row, col = guiGridListGetSelectedItem(grid)
                    if row == -1 then return end

                    local browser = guiGridListGetItemData(grid, row, cID)
                    if isElement(browser) then
                        showBrowser(browser)

                        showBrowserManagementGUI()
                    end
                end
            end, false)
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    lBrowserManagement = guiCreateLabel(0, 0, screen_width, 15, "Browser Textures", false)
    guiSetSize(lBrowserManagement, guiLabelGetTextExtent(lBrowserManagement) + 5, 14, false)
    guiSetPosition(lBrowserManagement, screen_width - guiLabelGetTextExtent(lBrowserManagement) - 5, screen_height - 40, false)
    guiSetAlpha(lBrowserManagement, 0.5)
    guiSetVisible(lBrowserManagement, false)

    addEventHandler("onClientMouseEnter", lBrowserManagement, function()
        guiSetAlpha(lBrowserManagement, 1)
    end, false)

    addEventHandler("onClientMouseLeave", lBrowserManagement, function()
        guiSetAlpha(lBrowserManagement, 0.5)
    end, false)

    addEventHandler("onClientGUIClick", lBrowserManagement, showBrowserManagementGUI, false)
    guiMoveToBack(lBrowserManagement)
end)

-- google docs presentation stuff
local wPresentationControls
local ePresentationPage

addEvent("frames:browser:sync", true)
addEventHandler("frames:browser:sync", root, function(id, data)
    if data.presentation_slide then
        for _, browser in ipairs(getElementsByType("webbrowser", resourceRoot)) do
            local d = getElementData(browser, "data") or {}
            if d.id == id then
                local url = "https://docs.google.com/presentation/d/" .. getElementData(browser, "state:presentation") .. "/embed#slide=" .. data.presentation_slide
                outputDebugString("Loading " .. url)
                loadBrowserURL(browser, url)

                setElementData(browser, "state:presentation_slide", data.presentation_slide, false)
                if isElement(ePresentationPage) then
                    guiSetText(ePresentationPage, tostring(data.presentation_slide))
                end
            end
        end
    end
end)

function closePresentationControls()
    if isElement(wPresentationControls) then
        destroyElement(wPresentationControls)
        wPresentationControls = nil
        ePresentationPage = nil
    end
end

function showPresentationControls(browser)
    closePresentationControls()

    local data = getElementData(browser, "data")
    if not data then return end

    local width, height = 160, 60
    wPresentationControls = guiCreateWindow((screen_width - width) / 2, 20, width, height, "Presentation", false)
    guiWindowSetSizable(wPresentationControls, false)
    setElementData(wPresentationControls, "browser", browser, false)

    local parentWindow = getElementData(browser, "window")
    addEventHandler("onClientElementDestroy", parentWindow, closePresentationControls)

    local bPrevious = guiCreateButton(5, 25, 20, 25, "<", false, wPresentationControls)
    addEventHandler("onClientGUIClick", bPrevious, function(button, state)
        if button == "left" and state == "up" then
            local currentPage = (getElementData(browser, "state:presentation_slide") or 1)
            if currentPage > 1 then
                triggerServerEvent("frames:browser:syncPresentation", resourceRoot, data.id, currentPage - 1)
            end
        end
    end, false)

    ePresentationPage = guiCreateEdit(35, 25, 50, 25, tostring(getElementData(browser, "state:presentation_slide") or 1), false, wPresentationControls)
    addEventHandler("onClientGUIAccepted", ePresentationPage, function()
        local v = tonumber(guiGetText(ePresentationPage))
        if v then
            triggerServerEvent("frames:browser:syncPresentation", resourceRoot, data.id, v)
        end
    end)

    local bNext = guiCreateButton(90, 25, 20, 25, ">", false, wPresentationControls)
    addEventHandler("onClientGUIClick", bNext, function(button, state)
        if button == "left" and state == "up" then
            local currentPage = (getElementData(browser, "state:presentation_slide") or 1)
            triggerServerEvent("frames:browser:syncPresentation", resourceRoot, data.id, currentPage + 1)
        end
    end, false)

    local bClose = guiCreateButton(130, 25, 20, 25, "x", false, wPresentationControls)
    addEventHandler("onClientGUIClick", bClose, function(button, state)
        if button == "left" and state == "up" then
            closePresentationControls()
            removeEventHandler("onClientElementDestroy", parentWindow, closePresentationControls)
        end
    end, false)
end
