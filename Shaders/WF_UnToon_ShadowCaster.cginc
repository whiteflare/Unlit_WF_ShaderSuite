﻿/*
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

    #include "WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct v2f_shadow {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    #ifdef _WF_DEPTHONLY_BRP
        float _GL_DepthOnlyWidth;
        float _GL_DepthOnlyVRCCam;
        float _VRChatCameraMode;
    #endif

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_shadow vert_shadow(appdata_base v) {
        v2f_shadow o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_shadow, o);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

#ifdef _TL_ENABLE
        if (TGL_ON(_TL_Enable)) {
            float3 ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
            ws_vertex = shiftNormalVertex(ws_vertex, normalize(v.normal), getOutlineShiftWidth(o.uv));
            v.vertex.xyz = UnityWorldToObjectPos(ws_vertex);
        }
#endif
#ifdef _WF_DEPTHONLY_BRP
        if (0 < _GL_DepthOnlyWidth) {
            float3 ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
            ws_vertex = shiftNormalVertex(ws_vertex, normalize(v.normal), _GL_DepthOnlyWidth);
            v.vertex.xyz = UnityWorldToObjectPos(ws_vertex);
        }
#endif

        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

#ifndef _WF_DEPTHONLY_BRP
        if (TGL_OFF(_GL_CastShadow)) {
            o.pos = DISCARD_VS_VERTEX_ZERO;
            return o;
        }
#else
        if (TGL_ON(_GL_DepthOnlyVRCCam) && _VRChatCameraMode == 0) {
            o.pos = DISCARD_VS_VERTEX_ZERO;
            return o;
        }
#endif
#ifdef _GL_NCC_ENABLE
        if (TGL_ON(_GL_NCC_Enable)) {
            affectNearClipCancel(o.pos);
        }
#endif
        return o;
    }

    float4 frag_shadow_caster(v2f_shadow i) {
        SHADOW_CASTER_FRAGMENT(i)
    }

    float4 frag_shadow(v2f_shadow i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.pos);

        if (TGL_OFF(_GL_CastShadow)) {
            discard;
            return float4(0, 0, 0, 0);
        }

        // アルファ計算
        #ifdef _AL_ENABLE
            float4 color = PICK_MAIN_TEX2D(_MainTex, i.uv) * _Color;
            affectAlphaMask(i.uv, color);
            #if defined(_WF_ALPHA_BLEND)
            if (color.a < _GL_ShadowCutoff) {
                discard;
                return float4(0, 0, 0, 0);
            }
            #endif
        #endif

        // ディゾルブの考慮
        #ifdef _DSV_ENABLE
            if (TGL_ON(_DSV_Enable) && _DSV_Dissolve < 1 - 0.05) {
                discard;
                return float4(0, 0, 0, 0);
            }
        #endif

        return frag_shadow_caster(i);
    }

    float4 frag_shadow_hidden(v2f_shadow i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        discard;
        return float4(0, 0, 0, 0);
    }


#endif
