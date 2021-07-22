Resource: Dynamic Lighting v1.5.3
contact: knoblauch700@o2.pl
Update v1.5.2
-fixed a typo
Update v1.5.1
-updated texture list (for new dynamic_sky resource)
Update v1.5.0
-applied setDiffColorRange, setDirColorRange
-applied nightSpot (nightMod required) 
-new functions setNightSpotEnable, setNightSpotRadius, setNightSpotPosition
Update v1.4.9
-applied vehicleEnv texture for non layered vehicle effect
-set gMaxLights to 8 (15 is maximum value)
Update v1.4.8
-applied specular light for windsheild (nightMod)
-the vehicle shader effect is applied to windshield (nightMod)
-point, spot, diffuse and directional lighting for vehicle non layered effect are properly colored 
Update v1.4.7
-updated texture list
Update v1.4.6
-added setDiffLightEnable, setDiffLightColor
-recreated specular lighting for vehicles
-minor changes for nightMod options
Update v1.4.4
-added setNormalShading, getLightDirection, getLightPosition, getLightColor, getLightAttenuation
getLightNormalShading, getLightFalloff, getLightTheta, getLightPhi
-directional light code is not applied when the light is not used
Update v1.4.3
-shaders are created only on redefinition
-added setShadersLayered function
Update v1.4.2
-improved shader performance
-dropped the setNormalShadowingAmount function
Update v1.4.0
-improved light sorting

This resource lets You create dynamic lights in MTA. It gives you a list of exported functions
that You can use to create per pixel pointlights and spotlights.

Check out mta wiki for details:
https://wiki.multitheftauto.com/wiki/Resource:Dynamic_lighting

exported functions:

createPointLight(float posX,posY,posZ,colorR,colorG,colorB,colorA,attenuation,[bool normalShadowing = true])
	Creates a pointlight.
createSpotLight(float posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,bool isEuler,float falloff,theta,phi,attenuation,[bool normalShadowing = true])
	Creates a spotlight.
destroyLight(lightElement)
	Destroys the light element.
setLightDirection(element lightElement,float dirX,dirY,dirZ,[isEuler])
	Direction that the light is pointing in world space. This member has meaning only for spotlights. 
setLightPosition(element lightElement,float posX,posY,posZ)
	Position of the light in world space,
setLightColor(lightElement,colorR,colorG,colorB,colorA)
	RGBA diffuse color emitted by the light. 
setLightAttenuation(element lightElement,float attenuation)
	Value specifying how the light intensity changes over distance.
setLightFalloff(element lightElement,float falloff)
	Decrease in illumination between a spotlight's inner cone (the angle specified by Theta) and the outer 
	edge of the outer cone (the angle specified by Phi). 
setLightTheta(element lightElement,float theta)
	Angle, in radians, of a spotlight's inner cone - that is, the fully illuminated spotlight cone. 
	This value must be in the range from 0 through the value specified by Phi.
setLightPhi(element lightElement,float phi)
	Angle, in radians, defining the outer edge of the spotlight's outer cone. Points outside this cone 
	are not lit by the spotlight. This value must be between 0 and pi.
setLightNormalShadowing(element lightElement,bool normalShadow)
	Determine if the light source should be obscured when lighting a surface on opposite angles..
setNormalShading(bool isWorld, isVeh, isPed)
	Same as above - but works on ped and vehicle elements and for all lights.
setShadersLayered(bool isWorld, isVeh, isPed)
	Should the main shader effects be created in a separate render pass ? Non layered effects work faster.
	As default only the vehicle effect is layered - due to issues with recreating the vehicle effect.
setGenerateBumpNormals(bool isTrue,[int textureSize = 512, float normalStrength.x = 1, float normalStrength.y = 1, float normalStrength.z = 1])
	Should the shader effect generate bump normals from texture0. Doesn't work when normal shadowing is set to false.
setTextureBrightness(float brightness)
	Set the world and ped textures brightness  1 - full 0 - none. Is currently not applied to vehicles, but can be managed
	by an external non layered vehicle effect.
setLightsDistFade(int MaxEffectFade,int MinEffectFade)
	Set the Max distance of the light to sync and the distance on which the light starts to fade out.
setLightsEffectRange(int MaxEffectRange)
	Set the Max distance from the camera the shader effects are applied to.
setShaderForcedOn(bool)
	Should the shader effect turn off when no lightsources
setShaderTimeOut(int)
	Should the shader effect turn off after number of seconds (when no lightsources)
setShaderNightMod(bool)
	Enable nightMod effect - requires proper manipulation of setTextureBrightness and SetShaderDayTime, also some additional shaders.
setShaderDayTime(float)
	Another additional variable to control texture colors - requires setShaderNightMod(true)
setShaderPedDiffuse(bool)
	Enable or disable gta directional lights for ped.
setDirLightEnable(bool)
	This function creates a vertex shader directional light. NOTE: Forcing the effects on or using any other lights is required for directional light to work. 
setDirLightDirection(float dirX,dirY,dirZ,[bool isEuler = false])
	This function sets the directional light direction. 
setDirLightColor(float colorR,colorG,colorB,colorA)
	This function sets the directional light color value.
setDirColorRange(float)
	Set the effect visibility range
setDiffLightEnable(bool)
	This function creates a vertex shader diffuse light. NOTE: Forcing the effects on or using any other lights is required for light to work. 
setDiffLightColor(float colorR,colorG,colorB,colorA)
	This function sets the directional light color value.
setDiffColorRange(float)
	Set the effect visibility range
setNightSpotEnable(bool)
	The function creates a zone in world - unaltered by gDayTime and gBrightness.
setNightSpotRadius(float)
	Set the effect visibility range ( from position in world space)	
setNightSpotPosition(float posX,posY,posZ)
	Position of the light in world space.