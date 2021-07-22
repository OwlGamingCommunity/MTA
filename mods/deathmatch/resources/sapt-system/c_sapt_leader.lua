ibisAdmin = { }

function showIBISAdmin(cRoutes, cLines, cDestinations)
	if (isElement(ibisAdmin.Window)) then destroyElement(ibisAdmin.Window) end
	
	ibisAdmin.Window = guiCreateWindow(379,197,560,343,"IBIS Control Panel", false)
	guiWindowSetSizable(ibisAdmin.Window, false)
	ibisAdmin.tabPanel = guiCreateTabPanel(0.0161,0.0758,0.9679,0.898, true, ibisAdmin.Window)
	ibisAdmin.tab = { }
	ibisAdmin.tab[1] = guiCreateTab("Routes", ibisAdmin.tabPanel)
	ibisAdmin.tab[2] = guiCreateTab("Destinations", ibisAdmin.tabPanel)
	ibisAdmin.tab[3] = guiCreateTab("Stops", ibisAdmin.tabPanel)
end
addEvent("sapt:client_showIBISAdmin", true)
addEventHandler("sapt:client_showIBISAdmin", localPlayer, showIBISAdmin)
