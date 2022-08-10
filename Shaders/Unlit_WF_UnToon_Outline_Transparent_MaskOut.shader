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
Shader "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut" {

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Toggle(_)]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        // StencilMask
        [WFHeader(Stencil Mask)]
        [Enum(A_1000,8,B_1001,9,C_1010,10,D_1100,11)]
            _StencilMaskID          ("ID", int) = 8

        // Alpha
        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _AL_Power               ("[AL] Power", Range(0, 2)) = 1.0
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite              ("[AL] ZWrite", int) = 1

        // アウトライン
        [WFHeaderAlwaysOn(Outline)]
            _TL_Enable              ("[LI] Enable", Float) = 1
            _TL_LineColor           ("[LI] Line Color", Color) = (0.1, 0.1, 0.1, 1)
        [NoScaleOffset]
            _TL_CustomColorTex      ("[LI] Custom Color Texture", 2D) = "white" {}
            _TL_LineWidth           ("[LI] Line Width", Range(0, 1)) = 0.05
        [Enum(NORMAL,0,EDGE,1)]
            _TL_LineType            ("[LI] Line Type", Float) = 0
            _TL_BlendCustom         ("[LI] Blend Custom Color Texture", Range(0, 1)) = 0
            _TL_BlendBase           ("[LI] Blend Base Color", Range(0, 1)) = 0
        [NoScaleOffset]
            _TL_MaskTex             ("[LI] Mask Texture (R)", 2D) = "white" {}
        [Toggle(_)]
            _TL_InvMaskVal          ("[LI] Invert Mask Value", Float) = 0
            _TL_Z_Shift             ("[LI] Z-shift (tweak)", Range(-0.1, 0.5)) = 0

        // 裏面テクスチャ
        [WFHeaderToggle(BackFace Texture)]
            _BK_Enable              ("[BK] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _BK_UVType              ("[BK] UV Type", Float) = 0
            _BK_BackTex             ("[BK] Back Texture", 2D) = "white" {}
        [HDR]
            _BK_BackColor           ("[BK] Back Color", Color) = (1, 1, 1, 1)

        // 3chカラーマスク
        [WFHeaderToggle(3ch Color Mask)]
            _CH_Enable              ("[CH] Enable", Float) = 0
        [NoScaleOffset]
            _CH_3chMaskTex          ("[CH] 3ch Mask Texture", 2D) = "black" {}
        [HDR]
            _CH_ColorR              ("[CH] R ch Color", Color) = (1, 1, 1, 1)
        [HDR]
            _CH_ColorG              ("[CH] G ch Color", Color) = (1, 1, 1, 1)
        [HDR]
            _CH_ColorB              ("[CH] B ch Color", Color) = (1, 1, 1, 1)

        // 色変換
        [WFHeaderToggle(Color Change)]
            _CL_Enable              ("[CL] Enable", Float) = 0
        [Toggle(_)]
            _CL_Monochrome          ("[CL] monochrome", Range(0, 1)) = 0
            _CL_DeltaH              ("[CL] Hur", Range(0, 1)) = 0
            _CL_DeltaS              ("[CL] Saturation", Range(-1, 1)) = 0
            _CL_DeltaV              ("[CL] Brightness", Range(-1, 1)) = 0

        // ノーマルマップ
        [WFHeaderToggle(NormalMap)]
            _NM_Enable              ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap                ("[NM] NormalMap Texture", 2D) = "bump" {}
            _BumpScale              ("[NM] Bump Scale", Range(0, 2)) = 1.0
            _NM_Power               ("[NM] Shadow Power", Range(0, 1)) = 0.25
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FlipMirror             ("[NM] Flip Mirror", Float) = 0

        // Detailノーマルマップ
        [WFHeaderToggle(Detail NormalMap)]
            _NS_Enable              ("[NS] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _NS_UVType              ("[NS] 2nd Normal UV Type", Float) = 0
            _DetailNormalMap        ("[NS] 2nd NormalMap Texture", 2D) = "bump" {}
            _DetailNormalMapScale   ("[NS] 2nd Bump Scale", Range(0, 2)) = 0.4
        [NoScaleOffset]
            _NS_2ndMaskTex          ("[NS] 2nd NormalMap Mask Texture (R)", 2D) = "white" {}
        [Toggle(_)]
            _NS_InvMaskVal          ("[NS] Invert Mask Value", Range(0, 1)) = 0

        // メタリックマップ
        [WFHeaderToggle(Metallic)]
            _MT_Enable              ("[MT] Enable", Float) = 0
            _MT_Metallic            ("[MT] Metallic", Range(0, 1)) = 1
            _MT_ReflSmooth          ("[MT] Smoothness", Range(0, 1)) = 1
            _MT_Brightness          ("[MT] Brightness", Range(0, 1)) = 0.2
            _MT_BlendNormal         ("[MT] Blend Normal", Range(0, 1)) = 0.1
            _MT_BlendNormal2        ("[MT] Blend Normal 2nd", Range(0, 1)) = 0.1
            _MT_Monochrome          ("[MT] Monochrome Reflection", Range(0, 1)) = 0
        [Toggle(_)]
            _MT_GeomSpecAA          ("[MT] Geometric Specular AA", Range(0, 1)) = 1
        [Enum(MASK,0,METALLIC,1)]
            _MT_MetallicMapType     ("[MT] MetallicMap Type", Float) = 0
        [NoScaleOffset]
            _MetallicGlossMap       ("[MT] MetallicSmoothnessMap Texture", 2D) = "white" {}
        [Toggle(_)]
            _MT_InvMaskVal          ("[MT] Invert Mask Value", Range(0, 1)) = 0
        [NoScaleOffset]
            _SpecGlossMap           ("[MT] RoughnessMap Texture", 2D) = "black" {}
        [Toggle(_)]
            _MT_InvRoughnessMaskVal ("[MT] Invert Mask Value", Range(0, 1)) = 0

        [Header(Metallic Specular)]
            _MT_Specular            ("[MT] Specular", Range(0, 1)) = 0
            _MT_SpecSmooth          ("[MT] Smoothness", Range(0, 1)) = 0.8

        [Header(Metallic Secondary)]
        [Enum(OFF,0,ONLY_SECOND_MAP,2)]
            _MT_CubemapType         ("[MT] 2nd CubeMap Blend", Float) = 0
        [NoScaleOffset]
            _MT_Cubemap             ("[MT] 2nd CubeMap", Cube) = "" {}
            _MT_CubemapPower        ("[MT] 2nd CubeMap Power", Range(0, 2)) = 1
            _MT_CubemapHighCut      ("[MT] 2nd CubeMap Hi-Cut Filter", Range(0, 1)) = 0

        // Matcapハイライト
        [WFHeaderToggle(Light Matcap)]
            _HL_Enable              ("[HL] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType             ("[HL] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex           ("[HL] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor         ("[HL] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power               ("[HL] Power", Range(0, 2)) = 1
            _HL_BlendNormal         ("[HL] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2        ("[HL] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha         ("[HL] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex             ("[HL] Mask Texture (RGB)", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal          ("[HL] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax            ("[HL] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome    ("[HL] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor         ("[HL] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 2)]
            _HL_Enable_1            ("[HA] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType_1           ("[HA] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_1         ("[HA] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_1       ("[HA] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_1             ("[HA] Power", Range(0, 2)) = 1
            _HL_BlendNormal_1       ("[HA] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_1      ("[HA] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha_1       ("[HA] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_1           ("[HA] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal_1        ("[HA] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_1          ("[HA] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_1  ("[HA] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_1       ("[HA] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        // ラメ
        [WFHeaderToggle(Lame)]
            _LM_Enable              ("[LM] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _LM_UVType              ("[LM] UV Type", Float) = 0
        [HDR]
            _LM_Color               ("[LM] Color", Color) = (1, 1, 1, 1)
            _LM_Texture             ("[LM] Texture", 2D) = "white" {}
        [HDR]
            _LM_RandColor           ("[LM] Random Color", Color) = (0, 0, 0, 1)
        [Toggle(_)]
            _LM_ChangeAlpha         ("[LM] Change Alpha Transparency", Range(0, 1)) = 0
        [Enum(POLYGON,0,POINT,1)]
            _LM_Shape               ("[LM] Shape", Float) = 0
        [PowerSlider(4.0)]
            _LM_Scale               ("[LM] Scale", Range(0, 4)) = 0.5
        [PowerSlider(4.0)]
            _LM_Dencity             ("[LM] Dencity", Range(0.3, 4)) = 0.5
            _LM_Glitter             ("[LM] Glitter", Range(0, 1)) = 0.5
            _LM_MinDist             ("[LM] FadeOut Distance (Near)", Range(0, 5)) = 2.0
            _LM_MaxDist             ("[LM] FadeOut Distance (Far)", Range(0, 5)) = 4.0
            _LM_Spot                ("[LM] FadeOut Angle", Range(0, 16)) = 2.0
            _LM_AnimSpeed           ("[LM] Anim Speed", Range(0, 1)) = 0.2
        [NoScaleOffset]
            _LM_MaskTex             ("[LM] Mask Texture (R)", 2D) = "white" {}
        [Toggle(_)]
            _LM_InvMaskVal          ("[LM] Invert Mask Value", Range(0, 1)) = 0

        // 階調影
        [WFHeaderToggle(ToonShade)]
            _TS_Enable              ("[SH] Enable", Float) = 0
        [IntRange]
            _TS_Steps               ("[SH] Steps", Range(1, 3)) = 2
            _TS_BaseColor           ("[SH] Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _TS_BaseTex             ("[SH] Base Shade Texture", 2D) = "white" {}
            _TS_1stColor            ("[SH] 1st Shade Color", Color) = (0.81, 0.81, 0.9, 1)
        [NoScaleOffset]
            _TS_1stTex              ("[SH] 1st Shade Texture", 2D) = "white" {}
            _TS_2ndColor            ("[SH] 2nd Shade Color", Color) = (0.68, 0.68, 0.8, 1)
        [NoScaleOffset]
            _TS_2ndTex              ("[SH] 2nd Shade Texture", 2D) = "white" {}
            _TS_3rdColor            ("[SH] 3rd Shade Color", Color) = (0.595, 0.595, 0.7, 1)
        [NoScaleOffset]
            _TS_3rdTex              ("[SH] 3rd Shade Texture", 2D) = "white" {}
            _TS_Power               ("[SH] Shade Power", Range(0, 2)) = 1
            _TS_MinDist             ("[SH] FadeOut Distance (Near)", Range(0, 15)) = 1.0
            _TS_MaxDist             ("[SH] FadeOut Distance (Far)", Range(0, 15)) = 4.0
        [Toggle(_)]
            _TS_FixContrast         ("[SH] Dont Ajust Contrast", Range(0, 1)) = 0
            _TS_BlendNormal         ("[SH] Blend Normal", Range(0, 1)) = 0.1
            _TS_BlendNormal2        ("[SH] Blend Normal 2nd", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _TS_MaskTex             ("[SH] Anti-Shadow Mask Texture (R)", 2D) = "black" {}
        [Toggle(_)]
            _TS_InvMaskVal          ("[SH] Invert Mask Value", Range(0, 1)) = 0
        [Header(ToonShade Advance)]
            _TS_1stBorder           ("[SH] 1st Border", Range(0, 1)) = 0.4
            _TS_2ndBorder           ("[SH] 2nd Border", Range(0, 1)) = 0.2
            _TS_3rdBorder           ("[SH] 3rd Border", Range(0, 1)) = 0.1
            _TS_1stFeather          ("[SH] 1st Feather", Range(0, 0.2)) = 0.05
            _TS_2ndFeather          ("[SH] 2nd Feather", Range(0, 0.2)) = 0.05
            _TS_3rdFeather          ("[SH] 3rd Feather", Range(0, 0.2)) = 0.05

        // リムライト
        [WFHeaderToggle(RimLight)]
            _TR_Enable              ("[RM] Enable", Float) = 0
        [HDR]
            _TR_Color               ("[RM] Rim Color", Color) = (0.8, 0.8, 0.8, 1)
        [Enum(ADD,2,ALPHA,1,ADD_AND_SUB,0)]
            _TR_BlendType           ("[RM] Blend Type", Float) = 0
            _TR_Power               ("[RM] Power", Range(0, 2)) = 1
            _TR_Feather             ("[RM] Feather", Range(0, 0.2)) = 0.05
            _TR_BlendNormal         ("[RM] Blend Normal", Range(0, 1)) = 0
            _TR_BlendNormal2        ("[RM] Blend Normal 2nd", Range(0, 1)) = 0
        [NoScaleOffset]
            _TR_MaskTex             ("[RM] Mask Texture (RGB)", 2D) = "white" {}
        [Toggle(_)]
            _TR_InvMaskVal          ("[RM] Invert Mask Value", Range(0, 1)) = 0
        [Header(RimLight Advance)]
            _TR_PowerTop            ("[RM] Power Top", Range(0, 0.5)) = 0.05
            _TR_PowerSide           ("[RM] Power Side", Range(0, 0.5)) = 0.1
            _TR_PowerBottom         ("[RM] Power Bottom", Range(0, 0.5)) = 0.1

        // Overlay Texture
        [WFHeaderToggle(Overlay Texture)]
            _OL_Enable              ("[OL] Enable", Float) = 0
        [Enum(UV1,0,UV2,1,SKYBOX,2,MATCAP,4,ANGEL_RING,3)]
            _OL_UVType              ("[OL] UV Type", Float) = 0
        [HDR]
            _OL_Color               ("[OL] Overlay Color", Color) = (1, 1, 1, 1)
            _OL_OverlayTex          ("[OL] Overlay Texture", 2D) = "white" {}
        [WF_Vector2]
            _OL_UVScroll            ("[OL] UV Scroll", Vector) = (0, 0, 0, 0)
        [Toggle(_)]
            _OL_VertColToDecal      ("[OL] Multiply VertexColor To Overlay Texture", Range(0, 1)) = 0
        [Enum(ALPHA,0,ADD,1,MUL,2,ADD_AND_SUB,3,SCREEN,4,OVERLAY,5,HARD_LIGHT,6)]
            _OL_BlendType           ("[OL] Blend Type", Float) = 0
            _OL_Power               ("[OL] Blend Power", Range(0, 1)) = 1
            _OL_CustomParam1        ("[OL] Customize Parameter 1", Range(0, 1)) = 0
        [NoScaleOffset]
            _OL_MaskTex             ("[OL] Mask Texture (R)", 2D) = "white" {}
        [Toggle(_)]
            _OL_VertColToMask       ("[OL] Multiply VertexColor To Mask Texture", Range(0, 1)) = 0
        [Toggle(_)]
            _OL_InvMaskVal          ("[OL] Invert Mask Value", Range(0, 1)) = 0

        // Distance Fade
        [WFHeaderToggle(Distance Fade)]
            _DF_Enable              ("[DF] Enable", Float) = 0
            _DF_Color               ("[DF] Color", Color) = (0.1, 0.1, 0.1, 1)
            _DF_MinDist             ("[DF] Fade Distance (Near)", Range(0, 0.5)) = 0.02
            _DF_MaxDist             ("[DF] Fade Distance (Far)", Range(0, 0.5)) = 0.08
            _DF_Power               ("[DF] Power", Range(0, 1)) = 1
        [Toggle(_)]
            _DF_BackShadow          ("[DF] BackFace Shadow", Float) = 1

        // Ambient Occlusion
        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable              ("[AO] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _AO_UVType              ("[AO] UV Type", Float) = 0
        [NoScaleOffset]
            _OcclusionMap           ("[AO] Occlusion Map (RGB)", 2D) = "white" {}
        [Toggle(_)]
            _AO_UseGreenMap         ("[AO] Use Green Channel Only", Float) = 0
            _AO_TintColor           ("[AO] Tint Color", Color) = (0, 0, 0, 1)
        [Toggle(_)]
            _AO_UseLightMap         ("[AO] Use LightMap", Float) = 1
            _AO_Contrast            ("[AO] Contrast", Range(0, 2)) = 1
            _AO_Brightness          ("[AO] Brightness", Range(-1, 1)) = 0

        // Emission
        [WFHeaderToggle(Emission)]
            _ES_Enable              ("[ES] Enable", Float) = 0
        [HDR]
            _EmissionColor          ("[ES] Emission", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _EmissionMap            ("[ES] Emission Texture", 2D) = "white" {}
        [Enum(ADD,0,ALPHA,2,LEGACY_ALPHA,1)]
            _ES_BlendType           ("[ES] Blend Type", Float) = 0

        [Header(Emissive Scroll)]
        [Enum(STANDARD,0,SAWTOOTH,1,SIN_WAVE,2,CONSTANT,3)]
            _ES_Shape               ("[ES] Wave Type", Float) = 3
        [Toggle(_)]
            _ES_AlphaScroll         ("[ES] Change Alpha Transparency", Range(0, 1)) = 0
        [Enum(WORLD_SPACE,0,LOCAL_SPACE,1,UV1,2,UV2,3)]
            _ES_DirType             ("[ES] Direction Type", Float) = 0
        [WF_Vector3]
            _ES_Direction           ("[ES] Direction", Vector) = (0, -10, 0, 0)
            _ES_LevelOffset         ("[ES] LevelOffset", Range(-1, 1)) = 0
            _ES_Sharpness           ("[ES] Sharpness", Range(0, 4)) = 1
            _ES_Speed               ("[ES] ScrollSpeed", Range(0, 8)) = 2

        // Fog
        [WFHeaderToggle(Fog)]
            _FG_Enable              ("[FG] Enable", Float) = 0
            _FG_Color               ("[FG] Color", Color) = (0.5, 0.5, 0.6, 1)
            _FG_MinDist             ("[FG] FadeOut Distance (Near)", Float) = 0.5
            _FG_MaxDist             ("[FG] FadeOut Distance (Far)", Float) = 0.8
            _FG_Exponential         ("[FG] Exponential", Range(0.5, 4.0)) = 1.0
        [WF_Vector3]
            _FG_BaseOffset          ("[FG] Base Offset", Vector) = (0, 0, 0, 0)
        [WF_Vector3]
            _FG_Scale               ("[FG] Scale", Vector) = (1, 1, 1, 0)

        // Lit
        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8
        [Toggle(_)]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1

        [WFHeader(Lit Advance)]
        [Enum(AUTO,0,ONLY_DIRECTIONAL_LIT,1,ONLY_POINT_LIT,2,CUSTOM_WORLD_DIR,3,CUSTOM_LOCAL_DIR,4,CUSTOM_WORLD_POS,5)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)
        [Toggle(_)]
            _GL_DisableBackLit      ("Disable BackLit", Range(0, 1)) = 0
        [Toggle(_)]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0

        [WFHeaderToggle(Light Bake Effects)]
            _GI_Enable              ("[GI] Enable", Float) = 0
            _GI_IndirectMultiplier  ("[GI] Indirect Multiplier", Range(0, 2)) = 1
            _GI_EmissionMultiplier  ("[GI] Emission Multiplier", Range(0, 2)) = 1
            _GI_IndirectChroma      ("[GI] Indirect Chroma", Range(0, 2)) = 1

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2022/08/13", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _FallBack               ("UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+1"
            "DisableBatching" = "True"
            "VRCFallback" = "UnlitCutout"
        }

        GrabPass { "_UnToonOutlineCancelLater" }

        Pass {
            Name "OUTLINE"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            Stencil {
                Ref [_StencilMaskID]
                ReadMask 15
                Comp notEqual
            }

            CGPROGRAM

            #pragma vertex vert
            #pragma geometry geom_outline
            #pragma fragment frag

            #pragma target 4.5
            #pragma require geometry

            #define _WF_ALPHA_BLEND



            #define _TL_ENABLE
            #define _VC_ENABLE
            #define _FG_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE SHADOWS_SHADOWMASK

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "OUTLINE_CANCELLER"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF
            ZWrite OFF

            Stencil {
                Ref [_StencilMaskID]
                ReadMask 15
                Comp notEqual
            }

            CGPROGRAM

            #pragma vertex vert_outline_canceller
            #pragma fragment frag_outline_canceller

            #pragma target 4.5

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE SHADOWS_SHADOWMASK

            #define _TL_CANCEL_GRAB_TEXTURE _UnToonOutlineCancelLater

            #include "WF_UnToon_LineCanceller.cginc"

            ENDCG
        }

        Pass {
            Name "MAIN_BACK"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            Stencil {
                Ref [_StencilMaskID]
                ReadMask 15
                Comp notEqual
            }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #define _WF_ALPHA_FRESNEL
            #define _WF_FACE_BACK



            #define _AO_ENABLE
            #define _NM_ENABLE
            #define _NS_ENABLE
            #define _OL_ENABLE
            #define _TS_ENABLE
            #define _VC_ENABLE



            #define _BK_ENABLE
            #define _CH_ENABLE
            #define _CL_ENABLE
            #define _DF_ENABLE
            #define _ES_ENABLE
            #define _FG_ENABLE
            #define _HL_ENABLE
            #define _HL_ENABLE_1
            #define _LM_ENABLE
            #define _MT_ENABLE
            #define _TR_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE SHADOWS_SHADOWMASK

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "MAIN_FRONT"
            Tags { "LightMode" = "ForwardBase" }

            Cull BACK
            ZWrite [_AL_ZWrite]
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            Stencil {
                Ref [_StencilMaskID]
                ReadMask 15
                Comp notEqual
            }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #define _WF_ALPHA_FRESNEL



            #define _AO_ENABLE
            #define _NM_ENABLE
            #define _NS_ENABLE
            #define _OL_ENABLE
            #define _TS_ENABLE
            #define _VC_ENABLE


            #define _BK_ENABLE
            #define _CH_ENABLE
            #define _CL_ENABLE
            #define _ES_ENABLE
            #define _FG_ENABLE
            #define _HL_ENABLE
            #define _HL_ENABLE_1
            #define _LM_ENABLE
            #define _MT_ENABLE
            #define _TR_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE SHADOWS_SHADOWMASK

            #include "WF_UnToon.cginc"

            ENDCG
        }

        UsePass "UnlitWF/WF_UnToon_Transparent/SHADOWCASTER"
        UsePass "UnlitWF/WF_UnToon_Transparent/META"
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
