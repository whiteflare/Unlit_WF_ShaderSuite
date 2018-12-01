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
     *      ver:2018/11/29 whiteflare,
     */

    struct appdata {
        float4 vertex   : POSITION;
        float2 uv       : TEXCOORD0;
    };

    struct v2f {
        float4 vertex   : SV_POSITION;
        float2 uv       : TEXCOORD0;
        #ifndef _GL_LEVEL_OFF
            float lightPower    : COLOR0;
        #endif
        UNITY_FOG_COORDS(2)
    };

    struct appdata_fur {
        float4 vertex   : POSITION;
        float3 normal   : NORMAL;
        float4 tangent  : TANGENT;
        float2 uv       : TEXCOORD0;
        float2 uv2      : TEXCOORD1;
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
    };

    uniform sampler2D   _MainTex;
    uniform float4      _MainTex_ST;
    uniform float       _CutOffLevel;

    uniform sampler2D   _FurMaskTex;
    uniform sampler2D   _FurNoiseTex;
    uniform float4      _FurNoiseTex_ST;
    uniform float       _FurHeight;
    uniform float       _FurShadowPower;
    uniform uint        _FurRepeat;
    uniform float4      _FurVector;

    uniform float4      _WaveSpeed;
    uniform float4      _WaveScale;
    uniform float4      _WavePosFactor;

    inline float calcBrightness(float3 color) {
        static float3 BT709 = { 0.21, 0.72, 0.07 };
        return dot(color, BT709);
    }

    inline float3 OmniDirectional_ShadeSH9() {
        // UnityCG.cginc にある ShadeSH9 の等方向版
        float3 col = 0;
        col = max(col, ShadeSH9( float4(+1, +0, +0, 1) ));
        col = max(col, ShadeSH9( float4(+0, +1, +0, 1) ));
        col = max(col, ShadeSH9( float4(+0, +0, +1, 1) ));
        col = max(col, ShadeSH9( float4(-1, -0, -0, 1) ));
        col = max(col, ShadeSH9( float4(-0, -1, -0, 1) ));
        col = max(col, ShadeSH9( float4(-0, -0, -1, 1) ));
        return col;
    }

    inline float3 OmniDirectional_Shade4PointLights(
        float4 lpX, float4 lpY, float4 lpZ,
        float3 col0, float3 col1, float3 col2, float3 col3,
        float4 lightAttenSq, float3 ws_pos) {
        // UnityCG.cginc にある Shade4PointLights の等方向版

        float4 toLightX = lpX - ws_pos.x;
        float4 toLightY = lpY - ws_pos.y;
        float4 toLightZ = lpZ - ws_pos.z;

        float4 lengthSq
            = toLightX * toLightX
            + toLightY * toLightY
            + toLightZ * toLightZ;
        // ws_normal との内積は取らない。これによって反射光の強さではなく、頂点に当たるライトの強さが取れる。

        // attenuation
        float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);

        float3 col
            = col0 * atten.x
            + col1 * atten.y
            + col2 * atten.z
            + col3 * atten.w;
        return col;
    }

    inline float calcLightPower(float4 ls_vertex) {
        // directional light
        float3 lightColor = _LightColor0;
        #if UNITY_SHOULD_SAMPLE_SH
            // ambient
            lightColor += OmniDirectional_ShadeSH9();
            #ifdef VERTEXLIGHT_ON
                // not important lights
                lightColor += OmniDirectional_Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb,
                    unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb,
                    unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    mul(unity_ObjectToWorld, ls_vertex)
                );
            #endif
        #endif
        return calcBrightness(saturate(lightColor));
    }

    v2g vert_fakefur(appdata_fur v) {
        v2g o;
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

        #ifndef _GL_LEVEL_OFF
            o.lightPower = saturate(calcLightPower(v.vertex) * 2
                #ifdef _GL_LEVEL_BRIGHT
                    + 0.2
                #elif _GL_LEVEL_DARK
                    + 0.03
                #endif
            );
        #endif

        return o;
    }

    inline g2f initGeomOutput(v2g p) {
        g2f o;
        UNITY_INITIALIZE_OUTPUT(g2f, o);
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
        float4 maskTex = tex2D(_FurMaskTex, i.uv);
        if (maskTex.r < 0.01) {
        	discard;
        }
        if (maskTex.r <= i.height) {
            discard;
        }

        float4 mainTex = tex2D(_MainTex, i.uv);
        float4 color = float4( mainTex.rgb, 1 );

        // Anti-Glare
        #ifndef _GL_LEVEL_OFF
            color.rgb = saturate(color.rgb * i.lightPower);
        #endif

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
