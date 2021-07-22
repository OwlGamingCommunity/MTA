bool isFRon = true;
float4 gLightColor = float4(1,1,0.8,1);

float4 PixelShaderPS(float4 TexCoord : TEXCOORD0, float4 Position : POSITION) : COLOR0
{
	float4 outPut=0;
	if (isFRon==true) { outPut=gLightColor;
	outPut.a=saturate((1-TexCoord.y)*0.13)*gLightColor;}
	return outPut;
}

technique shader_lightRays
{
    pass P0
    {
	AlphaRef = 1;
	AlphaBlendEnable = TRUE;
	PixelShader = compile ps_2_0 PixelShaderPS();
    }
}

technique fallback
{
    pass P0
    {
    }
}
