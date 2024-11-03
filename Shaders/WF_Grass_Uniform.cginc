/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2024 whiteflare.
 *
 *  This software is provided ‘as-is’, without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
 */

#ifndef INC_UNLIT_WF_GRASS_UNIFORM
#define INC_UNLIT_WF_GRASS_UNIFORM

    ////////////////////////////
    // Texture & Sampler
    ////////////////////////////

    DECL_MAIN_TEX2D     (_MainTex);
    DECL_VERT_TEX2D     (_GRS_HeightMaskTex);

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

    float4              _MainTex_ST;
    half                _Color;
    half                _Cutoff;
    half                _UseVertexColor;

    // -------------------------

    half                _GL_CastShadow;
    half                _GL_LevelMin;
    half                _GL_LevelMax;
    half                _GL_BlendPower;

    // 使わない変数は define で固定値を設定
    #define _GL_LightMode       0
    #define _GL_CustomAzimuth   0
    #define _GL_CustomAltitude  0
    #define _GL_CustomLitPos    0
    #define _GL_DisableBasePos  0
    #define _GL_LitOverride     0

    // -------------------------

    uint                _GRS_HeightType;
    uint                _GRS_HeightUVType;
    float4              _GRS_HeightMaskTex_ST;
    half                _GRS_InvMaskVal;
    half                _GRS_WorldYBase;
    half                _GRS_WorldYScale;
    half4               _GRS_UVFactor;
    half3               _GRS_ColorFactor;
    half4               _GRS_ColorBottom;
    half4               _GRS_ColorTop;
    half                _GRS_EraseSide;

    // -------------------------

    half                _LBE_Enable;
    half                _LBE_IndirectChroma;
    half                _LBE_IndirectMultiplier;
    half                _LBE_EmissionMultiplier;

    // -------------------------

    FEATURE_TGL        (_GRW_Enable);
    half                _GRW_WaveSpeed;
    half4               _GRW_WaveWidth;
    half                _GRW_WaveExponent;
    half                _GRW_WaveOffset;
    half4               _GRW_WindVector;

    // -------------------------

    FEATURE_TGL        (_AO_Enable);
    half                _AO_UseLightMap;
    half                _AO_Contrast;
    half                _AO_Brightness;

#endif
