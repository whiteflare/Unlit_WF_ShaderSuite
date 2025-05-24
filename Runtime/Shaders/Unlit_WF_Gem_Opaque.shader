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
Shader "UnlitWF/WF_Gem_Opaque" {

    Properties {
        [WFHeader(Gem Surface)]
        [HDR]
            _Color                  ("Color", Color) = (0.8, 0.4, 0.4, 1)
            _MainTex                ("Main Texture", 2D) = "white" {}
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

        [WFHeaderToggle(NormalMap)]
            _NM_Enable              ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap                ("[NM] NormalMap Texture", 2D) = "bump" {}
        [ToggleUI]
            _NM_InvConvex           ("[NM] Use DirectX NormalMap", Float) = 0
            _BumpScale              ("[NM] Bump Scale", Range(-1, 2)) = 1.0
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FlipMirror             ("[NM] Flip Mirror", Float) = 0

        [WFHeaderToggle(Emission)]
            _ES_Enable              ("[ES] Enable", Float) = 0
        [HDR]
            _EmissionColor          ("[ES] Emission", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _EmissionMap            ("[ES] Emission Texture", 2D) = "white" {}
        [ToggleUI]
            _ES_TintBaseCol         ("[ES] Tint Base Color", Range(0, 1)) = 0
        [WF_Enum(UnlitWF.BlendModeES,ADD,ALPHA,LEGACY_ALPHA)]
            _ES_BlendType           ("[ES] Blend Type", Float) = 0

        [Header(Emissive Scroll)]
        [ToggleUI]
            _ES_ScrollEnable        ("[ES] Enable EmissiveScroll", Float) = 0
        [Enum(WORLD_SPACE,0,LOCAL_SPACE,1,UV,2)]
            _ES_SC_DirType          ("[ES] Direction Type", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _ES_SC_UVType           ("[ES] UV Type", Float) = 0
        [WF_Vector3]
            _ES_SC_Direction        ("[ES] Direction", Vector) = (0, -10, 0, 0)
        [WF_Enum(UnlitWF.EmissiveScrollMode,STANDARD,SAWTOOTH,SIN_WAVE,CUSTOM)]
            _ES_SC_Shape            ("[ES] Wave Type", Float) = 0
            _ES_SC_LevelOffset      ("[ES] LevelOffset", Range(-1, 1)) = 0
            _ES_SC_Sharpness        ("[ES] Sharpness", Range(0, 4)) = 1
        [NoScaleOffset]
            _ES_SC_GradTex          ("[ES] Wave Grad Tex", 2D) = "white" {}
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
        [Enum(NONE,0,UV1_X,1,UV1_Y,2,UV2_X,3,UV2_Y,4,UV1_TEX,5)]
            _ES_AU_DelayDir         ("[ES] Delay Direction", Float) = 0
        [NoScaleOffset]
            _ES_AU_DelayTex         ("[ES] Delay Control Texture (R)", 2D) = "black" {}
        [ToggleUI]
            _ES_AU_DelayReverse     ("[ES] Delay Reverse", Float) = 0
            _ES_AU_DelayHistory     ("[ES] Delay Length", Range(0,128)) = 32

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
        [ToggleUI]
            _GL_NCC_Enable          ("Cancel Near Clipping", Range(0, 1)) = 0
        [ToggleUI]
            _GL_ULV_Enable          ("Use VRC LightVolumes", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2025/03/23 (2.8.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _FallBack               ("UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _VRCFallback            ("Unlit", Float) = 0
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
            #pragma fragment frag_gem_front

            #pragma target 3.0

            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_AULINKDTEX_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
            #pragma shader_feature_local _ _ES_SCROLLGRAD_ENABLE
            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _DSV_ENABLE
            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local _GL_ULV_ENABLE
            #pragma shader_feature_local _NM_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #include "WF_Gem.cginc"

            ENDCG
        }
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
