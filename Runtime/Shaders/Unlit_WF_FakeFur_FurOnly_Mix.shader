﻿/*
 *  The MIT License
 *
 *  Copyright 2018-2023 whiteflare.
 *  Copyright 2021 ma1on.
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
Shader "UnlitWF/WF_FakeFur_FurOnly_Mix" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
            _Cutoff                 ("Alpha CutOff Level", Range(0, 1)) = 0.2
        [ToggleUI]
            _AL_AlphaToMask         ("Alpha-To-Coverage (use MSAA)", Float) = 0

        [WFHeader(Fake Fur)]
            _FUR_Height             ("[FUR] Fur Height (Cutout)", Range(0, 0.2)) = 0.01
            _FUR_Height2            ("[FUR] Fur Height (Transparent)", Range(0, 0.2)) = 0.02
        [IntRange]
            _FUR_Repeat             ("[FUR] Fur Repeat (Cutout)", Range(1, 6)) = 3
        [IntRange]
            _FUR_Repeat2            ("[FUR] Fur Repeat (Transparent)", Range(1, 6)) = 2
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
            _FUR_MaskTex            ("[FUR] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _FUR_InvMaskVal         ("[FUR] Invert Mask Value", Range(0, 1)) = 0

        [WFHeaderToggle(Color Change)]
            _CLC_Enable             ("[CLC] Enable", Float) = 0
        [ToggleUI]
            _CLC_Monochrome         ("[CLC] monochrome", Range(0, 1)) = 0
            _CLC_DeltaH             ("[CLC] Hur", Range(0, 1)) = 0
            _CLC_DeltaS             ("[CLC] Saturation", Range(-1, 1)) = 0
            _CLC_DeltaV             ("[CLC] Brightness", Range(-1, 1)) = 0

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

        [WFHeaderToggle(Distance Fade)]
            _DFD_Enable             ("[DFD] Enable", Float) = 0
            _DFD_Color              ("[DFD] Color", Color) = (0.1, 0.1, 0.1, 1)
            _DFD_MinDist            ("[DFD] Fade Distance (Near)", Range(0, 0.5)) = 0.02
            _DFD_MaxDist            ("[DFD] Fade Distance (Far)", Range(0, 0.5)) = 0.08
            _DFD_Power              ("[DFD] Power", Range(0, 1)) = 1
        [ToggleUI]
            _DFD_BackShadow         ("[DFD] BackFace Shadow", Float) = 1

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
        [ToggleUI]
            _GL_NCC_Enable          ("Cancel Near Clipping", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/08/27 (1.4.0)", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "DisableBatching" = "True"
            "IgnoreProjector" = "True"
            "VRCFallback" = "Hidden"
        }

        Pass {
            Name "FUR"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF
            Blend One Zero, One OneMinusSrcAlpha
            AlphaToMask [_AL_AlphaToMask]

            CGPROGRAM

            #pragma vertex vert_fakefur
            #pragma geometry geom_fakefur
            #pragma fragment frag_fakefur_cutoff

            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _CLC_ENABLE
            #pragma shader_feature_local_fragment _DFD_ENABLE
            #pragma shader_feature_local_fragment _DSV_ENABLE

            #pragma target 5.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "WF_FakeFur.cginc"

            ENDCG
        }

        Pass {
            Name "FUR2"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert_fakefur
            #pragma geometry geom_fakefur
            #pragma fragment frag_fakefur

            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _CLC_ENABLE
            #pragma shader_feature_local_fragment _DFD_ENABLE
            #pragma shader_feature_local_fragment _DSV_ENABLE

            #define _FUR_HEIGHT_PARAM _FUR_Height2
            #define _FUR_REPEAT_PARAM _FUR_Repeat2

            #pragma target 5.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "WF_FakeFur.cginc"

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack "Hidden/UnlitWF/WF_UnToon_Hidden"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
