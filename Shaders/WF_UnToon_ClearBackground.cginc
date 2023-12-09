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
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR0;
#endif
        float2 uv               : TEXCOORD0;
        float2 uv_lmap          : TEXCOORD1;
        float3 normal           : NORMAL;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_clrbg {
        float4 vs_vertex        : SV_POSITION;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR0;
#endif
        float2 uv               : TEXCOORD0;
        float2 uv_lmap          : TEXCOORD1;
        float3 ws_vertex        : TEXCOORD2;
        float2 depth            : TEXCOORD3;
        float3 normal           : TEXCOORD4;
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
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif
        o.uv = v.uv;
        o.uv_lmap = v.uv_lmap;
        o.depth = o.vs_vertex.zw;

        localNormalToWorldTangentSpace(v.normal, o.normal);

#if defined(UNITY_REVERSED_Z)
        o.vs_vertex.z = o.vs_vertex.w * 1e-5;
#else
        o.vs_vertex.z = o.vs_vertex.w * (1 - 1e-5);
#endif

        return o;
    }

    fixed4 frag_clrbg(v2f_clrbg i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex.xy);

        float depth = i.depth.x / i.depth.y;
#if defined(UNITY_REVERSED_Z)
        if (depth <= 0 || 1 <= depth) {
            discard;
            return fixed4(0, 0, 0, 0);
        }
#else
        if (depth <= -1 || 1 <= depth) {
            discard;
            return fixed4(0, 0, 0, 0);
        }
#endif

        float4 color;
        float2 uv_main;

        i.normal = normalize(i.normal);

        // メイン
        affectBaseColor(i.uv, i.uv_lmap, facing, uv_main, color);
        // 頂点カラー
        affectVertexColor(i.vertex_color, color);

        // アルファマスク適用
        affectAlphaMask(uv_main, color);

        // BumpMap
        float3 ws_normal = i.normal;

        // ビューポイントへの方向
        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        // カメラへの方向
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);

        // 背景消去
        float4 cube_color = PICK_MAIN_TEXCUBE_LOD(unity_SpecCube0, -ws_camera_dir, 0);
        color.rgb = DecodeHDR(cube_color, float4(1, unity_SpecCube0_HDR.yzw));

        // フレネル
        affectFresnelAlpha(uv_main, ws_normal, ws_view_dir, color);

        return fixed4(color.rgb, 1);
    }

#endif
