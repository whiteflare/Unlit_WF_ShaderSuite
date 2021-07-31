/*
 *  The MIT License
 *
 *  Copyright 2018-2021 whiteflare.
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
Shader "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque" {

    Properties {
        // 基本
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)
        [Toggle(_)]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        // アウトライン
        [WFHeaderAlwaysOn(Outline)]
            _TL_Enable              ("[LI] Enable", Float) = 1
            _TL_LineColor           ("[LI] Line Color", Color) = (0.1, 0.1, 0.1, 1)
        [NoScaleOffset]
            _TL_CustomColorTex      ("[LI] Custom Color Texture", 2D) = "white" {}
            _TL_LineWidth           ("[LI] Line Width", Range(0, 1)) = 0.05
        [Enum(NORMAL,0,EDGE,1)]
            _TL_LineType            ("[LI] Line Type", Float) = 0
            _TL_BlendCustom         ("[LI] Blend Custom Color Texture", Range(0, 1)) = 0
            _TL_BlendBase           ("[LI] Blend Base Color", Range(0, 1)) = 0
        [NoScaleOffset]
            _TL_MaskTex             ("[LI] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _TL_InvMaskVal          ("[LI] Invert Mask Value", Float) = 0
            _TL_Z_Shift             ("[LI] Z-shift (tweak)", Range(-0.1, 0.5)) = 0

        // Lit
        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Darken (min value)", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Lighten (max value)", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Blend Light Color", Range(0, 1)) = 0.8
        [Toggle(_)]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1

        [WFHeader(Lit Advance)]
        [Enum(AUTO,0,ONLY_DIRECTIONAL_LIT,1,ONLY_POINT_LIT,2,CUSTOM_WORLDSPACE,3,CUSTOM_LOCALSPACE,4)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [Toggle(_)]
            _GL_DisableBackLit      ("Disable BackLit", Range(0, 1)) = 0
        [Toggle(_)]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2021/07/31", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "DisableBatching" = "True"
        }

        Pass {
            Name "OUTLINE"
            Tags { "LightMode" = "ForwardBase" }

            Cull FRONT

            CGPROGRAM

            #pragma vertex vert_outline
            #pragma fragment frag

            #pragma target 3.0

            #define _TL_ENABLE // 常にオン
            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "WF_UnToon.cginc"

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack "Hidden/UnlitWF/WF_UnToon_Hidden"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
