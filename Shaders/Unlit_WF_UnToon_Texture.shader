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
Shader "UnlitWF/WF_UnToon_Texture" {

    /*
     * authors:
     *      ver:2019/03/09 whiteflare,
     */

    Properties {
        // 基本
        [Header(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode       ("Cull Mode", int) = 2

        // Litブレンド
        [Header(Lit)]
        [Enum(OFF,0,BRIGHT,80,DARK,97,BLACK,100)]
            _GL_Level       ("Anti-Glare", Float) = 0
            _GL_BrendPower  ("Blend Light Color", Range(0, 1)) = 0.8

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
            _MT_Metallic    ("[MT] Metallic", Range(0, 1)) = 0.5
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

        // アウトライン
        [Header(Outline)]
        [Toggle(_TL_ENABLE)]
            _TL_Enable      ("[LI] Enable", Float) = 0
            _TL_LineColor   ("[LI] Line Color", Color) = (0, 0, 0, 0.8)
            _TL_LineWidth   ("[LI] Line Width", Range(0, 0.5)) = 0.05
        [NoScaleOffset]
            _TL_MaskTex     ("[LI] Outline Mask Texture", 2D) = "white" {}
        [MaterialToggle]
            _TL_InvMaskVal  ("[LI] Invert Mask Value", Float) = 0
            _TL_Z_Shift     ("[LI] Z-shift (tweak)", Range(0, 1)) = 0.5
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "DisableBatching" = "True"
        }

        Pass {
            Name "Outline"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert_outline
            #pragma fragment frag_outline

            #pragma target 3.0

            #pragma shader_feature _CL_ENABLE
            #pragma shader_feature _TL_ENABLE
            #pragma shader_feature _TR_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "Main"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]

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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            // 影
            Tags{ "LightMode" = "ShadowCaster" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v) {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }
    }

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
