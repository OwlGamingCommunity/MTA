//
// water.fx
//

//---------------------------------------------------------------------
// Water settings
//---------------------------------------------------------------------
texture showroomMapCube_Tex;
texture microflakeNMapVol_Tex;
float4 gWaterColor = float4(90 / 255.0, 170 / 255.0, 170 / 255.0, 240 / 255.0 );


//---------------------------------------------------------------------
// These parameters are set by MTA whenever a shader is drawn
//---------------------------------------------------------------------
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;

float3 gCameraPosition : CAMERAPOSITION;

float gTime : TIME;


//------------------------------------------------------------------------------------------
// Samplers for the textures
//------------------------------------------------------------------------------------------
sampler3D microflakeNMapVol = sampler_state
{
   Texture = (microflakeNMapVol_Tex);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};

samplerCUBE showroomMapCube = sampler_state
{
   Texture = (showroomMapCube_Tex);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex and pixel shaders
//---------------------------------------------------------------------
struct VertexShaderInput
{
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord0 : TEXCOORD0;
};

struct PixelShaderInput
{
    float4 Position  : POSITION;
    float4 Diffuse : COLOR0;
    float3 WorldPosition : TEXCOORD0;
    float4 SparkleTex : TEXCOORD1;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PixelShaderInput VertexShaderFunction(VertexShaderInput In)
{
    PixelShaderInput Out = (PixelShaderInput)0;

    // Transform postion
    Out.Position = mul(float4(In.Position, 1), gWorldViewProjection);

    // Transfer stuff
    Out.WorldPosition = mul(float4(In.Position, 1), (float4x3)gWorld);

    // Scroll noise texture
    float2 uvpos1 = 0;
    float2 uvpos2 = 0;

    uvpos1.x = sin(gTime/40);
    uvpos1.y = fmod(gTime/50,1);

    uvpos2.x = fmod(gTime/10,1);
    uvpos2.y = sin(gTime/12);

    Out.SparkleTex.x = Out.WorldPosition.x / 6 + uvpos1.x;
    Out.SparkleTex.y = Out.WorldPosition.y / 6 + uvpos1.y;
    Out.SparkleTex.z = Out.WorldPosition.x / 10 + uvpos2.x;
    Out.SparkleTex.w = Out.WorldPosition.y / 10 + uvpos2.y;

    // Convert regular water color to what we want
    float4 waterColorBase = float4(90 / 255.0, 170 / 255.0, 170 / 255.0, 240 / 255.0 );
    float4 conv           = float4(30 / 255.0,  58 / 255.0,  58 / 255.0, 200 / 255.0 );
    Out.Diffuse = saturate( gWaterColor * conv / waterColorBase );

    return Out;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PixelShaderInput In) : COLOR0
{
    //
    // This was all ripped and modded from the car paint shader, so some of the comments may seem a bit strange
    //

    float brightnessFactor = 0.10;
    float glossLevel = 0.00;

    // Get the surface normal
    float3 vNormal = float3(0,0,1);

    // Micro-flakes normal map is a high frequency normalized
    // vector noise map which is repeated across the surface.
    // Fetching the value from it for each pixel allows us to
    // compute perturbed normal for the surface to simulate
    // appearance of micro-flakes suspended in the coat of paint:
    float3 vFlakesNormal = tex3D(microflakeNMapVol, float3(In.SparkleTex.xy,1)).rgb;
    float3 vFlakesNormal2 = tex3D(microflakeNMapVol, float3(In.SparkleTex.zw,2)).rgb;

    vFlakesNormal = (vFlakesNormal + vFlakesNormal2 ) / 2;

    // Don't forget to bias and scale to shift color into [-1.0, 1.0] range:
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    // To compute the surface normal for the second layer of micro-flakes, which
    // is shifted with respect to the first layer of micro-flakes, we use this formula:
    // Np2 = ( c * Np + d * N ) / || c * Np + d * N || where c == d
    float3 vNp2 = ( vFlakesNormal + vNormal ) ;

    // The view vector (which is currently in world space) needs to be normalized.
    // This vector is normalized in the pixel shader to ensure higher precision of
    // the resulting view vector. For this highly detailed visual effect normalizing
    // the view vector in the vertex shader and simply interpolating it is insufficient
    // and produces artifacts.
    float3 vView = normalize( gCameraPosition - In.WorldPosition );

    // Transform the surface normal into world space (in order to compute reflection
    // vector to perform environment map look-up):
    float3 vNormalWorld = float3(0,0,1);

    // Compute reflection vector resulted from the clear coat of paint on the metallic
    // surface:
    float fNdotV = saturate(dot( vNormalWorld, vView));
    float3 vReflection = 2 * vNormalWorld * fNdotV - vView;

    // Hack in some bumpyness
    vReflection += vNp2;

    // Sample environment map using this reflection vector:
    float4 envMap = texCUBE( showroomMapCube, vReflection );

    // Premultiply by alpha:
    envMap.rgb = envMap.rgb * envMap.a;

    // Brighten the environment map sampling result:
    envMap.rgb *= brightnessFactor;


    float4 OutColor = 1;

    // Bodge in the water color
    OutColor = envMap + In.Diffuse * 0.5;
    OutColor += envMap * In.Diffuse;
    OutColor.a = In.Diffuse.a;

    return OutColor;
}



//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique water
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}


technique fallback
{
    pass P0
    {
    }
}
