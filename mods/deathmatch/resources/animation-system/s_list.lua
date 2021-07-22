local bannedAnimations = { ["FIN_Cop1_ClimbOut2"]=true, ["FIN_Jump_on"]=true, ["sprint_civi"] = true }

addEvent("AnimationSet",true)
addEventHandler("AnimationSet",getRootElement(),
	function (block, ani, loop)
		if bannedAnimations[ani] then
			outputChatBox("This animation is currently banned.", source, 255, 0, 0)
			return
		end

		if(source)then
			if(block)then
				if loop then
					setPedAnimation(source,block,ani,-1,loop)
				else
					setPedAnimation(source,block,ani,1,false)
				end
			else
				setPedAnimation(source)
			end
		end
	end)
