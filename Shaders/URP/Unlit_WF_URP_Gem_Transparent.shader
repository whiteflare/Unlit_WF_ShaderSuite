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
Shader "UnlitWF_URP/WF_Gem_Transparent" {

    Properties {
        [WFHeader(Gem Surface)]
        [HDR]
            _Color                  ("Color", Color) = (0.8, 0.4, 0.4, 1)
            _MainTex                ("Main Texture", 2D) = "white" {}
            _AlphaFront             ("Transparency (front)", Range(0, 1)) = 0.5
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2
        [ToggleUI]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        [WFHeaderToggle(Gem Flake)]
            _GMF_Enable             ("[GMF] Enable", Float) = 1
        [PowerSlider(2.0)]
            _GMF_FlakeSizeFront     ("[GMF] Flake Size (front)", Range(0, 1)) = 0.1
            _GMF_FlakeShear         ("[GMF] Shear", Range(0, 1)) = 0.5
            _GMF_FlakeBrighten      ("[GMF] Brighten", Range(0, 8)) = 2
            _GMF_FlakeDarken        ("[GMF] Darken", Range(0, 8)) = 0.5
            _GMF_Twinkle            ("[GMF] Twinkle", Range(0, 4)) = 2
            _GMF_BlendNormal        ("[GMF] Blend Normal", Range(0, 1)) = 0.1

        [WFHeaderToggle(Gem Reflection)]
            _GMR_Enable             ("[GMR] Enable", Float) = 1
            _GMR_Power              ("[GMR] Blend Power", Range(0, 1)) = 1
        [NoScaleOffset]
            _GMR_Cubemap            ("[GMR] CubeMap", Cube) = "" {}
            _GMR_Brightness         ("[GMR] Brightness", Range(0, 1)) = 0
            _GMR_Monochrome         ("[GMR] Monochrome Reflection", Range(0, 1)) = 1
            _GMR_CubemapPower       ("[GMR] 2nd CubeMap Power", Range(0, 2)) = 1
            _GMR_CubemapHighCut     ("[GMR] 2nd CubeMap Hi-Cut Filter", Range(0, 1)) = 0
            _GMR_BlendNormal        ("[GMR] Blend Normal", Range(0, 1)) = 0.1

        [WFHeader(Transparent Alpha)]
        [WF_FixNoTexture]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _AL_Power               ("[AL] Power", Range(0, 2)) = 0.8
            _AL_PowerMin            ("[AL] Power(Min)", Range(0, 2)) = 0
            _AL_Fresnel             ("[AL] Fresnel Power", Range(0, 2)) = 1
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite              ("[AL] ZWrite", int) = 0

        [WFHeaderToggle(NormalMap)]
            _NM_Enable              ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap                ("[NM] NormalMap Texture", 2D) = "bump" {}
        [ToggleUI]
            _NM_InvConvex           ("[NM] Use DirectX NormalMap", Float) = 0
            _BumpScale              ("[NM] Bump Scale", Range(-1, 2)) = 1.0
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FlipMirror             ("[NM] Flip Mirror", Float) = 0

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

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2025/08/16 (2.10.1)", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "UniversalForwardOnly" }

            Cull [_CullMode]
            ZWrite [_AL_ZWrite]
            Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert
            #pragma fragment frag_gem_front

            #pragma target 3.0

            #define _WF_ALPHA_FRESNEL
            #define _WF_MOBILE
            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _VC_ENABLE

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

            #include "../WF_INPUT_Gem.cginc"
            #include "../WF_Gem.cginc"

            ENDHLSL
        }

        Pass {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            Cull[_CullMode]
            ZWrite [_AL_ZWrite]
            ColorMask 0

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert
            #pragma fragment frag_depth

            #define _WF_ALPHA_BLEND
            #define _WF_MOBILE
            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_instancing

            #include "../WF_INPUT_Gem.cginc"
            #include "../WF_UnToon.cginc"

            ENDHLSL
        }

        Pass {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormalsOnly"}

            Cull[_CullMode]
            ZWrite [_AL_ZWrite]

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert
            #pragma fragment frag_depth

            #define _WF_MOBILE
            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_instancing

            #include "../WF_INPUT_Gem.cginc"
            #include "../WF_UnToon.cginc"

            ENDHLSL
        }
    }

    FallBack "Hidden/InternalErrorShader"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
