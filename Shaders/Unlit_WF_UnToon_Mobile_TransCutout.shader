/*
 *  The MIT License
 *
 *  Copyright 2018-2019 whiteflare.
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
Shader "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransCutout" {

    /*
     * authors:
     *      ver:2019/09/14 whiteflare,
     */

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color          ("Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode       ("Cull Mode", int) = 0

        // Lit
        [WFHeader(Lit)]
        [Enum(OFF,0,BRIGHT,80,DARK,97,BLACK,100)]
            _GL_Level       ("Anti-Glare", Float) = 97
            _GL_BrendPower  ("Blend Light Color", Range(0, 1)) = 0.8

        // Alpha
        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source      ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex     ("[AL] Alpha Mask Texture", 2D) = "white" {}
            _AL_Power       ("[AL] Power", Range(0, 2)) = 1.0
            _AL_CutOff      ("[AL] Cutoff Threshold", Range(0, 1)) = 0.5

        // Matcapハイライト
        [WFHeaderToggle(Light Matcap)]
            _HL_Enable      ("[HL] Enable", Float) = 0
        [Enum(MEDIAN_CAP,0,LIGHT_CAP,1)]
            _HL_CapType     ("[HL] Matcap Type", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex   ("[HL] Matcap Sampler", 2D) = "gray" {}
            _HL_MatcapColor ("[HL] Matcap Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Power       ("[HL] Power", Range(0, 2)) = 1
            _HL_BlendNormal ("[HL] Blend Normal", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _HL_MaskTex     ("[HL] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _HL_InvMaskVal  ("[HL] Invert Mask Value", Range(0, 1)) = 0

        // 階調影
        [WFHeaderToggle(ToonShade)]
            _TS_Enable      ("[SH] Enable", Float) = 0
            _TS_BaseColor   ("[SH] Base Color", Color) = (1, 1, 1, 1)
            _TS_1stColor    ("[SH] 1st Shade Color", Color) = (0.7, 0.7, 0.9, 1)
            _TS_2ndColor    ("[SH] 2nd Shade Color", Color) = (0.5, 0.5, 0.8, 1)
            _TS_Power       ("[SH] Shade Power", Range(0, 2)) = 1
            _TS_1stBorder   ("[SH] 1st Border", Range(0, 1)) = 0.4
            _TS_2ndBorder   ("[SH] 2nd Border", Range(0, 1)) = 0.2
            _TS_Feather     ("[SH] Feather", Range(0, 0.2)) = 0.05
            _TS_BlendNormal ("[SH] Blend Normal", Range(0, 1)) = 0.1
        [NoScaleOffset]
            _TS_MaskTex     ("[SH] BoostLight Mask Texture", 2D) = "black" {}
        [Toggle(_)]
            _TS_InvMaskVal  ("[SH] Invert Mask Value", Range(0, 1)) = 0

        // リムライト
        [WFHeaderToggle(RimLight)]
            _TR_Enable      ("[RM] Enable", Float) = 0
        [HDR]
            _TR_Color       ("[RM] Rim Color", Color) = (0.8, 0.8, 0.8, 1)
            _TR_PowerTop    ("[RM] Power Top", Range(0, 0.5)) = 0.1
            _TR_PowerSide   ("[RM] Power Side", Range(0, 0.5)) = 0.1
            _TR_PowerBottom ("[RM] Power Bottom", Range(0, 0.5)) = 0.1
        [NoScaleOffset]
            _TR_MaskTex     ("[RM] RimLight Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _TR_InvMaskVal  ("[RM] Invert Mask Value", Range(0, 1)) = 0

        // Ambient Occlusion
        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable      ("[AO] Enable", Float) = 0
            _AO_Contrast    ("[AO] Contrast", Range(0, 2)) = 1
            _AO_Brightness  ("[AO] Brightness", Range(-1, 1)) = 0
        [NoScaleOffset]
            _AO_MaskTex     ("[AO] Occlusion Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _AO_InvMaskVal  ("[AO] Invert Mask Value", Range(0, 1)) = 0

        [WFHeader(Lit Advance)]
        [Enum(AUTO,0,ONLY_DIRECTIONAL_LIT,1,ONLY_POINT_LIT,2,CUSTOM_WORLDSPACE,3,CUSTOM_LOCALSPACE,4)]
            _GL_LightMode       ("Sun Source", Float) = 0
            _GL_CustomAzimuth   ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude  ("Custom Sun Altitude", Range(-90, 90)) = 45
        [Toggle(_)]
            _GL_DisableBackLit  ("Disable BackLit", Range(0, 1)) = 0

        [WFHeader(DebugMode)]
        [KeywordEnum(NONE,MAGENTA,CLIP,POSITION,NORMAL,TANGENT,BUMPED_NORMAL,LIGHT_COLOR,LIGHT_MAP)]
            _WF_DebugView       ("Debug View", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "TransparentCutout"
            "Queue" = "AlphaTest"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag_cutout_upper

            #pragma target 3.0

            #define _WF_MOBILE

            #define _AO_ENABLE
            #define _HL_ENABLE
            #define _TR_ENABLE
            #define _TS_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma shader_feature _WF_DEBUGVIEW_NONE _WF_DEBUGVIEW_MAGENTA _WF_DEBUGVIEW_CLIP _WF_DEBUGVIEW_POSITION _WF_DEBUGVIEW_NORMAL _WF_DEBUGVIEW_TANGENT _WF_DEBUGVIEW_BUMPED_NORMAL _WF_DEBUGVIEW_LIGHT_COLOR _WF_DEBUGVIEW_LIGHT_MAP

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_UnToon.cginc"

            ENDCG
        }
    }

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
