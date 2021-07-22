bool isFLon = true;
float4 gLightColor = float4(1,1,0.8,0.8);

texture gTexture0 < string textureState="0,Texture"; >;
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};
    
float4 PixelShaderPS(float4 TexCoord : TEXCOORD0, float4 Position : POSITION, float4 Diffuse:COLOR0) : COLOR0
{
	float4 Tex = tex2D(Sampler0, TexCoord);
	if (isFLon==true) 	{ return float4(Tex.rgb,1)*float4(gLightColor.rgb,1); }
						else
						{return float4(Tex.rgb,1)*Diffuse;}
}

technique shader_lightBulb
{
    pass P0
    {
		PixelShader = compile ps_2_0 PixelShaderPS();
    }
}

technique fallback
{
    pass P0
    {
    }
}

