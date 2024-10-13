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
Shader "UnlitWF_URP/WF_FakeFur_FurOnly_TransCutout" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
            _Cutoff                 ("Alpha CutOff Level", Range(0, 1)) = 0.2
        [ToggleUI]
            _AL_AlphaToMask         ("Alpha-To-Coverage (use MSAA)", Float) = 0

        [WFHeader(Fake Fur)]
            _FUR_Height             ("[FUR] Fur Height", Range(0, 0.2)) = 0.02
        [IntRange]
            _FUR_Repeat             ("[FUR] Fur Repeat", Range(1, 6)) = 3

        [Header(Fur Shape)]
            _FUR_NoiseTex           ("[FUR] Fur Noise Texture", 2D) = "white" {}
        [WF_Vector3]
            _FUR_Vector             ("[FUR] Fur Vector", Vector) = (0, 0, 1, 0)
            _FUR_Random             ("[FUR] Fur Vector Randomize", Range(0, 5)) = 0
        [NoScaleOffset]
        [Normal]
            _FUR_BumpMap            ("[FUR] NormalMap Texture", 2D) = "bump" {}
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FlipMirror             ("[FUR] Flip Mirror", Float) = 0

        [Header(Fur Color)]
            _FUR_ShadowPower        ("[FUR] Fur ShadowPower", Range(0, 1)) = 0
            _FUR_TintColorBase      ("[FUR] Tint Color (Base)", Color) = (1, 1, 1, 1)
            _FUR_TintColorTip       ("[FUR] Tint Color (Tip)", Color) = (1, 1, 1, 1)

        [Header(Fur Mask Texture)]
        [NoScaleOffset]
            _FUR_LenMaskTex         ("[FUR] Length Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _FUR_InvLenMaskVal      ("[FUR] Invert Mask Value", Range(0, 1)) = 0
        [NoScaleOffset]
            _FUR_MaskTex            ("[FUR] Alpha Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _FUR_InvMaskVal         ("[FUR] Invert Mask Value", Range(0, 1)) = 0

        [WFHeaderToggle(Gradient Map)]
            _CGR_Enable             ("[CGR] Enable", Float) = 0
        [NoScaleOffset]
            _CGR_GradMapTex         ("[CGR] Gradient Map", 2D) = "white" {}
        [NoScaleOffset]
            _CGR_MaskTex            ("[CGR] Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _CGR_InvMaskVal         ("[CGR] Invert Mask Value", Range(0, 1)) = 0

        [WFHeaderToggle(Color Change)]
            _CLC_Enable             ("[CLC] Enable", Float) = 0
        [ToggleUI]
            _CLC_Monochrome         ("[CLC] monochrome", Range(0, 1)) = 0
            _CLC_DeltaH             ("[CLC] Hur", Range(0, 1)) = 0
            _CLC_DeltaS             ("[CLC] Saturation", Range(-1, 1)) = 0
            _CLC_DeltaV             ("[CLC] Brightness", Range(-1, 1)) = 0
        [PowerSlider(2.0)]
            _CLC_Gamma              ("[CLC] Gamma", Range(0, 4)) = 1
        [NoScaleOffset]
            _CLC_MaskTex            ("[CLC] Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _CLC_InvMaskVal         ("[CLC] Invert Mask Value", Range(0, 1)) = 0

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

        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8

        [WFHeader(Lit Advance)]
        [WF_Enum(UnlitWF.SunSourceMode)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)
        [ToggleUI]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2024/10/14 (2.4.0)", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "TransparentCutout"
            "Queue" = "AlphaTest"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass {
            Name "FUR"
            Tags { "LightMode" = "UniversalForward" }

            Cull OFF
            Blend One Zero, One OneMinusSrcAlpha
            AlphaToMask [_AL_AlphaToMask]

            HLSLPROGRAM

            #pragma exclude_renderers d3d11_9x gles

            #pragma vertex vert_fakefur
            #pragma geometry geom_fakefur
            #pragma fragment frag_fakefur_cutoff

            #pragma target 5.0

            #define _WF_PLATFORM_LWRP

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local _CGR_ENABLE
            #pragma shader_feature_local _CLC_ENABLE
            #pragma shader_feature_local _TS_ENABLE

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

            //--------------------------------------
            #pragma multi_compile_instancing

            #include "../WF_INPUT_FakeFur.cginc"
            #include "../WF_FakeFur.cginc"

            ENDHLSL
        }
    }

    FallBack "Hidden/InternalErrorShader"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
