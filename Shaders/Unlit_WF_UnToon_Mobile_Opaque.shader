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
Shader "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque" {

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2
        [Toggle(_)]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        // 法線マップ
        [WFHeaderToggle(NormalMap)]
            _NM_Enable              ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap                ("[NM] NormalMap Texture", 2D) = "bump" {}
            _BumpScale              ("[NM] Bump Scale", Range(0, 2)) = 1.0
            _NM_Power               ("[NM] Shadow Power", Range(0, 1)) = 0.25
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FlipMirror             ("[NM] Flip Mirror", Float) = 0

        // メタリックマップ
        [WFHeaderToggle(Metallic)]
            _MT_Enable              ("[MT] Enable", Float) = 0
            _MT_Metallic            ("[MT] Metallic", Range(0, 1)) = 1
            _MT_ReflSmooth          ("[MT] Smoothness", Range(0, 1)) = 1
            _MT_Brightness          ("[MT] Brightness", Range(0, 1)) = 0.2
            _MT_BlendNormal         ("[MT] Blend Normal", Range(0, 1)) = 0.1
            _MT_Monochrome          ("[MT] Monochrome Reflection", Range(0, 1)) = 0
        [Toggle(_)]
            _MT_GeomSpecAA          ("[MT] Geometric Specular AA", Range(0, 1)) = 1
        [Enum(MASK,0,METALLIC,1)]
            _MT_MetallicMapType     ("[MT] MetallicMap Type", Float) = 0
        [NoScaleOffset]
            _MetallicGlossMap       ("[MT] MetallicSmoothnessMap Texture", 2D) = "white" {}
        [Toggle(_)]
            _MT_InvMaskVal          ("[MT] Invert Mask Value", Range(0, 1)) = 0

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
        [NoScaleOffset]
            _HL_MaskTex             ("[HL] Mask Texture (RGB)", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal          ("[HL] Invert Mask Value", Range(0, 1)) = 0
        [Header(Matcap Advance)]
            _HL_Parallax            ("[HL] Parallax", Range(0, 1)) = 0.75
            _HL_MatcapMonochrome    ("[HL] Matcap Monochrome", Range(0, 1)) = 0
            _HL_MatcapColor         ("[HL] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        // 階調影
        [WFHeaderToggle(ToonShade)]
            _TS_Enable              ("[SH] Enable", Float) = 0
        [IntRange]
            _TS_Steps               ("[SH] Steps", Range(1, 3)) = 2
            _TS_BaseColor           ("[SH] Base Color", Color) = (1, 1, 1, 1)
            _TS_1stColor            ("[SH] 1st Shade Color", Color) = (0.81, 0.81, 0.9, 1)
            _TS_2ndColor            ("[SH] 2nd Shade Color", Color) = (0.68, 0.68, 0.8, 1)
            _TS_3rdColor            ("[SH] 3rd Shade Color", Color) = (0.595, 0.595, 0.7, 1)
            _TS_Power               ("[SH] Shade Power", Range(0, 2)) = 1
        [Toggle(_)]
            _TS_FixContrast         ("[SH] Dont Ajust Contrast", Range(0, 1)) = 0
            _TS_BlendNormal         ("[SH] Blend Normal", Range(0, 1)) = 0.1
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
        [Enum(WORLD_SPACE,0,LOCAL_SPACE,1,UV1,2,UV2,3)]
            _ES_DirType             ("[ES] Direction Type", Float) = 0
        [WF_Vector3]
            _ES_Direction           ("[ES] Direction", Vector) = (0, -10, 0, 0)
            _ES_LevelOffset         ("[ES] LevelOffset", Range(-1, 1)) = 0
            _ES_Sharpness           ("[ES] Sharpness", Range(0, 4)) = 1
            _ES_Speed               ("[ES] ScrollSpeed", Range(0, 8)) = 2

        // Lit
        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8

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
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "VRCFallback" = "Unlit"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _MT_ONLY2ND_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _ES_ENABLE
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

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE SHADOWS_SHADOWMASK

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature_local _VC_ENABLE

            #pragma shader_feature EDITOR_VISUALIZATION

            #include "WF_UnToon_Meta.cginc"

            ENDCG
        }
    }

    FallBack "Unlit/Texture"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
