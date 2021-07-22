float4 createLight(float3 Normal, float3 WorldPos, int LightType, float3 LightPos, float3 LightDir, float4 LightDiffuse, float Attenuation, float LightPhi, float LightTheta, float LightFalloff, bool LightNormalShadow )
{	
    // Compute the distance attenuation factor:
	float fDistance = distance( LightPos, WorldPos );

    // Compute the attenuation:
    float fAttenuation = 1 - saturate(fDistance / Attenuation);
    fAttenuation = pow( fAttenuation, 2); 	
	
    // Compute the direction to the light:
    float3 vLight = normalize( LightPos - WorldPos );

    // Determine the angle between the current sample
    // and the light's direction:
    float angle = acos( dot ( -vLight, normalize( LightDir )));
	
    // Compute the spot attenuation factor:
    float fSpotAtten = 0.0f;
    if ( angle > LightPhi ) fSpotAtten = 0.0f;
    else if ( angle < LightTheta) fSpotAtten = 1.0f;
    else fSpotAtten = pow( smoothstep( LightPhi, LightTheta, angle ), LightFalloff );
	 
    // ..If it's going to be a spotlight:	 
    if (LightType==2) fAttenuation *= fSpotAtten;

    // Determine the final colour:
    float NdotL = saturate( max( 0.0f, dot( Normal , vLight ) ));

    // The final attenuation is the product of both types 
    // previously evaluated:
	 
    if (LightNormalShadow) return  NdotL * fAttenuation * LightDiffuse;
    else return fAttenuation * LightDiffuse ;
}