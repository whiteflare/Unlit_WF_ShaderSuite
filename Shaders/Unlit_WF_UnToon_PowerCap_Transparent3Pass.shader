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
Shader "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent3Pass" {

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Toggle(_)]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        // Alpha
        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _Cutoff                 ("[AL] Cutoff Threshold", Range(0, 1)) = 0.9
            _AL_Power               ("[AL] Power", Range(0, 2)) = 1.0
            _AL_Fresnel             ("[AL] Fresnel Power", Range(0, 2)) = 0
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite              ("[AL] ZWrite", int) = 0

        // 裏面テクスチャ
        [WFHeaderToggle(BackFace Texture)]
            _BK_Enable              ("[BK] Enable", Float) = 0
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

        [WFHeaderToggle(Light Matcap 3)]
            _HL_Enable_2            ("[HB] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType_2           ("[HB] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_2         ("[HB] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_2       ("[HB] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_2             ("[HB] Power", Range(0, 2)) = 1
            _HL_BlendNormal_2       ("[HB] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_2      ("[HB] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha_2       ("[HB] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_2           ("[HB] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal_2        ("[HB] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_2          ("[HB] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_2  ("[HB] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_2       ("[HB] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 4)]
            _HL_Enable_3            ("[HC] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType_3           ("[HC] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_3         ("[HC] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_3       ("[HC] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_3             ("[HC] Power", Range(0, 2)) = 1
            _HL_BlendNormal_3       ("[HC] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_3      ("[HC] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha_3       ("[HC] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_3           ("[HC] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal_3        ("[HC] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_3          ("[HC] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_3  ("[HC] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_3       ("[HC] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 5)]
            _HL_Enable_4            ("[HD] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType_4           ("[HD] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_4         ("[HD] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_4       ("[HD] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_4             ("[HD] Power", Range(0, 2)) = 1
            _HL_BlendNormal_4       ("[HD] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_4      ("[HD] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha_4       ("[HD] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_4           ("[HD] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal_4        ("[HD] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_4          ("[HD] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_4  ("[HD] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_4       ("[HD] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 6)]
            _HL_Enable_5            ("[HE] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType_5           ("[HE] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_5         ("[HE] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_5       ("[HE] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_5             ("[HE] Power", Range(0, 2)) = 1
            _HL_BlendNormal_5       ("[HE] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_5      ("[HE] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha_5       ("[HE] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_5           ("[HE] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal_5        ("[HE] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_5          ("[HE] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_5  ("[HE] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_5       ("[HE] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 7)]
            _HL_Enable_6            ("[HF] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType_6           ("[HF] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_6         ("[HF] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_6       ("[HF] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_6             ("[HF] Power", Range(0, 2)) = 1
            _HL_BlendNormal_6       ("[HF] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_6      ("[HF] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha_6       ("[HF] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_6           ("[HF] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal_6        ("[HF] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_6          ("[HF] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_6  ("[HF] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_6       ("[HF] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 8)]
            _HL_Enable_7            ("[HG] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1,SHADE_CAP,2)]
            _HL_CapType_7           ("[HG] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_7         ("[HG] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_7       ("[HG] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_7             ("[HG] Power", Range(0, 2)) = 1
            _HL_BlendNormal_7       ("[HG] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_7      ("[HG] Blend Normal 2nd", Range(0, 1)) = 0.1
        [Toggle(_)]
            _HL_ChangeAlpha_7       ("[HG] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_7           ("[HG] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal_7        ("[HG] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_7          ("[HG] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_7  ("[HG] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_7       ("[HG] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

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
        [Toggle(_)]
            _TS_FixContrast         ("[SH] Dont Ajust Contrast", Range(0, 1)) = 0
            _TS_1stBorder           ("[SH] 1st Border", Range(0, 1)) = 0.4
            _TS_2ndBorder           ("[SH] 2nd Border", Range(0, 1)) = 0.2
            _TS_3rdBorder           ("[SH] 3rd Border", Range(0, 1)) = 0.1
            _TS_Feather             ("[SH] Feather", Range(0, 0.2)) = 0.05
            _TS_BlendNormal         ("[SH] Blend Normal", Range(0, 1)) = 0.1
            _TS_BlendNormal2        ("[SH] Blend Normal 2nd", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _TS_MaskTex             ("[SH] Anti-Shadow Mask Texture (R)", 2D) = "black" {}
        [Toggle(_)]
            _TS_InvMaskVal          ("[SH] Invert Mask Value", Range(0, 1)) = 0

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
            _CurrentVersion         ("2022/05/29", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _FallBack               ("UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "DisableBatching" = "True"
            "VRCFallback" = "UnlitCutout"
        }

        Pass {
            Name "MAIN_OPAQUE"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF
            ZWrite ON
            Blend Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #define _WF_ALPHA_FRESNEL
            #define _WF_ALPHA_CUSTOM    if (alpha < _Cutoff) { discard; } else { alpha *= _AL_Power; } // _Cutoff 以上を描画
            #define _WF_UNTOON_POWERCAP

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _NS_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local _VC_ENABLE
            #pragma shader_feature_local_fragment _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _BK_ENABLE
            #pragma shader_feature_local_fragment _CH_ENABLE
            #pragma shader_feature_local_fragment _ES_ENABLE
            #pragma shader_feature_local_fragment _FG_ENABLE
            #pragma shader_feature_local_fragment _HL_ENABLE
            #pragma shader_feature_local_fragment _TR_ENABLE

            #pragma shader_feature_local_fragment _HL_ENABLE_1
            #pragma shader_feature_local_fragment _HL_ENABLE_2
            #pragma shader_feature_local_fragment _HL_ENABLE_3
            #pragma shader_feature_local_fragment _HL_ENABLE_4
            #pragma shader_feature_local_fragment _HL_ENABLE_5
            #pragma shader_feature_local_fragment _HL_ENABLE_6
            #pragma shader_feature_local_fragment _HL_ENABLE_7

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE SHADOWS_SHADOWMASK

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "MAIN_BACK"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #define _WF_ALPHA_FRESNEL
            #define _WF_ALPHA_CUSTOM    if (alpha < _Cutoff) { alpha *= _AL_Power; } else { discard; } // _Cutoff 以下を描画
            #define _WF_UNTOON_POWERCAP
            #define _WF_FACE_BACK

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _NS_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local _VC_ENABLE
            #pragma shader_feature_local_fragment _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _BK_ENABLE
            #pragma shader_feature_local_fragment _CH_ENABLE
            #pragma shader_feature_local_fragment _ES_ENABLE
            #pragma shader_feature_local_fragment _FG_ENABLE
            #pragma shader_feature_local_fragment _HL_ENABLE
            #pragma shader_feature_local_fragment _TR_ENABLE

            #pragma shader_feature_local_fragment _HL_ENABLE_1
            #pragma shader_feature_local_fragment _HL_ENABLE_2
            #pragma shader_feature_local_fragment _HL_ENABLE_3
            #pragma shader_feature_local_fragment _HL_ENABLE_4
            #pragma shader_feature_local_fragment _HL_ENABLE_5
            #pragma shader_feature_local_fragment _HL_ENABLE_6
            #pragma shader_feature_local_fragment _HL_ENABLE_7

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

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #define _WF_ALPHA_FRESNEL
            #define _WF_ALPHA_CUSTOM    if (alpha < _Cutoff) { alpha *= _AL_Power; } else { discard; } // _Cutoff 以下を描画
            #define _WF_UNTOON_POWERCAP

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _NS_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local _VC_ENABLE
            #pragma shader_feature_local_fragment _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _BK_ENABLE
            #pragma shader_feature_local_fragment _CH_ENABLE
            #pragma shader_feature_local_fragment _ES_ENABLE
            #pragma shader_feature_local_fragment _FG_ENABLE
            #pragma shader_feature_local_fragment _HL_ENABLE
            #pragma shader_feature_local_fragment _TR_ENABLE

            #pragma shader_feature_local_fragment _HL_ENABLE_1
            #pragma shader_feature_local_fragment _HL_ENABLE_2
            #pragma shader_feature_local_fragment _HL_ENABLE_3
            #pragma shader_feature_local_fragment _HL_ENABLE_4
            #pragma shader_feature_local_fragment _HL_ENABLE_5
            #pragma shader_feature_local_fragment _HL_ENABLE_6
            #pragma shader_feature_local_fragment _HL_ENABLE_7

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE SHADOWS_SHADOWMASK

            #include "WF_UnToon.cginc"

            ENDCG
        }

        UsePass "UnlitWF/WF_UnToon_TransCutout/SHADOWCASTER"
        UsePass "UnlitWF/WF_UnToon_TransCutout/META"
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
