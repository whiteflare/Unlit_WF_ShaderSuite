/*
 *  The MIT License
 *
 *  Copyright 2018-2023 whiteflare.
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
        float4 vertex           : POSITION;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR0;
#endif
        float2 uv               : TEXCOORD0;
        float2 uv_lmap          : TEXCOORD1;
        float3 normal           : NORMAL;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_shadow {
        float4 pos          : SV_POSITION;
        float2 uv           : TEXCOORD1;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR0;
#endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

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
            o.pos = UnityObjectToClipPos( ZERO_VEC3 );
        }
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif

        return o;
    }

    float4 frag_shadow(v2f_shadow i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        if (TGL_OFF(_GL_CastShadow)) {
            discard;
            return ZERO_VEC4;
        }

        // アルファ計算
        #ifdef _AL_ENABLE
            float4 color = PICK_MAIN_TEX2D(_MainTex, i.uv) * _Color;
#ifdef _VC_ENABLE
            color *= i.vertex_color;
#endif
            affectAlphaMask(i.uv, color);
            if (color.a < 0.5) {
                discard;
                return float4(0, 0, 0, 0);
            }
        #endif

        return ZERO_VEC4;
    }

#endif
