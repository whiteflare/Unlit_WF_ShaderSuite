/*
 *  The MIT License
 *
 *  Copyright 2018-2021 whiteflare.
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
        float4 vertex           : POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_canceller {
        float4      vs_vertex   : SV_POSITION;
        float4      uv_grab     : TEXCOORD0;
        float3      ws_vertex   : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // アウトラインキャンセラ用 vertex&fragment shader
    ////////////////////////////

    sampler2D _TL_CANCEL_GRAB_TEXTURE;

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
        o.uv_grab       = o.vs_vertex;
        o.uv_grab.xy    = ComputeGrabScreenPos(o.vs_vertex);

        return o;
    }

    float4 frag_outline_canceller(v2f_canceller i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        return tex2Dproj(_TL_CANCEL_GRAB_TEXTURE, UNITY_PROJ_COORD(i.uv_grab));
    }

#endif
