/*
 *  The MIT License
 *
 *  Copyright 2018-2022 whiteflare.
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

#ifndef INC_UNLIT_WF_UNTOON_UNIFORM
#define INC_UNLIT_WF_UNTOON_UNIFORM

    ////////////////////////////
    // Texture & Sampler
    ////////////////////////////

    // _MainTex ================================================

    DECL_MAIN_TEX2D     (_MainTex);
#ifndef _WF_MOBILE
    DECL_MAIN_TEX2D     (_BK_BackTex);
#endif

    // _MainTex の Sampler で参照するサブテクスチャ ============

    DECL_SUB_TEX2D      (_AL_MaskTex);
    DECL_SUB_TEX2D      (_EmissionMap);
    DECL_SUB_TEX2D      (_MetallicGlossMap);
    DECL_SUB_TEX2D      (_TS_MaskTex);
    DECL_SUB_TEX2D      (_TR_MaskTex);
    DECL_SUB_TEX2D      (_OL_MaskTex);
    DECL_SUB_TEX2D      (_TL_CustomColorTex);
    DECL_SUB_TEX2D      (_CH_3chMaskTex);
#ifndef _WF_MOBILE
    DECL_SUB_TEX2D      (_NS_2ndMaskTex);
    DECL_SUB_TEX2D      (_SpecGlossMap);
    DECL_SUB_TEX2D      (_TS_BaseTex);
    DECL_SUB_TEX2D      (_TS_1stTex);
    DECL_SUB_TEX2D      (_TS_2ndTex);
    DECL_SUB_TEX2D      (_TS_3rdTex);
    DECL_SUB_TEX2D      (_OcclusionMap);
    DECL_SUB_TEX2D      (_LM_Texture);
    DECL_SUB_TEX2D      (_LM_MaskTex);
#endif
#ifdef _WF_LEGACY_TL_MASK    // マスクをfragmentでアルファに反映する場合
    DECL_SUB_TEX2D      (_TL_MaskTex);
#endif

    // 独自の Sampler で参照するサブテクスチャ =================

    DECL_MAIN_TEX2D     (_BumpMap); // UVはMainTexと共通だが別のFilterを使えるようにsampler2Dで定義する
#ifndef _WF_MOBILE
    DECL_MAIN_TEX2D     (_DetailNormalMap);
#endif
    DECL_MAIN_TEXCUBE   (_MT_Cubemap);
    DECL_MAIN_TEX2D     (_OL_OverlayTex);

    // vert から tex2Dlod で参照するサブテクスチャ =============

#ifndef _WF_LEGACY_TL_MASK   // マスクをシフト時に太さに反映する場合
    DECL_VERT_TEX2D     (_TL_MaskTex);
#endif
#ifdef _WF_UNTOON_TESS
    DECL_VERT_TEX2D     (_TE_SmoothPowerTex);
#endif

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

    float4          _MainTex_ST;
    float4          _Color;
    float           _Cutoff;
    float           _UseVertexColor;
    float           _Z_Shift;
    uint            _FlipMirror;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_BK_Enable);
    float4          _BK_BackTex_ST;
    float4          _BK_BackColor;
#endif

    // -------------------------

    uint            _AL_Source;
    float           _AL_Power;
    float           _AL_Fresnel;
    float           _AL_AlphaToMask;
    float           _AL_Z_Offset;
    float           _AL_InvMaskVal;

    // -------------------------

    float           _GL_CastShadow;
    float           _GL_LevelMin;
    float           _GL_LevelMax;
    float           _GL_BlendPower;
    uint            _GL_LightMode;
    float           _GL_CustomAzimuth;
    float           _GL_CustomAltitude;
    float3          _GL_CustomLitPos;
    float           _GL_DisableBackLit;
    float           _GL_DisableBasePos;

    // -------------------------

    float           _GI_Enable;
    float           _GI_IndirectChroma;
    float           _GI_IndirectMultiplier;
    float           _GI_EmissionMultiplier;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_CH_Enable);
    float4          _CH_ColorR;
    float4          _CH_ColorG;
    float4          _CH_ColorB;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_CL_Enable);
    float           _CL_DeltaH;
    float           _CL_DeltaS;
    float           _CL_DeltaV;
    float           _CL_Monochrome;
#endif

    // -------------------------

    FEATURE_TGL     (_ES_Enable);
    float4          _EmissionColor;
    uint            _ES_BlendType;
    uint            _ES_Shape;
    uint            _ES_DirType;
    float4          _ES_Direction;
    float           _ES_LevelOffset;
    float           _ES_Sharpness;
    float           _ES_Speed;
    float           _ES_AlphaScroll;

    // -------------------------

    FEATURE_TGL     (_NM_Enable);
    float           _BumpScale;
    float           _NM_Power;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_NS_Enable);
    uint            _NS_UVType;
    float4          _DetailNormalMap_ST;
    float           _DetailNormalMapScale;
    float           _NS_InvMaskVal;
#endif

    // -------------------------

    FEATURE_TGL     (_MT_Enable);
    float           _MT_Metallic;
    float           _MT_ReflSmooth;
    float           _MT_BlendNormal;
    float           _MT_BlendNormal2;
    float           _MT_Brightness;
    float           _MT_Monochrome;
    float           _MT_GeomSpecAA;
    uint            _MT_MetallicMapType;
    float           _MT_Specular;
    float           _MT_SpecSmooth;
    float           _MT_InvMaskVal;
#ifndef _WF_MOBILE
    float           _MT_InvRoughnessMaskVal;
#endif
    uint            _MT_CubemapType;
    float4          _MT_Cubemap_HDR;
    float           _MT_CubemapPower;
    float           _MT_CubemapHighCut;

    // -------------------------

#define WF_DECL_MATCAP(id)                  \
    DECL_MAIN_TEX2D(_HL_MatcapTex##id);     \
    DECL_SUB_TEX2D(_HL_MaskTex##id);        \
    FEATURE_TGL (_HL_Enable##id);           \
    uint        _HL_CapType##id;            \
    float3      _HL_MedianColor##id;        \
    float3      _HL_MatcapColor##id;        \
    float       _HL_Power##id;              \
    float       _HL_BlendNormal##id;        \
    float       _HL_BlendNormal2##id;       \
    float       _HL_Parallax##id;           \
    float       _HL_InvMaskVal##id;         \
    float       _HL_ChangeAlpha##id;        \
    float       _HL_MatcapMonochrome##id;

#ifdef UNITY_OLD_PREPROCESSOR
    WF_DECL_MATCAP(##)
#else
    WF_DECL_MATCAP()
#endif
#ifndef _WF_MOBILE
    WF_DECL_MATCAP(_1)
#endif

#ifdef _WF_UNTOON_POWERCAP
    WF_DECL_MATCAP(_2)
    WF_DECL_MATCAP(_3)
    WF_DECL_MATCAP(_4)
    WF_DECL_MATCAP(_5)
    WF_DECL_MATCAP(_6)
    WF_DECL_MATCAP(_7)
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_LM_Enable);
    float4          _LM_Texture_ST;
    float4          _LM_Color;
    float3          _LM_RandColor;
    uint            _LM_UVType;
    uint            _LM_Shape;
    float           _LM_Scale;
    float           _LM_Dencity;
    float           _LM_Glitter;
    float           _LM_MinDist;
    float           _LM_MaxDist;
    float           _LM_Spot;
    float           _LM_AnimSpeed;
    float           _LM_ChangeAlpha;
    float           _LM_InvMaskVal;
#endif

    // -------------------------

    FEATURE_TGL     (_TS_Enable);
    uint            _TS_Steps;
    float3          _TS_BaseColor;
    float3          _TS_1stColor;
    float3          _TS_2ndColor;
    float3          _TS_3rdColor;
    float           _TS_Power;
    float           _TS_1stBorder;
    float           _TS_2ndBorder;
    float           _TS_3rdBorder;
    float           _TS_Feather;
    float           _TS_BlendNormal;
    float           _TS_BlendNormal2;
    float           _TS_InvMaskVal;
    float           _TS_FixContrast;

    // -------------------------

    FEATURE_TGL     (_TR_Enable);
    float3          _TR_Color;
    uint            _TR_BlendType;
    float           _TR_Power;
    float           _TR_Feather;
    float           _TR_InvMaskVal;
    float           _TR_BlendNormal;
    float           _TR_BlendNormal2;
    float           _TR_PowerTop;
    float           _TR_PowerSide;
    float           _TR_PowerBottom;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_OL_Enable);
    uint            _OL_UVType;
    float4          _OL_Color;
    float4          _OL_OverlayTex_ST;
    float2          _OL_UVScroll;
    uint            _OL_BlendType;
    float           _OL_Power;
    float           _OL_CustomParam1;
    float           _OL_InvMaskVal;
    float           _OL_VertColToDecal;
    float           _OL_VertColToMask;
#endif

    // -------------------------

    FEATURE_TGL     (_TL_Enable);
    float           _TL_LineWidth;
    uint            _TL_LineType;
    float           _TL_Z_Shift;
    float4          _TL_LineColor;
    float           _TL_BlendBase;
    float           _TL_BlendCustom;
    float           _TL_InvMaskVal;
    float           _TL_UseCutout;

    // -------------------------

    FEATURE_TGL     (_AO_Enable);
    uint            _AO_UVType;
    float           _AO_UseLightMap;
    float           _AO_UseGreenMap;
    float           _AO_Contrast;
    float           _AO_Brightness;
    float4          _AO_TintColor;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_DF_Enable);
    float4          _DF_Color;
    float           _DF_MinDist;
    float           _DF_MaxDist;
    float           _DF_Power;
    float           _DF_BackShadow;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_FG_Enable);
    float4          _FG_Color;
    float           _FG_MinDist;
    float           _FG_MaxDist;
    float           _FG_Exponential;
    float3          _FG_BaseOffset;
    float3          _FG_Scale;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL     (_RF_Enable);
    float           _RF_RefractiveIndex;
    float           _RF_Distance;
    float3          _RF_Tint;
    float           _RF_BlendNormal;
    float           _RF_BlendNormal2;
#endif

    // -------------------------

#ifdef _WF_UNTOON_TESS
    float           _TE_Factor;
    float           _TE_MinDist;
    float           _TE_MaxDist;
    float           _TE_SmoothPower;
    float           _TE_InvMaskVal;
#endif

#endif
