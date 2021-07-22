--
-- c_helper_functions.lua
--

---------------------------------------------------------------------------------------------------
-- shader model version
---------------------------------------------------------------------------------------------------
function vCardPSVer()
	local smVersion = tostring(dxGetStatus().VideoCardPSVersion)
	outputDebugString("VideoCardPSVersion: "..smVersion)
	return smVersion
end

---------------------------------------------------------------------------------------------------
-- debug lights
---------------------------------------------------------------------------------------------------
local lightDebugSwitch = false

addCommandHandler( "debugDynamicLights",
function()
	if isDebugViewActive() then 
		lightDebugSwitch = switchDebugLights(not lightDebugSwitch)
	end
end
)

function switchDebugLights(switch)
	if switch then
		addEventHandler("onClientRender",root,renderDebugLights)
	else
		outputDebugString('Debug mode: OFF')
		removeEventHandler("onClientRender",root,renderDebugLights)
	end
	return switch
end

local scx,scy = guiGetScreenSize()
function renderDebugLights()
	dxDrawText(fpscheck()..' FPS', scx/2, 25)
	if (#lightTable.outputLights<1) then 
		return
	end
	dxDrawText(lightTable.thisLight..' Active', scx/2 ,10 )
	for index,this in ipairs(lightTable.outputLights) do
		if this.enabled then
			local col = tocolor(this.color[1] * 255, this.color[2] * 255,this.color[3] * 255,this.color[4] * 255)
			if this.lType == 2 then
				drawRotBox(this.pos[1], this.pos[2], this.pos[3], this.dir[1], this.dir[2], this.dir[3])
			end
			local xVal, yVal, xStr, yStr, dist = getBoxScreenParams(scx, scy, this.pos[1], this.pos[2], this.pos[3], 0.5, 0.5)
			if xVal and yVal then
				dxDrawRectangle ( xVal, yVal, xStr, yStr, col)
			end
		end
	end
end


function drawRotBox(posX, posY, posZ, vecX, vecY, vecZ)
	local rotX,rotY,rotZ = getEulerFromVector(vecX, vecY, vecZ)
	local myMatrix = createElementMatrix(posX, posY, posZ, rotX, rotY, rotZ)
	local ofPosX, ofPosY, ofPosZ
	ofPosX, ofPosY, ofPosZ = getPositionFromMatrixOffset(myMatrix, 0, 0, 1) -- z g
	dxDrawLine3D ( posX, posY, posZ, ofPosX, ofPosY, ofPosZ, tocolor ( 0, 255, 0 ),3)
	ofPosX, ofPosY, ofPosZ = getPositionFromMatrixOffset(myMatrix, 1, 0, 0) -- x b
	dxDrawLine3D ( posX, posY, posZ, ofPosX, ofPosY, ofPosZ, tocolor ( 0, 0, 255 ),3)
	ofPosX, ofPosY, ofPosZ = getPositionFromMatrixOffset(myMatrix, 0, 1, 0) -- y r
	dxDrawLine3D ( posX, posY, posZ, ofPosX, ofPosY, ofPosZ, tocolor ( 255, 0, 0 ),3)
end

function getBoxScreenParams(szx, szy, hx, hy, hz, sizeX, sizeY)
	local sx,sy = getScreenFromWorldPosition(hx, hy, hz, 0.25, true)
	if sx and sy then
		local cx, cy, cz, clx, cly, clz, crz, cfov = getCameraMatrix()
		local dist = getDistanceBetweenPoints3D(hx, hy, hz, cx, cy, cz)
		local xMult = szx/800/70 * cfov * sizeX
		local yMult = szy/600/70 * cfov * sizeY
		local xVal = sx-(100/dist) * xMult
		local yVal = sy-(100/dist) * yMult
		local xStr = (200/dist) * xMult
		local yStr = (200/dist) * yMult
		return xVal, yVal, xStr, yStr, dist
	else
		return false
	end
end

local frames,lastsec,fpsOut = 0,0,0
function fpscheck()
	local frameticks = getTickCount()
	frames = frames + 1
	if frameticks - 1000 > lastsec then
		local prog = (frameticks - lastsec)
		lastsec = frameticks
		fps = frames / (prog / 1000)
		frames = fps * ((prog - 1000) / 1000)
		fpsOut = tostring(math.floor(fps))
	end
	return fpsOut
end

---------------------------------------------------------------------------------------------------
-- light sorting
---------------------------------------------------------------------------------------------------
function sortedOutput(inTable,isSo,distFade,maxEntities)
	local outTable = {}
	for index,value in ipairs(inTable) do
		if inTable[index].enabled then
			local dist = getElementFromCameraDistance(value.pos[1],value.pos[2],value.pos[3])
			if dist <= distFade then 
				local w = #outTable + 1
				if not outTable[w] then 
					outTable[w] = {} 
				end
				outTable[w].enabled = value.enabled
				outTable[w].lType = value.lType
				outTable[w].pos = value.pos
				outTable[w].dist = dist
				outTable[w].color = value.color	
				outTable[w].attenuation = value.attenuation
				outTable[w].normalShadow = value.normalShadow 
				if (value.lType==2) then
					outTable[w].dir = value.dir				
					outTable[w].falloff = value.falloff			
					outTable[w].theta = value.theta			
					outTable[w].phi = value.phi		
				end
			end
		end
	end
		if isSo and (#outTable > maxEntities) then
			table.sort(outTable, function(a, b) return a.dist < b.dist end)
		end
	return outTable
end

function findEmptyEntry(inTable)
	for index,value in ipairs(inTable) do
		if not value.enabled then
			return index
		end
	end
	return #inTable + 1
end

function getElementFromCameraDistance(hx,hy,hz)
	local cx,cy,cz,clx,cly,clz,crz,cfov = getCameraMatrix()
	local dist = getDistanceBetweenPoints3D(hx,hy,hz,cx,cy,cz)
	return dist
end

---------------------------------------------------------------------------------------------------
-- shader file creation for the light resource
---------------------------------------------------------------------------------------------------
function createLightShaderFiles(currLightNr, isLayer, isWrdSobel, isNightMod, isPedDiffuse, isShading, isDirLight, isDiffuse, isNightSpot,isSM3)
	local isValid = true
	isNightSpot = isNightSpot and isNightMod
	local isTex1 = true
	-- due to instruction limit for sm2.0 we need to restrict vehicle specular when using nightMod or vertex lights
	if (not isSM3 and not isLayer[2] and (isNightMod or isDirLight or isDiffuse or isNightSpot)) then isTex1 = false end
	if currLightNr > 0 then
		isValid = createEffectFile('shaders/dynamic_wrd.fx', currLightNr, isLayer[1], isWrdSobel, isNightMod, false, isShading[1], isDirLight, isDiffuse, false, false, isNightSpot) and isValid
	else
		isValid = createEffectFile('shaders/dynamic_wrd.fx', currLightNr, isLayer[1], false, isNightMod, false, isShading[1], isDirLight, isDiffuse, false, false, isNightSpot) and isValid
	end
	isValid = createEffectFile('shaders/dynamic_veh.fx', currLightNr, isLayer[2], false, isNightMod, true, isShading[2], isDirLight, isDiffuse, true, isTex1, isNightSpot) and isValid
	isValid = createEffectFile('shaders/dynamic_ped.fx', currLightNr, isLayer[3], false, isNightMod, isPedDiffuse, isShading[3], isDirLight, isDiffuse, false, false, isNightSpot) and isValid
	if isValid then
		outputDebugString('Created effects for: '..currLightNr..' + 1 lights.')
		outputDebugString('Effect layered WRD: '..tostring(isLayer[1])..' Effect layered VEH: '..tostring(isLayer[2])..' Effect layered PED: '..tostring(isLayer[3]))
		outputDebugString('Effect normal WRD: '..tostring(isShading[1])..' Effect normal VEH: '..tostring(isShading[2])..' Effect normal PED: '..tostring(isShading[3]))
		outputDebugString('Effect sobel WRD: '..tostring(isWrdSobel)..' Effect diffuse PED: '..tostring(isPedDiffuse)..' Effect DirLight: '..tostring(isDirLight))
		outputDebugString('Effect DiffuseLight: '..tostring(isDiffuse)..' Effect nightSpot: '..tostring(isNightSpot)..' Effect nightMod: '..tostring(isNightMod))
		return true
	else
		outputDebugString('Effects create fail!')
		return false
	end
end

function createEffectFile(filePath, lightNr, isLayer, isSobel, isNightMod, isGTADiffuse, isShading, isDirLight, isDiffuse, isVehicle, isTex1, isNightSpot)
	local theFile = fileCreate(filePath)
	if (theFile) then
		writeFileLine( theFile, ' float2 gDistFade = float2(250, 150);\n float gBrightness = 1;\n float gDayTime = 1;\n float gTextureSize = 512.0;\n float3 gNormalStrength = float3(1,1,1);\n ')
		for lID=0,lightNr do
			writeFileLine( theFile, ' float gLight'..lID..'Enable = 0;\n int gLight'..lID..'Type = 1;\n float3 gLight'..lID..'Position = float3(0,0,0);\n float4 gLight'..lID..'Diffuse = float4(0,0,0,1);\n float gLight'..lID..'Attenuation = 0; ') 
			writeFileLine( theFile, ' bool gLight'..lID..'NormalShadow = true;\n float3 gLight'..lID..'Direction = float3(0.0, 0.0, -1.0);\n float gLight'..lID..'Falloff  = 1.0;\n float gLight'..lID..'Theta = 0;\n float gLight'..lID..'Phi = 0; ')
		end
		if isDirLight then
			writeFileLine( theFile, ' bool gDirLightEnable = false;\n float4 gDirLightDiffuse = float4(0,0,0,1);\n float3 gDirLightDirection = float3(0.0, 0.0, -1.0);\n float gDirLightRange = 60; ')
		end
		if isDiffuse then
			writeFileLine( theFile, ' bool gDiffLightEnable = false;\n float4 gDiffLightDiffuse = float4(0,0,0,1);\n float gDiffLightRange = 60; ')
		end
		if isNightSpot then
			writeFileLine( theFile, ' bool gNightSpotEnable = false;\n float3 gNightSpotPosition = float3(0,0,0);\n float gNightSpotRadius = 0; ')
		end		
		writeFileLine( theFile, ' float4x4 gWorld : WORLD;\n float4x4 gView : VIEW;\n float4x4 gProjection : PROJECTION;\n float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;\n float4x4 gWorldInverseTranspose : WORLDINVERSETRANSPOSE;\n float3 gCameraPosition : CAMERAPOSITION; ')
		writeFileLine( theFile, ' #include \"common.txt\" ')
		if isShading then
			writeFileLine( theFile, ' #include \"light1.txt\" ')
		else
			writeFileLine( theFile, ' #include \"light0.txt\" ')
		end
		writeFileLine( theFile, ' texture gTexture0 < string textureState="0,Texture"; >;\n sampler Sampler0 = sampler_state\n {\n Texture = (gTexture0);\n };\n  texture gTexture1 < string textureState="1,Texture"; >;\n sampler Sampler1 = sampler_state\n {\n Texture = (gTexture1);\n }; ')
		writeFileLine( theFile, ' struct VSInput{\n float4 Position : POSITION0;\n float3 TexCoord : TEXCOORD0;\n float2 TexCoord1 : TEXCOORD1;\n float4 Normal : NORMAL0;\n float4 Diffuse : COLOR0;\n }; ')
		writeFileLine( theFile, ' struct PSInput{\n float4 Position : POSITION;\n float2 TexCoord : TEXCOORD0;\n float DistFade : TEXCOORD1;\n float3 WorldPos : TEXCOORD2;\n float4 Diffuse : COLOR0;\n float4 ViewPos : TEXCOORD4; ')
		if isDirLight or isDiffuse or (isVehicle and not isLayer) then
			writeFileLine( theFile, ' float4 VertLight : COLOR1; ')
		end
		if isShading then
			writeFileLine( theFile, ' float3 Normal : TEXCOORD3; ')
			if isSobel then
				writeFileLine( theFile, ' float3 Binormal : TEXCOORD5;\n float3 Tangent : TEXCOORD6; ')
			end
		end
		if ((isVehicle and isTex1) and not isLayer and not isSobel) then
			writeFileLine( theFile, ' float2 TexCoord1 : TEXCOORD5; ')
		end
		writeFileLine( theFile, ' }; ')
		--vs
		writeFileLine( theFile, ' PSInput VertexShaderSB(VSInput VS)\n {\n PSInput PS = (PSInput)0;\n PS.Position = mul(VS.Position, gWorldViewProjection);\n PS.ViewPos = PS.Position;\n PS.WorldPos = mul(float4(VS.Position.xyz,1), gWorld).xyz;\n PS.TexCoord = VS.TexCoord; ')
		if ((isVehicle and isTex1) and not isLayer and not isSobel) then
			writeFileLine( theFile, ' float3 posInWorld = gWorld[3] * 0.02;\n posInWorld.x = ( posInWorld.x  - int(posInWorld.x )) * -gWorld[1].x;\n posInWorld.y = ( posInWorld.y  - int(posInWorld.y )) * -gWorld[1].y;\n float anim = posInWorld.x + posInWorld.y;\n PS.TexCoord1 = VS.TexCoord1 + float2( anim, 0 ); ')
		end
		writeFileLine( theFile, ' float DistanceFromCamera = distance( gCameraPosition, PS.WorldPos ); ')
		if isShading then
			writeFileLine( theFile, ' PS.Normal = mul(VS.Normal, gWorldInverseTranspose); ')
			if isDirLight then
				writeFileLine( theFile, ' PS.VertLight = createDirLight( normalize(PS.Normal), gDirLightDirection, gDirLightDiffuse); ')
				writeFileLine( theFile, ' PS.VertLight *= saturate(MTAUnlerp(gDirLightRange, gDirLightRange * 0.6, DistanceFromCamera));')
			end
			if isSobel then
				writeFileLine( theFile, ' float3 Tangent = VS.Normal.yxz;\n Tangent.xz = VS.TexCoord.xy;\n float3 Binormal = normalize( cross(Tangent, VS.Normal) );\n Tangent = normalize( cross(Binormal, VS.Normal) );\n PS.Tangent = mul(Tangent, gWorldInverseTranspose);\n PS.Binormal = mul(-Binormal, gWorldInverseTranspose); ')
			end
		end
		if isDiffuse then
			if isDirLight then
				writeFileLine( theFile, ' PS.VertLight += gDiffLightDiffuse * saturate(MTAUnlerp(gDiffLightRange, gDiffLightRange * 0.6, DistanceFromCamera)); ')
			else
				writeFileLine( theFile, ' PS.VertLight = gDiffLightDiffuse * saturate(MTAUnlerp(gDiffLightRange, gDiffLightRange * 0.6, DistanceFromCamera)); ')			
			end	
		end
		if isVehicle and not isLayer then
			if (isShading and isDirLight) or isDiffuse then
				writeFileLine( theFile, ' if (VS.Diffuse.a <= 0.85) PS.VertLight.rgb *= 0.25;\n PS.VertLight.rgb *= gMaterialDiffuse.rgb; ')
			end
		end
		writeFileLine( theFile, ' PS.DistFade = MTAUnlerp ( gDistFade[0], gDistFade[1], DistanceFromCamera ); ')
		if isGTADiffuse and isShading and not isLayer then
			writeFileLine( theFile, ' float4 Diffuse = MTACalcGTACompleteDiffuse( PS.Normal , VS.Diffuse );')
			if isVehicle then
				if isDiffuse or isDirLight then
					writeFileLine( theFile, ' PS.VertLight += sMaterialSpecular * MTACalculateSpecular( sCameraDirection, sLightDirection, PS.Normal, sMaterialSpecPower ) * 0.7 * max( gDayTime, PS.VertLight.a ); ')
				else
					writeFileLine( theFile, ' PS.VertLight = sMaterialSpecular * MTACalculateSpecular( sCameraDirection, sLightDirection, PS.Normal, sMaterialSpecPower ) * 0.7 * gDayTime * max( gDayTime, PS.VertLight.a ); ')				
				end
			end	
		else
			writeFileLine( theFile, ' float4 Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse ); ')
		end
		if (isDiffuse or isDirLight or (isVehicle and not isLayer)) then
			writeFileLine( theFile, ' PS.VertLight = saturate( PS.VertLight ) * saturate( PS.DistFade ); ')
		end
			writeFileLine( theFile, ' float brightness = gBrightness; ')
		if isNightMod then
			writeFileLine( theFile, ' float dayTime = gDayTime; ') 
			if isNightSpot then
				writeFileLine( theFile, ' float nightLight = createVertexLightPoint(PS.WorldPos, gNightSpotPosition, gNightSpotRadius ); ')
				writeFileLine( theFile, ' dayTime = max(gDayTime,nightLight);')
				writeFileLine( theFile, ' brightness = max(gBrightness,nightLight);')
			end		
			if isVehicle then
				writeFileLine( theFile, ' Diffuse = lerp( saturate(float4( Diffuse.rgb * min(0.1, dayTime) , Diffuse.a )) , Diffuse, saturate( dayTime )); ')
			else
				writeFileLine( theFile, ' float diffGray = saturate( 0.1 + (( Diffuse.r +Diffuse.g+Diffuse.b )/3 ) * dayTime); ')
				writeFileLine( theFile, ' Diffuse = lerp( float4( diffGray, diffGray, diffGray, Diffuse.a ), Diffuse, saturate( dayTime )); ')
			end

		end
		writeFileLine( theFile, ' Diffuse.rgb *= brightness; ')
		writeFileLine( theFile, ' PS.Diffuse = saturate(Diffuse);\n return PS;\n } ')
		--ps
		writeFileLine( theFile, ' struct PSOutput \n {\n float4 color : COLOR0; ')
		if isLayer then
			writeFileLine( theFile, ' float depth : DEPTH; ')
		end
		writeFileLine( theFile, ' }; ')
		writeFileLine( theFile, ' PSOutput PixelShaderSB(PSInput PS)\n {\n PSOutput output = (PSOutput)0;\n float4 texel = tex2D(Sampler0, PS.TexCoord);\n float4 texLight = 0;\n float3 Normal = 0; ')
		if isShading then
			writeFileLine( theFile, ' Normal = normalize( PS.Normal ); ')
			if isSobel then
				writeFileLine( theFile, ' float3 NormalTex = ComputeNormalsPS( Sampler0, PS.TexCoord.xy, texel, gTextureSize );\n NormalTex.xy = NormalTex.xy * 2.0 - 1.0;\n Normal += ( NormalTex.x * normalize(PS.Tangent) * gNormalStrength.x + NormalTex.y * normalize(PS.Binormal) * gNormalStrength.y + NormalTex.y * PS.Normal * gNormalStrength.z);\n Normal = normalize(Normal); ')
			end
		end
		if ((isVehicle and isTex1) and not isLayer and not isSobel) then
			writeFileLine( theFile, ' float4 refTex = tex2D(Sampler1, PS.TexCoord1); ')
		end
		for lID=0,lightNr do
			writeFileLine( theFile, ' if (gLight'..lID..'Enable) texLight += createLight(Normal, PS.WorldPos, gLight'..lID..'Type, gLight'..lID..'Position, gLight'..lID..'Direction, gLight'..lID..'Diffuse, gLight'..lID..'Attenuation, gLight'..lID..'Phi, gLight'..lID..'Theta, gLight'..lID..'Falloff, gLight'..lID..'NormalShadow ); ')		
		end
		if isLayer then
			writeFileLine( theFile, ' float4 light = texel * texLight * saturate( PS.DistFade ); ')
			writeFileLine( theFile, ' texel = 0; ')
		elseif isVehicle then
			writeFileLine( theFile, ' float4 texCopy = texel; ')
			writeFileLine( theFile, ' float4 light = 0;  ')
			writeFileLine( theFile, ' if (PS.Diffuse.a <= 0.85) {light = (texLight * 0.1) * saturate( PS.DistFade );}')
			writeFileLine( theFile, ' else {light = texel * texLight * saturate( PS.DistFade );} ')
			writeFileLine( theFile, ' texel.rgb *= PS.Diffuse.rgb; ')
		else
			if (isShading and isDirLight) or isDiffuse then
				writeFileLine( theFile, ' texLight += PS.VertLight; ')
			end
			writeFileLine( theFile, ' float4 light = texel * texLight * saturate( PS.DistFade ); ')
			writeFileLine( theFile, ' texel.rgb *= PS.Diffuse.rgb; ')
		end
		if isVehicle and not isLayer then
			if (isShading and isDirLight) or isDiffuse then
				writeFileLine( theFile, ' if (PS.Diffuse.a <= 0.85) texel.rgb += PS.VertLight.rgb;\n else texel.rgb += texCopy.rgb * PS.VertLight.rgb;')
			else
				writeFileLine( theFile, ' texel.rgb += PS.VertLight.rgb;')
			end
			writeFileLine( theFile, ' texel.rgb += saturate( light.rgb * gMaterialDiffuse.rgb); ')
		else
			writeFileLine( theFile, ' texel.rgb += saturate( light.rgb ); ')
		end
		if isLayer then 
			writeFileLine( theFile, ' texel.a = light.a;\n output.color = saturate( texel );\n output.depth = calculateLayeredDepth( PS.ViewPos ); ')
		else
			if lightNr>0 then
				writeFileLine( theFile, ' texel.rgb = MTAApplyFog( texel.rgb, PS.WorldPos ); ')
			end
			writeFileLine( theFile, ' output.color = saturate( texel ); ')
		end
		if ((isVehicle and isTex1) and not isLayer and not isSobel) then
			writeFileLine( theFile, ' output.color.rgb += saturate(refTex.rgb * sMaterialSpecular.rgb * 0.20) * gBrightness * gDayTime;')
		end
		writeFileLine( theFile, ' output.color.a *= PS.Diffuse.a; \n return output;\n } ')
			
		writeFileLine( theFile, ' technique dynamic_lighting \n {\n pass P0 \n { ')
		if isLayer then
			writeFileLine( theFile, ' AlphaRef = 1;\n SrcBlend = SRCALPHA;\n DestBlend = ONE; ')
		end
		if (lightNr==0) then
			writeFileLine( theFile, ' AlphaBlendEnable = TRUE;\n VertexShader = compile vs_2_0 VertexShaderSB();\n PixelShader = compile ps_2_0 PixelShaderSB();\n }\n }\n technique fallback \n {\n pass P0 \n { }\n } ')
		else
			writeFileLine( theFile, ' AlphaBlendEnable = TRUE;\n VertexShader = compile vs_3_0 VertexShaderSB();\n PixelShader = compile ps_3_0 PixelShaderSB();\n }\n }\n technique fallback \n {\n pass P0 \n { }\n } ')
		end
		fileClose ( theFile )
		return true
	else
		return false
	end
end

function writeFileLine( theFile, theLine)
    if ( theFile ) then
        pos = fileGetSize( theFile )
        newPos = fileSetPos ( theFile, pos )
        writeFile = fileWrite ( theFile, theLine .."\n" )
        if not ( writeFile ) then
            outputDebugString ( "Error writing the shader file." )
            return false
		end
	end
end

---------------------------------------------------------------------------------------------------
-- vector stuff
---------------------------------------------------------------------------------------------------
function getVectorFromEulerXZ(rotX, rotY, rotZ)
	local rx, rz = math.rad(rotX), math.rad(rotZ)
	return -math.cos(rx) * math.sin(rz), math.cos(rz) * math.cos(rx), math.sin(rx)
end

function getEulerFromVector(vx, vy, vz)
	local len = math.sqrt(vx * vx + vy * vy + vz * vz)
	return math.deg(math.asin(vz / len)), 0, -math.deg(math.atan2(vx, vy))
end

function getEulerAnglesFromMatrix(m)
	local nz1, nz2, nz3
	nz3 = math.sqrt(m[2][1] * m[2][1] + m[2][2] * m[2][2])
	nz1 = -m[2][1] * m[2][3] / nz3
	nz2 = -m[2][2] * m[2][3] / nz3
	local vx = nz1 * m[1][1] + nz2 * m[1][2] + nz3 * m[1][3]
	local vz = nz1 * m[3][1] + nz2 * m[3][2] + nz3 * m[3][3]
	return math.deg(math.asin(m[2][3])), -math.deg(math.atan2(vx, vz)), -math.deg(math.atan2(m[2][1], m[2][2]))
end
function createElementMatrix(posX, posY, posZ, rotX, rotY, rotZ)
	local rx, ry, rz = math.rad(rotX), math.rad(rotY), math.rad(rotZ)
	return {{ math.cos(rz) * math.cos(ry) - math.sin(rz) * math.sin(rx) * math.sin(ry), 
			math.cos(ry) * math.sin(rz) + math.cos(rz) * math.sin(rx) * math.sin(ry), -math.cos(rx) * math.sin(ry) },
	{ -math.cos(rx) * math.sin(rz), math.cos(rz) * math.cos(rx), math.sin(rx) },
	{math.cos(rz) * math.sin(ry) + math.cos(ry) * math.sin(rz) * math.sin(rx), math.sin(rz) * math.sin(ry) - 
			math.cos(rz) * math.cos(ry) * math.sin(rx), math.cos(rx) * math.cos(ry)},
	{posX, posY, posZ, 1 }}
end

function getPositionFromMatrixOffset(m, x, y, z)
	return (x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1]), (x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2]),
		(x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3])
end
