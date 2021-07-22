float3x3 makeTranslationMatrix ( float2 pos )
{
    return float3x3(
                    1, 0, 0,
                    0, 1, 0,
                    pos.x, pos.y, 1
                    );
}

float3x3 makeRotationMatrix ( float angle )
{
    float s = sin(angle);
    float c = cos(angle);
    return float3x3(
                    c, s, 0,
                    -s, c, 0,
                    0, 0, 1
                    );
}

float3x3 makeTextureTransform ( float rotAngle, float2 rotCenter )
{
    float3x3 matToRotCen = makeTranslationMatrix( -rotCenter );
    float3x3 matRot = makeRotationMatrix( rotAngle );
    float3x3 matFromRotCen = makeTranslationMatrix( rotCenter );

    float3x3 result = mul(mul(matToRotCen, matRot), matFromRotCen);
    return result;
}
