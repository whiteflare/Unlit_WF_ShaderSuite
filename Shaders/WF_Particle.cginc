/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
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

#ifndef INC_UNLIT_WF_PARTICLE
#define INC_UNLIT_WF_PARTICLE

    ////////////////////////////
    // uniform variable
    ////////////////////////////

#ifdef _PF_ENABLE
    #define _FLIPBOOK_BLENDING
#endif

    #include "WF_INPUT_UnToon.cginc"
    #include "UnityStandardParticleInstancing.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4  vertex              : POSITION;
        half4   vertex_color        : COLOR0;
#ifndef _PF_ENABLE
        float2  uv                  : TEXCOORD0;
#else
        float4  uv                  : TEXCOORD0;
        float   uv2                 : TEXCOORD1;
#endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4  vs_vertex           : SV_POSITION;
        half4   vertex_color        : COLOR0;
#ifndef _WF_FORCE_UNLIT
        half3   light_color         : COLOR1;
#endif
        float2  uv                  : TEXCOORD0;
#ifdef _PF_ENABLE
        float3  uv2                 : TEXCOORD1;
#endif
        float3  ws_vertex           : TEXCOORD2;
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f

    struct drawing {
        half4   color;
        float2  uv1;
        float2  uv2;
        float2  uv_main;
#ifdef _PF_ENABLE
        float3  uv_flip;
#endif
        float3  ws_vertex;
#ifndef _WF_FORCE_UNLIT
        half3   light_color;
#endif
        uint    facing;
        half4   vertex_color;
    };

    drawing prepareDrawing(IN_FRAG i, uint facing) {
        drawing d = (drawing) 0;

        d.color         = half4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv2           = i.uv; // EmissiveScroll用にUV2を確保
        d.uv_main       = i.uv;
#ifdef _PF_ENABLE
        d.uv_flip       = i.uv2; // uv2ではなくuv_flipに設定
#endif
        d.facing        = facing;
        d.ws_vertex     = i.ws_vertex;
        d.vertex_color  = i.vertex_color;
#ifndef _WF_FORCE_UNLIT
        d.light_color   = i.light_color;
#endif
        return d;
    }

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    void prepareParticleMainTex(IN_FRAG i, inout drawing d) {
#ifndef _PF_ENABLE
        d.uv_main = i.uv;
#else
        d.uv_main = TRANSFORM_TEX(i.uv, _MainTex);
#endif
    }

    uint            _PA_VCBlendType;
    half            _PA_Z_Offset;

    void drawParticleVertexColor(inout drawing d) {
        switch(_PA_VCBlendType) {
            case 0:
                d.color *= d.vertex_color;
                break;
            case 1:
                d.color.rgb += d.vertex_color.rgb;
                d.color.a *= d.vertex_color.a;
                break;
            case 2:
                d.color.rgb -= d.vertex_color.rgb;
                d.color.a *= d.vertex_color.a;
                break;
        }
        d.color = max(ZERO_VEC4, d.color);
    }

    void drawParticleFlipbookTex(inout drawing d) {
#ifdef _PF_ENABLE
        half4 color2 = PICK_MAIN_TEX2D(_MainTex, d.uv_flip.xy);
        d.color = lerp(d.color, color2, d.uv_flip.z);
#endif
    }

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f vert(in appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
#ifndef _WF_MAIN_Z_SHIFT
        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);   // 通常の ToClipPos を使う
#else
        o.vs_vertex = shiftDepthVertex(o.ws_vertex, _WF_MAIN_Z_SHIFT);      // Zシフトした値を使う
#endif

#ifdef UNITY_PARTICLE_INSTANCING_ENABLED
        vertInstancingColor(o.vertex_color);
    #ifndef _PF_ENABLE
        vertInstancingUVs(v.uv, o.uv);
    #else
        vertInstancingUVs(v.uv, o.uv, o.uv2);
    #endif
#else
        o.vertex_color = v.vertex_color;
    #ifndef _PF_ENABLE
        o.uv = v.uv.xy;
    #else
        o.uv = v.uv.xy;
        o.uv2 = float3(v.uv.z, v.uv.w, v.uv2.x);
    #endif
#endif

#ifndef _WF_FORCE_UNLIT
        // 環境光取得
        float3 ambientColor = sampleSHLightColor();
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(o.ws_vertex, ambientColor);
#endif

        UNITY_TRANSFER_FOG(o, o.vs_vertex);

        return o;
    }

    half4 frag(v2f i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        drawing d = prepareDrawing(i, facing);
        d.color = _Color;

        prepareParticleMainTex(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawParticleFlipbookTex(d); // Particleテクスチャシートアニメーション
        drawParticleVertexColor(d); // 頂点カラー

#ifdef _WF_PREMUL_ALPHA
        d.color.rgb *= d.color.a;
#endif

        drawAlphaMask(d);           // アルファ

#ifndef _WF_FORCE_UNLIT
        // Anti-Glare とライト色ブレンドを同時に計算
        d.color.rgb *= d.light_color;
#endif

        drawEmissiveScroll(d);      // エミッション
        drawFresnelAlpha(d);        // フレネル

        // fog
#ifdef _WF_CUSTOM_FOG_COLOR
        UNITY_APPLY_FOG_COLOR(i.fogCoord, d.color, _WF_CUSTOM_FOG_COLOR);
#else
        UNITY_APPLY_FOG(i.fogCoord, d.color);
#endif
        // Alpha は 0-1 にクランプ
        d.color.a = saturate(d.color.a);

        return d.color;
    }

#endif
