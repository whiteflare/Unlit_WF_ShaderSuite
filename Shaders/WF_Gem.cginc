/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2025 whiteflare.
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
        d.color.rgb *= calcLightColorFrag(d.ws_vertex, d.light_color);

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
        d.color.rgb *= calcLightColorFrag(d.ws_vertex, d.light_color);

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
