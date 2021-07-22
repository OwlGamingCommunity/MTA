--fakevideo
--Script allows replacing textures in the game with a range of remote pictures to make animated textures
--Created by Exciter, 21.06.2014 (DD.MM.YYYY).
--Based upon iG texture-system (based on Exciter's uG/RPP texture-system), shader_cinema_fl by Ren712, and OwlGaming/Cat's fixes to texture-system based on mabako-clothingstore. 

--settings
noDisc_id = 2
noDisc_id_clubtec = 2

function getFakevideoData(id)
	return fakevideos[id]
end