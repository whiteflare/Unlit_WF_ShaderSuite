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
    DECL_SUB_TEX2D      (_SpecGlossMap);
    DECL_SUB_TEX2D      (_TS_BaseTex);
    DECL_SUB_TEX2D      (_TS_1stTex);
    DECL_SUB_TEX2D      (_TS_2ndTex);
    DECL_SUB_TEX2D      (_TS_3rdTex);
    DECL_SUB_TEX2D      (_LME_Texture);
    DECL_SUB_TEX2D      (_LME_MaskTex);
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
    DECL_MAIN_TEX2D     (_OVL_OverlayTex);

    // vert から tex2Dlod で参照するサブテクスチャ =============

#ifndef _WF_LEGACY_TL_MASK   // マスクをシフト時に太さに反映する場合
    DECL_VERT_TEX2D     (_TL_MaskTex);
#endif
#ifdef _WF_UNTOON_TESS
    DECL_VERT_TEX2D     (_TE_SmoothPowerTex);
#endif

    // GrabTexture =============================================

#ifdef _WF_PB_GRAB_TEXTURE
    DECL_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE);   // URPではGrabがサポートされていないのでここで宣言する
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
    FEATURE_TGL    (_BKT_Enable);
    float4          _BKT_BackTex_ST;
    float4          _BKT_BackColor;
    uint            _BKT_UVType;
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

    float           _LBE_Enable;
    float           _LBE_IndirectChroma;
    float           _LBE_IndirectMultiplier;
    float           _LBE_EmissionMultiplier;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CHM_Enable);
    float4          _CHM_ColorR;
    float4          _CHM_ColorG;
    float4          _CHM_ColorB;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CLC_Enable);
    float           _CLC_DeltaH;
    float           _CLC_DeltaS;
    float           _CLC_DeltaV;
    float           _CLC_Monochrome;
#endif

    // -------------------------

    FEATURE_TGL    (_ES_Enable);
    float4          _EmissionColor;
    uint            _ES_BlendType;

    float           _ES_ScrollEnable;
    uint            _ES_SC_Shape;
    uint            _ES_SC_DirType;
    uint            _ES_SC_UVType;
    float4          _ES_SC_Direction;
    float           _ES_SC_LevelOffset;
    float           _ES_SC_Sharpness;
    float           _ES_SC_Speed;
    float           _ES_SC_AlphaScroll;

    // -------------------------

    FEATURE_TGL    (_NM_Enable);
    float           _BumpScale;
    float           _NM_Power;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_NS_Enable);
    uint            _NS_UVType;
    float4          _DetailNormalMap_ST;
    float           _DetailNormalMapScale;
    float           _NS_InvMaskVal;
#endif

    // -------------------------

    FEATURE_TGL    (_MT_Enable);
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
    FEATURE_TGL(_HL_Enable##id);            \
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
    FEATURE_TGL    (_LME_Enable);
    float4          _LME_Texture_ST;
    float4          _LME_Color;
    float3          _LME_RandColor;
    uint            _LME_UVType;
    uint            _LME_Shape;
    float           _LME_Scale;
    float           _LME_Dencity;
    float           _LME_Glitter;
    float           _LME_MinDist;
    float           _LME_MaxDist;
    float           _LME_Spot;
    float           _LME_AnimSpeed;
    float           _LME_ChangeAlpha;
    float           _LME_InvMaskVal;
#endif

    // -------------------------

    FEATURE_TGL    (_TS_Enable);
    uint            _TS_Steps;
    float3          _TS_BaseColor;
    float3          _TS_1stColor;
    float3          _TS_2ndColor;
    float3          _TS_3rdColor;
    float           _TS_Power;
    float           _TS_1stBorder;
    float           _TS_2ndBorder;
    float           _TS_3rdBorder;
    float           _TS_1stFeather;
    float           _TS_2ndFeather;
    float           _TS_3rdFeather;
    float           _TS_BlendNormal;
    float           _TS_BlendNormal2;
    float           _TS_InvMaskVal;
    float           _TS_FixContrast;
    float           _TS_MinDist;
    float           _TS_MaxDist;

    // -------------------------

    FEATURE_TGL    (_TR_Enable);
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
    FEATURE_TGL    (_OVL_Enable);
    uint            _OVL_UVType;
    float4          _OVL_Color;
    float4          _OVL_OverlayTex_ST;
    float2          _OVL_UVScroll;
    uint            _OVL_BlendType;
    float           _OVL_Power;
    float           _OVL_CustomParam1;
    float           _OVL_InvMaskVal;
    float           _OVL_VertColToDecal;
    float           _OVL_VertColToMask;
#endif

    // -------------------------

    FEATURE_TGL    (_TL_Enable);
    float           _TL_LineWidth;
    uint            _TL_LineType;
    float           _TL_Z_Shift;
    float4          _TL_LineColor;
    float           _TL_BlendBase;
    float           _TL_BlendCustom;
    float           _TL_InvMaskVal;
    float           _TL_UseCutout;

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
    FEATURE_TGL    (_DFD_Enable);
    float4          _DFD_Color;
    float           _DFD_MinDist;
    float           _DFD_MaxDist;
    float           _DFD_Power;
    float           _DFD_BackShadow;
#endif

    // -------------------------

    FEATURE_TGL    (_DSV_Enable);
    float           _DSV_Dissolve;
    float           _DSV_Invert;
    float4          _DSV_SparkColor;
    float           _DSV_SparkWidth;
    DECL_MAIN_TEX2D(_DSV_CtrlTex);
    float4          _DSV_CtrlTex_ST;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_TFG_Enable);
    float4          _TFG_Color;
    float           _TFG_MinDist;
    float           _TFG_MaxDist;
    float           _TFG_Exponential;
    float3          _TFG_BaseOffset;
    float3          _TFG_Scale;
#endif

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CRF_Enable);
    float           _CRF_RefractiveIndex;
    float           _CRF_Distance;
    float3          _CRF_Tint;
    float           _CRF_BlendNormal;
#endif

    // -------------------------

    FEATURE_TGL    (_CGO_Enable);
    float           _CGO_Power;

    // -------------------------

#ifndef _WF_MOBILE
    FEATURE_TGL    (_CGL_Enable);
    float           _CGL_Blur;
    uint            _CGL_BlurMode;
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
