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
Shader "UnlitWF/WF_FakeFur_Transparent" {

    /*
     * authors:
     *      ver:2018/12/02 whiteflare,
     */

    Properties {
        // 基本
        [Header(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}
        [KeywordEnum(OFF,BRIGHT,DARK,BLACK)]
            _GL_LEVEL       ("Anti-Glare", Float) = 0

        // ファー設定
        [Header(Fur Settings)]
        [NoScaleOffset]
            _FurMaskTex     ("Fur Mask Texture", 2D) = "white" {}
            _FurNoiseTex    ("Fur Noise Texture", 2D) = "white" {}
            _FurHeight      ("Fur Height", Float) = 0.1
            _FurShadowPower ("Fur ShadowPower", Range(0, 1)) = 0
        [IntRange]
            _FurRepeat      ("Fur Repeat", Range(1, 8)) = 3
            _FurVector      ("Fur Static Vector", Vector) = (0, 0, 0, 0)

        // 色変換
        [Header(Color Change)]
        [Toggle(_CL_ENABLE)]
            _CL_Enable      ("[CL] Enable", Float) = 0
        [Toggle(_CL_MONOCHROME)]
            _CL_Monochrome  ("[CL] monochrome", Float) = 0
            _CL_DeltaH      ("[CL] Hur", Range(0, 1)) = 0
            _CL_DeltaS      ("[CL] Saturation", Range(-1, 1)) = 0
            _CL_DeltaV      ("[CL] Brightness", Range(-1, 1)) = 0

        // Matcapハイライト
        [Header(HighLight and Shadow Matcap)]
        [Toggle(_HL_ENABLE)]
            _HL_Enable      ("[HL] Enable", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex   ("[HL] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor ("[HL] Median Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Range       ("[HL] Matcap Range (Tweak)", Range(0, 2)) = 1
            _HL_Power       ("[HL] Power", Range(0, 2)) = 1
        [NoScaleOffset]
            _HL_MaskTex     ("[HL] Mask Texture", 2D) = "white" {}
        [Toggle(_HL_SOFT_SHADOW)]
            _HL_SoftShadow  ("[HL] Soft Shadow Enable (expt.)", Float) = 1
        [Toggle(_HL_SOFT_LIGHT)]
            _HL_SoftLight   ("[HL] Soft Light Enable (expt.)", Float) = 0

        // ウェーブアニメーション
        [Header(Fur Wave Animation)]
        [Toggle(_WV_ENABLE)]
            _WV_Enable      ("[WV] Enable", Float) = 0
            _WaveSpeed      ("[WV] Wave Speed", Vector) = (0, 0, 0, 0)
            _WaveScale      ("[WV] Wave Scale", Vector) = (0, 0, 0, 0)
            _WavePosFactor  ("[WV] Position Factor", Vector) = (0, 0, 0, 0)
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass {
            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma shader_feature _CL_ENABLE
            #pragma shader_feature _CL_MONOCHROME
            #pragma shader_feature _HL_ENABLE
            #pragma shader_feature _HL_SOFT_SHADOW
            #pragma shader_feature _HL_SOFT_LIGHT

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_MatcapShadows.cginc"

            ENDCG
        }

        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass {
            Cull OFF
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert_fakefur
            #pragma geometry geom_fakefur
            #pragma fragment frag_fakefur

            #pragma target 5.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma shader_feature _WV_ENABLE
            #pragma shader_feature _FUR_QUALITY_FAST _FUR_QUALITY_NORMAL _FUR_QUALITY_DETAIL

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_FakeFur.cginc"

            ENDCG
        }
    }

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
