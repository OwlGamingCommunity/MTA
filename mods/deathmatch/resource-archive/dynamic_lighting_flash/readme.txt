Resource: Shader_flashlight_test v1.2.2
contact: knoblauch700@o2.pl
Update 1.22
-readded gAttenuation variable
-added switchFlashLight event for external resources
Update 1.21
-Improved shader performance (requires new dynamic_lighting resource version)
Update 1.20
-Changed effectRange and distFade to make this effect as fps friendly as pre 1.19 version.
Update 1.19
-Using exported functions from dynamic_lighting resource.
Update 1.17
-Decided to drop the redefinition of the effect during play (introduced in 1.04).
-culling the light sources that are not visible on screen.
-Increased max number of synced lights to 15+1 (5+1 is default)

Update 1.16
-Applied better solution for zFighting when the Effect is layered
-removed few shinemap textures from the effect
-isEffectForcedOn: switching between 1 and 2 lights works faster
-Shader model 2 shader is not forced for shader model 3 graphics cards

Update 1.13
-Set the isEffectForcedOn variable to false.

Update 1.12
-Added isEffectForcedOn variable to force the shader effect to be applied when the
lights are turned off. Alternative 'false' serves for better performance (no needless shaders applied) 

Update 1.11
-Set the isEffectLayered variable back to false.

Update 1.10
-Added an option to apply the world and ped effects in a separate pass.
 Gives an ability to use other world shader effects - but with significant FPS drop.
-Changed blending method for vehicle shader.

Update 1.09
-Replaced onClientRender events with timers for some calculations in order to save FPS.

Update 1.08
-Changed the light position update method. Solves issues with light source shaking.

Update 1.07
-Effect redefinition fix 

Update 1.06
-Reapplied gtasa fog for sm 3.0 effect (thanks to ccw for the SM 3.0 pixel shader snippet for fog)
-Added fallback techniques

Update 1.04
-Increased potential max support to 12 flashlights streamed in
-Optimalisation: the effect is redefined and restarted for certain number of light effects

Update 1.03
-Fixed some potential alpha issues
-Optimised the effects
Added some variables:
-gBrightness - modify texture max brightness
-gLightFalloff - a spotlight attenuation variable
-gWorldSelfShadow - bring back world object self shadowing from previous versions

Update 1.02
-Increased max light support for SM3 to 8+1 (localPlayer)
-Applied light sorting (isSortLight)
-theta and phi variables now in dergees instead of radians

Update v1.0.1
-Added some explanation for theta and phi variables
-lowered the gta point light brightness

Update v1.0.0
-Changed the rendering techniques

Instead of a projected cube texture this version uses per pixel spot light.
The effect is rendered in a single pass, that means that the flashlight shouldn't
lag anymore to anyone. Shader model 3 supports up to 6 lights at once while
Shader model 2 - only one light effect synced.

This version (as default) doesn't work with other toWorldTexture effects.
Look into dynamic_lighting resource for details on how to customise it.

Description:

This is the flashlight shader I've been working on. It's a fully functional version. 
All you need is to start the resource and you will see the explanation on how to use 
it in the chatbox.

The shader projects a light effect on nearby world, vehicle and ped textures. 
It uses exported functions of the Dynamic lighting resource.

The original flashlight model from:
http://www.sharecg.com/v/29667/related/5/3D-Model/Flashlight-model+texture
Slightly modified and converted.

You will be needing bone_attach resource - so place it along with flashlight
resource in resources folder. Also You will need synamic_lighting resource  
but I think You've figured it out already. 