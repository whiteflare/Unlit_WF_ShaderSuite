/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2026 whiteflare.
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

    #include "WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct v2f_shadow {
        V2F_SHADOW_CASTER;
        float2  uv : TEXCOORD1;
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
            ws_vertex = shiftNormalVertex(ws_vertex, UnityObjectToWorldNormal(v.normal), getOutlineShiftWidth(o.uv));
            v.vertex.xyz = UnityWorldToObjectPos(ws_vertex);
        }
#endif
#ifdef _WF_DEPTHONLY_BRP
        if (0 < _GL_DepthOnlyWidth) {
            float3 ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
            ws_vertex = shiftNormalVertex(ws_vertex, UnityObjectToWorldNormal(v.normal), _GL_DepthOnlyWidth);
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

    half4 frag_shadow_caster(v2f_shadow i) {
        SHADOW_CASTER_FRAGMENT(i)
    }

    half4 frag_shadow(v2f_shadow i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.pos);

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

        // ディゾルブの考慮
        #ifdef _DSV_ENABLE
            if (TGL_ON(_DSV_Enable) && _DSV_Dissolve < 1 - 0.05) {
                discard;
                return half4(0, 0, 0, 0);
            }
        #endif

        return frag_shadow_caster(i);
    }

    half4 frag_shadow_hidden(v2f_shadow i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        discard;
        return half4(0, 0, 0, 0);
    }


#endif
