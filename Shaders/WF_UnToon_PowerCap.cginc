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

#ifndef INC_UNLIT_WF_UNTOON_POWERCAP
#define INC_UNLIT_WF_UNTOON_POWERCAP

    #include "WF_UnToon.cginc"

    ////////////////////////////
    // Light Matcap Power
    ////////////////////////////

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    float4 frag_powercap(v2f i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float4 color;
        float2 uv_main;

        i.normal = normalize(i.normal);
#ifdef _V2F_HAS_TANGENT
        i.tangent = normalize(i.tangent);
        i.bitangent = normalize(i.bitangent);
#endif

        // メイン
        affectBaseColor(i.uv, facing, uv_main, color);
        // 頂点カラー
        affectVertexColor(i.vertex_color, color);

        // アルファマスク適用
        affectAlphaMask(uv_main, color);

        // BumpMap
        float3 ws_normal = i.normal;
        float3 ws_bump_normal;
        affectBumpNormal(i, uv_main, ws_bump_normal, color);

        // ビューポイントへの方向
        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        // カメラへの方向
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i.ws_vertex, i.ws_light_dir.xyz);

        // matcapベクトルの配列
        float4x4 matcapVector = calcMatcapVectorArray(ws_view_dir, ws_camera_dir, ws_normal, ws_bump_normal);

        // Highlight
        affectMatcapColor(matcapVector, uv_main, color);

        // 階調影
        affectToonShade(i, uv_main, ws_normal, ws_bump_normal, angle_light_camera, color);
        // リムライト
        affectRimLight(i, uv_main, calcMatcapVector(matcapVector, _TR_BlendNormal, 0), angle_light_camera, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // ToonFog
        affectToonFog(i, ws_view_dir, color);

        // フレネル
        affectFresnelAlpha(uv_main, ws_normal, ws_view_dir, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

#endif
