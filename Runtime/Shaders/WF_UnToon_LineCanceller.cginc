/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2024 whiteflare.
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

#ifndef INC_UNLIT_WF_UNTOON_LINE_CANCELLER
#define INC_UNLIT_WF_UNTOON_LINE_CANCELLER

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4  vertex              : POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_canceller {
        float4  vs_vertex           : SV_POSITION;
        float4  uv_grab             : TEXCOORD0;
        float3  ws_vertex           : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct v2f {    // dummy
        float4  vs_vertex           : SV_POSITION;
        float2  uv                  : TEXCOORD0;
    };

    struct drawing {    // dummy
        half4   color;
        float2  uv_main;
    };

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // アウトラインキャンセラ用 vertex&fragment shader
    ////////////////////////////

    DECL_GRAB_TEX2D(_TL_CANCEL_GRAB_TEXTURE);

    v2f_canceller vert_outline_canceller(appdata v) {
        v2f_canceller o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_canceller, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.ws_vertex     = UnityObjectToWorldPos(v.vertex.xyz);
#ifndef _WF_MAIN_Z_SHIFT
        o.vs_vertex     = UnityObjectToClipPos(v.vertex);   // 通常の ToClipPos を使う
#else
        o.vs_vertex     = shiftDepthVertex(o.ws_vertex, _WF_MAIN_Z_SHIFT);     // Zシフトした値を使う
#endif
        affectNearClipCancel(o.vs_vertex);
        o.uv_grab       = ComputeGrabScreenPos(o.vs_vertex);

        return o;
    }

    half4 frag_outline_canceller(v2f_canceller i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        i.uv_grab.xy /= i.uv_grab.w;
        return PICK_GRAB_TEX2D(_TL_CANCEL_GRAB_TEXTURE, i.uv_grab.xy);
    }

#endif
