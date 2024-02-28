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

#ifndef INC_UNLIT_WF_UNTOON_UNIFORM
#define INC_UNLIT_WF_UNTOON_UNIFORM

    ////////////////////////////
    // Texture & Sampler
    ////////////////////////////

    // _MainTex ================================================

    DECL_MAIN_TEX2D     (_MainTex);
#ifndef _WF_MOBILE
    DECL_MAIN_TEX2D     (_BKT_BackTex);
#endif

    // _MainTex の Sampler で参照するサブテクスチャ ============

    DECL_SUB_TEX2D      (_AL_MaskTex);
    DECL_SUB_TEX2D      (_EmissionMap);
    DECL_SUB_TEX2D      (_MetallicGlossMap);
    DECL_SUB_TEX2D      (_SpecGlossMap);
    DECL_SUB_TEX2D      (_TS_MaskTex);
    DECL_SUB_TEX2D      (_TR_MaskTex);
    DECL_SUB_TEX2D      (_OVL_MaskTex);
    DECL_SUB_TEX2D      (_TL_CustomColorTex);
    DECL_SUB_TEX2D      (_CHM_3chMaskTex);
#ifndef _WF_AO_ONLY_LMAP
    DECL_SUB_TEX2D      (_OcclusionMap);
#endif
#ifndef _WF_MOBILE
    DECL_SUB_TEX2D      (_NS_2ndMaskTex);
    DECL_SUB_TEX2D      (_TS_BaseTex);
    DECL_SUB_TEX2D      (_TS_1stTex);
    DECL_SUB_TEX2D      (_TS_2ndTex);
    DECL_SUB_TEX2D      (_TS_3rdTex);
    DECL_SUB_TEX2D      (_LME_Texture);
    DECL_SUB_TEX2D      (_LME_MaskTex);
    DECL_SUB_TEX2D      (_DFD_ColorTex);
    DECL_SUB_TEX2D      (_CGR_MaskTex);
    DECL_SUB_TEX2D      (_CLC_MaskTex);
#endif

    // 独自の Sampler で参照するサブテクスチャ =================

    DECL_MAIN_TEX2D     (_BumpMap); // UVはMainTexと共通だが別のFilterを使えるようにsampler2Dで定義する
#ifndef _WF_MOBILE
    DECL_MAIN_TEX2D     (_DetailNormalMap);
#endif
    DECL_MAIN_TEXCUBE   (_MT_Cubemap);
    DECL_MAIN_TEX2D     (_OVL_OverlayTex);
    DECL_MAIN_TEX2D     (_CGR_GradMapTex);

    // vert から tex2Dlod で参照するサブテクスチャ =============

    DECL_VERT_TEX2D     (_TL_MaskTex);
#ifdef _WF_UNTOON_TESS
    DECL_VERT_TEX2D     (_TE_SmoothPowerTex);
#endif

    // GrabTexture =============================================

#ifdef _WF_PB_GRAB_TEXTURE
    DECL_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE);   // URPではGrabがサポートされていないのでここで宣言する
#endif

    // CameraDepthTexture ======================================

#if defined(_GL_DEPTH_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

    float4          _MainTex_ST;
    half4           _Color;
    half            _Cutoff;
    half            _UseVertexColor;
    half            _Z_Shift;
    uint            _FlipMirror;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_BKT_Enable);
    float4          _BKT_BackTex_ST;
    half4           _BKT_BackColor;
    uint            _BKT_UVType;
#endif

    // -------------------------

    uint            _AL_Source;
    half            _AL_Power;
    half            _AL_Fresnel;
    half            _AL_AlphaToMask;
    half            _AL_Z_Offset;
    half            _AL_InvMaskVal;
    uint            _AL_MaskMode;

    // -------------------------

    half            _GL_CastShadow;
    half            _GL_ShadowCutoff;
    half            _GL_LevelMin;
    half            _GL_LevelMax;
    half            _GL_BlendPower;
    uint            _GL_LightMode;
    half            _GL_CustomAzimuth;
    half            _GL_CustomAltitude;
    half3           _GL_CustomLitPos;
    half            _GL_DisableBasePos;
    half            _GL_NCC_Enable; // ShadowCasterで参照するため FEATURE_TGL ではなく half で定義
    half            _GL_UseDepthTex;

    // -------------------------

    #define _WF_DEFINED_LBE
    half            _LBE_Enable;
    half            _LBE_IndirectChroma;
    half            _LBE_IndirectMultiplier;
    half            _LBE_EmissionMultiplier;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CHM_Enable);
    half4           _CHM_ColorR;
    half4           _CHM_ColorG;
    half4           _CHM_ColorB;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CGR_Enable);
    half            _CGR_InvMaskVal;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CLC_Enable);
    half            _CLC_DeltaH;
    half            _CLC_DeltaS;
    half            _CLC_DeltaV;
    half            _CLC_Gamma;
    half            _CLC_Monochrome;
    half            _CLC_InvMaskVal;
#endif

    // -------------------------

    FEATURE_TGL    (_ES_Enable);
    half4           _EmissionColor;
    uint            _ES_BlendType;
    half            _ES_ChangeAlpha;

    half            _ES_ScrollEnable;
    uint            _ES_SC_Shape;
    uint            _ES_SC_DirType;
    uint            _ES_SC_UVType;
    half4           _ES_SC_Direction;
    half            _ES_SC_LevelOffset;
    half            _ES_SC_Sharpness;
    half            _ES_SC_Speed;
    half            _ES_SC_AlphaScroll;

    // -------------------------

    FEATURE_TGL    (_NM_Enable);
    half            _BumpScale;
    half            _NM_Power;
    half            _NM_InvConvex;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_NS_Enable);
    uint            _NS_UVType;
    float4          _DetailNormalMap_ST;
    half            _DetailNormalMapScale;
    half            _NS_InvMaskVal;
#endif

    // -------------------------

    FEATURE_TGL    (_MT_Enable);
    half            _MT_Metallic;
    half            _MT_ReflSmooth;
    half            _MT_BlendNormal;
    half            _MT_BlendNormal2;
    half            _MT_Brightness;
    half            _MT_Monochrome;
    half            _MT_GeomSpecAA;
    uint            _MT_MetallicMapType;
    half            _MT_Specular;
    half            _MT_SpecSmooth;
    half            _MT_InvMaskVal;
    half            _MT_InvRoughnessMaskVal;
    uint            _MT_CubemapType;
    half4           _MT_Cubemap_HDR;
    half            _MT_CubemapPower;
    half            _MT_CubemapHighCut;

    // -------------------------

#define WF_DECL_MATCAP(id)                  \
    DECL_MAIN_TEX2D(_HL_MatcapTex##id);     \
    DECL_SUB_TEX2D(_HL_MaskTex##id);        \
    FEATURE_TGL(_HL_Enable##id);            \
    uint        _HL_CapType##id;            \
    half3       _HL_MedianColor##id;        \
    half3       _HL_MatcapColor##id;        \
    half        _HL_Power##id;              \
    half        _HL_BlendNormal##id;        \
    half        _HL_BlendNormal2##id;       \
    half        _HL_Parallax##id;           \
    half        _HL_InvMaskVal##id;         \
    half        _HL_ChangeAlpha##id;        \
    half        _HL_MatcapMonochrome##id;

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
    FEATURE_TGL    (_LME_Enable);
    float4          _LME_Texture_ST;
    half4           _LME_Color;
    half3           _LME_RandColor;
    uint            _LME_UVType;
    uint            _LME_Shape;
    half            _LME_Scale;
    half            _LME_Dencity;
    half            _LME_Glitter;
    half            _LME_MinDist;
    half            _LME_MaxDist;
    half            _LME_Spot;
    half            _LME_AnimSpeed;
    half            _LME_ChangeAlpha;
    half            _LME_InvMaskVal;
#endif

    // -------------------------

    FEATURE_TGL    (_TS_Enable);
    uint            _TS_Steps;
    half3           _TS_BaseColor;
    half3           _TS_1stColor;
    half3           _TS_2ndColor;
    half3           _TS_3rdColor;
    half            _TS_Power;
    half            _TS_1stBorder;
    half            _TS_2ndBorder;
    half            _TS_3rdBorder;
    half            _TS_1stFeather;
    half            _TS_2ndFeather;
    half            _TS_3rdFeather;
    half            _TS_BlendNormal;
    half            _TS_BlendNormal2;
    half            _TS_InvMaskVal;
    half            _TS_FixContrast;
    half            _TS_MinDist;
    half            _TS_MaxDist;
    half            _TS_DisableBackLit;

    // -------------------------

    FEATURE_TGL    (_TR_Enable);
    half3           _TR_Color;
    uint            _TR_BlendType;
    half            _TR_Width;
    half            _TR_Feather;
    half            _TR_Exponent;
    half            _TR_InvMaskVal;
    half            _TR_BlendNormal;
    half            _TR_BlendNormal2;
    half            _TR_WidthTop;
    half            _TR_WidthSide;
    half            _TR_WidthBottom;
    half            _TR_DisableBackLit;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_OVL_Enable);
    uint            _OVL_UVType;
    uint            _OVL_OutUVType;
    half4           _OVL_Color;
    float4          _OVL_OverlayTex_ST;
    half2           _OVL_UVScroll;
    uint            _OVL_BlendType;
    half            _OVL_Power;
    half            _OVL_CustomParam1;
    half            _OVL_InvMaskVal;
    half            _OVL_VertColToDecal;
    half            _OVL_VertColToMask;
#endif

    // -------------------------

    half            _TL_Enable; // ShadowCasterで参照するため FEATURE_TGL ではなく half で定義
    half            _TL_LineWidth;
    uint            _TL_LineType;
    half            _TL_Z_Shift;
    half4           _TL_LineColor;
    half            _TL_BlendBase;
    half            _TL_BlendCustom;
    half            _TL_InvMaskVal;
    half            _TL_UseCutout;

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
    FEATURE_TGL    (_DFD_Enable);
    half4           _DFD_Color;
    half            _DFD_MinDist;
    half            _DFD_MaxDist;
    half            _DFD_Power;
    half            _DFD_BackShadow;
#endif

    // -------------------------

    half            _DSV_Enable; // ShadowCasterで参照するため FEATURE_TGL ではなく half で定義
    half            _DSV_Dissolve;
    half            _DSV_Invert;
    half4           _DSV_SparkColor;
    half            _DSV_SparkWidth;
    DECL_MAIN_TEX2D(_DSV_CtrlTex);
    float4          _DSV_CtrlTex_ST;
    half            _DSV_TexIsSRGB;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_TFG_Enable);
    half4           _TFG_Color;
    half            _TFG_MinDist;
    half            _TFG_MaxDist;
    half            _TFG_Exponential;
    half3           _TFG_BaseOffset;
    half3           _TFG_Scale;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CRF_Enable);
    half            _CRF_RefractiveIndex;
    half            _CRF_Distance;
    half3           _CRF_Tint;
    half            _CRF_BlendNormal;
#endif

    // -------------------------

    FEATURE_TGL    (_CGO_Enable);
    half            _CGO_Power;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CGL_Enable);
    half            _CGL_Blur;
    half            _CGL_BlurMin;
    uint            _CGL_BlurMode;
    half            _CGL_BlurRandom;
#endif

    // -------------------------

#ifdef _WF_UNTOON_TESS
    half            _TE_Factor;
    half            _TE_MinDist;
    half            _TE_MaxDist;
    half            _TE_SmoothPower;
    half            _TE_InvMaskVal;
#endif

#endif
