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

#ifndef INC_UNLIT_WF_MATCAPSHADOWS
#define INC_UNLIT_WF_MATCAPSHADOWS

    /*
     * authors:
     *      ver:2019/03/02 whiteflare,
     */

    #include "WF_Common.cginc"

    struct appdata {
        float4 vertex       : POSITION;
        float2 uv           : TEXCOORD0;
        float3 normal       : NORMAL;
        #ifdef _NM_ENABLE
            float4 tangent  : TANGENT;
        #endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vertex           : SV_POSITION;
        float4 ls_vertex        : TEXCOORD0;
        float2 uv               : TEXCOORD1;
        float3 normal           : TEXCOORD2;
        #ifdef _NM_ENABLE
            float3 tangent      : TEXCOORD3;
            float3 bitangent    : TEXCOORD4;
            float3 lightDir     : TEXCOORD5;
        #endif
        #ifdef _OL_ENABLE
            float4 vs_vertex    : TEXCOORD6;
        #endif
        #ifndef _GL_LEVEL_OFF
            float lightPower    : COLOR0;
        #endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    sampler2D       _MainTex;
    float4          _MainTex_ST;
    float4          _Color;
    float           _AL_CutOff;

    #ifdef _NM_ENABLE
        sampler2D   _BumpMap;
        float       _NM_Power;
    #endif

    #ifdef _OL_ENABLE
        sampler2D   _OL_OverlayTex;
        float4      _OL_OverlayTex_ST;
        float       _OL_Power;
        float       _OL_Scroll_U;
        float       _OL_Scroll_V;
    #endif

    #ifdef _OL_ENABLE
        inline float4 computeNonStereoGrabScreenPos(float4 pos) {
            // UnityCG.cginc にある ComputeGrabScreenPos の UNITY_SINGLE_PASS_STEREO を考慮しない版
            #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
            #else
                float scale = 1.0;
            #endif
            float4 o = pos * 0.5f;
            o.xy = float2(o.x, o.y * scale) + o.w;
            o.zw = pos.zw;
            return o;
        }
        inline float2 computeOverlayTex(float4 vs_vertex, float2 uv) {
            #ifdef _OL_SCREEN_VIEW_XY
                 float4 screenPos = computeNonStereoGrabScreenPos(vs_vertex);
                 float2 scr = screenPos.xy / screenPos.w;
                 scr.y *= _ScreenParams.y / _ScreenParams.x;
             #else
                float2 scr = uv;
             #endif
             scr.x += frac(_OL_Scroll_U * _Time.x);
             scr.y += frac(_OL_Scroll_V * _Time.x);
             return TRANSFORM_TEX(scr, _OL_OverlayTex);
        }
        inline float3 blendOverlayColor(float3 color, float3 ov_color) {
            #ifdef _OL_BLENDTYPE_ADD
                // 加算
                return color + ov_color * _OL_Power;
            #elif _OL_BLENDTYPE_MUL
                // 重み付き乗算
                return color * lerp( float3(1, 1, 1), ov_color, _OL_Power);
            #else
                // ブレンド
                return lerp(color, ov_color, _OL_Power);
            #endif
        }
    #endif

    v2f vert(in appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vertex = UnityObjectToClipPos(v.vertex);
        o.ls_vertex = v.vertex;
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);

        #ifdef _NM_ENABLE
            o.normal = v.normal;
            o.tangent = v.tangent;
            o.bitangent = cross(o.normal, o.tangent);
            o.lightDir = calcLocalSpaceLightDir(o.ls_vertex);
        #else
            // NormalMapを使用しないときは頂点側でMatcap計算してnormalに突っ込む
            o.normal = calcMatcapVector(v.vertex, v.normal);
        #endif

        #ifdef _OL_ENABLE
            o.vs_vertex = o.vertex;
        #endif

		SET_ANTIGLARE_LEVEL(v.vertex, o.lightPower);

        UNITY_TRANSFER_FOG(o, o.vertex);
        return o;
    }

    float4 frag(v2f i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float4 color =
        #ifdef _SOLID_COLOR
            _Color;
        #else
            tex2D(_MainTex, i.uv);
        #endif

        // 色変換
        affectColorChange(color);

        // BumpMap
        #ifdef _NM_ENABLE
            // 法線計算
            float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal); // vertexのworld回転行列
            float3 ls_normal = UnpackNormal( tex2D(_BumpMap, i.uv) ); // 法線マップ参照
            float3 ws_normal = normalize( mul(ls_normal, tangentTransform) ); // world内の法線を作成
            // 光源とブレンド
            float diffuse = saturate((dot(ws_normal, i.lightDir.xyz) / 2 + 0.5) * _NM_Power + (1.0 - _NM_Power));
            color.rgb *= diffuse; // Unlitなのでライトの色は考慮しない
        #endif

        // Highlight
        float3 matcapVector =
            #ifdef _NM_ENABLE
                calcMatcapVector(i.ls_vertex, ws_normal); // Matcap計算
            #else
                i.normal; // NormalMap未使用時はvertで計算したMatcapVectorを使う
            #endif
        affectMatcapColor(matcapVector, i.uv, color);

        // Overlay
        #ifdef _OL_ENABLE
            float2 overlay = computeOverlayTex(i.vs_vertex, i.uv);
            color.rgb = blendOverlayColor(color.rgb, tex2D(_OL_OverlayTex, overlay).rgb);
        #endif

        // Anti-Glare
        affectAntiGlare(i.lightPower, color);

        // Alpha
        affectAlpha(i.uv, color);

        // EmissiveScroll
        affectEmissiveScroll(i.ls_vertex, i.uv, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    fixed4 frag_cutout_upper(v2f i) : SV_Target {
        float4 color = frag(i);
        clip(color.a - _AL_CutOff);
        return color;
    }

    fixed4 frag_cutout_lower(v2f i) : SV_Target {
        float4 color = frag(i);
        clip(_AL_CutOff - color.a);
        return color;
    }

#endif
