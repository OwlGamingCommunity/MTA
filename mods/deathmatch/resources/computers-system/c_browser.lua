local browserName = "Chromium"
local wBrowser, zBrowser, cefBrowser, eAddressBar, bUnblockResources -- gui elements

local screenWidth, screenHeight = guiGetScreenSize()
-- uncomment to debug
local outputDebugString = function() end

-- fit the browser on the screen
local computerWidth = 1080
local computerHeight = 700
if screenWidth < computerWidth or screenHeight < computerHeight then
    -- smaller screen size
    screenWidth, screenHeight = 800, 500
end

-- position of the computer
local computerX = (screenWidth - computerWidth)/2
local computerY = (screenHeight - computerHeight)/2 + 10

local blockedResources = {}

-- split the url into different segments and fetch some information related to the domain mapping if available
local function getUrlInfo(url)
    local ssl = url:sub(1, 5) == "https"
    local segments = exports.global:split(url:gsub("http://", ""):gsub("https://", ""), "/")
    local domain = segments[1]

    table.remove(segments, 1)
    local query = "/" .. table.concat(segments, "/")

    local info = getDomainInformation(domain)
    return domain, query or "/", info, ssl
end

-- helper for requestBrowserDomains to return the domain and possibly the root domain
local function getRequestingDomain(url)
    local domain = getUrlInfo(url)
    local request = getDomainForRequestingWhitelist(domain)
    if isBrowserDomainBlocked(domain) and not isBrowserDomainBlocked(request) or domain == request then
        return {url}, true
    end
    return {request, domain}, false
end

-- switch between CEF (true) and old vG browser (false)
local function switchBrowserMode(new)
    setBrowserRenderingPaused(cefBrowser, not new)
    guiSetVisible(zBrowser, new)
    guiSetVisible(internet_pane, not new)
end

-- load CEF url without taking any mapping into account
function loadCEFURLDirectly(url)
    switchBrowserMode(true)
    local loaded = loadBrowserURL(cefBrowser, url)
    outputDebugString("Loading URL " .. url .. ", loaded? " .. tostring(loaded))
    if not loaded then
        local urls, is_url = getRequestingDomain(url)
        requestBrowserDomains(urls, is_url, function(wasAccepted)
            if wasAccepted then
                outputDebugString("User accepted domain request, loading " .. url)
                setTimer(function() loadBrowserURL(cefBrowser, url) end, 1000, 1)
            else
                outputDebugString("User declined domain request for " .. url)
                updateDisplayedInfo()
            end
        end)
    end
end

-- returns the formatted URL for the address bar
local function formatURL(domain, query, info, ssl)
    if info ~= nil then
        domain = info.fake
        if info.query and query == info.query then
            query = "/"
        end
    end
    local scheme = ssl and "https://" or ""


    return scheme .. domain .. query
end

-- main logic for deciding which site to load
local function loadURL(url)
    outputDebugString("Requesting URL " .. url)
    local domain, query, info, ssl = getUrlInfo(url)
    if info ~= nil then
        -- we're visiting a fake domain, replace it with the real one.
        if info.real then
            if query == "/" and (domain:gsub("www.", "") == info.fake or not info.append_query_only_on_fake_url) and info.query then
                query = info.query
            end

            domain = info.real

            local scheme = (ssl or info.ssl) and "https://" or "http://"
            loadCEFURLDirectly(scheme .. domain .. query)
        elseif info.fn then
            closeComputerWindow()
            info.fn()
        else
            get_page(domain .. query)
        end
    elseif isBlockedDomain(domain) then
        -- old, pre-CEF local browser emulation
        get_page("error_404")
    else
        -- not a domain we necessarily know anything about.
        loadCEFURLDirectly((ssl and "https://" or "http://") .. domain .. query)
    end
end

-- show the formatted url (with possibly replaced domains) in the browser.
function showFormattedURL(url)
    guiSetText(eAddressBar, (url and #url > 0) and formatURL(getUrlInfo(url)) or "")
end

-- update the browser title + url
function updateDisplayedInfo()
    guiSetText(wBrowser, getBrowserTitle(cefBrowser) .. " - " .. browserName)
    showFormattedURL(getBrowserURL(cefBrowser))
end

-- callback for user navigation.
local function navigatedToPage(url, blocked)
    local domain = getUrlInfo(url)
    if blocked then
        if isBlockedDomain(domain) then return end

        outputDebugString("Navigation to page " .. url .. " was blocked")

        local urls, is_url = getRequestingDomain(url)
        requestBrowserDomains(urls, is_url, function(wasAccepted)
            if wasAccepted then
                -- url = getBrowserURL(cefBrowser) maybe this gets around the iframe bug?
                outputDebugString("User accepted domain request, loading " .. url)
                setTimer(function() loadBrowserURL(cefBrowser, url) end, 1000, 1)
            else
                outputDebugString("User declined domain request for " .. url)
                updateDisplayedInfo()
            end
        end)
    else
        showFormattedURL(url)
    end
end

-- toggle the visibility of the "Unblock resources" button depending on whether or not we encountered blocked resources
local function toggleUnblockResources()
    local any = false
    for _ in pairs(blockedResources) do
        any = true
        break
    end

    if not any then
        guiSetSize(eAddressBar, computerWidth - 100, 25, false)
        guiSetVisible(bUnblockResources, false)
    else
        guiSetSize(eAddressBar, computerWidth - 225, 25, false)
        guiSetVisible(bUnblockResources, true)
    end
end

function openBrowser(home_url)
    closeBrowser()

    wBrowser = guiCreateWindow(computerX, computerY, computerWidth, computerHeight + 29, browserName, false)
    guiWindowSetSizable(wBrowser, false)

    -- toolbar
    eAddressBar = guiCreateEdit(60, 25, computerWidth - 100, 25, tostring(url), false, wBrowser)
    addEventHandler("onClientGUIAccepted", eAddressBar, function() loadURL(tostring(guiGetText(source))) end, false)
    addEventHandler("onClientGUIClick", eAddressBar, function() focusBrowser(nil) end, false)

    local bHomeButton = guiCreateButton(5, 25, 45, 25, "Home", false, wBrowser)
    addEventHandler("onClientGUIClick", bHomeButton, function(button, state) if button == "left" and state == "up" then loadURL(home_url) end end, false)

    local bCloseButton = guiCreateButton(computerWidth - 35, 25, 25, 25, "x", false, wBrowser)
    addEventHandler("onClientGUIClick", bCloseButton,
        function(button, state)
            if button == "left" and state == "up" then
                 closeBrowser()
                 if exports.phone:isPhoneGUICreated() then
                    setElementData(localPlayer, "exclusiveGUI", true)
                    exports.phone:drawPhoneHome()
                 end 
            end
        end, false)

    -- classic browser
    internet_pane = guiCreateScrollPane(0, 55, computerWidth, computerHeight - 35, false, wBrowser)
    guiScrollPaneSetScrollBars(internet_pane, false, false)
    guiSetVisible(internet_pane, false)

    address_bar = eAddressBar

    -- CEF
    blockedResources = {}
    bUnblockResources = guiCreateButton(computerWidth - 160, 25, 120, 25, "Unblock Resources", false, wBrowser)
    addEventHandler("onClientGUIClick", bUnblockResources, function(button, state)
        if button == "left" and state == "up" then
            local res = {}
            for domain in pairs(blockedResources) do
                table.insert(res, domain)
            end
            outputDebugString("requesting whitelisting of " .. toJSON(blockedResources))
            requestBrowserDomains(res, false, function(wasAccepted)
                if wasAccepted then
                    blockedResources = {}
                    toggleUnblockResources()

                    outputDebugString("User accepted domain request, reloading")
                    setTimer(function() loadBrowserURL(cefBrowser, getBrowserURL(cefBrowser)) end, 1000, 1)
                else
                    outputDebugString("User declined unblocking resources")
                    updateDisplayedInfo()
                end
            end)
        end
    end, false)

    zBrowser = guiCreateBrowser(0, 55, computerWidth, computerHeight - 35, false, false, false, wBrowser)
    addEventHandler("onClientBrowserCreated", zBrowser, function()
        cefBrowser = source

        -- browser was loaded successfully, open the default page
        loadURL(home_url)

        addEventHandler("onClientBrowserDocumentReady", source, updateDisplayedInfo)
        addEventHandler("onClientBrowserNavigate", source, navigatedToPage)
        addEventHandler("onClientBrowserLoadingStart", source, function() blockedResources = {} toggleUnblockResources() showFormattedURL() end)
        addEventHandler("onClientBrowserLoadingFailed", source, function(...) outputDebugString("Loading Failed: " .. toJSON({...})) end)
        addEventHandler("onClientBrowserResourceBlocked", source, function(url, domain, reason) if reason == 0 and not isBlockedDomain(domain) then blockedResources[domain] = true; toggleUnblockResources() end end)
    end)

    toggleUnblockResources()
    guiSetInputEnabled(true)
end
-- addCommandHandler("browser", function() guiSetInputEnabled(true) openBrowser("google.sa") end)

function closeBrowser()
    if cefBrowser then
        destroyElement(cefBrowser)
        cefBrowser = nil
    end

    if wBrowser then
        destroyElement(wBrowser)
        wBrowser = nil
    end
end

-- stone age browser emulator
function get_page(url)
    switchBrowserMode(false)

    url = url:gsub("%.", "_"):gsub("/","_"):gsub("-","_"):gsub("[^a-zA-Z0-9_]", ""):lower()
    if string.find(url, "www_") ~= 1 then
        url = "www_" .. url
    end
    if url:sub(#url, #url) == "_" then
        url = url:sub(1, #url - 1)
    end

    if isElement(bg) then
        destroyElement(bg)
        bg = nil
    end

    outputDebugString("loading stone age url " .. url)
    local status, error = pcall(loadstring( "return " .. url .. "()" ) )
    if not status then
        error_404()
    end
end

function setPageTitle(title)
    guiSetText(wBrowser, title .. " - Internet Explorer 6")
end
