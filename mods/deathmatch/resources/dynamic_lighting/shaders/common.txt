//------------------------------------------------------------------------------------------
// - Some states for Diffuse
//------------------------------------------------------------------------------------------
int gLighting                      < string renderState="LIGHTING"; >; 
int gDiffuseMaterialSource         < string renderState="DIFFUSEMATERIALSOURCE"; >;           //  = 145,
int gAmbientMaterialSource         < string renderState="AMBIENTMATERIALSOURCE"; >;           //  = 147,
int gEmissiveMaterialSource        < string renderState="EMISSIVEMATERIALSOURCE"; >;          //  = 148,

float4 gGlobalAmbient       < string renderState="AMBIENT"; >;                    //  = 139
float4 gMaterialAmbient     < string materialState="Ambient"; >;
float4 gMaterialDiffuse     < string materialState="Diffuse"; >;
float4 gMaterialEmissive    < string materialState="Emissive"; >;

int sLight1Enable           < string lightEnableState="1,Enable"; >;
int sLight2Enable           < string lightEnableState="2,Enable"; >;
int sLight3Enable           < string lightEnableState="3,Enable"; >;
int sLight4Enable           < string lightEnableState="4,Enable"; >;

float4 sLight1Diffuse           < string lightState="1,Diffuse"; >;
float3 sLight1Direction         < string lightState="1,Direction"; >;

float4 sLight2Diffuse           < string lightState="2,Diffuse"; >;
float3 sLight2Direction         < string lightState="2,Direction"; >;

float4 sLight3Diffuse           < string lightState="3,Diffuse"; >;
float3 sLight3Direction         < string lightState="3,Direction"; >;

float4 sLight4Diffuse           < string lightState="4,Diffuse"; >;
float3 sLight4Direction         < string lightState="4,Direction"; >;

float3 sCameraDirection : CAMERADIRECTION;
float3 sLightDirection : LIGHTDIRECTION;
float4 sLightAmbient : LIGHTAMBIENT;

float4 sMaterialSpecular    < string materialState="Specular"; >;
float sMaterialSpecPower    < string materialState="Power"; >;

//------------------------------------------------------------------------------------------
// CalculateSpecular
// - Get specular intensity
//------------------------------------------------------------------------------------------
float MTACalculateSpecular( float3 CamDir, float3 LightDir, float3 SurfNormal, float SpecPower )
{
    // Using Blinn half angle modification for performance over correctness
    LightDir = normalize(LightDir);
    SurfNormal = normalize(SurfNormal);
    float3 halfAngle = normalize(-CamDir - LightDir);
    float r = dot(halfAngle, SurfNormal);
    return pow(saturate(r), SpecPower);
}

//------------------------------------------------------------------------------------------
// MTACalcGTACompleteDiffuse
//------------------------------------------------------------------------------------------
float4 MTACalcGTAVehicleDiffuse( float3 WorldNormal, float4 InDiffuse )
{
    // Calculate diffuse color by doing what D3D usually does
    float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
    float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
    float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;

    float4 TotalAmbient = ambient * ( gGlobalAmbient + sLightAmbient ) ;

    // Add all the 4 pointlights
    float DirectionFactor=0;
    float4 TotalDiffuse=0;
    if (sLight1Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight1Direction ));
    TotalDiffuse += ( sLight1Diffuse * DirectionFactor );
                         }
    if (sLight2Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight2Direction ));
    TotalDiffuse += ( sLight2Diffuse * DirectionFactor );
                         }
    if (sLight3Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight3Direction ));
    TotalDiffuse += ( sLight3Diffuse * DirectionFactor );
                         }
    if (sLight4Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight4Direction ));
    TotalDiffuse += ( sLight4Diffuse * DirectionFactor );
                         }	
    TotalDiffuse *= diffuse;

    float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
    OutDiffuse.a *= diffuse.a;

    return OutDiffuse;
}

float4 MTACalcGTAPedDiffuse( float3 WorldNormal, float4 InDiffuse )
{
    // Calculate diffuse color by doing what D3D usually does
    float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
    float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
    float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;

    float4 TotalAmbient = ambient * ( gGlobalAmbient );

    // Add all the 4 pointlights
    float DirectionFactor=0;
    float4 TotalDiffuse=0;
    if (sLight1Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight1Direction ));
    TotalDiffuse += ( sLight1Diffuse * DirectionFactor );
                         }
    if (sLight2Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight2Direction ));
    TotalDiffuse += ( sLight2Diffuse * DirectionFactor );
                         }
    if (sLight3Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight3Direction ));
    TotalDiffuse += ( sLight3Diffuse * DirectionFactor );
                         }
    if (sLight4Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -sLight4Direction ));
    TotalDiffuse += ( sLight4Diffuse * DirectionFactor );
                         }	
    TotalDiffuse *= diffuse;

    float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
    OutDiffuse.a *= diffuse.a;

    return OutDiffuse;
}
//------------------------------------------------------------------------------------------
// MTACalcGTABuildingDiffuse
//------------------------------------------------------------------------------------------
float4 MTACalcGTABuildingDiffuse( float4 InDiffuse )
{
    float4 OutDiffuse;

    if ( !gLighting )
    {
        // If lighting render state is off, pass through the vertex color
        OutDiffuse = InDiffuse;
    }
    else
    {
        // If lighting render state is on, calculate diffuse color by doing what D3D usually does
        float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
        float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
        float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;
        OutDiffuse = gGlobalAmbient * saturate( ambient + emissive );
        OutDiffuse.a *= diffuse.a;
    }
    return OutDiffuse;
}

//------------------------------------------------------------------------------------------
// CreateDirLight
//------------------------------------------------------------------------------------------
float4 createDirLight(float3 Normal, float3 LightDir, float4 LightDiffuse)
{		 
    // Compute the direction to the light:
    float3 vLight = normalize( LightDir );
	
    // Determine the final colour:
    float NdotL = saturate( max( 0.0f, dot( Normal, -vLight ) ));
	 
    // The final attenuation is the product of both types 
    // previously evaluated:
	 
    return  NdotL * LightDiffuse;
}

//------------------------------------------------------------------------------------------
// MTAUnlerp
//------------------------------------------------------------------------------------------
float MTAUnlerp( float from, float to, float pos )
{
    if ( from == to )
        return 1.0;
    else
        return ( pos - from ) / ( to - from );
}

//------------------------------------------------------------------------------------------
// CreateVertexLightPoint
//------------------------------------------------------------------------------------------
float createVertexLightPoint(float3 WorldPos, float3 LightPos, float Attenuation )
{
     // Compute the distance attenuation factor:
     float fDistance = distance( LightPos, WorldPos );

     float fAttenuation = MTAUnlerp( Attenuation, Attenuation/2, fDistance );
 
     // Pass the attenuation:

	 return saturate( fAttenuation );
}

//------------------------------------------------------------------------------------------
// MTAApplyFog
//------------------------------------------------------------------------------------------
int gFogEnable                     < string renderState="FOGENABLE"; >;
float4 gFogColor                   < string renderState="FOGCOLOR"; >;
float gFogStart                    < string renderState="FOGSTART"; >;
float gFogEnd                      < string renderState="FOGEND"; >;
 
float3 MTAApplyFog( float3 texel, float3 worldPos )
{
    if ( !gFogEnable )
        return texel;
 
    float DistanceFromCamera = distance( gCameraPosition, worldPos );
    float FogAmount = ( DistanceFromCamera - gFogStart )/( gFogEnd - gFogStart );
    texel.rgb = lerp(texel.rgb, gFogColor, saturate( FogAmount ) );
    return texel;
}

//------------------------------------------------------------------------------------------
// ComputeNormalsPS
//------------------------------------------------------------------------------------------
// The Sobel filter extracts the first order derivates of the image,
// that is, the slope. The slope in X and Y directon allows us to
// given a heightmap evaluate the normal for each pixel. This is
// the same this as ATI's NormalMapGenerator application does,
// except this is in hardware.
//
// These are the filter kernels:
//
//  SobelX       SobelY
//  1  0 -1      1  2  1
//  2  0 -2      0  0  0
//  1  0 -1     -1 -2 -1

float3 ComputeNormalsPS(sampler2D sample, float2 texCoord, float4 lightness, float tSize)
{
    float off = 1.0 / tSize;

    // Take all neighbor samples
    float4 s00 = tex2D(sample, texCoord + float2(-off, -off));
    float4 s01 = tex2D(sample, texCoord + float2( 0,   -off));
    float4 s02 = tex2D(sample, texCoord + float2( off, -off));

    float4 s10 = tex2D(sample, texCoord + float2(-off,  0));
    float4 s12 = tex2D(sample, texCoord + float2( off,  0));

    float4 s20 = tex2D(sample, texCoord + float2(-off,  off));
    float4 s21 = tex2D(sample, texCoord + float2( 0,    off));
    float4 s22 = tex2D(sample, texCoord + float2( off,  off));

    // Slope in X direction
    float4 sobelX = s00 + 2 * s10 + s20 - s02 - 2 * s12 - s22;
    // Slope in Y direction
    float4 sobelY = s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;

    // Weight the slope in all channels, we use grayscale as height
    float sx = dot(sobelX, lightness);
    float sy = dot(sobelY, lightness);

    // Compose the normal
    float3 normal = normalize(float3(sx, sy, 1));

    // Pack [-1, 1] into [0, 1]
    return float3(normal * 0.5 + 0.5);
}


//------------------------------------------------------------------------------------------
// CalculateLayeredDepth
//------------------------------------------------------------------------------------------
float depthCalcBias = 1.00004;
float depthBias = -0.00014f;
float depthPlanularBias = 1.0f;
float depthDensityStabilize = 50;

float calculateLayeredDepth(float4 ViewPos)
{
    float depth = ViewPos.z / ViewPos.w;
    
    return depth * pow(depthCalcBias, depth - (0.25 + (1 - depth * (depth * depthPlanularBias)) * depthDensityStabilize)) + depthBias;
}


int CUSTOMFLAGS <string createNormals = "yes"; string skipUnusedParameters = "yes"; >;