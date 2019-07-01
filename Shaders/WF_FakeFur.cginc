/*
 *  The MIT License
 *
 *  Copyright 2018-2019 whiteflare.
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
     *      ver:2019/05/26 whiteflare,
     */

    #include "WF_Common.cginc"

    struct appdata_fur {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float3 normal           : NORMAL;
        float4 tangent          : TANGENT;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2g {
        float2 uv               : TEXCOORD0;
        float4 ls_vertex        : TEXCOORD1;
        float3 normal           : TEXCOORD2;
        UNITY_VERTEX_OUTPUT_STEREO
        float2 uv2              : TEXCOORD3;
        float3 waving           : TEXCOORD4;
    };

    struct g2f {
        float2 uv               : TEXCOORD0;
        float4 ls_vertex        : TEXCOORD1;
        float3 normal           : TEXCOORD2;
        UNITY_VERTEX_OUTPUT_STEREO
        float2 uv2              : TEXCOORD3;
        float height            : COLOR0;
        float4 vertex           : SV_POSITION;
    };

    float       _CutOffLevel;

    sampler2D   _FurMaskTex;
    sampler2D   _FurNoiseTex;
    float4      _FurNoiseTex_ST;
    float       _FurHeight;
    float       _FurShadowPower;
    uint        _FurRepeat;
    float4      _FurVector;

    v2g vert_fakefur(appdata_fur v) {
        v2g o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.ls_vertex = v.vertex;
        o.normal = normalize(v.normal.xyz);
        o.uv2 = TRANSFORM_TEX(v.uv, _FurNoiseTex);

        float3 tangent = normalize(v.tangent.xyz);
        float3 bitangent = cross(o.normal, tangent) * v.tangent.w;
        float3x3 tangentTransform = float3x3(tangent, bitangent, o.normal);
        o.waving = mul(_FurVector.xyz, tangentTransform);

        return o;
    }

    inline g2f initGeomOutput(v2g p) {
        g2f o;
        UNITY_INITIALIZE_OUTPUT(g2f, o);
        UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(g2f, o);
        o.uv                = p.uv;
        o.ls_vertex         = p.ls_vertex;
        o.normal            = p.normal;
        o.uv2               = p.uv2;
        return o;
    }

    inline void transferGeomVertex(inout g2f o, float4 vb, float4 vu, float height) {
        o.ls_vertex = lerp(vb, vu, height);
        o.vertex = UnityObjectToClipPos( o.ls_vertex );
        o.height = height;
    }

    inline v2g lerp_v2g(v2g x, v2g y, float div) {
        v2g o;
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        o.uv                = lerp(x.uv,            y.uv,               div);
        o.ls_vertex         = lerp(x.ls_vertex,     y.ls_vertex,        div);
        o.normal            = lerp(x.normal,        y.normal,           div);
        o.uv2               = lerp(x.uv2,           y.uv2,              div);
        return o;
    }

    void fakefur(v2g v[3], inout TriangleStream<g2f> triStream) {
        float4 vb[3] = { v[0].ls_vertex, v[1].ls_vertex, v[2].ls_vertex };
        float4 vu[3] = vb;
        {
            for (uint i = 0; i < 3; i++) {
                vu[i].xyz += (v[i].normal.xyz + v[i].waving.xyz) * _FurHeight;
            }
        }
        {
            // 1回あたり8頂点
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

        float4 vb[3] = { v[0].ls_vertex, v[1].ls_vertex, v[2].ls_vertex };
        float4 vu[3] = vb;
        {
            for (uint i = 0; i < 3; i++) {
                vu[i].xyz += (v[i].normal.xyz + v[i].waving.xyz) * _FurHeight;
            }
        }
        {
            v2g c = lerp_v2g(v[0], lerp_v2g(v[1], v[2], 0.5), 2.0 / 3.0);
            for (uint i = 0; i < _FurRepeat; i++) {
                float rate = i / (float) _FurRepeat;
                v2g v2[3] = { lerp_v2g(v[0], c, rate), lerp_v2g(v[1], c, rate), lerp_v2g(v[2], c, rate) };
                fakefur(v2, triStream);
            }
        }
    }

    fixed4 frag_fakefur(g2f gi) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        v2f i = (v2f) 0;
        i.uv = gi.uv;
        i.ls_vertex = gi.ls_vertex;
        i.normal = gi.normal;
        i.ls_light_dir = calcLocalSpaceLightDir( float4(0, 0, 0, i.ls_vertex.w) );

        // 環境光取得
        float3 ambientColor = OmniDirectional_ShadeSH9();
        // 影コントラスト
        calcToonShadeContrast(i.ls_vertex, i.ls_light_dir, ambientColor, i.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        i.light_color = calcLightColorVertex(i.ls_vertex, ambientColor);

        // メイン
        float4 color = PICK_MAIN_TEX2D(_MainTex, i.uv) * _Color;

        // 色変換
        affectColorChange(color);

        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i);
        // 階調影
        affectToonShade(i, i.normal, i.normal, angle_light_camera, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // Alpha
        affectAlpha(i.uv, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        float4 maskTex = tex2D(_FurMaskTex, i.uv);
        if (maskTex.r < 0.01 || maskTex.r <= gi.height) {
            discard;
        }

        float3 noise = tex2D(_FurNoiseTex, gi.uv2).rgb;
        color = saturate( float4( color - (1 - noise) * _FurShadowPower, calcBrightness(noise) - pow(gi.height, 3)) );

        return color;
    }

    fixed4 frag_fakefur_cutoff(g2f i) : SV_Target {
        float4 color = frag_fakefur(i);
        if (color.a < _CutOffLevel) {
            discard;
        }
        return color;
    }

#endif
