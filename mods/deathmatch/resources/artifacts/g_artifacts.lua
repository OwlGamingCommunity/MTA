-- Script: artifacts
-- Description: Handles artifacts (things players can wear that are not clothes)
-- Client and Server
-- Created by Exciter for Owl Gaming, 15.05.2014 (DD/MM/YYYY)
-- Thanks to Adams, iG Scripting Team and RPP Scripting Team for their base work.
-- License: BSD

g_artifacts = {
	--[ID] = {model, bone, x, y, z, rx, ry, rz, scale, doublesided, texture},
	["helmet"]			= {2799,1,0,0.037,0.08,7.5,0,180,1,false},
	["gasmask"]			= {3890,1,0.00825,0.14,0,0,-3,90,0.8725,true},
	["kevlar"]			= {3916,3,0,0.025,0.075,0,270,0,1.125,true},
	["rod"]				= {16442,11,0,0.037,0.08,0,270,0,2,false},
	["dufflebag"]		= {3915,3,0,-0.1325,0.145,0,0,0,1,true},
	["briefcase"]		= {1210,12,0,0.1,0.3,0,180,0,1,false},
	["backpack"]		= {3026,5,0,-0.4,0.02,0,0,80,1,true},
	["medicbag"]		= {3915,3,0,-0.1325,0.145,0,0,0,1,true,{{":artifacts/textures/medicbag.png","hoodyabase5"},}},
	["bikerhelmet"]		= {3911,1,0,0.037,0.08,7.5,0,180,1,false},
	["fullfacehelmet"]	= {3917,1,0,0.037,0.08,7.5,0,180,1,false},
	["christmashat"]	= {954,1,0,0.027,0.145,0,26,90,1,false},
	["shield"]			= {1631,4,0,0.1,-0.3,270,0,0,1,false},
	["surfboard"]		= {2406,11,0.2,-0.02,0.25,-10,90,0,1,false},
}
--[[
-- Bone IDs: --
1 - head
2 - neck
3 - spine
4 - pelvis
5 - left clavicle
6 - right clavicle
7 - left shoulder
8 - right shoulder
9 - left elbow
10 - right elbow
11 - left hand
12 - right hand
13 - left hip
14 - right hip
15 - left knee
16 - right knee
17 - left ankle
18 - right ankle
19 - left foot
20 - right foot
]]

ART_MODEL = 1
ART_BONE = 2
ART_X = 3
ART_Y = 4
ART_Z = 5
ART_RX = 6
ART_RY = 7
ART_RZ = 8
ART_SCALE = 9
ART_DOUBLESIDED = 10
ART_TEXTURE = 11

g_artifacts_mes = {
	--[ID] = {takeOn, takeOff} NOTE! Most items already output a /me in item-system, thus won't need to be added here
	--["helmet"]		= {"puts a helmet over their head.", "takes their helmet off."},
	--["gasmask"]		= {"slides a gasmask over their face.", "pulls a gasmask off their face."},
	--["kevlar"]		= {"puts on a kevlar.", "takes off a kevlar."},
	--["rod"]			= {"takes out a rod.", "removes a rod."},
	--["dufflebag"]		= {"puts a helmet over their head.", "takes their helmet off."},
	--["briefcase"]		= {"puts a helmet over their head.", "takes their helmet off."},
	--["backpack"]		= {"puts a helmet over their head.", "takes their helmet off."},
}

function getArtifacts() --may be useful as an exported function to let other scripts get the table of possible artifacts
	return g_artifacts
end

g_skinSpecifics = { --as skins differ, some skins may need different offsets than most others, thus this allows setting special skin-specific properties for artifacts
--["artifact"] = { }
	["helmet"] = {
		--[skin] = {model, bone, x, y, z, rx, ry, rz, scale, doublesided, texture}
		[235] = {2799,1,0,-0.03,0,-80,0,180,1,false},
	},
	["bikerhelmet"] = {
		--[skin] = {model, bone, x, y, z, rx, ry, rz, scale, doublesided, texture}
		[235] = {3911,1,0,-0.03,0,-80,0,180,1,false},
	},
	["fullfacehelmet"] = {
		--[skin] = {model, bone, x, y, z, rx, ry, rz, scale, doublesided, texture}
		[235] = {3917,1,0,-0.03,0,-80,0,180,1,false},
	},
}

function getSkinSpecificArtifactData(artifact, skin)
	--outputDebugString("getSkinSpecificArtifactData")
	if g_skinSpecifics[artifact] then
		--outputDebugString("check 1")
		if g_skinSpecifics[artifact][skin] then
			--outputDebugString("check 2")
			local data = {}
			for k,v in ipairs(g_skinSpecifics[artifact][skin]) do
				--outputDebugString("k="..tostring(k))
				local value
				if(v == nil) then
					value = g_artifacts[artifact][k]
					--outputDebugString("value["..tostring(k).."]="..tostring(value))
				else
					value = v
					--outputDebugString("v["..tostring(k).."]="..tostring(v))
				end
				table.insert(data, value)
			end
			return data
		end
	end
	return false
end