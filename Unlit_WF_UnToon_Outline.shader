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
Shader "UnlitWF/WF_UnToon_Outline" {

    /*
     * authors:
     *      ver:2018/11/08 whiteflare,
     */

    Properties {
        // 基本
        [Header(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}
            _SolidColor     ("Solid Color", Color) = (0, 0, 0, 0)
        [KeywordEnum(OFF,BRIGHT,DARK,BLACK)]
            _GL_LEVEL       ("Anti-Glare", Float) = 0

        // Toon Simulation
        [Header(Toon)]
        [PowerSlider(3.0)]
            _TN_LineWidth   ("[TN] Outline width", Range(0., 0.34)) = 0.05
            _TN_LineColor   ("[TN] Outline color", Color) = (1, 1, 1, 1)

        // 法線マップ
        [Header(NormalMap)]
        [Toggle(_NM_ENABLE)]
            _NM_Enable      ("[NM] Enable", Float) = 0
        [NoScaleOffset]
            _BumpMap        ("[NM] NormalMap Texture", 2D) = "bump" {}
            _NM_Power       ("[NM] Shadow Power", Range(0, 1)) = 0.25
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Transparent" // ZWrite OFF で Geometry キューを使うと、背景に塗りつぶされてしまうので Transparent を使う
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass {
            Cull OFF
            ZWrite OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex   : POSITION;
            };

            struct v2g {
                float4 vertex   : POSITION;
            };

            struct g2f {
                float4 vertex   : SV_POSITION;
            };

            uniform float   _TN_LineWidth;
            uniform float4  _TN_LineColor;

            v2g vert(appdata v) {
                v2g o;
                o.vertex = v.vertex;
                return o;
            }

            [maxvertexcount(16)]
            void geom(triangle v2g v[3], inout TriangleStream<g2f> triStream) {
                g2f o;
                for (uint i = 0; i < 4; i++) {  // 最後の角を描画するために1回多く描く
                    float4 p0 = v[ (i + 0) % 3 ].vertex;
                    float4 p1 = v[ (i + 1) % 3 ].vertex;
                    float4 p2 = v[ (i + 2) % 3 ].vertex;
                    float3 n = normalize( cross( p1 - p0, cross(p1 - p0, p2 - p0) ) ) * _TN_LineWidth;

                    o.vertex = UnityObjectToClipPos( p0 );
                    triStream.Append(o);
                    o.vertex = UnityObjectToClipPos( p0 + n );
                    triStream.Append(o);
                    o.vertex = UnityObjectToClipPos( p1 );
                    triStream.Append(o);
                    o.vertex = UnityObjectToClipPos( p1 + n );
                    triStream.Append(o);
                }
            }

            float4 frag(g2f i) : SV_Target {
                return _TN_LineColor;
            }

            ENDCG
        }

        Pass {
            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma shader_feature _NM_ENABLE
            #pragma shader_feature _HL_ENABLE
            #pragma shader_feature _OL_ENABLE
            #pragma shader_feature _OL_BLENDTYPE_ALPHA _OL_BLENDTYPE_ADD _OL_BLENDTYPE_MUL
            #pragma shader_feature _ES_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_MatcapShadows.cginc"

            ENDCG
        }
    }
}
