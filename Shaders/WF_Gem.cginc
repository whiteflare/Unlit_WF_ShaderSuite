/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
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

    void drawGemFlake(inout drawing d) {
        if (TGL_ON(_GMF_Enable)) {
            float size = 1 / NON_ZERO_FLOAT(d.facing ? _GMF_FlakeSizeFront : _GMF_FlakeSizeBack);
            half3 ws_normal = lerpNormals(d.ws_normal, d.ws_bump_normal, _GMF_BlendNormal);
            float2 matcapVector = calcMatcapVector(d.ws_camera_dir, ws_normal).xy * size;
            float3 ls_camera_dir = SafeNormalizeVec3(worldSpaceViewPointPos() - calcWorldSpaceBasePos(d.ws_vertex));

            float2 checker = step(0.5, frac(matcapVector.xy + matcapVector.yx * _GMF_FlakeShear
                + dot(ls_camera_dir.xyz, ls_camera_dir.yzx) * _GMF_Twinkle
            ));
            d.color.rgb *= checker.x != checker.y ? _GMF_FlakeBrighten : _GMF_FlakeDarken;

            matcapVector *= float2(1, -1);

            checker = step(0.5, frac(matcapVector.xy + matcapVector.yx * _GMF_FlakeShear
                + dot(ls_camera_dir.xyz, ls_camera_dir.zyx) * _GMF_Twinkle
            ));
            d.color.rgb *= checker.x != checker.y ? _GMF_FlakeBrighten : _GMF_FlakeDarken;
        }
    }

    ////////////////////////////
    // Gem Reflection
    ////////////////////////////

    void drawGemReflection(inout drawing d) {
        if (TGL_ON(_GMR_Enable)) {
            half3 ws_normal = lerpNormals(d.ws_normal, d.ws_bump_normal, _GMR_BlendNormal);
            float3 cubemap = pickReflectionCubemap(_GMR_Cubemap, _GMR_Cubemap_HDR, d.ws_vertex, ws_normal, 0); // smoothnessは1固定
            float3 reflection = lerp(cubemap, pow(max(ZERO_VEC3, cubemap), NON_ZERO_FLOAT(1 - _GMR_CubemapHighCut)), step(ONE_VEC3, cubemap)) * _GMR_CubemapPower;
            reflection = lerp(reflection, calcBrightness(reflection), _GMR_Monochrome);

            // 合成
            d.color.rgb = lerp(
                d.color.rgb,
                lerp(d.color.rgb * reflection.rgb, d.color.rgb + reflection.rgb, _GMR_Brightness),
                _GMR_Power);
        }
    }

    ////////////////////////////
    // fragment shader
    ////////////////////////////

    half4 frag_gem_back(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        drawing d = prepareDrawing(i, 0);
        d.color = TGL_ON(_GMB_Enable) ? _GMB_ColorBack : _Color;

        prepareMainTex(i, d);
        prepareBumpNormal(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawVertexColor(d);         // 頂点カラー

        drawAlphaMask(d);           // アルファ

#ifdef _AL_ENABLE
        d.color.a *= _AlphaBack;
#else
        d.color.a = 1;
#endif

        drawBumpNormal(d);          // ノーマルマップ

        drawGemReflection(d);       // リフレクション
        drawGemFlake(d);            // フレーク

        // Anti-Glare とライト色ブレンドを同時に計算
        d.color.rgb *= d.light_color;

        drawEmissiveScroll(d);      // エミッション
        drawFresnelAlpha(d);        // フレネル
        drawDissolve(d);            // ディゾルブ

        // fog
        UNITY_APPLY_FOG(i.fogCoord, d.color);
        // Alpha は 0-1 にクランプ
        d.color.a = saturate(d.color.a);

        return d.color;
    }

    half4 frag_gem_front(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        drawing d = prepareDrawing(i, 1);
        d.color = _Color;

        prepareMainTex(i, d);
        prepareBumpNormal(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawVertexColor(d);         // 頂点カラー

        drawAlphaMask(d);           // アルファ

#ifdef _AL_ENABLE
        d.color.rgb *= d.color.a;
        d.color.a = _AlphaFront;
#else
        d.color.a = 1;
#endif

        drawBumpNormal(d);          // ノーマルマップ

        drawGemReflection(d);       // リフレクション
        drawGemFlake(d);            // フレーク

        // Anti-Glare とライト色ブレンドを同時に計算
        d.color.rgb *= d.light_color;

        drawEmissiveScroll(d);      // エミッション
        drawFresnelAlpha(d);        // フレネル
        drawDissolve(d);            // ディゾルブ

        // fog
        UNITY_APPLY_FOG(i.fogCoord, d.color);
        // Alpha は 0-1 にクランプ
        d.color.a = saturate(d.color.a);

        return d.color;
    }

#endif
