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
Shader "UnlitWF/WF_MatcapShadows_Color" {

    /*
     * authors:
     *      ver:2019/03/17 whiteflare,
     */

    Properties {
        // 基本
        [Header(Base)]
        [HDR]
            _Color          ("Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode       ("Cull Mode", int) = 2
        [Enum(OFF,0,BRIGHT,80,DARK,97,BLACK,100)]
            _GL_Level       ("Anti-Glare", Float) = 0

        // Matcapハイライト
        [Header(HighLight and Shadow Matcap)]
        [ToggleNoKwd]
            _HL_Enable      ("[HL] Enable", Float) = 0
        [NoScaleOffset]
            _HL_MatcapTex   ("[HL] Matcap Sampler", 2D) = "gray" {}
            _HL_MedianColor ("[HL] Median Color", Color) = (0.5, 0.5, 0.5, 1)
            _HL_Range       ("[HL] Matcap Range (Tweak)", Range(0, 2)) = 1
            _HL_Power       ("[HL] Power", Range(0, 2)) = 1
        [NoScaleOffset]
            _HL_MaskTex     ("[HL] Mask Texture", 2D) = "white" {}
        [ToggleNoKwd]
            _HL_SoftShadow  ("[HL] Soft Shadow Enable", Float) = 1
        [ToggleNoKwd]
            _HL_SoftLight   ("[HL] Soft Light Enable", Float) = 0

        // Overlay Texture
        [Header(Overlay Texture)]
        [ToggleNoKwd]
            _OL_Enable      ("[OL] Enable", Float) = 0
            _OL_OverlayTex  ("[OL] Texture", 2D) = "white" {}
        [Enum(ALPHA,0,ADD,1,MUL,2)]
            _OL_BlendType   ("[OL] Blend Type", Float) = 0
            _OL_Power       ("[OL] Blend Power", Range(0, 1)) = 1
            _OL_Scroll_U    ("[OL] U Scroll", Float) = 0
            _OL_Scroll_V    ("[OL] V Scroll", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "LightMode" = "ForwardBase"
        }

        Pass {
            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #define _HL_ENABLE
            #define _OL_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #define _SOLID_COLOR
            #include "WF_MatcapShadows.cginc"

            ENDCG
        }
    }

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
