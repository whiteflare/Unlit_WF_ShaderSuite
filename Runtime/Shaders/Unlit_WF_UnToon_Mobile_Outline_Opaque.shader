﻿/*
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
Shader "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Outline_Opaque" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2
        [ToggleUI]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        [WFHeaderAlwaysOn(Outline)]
            _TL_Enable              ("[TL] Enable", Float) = 1
            _TL_LineColor           ("[TL] Line Color", Color) = (0.1, 0.1, 0.1, 1)
        [NoScaleOffset]
            _TL_CustomColorTex      ("[TL] Custom Color Texture", 2D) = "white" {}
            _TL_LineWidth           ("[TL] Line Width", Range(0, 1)) = 0.05
            _TL_BlendCustom         ("[TL] Blend Custom Color Texture", Range(0, 1)) = 0
            _TL_BlendBase           ("[TL] Blend Base Color", Range(0, 1)) = 0
        [NoScaleOffset]
            _TL_MaskTex             ("[TL] Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _TL_InvMaskVal          ("[TL] Invert Mask Value", Float) = 0
            _TL_Z_Shift             ("[TL] Z-shift (tweak)", Range(-0.1, 0.5)) = 0

        [WFHeaderToggle(NormalMap)]
            _NM_Enable              ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap                ("[NM] NormalMap Texture", 2D) = "bump" {}
            _BumpScale              ("[NM] Bump Scale", Range(0, 2)) = 1.0
            _NM_Power               ("[NM] Shadow Power", Range(0, 1)) = 0.25
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FlipMirror             ("[NM] Flip Mirror", Float) = 0

        [WFHeaderToggle(Metallic)]
            _MT_Enable              ("[MT] Enable", Float) = 0
            _MT_Metallic            ("[MT] Metallic", Range(0, 1)) = 1
            _MT_ReflSmooth          ("[MT] Smoothness", Range(0, 1)) = 1
            _MT_Brightness          ("[MT] Brightness", Range(0, 1)) = 0.2
            _MT_BlendNormal         ("[MT] Blend Normal", Range(0, 1)) = 0.1
            _MT_Monochrome          ("[MT] Monochrome Reflection", Range(0, 1)) = 0
        [ToggleUI]
            _MT_GeomSpecAA          ("[MT] Geometric Specular AA", Range(0, 1)) = 1
        [Enum(MASK,0,METALLIC,1)]
            _MT_MetallicMapType     ("[MT] MetallicMap Type", Float) = 0
        [NoScaleOffset]
            _MetallicGlossMap       ("[MT] MetallicSmoothnessMap Texture", 2D) = "white" {}
        [ToggleUI]
            _MT_InvMaskVal          ("[MT] Invert Mask Value", Range(0, 1)) = 0
        [NoScaleOffset]
            _SpecGlossMap           ("[MT] RoughnessMap Texture", 2D) = "black" {}
        [ToggleUI]
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

        [WFHeaderToggle(Light Matcap)]
            _HL_Enable              ("[HL] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType             ("[HL] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex           ("[HL] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor         ("[HL] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power               ("[HL] Power", Range(0, 2)) = 1
            _HL_BlendNormal         ("[HL] Blend Normal", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _HL_MaskTex             ("[HL] Mask Texture (RGB)", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal          ("[HL] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax            ("[HL] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome    ("[HL] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor         ("[HL] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(ToonShade)]
            _TS_Enable              ("[TS] Enable", Float) = 0
        [IntRange]
            _TS_Steps               ("[TS] Steps", Range(1, 3)) = 2
            _TS_BaseColor           ("[TS] Base Color", Color) = (1, 1, 1, 1)
            _TS_1stColor            ("[TS] 1st Shade Color", Color) = (0.81, 0.81, 0.9, 1)
            _TS_2ndColor            ("[TS] 2nd Shade Color", Color) = (0.68, 0.68, 0.8, 1)
            _TS_3rdColor            ("[TS] 3rd Shade Color", Color) = (0.595, 0.595, 0.7, 1)
            _TS_Power               ("[TS] Shade Power", Range(0, 2)) = 1
            _TS_MinDist             ("[TS] FadeOut Distance (Near)", Range(0, 15)) = 1.0
            _TS_MaxDist             ("[TS] FadeOut Distance (Far)", Range(0, 15)) = 4.0
        [ToggleUI]
            _TS_FixContrast         ("[TS] Dont Ajust Contrast", Range(0, 1)) = 0
            _TS_BlendNormal         ("[TS] Blend Normal", Range(0, 1)) = 0.1
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

        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable              ("[AO] Enable", Float) = 0
        [WF_FixUIToggle(1.0)]
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
            _ES_AU_BlackOut         ("[ES] Dont Emit when AudioLink is disabled", Range(0, 1)) = 0
        [Enum(TREBLE,3,HIGH_MIDS,2,LOW_MIDS,1,BASS,0)]
            _ES_AU_Band             ("[ES] Band", Float) = 0
            _ES_AU_Slope            ("[ES] Slope", Range(0, 1)) = 0.2
            _ES_AU_MinThreshold     ("[ES] Threshold (Min)", Range(0, 1)) = 0.1
            _ES_AU_MaxThreshold     ("[ES] Threshold (Max)", Range(0, 1)) = 0.5

        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8
        [ToggleUI]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1

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
            _CurrentVersion         ("2023/08/27 (1.4.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "VRCFallback" = "Unlit"
        }

        Pass {
            Name "OUTLINE"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT

            CGPROGRAM

            #pragma vertex vert_outline
            #pragma fragment frag

            #pragma target 3.0

            #define _WF_MOBILE

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local _TL_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #define _WF_AO_ONLY_LMAP
            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _MT_NORHMAP_ENABLE
            #pragma shader_feature_local _ _MT_ONLY2ND_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local _HL_ENABLE
            #pragma shader_feature_local _MT_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _TR_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local _VC_ENABLE

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
            Name "SHADOWCASTER"
            Tags{ "LightMode" = "ShadowCaster" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert_shadow
            #pragma fragment frag_shadow

            #define _GL_NCC_ENABLE

            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "WF_UnToon_ShadowCaster.cginc"

            ENDCG
        }

        Pass {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #define _WF_MOBILE

            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma shader_feature EDITOR_VISUALIZATION

            #include "WF_UnToon_Meta.cginc"

            ENDCG
        }
    }

    FallBack "Unlit/Texture"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
