#ifndef INC_UNLIT_WF_UNTOON_AUDIOLINK
#define INC_UNLIT_WF_UNTOON_AUDIOLINK

    ////////////////////////////
    // AudioLink.cginc より使用する定義をピックアップする
    ////////////////////////////

    // Map of where features in AudioLink are.
    #define ALPASS_AUDIOLINK                uint2(0,0)  //Size: 128, 4

    // Some basic constants to use (Note, these should be compatible with
    #define AUDIOLINK_WIDTH                 128

    uniform float4               _AudioTexture_TexelSize;

    #ifdef SHADER_TARGET_SURFACE_ANALYSIS
        #define AUDIOLINK_STANDARD_INDEXING
    #endif

    // Mechanism to index into texture.
    #ifdef AUDIOLINK_STANDARD_INDEXING
        sampler2D _AudioTexture;
        #define AudioLinkData(xycoord) tex2Dlod(_AudioTexture, float4(uint2(xycoord) * _AudioTexture_TexelSize.xy, 0, 0))
    #else
        uniform Texture2D<float4>   _AudioTexture;
        #define AudioLinkData(xycoord) _AudioTexture[uint2(xycoord)]
    #endif

    // Mechanism to sample between two adjacent pixels and lerp between them, like "linear" supesampling
    float4 AudioLinkLerp(float2 xy) { return lerp( AudioLinkData(xy), AudioLinkData(xy+int2(1,0)), frac( xy.x ) ); }

    //Tests to see if Audio Link texture is available
    bool AudioLinkIsAvailable()
    {
        #if !defined(AUDIOLINK_STANDARD_INDEXING)
            int width, height;
            _AudioTexture.GetDimensions(width, height);
            return width > 16;
        #else
            return _AudioTexture_TexelSize.z > 16;
        #endif
    }

#endif
