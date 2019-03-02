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

#ifndef INC_UNLIT_WF_FAKEFUR
#define INC_UNLIT_WF_FAKEFUR

    /*
     * authors:
     *      ver:2019/03/02 whiteflare,
     */

    #include "WF_Common.cginc"

    struct appdata_fur {
        float4 vertex   : POSITION;
        float3 normal   : NORMAL;
        float4 tangent  : TANGENT;
        float2 uv       : TEXCOORD0;
        float2 uv2      : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2g {
        float4 vertex   : POSITION;
        float3 normal   : NORMAL;
        float2 uv       : TEXCOORD0;
        float2 uv2      : TEXCOORD1;
        float3 waving   : TEXCOORD2;
        #ifndef _GL_LEVEL_OFF
            float lightPower    : COLOR1;
        #endif
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct g2f {
        float4 vertex   : SV_POSITION;
        float2 uv       : TEXCOORD0;
        float2 uv2      : TEXCOORD1;
        float  height   : COLOR0;
        #ifndef _GL_LEVEL_OFF
            float lightPower    : COLOR1;
        #endif
        UNITY_FOG_COORDS(2)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    sampler2D   _MainTex;
    float4      _MainTex_ST;
    float       _CutOffLevel;

    sampler2D   _FurMaskTex;
    sampler2D   _FurNoiseTex;
    float4      _FurNoiseTex_ST;
    float       _FurHeight;
    float       _FurShadowPower;
    uint        _FurRepeat;
    float4      _FurVector;

    float4      _WaveSpeed;
    float4      _WaveScale;
    float4      _WavePosFactor;

    v2g vert_fakefur(appdata_fur v) {
        v2g o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vertex = v.vertex;
        o.normal = v.normal;
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.uv2 = TRANSFORM_TEX(v.uv2, _FurNoiseTex);

        float3 tangent = v.tangent.xyz;
        float3 bitangent = cross(v.normal, tangent);
        float3x3 tangentTransform = float3x3(tangent, bitangent, o.normal);

        #ifdef _WV_ENABLE
            float3 ls_normal = _WaveScale.xyz * sin( _Time.y * _WaveSpeed - dot(v.vertex.xyz, _WavePosFactor.xyz) ) / 2;
            o.waving = mul(ls_normal + _FurVector.xyz, tangentTransform);
        #else
            o.waving = mul(_FurVector.xyz, tangentTransform);
        #endif

		SET_ANTIGLARE_LEVEL(v.vertex, o.lightPower);

        return o;
    }

    inline g2f initGeomOutput(v2g p) {
        g2f o;
        UNITY_INITIALIZE_OUTPUT(g2f, o);
        UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(g2f, o);
        o.uv = p.uv;
        o.uv2 = p.uv2;
        #ifndef _GL_LEVEL_OFF
            o.lightPower = p.lightPower;
        #endif
        return o;
    }

    inline void transferGeomVertex(inout g2f o, float4 vb, float4 vu, float height) {
        o.vertex = UnityObjectToClipPos( lerp(vb, vu, height) );
        o.height = height;
        UNITY_TRANSFER_FOG(o, o.vertex);
    }

    inline v2g lerp_v2g(v2g x, v2g y, float div) {
        v2g o;
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        o.vertex    = lerp(x.vertex,    y.vertex,   div);
        o.normal    = lerp(x.normal,    y.normal,   div);
        o.uv        = lerp(x.uv,        y.uv,       div);
        o.uv2       = lerp(x.uv2,       y.uv2,      div);
        o.waving    = lerp(x.waving,    y.waving,   div);
        #ifndef _GL_LEVEL_OFF
            o.lightPower = lerp(x.lightPower, y.lightPower, div);
        #endif
        return o;
    }

    void fakefur(v2g v[3], inout TriangleStream<g2f> triStream) {
        float4 vb[3] = { v[0].vertex, v[1].vertex, v[2].vertex };
        float4 vu[3] = vb;
        {
            for (uint i = 0; i < 3; i++) {
                vu[i].xyz += (normalize(v[i].normal) + v[i].waving.xyz) * _FurHeight;
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

        float4 vb[3] = { v[0].vertex, v[1].vertex, v[2].vertex };
        float4 vu[3] = vb;
        {
            for (uint i = 0; i < 3; i++) {
                vu[i].xyz += (normalize(v[i].normal) + v[i].waving.xyz) * _FurHeight;
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

    fixed4 frag_fakefur(g2f i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float4 maskTex = tex2D(_FurMaskTex, i.uv);
        if (maskTex.r < 0.01 || maskTex.r <= i.height) {
            discard;
        }

        float4 mainTex = tex2D(_MainTex, i.uv);
        float4 color = float4(mainTex.rgb, 1);

        // 色変換
        affectColorChange(color);

        // Anti-Glare
        affectAntiGlare(i.lightPower, color);

        float3 noise = tex2D(_FurNoiseTex, i.uv2).rgb;
        color = saturate( float4( color - (1 - noise) * _FurShadowPower, calcBrightness(noise) - pow(i.height, 3)) );

        UNITY_APPLY_FOG(i.fogCoord, color);
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
