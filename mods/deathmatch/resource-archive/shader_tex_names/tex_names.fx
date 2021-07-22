//
// tex_names.fx
//

float Time : TIME;

// Make everything all flashy!
float4 GetColor()
{
    return float4( cos(Time*10), cos(Time*7), cos(Time*4), 1 );
}

//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        MaterialAmbient = GetColor();
        MaterialDiffuse = GetColor();
        MaterialEmissive = GetColor();
        MaterialSpecular = GetColor();

        AmbientMaterialSource = Material;
        DiffuseMaterialSource = Material;
        EmissiveMaterialSource = Material;
        SpecularMaterialSource = Material;

        ColorOp[0] = SELECTARG1;
        ColorArg1[0] = Diffuse;

        AlphaOp[0] = SELECTARG1;
        AlphaArg1[0] = Diffuse;

        Lighting = true;
    }
}


