/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
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
Shader "UnlitWF/WF_Particle_Transparent" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        [WFHeader(Particle System)]
        [WF_Enum(UnlitWF.BlendModeVC,MUL,ADD,SUB,OVERLAY,COLOR,DIFFERENCE)]
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
            _AL_Power               ("[AL] Power", Range(0, 2)) = 1.0
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite              ("[AL] ZWrite", int) = 0

        [WFHeaderToggle(Emission)]
            _ES_Enable              ("[ES] Enable", Float) = 0
        [HDR]
            _EmissionColor          ("[ES] Emission", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _EmissionMap            ("[ES] Emission Texture", 2D) = "white" {}
        [WF_Enum(UnlitWF.BlendModeES,ADD,ALPHA,LEGACY_ALPHA)]
            _ES_BlendType           ("[ES] Blend Type", Float) = 0
        [ToggleUI]
            _ES_ChangeAlpha         ("[ES] Change Alpha Transparency", Range(0, 1)) = 0

        [Header(Emissive Scroll)]
        [ToggleUI]
            _ES_ScrollEnable        ("[ES] Enable EmissiveScroll", Float) = 0
        [Enum(STANDARD,0,SAWTOOTH,1,SIN_WAVE,2)]
            _ES_SC_Shape            ("[ES] Wave Type", Float) = 0
        [ToggleUI]
            _ES_SC_AlphaScroll      ("[ES] Change Alpha Transparency", Range(0, 1)) = 0
        [Enum(WORLD_SPACE,0,LOCAL_SPACE,1,UV,2)]
            _ES_SC_DirType          ("[ES] Direction Type", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
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

        [WFHeaderToggle(Lit)]
            _GL_Enable              ("[GL] Enable", Float) = 0
        [Gamma]
            _GL_LevelMin            ("[GL] Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("[GL] Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("[GL] Chroma Reaction", Range(0, 1)) = 0.8

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2024/01/01 (1.8.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _VRCFallback            ("UnlitTransparent", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "VRCFallback" = "UnlitTransparent"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
            "PerformanceChecks" = "False"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite [_AL_ZWrite]
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma instancing_options procedural:vertInstancingSetup

            #pragma target 3.0

            #define _WF_ALPHA_BLEND
            #define _WF_MAIN_Z_SHIFT    (_PA_Z_Offset)
            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
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

            #define _WF_ALPHA_BLEND
            #define _WF_MAIN_Z_SHIFT    (_PA_Z_Offset)
            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
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

            #define _WF_ALPHA_BLEND
            #define _WF_MAIN_Z_SHIFT    (_PA_Z_Offset)
            #define _WF_MOBILE

            #pragma shader_feature_local _ _ES_SCROLL_ENABLE
            #pragma shader_feature_local _ _ES_AULINK_ENABLE
            #pragma shader_feature_local _ES_ENABLE
            #pragma shader_feature_local _PF_ENABLE

            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "WF_Particle.cginc"

            ENDCG
        }
    }

    FallBack "Unlit/Transparent"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
