texture decal;

technique TexReplace
{
	pass P0
	{
		Texture[0] = decal;
	}
}