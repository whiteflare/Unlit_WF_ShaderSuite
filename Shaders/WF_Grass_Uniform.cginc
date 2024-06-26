﻿/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 *  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
