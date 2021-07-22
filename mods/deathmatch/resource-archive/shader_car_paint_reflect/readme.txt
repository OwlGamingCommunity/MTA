Resource: Shader Car Paint reflect
Video: http://www.youtube.com/watch?v=xIfxp4hJgPs

This is a modified shader_car_paint resource from shader examples at:
http://wiki.multitheftauto.com/wiki/Shader_examples

Carpaint color bug and reflection vector bug have been fixed.
Like in car_paint_fix_v2 i have enabled the dirt texture.
The reflection is based on screen source, giving an illusion 
of realtime reflection. Effect is similar to what is seen in ENB.  
It is applied to vehicle paint and windshields.
The effect requires (just as the carpaint shader) PS Model 2.0 GFX.
So it will run on almost anything.
Updare 1.1:
-New reflection quality

Updare 1.08:
-Changed the windshield techniqued.
The reflection is drawn on top of the original gtasa effect.
Looks better imho.
-The effect uses max distance variable to optimise drawing.
-Reconfigured the effect.

Updare 1.05:
-Reconfigured the effects
-Added some variables

Updare 1.04:
-fixed generic texture bug.
-added remaining textures

update 1.03:
-added bright pass for reflection texture
-added reflection flip and some useful variables
-added some missing textures in the list
-calibrated texture coords, normalisation


have fun
Ren712

knoblauch700@o2.pl

Credits:
I'd like to thank Ccw for his support.
And diegofkda for bug reports.