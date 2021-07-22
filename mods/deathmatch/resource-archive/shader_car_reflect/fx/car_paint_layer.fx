//
// car_paint_layer.fx
// author: Owner of || Freeroam. Don't dare copying it as you won't even succeed.
//

//---------------------------------------------------------------------
// Settings
//---------------------------------------------------------------------
float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0.25);
float sNorFacXY = 0.25;
float sNorFacZ = 1;
float sSparkleSize = 0.5;
float bumpSize = 1;
float envIntensity = 1;

float sAdd = 0.1;
float sMul = 1.1;
float sCutoff = 0.16;
float sPower = 2;

texture sReflectionTexture;
texture sRandomTexture;

static const float pi = 3.141592653589793f;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#define GENERATE_NORMALS      // Uncomment for normals to be generated
#include "mta-helper.fx"

//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------

sampler3D RandomSampler = sampler_state
{
    Texture = (sRandomTexture);
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = POINT;
    MIPMAPLODBIAS = 0.000000;
};

sampler2D ReflectionSampler = sampler_state
{
    Texture = (sReflectionTexture);	
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
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
  float2 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float3 PosProj : TEXCOORD1;
  float3 SparkleTex : TEXCOORD2;
  float3 Normal : TEXCOORD3;
  float3 ViewNormal : TEXCOORD4;
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

    PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 4.0/sSparkleSize;
    PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 4.0/sSparkleSize;
    PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 4.0/sSparkleSize;

    // Set information to do normal calculation
    PS.Normal = MTACalcWorldNormal( VS.Normal );
    float3 WorldPos = MTACalcWorldPosition( VS.Position );

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;

    // Calculate screen pos of vertex	
    float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld );	
    float4 viewPos = mul( worldPos , gView );
    float4 projPos = mul( viewPos, gProjection);
    PS.Position = projPos;

    // Reflection lookup coords to pixel shader
    projPos.x *= uvMul.x; projPos.y *= uvMul.y;	
    float projectedX = (0.5 * ( projPos.w + projPos.x ))+ uvMov.x;
    float projectedY = (0.5 * ( projPos.w + projPos.y )) + uvMov.y;
    PS.PosProj = float3(projectedX,projectedY,projPos.w );

    // Set information for the refraction
    PS.ViewNormal = normalize( mul(PS.Normal, (float3x3)gView ));

    // Calculate alpha
    PS.Diffuse.r = MTACalcGTABuildingDiffuse(VS.Diffuse).a;
    PS.Diffuse.g = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2.5 );

    float3 h = normalize(normalize(gCameraPosition - WorldPos.xyz ) - normalize(gCameraDirection));
    PS.Diffuse.g *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2));
    PS.Diffuse.g *=  saturate(1 + gCameraDirection.z);
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
    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    float3 vNp2 = normalize((vFlakesNormal + normalize(PS.Normal));

    float2 TexCoord = PS.PosProj.xy/PS.PosProj.z;
    TexCoord.xy += PS.ViewNormal.rg * float2( sNorFacXY, sNorFacZ );
    TexCoord.x += vNp2.x *(0.1 * bumpSize) - 0.1 * bumpSize;
    TexCoord.y += vNp2.y *(0.05 * bumpSize) - 0.05 * bumpSize;

    float4 envMap = tex2D( ReflectionSampler, TexCoord );

    // basic filter for vehicle effect reflection
    float lum = (envMap.r + envMap.g + envMap.b)/3;
    float adj = saturate( lum - sCutoff );
    adj = adj / (1.01 - sCutoff);
    envMap += sAdd;
    envMap = (envMap * adj);
    envMap = pow(envMap, sPower);
    envMap *= sMul;
    envMap.rgb = saturate( envMap.rgb );

    // Combine
    float4 finalColor = float4(envMap.rgb, PS.Diffuse.g * envIntensity);
    finalColor.a *= PS.Diffuse.r;	
    return saturate(finalColor);
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique car_paint_reflite_layered
{
    pass P0
    {
        DepthBias = -0.0002;
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