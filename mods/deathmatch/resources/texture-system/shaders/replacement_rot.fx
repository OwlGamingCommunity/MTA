#include "tex_matrix.fx"

texture Tex0;

float gUVRotAngle = float( 0 );
float2 gUVRotCenter = float2( 0.5, 0.5 );

technique cats
{
    pass P0
    {
        // Set the texture
        Texture[0] = Tex0;       // Use custom texture

        // Set the UV thingy
        TextureTransform[0] = makeTextureTransform( gUVRotAngle, gUVRotCenter );

        // Enable UV thingy
        TextureTransformFlags[0] = Count2;
    }
}
