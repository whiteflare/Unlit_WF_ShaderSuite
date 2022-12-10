/*
 *  The MIT License
 *
 *  Copyright 2018-2022 whiteflare.
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
Shader "UnlitWF/WF_Water_Option_BackgroundCapture" {
    Properties {
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2022/10/22", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-10" }

        GrabPass { "_UnToonWaterRefraction" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            ColorMask 0
            ZWrite OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 2.0

            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata_t v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : COLOR {
                return fixed4(0, 0, 0, 1);
            }

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack OFF

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
