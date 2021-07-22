texture gTexture;

technique TexReplace
{
	pass P0
	{
		Texture[0] = gTexture;
	}
}