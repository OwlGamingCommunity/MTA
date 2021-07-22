function invincibleMe ( attacker, weapon, bodypart )
	if getElementData(getLocalPlayer(), "emitter:fireResistance") and ( weapon == 37 ) then --if the weapon used was the flamethrower
		cancelEvent() --cancel the event
	end
end
addEventHandler ( "onClientPlayerDamage", getLocalPlayer(), invincibleMe )
