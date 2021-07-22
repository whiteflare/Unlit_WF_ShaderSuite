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

#ifndef INC_UNLIT_WF_UNTOON_POWERCAP
#define INC_UNLIT_WF_UNTOON_POWERCAP

    #include "WF_UnToon.cginc"

    ////////////////////////////
    // Light Matcap Power
    ////////////////////////////

#ifdef _WF_LEGACY_FEATURE_SWITCH
    #define WF_POWERCAP_FUNC(id)                                                                                                    \
        void affectMatcapColor_##id(float2 matcapVector, float2 uv_main, inout float4 color) {                                      \
            if (TGL_ON(_HL_Enable_##id)) {                                                                                          \
                float2 matcap_uv = matcapVector.xy * 0.5 + 0.5;                                                                     \
                float3 matcap_color = PICK_MAIN_TEX2D(_HL_MatcapTex_##id, saturate(matcap_uv)).rgb;                                 \
                float3 matcap_mask = SAMPLE_MASK_VALUE(_HL_MaskTex_##id, uv_main, _HL_InvMaskVal_##id).rgb;                         \
                float power = _HL_Power_##id * MAX_RGB(matcap_mask);                                                                \
                float3 matcap_mask_color = matcap_mask * _HL_MatcapColor_##id * 2;                                                  \
                if (_HL_CapType_##id == 1) {                                                                                        \
                    matcap_color *= LinearToGammaSpace(matcap_mask_color);                                                          \
                    color.rgb = blendColor_Add(color.rgb, matcap_color, power);                                                     \
                } else if(_HL_CapType_##id == 2) {                                                                                  \
                    matcap_color *= LinearToGammaSpace(matcap_mask_color);                                                          \
                    color.rgb = blendColor_Mul(color.rgb, matcap_color, power);                                                     \
                } else {                                                                                                            \
                    matcap_color -= _HL_MedianColor_##id;                                                                           \
                    float3 lighten_color = max(ZERO_VEC3, matcap_color);                                                            \
                    float3 darken_color  = min(ZERO_VEC3, matcap_color);                                                            \
                    matcap_color = lerp(darken_color, lighten_color, matcap_mask_color);                                            \
                    color.rgb = blendColor_Add(color.rgb, matcap_color, power);                                                     \
                }                                                                                                                   \
            }                                                                                                                       \
        }
#else
    #define WF_POWERCAP_FUNC(id)                                                                                                    \
        void affectMatcapColor_##id(float2 matcapVector, float2 uv_main, inout float4 color) {                                      \
                float2 matcap_uv = matcapVector.xy * 0.5 + 0.5;                                                                     \
                float3 matcap_color = PICK_MAIN_TEX2D(_HL_MatcapTex_##id, saturate(matcap_uv)).rgb;                                 \
                float3 matcap_mask = SAMPLE_MASK_VALUE(_HL_MaskTex_##id, uv_main, _HL_InvMaskVal_##id).rgb;                         \
                float power = _HL_Power_##id * MAX_RGB(matcap_mask);                                                                \
                float3 matcap_mask_color = matcap_mask * _HL_MatcapColor_##id * 2;                                                  \
                if (_HL_CapType_##id == 1) {                                                                                        \
                    matcap_color *= LinearToGammaSpace(matcap_mask_color);                                                          \
                    color.rgb = blendColor_Add(color.rgb, matcap_color, power);                                                     \
                } else if(_HL_CapType_##id == 2) {                                                                                  \
                    matcap_color *= LinearToGammaSpace(matcap_mask_color);                                                          \
                    color.rgb = blendColor_Mul(color.rgb, matcap_color, power);                                                     \
                } else {                                                                                                            \
                    matcap_color -= _HL_MedianColor_##id;                                                                           \
                    float3 lighten_color = max(ZERO_VEC3, matcap_color);                                                            \
                    float3 darken_color  = min(ZERO_VEC3, matcap_color);                                                            \
                    matcap_color = lerp(darken_color, lighten_color, matcap_mask_color);                                            \
                    color.rgb = blendColor_Add(color.rgb, matcap_color, power);                                                     \
                }                                                                                                                   \
        }
#endif

    #define WF_POWERCAP_AFFECT(id)  affectMatcapColor_##id(calcMatcapVector(matcapVector, _HL_BlendNormal_##id, _HL_Parallax_##id), i.uv, color)

#ifdef _HL_ENABLE_1
    WF_POWERCAP_FUNC(1)
#endif
#ifdef _HL_ENABLE_2
    WF_POWERCAP_FUNC(2)
#endif
#ifdef _HL_ENABLE_3
    WF_POWERCAP_FUNC(3)
#endif
#ifdef _HL_ENABLE_4
    WF_POWERCAP_FUNC(4)
#endif
#ifdef _HL_ENABLE_5
    WF_POWERCAP_FUNC(5)
#endif
#ifdef _HL_ENABLE_6
    WF_POWERCAP_FUNC(6)
#endif
#ifdef _HL_ENABLE_7
    WF_POWERCAP_FUNC(7)
#endif

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    float4 frag_powercap(v2f i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float4 color;
        float2 uv_main;

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

        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);

        // ビュー空間法線
        float3 vs_normal = calcMatcapVector(ws_view_dir, ws_normal);
        float3 vs_bump_normal = calcMatcapVector(ws_view_dir, ws_bump_normal);
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i.ws_vertex, i.ws_light_dir);

        float4x4 matcapVector = calcMatcapVectorArray(ws_view_dir, ws_camera_dir, ws_normal, ws_bump_normal);

        // Highlight
        affectMatcapColor(calcMatcapVector(matcapVector, _HL_BlendNormal, _HL_Parallax), uv_main, color);

#ifdef _HL_ENABLE_1
        WF_POWERCAP_AFFECT(1);
#endif
#ifdef _HL_ENABLE_2
        WF_POWERCAP_AFFECT(2);
#endif
#ifdef _HL_ENABLE_3
        WF_POWERCAP_AFFECT(3);
#endif
#ifdef _HL_ENABLE_4
        WF_POWERCAP_AFFECT(4);
#endif
#ifdef _HL_ENABLE_5
        WF_POWERCAP_AFFECT(5);
#endif
#ifdef _HL_ENABLE_6
        WF_POWERCAP_AFFECT(6);
#endif
#ifdef _HL_ENABLE_7
        WF_POWERCAP_AFFECT(7);
#endif

        // 階調影
        affectToonShade(i, uv_main, ws_normal, ws_bump_normal, angle_light_camera, color);
        // リムライト
        affectRimLight(i, uv_main, calcMatcapVector(matcapVector, _TR_BlendNormal, 0), angle_light_camera, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // ToonFog
        affectToonFog(i, ws_view_dir, color);

        // フレネル
        affectFresnelAlpha(i.uv, ws_normal, ws_view_dir, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

#endif
