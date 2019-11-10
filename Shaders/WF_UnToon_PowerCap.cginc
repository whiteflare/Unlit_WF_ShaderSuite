/*
 *  The MIT License
 *
 *  Copyright 2018-2019 whiteflare.
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

    /*
     * authors:
     *      ver:2019/07/13 whiteflare,
     */

    #include "WF_Common.cginc"
    #include "WF_UnToon.cginc"

    ////////////////////////////
    // Light Matcap Power
    ////////////////////////////

    #define WF_POWERCAP_DECL(id)                                                                                        \
        float       _HL_Enable_##id;                                                                                    \
        int         _HL_CapType_##id;                                                                                   \
        sampler2D   _HL_MatcapTex_##id;                                                                                 \
        float3      _HL_MatcapColor_##id;                                                                               \
        float       _HL_Power_##id;                                                                                     \
        float       _HL_BlendNormal_##id;                                                                               \
        DECL_SUB_TEX2D(_HL_MaskTex_##id);                                                                               \
        float       _HL_InvMaskVal_##id;                                                                                \
        void affectMatcapColor_##id(float2 matcapVector, float2 mask_uv, inout float4 color) {                          \
            if (TGL_ON(_HL_Enable_##id)) {                                                                              \
                float2 matcap_uv = matcapVector.xy * 0.5 + 0.5;                                                         \
                float3 matcap_color = tex2D(_HL_MatcapTex_##id, saturate(matcap_uv)).rgb;                               \
                float3 matcap_mask = SAMPLE_MASK_VALUE(_HL_MaskTex_##id, mask_uv, _HL_InvMaskVal_##id).rgb;             \
                float3 lightcap_power = saturate(matcap_mask * _HL_MatcapColor_##id * 2);                               \
                float3 shadecap_power = (1 - lightcap_power) * MAX3(matcap_mask.r, matcap_mask.g, matcap_mask.b);       \
                float3 median_color = _HL_CapType_##id == 0 ? MEDIAN_GRAY : float3(0, 0, 0);                            \
                float3 lightcap_color = saturate( (matcap_color - median_color) * lightcap_power );                     \
                float3 shadecap_color = saturate( (median_color - matcap_color) * shadecap_power );                     \
                color.rgb += (lightcap_color - shadecap_color) * _HL_Power_##id;                                        \
            }                                                                                                           \
        }

    #define WF_POWERCAP_AFFECT(id)  affectMatcapColor_##id(lerp(vs_normal, vs_bump_normal, _HL_BlendNormal_##id), i.uv, color)

    WF_POWERCAP_DECL(1)
    WF_POWERCAP_DECL(2)
    WF_POWERCAP_DECL(3)
    WF_POWERCAP_DECL(4)
    WF_POWERCAP_DECL(5)
    WF_POWERCAP_DECL(6)
    WF_POWERCAP_DECL(7)
    WF_POWERCAP_DECL(8)

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    float4 frag_powercap(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);

        // メイン
        float4 color = PICK_MAIN_TEX2D(_MainTex, uv_main) * _Color;

        // BumpMap
        float3 ls_normal = i.normal;
        float3 ls_bump_normal;
        affectBumpNormal(i, uv_main, ls_bump_normal, color);

        // ビュー空間法線
        float3 vs_normal = calcMatcapVector(i.ls_vertex, ls_normal);
        float3 vs_bump_normal = calcMatcapVector(i.ls_vertex, ls_bump_normal);
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i);

        // Highlight
        WF_POWERCAP_AFFECT(1);
        WF_POWERCAP_AFFECT(2);
        WF_POWERCAP_AFFECT(3);
        WF_POWERCAP_AFFECT(4);
        WF_POWERCAP_AFFECT(5);
        WF_POWERCAP_AFFECT(6);
        WF_POWERCAP_AFFECT(7);
        WF_POWERCAP_AFFECT(8);

        // 階調影
        affectToonShade(i, ls_normal, ls_bump_normal, angle_light_camera, color);
        // リムライト
        affectRimLight(i, vs_normal, angle_light_camera, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // Alpha
        affectAlphaWithFresnel(i.uv, ls_normal, localSpaceViewDir(i.ls_vertex), color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        // デバッグビュー
        WF_AFFECT_DEBUGVIEW;

        return color;
    }

    float4 frag_powercap_cutout_upper(v2f i) : SV_Target { // Cutout閾値よりも上側を描画
        float4 color = frag_powercap(i);
        clip(color.a - _AL_CutOff);
        return color;
    }

    float4 frag_powercap_cutout_lower(v2f i) : SV_Target { // Cutout閾値よりも下側を描画
        float4 color = frag_powercap(i);
        clip(_AL_CutOff - color.a);
        return color;
    }

#endif
