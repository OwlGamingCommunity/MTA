addEvent("playerKnock", true)
addEventHandler("playerKnock", root,
    function(x, y, z)
        outputChatBox(" * Knocks can be heard coming from the door. *      ((" .. getPlayerName(source):gsub("_"," ") .. "))", 255, 51, 102)
        local sound = playSound3D("knocking.mp3", x, y, z)
        setSoundMaxDistance(sound, 20)
        setElementDimension(sound, getElementDimension(localPlayer))
        setElementInterior(sound, getElementInterior(localPlayer))
    end
)

addEvent("doorUnlockSound", true)
addEventHandler("doorUnlockSound", root,
    function(x, y, z)
        local sound = playSound3D("doorUnlockSound.mp3", x, y, z)
        setSoundMaxDistance(sound, 20)
        setElementDimension(sound, getElementDimension(localPlayer))
        setElementInterior(sound, getElementInterior(localPlayer))
    end
)

addEvent("doorLockSound", true)
addEventHandler("doorLockSound", root,
    function(x, y, z)
        local sound = playSound3D("doorLockSound.mp3", x, y, z)
        setSoundMaxDistance(sound, 20)
        setElementDimension(sound, getElementDimension(localPlayer))
        setElementInterior(sound, getElementInterior(localPlayer))
    end
)

addEvent("doorGoThru", true)
addEventHandler("doorGoThru", root,
    function(x, y, z)
        local sound = playSound3D("doorGoThru.mp3", x, y, z)
        setSoundMaxDistance(sound, 20)
        setElementDimension(sound, getElementDimension(localPlayer))
        setElementInterior(sound, getElementInterior(localPlayer))
        setSoundVolume(sound, 0.5)
    end
)
