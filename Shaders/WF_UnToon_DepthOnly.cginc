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

#ifndef INC_UNLIT_WF_UNTOON_DEPTHONLY
#define INC_UNLIT_WF_UNTOON_DEPTHONLY

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4 vertex           : POSITION;
#ifdef _VC_ENABLE
        float4 vertex_color     : COLOR0;
#endif
        float2 uv               : TEXCOORD0;
        float2 uv_lmap          : TEXCOORD1;
        float3 normal           : NORMAL;
#ifdef _NM_ENABLE
            float4 tangent      : TANGENT;
#endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_depth {
        float4 pos              : SV_POSITION;
        float2 uv               : TEXCOORD0;
#ifdef _VC_ENABLE
        float4 vertex_color     : COLOR0;
#endif
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

    v2f_depth vert_depth(appdata i) {
        v2f_depth o;

        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_INITIALIZE_OUTPUT(v2f_depth, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.pos   = UnityObjectToClipPos(i.vertex.xyz);
        o.uv    = TRANSFORM_TEX(i.uv, _MainTex);
#ifdef _VC_ENABLE
        o.vertex_color = i.vertex_color;
#endif

        return o;
    }

    float4 frag_depth(v2f_depth i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        // アルファ計算
        #ifdef _AL_ENABLE
            float4 color;
            float2 uv_main;

            // メイン
            affectBaseColor(i.uv, facing, uv_main, color);
            // 頂点カラー
            affectVertexColor(i.vertex_color, color);

            // アルファマスク
            affectAlphaMask(uv_main, color);

            if (color.a < 0.5) {
                discard;
                return ZERO_VEC4;
            }
        #endif

        return ZERO_VEC4;
    }

#endif
