-- Script: artifacts
-- Description: Handles artifacts (things players can wear that are not clothes)
-- Client-Side
-- Created by Exciter for Owl Gaming, 15.05.2014 (DD/MM/YYYY)
-- Thanks to Adams, iG Scripting Team and RPP Scripting Team for their base work.
-- License: BSD

function replaceModels()
    -- Credit for models goes to Adams

	--Fishing Rod
	local txd = engineLoadTXD("models/rod.txd")
    engineImportTXD(txd, 16442 )
	local dff = engineLoadDFF("models/rod.dff", 16442)
    engineReplaceModel(dff, 16442)
	
	--Motocross Helmet
    local txd = engineLoadTXD("models/pro.txd")
    engineImportTXD(txd, 2799)
    local dff = engineLoadDFF("models/pro.dff", 2799)
    engineReplaceModel(dff, 2799)
    local col = engineLoadCOL("models/helmet.col")
    engineReplaceCOL(col, 2799)

    --Biker Helmet
    local txd = engineLoadTXD("models/bikerhelmet.txd")
    engineImportTXD(txd, 3911)
    local dff = engineLoadDFF("models/bikerhelmet.dff", 3911)
    engineReplaceModel(dff, 3911)
    --local col = engineLoadCOL("models/helmet.col")
    engineReplaceCOL(col, 3911)

    --Full Face Helmet
    local txd = engineLoadTXD("models/fullfacehelmet.txd")
    engineImportTXD(txd, 3917)
    local dff = engineLoadDFF("models/fullfacehelmet.dff", 3917)
    engineReplaceModel(dff, 3917)
     --local col = engineLoadCOL("models/helmet.col")
    engineReplaceCOL(col, 3917)
   
    --Gas Mask
    local txd = engineLoadTXD("models/gasmask.txd")
    engineImportTXD(txd, 3890)
    local dff = engineLoadDFF("models/gasmask.dff", 3890)
    engineReplaceModel(dff, 3890)
	
	--Dufflebag
    local txd = engineLoadTXD("models/dufflebag.txd")
    engineImportTXD(txd, 3915)
    local dff = engineLoadDFF("models/dufflebag.dff", 3915)
    engineReplaceModel(dff, 3915)
	
	--Kevlar Vest
    local txd = engineLoadTXD("models/kevlar.txd")
    engineImportTXD(txd, 3916)
    local dff = engineLoadDFF("models/kevlar.dff", 3916)
    engineReplaceModel(dff, 3916)
end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()),
     function()
         replaceModels()
         setTimer (replaceModels, 1000, 1)
end
)