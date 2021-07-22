function showInvoiceWindow(estimatedCosts)
    if isElement(invoiceWindow) then
        destroyElement(invoiceWindow)
    end

    invoiceWindow = guiCreateWindow(833, 478, 255, 155, "Pay N Spray Invoice", false)
    exports.global:centerWindow(invoiceWindow)
    guiWindowSetSizable(invoiceWindow, false)
    showCursor(true)

    local invoiceLabel = guiCreateLabel(3, 21, 247, 34, "The total cost to repair your vehicle is:\n$"..estimatedCosts.."", false, invoiceWindow)
    guiSetFont(invoiceLabel, "default-bold-small")
    guiLabelSetHorizontalAlign(invoiceLabel, "center", true)

    local payCash = guiCreateButton(10, 60, 234, 25, "Pay by Cash", false, invoiceWindow)
    local payCard = guiCreateButton(10, 90, 234, 25, "Pay by Debit Card", false, invoiceWindow)
    local cancelInvoiceButton = guiCreateButton(10, 120, 234, 25, "Cancel", false, invoiceWindow) 

    if exports.global:getMoney(localPlayer, true) < estimatedCosts then
        guiSetEnabled(payCash, false)
    end
    
    if not exports.bank:hasBankMoney(localPlayer, estimatedCosts) then 
        guiSetEnabled(payCard, false)
    end

    addEventHandler("onClientGUIClick", root, function(button, state)
        if button ~= "left" and state ~= "up" then 
            return false
        end

        if source == payCash then         
            triggerServerEvent("pns:PayInvoice", localPlayer, PAY_BY_CASH)
            destroyInvoiceWindow()
        elseif source == payCard then 
            triggerServerEvent("pns:PayInvoice", localPlayer, PAY_BY_CARD)
            destroyInvoiceWindow()
        elseif source == cancelInvoiceButton then
            outputChatBox("Please come back when you're willing to pay the invoice.", 255, 194, 14) 
            destroyInvoiceWindow()
        end
    end)

    triggerEvent("hud:convertUI", localPlayer, invoiceWindow)
end
addEvent("paynspray:Invoice", true)
addEventHandler("paynspray:Invoice", root, showInvoiceWindow)

function destroyInvoiceWindow()
    if isElement(invoiceWindow) then
        destroyElement(invoiceWindow)
        showCursor(false)
    end
end
addEvent("paynspray:destroyInvoice", true)
addEventHandler("paynspray:destroyInvoice", root, destroyInvoiceWindow)
addEventHandler("onClientChangeChar", root, destroyInvoiceWindow)