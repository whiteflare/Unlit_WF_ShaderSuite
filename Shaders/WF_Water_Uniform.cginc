/*
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

    DECL_MAIN_TEX2D     (_WAR_CookieTex);

    DECL_MAIN_TEXCUBE   (_WAM_Cubemap);

#ifdef _WF_PB_GRAB_TEXTURE
    DECL_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE);   // URPではGrabがサポートされていないのでここで宣言する
#endif

#if defined(_CRF_DEPTH_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
    UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

    float4          _MainTex_ST;
    half4           _Color;
    half4           _Color2;
    half            _ShadowPower;
    half            _Cutoff;

    half            _WaterLevel;
    half            _WaterTransparency;
    half            _HideCausticsAbove;

    // -------------------------

    FEATURE_TGL    (_WAV_Enable_1);
    uint            _WAV_UVType_1;
    half4           _WAV_Direction_1;
    half            _WAV_Speed_1;
    float4          _WAV_NormalMap_1_ST;
    half            _WAV_NormalScale_1;
    float4          _WAV_HeightMap_1_ST;
    float4          _WAV_CausticsTex_1_ST;

    FEATURE_TGL    (_WAV_Enable_2);
    uint            _WAV_UVType_2;
    half4           _WAV_Direction_2;
    half            _WAV_Speed_2;
    float4          _WAV_NormalMap_2_ST;
    half            _WAV_NormalScale_2;
    float4          _WAV_HeightMap_2_ST;
    float4          _WAV_CausticsTex_2_ST;

    FEATURE_TGL    (_WAV_Enable_3);
    uint            _WAV_UVType_3;
    half4           _WAV_Direction_3;
    half            _WAV_Speed_3;
    float4          _WAV_NormalMap_3_ST;
    half            _WAV_NormalScale_3;
    float4          _WAV_HeightMap_3_ST;
    float4          _WAV_CausticsTex_3_ST;

    // -------------------------

    uint            _AL_Source;
    half            _AL_Power;
    half            _AL_Fresnel;
    half            _AL_Z_Offset;
    half            _AL_InvMaskVal;
    uint            _AL_MaskMode;

    // -------------------------

    FEATURE_TGL    (_WAS_Enable);
    half            _WAS_Power;
    half4           _WAS_Color;
    half            _WAS_Smooth;
    half            _WAS_Power2;
    half4           _WAS_Color2;
    half            _WAS_Smooth2;

    // -------------------------

    FEATURE_TGL    (_WAM_Enable);
    half4           _WAM_Cubemap_HDR;
    half            _WAM_Power;
    half            _WAM_Smooth;
    half            _WAM_Bright;
    half            _WAM_CubemapType;
    half            _WAM_CubemapHighCut;

    // -------------------------

    uint            _GL_LightMode;
    half            _GL_CustomAzimuth;
    half            _GL_CustomAltitude;
    half3           _GL_CustomLitPos;

    // 使わない変数は define で固定値を設定
    #define _GL_CastShadow      0
    #define _GL_LevelMin        0
    #define _GL_LevelMax        1
    #define _GL_BlendPower      1
    #define _GL_DisableBasePos  0

    // -------------------------

    FEATURE_TGL    (_AO_Enable);
    uint            _AO_UVType;
    half            _AO_UseLightMap;
    half            _AO_UseGreenMap;
    half            _AO_Contrast;
    half            _AO_Brightness;
    half4           _AO_TintColor;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CRF_Enable);
    half            _CRF_RefractiveIndex;
    half            _CRF_Distance;
    half3           _CRF_Tint;
    half            _CRF_BlendNormal;
    half            _CRF_UseDepthTex;
#endif

    // -------------------------

    FEATURE_TGL    (_WAD_Enable);
    half4           _WAD_Color;
    half            _WAD_MinDist;
    half            _WAD_MaxDist;
    half            _WAD_Power;
    half            _WAD_BackShadow;

    // -------------------------

    FEATURE_TGL    (_WAR_Enable);
    half            _WAR_Power;
    half            _WAR_Azimuth;
    half            _WAR_Altitude;
    half3           _WAR_BasePosOffset;
    half            _WAR_CullBack;
    half            _WAR_Size;
    half            _WAR_Feather;
    half            _WAR_BlendNormal;
    half            _WAR_MinDist;
    half            _WAR_MaxDist;

#endif
