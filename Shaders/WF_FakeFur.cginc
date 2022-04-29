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

#ifndef INC_UNLIT_WF_FAKEFUR
#define INC_UNLIT_WF_FAKEFUR

    #include "WF_INPUT_FakeFur.cginc"
    #include "WF_UnToon.cginc"

    struct appdata_fur {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float3 normal           : NORMAL;
        float4 tangent          : TANGENT;
        uint vid                : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2g {
        float2 uv               : TEXCOORD0;
        float3 ws_vertex        : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        float3 ws_tangent       : TEXCOORD3;
        float3 ws_bitangent     : TEXCOORD4;
        float3 ws_light_dir     : TEXCOORD5;    // ws_light_dir.w は frag では使わないので削減
        float vid               : TEXCOORD6;
        float3 light_color      : COLOR1;
#ifdef _V2F_HAS_SHADOWPOWER
        float shadow_power      : COLOR2;
#endif
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct g2f {
        float4 vertex           : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float3 ws_vertex        : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        float3 ws_light_dir     : TEXCOORD3;    // ws_light_dir.w は frag では使わないので削減
        float  height           : COLOR0;
        float3 light_color      : COLOR1;
#ifdef _V2F_HAS_SHADOWPOWER
        float shadow_power      : COLOR2;
#endif
        UNITY_VERTEX_OUTPUT_STEREO
        // フルセット 21 value なので、geometry シェーダの制限 1024 value 内では 48 vertex = 6枚のファーまで使用できる
    };

    ////////////////////////////
    // vertex & fragment shader
    ////////////////////////////

    v2g vert_fakefur(appdata_fur v) {
        v2g o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.uv = v.uv;
        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
        o.vid = (float) v.vid;

        localNormalToWorldTangentSpace(v.normal, v.tangent, o.ws_normal, o.ws_tangent, o.ws_bitangent, _FR_FlipMirror & 1, _FR_FlipMirror & 2);

        float4 ws_light_dir = calcWorldSpaceLightDir(o.ws_vertex);
        o.ws_light_dir = ws_light_dir.xyz;
        // 環境光取得
        float3 ambientColor = sampleSHLightColor();
        // 影コントラスト
        calcToonShadeContrast(o.ws_vertex, ws_light_dir, ambientColor, o.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(o.ws_vertex, ambientColor);

        return o;
    }

    g2f initGeomOutput(v2g p) {
        g2f o;
        UNITY_INITIALIZE_OUTPUT(g2f, o);
        UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(p, o);
        o.uv            = p.uv;
        o.ws_vertex     = p.ws_vertex;
        o.ws_normal     = p.ws_normal;
        o.light_color   = p.light_color;
#ifdef _V2F_HAS_SHADOWPOWER
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
        UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(x, o);
        o.uv                = lerp(x.uv,            y.uv,               div);
        o.ws_vertex         = lerp(x.ws_vertex,     y.ws_vertex,        div);
        o.ws_normal         = lerp(x.ws_normal,     y.ws_normal,        div);
        o.ws_tangent        = lerp(x.ws_tangent,    y.ws_tangent,       div);
        o.ws_bitangent      = lerp(x.ws_bitangent,  y.ws_bitangent,     div);
        o.light_color       = lerp(x.light_color,   y.light_color,      div);
#ifdef _V2F_HAS_SHADOWPOWER
        o.shadow_power      = lerp(x.shadow_power,  y.shadow_power,     div);
#endif
        o.ws_light_dir      = lerp(x.ws_light_dir,  y.ws_light_dir,     div);
        o.vid               = lerp(x.vid,           y.vid,              div);
        return o;
    }

    float3 calcFurVector(float3 ws_tangent, float3 ws_bitangent, float3 ws_normal, float2 uv) {
        // Static Fur Vector 計算
        float3 vec_fur = SafeNormalizeVec3Normal(_FR_Vector.xyz);

#ifndef _FR_DISABLE_NORMAL_MAP
        // NormalMap Fur Vector 計算
        float2 uv_main = TRANSFORM_TEX(uv, _MainTex);
        float3 vec_map = UnpackNormal( PICK_VERT_TEX2D_LOD(_FR_BumpMap, uv_main, 0) );
        vec_fur = BlendNormals(vec_fur, vec_map);
#endif

        // Tangent Transform 計算
        return transformTangentToWorldNormal(vec_fur, ws_normal, ws_tangent, ws_bitangent);
    }

    void fakefur(v2g v[3], float3 ws_fur_vector[3], inout TriangleStream<g2f> triStream) {
        // 底辺座標
        float3 vb[3] = { v[0].ws_vertex, v[1].ws_vertex, v[2].ws_vertex };
        // 頂点座標
        float3 vu[3] = vb;

        // normal方向に従ってfurを伸ばす
        {for (uint i = 0; i < 3; i++) {
            // 頂点移動
            vu[i].xyz += ws_fur_vector[i];
            if (0 < _FR_Random) {
                float2 niz = random2(ws_fur_vector[i].xy + v[i].vid) * 2 - 1;
                niz *= 0.01 * _FR_Random;  // 1cm単位で±ランダム化
                vu[i].xyz += v[i].ws_tangent * niz.x + v[i].ws_bitangent * niz.y;
            }
        }}

        // ファーを増殖
        {for (uint i = 0; i < 4; i++) {
            uint n = i % 3;
            g2f o = initGeomOutput(v[n]);
            transferGeomVertex(o, vb[n], vu[n], 0); triStream.Append(o);
            transferGeomVertex(o, vb[n], vu[n], 1); triStream.Append(o);
        }}
    }

    [maxvertexcount(48)]
    void geom_fakefur(triangle v2g v[3], inout TriangleStream<g2f> triStream) {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(v[0]);

        // ファーを伸ばす方向を計算
        float3 ws_fur_vector[3];
        {for (uint i = 0; i < 3; i++) {
            ws_fur_vector[i] = calcFurVector(v[i].ws_tangent, v[i].ws_bitangent, v[i].ws_normal, v[i].uv) * _FR_HEIGHT_PARAM;
        }}

        v2g c = lerp_v2g(v[0], lerp_v2g(v[1], v[2], 0.5), 2.0 / 3.0);
        {for (uint i = 0; i < _FR_REPEAT_PARAM; i++) {
            float rate = i / (float) _FR_REPEAT_PARAM;
            v2g v2[3] = {
                lerp_v2g(v[0], c, rate),
                lerp_v2g(v[1], c, rate),
                lerp_v2g(v[2], c, rate)
            };
            fakefur(v2, ws_fur_vector, triStream);
        }}
    }

    float4 frag_fakefur(g2f gi) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(gi);

        v2f i = (v2f) 0;
        i.uv            = gi.uv;
        i.ws_vertex     = gi.ws_vertex;
        i.normal        = normalize(gi.ws_normal);
        i.light_color   = gi.light_color;
#ifdef _V2F_HAS_SHADOWPOWER
        i.shadow_power  = gi.shadow_power;
#endif
        i.ws_light_dir  = float4(gi.ws_light_dir, 0);

        // メイン
        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        float4 color = PICK_MAIN_TEX2D(_MainTex, uv_main) * _Color;
        // アルファマスク適用
        affectAlphaMask(uv_main, color);

        // 色変換
        affectColorChange(color);

        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i.ws_vertex, i.ws_light_dir.xyz);
        // 階調影
        affectToonShade(i, uv_main, i.normal, i.normal, angle_light_camera, color);
        // Distance Fade
        affectDistanceFade(i, 1, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        float4 maskTex = SAMPLE_MASK_VALUE(_FR_MaskTex, uv_main, _FR_InvMaskVal);
        if (maskTex.r < 0.01 || maskTex.r <= gi.height) {
            discard;
        }

        // ファーノイズを追加
        float noise = PICK_MAIN_TEX2D(_FR_NoiseTex, TRANSFORM_TEX(i.uv, _FR_NoiseTex)).r;
        color.rgb   *= lerp(_FR_TintColorBase.rgb, _FR_TintColorTip.rgb, gi.height);
        color.rgb   *= saturate(1 - (1 - noise) * _FR_ShadowPower);
        color.a     = saturate(noise - pow(gi.height, 4));

        return color;
    }

    float4 frag_fakefur_cutoff(g2f i) : SV_Target {
        float4 color = frag_fakefur(i);

        color.a = smoothstep(_Cutoff - 0.0625, _Cutoff + 0.0625, color.a);
        if (TGL_OFF(_AL_AlphaToMask) && color.a < 0.5) {
            discard;
        }
        return color;
    }

#endif
