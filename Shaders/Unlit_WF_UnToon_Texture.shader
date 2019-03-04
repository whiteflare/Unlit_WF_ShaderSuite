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
     *      ver:2019/03/02 whiteflare,
     */

    Properties {
        // 基本
        [Header(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}

        // 色変換
        [Header(Color Change)]
        [Toggle(_CL_ENABLE)]
            _CL_Enable      ("[CL] Enable", Float) = 0
        [Toggle(_CL_MONOCHROME)]
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

        // 階調影
        [Header(ToonShade)]
        [Toggle(_TS_ENABLE)]
            _TS_Enable      ("[SH] Enable", Float) = 0
            _TS_1stColor    ("[SH] 1st Shadow Color", Color) = (0.5, 0.5, 0.5, 1)
            _TS_2ndColor    ("[SH] 2nd Shadow Color", Color) = (0.3, 0.3, 0.3, 1)
            _TS_1stBorder   ("[SH] 1st Border", Range(0, 1)) = 0.5
            _TS_2ndBorder   ("[SH] 2nd Border", Range(0, 1)) = 0.2
            _TS_Feather     ("[SH] Feather", Range(0, 0.1)) = 0.02
        [Toggle(_TS_BOOSTLIGHT)]
            _TS_BoostLight  ("[SH] Boost Light", Float) = 0

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
            _TR_InvMaskTex  ("[RM] Invert Mask Value", Float) = 0

        // アウトライン
        [Header(Outline)]
        [Toggle(_TL_ENABLE)]
            _TL_Enable      ("[LI] Enable", Float) = 0
            _TL_LineColor   ("[LI] Line Color", Color) = (0, 0, 0, 0.8)
            _TL_LineWidth   ("[LI] Line Width", Range(0, 0.5)) = 0.1
        [NoScaleOffset]
            _TL_MaskTex     ("[LI] Outline Mask Texture", 2D) = "white" {}
        [MaterialToggle]
            _TL_InvMaskTex  ("[LI] Invert Mask Value", Float) = 0
            _TL_Z_Shift     ("[LI] Z-shift (tweak)", Range(0, 1)) = 0.1
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "DisableBatching" = "True"
        }

        Pass {
            // アウトライン
            Tags{ "LightMode" = "ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert_outline
            #pragma fragment frag_outline

            #pragma target 3.0

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma shader_feature _CL_ENABLE
            #pragma shader_feature _CL_MONOCHROME
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
            // メイン
            Tags{ "LightMode" = "ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma shader_feature _CL_ENABLE
            #pragma shader_feature _CL_MONOCHROME
            #pragma shader_feature _NM_ENABLE
            #pragma shader_feature _TS_ENABLE
            #pragma shader_feature _TS_BOOSTLIGHT
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
