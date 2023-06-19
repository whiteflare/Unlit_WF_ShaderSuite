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

#ifndef INC_UNLIT_WF_UNTOON_CLEARBACK
#define INC_UNLIT_WF_UNTOON_CLEARBACK

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata_clrbg {
        float4 vertex           : POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_clrbg {
        float4 vs_vertex        : SV_POSITION;
        float3 ws_vertex        : TEXCOORD0;
        float2 depth            : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_clrbg vert_clrbg(appdata_clrbg v) {
        v2f_clrbg o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_clrbg, o);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);
        o.depth = o.vs_vertex.zw;

#if defined(UNITY_REVERSED_Z)
        o.vs_vertex.z = o.vs_vertex.w * 1e-5;
#else
        o.vs_vertex.z = o.vs_vertex.w * (1 - 1e-5);
#endif

        return o;
    }

    fixed4 frag_clrbg(v2f_clrbg i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex.xy);

        float depth = i.depth.x / i.depth.y;
#if defined(UNITY_REVERSED_Z)
        if (depth <= 0 || 1 <= depth) {
            discard;
        }
#else
        if (depth <= -1 || 1 <= depth) {
            discard;
        }
#endif

        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);
        float4 color = PICK_MAIN_TEXCUBE_LOD(unity_SpecCube0, -ws_camera_dir, 0);
        color.rgb = DecodeHDR(color, float4(1, unity_SpecCube0_HDR.yzw));

        return fixed4(color.rgb, 1);
    }

#endif
