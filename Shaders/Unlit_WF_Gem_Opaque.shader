/*
 *  The MIT License
 *
 *  Copyright 2018-2020 whiteflare.
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
Shader "UnlitWF/WF_Gem_Opaque" {

    /*
     * authors:
     *      ver:2020/09/18 whiteflare,
     */

    Properties {
        // 基本
        [WFHeader(Gem Surface)]
        [HDR]
            _Color                  ("Color", Color) = (0.8, 0.4, 0.4, 1)
            _MainTex                ("Main Texture", 2D) = "white" {}
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        // Flake
        [WFHeaderToggle(Gem Flake)]
            _GF_Enable              ("[GF] Enable", Float) = 1
        [PowerSlider(2.0)]
            _GF_FlakeSizeFront      ("[GF] Flake Size (front)", Range(0, 1)) = 0.1
            _GF_FlakeShear          ("[GF] Shear", Range(0, 1)) = 0.5
            _GF_FlakeBrighten       ("[GF] Brighten", Range(0, 8)) = 2
            _GF_FlakeDarken         ("[GF] Darken", Range(0, 8)) = 0.5
            _GF_Twinkle             ("[GF] Twinkle", Range(0, 4)) = 2
            _GF_BlendNormal         ("[GF] Blend Normal", Range(0, 1)) = 0.1

        // Reflection
        [WFHeaderToggle(Gem Reflection)]
            _GR_Enable              ("[GR] Enable", Float) = 1
            _GR_Power               ("[GR] Blend Power", Range(0, 1)) = 1
        [NoScaleOffset]
            _GR_Cubemap             ("[GR] CubeMap", Cube) = "" {}
            _GR_Brightness          ("[GR] Brightness", Range(0, 1)) = 0
            _GR_Monochrome          ("[GR] Monochrome Reflection", Range(0, 1)) = 1
        [PowerSlider(4.0)]
            _GR_CubemapPower        ("[GR] 2nd CubeMap Power", Range(0, 16)) = 1
            _GR_BlendNormal         ("[GR] Blend Normal", Range(0, 1)) = 0.1

        // 法線マップ
        [WFHeaderToggle(NormalMap)]
            _NM_Enable              ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap                ("[NM] NormalMap Texture", 2D) = "bump" {}
            _BumpScale              ("[NM] Bump Scale", Range(0, 2)) = 1.0
        [Toggle(_)]
            _NM_FlipTangent         ("[NM] Flip Tangent", Float) = 0

        // Lit
        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Darken (min value)", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Lighten (max value)", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Blend Light Color", Range(0, 1)) = 0.8

        [WFHeader(Lit Advance)]
        [Enum(AUTO,0,ONLY_DIRECTIONAL_LIT,1,ONLY_POINT_LIT,2,CUSTOM_WORLDSPACE,3,CUSTOM_LOCALSPACE,4)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [Toggle(_)]
            _GL_DisableBackLit      ("Disable BackLit", Range(0, 1)) = 0
        [Toggle(_)]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag_gem_front

            #pragma target 3.0

            #define _NM_ENABLE
            #define _WF_MOBILE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "WF_Gem.cginc"

            ENDCG
        }
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
