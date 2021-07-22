technique car_tint_window
{
    pass P0
    {
		DepthBias = -0.0000;
		AlphaBlendEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
    }
}

// fallback method
technique fallback
{
    pass P0
    {
        // do normal drawing
    }
}
