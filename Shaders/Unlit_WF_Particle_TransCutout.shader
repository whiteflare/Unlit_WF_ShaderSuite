/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2024 whiteflare.
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
Shader "UnlitWF/WF_Particle_TransCutout" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        [WFHeader(Particle System)]
        [WF_Enum(UnlitWF.BlendModeVC,MUL,ADD,SUB)]
            _PA_VCBlendType         ("[PA] Vertex Color Blend Mode", Float) = 0
        [ToggleUI]
            _PA_UseFlipBook         ("[PA] Flip-Book Frame Blending", Float) = 0
            _PA_Z_Offset            ("[PA] Z Offset", Range(-2, 2)) = 0

        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _Cutoff                 ("[AL] Cutoff Threshold", Range(0, 1)) = 0.5
        [ToggleUI]
            _AL_AlphaToMask         ("[AL] Alpha-To-Coverage (use MSAA)", Float) = 0

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
        [HideInInspector]
        [WF_FixFloat(0.0)]
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

        [WFHeaderToggle(Lit)]
            _GL_Enable              ("[GL] Enable", Float) = 0
            _GL_LevelMin            ("[GL] Unlit Intensity", Range(0, 1)) = 0.125
            _GL_LevelMax            ("[GL] Saturate Intensity", Range(0, 1)) = 0.8
        [WF_FixFloat(0.0)]
            _GL_LevelTweak          ("Tweak Intensity", Range(-1, 1)) = 0
            _GL_BlendPower          ("[GL] Chroma Reaction", Range(0, 1)) = 0.8

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2024/12/17 (2.6.1)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _VRCFallback            ("UnlitCutout", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "TransparentCutout"
            "Queue" = "AlphaTest"
            "VRCFallback" = "UnlitCutout"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
            "PerformanceChecks" = "False"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            Blend One Zero, One OneMinusSrcAlpha
            AlphaToMask [_AL_AlphaToMask]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma instancing_options procedural:vertInstancingSetup

            #pragma target 3.0

            #define _WF_ALPHA_CUTFADE
            #define _WF_MAIN_Z_SHIFT    (_PA_Z_Offset)
            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_AULINKDTEX_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
            #pragma shader_feature_local _ _ES_SCROLLGRAD_ENABLE
            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _GL_ENABLE
            #pragma shader_feature_local _PF_ENABLE

            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "WF_Particle.cginc"

            ENDCG
        }

        Pass
        {
            Name "SceneSelectionPass"
            Tags { "LightMode" = "SceneSelectionPass" }

            BlendOp Add
            Blend One Zero
            ZWrite On
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragSceneHighlightPass
            #pragma instancing_options procedural:vertInstancingSetup

            #pragma target 3.0

            #define _WF_ALPHA_CUTFADE
            #define _WF_MAIN_Z_SHIFT    (_PA_Z_Offset)
            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_AULINKDTEX_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
            #pragma shader_feature_local _ _ES_SCROLLGRAD_ENABLE
            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _PF_ENABLE

            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "WF_Particle.cginc"

            ENDCG
        }

        Pass
        {
            Name "ScenePickingPass"
            Tags{ "LightMode" = "Picking" }

            BlendOp Add
            Blend One Zero
            ZWrite On
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragScenePickingPass
            #pragma instancing_options procedural:vertInstancingSetup

            #pragma target 3.0

            #define _WF_ALPHA_CUTFADE
            #define _WF_MAIN_Z_SHIFT    (_PA_Z_Offset)
            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_AULINKDTEX_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
            #pragma shader_feature_local _ _ES_SCROLLGRAD_ENABLE
            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _PF_ENABLE

            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "WF_Particle.cginc"

            ENDCG
        }

        Pass {
            Name "SHADOWCASTER"
            Tags{ "LightMode" = "ShadowCaster" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert_shadow
            #pragma fragment frag_shadow

            #define _WF_ALPHA_CUTOUT
            #define _WF_MOBILE

            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "WF_UnToon_ShadowCaster.cginc"

            ENDCG
        }
    }

    FallBack "Unlit/Transparent Cutout"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
