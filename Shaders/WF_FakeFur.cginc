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

#ifndef INC_UNLIT_WF_FAKEFUR
#define INC_UNLIT_WF_FAKEFUR

    #include "WF_INPUT_FakeFur.cginc"
    #include "WF_UnToon.cginc"

    struct appdata_fur {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float3 normal           : NORMAL;
        float4 tangent          : TANGENT;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2g {
        float2 uv               : TEXCOORD0;
        float3 ws_vertex        : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        float4 ws_light_dir     : TEXCOORD3;
        float3 ws_fur_vector    : TEXCOORD4;
        float3 light_color      : COLOR1;
#ifdef _TS_ENABLE
        float shadow_power      : COLOR2;
#endif
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct g2f {
        float4 vertex           : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float3 ws_vertex        : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        float  height           : COLOR0;
        float3 light_color      : COLOR1;
#ifdef _TS_ENABLE
        float shadow_power      : COLOR2;
#endif
        float4 ws_light_dir     : TEXCOORD3;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    ////////////////////////////
    // vertex & fragment shader
    ////////////////////////////

    float3 calcFurVector(float3 ws_tangent, float3 ws_bitangent, float3 ws_normal, float2 uv) {
        // Tangent Transform 計算
        float3x3 tangentTransform = float3x3(ws_tangent, ws_bitangent, ws_normal);

        // Static Fur Vector 計算
        float3 vec_fur = SafeNormalizeVec3Normal(_FR_Vector.xyz);

#ifndef _FR_DISABLE_NORMAL_MAP
        // NormalMap Fur Vector 計算
        float2 uv_main = TRANSFORM_TEX(uv, _MainTex);
        float3 vec_map = UnpackNormal( PICK_VERT_TEX2D_LOD(_FR_BumpMap, uv_main, 0) );
        vec_fur = BlendNormals(vec_fur, vec_map);
#endif

        return mul(vec_fur , tangentTransform);
    }

    v2g vert_fakefur(appdata_fur v) {
        v2g o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.uv = v.uv;
        o.ws_vertex = UnityObjectToWorldPos(v.vertex);
        o.ws_light_dir = calcWorldSpaceLightDir(o.ws_vertex);

        float3 ws_tangent;
        float3 ws_bitangent;
        localNormalToWorldTangentSpace(v.normal, v.tangent, o.ws_normal, ws_tangent, ws_bitangent, _FR_FlipMirror & 1, _FR_FlipMirror & 2);

        // 環境光取得
        float3 ambientColor = sampleSHLightColor();
        // 影コントラスト
        calcToonShadeContrast(o.ws_vertex, o.ws_light_dir, ambientColor, o.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(o.ws_vertex, ambientColor);

        // ファーを伸ばす方向を計算
        o.ws_fur_vector = calcFurVector(ws_tangent, ws_bitangent, o.ws_normal, o.uv)
            #ifdef _FR_HEIGHT_PARAM
                * _FR_HEIGHT_PARAM ;
            #else
                * _FR_Height ;
            #endif

        return o;
    }

    g2f initGeomOutput(v2g p) {
        g2f o;
        UNITY_INITIALIZE_OUTPUT(g2f, o);
        UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(g2f, o);
        o.uv            = p.uv;
        o.ws_vertex     = p.ws_vertex;
        o.ws_normal     = p.ws_normal;
        o.light_color   = p.light_color;
#ifdef _TS_ENABLE
        o.shadow_power  = p.shadow_power;
#endif
        o.ws_light_dir  = p.ws_light_dir;
        return o;
    }

    void transferGeomVertex(inout g2f o, float3 vb, float3 vu, float height) {
        o.ws_vertex = lerp(vb, vu, height);
        o.vertex = UnityWorldToClipPos( o.ws_vertex );
        o.height = height;
    }

    v2g lerp_v2g(v2g x, v2g y, float div) {
        v2g o;
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        o.uv                = lerp(x.uv,            y.uv,               div);
        o.ws_vertex         = lerp(x.ws_vertex,     y.ws_vertex,        div);
        o.ws_normal         = lerp(x.ws_normal,     y.ws_normal,        div);
        o.light_color       = lerp(x.light_color,   y.light_color,      div);
#ifdef _TS_ENABLE
        o.shadow_power      = lerp(x.shadow_power,  y.shadow_power,     div);
#endif
        o.ws_light_dir      = lerp(x.ws_light_dir,  y.ws_light_dir,     div);
        o.ws_fur_vector     = lerp(x.ws_fur_vector, y.ws_fur_vector,    div);
        return o;
    }

    void fakefur(v2g v[3], inout TriangleStream<g2f> triStream) {
        // 底辺座標
        float3 vb[3] = { v[0].ws_vertex, v[1].ws_vertex, v[2].ws_vertex };
        // 頂点座標
        float3 vu[3] = vb;

        // normal方向に従ってfurを伸ばす
        {
            for (uint i = 0; i < 3; i++) {
                // 頂点移動
                vu[i].xyz += v[i].ws_fur_vector;
            }
        }
        // ファーを増殖
        {
            for (uint i = 0; i < 4; i++) {
                uint n = i % 3;
                g2f o = initGeomOutput(v[n]);
                transferGeomVertex(o, vb[n], vu[n], 0); triStream.Append(o);
                transferGeomVertex(o, vb[n], vu[n], 1); triStream.Append(o);
            }
        }
    }

    [maxvertexcount(48)]
    void geom_fakefur(triangle v2g v[3], inout TriangleStream<g2f> triStream) {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(v[0]);

        v2g c = lerp_v2g(v[0], lerp_v2g(v[1], v[2], 0.5), 2.0 / 3.0);
        for (uint i = 0; i < _FR_Repeat; i++) {
            float rate = i / (float) _FR_Repeat;
            v2g v2[3] = {
                lerp_v2g(v[0], c, rate),
                lerp_v2g(v[1], c, rate),
                lerp_v2g(v[2], c, rate)
            };
            fakefur(v2, triStream);
        }
    }

    fixed4 frag_fakefur(g2f gi) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        v2f i = (v2f) 0;
        i.uv            = gi.uv;
        i.ws_vertex     = gi.ws_vertex;
        i.normal        = gi.ws_normal;
        i.light_color   = gi.light_color;
#ifdef _TS_ENABLE
        i.shadow_power  = gi.shadow_power;
#endif
        i.ws_light_dir  = gi.ws_light_dir;

        // メイン
        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        float4 color = PICK_MAIN_TEX2D(_MainTex, uv_main) * _Color;
        // アルファマスク適用
        affectAlphaMask(uv_main, color);

        // 色変換
        affectColorChange(color);

        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i.ws_vertex, i.ws_light_dir);
        // 階調影
        affectToonShade(i, uv_main, i.normal, i.normal, angle_light_camera, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        float4 maskTex = PICK_SUB_TEX2D(_FR_MaskTex, _MainTex, uv_main);
        if (maskTex.r < 0.01 || maskTex.r <= gi.height) {
            discard;
        }

        // ファーノイズを追加
        float noise = PICK_MAIN_TEX2D(_FR_NoiseTex, TRANSFORM_TEX(i.uv, _FR_NoiseTex)).r;
        color = float4(color.rgb * saturate(1 - (1 - noise) * _FR_ShadowPower), saturate(noise - pow(gi.height, 4)));

        return color;
    }

    fixed4 frag_fakefur_cutoff(g2f i) : SV_Target {
        float4 color = frag_fakefur(i);

        color.a = smoothstep(_Cutoff - 0.0625, _Cutoff + 0.0625, color.a);
        if (TGL_OFF(_AL_AlphaToMask) && color.a < 0.5) {
            discard;
        }
        return color;
    }

#endif
