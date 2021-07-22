------ Are we already holding a briefcase?
---
cases = {}

for i,v in ipairs(getElementsByType("player"))do
setElementData(v, "bcase", 0)
end


function briefcase(player)
    if hasItem( player, 122 ) then
        if(getResourceState(getResourceFromName("bone_attach")) == "running")then
            if(getElementType(player) == "player")then
                if(getElementData(player, "bcase") ~= 1)then
                    setElementData(player, "bcase", 1)
                    case = createObject(1210,0,0,0)
                    exports.bone_attach:attachElementToBone(case,player,12,0,0.05,0.27,0,180,0)
                    cases[player] = case
                elseif(getElementData(player, "bcase") == 1)then
                    setElementData(player, "bcase", 0)
                    exports.bone_attach:detachElementFromBone(cases[player])
                    destroyElement(cases[player])
                end
            end
        else
            outputDebugString("ERROR Loading briefcase item")
        end
    end
end
addEvent("bcase", true) addEventHandler("bcase", getRootElement(), briefcase)

addEvent("onPlayerQuit", getRootElement(), function()
		if (getElementData(source, "bcase") == 1) then
			setElementData(source, "bcase", 0)
			exports.bone_attach:detachElementFromBone(cases[source])
			destroyElement(cases[source])
		end
	end
)

addEvent("onPlayerWeaponSwitch", getRootElement(), function()
		if (getElementData(source, "bcase") == 1) then
			setElementData(source, "bcase", 0)
			exports.bone_attach:detachElementFromBone(cases[source])
			destroyElement(cases[source])
		end
	end
)

-- Resetting upon spawn, if data == 1.
addEvent("onPlayerSpawn", getRootElement(), function()
		if (getElementData(source, "bcase") == 1) then
			setElementData(source, "bcase", 0)
			exports.bone_attach:detachElementFromBone(cases[source])
			destroyElement(cases[source])
		end
	end
)