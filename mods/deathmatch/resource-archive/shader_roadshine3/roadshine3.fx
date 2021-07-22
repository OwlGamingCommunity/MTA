//
// Example shader - roadshine3.fx
//


//---------------------------------------------------------------------
// Road shine 3 settings
//---------------------------------------------------------------------
float3 sLightDir = float3(0.507,-0.507,-0.2);
float sSpecularPower = 4;
float sSpecularBrightness = 1;
float sStrength = 1;
float sVisibility = 1;
float sFadeStart = 10;          // Near point where distance fading will start
float sFadeEnd = 80;            // Far point where distance fading will complete (i.e. effect will not be visible past this point)


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#define GENERATE_NORMALS      // Uncomment for normals to be generated
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float3 WorldNormal : TEXCOORD1;
  float3 WorldPos : TEXCOORD2;
  float DistFade : TEXCOORD3;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Make sure normal is valid
    MTAFixUpNormal( VS.Normal );

    // Calculate screen pos of vertex
    PS.Position = MTACalcScreenPosition ( VS.Position );

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;

    // Calculate GTA lighting for buildings
    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );

    // Set information to do specular calculation in pixel shader
    PS.WorldNormal = MTACalcWorldNormal( VS.Normal );
    PS.WorldPos = MTACalcWorldPosition( VS.Position );

    // Distance fade calculation
    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, MTACalcWorldPosition( VS.Position ) );
    PS.DistFade = MTAUnlerp ( sFadeEnd, sFadeStart, DistanceFromCamera );

    return PS;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);

    // See how 'grey' the pixel is
    float greyScale = dot(texel.rgb, float3(0.3f, 0.59f, 0.11f));
    float redExtra = abs(texel.r - greyScale);
    float greenExtra = abs(texel.g - greyScale);
    float blueExtra = abs(texel.b - greyScale);
    float colorness = redExtra * 0.3f + greenExtra * 0.59f + blueExtra * 0.11f;
    colorness = colorness * 20 * greyScale;
    colorness = colorness - 0.1;
    float greyness = 1 - saturate(colorness);

    //
    // Specular calculation
    //

    float3 lightDir = normalize(sLightDir);

    // Using Blinn half angle modification for performance over correctness
    float3 h = normalize(normalize(gCameraPosition - PS.WorldPos) - lightDir);
    float specLighting = pow(saturate(dot(h, PS.WorldNormal)), sSpecularPower);

    // Stop underneath artifacts
    float lightAwayDot = -dot(lightDir, PS.WorldNormal);
    if ( lightAwayDot < 0 )
        specLighting = 0;

    // Modulate specular with texture a little bit to break up the surface
    specLighting *= texel.g;

    // Apply diffuse lighting
    float4 finalColor = texel * PS.Diffuse;

    // Apply specular
    finalColor.rgb += texel.rgb * specLighting * ( greyness ) * sSpecularBrightness * saturate( PS.DistFade ) * sStrength * sVisibility;

    return finalColor;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique shine
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
