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

#ifndef INC_UNLIT_WF_GEM
#define INC_UNLIT_WF_GEM

    #include "WF_INPUT_Gem.cginc"
    #include "WF_UnToon.cginc"

    ////////////////////////////
    // Gem Flake
    ////////////////////////////

    void affectGemFlake(v2f i, float3 ws_camera_dir, float3 ws_normal, float size, inout float4 color) {
        if (TGL_ON(_GMF_Enable)) {
            float2 matcapVector = calcMatcapVector(ws_camera_dir, ws_normal).xy * size;
            float3 ls_camera_dir = SafeNormalizeVec3(worldSpaceViewPointPos() - calcWorldSpaceBasePos(i.ws_vertex));

            float2 checker = step(0.5, frac(matcapVector.xy + matcapVector.yx * _GMF_FlakeShear
                + dot(ls_camera_dir.xyz, ls_camera_dir.yzx) * _GMF_Twinkle
            ));
            color.rgb *= checker.x != checker.y ? _GMF_FlakeBrighten : _GMF_FlakeDarken;

            matcapVector *= float2(1, -1);

            checker = step(0.5, frac(matcapVector.xy + matcapVector.yx * _GMF_FlakeShear
                + dot(ls_camera_dir.xyz, ls_camera_dir.zyx) * _GMF_Twinkle
            ));
            color.rgb *= checker.x != checker.y ? _GMF_FlakeBrighten : _GMF_FlakeDarken;
        }
    }

    ////////////////////////////
    // Gem Reflection
    ////////////////////////////

    void affectGemReflection(v2f i, float3 ws_normal, inout float4 color) {
        if (TGL_ON(_GMR_Enable)) {
            // リフレクション
            float3 cubemap = pickReflectionCubemap(_GMR_Cubemap, _GMR_Cubemap_HDR, i.ws_vertex, ws_normal, 0); // smoothnessは1固定
            float3 reflection = lerp(cubemap, pow(max(ZERO_VEC3, cubemap), NON_ZERO_FLOAT(1 - _GMR_CubemapHighCut)), step(ONE_VEC3, cubemap)) * _GMR_CubemapPower;
            reflection = lerp(reflection, calcBrightness(reflection), _GMR_Monochrome);

            // 合成
            color.rgb = lerp(
                color.rgb,
                lerp(color.rgb * reflection.rgb, color.rgb + reflection.rgb, _GMR_Brightness),
                _GMR_Power);
        }
    }

    ////////////////////////////
    // fragment shader
    ////////////////////////////

    float4 frag_gem_back(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        float4 color = TGL_ON(_GMB_Enable) ? _GMB_ColorBack : _Color;
        float2 uv_main;

        i.normal = normalize(i.normal);
#ifdef _V2F_HAS_TANGENT
        i.tangent = normalize(i.tangent);
        i.bitangent = normalize(i.bitangent);
#endif

        // メイン
        affectMainTex(i.uv, uv_main, color);
        // 頂点カラー
        affectVertexColor(i.vertex_color, color);

        // アルファマスク適用
        affectAlphaMask(uv_main, color);

#ifdef _AL_ENABLE
        color.a *= _AlphaBack;
#else
        color.a = 1;
#endif

        // BumpMap
        float3 ws_normal = i.normal;
        float3 ws_bump_normal = calcBumpNormal(i, uv_main);

        // ビューポイントへの方向
        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        // カメラへの方向
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);

        // リフレクション
        affectGemReflection(i, lerpNormals(ws_normal.zyx, ws_bump_normal.zyx, _GMR_BlendNormal), color);
        // フレーク
        affectGemFlake(i, ws_camera_dir, lerpNormals(ws_normal, ws_bump_normal, _GMF_BlendNormal), 1 / NON_ZERO_FLOAT(_GMF_FlakeSizeBack), color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // フレネル
        affectFresnelAlpha(uv_main, ws_normal, ws_view_dir, color);
        // ディゾルブ
        affectDissolve(i.uv, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    float4 frag_gem_front(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        float4 color = _Color;
        float2 uv_main;

        i.normal = normalize(i.normal);
#ifdef _V2F_HAS_TANGENT
        i.tangent = normalize(i.tangent);
        i.bitangent = normalize(i.bitangent);
#endif

        // メイン
        affectMainTex(i.uv, uv_main, color);
        // 頂点カラー
        affectVertexColor(i.vertex_color, color);

        // アルファマスク適用
        affectAlphaMask(uv_main, color);

#ifdef _AL_ENABLE
        color.rgb *= color.a;
        color.a = _AlphaFront;
#else
        color.a = 1;
#endif

        // BumpMap
        float3 ws_normal = i.normal;
        float3 ws_bump_normal = calcBumpNormal(i, uv_main);

        // ビューポイントへの方向
        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        // カメラへの方向
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);

        // リフレクション
        affectGemReflection(i, lerpNormals(ws_normal, ws_bump_normal, _GMR_BlendNormal), color);
        // フレーク
        affectGemFlake(i, ws_camera_dir, lerpNormals(ws_normal, ws_bump_normal, _GMF_BlendNormal), 1 / NON_ZERO_FLOAT(_GMF_FlakeSizeFront), color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // フレネル
        affectFresnelAlpha(uv_main, ws_normal, ws_view_dir, color);
        // ディゾルブ
        affectDissolve(i.uv, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

#endif
