/*
 *  The MIT License
 *
 *  Copyright 2018-2020 whiteflare.
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

    /*
     * authors:
     *      ver:2020/10/13 whiteflare,
     */

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
        float3 ws_tangent       : TEXCOORD3;
        float3 ws_bitangent     : TEXCOORD4;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct g2f {
        float2 uv               : TEXCOORD0;
        float3 ws_vertex        : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        UNITY_VERTEX_OUTPUT_STEREO
        float height            : COLOR0;
        float4 vertex           : SV_POSITION;
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
        o.ws_vertex = UnityObjectToWorldPos(v.vertex);
        localNormalToWorldTangentSpace(v.normal, v.tangent, o.ws_normal, o.ws_tangent, o.ws_bitangent, _FG_FlipTangent);

        return o;
    }

    inline g2f initGeomOutput(v2g p) {
        g2f o;
        UNITY_INITIALIZE_OUTPUT(g2f, o);
        UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(g2f, o);
        o.uv                = p.uv;
        o.ws_vertex         = p.ws_vertex;
        o.ws_normal         = p.ws_normal;
        return o;
    }

    inline void transferGeomVertex(inout g2f o, float3 vb, float3 vu, float height) {
        o.ws_vertex = lerp(vb, vu, height);
        o.vertex = UnityWorldToClipPos( o.ws_vertex );
        o.height = height;
    }

    inline v2g lerp_v2g(v2g x, v2g y, float div) {
        v2g o;
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        o.uv                = lerp(x.uv,            y.uv,               div);
        o.ws_vertex         = lerp(x.ws_vertex,     y.ws_vertex,        div);
        o.ws_normal         = lerp(x.ws_normal,     y.ws_normal,        div);
        o.ws_tangent        = lerp(x.ws_tangent,    y.ws_tangent,       div);
        o.ws_bitangent      = lerp(x.ws_bitangent,  y.ws_bitangent,     div);
        return o;
    }

    float3 calcFurVector(v2g v[3], uint i) {
        // Tangent Transform 計算
        float3x3 tangentTransform = float3x3(v[i].ws_tangent, v[i].ws_bitangent, v[i].ws_normal);

        // Static Fur Vector 計算
        float3 vec_fur = SafeNormalizeVec3Normal(_FR_Vector.xyz);

#ifndef _FR_DISABLE_NORMAL_MAP
        // NormalMap Fur Vector 計算
        float2 uv_main = TRANSFORM_TEX(v[i].uv, _MainTex);
        float3 vec_map = UnpackNormal(tex2Dlod(_FG_BumpMap, float4(uv_main.x, uv_main.y, 0, 0)));
        vec_fur = BlendNormals(vec_fur, vec_map);
#endif

        return mul(vec_fur , tangentTransform);
    }

    void fakefur(v2g v[3], inout TriangleStream<g2f> triStream) {
        // 底辺座標
        float3 vb[3] = { v[0].ws_vertex, v[1].ws_vertex, v[2].ws_vertex };
        // 頂点座標
        float3 vu[3] = vb;

        // normal方向に従ってfurを伸ばす
        {
            for (uint i = 0; i < 3; i++) {
                // 法線 * ファー高さぶんだけ頂点移動
                vu[i].xyz += calcFurVector(v, i) * _FR_Height;
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

    [maxvertexcount(64)]
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
        i.uv = gi.uv;
        i.ws_vertex = gi.ws_vertex;
        i.normal = gi.ws_normal;

        i.ws_light_dir = calcWorldSpaceLightDir(i.ws_vertex);

        // 環境光取得
        float3 ambientColor = sampleSHLightColor();
        // 影コントラスト
        calcToonShadeContrast(i.ws_vertex, i.ws_light_dir, ambientColor, i.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        i.light_color = calcLightColorVertex(i.ws_vertex, ambientColor);

        // メイン
        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        float4 color = PICK_MAIN_TEX2D(_MainTex, uv_main) * _Color;

        // 色変換
        affectColorChange(color);

        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i.ws_vertex, i.ws_light_dir);
        // 階調影
        affectToonShade(i, uv_main, i.normal, i.normal, angle_light_camera, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // Alpha
        affectAlpha(uv_main, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        float4 maskTex = tex2D(_FR_MaskTex, uv_main);
        if (maskTex.r < 0.01 || maskTex.r <= gi.height) {
            discard;
        }

        // ファーノイズを追加
        float3 noise = tex2D(_FR_NoiseTex, TRANSFORM_TEX(i.uv, _FR_NoiseTex)).rgb;
        color = saturate( float4( color - (1 - noise) * _FR_ShadowPower, calcBrightness(noise) - pow(gi.height, 4)) );

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
