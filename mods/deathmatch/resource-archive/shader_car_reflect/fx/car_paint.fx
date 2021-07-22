//
// car_paint.fx
// author: Ren712/, and the Owner of || Freeroam. Don't dare copying it as you won't even succeed.
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
float specularValue = 1;
float refTexValue = 0.2;

float sAdd = 0.1;
float sMul = 1.1;
float sPower = 2;
float sCutoff = 0.16;

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
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

sampler Sampler1 = sampler_state
{
    Texture = (gTexture1);
    AddressU = Wrap;
    AddressV = Wrap;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

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
  float2 TexCoord1 : TEXCOORD1;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float4 Specular : COLOR1;
  float2 TexCoord : TEXCOORD0;
  float3 Normal : TEXCOORD1;
  float3 WorldPos : TEXCOORD2;
  float3 PosProj : TEXCOORD3;
  float3 SparkleTex : TEXCOORD4;
  float2 TexCoord1 : TEXCOORD5;
  float3 ViewNormal : TEXCOORD6;
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

    // Set information to do specular calculation
    PS.Normal = mul(VS.Normal, (float3x3)gWorld);
    PS.WorldPos = mul( VS.Position.xyz, (float3x3)gWorld );

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;

    float3 posInWorld = gWorld[3].xyz * 0.02;
    posInWorld.x = ( posInWorld.x  - int(posInWorld.x )) * -gWorld[1].x;
    posInWorld.y = ( posInWorld.y  - int(posInWorld.y )) * -gWorld[1].y;

    float anim = posInWorld.x + posInWorld.y;
    PS.TexCoord1 = VS.TexCoord1 + float2( anim, 0 );

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

    // Calculate GTA lighting for Vehicles
    PS.Diffuse = MTACalcGTACompleteDiffuse( PS.Normal, VS.Diffuse );
    PS.Specular.rgb = gMaterialSpecular.rgb * MTACalculateSpecular( gCameraDirection, gLightDirection, PS.Normal, gMaterialSpecPower ) * specularValue;

    PS.Specular.a = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2.5 );
    float3 h = normalize(normalize(gCameraPosition - worldPos.xyz) - normalize(gCameraDirection));
    PS.Specular.a *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2));
    PS.Specular.a *=  saturate(1 + gCameraDirection.z);
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
    float4 refTex = tex2D(Sampler1, PS.TexCoord1);

    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;
    vFlakesNormal = 2 * vFlakesNormal - 1.0;	
    float3 vNp2 = normalize(vFlakesNormal + normalize(PS.Normal));

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

    // Apply diffuse lighting
    float4 finalColor = texel * PS.Diffuse;

    // Apply specular
    finalColor.rgb += PS.Specular.rgb;
    finalColor.rgb += saturate( envMap.rgb * envIntensity) * PS.Specular.a;
    finalColor.rgb += saturate( refTex.rgb * gMaterialSpecular.rgb * refTexValue );

    return saturate(finalColor);
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique car_paint_reflite
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