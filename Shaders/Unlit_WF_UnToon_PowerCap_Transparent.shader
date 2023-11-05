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
Shader "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [ToggleUI]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _AL_Power               ("[AL] Power", Range(0, 2)) = 1.0
            _AL_Fresnel             ("[AL] Fresnel Power", Range(0, 2)) = 0
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite              ("[AL] ZWrite", int) = 0
        [Enum(OFF,0,ON,1)]
            _AL_ZWriteBack          ("[AL] ZWrite (Back)", int) = 0

        [WFHeaderToggle(BackFace Texture)]
            _BKT_Enable             ("[BKT] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _BKT_UVType             ("[BKT] UV Type", Float) = 0
            _BKT_BackTex            ("[BKT] Back Texture", 2D) = "white" {}
        [HDR]
            _BKT_BackColor          ("[BKT] Back Color", Color) = (1, 1, 1, 1)

        [WFHeaderToggle(3ch Color Mask)]
            _CHM_Enable             ("[CHM] Enable", Float) = 0
        [NoScaleOffset]
            _CHM_3chMaskTex         ("[CHM] 3ch Mask Texture", 2D) = "black" {}
        [HDR]
            _CHM_ColorR             ("[CHM] R ch Color", Color) = (1, 1, 1, 1)
        [HDR]
            _CHM_ColorG             ("[CHM] G ch Color", Color) = (1, 1, 1, 1)
        [HDR]
            _CHM_ColorB             ("[CHM] B ch Color", Color) = (1, 1, 1, 1)

        [WFHeaderToggle(Color Change)]
            _CLC_Enable             ("[CLC] Enable", Float) = 0
        [ToggleUI]
            _CLC_Monochrome         ("[CLC] monochrome", Range(0, 1)) = 0
            _CLC_DeltaH             ("[CLC] Hur", Range(0, 1)) = 0
            _CLC_DeltaS             ("[CLC] Saturation", Range(-1, 1)) = 0
            _CLC_DeltaV             ("[CLC] Brightness", Range(-1, 1)) = 0

        [WFHeaderToggle(NormalMap)]
            _NM_Enable              ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap                ("[NM] NormalMap Texture", 2D) = "bump" {}
        [ToggleUI]
            _NM_InvConvex           ("[NM] Use DirectX NormalMap", Float) = 0
            _BumpScale              ("[NM] Bump Scale", Range(-1, 2)) = 1.0
            _NM_Power               ("[NM] Shadow Power", Range(0, 1)) = 0.25
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FlipMirror             ("[NM] Flip Mirror", Float) = 0

        [WFHeaderToggle(Detail NormalMap)]
            _NS_Enable              ("[NS] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _NS_UVType              ("[NS] 2nd Normal UV Type", Float) = 0
            _DetailNormalMap        ("[NS] 2nd NormalMap Texture", 2D) = "bump" {}
            _DetailNormalMapScale   ("[NS] 2nd Bump Scale", Range(-1, 2)) = 0.4
        [NoScaleOffset]
            _NS_2ndMaskTex          ("[NS] 2nd NormalMap Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _NS_InvMaskVal          ("[NS] Invert Mask Value", Range(0, 1)) = 0

        [WFHeaderToggle(Light Matcap)]
            _HL_Enable              ("[HL] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType             ("[HL] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex           ("[HL] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor         ("[HL] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power               ("[HL] Power", Range(0, 2)) = 1
            _HL_BlendNormal         ("[HL] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2        ("[HL] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha         ("[HL] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex             ("[HL] Mask Texture (RGB)", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal          ("[HL] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax            ("[HL] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome    ("[HL] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor         ("[HL] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 2)]
            _HL_Enable_1            ("[HA] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_1           ("[HA] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_1         ("[HA] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_1       ("[HA] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_1             ("[HA] Power", Range(0, 2)) = 1
            _HL_BlendNormal_1       ("[HA] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_1      ("[HA] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha_1       ("[HA] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_1           ("[HA] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_1        ("[HA] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_1          ("[HA] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_1  ("[HA] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_1       ("[HA] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 3)]
            _HL_Enable_2            ("[HB] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_2           ("[HB] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_2         ("[HB] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_2       ("[HB] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_2             ("[HB] Power", Range(0, 2)) = 1
            _HL_BlendNormal_2       ("[HB] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_2      ("[HB] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha_2       ("[HB] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_2           ("[HB] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_2        ("[HB] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_2          ("[HB] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_2  ("[HB] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_2       ("[HB] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 4)]
            _HL_Enable_3            ("[HC] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_3           ("[HC] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_3         ("[HC] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_3       ("[HC] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_3             ("[HC] Power", Range(0, 2)) = 1
            _HL_BlendNormal_3       ("[HC] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_3      ("[HC] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha_3       ("[HC] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_3           ("[HC] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_3        ("[HC] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_3          ("[HC] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_3  ("[HC] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_3       ("[HC] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 5)]
            _HL_Enable_4            ("[HD] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_4           ("[HD] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_4         ("[HD] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_4       ("[HD] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_4             ("[HD] Power", Range(0, 2)) = 1
            _HL_BlendNormal_4       ("[HD] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_4      ("[HD] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha_4       ("[HD] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_4           ("[HD] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_4        ("[HD] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_4          ("[HD] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_4  ("[HD] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_4       ("[HD] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 6)]
            _HL_Enable_5            ("[HE] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_5           ("[HE] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_5         ("[HE] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_5       ("[HE] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_5             ("[HE] Power", Range(0, 2)) = 1
            _HL_BlendNormal_5       ("[HE] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_5      ("[HE] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha_5       ("[HE] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_5           ("[HE] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_5        ("[HE] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_5          ("[HE] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_5  ("[HE] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_5       ("[HE] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 7)]
            _HL_Enable_6            ("[HF] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_6           ("[HF] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_6         ("[HF] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_6       ("[HF] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_6             ("[HF] Power", Range(0, 2)) = 1
            _HL_BlendNormal_6       ("[HF] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_6      ("[HF] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha_6       ("[HF] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_6           ("[HF] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_6        ("[HF] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_6          ("[HF] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_6  ("[HF] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_6       ("[HF] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 8)]
            _HL_Enable_7            ("[HG] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_7           ("[HG] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_7         ("[HG] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_7       ("[HG] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_7             ("[HG] Power", Range(0, 2)) = 1
            _HL_BlendNormal_7       ("[HG] Blend Normal", Range(0, 1)) = 0.1
            _HL_BlendNormal2_7      ("[HG] Blend Normal 2nd", Range(0, 1)) = 0.1
        [ToggleUI]
            _HL_ChangeAlpha_7       ("[HG] Change Alpha Transparency", Range(0, 1)) = 0
        [NoScaleOffset]
            _HL_MaskTex_7           ("[HG] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_7        ("[HG] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax_7          ("[HG] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome_7  ("[HG] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor_7       ("[HG] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(ToonShade)]
            _TS_Enable              ("[TS] Enable", Float) = 0
        [IntRange]
            _TS_Steps               ("[TS] Steps", Range(1, 3)) = 2
            _TS_BaseColor           ("[TS] Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _TS_BaseTex             ("[TS] Base Shade Texture", 2D) = "white" {}
            _TS_1stColor            ("[TS] 1st Shade Color", Color) = (0.81, 0.81, 0.9, 1)
        [NoScaleOffset]
            _TS_1stTex              ("[TS] 1st Shade Texture", 2D) = "white" {}
            _TS_2ndColor            ("[TS] 2nd Shade Color", Color) = (0.68, 0.68, 0.8, 1)
        [NoScaleOffset]
            _TS_2ndTex              ("[TS] 2nd Shade Texture", 2D) = "white" {}
            _TS_3rdColor            ("[TS] 3rd Shade Color", Color) = (0.595, 0.595, 0.7, 1)
        [NoScaleOffset]
            _TS_3rdTex              ("[TS] 3rd Shade Texture", 2D) = "white" {}
            _TS_Power               ("[TS] Shade Power", Range(0, 2)) = 1
            _TS_MinDist             ("[TS] FadeOut Distance (Near)", Range(0, 15)) = 1.0
            _TS_MaxDist             ("[TS] FadeOut Distance (Far)", Range(0, 15)) = 4.0
        [ToggleUI]
            _TS_FixContrast         ("[TS] Dont Ajust Contrast", Range(0, 1)) = 0
            _TS_BlendNormal         ("[TS] Blend Normal", Range(0, 1)) = 0.1
            _TS_BlendNormal2        ("[TS] Blend Normal 2nd", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _TS_MaskTex             ("[TS] Anti-Shadow Mask Texture (R)", 2D) = "black" {}
        [ToggleUI]
            _TS_InvMaskVal          ("[TS] Invert Mask Value", Range(0, 1)) = 0
        [Header(ToonShade Advance)]
            _TS_1stBorder           ("[TS] 1st Border", Range(0, 1)) = 0.4
            _TS_2ndBorder           ("[TS] 2nd Border", Range(0, 1)) = 0.2
            _TS_3rdBorder           ("[TS] 3rd Border", Range(0, 1)) = 0.1
            _TS_1stFeather          ("[TS] 1st Feather", Range(0, 0.2)) = 0.05
            _TS_2ndFeather          ("[TS] 2nd Feather", Range(0, 0.2)) = 0.05
            _TS_3rdFeather          ("[TS] 3rd Feather", Range(0, 0.2)) = 0.05
        [ToggleUI]
            _TS_DisableBackLit      ("[TS] Disable BackLit", Range(0, 1)) = 0

        [WFHeaderToggle(RimLight)]
            _TR_Enable              ("[TR] Enable", Float) = 0
        [HDR]
            _TR_Color               ("[TR] Rim Color", Color) = (0.8, 0.8, 0.8, 1)
        [WF_Enum(UnlitWF.BlendModeTR,ADD,ALPHA,ADD_AND_SUB)]
            _TR_BlendType           ("[TR] Blend Type", Float) = 0
            _TR_Power               ("[TR] Power", Range(0, 2)) = 1
            _TR_Feather             ("[TR] Feather", Range(0, 0.2)) = 0.05
            _TR_BlendNormal         ("[TR] Blend Normal", Range(0, 1)) = 0
            _TR_BlendNormal2        ("[TR] Blend Normal 2nd", Range(0, 1)) = 0
        [NoScaleOffset]
            _TR_MaskTex             ("[TR] Mask Texture (RGB)", 2D) = "white" {}
        [ToggleUI]
            _TR_InvMaskVal          ("[TR] Invert Mask Value", Range(0, 1)) = 0
        [Header(RimLight Advance)]
            _TR_PowerTop            ("[TR] Power Top", Range(0, 0.5)) = 0.05
            _TR_PowerSide           ("[TR] Power Side", Range(0, 0.5)) = 0.1
            _TR_PowerBottom         ("[TR] Power Bottom", Range(0, 0.5)) = 0.1
        [ToggleUI]
            _TR_DisableBackLit      ("[TR] Disable BackLit", Range(0, 1)) = 0

        [WFHeaderToggle(Distance Fade)]
            _DFD_Enable             ("[DFD] Enable", Float) = 0
        [NoScaleOffset]
            _DFD_ColorTex           ("[DFD] Color Texture", 2D) = "white" {}
            _DFD_Color              ("[DFD] Color", Color) = (0.1, 0.1, 0.1, 1)
            _DFD_MinDist            ("[DFD] Fade Distance (Near)", Range(0, 0.5)) = 0.02
            _DFD_MaxDist            ("[DFD] Fade Distance (Far)", Range(0, 0.5)) = 0.08
            _DFD_Power              ("[DFD] Power", Range(0, 1)) = 1
        [ToggleUI]
            _DFD_BackShadow         ("[DFD] BackFace Shadow", Float) = 1

        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable              ("[AO] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _AO_UVType              ("[AO] UV Type", Float) = 0
        [NoScaleOffset]
            _OcclusionMap           ("[AO] Occlusion Map (RGB)", 2D) = "white" {}
        [ToggleUI]
            _AO_UseGreenMap         ("[AO] Use Green Channel Only", Float) = 0
            _AO_TintColor           ("[AO] Tint Color", Color) = (0, 0, 0, 1)
        [ToggleUI]
            _AO_UseLightMap         ("[AO] Use LightMap", Float) = 1
            _AO_Contrast            ("[AO] Contrast", Range(0, 2)) = 1
            _AO_Brightness          ("[AO] Brightness", Range(-1, 1)) = 0

        [WFHeaderToggle(Emission)]
            _ES_Enable              ("[ES] Enable", Float) = 0
        [HDR]
            _EmissionColor          ("[ES] Emission", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _EmissionMap            ("[ES] Emission Texture", 2D) = "white" {}
        [WF_Enum(UnlitWF.BlendModeES,ADD,ALPHA,LEGACY_ALPHA)]
            _ES_BlendType           ("[ES] Blend Type", Float) = 0

        [Header(Emissive Scroll)]
        [ToggleUI]
            _ES_ScrollEnable        ("[ES] Enable EmissiveScroll", Float) = 0
        [Enum(STANDARD,0,SAWTOOTH,1,SIN_WAVE,2)]
            _ES_SC_Shape            ("[ES] Wave Type", Float) = 0
        [ToggleUI]
            _ES_SC_AlphaScroll      ("[ES] Change Alpha Transparency", Range(0, 1)) = 0
        [Enum(WORLD_SPACE,0,LOCAL_SPACE,1,UV,2)]
            _ES_SC_DirType          ("[ES] Direction Type", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _ES_SC_UVType           ("[ES] UV Type", Float) = 0
        [WF_Vector3]
            _ES_SC_Direction        ("[ES] Direction", Vector) = (0, -10, 0, 0)
            _ES_SC_LevelOffset      ("[ES] LevelOffset", Range(-1, 1)) = 0
            _ES_SC_Sharpness        ("[ES] Sharpness", Range(0, 4)) = 1
            _ES_SC_Speed            ("[ES] ScrollSpeed", Range(0, 8)) = 2

        [Header(Emissive AudioLink)]
        [ToggleUI]
            _ES_AuLinkEnable        ("[ES] Enable AudioLink", Float) = 0
            _ES_AU_MinValue         ("[ES] Emission Multiplier (Min)", Range(0, 1)) = 0
            _ES_AU_MaxValue         ("[ES] Emission Multiplier (Max)", Range(0, 8)) = 2
        [ToggleUI]
            _ES_AU_AlphaLink        ("[ES] Change Alpha Transparency", Range(0, 1)) = 0
        [ToggleUI]
            _ES_AU_BlackOut         ("[ES] Dont Emit when AudioLink is disabled", Range(0, 1)) = 0
        [Enum(TREBLE,3,HIGH_MIDS,2,LOW_MIDS,1,BASS,0)]
            _ES_AU_Band             ("[ES] Band", Float) = 0
            _ES_AU_Slope            ("[ES] Slope", Range(0, 1)) = 0.2
            _ES_AU_MinThreshold     ("[ES] Threshold (Min)", Range(0, 1)) = 0.1
            _ES_AU_MaxThreshold     ("[ES] Threshold (Max)", Range(0, 1)) = 0.5

        [WFHeaderToggle(Dissolve)]
            _DSV_Enable             ("[DSV] Enable", Float) = 0
            _DSV_Dissolve           ("[DSV] Dissolve", Range(0, 1)) = 1.0
        [ToggleUI]
            _DSV_Invert             ("[DSV] Invert", Range(0, 1)) = 0
            _DSV_CtrlTex            ("[DSV] Control Texture (R)", 2D) = "black" {}
        [ToggleUI]
            _DSV_TexIsSRGB          ("[DSV] sRGB", Range(0, 1)) = 1
        [HDR]
            _DSV_SparkColor         ("[DSV] Spark Color", Color) = (1, 1, 1, 1)
            _DSV_SparkWidth         ("[DSV] Spark Width", Range(0, 0.2)) = 0

        [WFHeaderToggle(Fog)]
            _TFG_Enable              ("[TFG] Enable", Float) = 0
            _TFG_Color               ("[TFG] Color", Color) = (0.5, 0.5, 0.6, 1)
            _TFG_MinDist             ("[TFG] FadeOut Distance (Near)", Float) = 0.5
            _TFG_MaxDist             ("[TFG] FadeOut Distance (Far)", Float) = 0.8
            _TFG_Exponential         ("[TFG] Exponential", Range(0.5, 4.0)) = 1.0
        [WF_Vector3]
            _TFG_BaseOffset          ("[TFG] Base Offset", Vector) = (0, 0, 0, 0)
        [WF_Vector3]
            _TFG_Scale               ("[TFG] Scale", Vector) = (1, 1, 1, 0)

        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8
        [ToggleUI]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1
            _GL_ShadowCutoff        ("Shadow Cutoff Threshold", Range(0, 1)) = 0.1

        [WFHeader(Lit Advance)]
        [WF_Enum(UnlitWF.SunSourceMode)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)
        [ToggleUI]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0
        [ToggleUI]
            _GL_NCC_Enable          ("Cancel Near Clipping", Range(0, 1)) = 0

        [WFHeaderToggle(Light Bake Effects)]
            _LBE_Enable             ("[LBE] Enable", Float) = 0
            _LBE_IndirectMultiplier ("[LBE] Indirect Multiplier", Range(0, 2)) = 1
            _LBE_EmissionMultiplier ("[LBE] Emission Multiplier", Range(0, 2)) = 1
            _LBE_IndirectChroma     ("[LBE] Indirect Chroma", Range(0, 2)) = 1

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/11/06 (1.6.1)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _FallBack               ("UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "DisableBatching" = "True"
            "VRCFallback" = "UnlitTransparent"
        }

        Pass {
            Name "MAIN_BACK"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT
            ZWrite [_AL_ZWriteBack]
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #define _WF_ALPHA_FRESNEL
            #define _WF_UNTOON_POWERCAP
            #define _WF_FACE_BACK

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _NS_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local _VC_ENABLE
            #pragma shader_feature_local_fragment _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local_fragment _ _ES_AULINK_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _BKT_ENABLE
            #pragma shader_feature_local_fragment _CHM_ENABLE
            #pragma shader_feature_local_fragment _CLC_ENABLE
            #pragma shader_feature_local_fragment _DFD_ENABLE
            #pragma shader_feature_local_fragment _DSV_ENABLE
            #pragma shader_feature_local_fragment _ES_ENABLE
            #pragma shader_feature_local_fragment _TFG_ENABLE
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
            #pragma multi_compile _ _WF_EDITOR_HIDE_LMAP

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

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
            #define _WF_UNTOON_POWERCAP

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _NS_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local _VC_ENABLE
            #pragma shader_feature_local_fragment _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local_fragment _ _ES_AULINK_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _BKT_ENABLE
            #pragma shader_feature_local_fragment _CHM_ENABLE
            #pragma shader_feature_local_fragment _CLC_ENABLE
            #pragma shader_feature_local_fragment _DFD_ENABLE
            #pragma shader_feature_local_fragment _DSV_ENABLE
            #pragma shader_feature_local_fragment _ES_ENABLE
            #pragma shader_feature_local_fragment _TFG_ENABLE
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
            #pragma multi_compile _ _WF_EDITOR_HIDE_LMAP

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #include "WF_UnToon.cginc"

            ENDCG
        }

        UsePass "UnlitWF/WF_UnToon_Transparent/SHADOWCASTER"
        UsePass "UnlitWF/WF_UnToon_Transparent/META"
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
