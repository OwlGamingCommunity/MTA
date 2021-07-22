//
// mta-helper.fx
//
// File version: 1.1.5-custom. Modified to fit the needs of the from-scratch carshader
// Date updated: 2016-09-30
//
// Big file of doom containg most of the stuff you need to get shaders working with MTA
// Added light states to support pointlights
//

//
// This file has 4 sections:
//      1. Variables
//      2. Renders states (parital - includes only those that are used the most)
//      3. Helper functions
//      4. Normal generation
//



//####################################################################################################################
//####################################################################################################################
//
// Section #1 : Variables
//
//####################################################################################################################
//####################################################################################################################

//---------------------------------------------------------------------
// These parameters are set by MTA whenever a shader is drawn
//---------------------------------------------------------------------

//
// Matrices
//
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;
float4x4 gWorldView : WORLDVIEW;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 gViewProjection : VIEWPROJECTION;
float4x4 gViewInverse : VIEWINVERSE;
float4x4 gWorldInverseTranspose : WORLDINVERSETRANSPOSE;
float4x4 gViewInverseTranspose : VIEWINVERSETRANSPOSE;

//
// Camera
//
float3 gCameraPosition : CAMERAPOSITION;
float3 gCameraDirection : CAMERADIRECTION;

//
// Seconds counter
//
float gTime : TIME;

//
// Strongest light influence
//
float4 gLightAmbient : LIGHTAMBIENT;
float4 gLightDiffuse : LIGHTDIFFUSE;
float4 gLightSpecular : LIGHTSPECULAR;
float3 gLightDirection : LIGHTDIRECTION;



//####################################################################################################################
//####################################################################################################################
//
// Section #2 : Renders states
//
//####################################################################################################################
//####################################################################################################################

//---------------------------------------------------------------------
// The parameters below mirror the contents of the D3D registers.
// They are only relevant when using engineApplyShaderToWorldTexture.
//---------------------------------------------------------------------

//------------------------------------------------------------------------------------------
// renderState (partial) - String value should be one of D3DRENDERSTATETYPE without the D3DRS_  http://msdn.microsoft.com/en-us/library/bb172599%28v=vs.85%29.aspx
//------------------------------------------------------------------------------------------

int gLighting                      < string renderState="LIGHTING"; >;                        //  = 137,

float4 gGlobalAmbient              < string renderState="AMBIENT"; >;                    //  = 139,

int gDiffuseMaterialSource         < string renderState="DIFFUSEMATERIALSOURCE"; >;           //  = 145,
int gSpecularMaterialSource        < string renderState="SPECULARMATERIALSOURCE"; >;          //  = 146,
int gAmbientMaterialSource         < string renderState="AMBIENTMATERIALSOURCE"; >;           //  = 147,
int gEmissiveMaterialSource        < string renderState="EMISSIVEMATERIALSOURCE"; >;          //  = 148,


//------------------------------------------------------------------------------------------
// materialState - String value should be one of the members from D3DMATERIAL9  http://msdn.microsoft.com/en-us/library/bb172571%28v=VS.85%29.aspx
//------------------------------------------------------------------------------------------

float4 gMaterialAmbient     < string materialState="Ambient"; >;
float4 gMaterialDiffuse     < string materialState="Diffuse"; >;
float4 gMaterialSpecular    < string materialState="Specular"; >;
float4 gMaterialEmissive    < string materialState="Emissive"; >;
float gMaterialSpecPower    < string materialState="Power"; >;


//------------------------------------------------------------------------------------------
// textureState (partial) - String value should be a texture number followed by 'Texture'
//------------------------------------------------------------------------------------------

texture gTexture0           < string textureState="0,Texture"; >;
texture gTexture1           < string textureState="1,Texture"; >;
texture gTexture2           < string textureState="2,Texture"; >;
texture gTexture3           < string textureState="3,Texture"; >;


//------------------------------------------------------------------------------------------
// vertexDeclState  (partial)
//------------------------------------------------------------------------------------------

int gDeclNormal             < string vertexDeclState="Normal"; >;       // Set to 1 if vertex stream includes normals



//------------------------------------------------------------------------------------------
// lightEnableState - String value should be a light number followed by 'Enable'
//------------------------------------------------------------------------------------------

int gLight0Enable           < string lightEnableState="0,Enable"; >;
int gLight1Enable           < string lightEnableState="1,Enable"; >;
int gLight2Enable           < string lightEnableState="2,Enable"; >;
int gLight3Enable           < string lightEnableState="3,Enable"; >;
int gLight4Enable           < string lightEnableState="4,Enable"; >;

//------------------------------------------------------------------------------------------
// lightState - String value should be a light number followed by one of the members from D3DLIGHT9  http://msdn.microsoft.com/en-us/library/bb172566%28VS.85%29.aspx
//------------------------------------------------------------------------------------------

int gLight0Type                 < string lightState="0,Type"; >;
float4 gLight0Diffuse           < string lightState="0,Diffuse"; >;
float4 gLight0Specular          < string lightState="0,Specular"; >;
float4 gLight0Ambient           < string lightState="0,Ambient"; >;
float3 gLight0Position          < string lightState="0,Position"; >;
float3 gLight0Direction         < string lightState="0,Direction"; >;

int gLight1Type                 < string lightState="1,Type"; >;
float4 gLight1Diffuse           < string lightState="1,Diffuse"; >;
float4 gLight1Specular          < string lightState="1,Specular"; >;
float4 gLight1Ambient           < string lightState="1,Ambient"; >;
float3 gLight1Position          < string lightState="1,Position"; >;
float3 gLight1Direction         < string lightState="1,Direction"; >;

int gLight2Type                 < string lightState="2,Type"; >;
float4 gLight2Diffuse           < string lightState="2,Diffuse"; >;
float4 gLight2Specular          < string lightState="2,Specular"; >;
float4 gLight2Ambient           < string lightState="2,Ambient"; >;
float3 gLight2Position          < string lightState="2,Position"; >;
float3 gLight2Direction         < string lightState="2,Direction"; >;

int gLight3Type                 < string lightState="3,Type"; >;
float4 gLight3Diffuse           < string lightState="3,Diffuse"; >;
float4 gLight3Specular          < string lightState="3,Specular"; >;
float4 gLight3Ambient           < string lightState="3,Ambient"; >;
float3 gLight3Position          < string lightState="3,Position"; >;
float3 gLight3Direction         < string lightState="3,Direction"; >;

int gLight4Type                 < string lightState="4,Type"; >;
float4 gLight4Diffuse           < string lightState="4,Diffuse"; >;
float4 gLight4Specular          < string lightState="4,Specular"; >;
float4 gLight4Ambient           < string lightState="4,Ambient"; >;
float3 gLight4Position          < string lightState="4,Position"; >;
float3 gLight4Direction         < string lightState="4,Direction"; >;

//####################################################################################################################
//####################################################################################################################
//
// Section #3 : Helper functions
//
//####################################################################################################################
//####################################################################################################################

//------------------------------------------------------------------------------------------
// MTAUnlerp
// - Find a the relative position between 2 values
//------------------------------------------------------------------------------------------
float MTAUnlerp( float from, float to, float pos )
{
    if ( from == to )
        return 1.0;
    else
        return ( pos - from ) / ( to - from );
}


//------------------------------------------------------------------------------------------
// MTACalcScreenPosition
// - Transform vertex position for the camera
//------------------------------------------------------------------------------------------
float4 MTACalcScreenPosition( float3 InPosition )
{
    float4 posWorld = mul(float4(InPosition,1), gWorld);
    float4 posWorldView = mul(posWorld, gView);
    return mul(posWorldView, gProjection);
}

//------------------------------------------------------------------------------------------
// MTACalcWorldPosition
// - Transform position by current world matix
//------------------------------------------------------------------------------------------
float3 MTACalcWorldPosition( float3 InPosition )
{
    return mul(float4(InPosition,1), gWorld).xyz;
}

//------------------------------------------------------------------------------------------
// MTACalcWorldNormal
// - Rotate normal by current world matix
//------------------------------------------------------------------------------------------
float3 MTACalcWorldNormal( float3 InNormal )
{
    return mul(InNormal, (float3x3)gWorld);
}

//------------------------------------------------------------------------------------------
// MTACalculateVehicleSpecular
// - Calculate GTA specular lighting for vehicles
//------------------------------------------------------------------------------------------
float4 MTACalculateVehicleSpecular(float3 SurfNormal )
{
    // Using Blinn half angle modification for performance over correctness
    SurfNormal = normalize(SurfNormal);
    float3 halfAngle = normalize(-gCameraDirection - gLightDirection);
    float r = saturate(dot(halfAngle, SurfNormal));
    float spec = pow(r, gMaterialSpecPower);
	return gMaterialSpecular * spec;
}

//------------------------------------------------------------------------------------------
// MTACalcGTABuildingDiffuse
// - Calculate GTA lighting for buildings
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
// MTACalcGTAVehicleDiffuse
// - Calculate GTA lighting for vehicles
//------------------------------------------------------------------------------------------
float4 MTACalcGTAVehicleDiffuse( float3 WorldNormal, float4 InDiffuse )
{
    // Calculate diffuse color by doing what D3D usually does
    float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
    float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
    float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;

    float4 TotalAmbient = ambient * ( gGlobalAmbient + gLightAmbient );

    // Add the strongest light
    float DirectionFactor = max(0,dot(WorldNormal, -gLightDirection ));
    float4 TotalDiffuse = ( diffuse * gLightDiffuse * DirectionFactor );

    float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
    OutDiffuse.a *= diffuse.a;

    return OutDiffuse;
}

//------------------------------------------------------------------------------------------
// MTACalcGTACompleteDiffuse
// - Calculate GTA lighting including pointlights for vehicles (all 4 lights)
//------------------------------------------------------------------------------------------
float4 MTACalcGTACompleteDiffuse( float3 WorldNormal, float4 InDiffuse )
{
    // Calculate diffuse color by doing what D3D usually does
    float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
    float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
    float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;

    float4 TotalAmbient = ambient * ( gGlobalAmbient + gLightAmbient );

    // Add all the 4 pointlights
    float DirectionFactor=0;
    float4 TotalDiffuse=0;
	
    if (gLight1Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight1Direction ));
    TotalDiffuse += ( gLight1Diffuse * DirectionFactor );
                     }
    if (gLight2Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight2Direction ));
    TotalDiffuse += ( gLight2Diffuse * DirectionFactor );
                     }
    if (gLight3Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight3Direction ));
    TotalDiffuse += ( gLight3Diffuse * DirectionFactor );
                     }
    if (gLight4Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight4Direction ));
    TotalDiffuse += ( gLight4Diffuse * DirectionFactor );
                     }	

    TotalDiffuse *= diffuse;

    float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
    OutDiffuse.a *= diffuse.a;

    return OutDiffuse;
}

//------------------------------------------------------------------------------------------
// MTACalcGTADynamicDiffuse
// - Calculate GTA lighting for vehicles (all 4 lights)
//------------------------------------------------------------------------------------------
float4 MTACalcGTADynamicDiffuse( float3 WorldNormal )
{
    // Add all the 4 pointlights
    float DirectionFactor=0;
    float4 TotalDiffuse=0;

    if (gLight1Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight1Direction ));
    TotalDiffuse += ( gLight1Diffuse * DirectionFactor );
                     }
    if (gLight2Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight2Direction ));
    TotalDiffuse += ( gLight2Diffuse * DirectionFactor );
                     }
    if (gLight3Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight3Direction ));
    TotalDiffuse += ( gLight3Diffuse * DirectionFactor );
                     }
    if (gLight4Enable) {
    DirectionFactor = max(0,dot(WorldNormal, -gLight4Direction ));
    TotalDiffuse += ( gLight4Diffuse * DirectionFactor );
                     }	

    float4 OutDiffuse = saturate(TotalDiffuse);

    return OutDiffuse;
}

//------------------------------------------------------------------------------------------
// MTACalculateCameraDirection
// - Get camera direction to a world point
//------------------------------------------------------------------------------------------
float3 MTACalculateCameraDirection( float3 CamPos, float3 InWorldPos )
{
    return normalize( InWorldPos - CamPos );
}

//------------------------------------------------------------------------------------------
// CalcCameraDistance
// - Get camera distance from a world point
//------------------------------------------------------------------------------------------
float MTACalcCameraDistance( float3 CamPos, float3 InWorldPos )
{
    return distance( InWorldPos, CamPos );
}

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



//####################################################################################################################
//####################################################################################################################
//
// Section #4 : Normal generation
//
//####################################################################################################################
//####################################################################################################################

//
// Declare '#define GENERATE_NORMALS' before this file is included to tell MTA to generate vertex normals if required
//

//---------------------------------------------------------------------
// Flags for MTA to do something about
//---------------------------------------------------------------------
int CUSTOMFLAGS
<
#ifdef GENERATE_NORMALS
    string createNormals = "yes";           // Some models do not have normals by default. Setting this to 'yes' will add them to the VertexShaderInput as NORMAL0
#endif
    string skipUnusedParameters = "yes";    // This will make the shader a bit faster
>;


//------------------------------------------------------------------------------------------
// MTAFixUpNormal
// - Make sure the normal is valid
//------------------------------------------------------------------------------------------
void MTAFixUpNormal( in out float3 OutNormal )
{
    // Incase we have no normal inputted
    if ( OutNormal.x == 0 && OutNormal.y == 0 && OutNormal.z == 0 )
        OutNormal = float3(0,0,1);   // Default to up
}