/*
 *  The MIT License
 *
 *  Copyright 2018-2023 whiteflare.
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

#ifndef INC_UNLIT_WF_WATER_UNIFORM
#define INC_UNLIT_WF_WATER_UNIFORM

    ////////////////////////////
    // Texture & Sampler
    ////////////////////////////

    DECL_MAIN_TEX2D     (_MainTex);

    DECL_SUB_TEX2D      (_AL_MaskTex);

    DECL_MAIN_TEX2D     (_WAV_NormalMap_1);
    DECL_MAIN_TEX2D     (_WAV_HeightMap_1);
    DECL_MAIN_TEX2D     (_WAV_CausticsTex_1);

    DECL_MAIN_TEX2D     (_WAV_NormalMap_2);
    DECL_MAIN_TEX2D     (_WAV_HeightMap_2);
    DECL_MAIN_TEX2D     (_WAV_CausticsTex_2);

    DECL_MAIN_TEX2D     (_WAV_NormalMap_3);
    DECL_MAIN_TEX2D     (_WAV_HeightMap_3);
    DECL_MAIN_TEX2D     (_WAV_CausticsTex_3);

    DECL_MAIN_TEXCUBE   (_WAM_Cubemap);

#ifdef _WF_PB_GRAB_TEXTURE
    DECL_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE);   // URPではGrabがサポートされていないのでここで宣言する
#endif

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

    float4          _MainTex_ST;
    float4          _Color;
    float4          _Color2;
    float           _ShadowPower;
    float           _Cutoff;

    float           _WaterLevel;
    float           _WaterTransparency;
    float           _HideCausticsAbove;

    // -------------------------

    FEATURE_TGL    (_WAV_Enable_1);
    uint            _WAV_UVType_1;
    float4          _WAV_Direction_1;
    float           _WAV_Speed_1;
    float4          _WAV_NormalMap_1_ST;
    float           _WAV_NormalScale_1;
    float4          _WAV_HeightMap_1_ST;
    float4          _WAV_CausticsTex_1_ST;

    FEATURE_TGL    (_WAV_Enable_2);
    uint            _WAV_UVType_2;
    float4          _WAV_Direction_2;
    float           _WAV_Speed_2;
    float4          _WAV_NormalMap_2_ST;
    float           _WAV_NormalScale_2;
    float4          _WAV_HeightMap_2_ST;
    float4          _WAV_CausticsTex_2_ST;

    FEATURE_TGL    (_WAV_Enable_3);
    uint            _WAV_UVType_3;
    float4          _WAV_Direction_3;
    float           _WAV_Speed_3;
    float4          _WAV_NormalMap_3_ST;
    float           _WAV_NormalScale_3;
    float4          _WAV_HeightMap_3_ST;
    float4          _WAV_CausticsTex_3_ST;

    // -------------------------

    uint            _AL_Source;
    float           _AL_Power;
    float           _AL_Fresnel;
    float           _AL_AlphaToMask;
    float           _AL_Z_Offset;
    float           _AL_InvMaskVal;

    // -------------------------

    FEATURE_TGL    (_WAS_Enable);
    float           _WAS_Power;
    float4          _WAS_Color;
    float           _WAS_Smooth;
    float           _WAS_Power2;
    float4          _WAS_Color2;
    float           _WAS_Smooth2;

    // -------------------------

    FEATURE_TGL    (_WAM_Enable);
    float4          _WAM_Cubemap_HDR;
    float           _WAM_Power;
    float           _WAM_Smooth;
    float           _WAM_Bright;
    float           _WAM_CubemapType;
    float           _WAM_CubemapHighCut;

    // -------------------------

    uint            _GL_LightMode;
    float           _GL_CustomAzimuth;
    float           _GL_CustomAltitude;
    float3          _GL_CustomLitPos;

    // 使わない変数は define で固定値を設定
    #define _GL_CastShadow      0
    #define _GL_LevelMin        0
    #define _GL_LevelMax        1
    #define _GL_BlendPower      1
    #define _GL_DisableBackLit  0
    #define _GL_DisableBasePos  0

    // -------------------------

    FEATURE_TGL    (_AO_Enable);
    uint            _AO_UVType;
    float           _AO_UseLightMap;
    float           _AO_UseGreenMap;
    float           _AO_Contrast;
    float           _AO_Brightness;
    float4          _AO_TintColor;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CRF_Enable);
    float           _CRF_RefractiveIndex;
    float           _CRF_Distance;
    float3          _CRF_Tint;
    float           _CRF_BlendNormal;
#endif

    // -------------------------

    FEATURE_TGL    (_WAD_Enable);
    float4          _WAD_Color;
    float           _WAD_MinDist;
    float           _WAD_MaxDist;
    float           _WAD_Power;
    float           _WAD_BackShadow;

    // -------------------------

    FEATURE_TGL    (_WAR_Enable);
    float           _WAR_Power;
    float           _WAR_Azimuth;
    float           _WAR_Altitude;
    float3          _WAR_BasePosOffset;
    float           _WAR_CullBack;
    float           _WAR_Size;
    float           _WAR_Feather;
    float           _WAR_BlendNormal;
    float           _WAR_MinDist;
    float           _WAR_MaxDist;

#endif
