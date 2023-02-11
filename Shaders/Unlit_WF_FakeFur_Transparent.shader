/*
 *  The MIT License
 *
 *  Copyright 2018-2023 whiteflare.
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
Shader "UnlitWF/WF_FakeFur_Transparent" {

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)

        // ファー設定
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
            _FUR_MaskTex            ("[FUR] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _FUR_InvMaskVal         ("[FUR] Invert Mask Value", Range(0, 1)) = 0

        // 色変換
        [WFHeaderToggle(Color Change)]
            _CLC_Enable             ("[CLC] Enable", Float) = 0
        [ToggleUI]
            _CLC_Monochrome         ("[CLC] monochrome", Range(0, 1)) = 0
            _CLC_DeltaH             ("[CLC] Hur", Range(0, 1)) = 0
            _CLC_DeltaS             ("[CLC] Saturation", Range(-1, 1)) = 0
            _CLC_DeltaV             ("[CLC] Brightness", Range(-1, 1)) = 0

        // Matcapハイライト
        [WFHeaderToggle(Light Matcap)]
            _HL_Enable              ("[HL] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType             ("[HL] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex           ("[HL] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor         ("[HL] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power               ("[HL] Power", Range(0, 2)) = 1
            _HL_Parallax            ("[HL] Parallax", Range(0, 1)) = 0.75
        [NoScaleOffset]
            _HL_MaskTex             ("[HL] Mask Texture (RGB)", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal          ("[HL] Invert Mask Value", Range(0, 1)) = 0
            _HL_MatcapColor         ("[HL] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        [WFHeaderToggle(Light Matcap 2)]
            _HL_Enable_1            ("[HA] Enable", Float) = 0
        [WF_Enum(UnlitWF.BlendModeHL)]
            _HL_CapType_1           ("[HA] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex_1         ("[HA] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor_1       ("[HA] Matcap Base Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power_1             ("[HA] Power", Range(0, 2)) = 1
            _HL_Parallax_1          ("[HA] Parallax", Range(0, 1)) = 0.75
        [NoScaleOffset]
            _HL_MaskTex_1           ("[HA] Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _HL_InvMaskVal_1        ("[HA] Invert Mask Value", Range(0, 1)) = 0
            _HL_MatcapColor_1       ("[HA] Matcap Tint Color", Color) = (0.5, 0.5, 0.5, 1)

        // 階調影
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

        // リムライト
        [WFHeaderToggle(RimLight)]
            _TR_Enable              ("[TR] Enable", Float) = 0
        [HDR]
            _TR_Color               ("[TR] Rim Color", Color) = (0.8, 0.8, 0.8, 1)
        [WF_Enum(UnlitWF.BlendModeTR,ADD,ALPHA,ADD_AND_SUB)]
            _TR_BlendType           ("[TR] Blend Type", Float) = 0
            _TR_Power               ("[TR] Power", Range(0, 2)) = 1
            _TR_Feather             ("[TR] Feather", Range(0, 0.2)) = 0.05
        [NoScaleOffset]
            _TR_MaskTex             ("[TR] Mask Texture (RGB)", 2D) = "white" {}
        [ToggleUI]
            _TR_InvMaskVal          ("[TR] Invert Mask Value", Range(0, 1)) = 0
        [Header(RimLight Advance)]
            _TR_PowerTop            ("[TR] Power Top", Range(0, 0.5)) = 0.05
            _TR_PowerSide           ("[TR] Power Side", Range(0, 0.5)) = 0.1
            _TR_PowerBottom         ("[TR] Power Bottom", Range(0, 0.5)) = 0.1

        // Distance Fade
        [WFHeaderToggle(Distance Fade)]
            _DFD_Enable             ("[DFD] Enable", Float) = 0
            _DFD_Color              ("[DFD] Color", Color) = (0.1, 0.1, 0.1, 1)
            _DFD_MinDist            ("[DFD] Fade Distance (Near)", Range(0, 0.5)) = 0.02
            _DFD_MaxDist            ("[DFD] Fade Distance (Far)", Range(0, 0.5)) = 0.08
            _DFD_Power              ("[DFD] Power", Range(0, 1)) = 1
        [ToggleUI]
            _DFD_BackShadow         ("[DFD] BackFace Shadow", Float) = 1

        // Dissolve
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

        // Lit
        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8
        [ToggleUI]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1

        [WFHeader(Lit Advance)]
        [WF_Enum(UnlitWF.SunSourceMode)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)
        [ToggleUI]
            _GL_DisableBackLit      ("Disable BackLit", Range(0, 1)) = 0
        [ToggleUI]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/02/04", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _FallBack               ("UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "DisableBatching" = "True"
            "VRCFallback" = "UnlitCutout"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #pragma shader_feature_local _ _TS_FIXC_ENABLE
            #pragma shader_feature_local _TS_ENABLE
            #pragma shader_feature_local_fragment _ _TS_STEP1_ENABLE _TS_STEP2_ENABLE _TS_STEP3_ENABLE
            #pragma shader_feature_local_fragment _CLC_ENABLE
            #pragma shader_feature_local_fragment _HL_ENABLE
            #pragma shader_feature_local_fragment _HL_ENABLE_1
            #pragma shader_feature_local_fragment _TR_ENABLE
            #pragma shader_feature_local_fragment _DFD_ENABLE
            #pragma shader_feature_local_fragment _DSV_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "FUR"
            Tags { "LightMode" = "ForwardBase" }

            Cull OFF
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert_fakefur
            #pragma geometry geom_fakefur
            #pragma fragment frag_fakefur

            #pragma shader_feature_local _ _TS_FIXC_ENABLE
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

        UsePass "UnlitWF/WF_UnToon_Transparent/SHADOWCASTER"
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
