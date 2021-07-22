texture Tex0;

technique textureReplacement
{
    pass P0
    {
        Texture[0] = Tex0;
    }
}