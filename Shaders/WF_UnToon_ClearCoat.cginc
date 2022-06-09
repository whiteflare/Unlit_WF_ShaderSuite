/*
 *  The MIT License
 *
 *  Copyright 2018-2022 whiteflare.
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

#ifndef INC_UNLIT_WF_UNTOON_CLEARCOAT
#define INC_UNLIT_WF_UNTOON_CLEARCOAT

    #include "WF_UnToon.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    float _CC_Width;
    float _CC_Z_Shift;

    // vertex シェーダでアウトラインメッシュを張るタイプ。NORMALのみサポートする。
    v2f vert_clearcoat(appdata v) {
        // 通常の vert を使う
        v2f o = vert(v);
        // SV_POSITION を上書き
        o.vs_vertex = shiftNormalAndDepthVertex(o.ws_vertex, o.normal, _CC_Width * 0.001, -_CC_Z_Shift);

        return o;
    }

    float4 frag_clearcoat(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);

        i.normal = normalize(i.normal);
#ifdef _V2F_HAS_TANGENT
        i.tangent = normalize(i.tangent);
        i.bitangent = normalize(i.bitangent);
#endif

        // メイン
        float4 color = float4(0, 0, 0, 1);

        // BumpMap
        float3 ws_normal = i.normal;
        float3 ws_bump_normal;
        float3 ws_detail_normal;
        affectBumpNormal(i, uv_main, ws_bump_normal, color);
        affectDetailNormal(i, uv_main, ws_detail_normal, color);

        // ビューポイントへの方向
        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        // カメラへの方向
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);

        // matcapベクトルの配列
        WF_TYP_MATVEC matcapVector = calcMatcapVectorArray(ws_view_dir, ws_camera_dir, ws_normal, ws_bump_normal, ws_detail_normal);

        // メタリック
        affectMetallic(i, ws_camera_dir, uv_main, ws_normal, ws_bump_normal, ws_detail_normal, color);
        // Highlight
        affectMatcapColor(matcapVector, uv_main, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;
        // Ambient Occlusion
        affectOcclusion(i, uv_main, color);

        return color;
    }

#endif
