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
Shader "UnlitWF/WF_Gem_Transparent" {

    /*
     * authors:
     *      ver:2019/08/24 whiteflare,
     */

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color          ("Color", Color) = (1, 1, 1, 1)

        // Lit
        [WFHeader(Lit)]
        [Enum(OFF,0,BRIGHT,80,DARK,97,BLACK,100)]
            _GL_Level       ("Anti-Glare", Float) = 97
            _GL_BrendPower  ("Blend Light Color", Range(0, 1)) = 0.8

        // Alpha
        [WFHeader(Transparent Alpha)]
        [FixNoTexture]
            _AL_MaskTex     ("[AL] Alpha Mask Texture", 2D) = "white" {}
            _AL_Power       ("[AL] Power", Range(0, 2)) = 0.8
            _AL_Fresnel     ("[AL] Fresnel Power", Range(0, 2)) = 1

        // Gem
        [WFHeader(Gem Reflection)]
        [NoScaleOffset]
            _MT_Cubemap     ("[GM] CubeMap", Cube) = "" {}
            _MT_BlendType   ("[GM] Brightness", Range(0, 1)) = 0.2
        [Toggle(_)]
            _MT_Monochrome  ("[GM] Monochrome Reflection", Range(0, 1)) = 1

        // hidden parameter
        [HideInInspector]
        [FixFloat(0.0)]
            _AL_Source      ("[AL] Alpha Source", Float) = 0
        [HideInInspector]
        [FixFloat(1.0)]
            _MT_Enable      ("[MT] Enable", Float) = 1
        [HideInInspector]
        [FixFloat(1.0)]
            _MT_Metallic    ("[MT] Metallic", Range(0, 1)) = 1
        [HideInInspector]
        [FixFloat(1.0)]
            _MT_Smoothness  ("[MT] Smoothness", Range(0, 1)) = 1
        [HideInInspector]
        [FixFloat(0.0)]
            _MT_BlendNormal ("[MT] Blend Normal", Range(0, 1)) = 0
        [HideInInspector]
        [FixFloat(0.0)]
            _MT_Specular    ("[MT] Specular", Range(0, 1)) = 0
        [HideInInspector]
        [FixFloat(2.0)]
            _MT_CubemapType ("[MT] 2nd CubeMap Blend", Float) = 2
        [HideInInspector]
        [FixNoTexture]
            _MT_MaskTex     ("[MT] MetallicMap Texture", 2D) = "white" {}
        [HideInInspector]
        [FixFloat(0.0)]
            _MT_InvMaskVal  ("[MT] Invert Mask Value", Range(0, 1)) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "DisableBatching" = "True"
        }

        Pass {
            Name "MAIN_BACK"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #define _AL_ENABLE
            #define _AL_FRESNEL_ENABLE
            #define _MT_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_UnToon.cginc"

            ENDCG
        }

        Pass {
            Name "MAIN_FRONT"
            Tags { "LightMode" = "ForwardBase" }

            Cull BACK
            ZWrite OFF
            Blend SrcAlpha One

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #define _AL_ENABLE
            #define _AL_FRESNEL_ENABLE
            #define _MT_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_UnToon.cginc"

            ENDCG
        }
    }

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
