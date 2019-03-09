/*
 *  The MIT License
 *
 *  Copyright 2018 whiteflare.
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
Shader "UnlitWF/WF_UnToon_Transparent_Mask" {

    /*
     * authors:
     *      ver:2019/03/09 whiteflare,
     */

    Properties {
        // 基本
        [Header(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}

        // Litブレンド
        [Header(Lit)]
        [Enum(OFF,0,BRIGHT,80,DARK,97,BLACK,100)]
            _GL_Level       ("Anti-Glare", Float) = 0
            _GL_BrendPower  ("Blend Light Color", Range(0, 1)) = 0.8

        // StencilMask
        [Header(Stencil Mask)]
        [Enum(A_1000,8,B_1001,9,C_1010,10,D_1100,11)]
            _StencilMaskID  ("ID", int) = 8

        // Alpha
        [Header(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source      ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex     ("[AL] Alpha Mask Texture", 2D) = "white" {}
            _AL_Power       ("[AL] Power", Range(0, 2)) = 1.0
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite      ("[AL] ZWrite", int) = 0

        // 色変換
        [Header(Color Change)]
        [Toggle(_CL_ENABLE)]
            _CL_Enable      ("[CL] Enable", Float) = 0
        [MaterialToggle]
            _CL_Monochrome  ("[CL] monochrome", Float) = 0
            _CL_DeltaH      ("[CL] Hur", Range(0, 1)) = 0
            _CL_DeltaS      ("[CL] Saturation", Range(-1, 1)) = 0
            _CL_DeltaV      ("[CL] Brightness", Range(-1, 1)) = 0

        // 法線マップ
        [Header(NormalMap)]
        [Toggle(_NM_ENABLE)]
            _NM_Enable      ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap        ("[NM] NormalMap Texture", 2D) = "bump" {}
            _NM_Power       ("[NM] Shadow Power", Range(0, 1)) = 0.25

        // メタリックマップ
        [Header(Metallic)]
        [Toggle(_MT_ENABLE)]
            _MT_Enable      ("[MT] Enable", Float) = 0
            _MT_Metallic     ("[MT] Metallic", Range(0, 1)) = 0.5
            _MT_Smoothness  ("[MT] Smoothness", Range(0, 1)) = 0.5
            _MT_BlendNormal ("[MT] Blend Normal", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _MT_MaskTex     ("[MT] Metallic Map Texture", 2D) = "white" {}
        [MaterialToggle]
            _MT_InvMaskVal  ("[MT] Invert Mask Value", Float) = 0

        // 階調影
        [Header(ToonShade)]
        [Toggle(_TS_ENABLE)]
            _TS_Enable      ("[SH] Enable", Float) = 0
            _TS_1stColor    ("[SH] 1st Shade Color", Color) = (0.5, 0.5, 0.5, 1)
            _TS_2ndColor    ("[SH] 2nd Shade Color", Color) = (0.3, 0.3, 0.3, 1)
            _TS_1stBorder   ("[SH] 1st Border", Range(0, 1)) = 0.4
            _TS_2ndBorder   ("[SH] 2nd Border", Range(0, 1)) = 0.2
            _TS_ShadowLimit ("[SH] Shade Power Limit", Range(0, 1)) = 0.7
            _TS_BlendNormal ("[SH] Blend Normal", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _TS_MaskTex     ("[SH] BoostLight Mask Texture", 2D) = "black" {}
        [MaterialToggle]
            _TS_InvMaskVal  ("[SH] Invert Mask Value", Float) = 0

        // Matcapハイライト
        [Header(Light Matcap)]
        [Toggle(_HL_ENABLE)]
            _HL_Enable      ("[HL] Enable", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex   ("[HL] Matcap Sampler", 2D) = "gray" {}
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1)]
            _HL_CapType     ("[HL] Matcap Type", Float) = 0
            _HL_MatcapColor ("[HL] Median Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power       ("[HL] Power", Range(0, 2)) = 1
            _HL_BlendNormal ("[HL] Blend Normal", Range(0, 1)) = 0.1
        [HideInInspector]
            _HL_Range       ("[HL] Matcap Range (Tweak)", Range(0, 2)) = 1
        [NoScaleOffset]
            _HL_MaskTex     ("[HL] Mask Texture", 2D) = "white" {}
        [MaterialToggle]
            _HL_InvMaskVal  ("[HL] Invert Mask Value", Float) = 0

        // リムライト
        [Header(RimLight)]
        [Toggle(_TR_ENABLE)]
            _TR_Enable      ("[RM] Enable", Float) = 0
            _TR_Color       ("[RM] Rim Color", Color) = (0.8, 0.8, 0.8, 1)
            _TR_PowerTop    ("[RM] Power Top", Range(0, 0.5)) = 0.1
            _TR_PowerSide   ("[RM] Power Side", Range(0, 0.5)) = 0.1
            _TR_PowerBottom ("[RM] Power Bottom", Range(0, 0.5)) = 0.1
        [NoScaleOffset]
            _TR_MaskTex     ("[RM] RimLight Mask Texture", 2D) = "white" {}
        [MaterialToggle]
            _TR_InvMaskVal  ("[RM] Invert Mask Value", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "DisableBatching" = "True"
        }

        Stencil {
            Ref [_StencilMaskID]
            WriteMask [_StencilMaskID]
            Comp ALWAYS
            Pass replace
        }

        Pass {
            Name "Main_Back"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #pragma shader_feature _CL_ENABLE
            #pragma shader_feature _NM_ENABLE
            #pragma shader_feature _TS_ENABLE
            #pragma shader_feature _MT_ENABLE
            #pragma shader_feature _TR_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define _AL_ENABLE

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "Main_Front"
            Tags { "LightMode" = "ForwardBase" }

            Cull BACK
            ZWrite [_AL_ZWrite]
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #pragma shader_feature _CL_ENABLE
            #pragma shader_feature _NM_ENABLE
            #pragma shader_feature _TS_ENABLE
            #pragma shader_feature _MT_ENABLE
            #pragma shader_feature _HL_ENABLE
            #pragma shader_feature _TR_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define _AL_ENABLE

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_UnToon.cginc"

            ENDCG
        }
    }

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
