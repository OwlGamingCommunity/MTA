local sharedDefine = {
 { 'float2 uvMul = float2(1,1); float2 uvMov = float2(0,0.25); float sNorFacXY = 0.25; float sNorFacZ = 1;  float bumpSize = 1; float sSparkleSize = 0.5; float envIntensity = 1; float specularValue = 1; ' },
 { 'float refTexValue = 0.2; float sAdd = 0.1; float sMul = 1.1; float sPower = 2; float sCutoff = 0.16; bool isShatter = false; texture sReflectionTexture; texture sRandomTexture; ' },
 { 'static const float pi = 3.141592653589793f; ' },
 { '#define GENERATE_NORMALS ' },
 { '#include "mta-helper.fx" ' },

 { 'sampler Sampler0 = sampler_state{Texture = (gTexture0);}; sampler Sampler1 = sampler_state{Texture = (gTexture1); AddressU = Wrap; AddressV = Wrap; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;}; ' },
 { 'sampler3D RandomSampler = sampler_state{Texture = (sRandomTexture); MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = POINT; MIPMAPLODBIAS = 0.000000;}; ' },
 { 'sampler2D ReflectionSampler = sampler_state{Texture = (sReflectionTexture);	 AddressU = Mirror; AddressV = Mirror; MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;}; ' }
					}

local carPaintDefine = {
 { 'struct VSInput{ float3 Position : POSITION0; float3 Normal : NORMAL0; float4 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0; float2 TexCoord1 : TEXCOORD1;}; '},
 { 'struct PSInput{ float4 Position : POSITION0; float4 Diffuse : COLOR0; float4 Specular : COLOR1; float2 TexCoord : TEXCOORD0; float3 Normal : TEXCOORD1; float3 WorldPos : TEXCOORD2; float3 PosProj : TEXCOORD3; float3 SparkleTex : TEXCOORD4; float2 TexCoord1 : TEXCOORD5; float3 ViewNormal : TEXCOORD6; }; '},
 { 'PSInput VertexShaderFunction(VSInput VS) { PSInput PS = (PSInput)0; MTAFixUpNormal( VS.Normal ); PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 4.0/sSparkleSize; PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 4.0/sSparkleSize; PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 4.0/sSparkleSize; '},
 { 'PS.Normal = mul(VS.Normal, (float3x3)gWorld); PS.WorldPos = mul( VS.Position.xyz, (float3x3)gWorld ); PS.TexCoord = VS.TexCoord; float3 posInWorld = gWorld[3].xyz * 0.02; posInWorld.x = ( posInWorld.x  - int(posInWorld.x )) * -gWorld[1].x; '},
 { 'posInWorld.y = ( posInWorld.y  - int(posInWorld.y )) * -gWorld[1].y; float anim = posInWorld.x + posInWorld.y; PS.TexCoord1 = VS.TexCoord1 + float2( anim, 0 );	 float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld ); '},
 { 'float4 viewPos = mul( worldPos , gView );  float4 projPos = mul( viewPos, gProjection); PS.Position = projPos; projPos.x *= uvMul.x; projPos.y *= uvMul.y;	 float projectedX = (0.5 * ( projPos.w + projPos.x ))+ uvMov.x; float projectedY = (0.5 * ( projPos.w + projPos.y )) + uvMov.y; '},
 { 'PS.PosProj = float3(projectedX,projectedY,projPos.w ); PS.ViewNormal = normalize( mul(PS.Normal, (float3x3)gView )); PS.Diffuse = MTACalcGTACompleteDiffuse( PS.Normal, VS.Diffuse ); PS.Specular.rgb = gMaterialSpecular.rgb * MTACalculateSpecular( gCameraDirection, gLightDirection, PS.Normal, gMaterialSpecPower ) * specularValue; '},
 { 'PS.Specular.a = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2.5 );  float3 h = normalize(normalize(gCameraPosition - worldPos.xyz) - normalize(gCameraDirection)); PS.Specular.a *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2)); PS.Specular.a *=  saturate(1 + gCameraDirection.z); return PS; } '},
 { 'float4 PixelShaderFunction(PSInput PS) : COLOR0 { float4 texel = tex2D(Sampler0, PS.TexCoord); float4 refTex = tex2D(Sampler1, PS.TexCoord1);	 float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb; vFlakesNormal = 2 * vFlakesNormal - 1.0; float3 vNp2 = normalize(vFlakesNormal + normalize(PS.Normal)); float2 TexCoord = PS.PosProj.xy/PS.PosProj.z;  '},
 { 'TexCoord.xy += PS.ViewNormal.rg * float2( sNorFacXY, sNorFacZ ); TexCoord.x += vNp2.x *(0.1 * bumpSize) - 0.1 * bumpSize; TexCoord.y += vNp2.y *(0.05 * bumpSize) - 0.05 * bumpSize; float4 envMap = tex2D( ReflectionSampler, TexCoord ); float lum = (envMap.r + envMap.g + envMap.b)/3; float adj = saturate( lum - sCutoff ); '},
 { 'adj = adj / (1.01 - sCutoff); envMap += sAdd;  envMap = (envMap * adj); envMap = pow(envMap, sPower);  envMap *= sMul; envMap.rgb = saturate( envMap.rgb ); float4 finalColor = texel * PS.Diffuse; finalColor.rgb += PS.Specular.rgb; finalColor.rgb += saturate( envMap.rgb * envIntensity) * PS.Specular.a; '},
 { 'finalColor.rgb += saturate( refTex.rgb * gMaterialSpecular.rgb * refTexValue ); return saturate(finalColor); } '},
 { 'technique car_paint_reflite { pass P0 { VertexShader = compile vs_2_0 VertexShaderFunction(); PixelShader = compile ps_2_0 PixelShaderFunction(); } } technique fallback { pass P0 { } } '}
						}

local carPaintLayeredDefine = {
 { 'struct VSInput { float3 Position : POSITION0; float3 Normal : NORMAL0; float4 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0; }; ' },
 { 'struct PSInput { float4 Position : POSITION0; float2 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0; float3 PosProj : TEXCOORD1; float3 SparkleTex : TEXCOORD2; float3 Normal : TEXCOORD3; float3 ViewNormal : TEXCOORD4;}; ' },
 { 'PSInput VertexShaderFunction(VSInput VS){ PSInput PS = (PSInput)0; MTAFixUpNormal( VS.Normal ); ' },
 { 'PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 4.0/sSparkleSize; PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 4.0/sSparkleSize; PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 4.0/sSparkleSize;  ' },
 { 'PS.Normal = MTACalcWorldNormal( VS.Normal ); float3 WorldPos = MTACalcWorldPosition( VS.Position ); PS.TexCoord = VS.TexCoord; float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld ); ' },
 { 'float4 viewPos = mul( worldPos , gView );  float4 projPos = mul( viewPos, gProjection); PS.Position = projPos; projPos.x *= uvMul.x; projPos.y *= uvMul.y; ' },
 { 'float projectedX = (0.5 * ( projPos.w + projPos.x ))+ uvMov.x; float projectedY = (0.5 * ( projPos.w + projPos.y )) + uvMov.y; PS.PosProj = float3(projectedX,projectedY,projPos.w ); ' },
 { 'PS.ViewNormal = normalize( mul(PS.Normal, (float3x3)gView )); PS.Diffuse.r = MTACalcGTABuildingDiffuse(VS.Diffuse).a; PS.Diffuse.g = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2.5 );  ' },
 { 'float3 h = normalize(normalize(gCameraPosition - WorldPos.xyz ) - normalize(gCameraDirection)); PS.Diffuse.g *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2)); PS.Diffuse.g *= saturate(1 + gCameraDirection.z); return PS; } ' },
 { 'float4 PixelShaderFunction(PSInput PS) : COLOR0 { float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb; vFlakesNormal = 2 * vFlakesNormal - 1.0; ' },
 { 'float3 vNp2 = normalize(vFlakesNormal + normalize(PS.Normal)); float2 TexCoord = PS.PosProj.xy/PS.PosProj.z;  TexCoord.xy += PS.ViewNormal.rg * float2( sNorFacXY, sNorFacZ ); TexCoord.x += vNp2.x *(0.1 * bumpSize) - 0.1 * bumpSize; ' },
 { 'TexCoord.y += vNp2.y *(0.05 * bumpSize) - 0.05 * bumpSize; float4 envMap = tex2D( ReflectionSampler, TexCoord ); float lum = (envMap.r + envMap.g + envMap.b)/3; float adj = saturate( lum - sCutoff ); ' },
 { 'adj = adj / (1.01 - sCutoff); envMap += sAdd;  envMap = (envMap * adj); envMap = pow(envMap, sPower);  envMap *= sMul; ' },
 { 'envMap.rgb = saturate( envMap.rgb ); float4 finalColor = float4(envMap.rgb, PS.Diffuse.g * envIntensity); finalColor.a *= PS.Diffuse.r;	 return saturate(finalColor);} ' },
 { 'technique car_paint_reflite_layered { pass P0 { DepthBias = -0.0002; VertexShader = compile vs_2_0 VertexShaderFunction(); PixelShader = compile ps_2_0 PixelShaderFunction(); } } ' },
 { 'technique fallback{ pass P0 { } } ' }
							}

local windShieldDefine = {

 { ' struct VSInput { float3 Position : POSITION0; float3 Normal : NORMAL0; float4 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0; float2 TexCoord1 : TEXCOORD1; }; '},
 { ' struct PSInput { float4 Position : POSITION0; float4 Diffuse : COLOR0; float4 Specular : COLOR1; float2 TexCoord : TEXCOORD0; float3 Normal : TEXCOORD1; float3 WorldPos : TEXCOORD2; float3 PosProj : TEXCOORD3; float2 TexCoord1 : TEXCOORD4; float3 ViewNormal : TEXCOORD5; }; '},
 { ' PSInput VertexShaderFunction(VSInput VS) { PSInput PS = (PSInput)0; MTAFixUpNormal( VS.Normal ); PS.Normal = MTACalcWorldNormal( VS.Normal ); PS.WorldPos = MTACalcWorldPosition( VS.Position ); PS.TexCoord = VS.TexCoord; float3 posInWorld = gWorld[3] * 0.02; '},
 { ' posInWorld.x = ( posInWorld.x  - int(posInWorld.x )) * -gWorld[1].x; posInWorld.y = ( posInWorld.y  - int(posInWorld.y )) * -gWorld[1].y; float anim = posInWorld.x + posInWorld.y; PS.TexCoord1 = VS.TexCoord1 + float2( anim, 0 ); float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld ); '},
 { ' float4 viewPos = mul( worldPos , gView );  float4 projPos = mul( viewPos, gProjection); PS.Position = projPos; projPos.x *= uvMul.x; projPos.y *= uvMul.y;	 float projectedX = (0.5 * ( projPos.w + projPos.x ))+ uvMov.x; float projectedY = (0.5 * ( projPos.w + projPos.y )) + uvMov.y; PS.PosProj = float3(projectedX,projectedY,projPos.w ); '},
 { ' PS.ViewNormal = normalize( mul(PS.Normal, (float3x3)gView) ); PS.Diffuse = MTACalcGTACompleteDiffuse( PS.Normal, VS.Diffuse ); PS.Specular.rgb = gMaterialSpecular.rgb * MTACalculateSpecular( gCameraDirection, gLightDirection, PS.Normal, gMaterialSpecPower ) * specularValue; PS.Specular.a = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2.5 ); '},
 { ' float3 h = normalize(normalize(gCameraPosition - worldPos.xyz) - normalize(gCameraDirection)); PS.Specular.a *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2)); PS.Specular.a *=  saturate(1 + gCameraDirection.z); return PS; } '},
 { ' float4 PixelShaderFunction(PSInput PS) : COLOR0 { float microflakePerturbation = 1.00; float4 texel = tex2D(Sampler0, PS.TexCoord); float4 refTex = tex2D(Sampler1, PS.TexCoord1); float2 TexCoord = PS.PosProj.xy/PS.PosProj.z; '},
 { ' TexCoord += PS.ViewNormal.rg * float2(sNorFacXY,sNorFacZ); float4 envMap = tex2D( ReflectionSampler, TexCoord ); float lum = (envMap.r + envMap.g + envMap.b)/3; float adj = saturate( lum - sCutoff ); adj = adj / (1.01 - sCutoff); '},
 { ' envMap += sAdd;  envMap = (envMap * adj); envMap = pow(envMap, sPower);  envMap *= sMul; envMap = saturate( envMap );  float4 finalColor = texel * PS.Diffuse; finalColor.rgb += PS.Specular.rgb; if ((isShatter) ||(PS.Diffuse.a <= 0.85)) finalColor.rgb += saturate(envMap.rgb * envIntensity) * PS.Specular.a; '},
 { ' if (isShatter)  finalColor.a = max(0, texel.a); finalColor.rgb += saturate(refTex.rgb * gMaterialSpecular.rgb * refTexValue); return saturate(finalColor); } '},
 { ' technique car_paint_reflite { pass P0 { VertexShader = compile vs_2_0 VertexShaderFunction(); PixelShader = compile ps_2_0 PixelShaderFunction(); } } technique fallback { pass P0 { } } '}
						}

local windShieldLayeredDefine = {
 { ' struct VSInput { float3 Position : POSITION0; float3 Normal : NORMAL0; float4 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0;}; '},
 { ' struct PSInput { float4 Position : POSITION0; float2 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0; float3 PosProj : TEXCOORD1; float3 Normal : TEXCOORD2; float3 ViewNormal : TEXCOORD3;}; '},
 { ' PSInput VertexShaderFunction(VSInput VS) { PSInput PS = (PSInput)0; MTAFixUpNormal( VS.Normal ); PS.Normal = MTACalcWorldNormal( VS.Normal ); '},
 { ' float3 WorldPos = MTACalcWorldPosition( VS.Position ); PS.TexCoord = VS.TexCoord; float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld );	 float4 viewPos = mul( worldPos , gView );  float4 projPos = mul( viewPos, gProjection); PS.Position = projPos; '},
 { ' projPos.x *= uvMul.x; projPos.y *= uvMul.y;	 float projectedX = (0.5 * ( projPos.w + projPos.x ))+ uvMov.x; float projectedY = (0.5 * ( projPos.w + projPos.y )) + uvMov.y; PS.PosProj = float3(projectedX, projectedY, projPos.w ); PS.ViewNormal = normalize( mul(PS.Normal, (float3x3)gView )); '},
 { ' PS.Diffuse.r = MTACalcGTABuildingDiffuse(VS.Diffuse).a; PS.Diffuse.g = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2.5 );  float3 h = normalize(normalize(gCameraPosition - WorldPos.xyz ) - normalize(gCameraDirection)); PS.Diffuse.g *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2)); PS.Diffuse.g *= saturate(1 + gCameraDirection.z); return PS; '},
 { ' } float4 PixelShaderFunction(PSInput PS) : COLOR0 { float microflakePerturbation = 1.00; float4 texel = tex2D(Sampler0, PS.TexCoord); float2 TexCoord = PS.PosProj.xy/PS.PosProj.z; TexCoord += PS.ViewNormal.rg * float2(sNorFacXY,sNorFacZ); '},
 { ' float4 envMap = tex2D( ReflectionSampler, TexCoord ); float lum = (envMap.r + envMap.g + envMap.b)/3; float adj = saturate( lum - sCutoff ); adj = adj / (1.01 - sCutoff); envMap += sAdd;  envMap = (envMap * adj); envMap = pow(envMap, sPower);  envMap *= sMul; '},
 { ' envMap.rgb = saturate( envMap.rgb ); float4 finalColor = 0; if ((isShatter) ||(PS.Diffuse.r <= 0.85)) finalColor = float4( envMap.rgb, envIntensity * PS.Diffuse.g * PS.Diffuse.r); if (isShatter)  finalColor.a = max(0, texel.a * 0.1); return saturate(finalColor); } '},
 { ' technique car_paint_reflite_layered {pass P0{ DepthBias = -0.0002; VertexShader = compile vs_2_0 VertexShaderFunction(); PixelShader = compile ps_2_0 PixelShaderFunction(); }} technique fallback{pass P0{}} '}
								}

function writeFileLine( theFile, theLine)
    if ( theFile ) then
        pos = fileGetSize( theFile )
        newPos = fileSetPos ( theFile, pos )
        writeFile = fileWrite ( theFile, theLine .."\n" )
        if not ( writeFile ) then
            outputDebugString ( "Error writing the shader file." )
            return false
		else
			return true
		end
	end
end

function createShaderFiles(isCPLay,isVSLay)
	local layerString = ""
	if isCPLay then layerString = "_layer" end
	-- carpaint shader create
	local isvalid = true
	local fxFilePaint = fileCreate("fx/car_paint"..layerString..".fx")
	if not fxFilePaint then return false end
	for i,thisLine in ipairs(sharedDefine) do
		isvalid = isvalid and writeFileLine( fxFilePaint, thisLine[1])
	end
	if isCPLay then
		for i,thisLine in ipairs(carPaintLayeredDefine) do
			isvalid = isvalid and writeFileLine( fxFilePaint, thisLine[1])
		end
	else
		for i,thisLine in ipairs(carPaintDefine) do
			isvalid = isvalid and writeFileLine( fxFilePaint, thisLine[1])
		end
	end
	fileClose ( fxFilePaint )
	-- windshield shader create
	if isVSLay then layerString = "_layer" end
	local fxFileGlass = fileCreate("fx/car_glass"..layerString..".fx")
	if not fxFileGlass then return false end
	for i,thisLine in ipairs(sharedDefine) do
		isvalid = isvalid and writeFileLine( fxFileGlass, thisLine[1])
	end
	if isVSLay then
		for i,thisLine in ipairs(windShieldLayeredDefine) do
			isvalid = isvalid and writeFileLine( fxFileGlass, thisLine[1])
		end
	else
		for i,thisLine in ipairs(windShieldDefine) do
			isvalid = isvalid and writeFileLine( fxFileGlass, thisLine[1])
		end
	end
	fileClose ( fxFileGlass )
end

function destroyShaderFiles(isCPLay,isVSLay)
	local layerString = ""
	if isCPLay then layerString = "_layer" else layerString = "" end
	fileDelete("fx/car_paint"..layerString..".fx")
	if isVSLay then layerString = "_layer" else layerString = "" end
	fileDelete("fx/car_glass"..layerString..".fx")
end
