/*
 *  The MIT License
 *
 *  Copyright 2018-2021 whiteflare.
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
    DECL_SUB_TEX2D      (_HL_MaskTex);
    DECL_SUB_TEX2D      (_TS_MaskTex);
    DECL_SUB_TEX2D      (_TR_MaskTex);
    DECL_SUB_TEX2D      (_OL_MaskTex);
    DECL_SUB_TEX2D      (_TL_CustomColorTex);
    DECL_SUB_TEX2D      (_CH_3chMaskTex);
#ifndef _WF_MOBILE
    DECL_SUB_TEX2D      (_NM_2ndMaskTex);
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
    DECL_MAIN_TEX2D     (_HL_MatcapTex);
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

#ifndef _WF_MOBILE
#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _BK_Enable;
#endif
    float4          _BK_BackTex_ST;
    float4          _BK_BackColor;
#endif

    uint            _AL_Source;
    float           _AL_Power;
    float           _AL_Fresnel;
    float           _AL_AlphaToMask;
    float           _AL_Z_Offset;
    float           _AL_InvMaskVal;

    float           _GL_CastShadow;
    float           _GL_LevelMin;
    float           _GL_LevelMax;
    float           _GL_BlendPower;
    uint            _GL_LightMode;
    float           _GL_CustomAzimuth;
    float           _GL_CustomAltitude;
    float           _GL_DisableBackLit;
    float           _GL_DisableBasePos;

    float           _GI_Enable;
    float           _GI_IndirectChroma;
    float           _GI_IndirectMultiplier;
    float           _GI_EmissionMultiplier;

#ifndef _WF_MOBILE
#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _CH_Enable;
#endif
    float4          _CH_ColorR;
    float4          _CH_ColorG;
    float4          _CH_ColorB;
#endif

#ifndef _WF_MOBILE
#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _CL_Enable;
#endif
    float           _CL_DeltaH;
    float           _CL_DeltaS;
    float           _CL_DeltaV;
    float           _CL_Monochrome;
#endif

#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _ES_Enable;
#endif
    float4          _EmissionColor;
    uint            _ES_BlendType;
    uint            _ES_Shape;
    uint            _ES_DirType;
    float4          _ES_Direction;
    float           _ES_LevelOffset;
    float           _ES_Sharpness;
    float           _ES_Speed;
    float           _ES_AlphaScroll;

    float           _NM_Enable;
    float           _BumpScale;
    float           _NM_Power;
    uint            _NM_FlipMirror;
#ifndef _WF_MOBILE
    uint            _NM_2ndType;
    float4          _DetailNormalMap_ST;
    float           _DetailNormalMapScale;
    float           _NM_InvMaskVal;
#endif

#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _MT_Enable;
#endif
    float           _MT_Metallic;
    float           _MT_ReflSmooth;
    float           _MT_BlendNormal;
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

    float           _HL_Enable;
    uint            _HL_CapType;
    float3          _HL_MedianColor;
    float3          _HL_MatcapColor;
    float           _HL_Power;
    float           _HL_BlendNormal;
    float           _HL_Parallax;
    float           _HL_InvMaskVal;

#ifndef _WF_MOBILE
#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _LM_Enable;
#endif
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

#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _TS_Enable;
#endif
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
    float           _TS_InvMaskVal;

#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _TR_Enable;
#endif
    float3          _TR_Color;
    uint            _TR_BlendType;
    float           _TR_Power;
    float           _TR_Feather;
    float           _TR_InvMaskVal;
    float           _TR_BlendNormal;
    float           _TR_PowerTop;
    float           _TR_PowerSide;
    float           _TR_PowerBottom;

#ifndef _WF_MOBILE
#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _OL_Enable;
#endif
    uint            _OL_UVType;
    float4          _OL_Color;
    float4          _OL_OverlayTex_ST;
    uint            _OL_BlendType;
    float           _OL_Power;
    float           _OL_CustomParam1;
    float           _OL_InvMaskVal;
    float           _OL_VertColToDecal;
    float           _OL_VertColToMask;
#endif

#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _TL_Enable;
#endif
    float           _TL_LineWidth;
    uint            _TL_LineType;
    float           _TL_Z_Shift;
    float4          _TL_LineColor;
    float           _TL_BlendBase;
    float           _TL_BlendCustom;
    float           _TL_InvMaskVal;
    float           _TL_UseCutout;

#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _AO_Enable;
#endif
    float           _AO_UseLightMap;
    float           _AO_Contrast;
    float           _AO_Brightness;
    float4          _AO_TintColor;

#ifndef _WF_MOBILE
#ifdef _WF_LEGACY_FEATURE_SWITCH
    float           _FG_Enable;
#endif
    float4          _FG_Color;
    float           _FG_MinDist;
    float           _FG_MaxDist;
    float           _FG_Exponential;
    float3          _FG_BaseOffset;
    float3          _FG_Scale;
#endif

#ifdef _WF_UNTOON_TESS
    float           _TE_Factor;
    float           _TE_MinDist;
    float           _TE_MaxDist;
    float           _TE_SmoothPower;
    float           _TE_InvMaskVal;
#endif

#ifdef _WF_UNTOON_POWERCAP
    #define WF_POWERCAP_DECL(id)                \
        float       _HL_Enable_##id;            \
        uint        _HL_CapType_##id;           \
        DECL_MAIN_TEX2D(_HL_MatcapTex_##id);    \
        float3      _HL_MedianColor_##id;       \
        float3      _HL_MatcapColor_##id;       \
        float       _HL_Power_##id;             \
        float       _HL_BlendNormal_##id;       \
        float       _HL_Parallax_##id;          \
        DECL_SUB_TEX2D(_HL_MaskTex_##id);       \
        float       _HL_InvMaskVal_##id;

    WF_POWERCAP_DECL(1)
    WF_POWERCAP_DECL(2)
    WF_POWERCAP_DECL(3)
    WF_POWERCAP_DECL(4)
    WF_POWERCAP_DECL(5)
    WF_POWERCAP_DECL(6)
    WF_POWERCAP_DECL(7)
#endif

#endif
