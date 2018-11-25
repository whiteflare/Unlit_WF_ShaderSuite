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
     *      ver:2018/11/25 whiteflare,
     */

    Properties {
        [Header(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}
            _SolidColor     ("Solid Color", Color) = (0, 0, 0, 0)
        [KeywordEnum(OFF,BRIGHT,DARK,BLACK)]
            _GL_LEVEL       ("Anti-Glare", Float) = 0

        [Header(Fur Settings)]
        [NoScaleOffset]
            _FurMaskTex     ("Fur Mask Texture", 2D) = "white" {}
            _FurNoiseTex    ("Fur Noise Texture", 2D) = "white" {}
            _FurHeight      ("Fur Height", Float) = 0.1
            _FurShadowPower ("Fur ShadowPower", Range(0, 1)) = 0
        [IntRange]
            _FurRepeat      ("Fur Repeat", Range(1, 8)) = 3
            _FurVector      ("Fur Static Vector", Vector) = (0, 0, 0, 0)

        [Header(Fur Wave Animation)]
        [Toggle(_WV_ENABLE)]
            _WV_Enable      ("[WV] Enable", Float) = 0
            _WaveSpeed      ("WV] Wave Speed", Vector) = (0, 0, 0, 0)
            _WaveScale      ("WV] Wave Scale", Vector) = (0, 0, 0, 0)
            _WavePosFactor  ("WV] Position Factor", Vector) = (0, 0, 0, 0)
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass {
            Cull OFF
            Blend One Zero

            CGPROGRAM

            #pragma vertex vert_base
            #pragma fragment frag_base

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_FakeFur.cginc"

            ENDCG
        }

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
