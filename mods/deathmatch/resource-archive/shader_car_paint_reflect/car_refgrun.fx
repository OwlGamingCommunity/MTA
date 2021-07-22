// paint fix and reflection by Ren712
// car_refgrun.fx
//
//
// Badly converted from:
//
//      ShaderX2 – Shader Programming Tips and Tricks with DirectX 9
//      http://developer.amd.com/media/gpu_assets/ShaderX2_LayeredCarPaintShader.pdf
//
//      Chris Oat           Natalya Tatarchuk       John Isidoro
//      ATI Research        ATI Research            ATI Research
//

//some additional variables for the reflection
//for reflection factor look for brightnessFactor in piel shader


  float brightnessFactor = 0.20;
  float dirtTex =1;
  float bumpSize =0.02;
  float sNormZ =3;
  float sRefFl =1;
  float sRefFlan = 0.2;
  float sAdd=0.1;  
  float sMul=1.1; 
  float sCutoff : CUTOFF = 0.16;         // 0 - 1
  float sPower : POWER  = 2;            // 1 - 5
  float sNorFac= 1;
  float sProjectedXsize=0.45;
  float sProjectedXvecMul=0.6;
  float sProjectedXoffset=-0.021;
  float sProjectedYsize=0.4;
  float sProjectedYvecMul=0.6;
  float sProjectedYoffset=0.22;

//---------------------------------------------------------------------
// Car paint settings
//---------------------------------------------------------------------
texture sReflectionTexture;
texture sRandomTexture;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"

//------------------------------------------------------------------------------------------
// Samplers for the textures
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture         = (gTexture0);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
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
    float4 Position : POSITION; 
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
	float3 View : TEXCOORD1;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION;
    float4 Diffuse : COLOR0;
	float4 Specular : COLOR1;   
    float2 TexCoord : TEXCOORD0;
    float3 Tangent : TEXCOORD1;
    float3 Binormal : TEXCOORD2;
    float3 Normal : TEXCOORD3;
    float3 View : TEXCOORD4;
    float3 SparkleTex : TEXCOORD5;
	float2 TexCoord_dust : TEXCOORD6;

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

    // Transform postion
	
	float4 worldPosition = mul ( VS.Position, gWorld );
	float4 viewPosition  = mul ( worldPosition, gView );
	float4 position = mul ( viewPosition, gProjection );
	PS.Position  = position;     
	float3 viewDirection = normalize(gCameraPosition - worldPosition);
	
    // Fake tangent and binormal
    float3 Tangent = VS.Normal.yxz;
    Tangent.xz = VS.TexCoord.xy;
    float3 Binormal =normalize( cross(Tangent, VS.Normal) );
    Tangent = normalize( cross(Binormal, VS.Normal) );

    // Transfer some stuff
    PS.Normal = normalize( mul(VS.Normal, (float3x3)gWorldInverseTranspose).xyz );
	PS.Tangent = normalize(mul(Tangent, (float3x3)gWorldInverseTranspose).xyz);
	PS.Binormal = normalize( mul(Binormal, (float3x3)gWorldInverseTranspose).xyz );
	
    PS.View =normalize(viewDirection); 
	
	PS.TexCoord_dust = VS.TexCoord;
	
    PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 4.0;
    PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 4.0;
    PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 4.0;

	float4 eyeVector=mul(-VS.Position, gWorldViewProjection);
	float projectedX =(((eyeVector.x) /eyeVector.z*sProjectedXvecMul)*sProjectedXsize+0.5)+sProjectedXoffset;
	float projectedY =(((eyeVector.y) /eyeVector.z*sProjectedYvecMul)*sProjectedYsize+0.5)+sProjectedYoffset; 
	if ((gCameraDirection.z > sRefFlan) && sRefFl==1) {eyeVector=mul(VS.Position, gWorldViewProjection);
	projectedY =(((-eyeVector.y) /eyeVector.z*sProjectedYvecMul)*sProjectedYsize+0.5)-sProjectedYoffset;}
    // Calc and send reflection lookup coords to pixel shader
	float3 Nn = VS.Normal/(length(VS.Normal)*sNorFac);
    float3 Vn = float3(projectedX,projectedY,0);
    float2 vReflection = reflect(Vn.xy,Nn.xy);
    PS.TexCoord = vReflection.xy;
    // Calc lighting
    PS.Diffuse = MTACalcGTAVehicleDiffuse( PS.Normal, VS.Diffuse );
    PS.Specular.a = pow(VS.Normal.z,sNormZ);   
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
    //reflection variable here

    // Some settings for something or another
    float microflakePerturbation = 1.00;
    float normalPerturbation = 1.00;
    float microflakePerturbationA = 0.10;

    // Compute paint colors
    float4 base = gMaterialAmbient;
	
    float4 paintColorMid;
    float4 paintColor2;
    float4 paintColor0;
    float4 flakeLayerColor;

    paintColorMid = base;
    paintColor2.r = base.g / 2 + base.b / 2;
    paintColor2.g = (base.r / 2 + base.b / 2);
    paintColor2.b = base.r / 2 + base.g / 2;

    paintColor0.r = base.r / 2 + base.g / 2;
    paintColor0.g = (base.g / 2 + base.b / 2);
    paintColor0.b = base.b / 2 + base.r / 2;

    flakeLayerColor.r = base.r / 2 + base.b / 2;
    flakeLayerColor.g = (base.g / 2 + base.r / 2);
    flakeLayerColor.b = base.b / 2 + base.g / 2;

    // Get the surface normal
    float3 vNormal = PS.Normal;

    // Micro-flakes normal map is a high frequency normalized
    // vector noise map which is repeated across the surface.
    // Fetching the value from it for each pixel allows us to
    // compute perturbed normal for the surface to simulate
    // appearance of micro-flakes suspended in the coat of paint:
    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;

    // Don't forget to bias and scale to shift color into [-1.0, 1.0] range:
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    // This shader simulates two layers of micro-flakes suspended in
    // the coat of paint. To compute the surface normal for the first layer,
    // the following formula is used:
    // Np1 = ( a * Np + b * N ) / || a * Np + b * N || where a << b
    //
    float3 vNp1 = microflakePerturbationA * vFlakesNormal + normalPerturbation * vNormal ;

    // To compute the surface normal for the second layer of micro-flakes, which
    // is shifted with respect to the first layer of micro-flakes, we use this formula:
    // Np2 = ( c * Np + d * N ) / || c * Np + d * N || where c == d
    float3 vNp2 = microflakePerturbation * ( vFlakesNormal + vNormal ) ;

    // The view vector (which is currently in world space) needs to be normalized.
    // This vector is normalized in the pixel shader to ensure higher precision of
    // the resulting view vector. For this highly detailed visual effect normalizing
    // the view vector in the vertex shader and simply interpolating it is insufficient
    // and produces artifacts.

   float3 vView = PS.View;
    // Transform the surface normal into world space (in order to compute reflection
    // vector to perform environment map look-up):
	 float3x3 mTangentToWorld = transpose( float3x3( PS.Tangent,PS.Binormal, PS.Normal ) );
     float3 vNormalWorld = normalize( mul( mTangentToWorld, vNormal ));
       
    // Compute reflection vector resulted from the clear coat of paint on the metallic
    // surface:
	
	 float fNdotV = saturate(dot( vNormalWorld, vView ));
	
	float2 vReflection = PS.TexCoord;
    // Hack in some bumpyness
	vReflection.xy +=vNp2.xy*bumpSize;	
	
    float4 envMap = tex2D( ReflectionSampler, vReflection );
	float lum = (envMap.r + envMap.g + envMap.b)/3;
    float adj = saturate( lum - sCutoff );
    adj = adj / (1.01 - sCutoff);
    envMap+=sAdd;
    envMap = (envMap * adj);
    envMap = pow(envMap, sPower);
	envMap*=sMul;
    if (gCameraDirection.z < -0.5) {envMap.rgb*=(2*(1+gCameraDirection.z)); }

      // Brighten the environment map sampling result:
    envMap.rgb *= brightnessFactor;
    envMap.rgb *= PS.Specular.a;   
    // Dust texture
	float4 maptex = tex2D(Sampler0,PS.TexCoord_dust.xy);
	

    // Compute modified Fresnel term for reflections from the first layer of
    // microflakes. First transform perturbed surface normal for that layer into
    // world space and then compute dot product of that normal with the view vector:
    float3 vNp1World = normalize( mul( mTangentToWorld, vNp1) );
    float fFresnel1 = saturate( dot( vNp1World, vView ));

    // Compute modified Fresnel term for reflections from the second layer of
    // microflakes. Again, transform perturbed surface normal for that layer into
    // world space and then compute dot product of that normal with the view vector:
    float3 vNp2World = normalize( mul( mTangentToWorld, vNp2 ));
    float fFresnel2 = saturate( dot( vNp2World, vView ));
    float fFresnel3 = saturate( dot( vNormal, vView));
	
    // Combine all layers of paint as well as two layers of microflakes
       float fFresnel1Sq = fFresnel1 * fFresnel1;

		 float4 paintColor = fFresnel1 * paintColor0 +
		 fFresnel1Sq * paintColorMid +
		 fFresnel1Sq * fFresnel1Sq * paintColor2 +
         pow( fFresnel2, 32 ) * flakeLayerColor;
			
 // Combine result of environment map reflection with the paint color:
 
     float fEnvContribution =1.0 - 0.5 *fNdotV; 
    float4 finalColor;
	finalColor =paintColor;
    finalColor+=((envMap) * (fEnvContribution));
    finalColor.a = 1.0;
    // Bodge in the car colors
    float4 Color = 1;
    Color = (finalColor / 1 + PS.Diffuse * 0.5);
    Color += finalColor * PS.Diffuse * 1.5;
	if (dirtTex==1) {Color *= maptex; }
    Color.a = PS.Diffuse.a;
    return Color;

}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique car_reflect_paint
{
    pass P0
    {
		AlphaBlendEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
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
