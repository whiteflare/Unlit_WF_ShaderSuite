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
Shader "Hidden/UnlitWF/WF_UnToon_Hidden" {

    Properties {
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2021/10/16", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "IgnoreProjector" = "True"
        }

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

        Pass {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert_meta
            #pragma fragment frag_meta_black

            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityStandardMeta.cginc"

            float4 frag_meta_black(v2f_meta i) : SV_Target {
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                o.Albedo        = float3(0, 0, 0);
                o.SpecularColor = float3(0, 0, 0);
                o.Emission      = float3(0, 0, 0);

                #ifdef EDITOR_VISUALIZATION
                    o.VizUV         = i.vizUV;
                    o.LightCoord    = i.lightCoord;
                #endif

                return UnityMetaFragment(o);
            }

            ENDCG
        }
    }

    FallBack OFF

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
