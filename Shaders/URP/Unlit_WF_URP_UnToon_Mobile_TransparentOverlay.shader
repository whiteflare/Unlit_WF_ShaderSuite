/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2025 whiteflare.
 *
 *  This software is provided ‘as-is’, without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
 */
Shader "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_TransparentOverlay" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Enum(UnityEngine.Rendering.CullMode)]
            _CullMode               ("Cull Mode", int) = 0
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
            _AL_PowerMin            ("[AL] Power(Min)", Range(0, 2)) = 0
            _AL_Fresnel             ("[AL] Fresnel Power", Range(0, 2)) = 0
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite              ("[AL] ZWrite", int) = 0

        [Header(Transparent Detail)]
        [Enum(UnityEngine.Rendering.CompareFunction)]
            _AL_ZTest               ("[AL] Z Test", Float) = 4
        [Enum(UnityEngine.Rendering.BlendMode)]
            _AL_SrcAlpha            ("[AL] Blend Src Alpha", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
            _AL_DstAlpha            ("[AL] Blend Dst Alpha", Float) = 10
            _AL_Z_Offset            ("[AL] Z Offset", Range(-2, 2)) = 0

        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable              ("[AO] Enable", Float) = 0
        [WF_FixUIToggle(1.0)]
            _AO_UseLightMap         ("[AO] Use LightMap", Float) = 1
            _AO_Contrast            ("[AO] Contrast", Range(0, 2)) = 1
            _AO_Brightness          ("[AO] Brightness", Range(-1, 1)) = 0

        [WFHeader(Lit)]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
        [WF_FixFloat(0.0)]
            _GL_LevelTweak          ("Tweak Intensity", Range(-1, 1)) = 0
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8

        [WFHeader(Lit Advance)]
        [WF_Enum(UnlitWF.SunSourceMode)]
            _GL_LightMode           ("Sun Source", Float) = 0
        [WF_FixFloat(0.0)]
            _GL_LitOverride         ("Light Direction Override", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)
        [ToggleUI]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0

        [WFHeaderToggle(Light Bake Effects)]
            _LBE_Enable             ("[LBE] Enable", Float) = 0
            _LBE_IndirectMultiplier ("[LBE] Indirect Multiplier", Range(0, 2)) = 1
            _LBE_EmissionMultiplier ("[LBE] Emission Multiplier", Range(0, 2)) = 1
            _LBE_IndirectChroma     ("[LBE] Indirect Chroma", Range(0, 2)) = 1

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2025/01/28 (2.7.0)", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Overlay"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "UniversalForward" }

            Cull [_CullMode]
            ZTest [_AL_ZTest]
            ZWrite [_AL_ZWrite]
            Blend [_AL_SrcAlpha] [_AL_DstAlpha], One OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #define _WF_ALPHA_FRESNEL
            #define _WF_AO_ONLY_LMAP
            #define _WF_MAIN_Z_SHIFT    (_AL_Z_Offset)
            #define _WF_MOBILE
            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile _ _WF_EDITOR_HIDE_LMAP

            // -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            #pragma multi_compile_instancing

            #include "../WF_INPUT_UnToon.cginc"
            #include "../WF_UnToon.cginc"

            ENDHLSL
        }

        Pass {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            Cull [_CullMode]
            ZTest [_AL_ZTest]
            ZWrite [_AL_ZWrite]
            ColorMask 0

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert
            #pragma fragment frag_depth

            #define _WF_ALPHA_BLEND
            #define _WF_MAIN_Z_SHIFT    (_AL_Z_Offset)
            #define _WF_MOBILE
            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_instancing

            #include "../WF_INPUT_UnToon.cginc"
            #include "../WF_UnToon.cginc"

            ENDHLSL
        }

        Pass {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            Cull [_CullMode]
            ZTest [_AL_ZTest]
            ZWrite [_AL_ZWrite]

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert
            #pragma fragment frag_depth

            #define _WF_ALPHA_BLEND
            #define _WF_MAIN_Z_SHIFT    (_AL_Z_Offset)
            #define _WF_MOBILE
            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_instancing

            #include "../WF_INPUT_UnToon.cginc"
            #include "../WF_UnToon.cginc"

            ENDHLSL
        }

        Pass {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #define _WF_ALPHA_BLEND
            #define _WF_MOBILE
            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _VC_ENABLE

            #include "../WF_INPUT_UnToon.cginc"
            #include "WF_UnToonURP_Meta.cginc"

            ENDHLSL
        }
    }

    FallBack "Hidden/InternalErrorShader"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
