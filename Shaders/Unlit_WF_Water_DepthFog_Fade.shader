/*
 *  The MIT License
 *
 *  Copyright 2018-2023 whiteflare.
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
Shader "UnlitWF/WF_Water_DepthFog_Fade" {

    Properties {
        [WFHeader(Base)]
        [HDR]
            _Color                  ("Fog Color", Color) = (0.3, 0.4, 0.8, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        [WFHeader(Water)]
            _WaterLevel             ("[WA] Water Level (World Y Coord)", Float) = 0
            _WaterTransparency      ("[WA] Water Transparency", Float) = 1

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/02/04", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-70" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert_depthfog
            #pragma fragment frag_depthfog

            #pragma target 3.0

            #pragma multi_compile_fwdbase
            // #pragma multi_compile_fog // DepthFog は Fog には対応しない
            #pragma multi_compile_instancing
            // #pragma multi_compile _ _WF_EDITOR_HIDE_LMAP // ライトマップは使わない

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #define _WF_WATER_DEPTHFOG
            #include "WF_Water.cginc"

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack OFF

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
