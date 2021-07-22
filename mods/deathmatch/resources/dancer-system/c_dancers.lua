function pedDamage()
	cancelEvent()
end
addEventHandler("onClientPedDamage", getResourceRootElement(), pedDamage)