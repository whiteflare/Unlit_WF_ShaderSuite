/*
 *  The MIT License
 *
 *  Copyright 2018-2021 whiteflare.
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
Shader "UnlitWF/WF_FakeFur_TransCutout" {

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
            _Cutoff                 ("Alpha CutOff Level", Range(0, 1)) = 0.2
        [Toggle(_)]
            _AL_AlphaToMask         ("Alpha-To-Coverage (use MSAA)", Float) = 0

        // ファー設定
        [WFHeader(Fake Fur)]
            _FR_NoiseTex            ("[FR] Fur Noise Texture", 2D) = "white" {}
            _FR_Height              ("[FR] Fur Height", Range(0, 0.2)) = 0.05
        [WF_Vector3]
            _FR_Vector              ("[FR] Fur Vector", Vector) = (0, 0, 1, 0)
        [NoScaleOffset]
        [Normal]
            _FR_BumpMap             ("[FR] NormalMap Texture", 2D) = "bump" {}
        [Enum(NONE,0,X,1,Y,2,XY,3)]
            _FR_FlipMirror          ("[FR] Flip Mirror", Float) = 0
        [IntRange]
            _FR_Repeat              ("[FR] Fur Repeat", Range(1, 6)) = 3
            _FR_ShadowPower         ("[FR] Fur ShadowPower", Range(0, 1)) = 0
        [NoScaleOffset]
            _FR_MaskTex             ("[FR] Mask Texture", 2D) = "white" {}

        // 色変換
        [WFHeaderToggle(Color Change)]
            _CL_Enable              ("[CL] Enable", Float) = 0
        [Toggle(_)]
            _CL_Monochrome          ("[CL] monochrome", Range(0, 1)) = 0
            _CL_DeltaH              ("[CL] Hur", Range(0, 1)) = 0
            _CL_DeltaS              ("[CL] Saturation", Range(-1, 1)) = 0
            _CL_DeltaV              ("[CL] Brightness", Range(-1, 1)) = 0

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
            _HL_Parallax            ("[HL] Parallax", Range(0, 1)) = 0.75
        [NoScaleOffset]
            _HL_MaskTex             ("[HL] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal          ("[HL] Invert Mask Value", Range(0, 1)) = 0
            _HL_MatcapColor         ("[HL] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        // 階調影
        [WFHeaderToggle(ToonShade)]
            _TS_Enable              ("[SH] Enable", Float) = 0
        [IntRange]
            _TS_Steps               ("[SH] Steps", Range(1, 3)) = 2
            _TS_BaseColor           ("[SH] Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _TS_BaseTex             ("[SH] Base Shade Texture", 2D) = "white" {}
            _TS_1stColor            ("[SH] 1st Shade Color", Color) = (0.7, 0.7, 0.9, 1)
        [NoScaleOffset]
            _TS_1stTex              ("[SH] 1st Shade Texture", 2D) = "white" {}
            _TS_2ndColor            ("[SH] 2nd Shade Color", Color) = (0.5, 0.5, 0.8, 1)
        [NoScaleOffset]
            _TS_2ndTex              ("[SH] 2nd Shade Texture", 2D) = "white" {}
            _TS_3rdColor            ("[SH] 3rd Shade Color", Color) = (0.5, 0.5, 0.7, 1)
        [NoScaleOffset]
            _TS_3rdTex              ("[SH] 3rd Shade Texture", 2D) = "white" {}
            _TS_Power               ("[SH] Shade Power", Range(0, 2)) = 1
            _TS_1stBorder           ("[SH] 1st Border", Range(0, 1)) = 0.4
            _TS_2ndBorder           ("[SH] 2nd Border", Range(0, 1)) = 0.2
            _TS_3rdBorder           ("[SH] 3rd Border", Range(0, 1)) = 0.1
            _TS_Feather             ("[SH] Feather", Range(0, 0.2)) = 0.05
            _TS_BlendNormal         ("[SH] Blend Normal", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _TS_MaskTex             ("[SH] Anti-Shadow Mask Texture", 2D) = "black" {}
        [Toggle(_)]
            _TS_InvMaskVal          ("[SH] Invert Mask Value", Range(0, 1)) = 0

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
            _TR_MaskTex             ("[RM] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _TR_InvMaskVal          ("[RM] Invert Mask Value", Range(0, 1)) = 0
        [Header(RimLight Advance)]
            _TR_PowerTop            ("[RM] Power Top", Range(0, 0.5)) = 0.1
            _TR_PowerSide           ("[RM] Power Side", Range(0, 0.5)) = 0.1
            _TR_PowerBottom         ("[RM] Power Bottom", Range(0, 0.5)) = 0.1

        // Lit
        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Darken (min value)", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Lighten (max value)", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Blend Light Color", Range(0, 1)) = 0.8
        [Toggle(_)]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1

        [WFHeader(Lit Advance)]
        [Enum(AUTO,0,ONLY_DIRECTIONAL_LIT,1,ONLY_POINT_LIT,2,CUSTOM_WORLDSPACE,3,CUSTOM_LOCALSPACE,4)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [Toggle(_)]
            _GL_DisableBackLit      ("Disable BackLit", Range(0, 1)) = 0
        [Toggle(_)]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2021/07/31", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _FallBack               ("UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "TransparentCutout"
            "Queue" = "AlphaTest"
            "DisableBatching" = "True"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #pragma shader_feature_local _CL_ENABLE
            #pragma shader_feature_local _HL_ENABLE
            #pragma shader_feature_local _TR_ENABLE
            #pragma shader_feature_local _TS_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "FUR"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF
            AlphaToMask [_AL_AlphaToMask]

            CGPROGRAM

            #pragma vertex vert_fakefur
            #pragma geometry geom_fakefur
            #pragma fragment frag_fakefur_cutoff

            #pragma shader_feature_local _CL_ENABLE
            #pragma shader_feature_local _TS_ENABLE

            #pragma target 5.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "WF_FakeFur.cginc"

            ENDCG
        }

        UsePass "UnlitWF/WF_UnToon_TransCutout/SHADOWCASTER"
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
