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
Shader "UnlitWF/Custom/WF_UnToon_Custom_Transparent_FrostedGlass" {

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Toggle(_)]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        // Alpha
        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _AL_Power               ("[AL] Power", Range(0, 2)) = 1.0
            _AL_Fresnel             ("[AL] Fresnel Power", Range(0, 2)) = 0

        // すりガラス
        [WFHeaderAlwaysOn(FrostedGlass)]
            _GS_Enable              ("[GS] Enable", Float) = 1
            _GS_Blur                ("[GS] Blur", Range(0, 2)) = 0.4
        [Enum(NORMAL,0,FAST,1)]
            _GS_BlurMode            ("[GS] Blur Mode", Float) = 0

        // 裏面テクスチャ
        [WFHeaderToggle(BackFace Texture)]
            _BK_Enable              ("[BK] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _BK_UVType              ("[BK] UV Type", Float) = 0
            _BK_BackTex             ("[BK] Back Texture", 2D) = "white" {}
        [HDR]
            _BK_BackColor           ("[BK] Back Color", Color) = (1, 1, 1, 1)

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
            "RenderType" = "Opaque"
            "Queue" = "Overlay-100"
            "VRCFallback" = "UnlitTransparent"
        }

        GrabPass { "_UnToonFrostedGlass" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite ON

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #define _WF_ALPHA_FRESNEL

            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _NS_ENABLE
            #pragma shader_feature_local _OL_ENABLE
            #pragma shader_feature_local _VC_ENABLE
            #pragma shader_feature_local_fragment _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local_fragment _ _MT_ONLY2ND_ENABLE
            #pragma shader_feature_local_fragment _BK_ENABLE
            #pragma shader_feature_local_fragment _ES_ENABLE
            #pragma shader_feature_local_fragment _GS_ENABLE
            #pragma shader_feature_local_fragment _LM_ENABLE
            #pragma shader_feature_local_fragment _MT_ENABLE
            #pragma shader_feature_local_fragment _ _GS_BLURFAST_ENABLE

            #define _GS_GRAB_TEXTURE _UnToonFrostedGlass

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "SHADOWCASTER"
            Tags{ "LightMode" = "ShadowCaster" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert_shadow
            #pragma fragment frag_shadow

            #define _WF_ALPHA_BLEND

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

            #define _WF_ALPHA_BLEND

            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma shader_feature EDITOR_VISUALIZATION

            #include "WF_UnToon_Meta.cginc"

            ENDCG
        }
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
