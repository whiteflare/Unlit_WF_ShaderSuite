#ifndef INC_UNLIT_WF_UNTOON_AUDIOLINK
#define INC_UNLIT_WF_UNTOON_AUDIOLINK

    ////////////////////////////
    // AudioLink.cginc より使用する定義をピックアップする
    ////////////////////////////

#define ALPASS_AUDIOLINK                uint2(0,0)  //Size: 128, 4
#define AUDIOLINK_WIDTH                 128

uniform float4               _AudioTexture_TexelSize;

uniform Texture2D<float4>   _AudioTexture;
#define AudioLinkData(xycoord) _AudioTexture[uint2(xycoord)]

float4 AudioLinkLerp(float2 xy) { return lerp( AudioLinkData(xy), AudioLinkData(xy+int2(1,0)), frac( xy.x ) ); }

bool AudioLinkIsAvailable()
{
    int width, height;
    _AudioTexture.GetDimensions(width, height);
    return width > 16;
}

#endif
