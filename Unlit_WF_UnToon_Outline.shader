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
     *      ver:2018/11/12 whiteflare,
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

            #pragma vertex vert_outline
            #pragma fragment frag_outline
            #pragma geometry geom_outline

            #pragma target 3.0

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
            };

            struct v2g {
                float4 vertex   : POSITION;
                #ifndef _GL_LEVEL_OFF
                    float lightPower    : COLOR0;
                #endif
            };

            struct g2f {
                float4 vertex   : SV_POSITION;
                #ifndef _GL_LEVEL_OFF
                    float lightPower    : COLOR0;
                #endif
            };

            uniform float   _TN_LineWidth;
            uniform float4  _TN_LineColor;

            inline float calcBrightness(float3 color) {
                return color.r * 0.21 + color.g * 0.72 + color.b * 0.07;
            }

            inline float calcLightPower(float4 ls_vertex, float3 normal) {
                // directional light
                float light_intensity = calcBrightness(_LightColor0);
                float4 ws_vertex = mul(unity_ObjectToWorld, ls_vertex);
                #if UNITY_SHOULD_SAMPLE_SH
                    float3 ws_normal = UnityObjectToWorldNormal(normal);
                    // ambient
                    float3 ambient = max(0, ShadeSH9( float4(ws_normal, 1)) );
                    #if defined(VERTEXLIGHT_ON)
                        // not important lights
                        ambient += Shade4PointLights(
                            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                            unity_LightColor[0].rgb,
                            unity_LightColor[1].rgb,
                            unity_LightColor[2].rgb,
                            unity_LightColor[3].rgb,
                            unity_4LightAtten0,
                            ws_vertex,
                            ws_normal
                        );
                    #endif
                    light_intensity += calcBrightness(ambient);
                #endif
                return light_intensity;
            }

            v2g vert_outline(appdata v) {
                v2g o;
                o.vertex = v.vertex;

                #ifndef _GL_LEVEL_OFF
                    o.lightPower = saturate(calcLightPower(v.vertex, v.normal) * 2
                        #ifdef _GL_LEVEL_BRIGHT
                            + 0.2
                        #elif _GL_LEVEL_DARK
                            + 0.03
                        #endif
                    );
                #endif

                return o;
            }

            [maxvertexcount(16)]
            void geom_outline(triangle v2g v[3], inout TriangleStream<g2f> triStream) {
                g2f o;
                for (uint i = 0; i < 4; i++) {  // 最後の角を描画するために1回多く描く
                    v2g v0 = v[ (i + 0) % 3 ];
                    v2g v1 = v[ (i + 1) % 3 ];
                    v2g v2 = v[ (i + 2) % 3 ];
                    float4 p0 = v0.vertex;
                    float4 p1 = v1.vertex;
                    float4 p2 = v2.vertex;
                    float3 n = normalize( cross( p1 - p0, cross(p1 - p0, p2 - p0) ) ) * _TN_LineWidth;

                    o.vertex = UnityObjectToClipPos( p0 );
                    #ifndef _GL_LEVEL_OFF
                        o.lightPower = v0.lightPower;
                    #endif
                    triStream.Append(o);

                    o.vertex = UnityObjectToClipPos( p0 + n );
                    #ifndef _GL_LEVEL_OFF
                        o.lightPower = v1.lightPower;
                    #endif
                    triStream.Append(o);

                    o.vertex = UnityObjectToClipPos( p1 );
                    #ifndef _GL_LEVEL_OFF
                        o.lightPower = v2.lightPower;
                    #endif
                    triStream.Append(o);

                    o.vertex = UnityObjectToClipPos( p1 + n );
                    #ifndef _GL_LEVEL_OFF
                        o.lightPower = v0.lightPower;
                    #endif
                    triStream.Append(o);
                }
            }

            float4 frag_outline(g2f i) : SV_Target {
                float4 color = _TN_LineColor;
                #ifndef _GL_LEVEL_OFF
                    color.rgb = saturate(color.rgb * i.lightPower);
                #endif
                return color;
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
