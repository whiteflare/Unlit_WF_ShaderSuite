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
Shader "UnlitWF/WF_UnToon_Texture" {

    /*
     * authors:
     *      ver:2019/03/02 whiteflare,
     */

    Properties {
        // 基本
        [Header(Base)]
            _MainTex        ("Main Texture", 2D) = "white" {}
        [KeywordEnum(OFF,BRIGHT,DARK,BLACK)]
            _GL_LEVEL       ("Anti-Glare", Float) = 0

        // アウトライン
        [Header(Outline)]
        [Toggle(_TL_ENABLE)]
            _TL_Enable      ("[LI] Enable", Float) = 0
            _TL_LineColor   ("[LI] Line Color", Color) = (0, 0, 0, 0.5)
            _TL_LineWidth   ("[LI] Line Width", Range(0, 0.5)) = 0.1
        [NoScaleOffset]
            _TL_MaskTex     ("[LI] Outline Mask Texture", 2D) = "white" {}
            _TL_Z_Shift     ("[LI] Z-shift (tweak)", Range(0, 1)) = 0.1
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "DisableBatching" = "True"
        }

        Pass {
            Tags{ "LightMode" = "ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert_outline
            #pragma fragment frag_outline

            #pragma target 3.0

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma shader_feature _TL_ENABLE
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_Common.cginc"
            #include "WF_MatcapShadows.cginc"

            float4      _TL_LineColor;
            float       _TL_LineWidth;
            sampler2D   _TL_MaskTex;
            float       _TL_Z_Shift;

            v2f vert_outline(appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.ls_vertex = v.vertex;
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                #ifdef _TL_ENABLE
                    // マスクテクスチャ参照
                    float mask = tex2Dlod(_TL_MaskTex, float4(o.uv.x, o.uv.y, 0, 0)).r;
                    // 外側にシフトする
                    o.ls_vertex.xyz += normalize( v.normal ).xyz * _TL_LineWidth * 0.01 * mask;
                    // カメラ方向の z シフト量を計算
                    float3 vecZShift = normalize( ObjSpaceViewDir(o.ls_vertex) ) * _TL_Z_Shift;
                    if (unity_OrthoParams.w < 0.5) {
                        // カメラが perspective のときは単にカメラ方向の逆にシフトする
                        o.ls_vertex.xyz -= vecZShift;
                        o.vertex = UnityObjectToClipPos( o.ls_vertex );
                    } else {
                        // カメラが orthographic のときはシフト後の z のみ採用する
                        o.vertex = UnityObjectToClipPos( o.ls_vertex );
                        o.ls_vertex.xyz -= vecZShift;
                        o.vertex.z = UnityObjectToClipPos( o.ls_vertex ).z;
                    }
                #else
                    o.vertex = UnityObjectToClipPos( o.ls_vertex );
                #endif

                SET_ANTIGLARE_LEVEL(v.vertex, o.lightPower);

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float4 frag_outline(v2f i) : SV_Target {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                #ifdef _TL_ENABLE
                    // アウトライン側の色を計算
                    float4 lineColor = _TL_LineColor;
                    affectAntiGlare(i.lightPower, lineColor);
                    UNITY_APPLY_FOG(i.fogCoord, lineColor);
                    // ベース側の色を計算
                    float4 baseColor = frag(i);
                    // ブレンドして返却
                    return float4( lerp(baseColor.rgb, lineColor.rgb, lineColor.a), 1);
                #else
                    // 無効のときはクリッピングする
                    clip(-1);
                    return float4(0, 0, 0, 0);
                #endif
            }

            ENDCG
        }

        Pass {
            Tags{ "LightMode" = "ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #pragma shader_feature _GL_LEVEL_OFF _GL_LEVEL_BRIGHT _GL_LEVEL_DARK _GL_LEVEL_BLACK
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "WF_MatcapShadows.cginc"

            ENDCG
        }

        Pass {
            Tags{ "LightMode" = "ShadowCaster" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v) {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }
    }

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
