/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2025 whiteflare.
 *
 *  This software is provided ‘as-is’, without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
 */

#ifndef INC_UNLIT_WF_UNTOON_SHADOWCASTER
#define INC_UNLIT_WF_UNTOON_SHADOWCASTER

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "../WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4  vertex              : POSITION;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color        : COLOR0;
#endif
        float2  uv                  : TEXCOORD0;
        float2  uv2                 : TEXCOORD1;
        half3   normal              : NORMAL;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct v2f_shadow {
        float4  pos                 : SV_POSITION;
        float2  uv                  : TEXCOORD1;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color        : COLOR0;
#endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f_shadow

    struct drawing {
        half4   color;
        float2  uv1;
        float2  uv_main;
    };

    drawing prepareDrawing(IN_FRAG i) {
        drawing d = (drawing) 0;

        d.color         = half4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;

        return d;
    }

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "../WF_UnToon_Function.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

#ifndef UNIVERSAL_SHADOWS_INCLUDED
    float4 _ShadowBias;
#endif

    float3 _LightDirection;

    float4 GetShadowPositionHClip(appdata input) {
        float3 positionWS = UnityObjectToWorldPos(input.vertex.xyz);
        float3 normalWS = UnityObjectToWorldNormal(input.normal);

#ifdef UNIVERSAL_SHADOWS_INCLUDED

        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

#else   // LIGHTWEIGHT_SHADOWS_INCLUDED

        float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
        float scale = invNdotL * _ShadowBias.y;

        // normal bias is negative since we want to apply an inset normal offset
        positionWS = _LightDirection * _ShadowBias.xxx + positionWS;
        positionWS = normalWS * scale.xxx + positionWS;
        float4 positionCS = TransformWorldToHClip(positionWS);

#endif

#if UNITY_REVERSED_Z
        positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
        positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

        return positionCS;
    }

    v2f_shadow vert_shadow(appdata v) {
        v2f_shadow o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_shadow, o);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.pos = GetShadowPositionHClip(v);
        if (TGL_OFF(_GL_CastShadow)) {
            // 無効化
            o.pos = DISCARD_VS_VERTEX_ZERO;
        }
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif

        return o;
    }

    half4 frag_shadow(v2f_shadow i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        if (TGL_OFF(_GL_CastShadow)) {
            discard;
            return half4(0, 0, 0, 0);
        }

        drawing d = prepareDrawing(i);
        d.color = _Color;

        prepareMainTex(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawVertexColor(d);         // 頂点カラー

        // アルファ計算
        #ifdef _AL_ENABLE
            drawAlphaMask(d);       // アルファ
            #if defined(_WF_ALPHA_BLEND)
            if (d.color.a < _GL_ShadowCutoff) {
                discard;
                return half4(0, 0, 0, 0);
            }
            #endif
        #endif

        return half4(0, 0, 0, 0);
    }

#endif
