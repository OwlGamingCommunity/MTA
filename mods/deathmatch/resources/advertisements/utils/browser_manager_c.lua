BrowserManager = {
    developmentMode = false,
    gui = nil,
    browser = nil,
    position = Vector2(0, 0),
    size = Vector2(guiGetScreenSize()),

    open = function(self)
        self.gui = GuiBrowser(self.position, self.size, true, true, false)
        self.browser = self.gui:getBrowser()

        addEventHandler("onClientBrowserCreated", self.browser, function ()
            self.browser:loadURL(self.url)

            if self.developmentMode then
                setDevelopmentMode(true, true)
                self.browser:toggleDevTools(true)
            end
        end, false)
    end;

    close = function (self)
        self.gui:destroy()

        return true
    end;

    isOpen = function (self)
        return isElement(self.gui)
    end;

    toggle = function (self)
        return self:isOpen() and self:close() or self:open()
    end;

    executeJavascript = function (self, javascript)
        self.browser:executeJavascript(javascript)

        return self
    end;

    javascriptJsonEncode = function (tbl, encoded)
        local str = string.sub(toJSON(tbl), 2, -2)

        if encoded then
            return base64Encode(str)
        end

        return str
    end;
}