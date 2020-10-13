/*
 *  The MIT License
 *
 *  Copyright 2018-2020 whiteflare.
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

    /*
     * authors:
     *      ver:2020/10/13 whiteflare,
     */

    #include "WF_UnToon.cginc"

    ////////////////////////////
    // Gem Flake
    ////////////////////////////

    float           _GF_Enable;
    float           _GF_FlakeSizeFront;
    float           _GF_FlakeSizeBack;
    float           _GF_FlakeShear;
    float           _GF_FlakeBrighten;
    float           _GF_FlakeDarken;
    float           _GF_Twinkle;
    float           _GF_BlendNormal;

    void affectGemFlake(v2f i, float3 ws_camera_dir, float3 ws_normal, float size, inout float4 color) {
        if (TGL_ON(_GF_Enable)) {
            float2 matcapVector = calcMatcapVector(ws_camera_dir, ws_normal) * size;
            float3 ls_camera_dir = SafeNormalizeVec3(worldSpaceViewPointPos() - calcWorldSpaceBasePos(i.ws_vertex));

            float2 checker = step(0.5, frac(matcapVector.xy + matcapVector.yx * _GF_FlakeShear
                + dot(ls_camera_dir.xyz, ls_camera_dir.yzx) * _GF_Twinkle
            ));
            color.rgb *= checker.x != checker.y ? _GF_FlakeBrighten : _GF_FlakeDarken;

            matcapVector *= float2(1, -1);

            checker = step(0.5, frac(matcapVector.xy + matcapVector.yx * _GF_FlakeShear
                + dot(ls_camera_dir.xyz, ls_camera_dir.zyx) * _GF_Twinkle
            ));
            color.rgb *= checker.x != checker.y ? _GF_FlakeBrighten : _GF_FlakeDarken;
        }
    }

    ////////////////////////////
    // Gem Reflection
    ////////////////////////////

    float           _GR_Enable;
    float           _GR_Power;
    float           _GR_Brightness;
    float           _GR_Monochrome;
    samplerCUBE     _GR_Cubemap;
    float4          _GR_Cubemap_HDR;
    float           _GR_CubemapPower;
    float           _GR_BlendNormal;

    void affectGemReflection(v2f i, float3 ws_normal, inout float4 color) {
        if (TGL_ON(_GR_Enable)) {
            // リフレクション
            float3 reflection = pickReflectionCubemap(_GR_Cubemap, _GR_Cubemap_HDR, i.ws_vertex, ws_normal, 0) * _GR_CubemapPower; // smoothnessは1固定
            reflection = lerp(reflection, calcBrightness(reflection), _GR_Monochrome);

            // 合成
            color.rgb = lerp(
                color.rgb,
                lerp(color.rgb * reflection.rgb, color.rgb + reflection.rgb, _GR_Brightness),
                _GR_Power);
        }
    }

    ////////////////////////////
    // fragment shader
    ////////////////////////////

    float           _AlphaFront;
    float           _AlphaBack;

    float           _GB_Enable;
    float4          _GB_ColorBack;

    float4 frag_gem_back(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);

        // メイン
        float4 color = PICK_MAIN_TEX2D(_MainTex, uv_main);
#ifdef _VC_ENABLE
        color *= lerp(ONE_VEC4, i.vertex_color, _UseVertexColor);
#endif
#ifdef _AL_ENABLE
        color *= TGL_ON(_GB_Enable) ? _GB_ColorBack : _Color;
        color.a *= _AlphaBack;
#else
        color *= _Color;
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
        affectGemReflection(i, lerp(ws_normal.zyx, ws_bump_normal.zyx, _GR_BlendNormal), color);
        // フレーク
        affectGemFlake(i, ws_camera_dir, lerp(ws_normal, ws_bump_normal, _GF_BlendNormal), 1 / NON_ZERO_FLOAT(_GF_FlakeSizeBack), color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // Alpha
        affectAlphaWithFresnel(uv_main, ws_normal, ws_view_dir, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    float4 frag_gem_front(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);

        // メイン
        float4 color = PICK_MAIN_TEX2D(_MainTex, uv_main);
#ifdef _VC_ENABLE
        color *= lerp(ONE_VEC4, i.vertex_color, _UseVertexColor);
#endif
        color *= _Color;
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
        affectGemReflection(i, lerp(ws_normal, ws_bump_normal, _GR_BlendNormal), color);
        // フレーク
        affectGemFlake(i, ws_camera_dir, lerp(ws_normal, ws_bump_normal, _GF_BlendNormal), 1 / NON_ZERO_FLOAT(_GF_FlakeSizeFront), color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // Alpha
        affectAlphaWithFresnel(uv_main, ws_normal, ws_view_dir, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

#endif
