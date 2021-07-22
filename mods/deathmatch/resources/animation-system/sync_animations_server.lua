-- since we're only interested in ped block, we don't need support for other blocks
-- you might want to rename playerAnimations.replacedPedBlock to playerAnimations.replacedBlocks 
-- to add support for replacing more blocks and keeping them sync 

local playerAnimations = {  } -- current = {}, replacedPedBlock = {}
local synchronizationPlayers = {}

local SetAnimation -- function

addEventHandler ( "onPlayerJoin", root,
    function ( )
        playerAnimations [ source ] = {}
    end
)

for _, player in pairs ( getElementsByType ("player") ) do 
    playerAnimations [ player ] = {}
end

addEvent ("onCustomAnimationStop", true )
addEventHandler ("onCustomAnimationStop", root,
    function ( player )
        SetAnimation ( player, false )
    end 
)

addEvent ("onCustomAnimationSyncRequest", true )
addEventHandler ("onCustomAnimationSyncRequest", root,
    function ( player )
        table.insert ( synchronizationPlayers, player )
        triggerLatentClientEvent ( player, "onClientCustomAnimationSyncRequest", 50000, false, player, playerAnimations )
    end 
)

addEventHandler ( "onPlayerQuit", root,
    function ( )
        for i, player in pairs ( synchronizationPlayers ) do
            if source == player then 
                table.remove ( synchronizationPlayers, i )
                break
            end 
        end 
        playerAnimations [ source ] = nil
    end
)

addEvent ("onCustomAnimationSet", true )
addEventHandler ("onCustomAnimationSet", root,
    function ( player, blockName, animationName, loop )
        SetAnimation ( player, blockName, animationName, -1, loop )
        triggerClientEvent ( synchronizationPlayers, "onClientCustomAnimationSet", player, blockName, animationName, loop  ) 
    end 
)

addEvent ("onCustomAnimationReplace", true )
addEventHandler ("onCustomAnimationReplace", root,
    function ( player, ifpIndex )
        playerAnimations[ player ].replacedPedBlock = ifpIndex
        triggerClientEvent ( synchronizationPlayers, "onClientCustomAnimationReplace", player, ifpIndex )
    end 
)

addEvent ("onCustomAnimationRestore", true )
addEventHandler ("onCustomAnimationRestore", root,
    function ( player, blockName )
        playerAnimations[ player ].replacedPedBlock = nil
        triggerClientEvent ( synchronizationPlayers, "onClientCustomAnimationRestore", player, blockName )
    end 
)

function SetAnimation ( player, blockName, animationName, loop )
    if not playerAnimations[ player ] then playerAnimations[ player ] = {} end 
    if blockName == false then
        playerAnimations[ player ].current = nil
    else
        playerAnimations[ player ].current = { blockName, animationName, loop }
    end 
end 

