--MAXIME / 2015.1.8
local GUIEditor = {
    gridlist = {},
    window = {},
    button = {},
    edit = {},
    label = {},
    memo = {}, 
    combobox = {},
    checkbox = {},
    audience = {},
    gridcol = {},
}
local motds = nil
local pointer = nil
function playerReceiveMotds(motds1)
    if motds1 and #motds1 > 0 then

        motds = motds1
        pointer = 1
        displayOneMotd()
    end
end
addEvent("playerReceiveMotds", true)
addEventHandler("playerReceiveMotds", root, playerReceiveMotds)

function displayOneMotd()
    closeOneMotd()
    if pointer and motds and #motds>0 and motds[pointer] then
        exports.global:playSoundAlert()
        GUIEditor.window[1] = guiCreateWindow(491, 193, 800, 369, "Message of the day! - "..motds[pointer].title, false)
        guiWindowSetSizable(GUIEditor.window[1], false)
        exports.global:centerWindow(GUIEditor.window[1])
        GUIEditor.memo[1] = guiCreateMemo(9, 23, 781, 302, motds[pointer].content, false, GUIEditor.window[1])
        guiMemoSetReadOnly(GUIEditor.memo[1], true)
        GUIEditor.label[1] = guiCreateLabel(10, 330, 329, 16, "By "..motds[pointer].author, false, GUIEditor.window[1])
        guiSetFont(GUIEditor.label[1], "default-bold-small")
        GUIEditor.label[2] = guiCreateLabel(10, 346, 329, 16, motds[pointer].creation_date, false, GUIEditor.window[1])
        guiSetFont(GUIEditor.label[2], "default-small")
        GUIEditor.button[1] = guiCreateButton(666, 330, 124, 29, "Close", false, GUIEditor.window[1])
        GUIEditor.checkbox[1] = guiCreateCheckBox(522, 335, 144, 14, "Don't show this again", false, false, GUIEditor.window[1])
        if motds[pointer].dismissable == "0" then
            guiSetVisible(GUIEditor.checkbox[1], false)
        end
        addEventHandler("onClientGUIClick", GUIEditor.button[1], function()
            if source == GUIEditor.button[1] then
                closeOneMotd()
            end
        end)
    else
        pointer = nil
        motds = nil
    end
end

function closeOneMotd()
    if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
        if GUIEditor.checkbox[1] and isElement(GUIEditor.checkbox[1]) and guiGetVisible(GUIEditor.checkbox[1]) and  guiCheckBoxGetSelected(GUIEditor.checkbox[1]) then
            triggerServerEvent("dismissMotd", localPlayer, motds[pointer].id)
        end
        destroyElement(GUIEditor.window[1])
        if pointer then
            pointer = pointer + 1
            displayOneMotd()
        end
    end
end