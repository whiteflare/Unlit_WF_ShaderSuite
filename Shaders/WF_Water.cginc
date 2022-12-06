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

#ifndef INC_UNLIT_WF_WATER
#define INC_UNLIT_WF_WATER

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "WF_INPUT_Water.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata_surface {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv2              : TEXCOORD1;
        float3 normal           : NORMAL;
        float4 tangent          : TANGENT;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_surface {
        float4 vs_vertex        : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv_lmap          : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        float3 ws_vertex        : TEXCOORD3;
        float3 ws_tangent       : TEXCOORD4;
        float3 ws_bitangent     : TEXCOORD5;
        float3 ws_light_dir     : TEXCOORD6;
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #define IN_FRAG                         v2f_surface
    #define WF_TEX2D_OCCLUSION(uv)          float3(1, 1, 1)

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // Waving
    ////////////////////////////

    float2 calcWavingUV(v2f_surface i, uint uvType, float4 direction, float speed, float4 map_ST) {
        float2 uv =
            uvType == 0 ? i.uv :
            uvType == 1 ? i.uv_lmap :
            i.ws_vertex.xz;
        uv += _Time.xx * direction.zy * max(0, speed);
        return uv * map_ST.xy + map_ST.zw;
    }

    #define WF_DEF_WAVE_NORMAL(id)                                                                                              \
        float3 calcWavingNormal##id(v2f_surface i, inout uint cnt) {                                                            \
            float3 ws_bump_normal = ZERO_VEC3;                                                                                  \
            FEATURE_TGL_ON_BEGIN(_WAV_Enable##id)                                                                               \
                float2 uv = calcWavingUV(i, _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_NormalMap##id##_ST);      \
                float3 normalTangent = UnpackScaleNormal( PICK_MAIN_TEX2D(_WAV_NormalMap##id, uv), _WAV_NormalScale##id ).xyz;  \
                ws_bump_normal = transformTangentToWorldNormal(normalTangent, i.ws_normal, i.ws_tangent, i.ws_bitangent);       \
                cnt++;                                                                                                          \
            FEATURE_TGL_END                                                                                                     \
            return ws_bump_normal;                                                                                              \
        }

    #define WF_DEF_WAVE_HEIGHT(id)                                                                                              \
        float3 calcWavingHeight##id(v2f_surface i, inout uint cnt) {                                                            \
            float3 ws_bump_normal = ZERO_VEC3;                                                                                  \
            FEATURE_TGL_ON_BEGIN(_WAV_Enable##id)                                                                               \
                float2 uv = calcWavingUV(i, _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_HeightMap##id##_ST);      \
                cnt++;                                                                                                          \
                return PICK_MAIN_TEX2D(_WAV_HeightMap##id, uv).r * 2 - 0.5;                                                     \
            FEATURE_TGL_END                                                                                                     \
            return 0;                                                                                                           \
        }

    #ifdef _WAV_ENABLE_1
        WF_DEF_WAVE_NORMAL(_1)
        WF_DEF_WAVE_HEIGHT(_1)
    #else
        #define calcWavingNormal_1(i, cnt)  ZERO_VEC3
        #define calcWavingHeight_1(i, cnt)  0
    #endif
    #ifdef _WAV_ENABLE_2
        WF_DEF_WAVE_NORMAL(_2)
        WF_DEF_WAVE_HEIGHT(_2)
    #else
        #define calcWavingNormal_2(i, cnt)  ZERO_VEC3
        #define calcWavingHeight_2(i, cnt)  0
    #endif
    #ifdef _WAV_ENABLE_3
        WF_DEF_WAVE_NORMAL(_3)
        WF_DEF_WAVE_HEIGHT(_3)
    #else
        #define calcWavingNormal_3(i, cnt)  ZERO_VEC3
        #define calcWavingHeight_3(i, cnt)  0
    #endif

    float calcWavingHeight(v2f_surface i) {
        uint cnt = 0;
        float height = 0;
        height += calcWavingHeight_1(i, cnt);
        height += calcWavingHeight_2(i, cnt);
        height += calcWavingHeight_3(i, cnt);
        return cnt == 0 ? 1 : saturate( height / max(1, cnt) / 0.5 + 0.5 );
    }

    float3 calcWavingNormal(v2f_surface i) {
        uint cnt = 0;
        float3 ws_bump_normal = ZERO_VEC3;
        ws_bump_normal += calcWavingNormal_1(i, cnt);
        ws_bump_normal += calcWavingNormal_2(i, cnt);
        ws_bump_normal += calcWavingNormal_3(i, cnt);
        return cnt == 0 ? i.ws_normal : SafeNormalizeVec3(ws_bump_normal / max(1, cnt));
    }

    ////////////////////////////
    // Waving Specular
    ////////////////////////////

#ifdef _WAS_ENABLE

    float3 pickSpecular(float3 ws_camera_dir, float3 ws_normal, float3 ws_light_dir, float3 spec_color, float smoothness) {
        return spec_color * smoothnessToSpecularPower(ws_camera_dir, ws_normal, ws_light_dir, smoothness);
    }

    void affectWaterSurfaceSpecular(v2f_surface i, float3 ws_bump_normal, inout float4 color) {
FEATURE_TGL_ON_BEGIN(_WAS_ENABLE)
        // カメラへの方向
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);

        // GGX Specular
        color.rgb += pickSpecular(ws_camera_dir, ws_bump_normal, i.ws_light_dir, _WAS_Color.rgb, _WAS_Smooth) * _WAS_Power;
        color.rgb += pickSpecular(ws_camera_dir, ws_bump_normal, i.ws_light_dir, _WAS_Color2.rgb, _WAS_Smooth2) * _WAS_Power2;
FEATURE_TGL_END
    }

#else
    #define affectWaterSurfaceSpecular(i, ws_bump_normal, color)
#endif

    ////////////////////////////
    // Waving Reflection
    ////////////////////////////

#ifdef _WAM_ENABLE

    float3 pickReflection(float3 ws_vertex, float3 ws_normal, float smoothness) {
        float metal_lod = (1 - smoothness) * 10;
        float3 color = ZERO_VEC3;

        // ONLYでなければ PROBE を加算
#ifdef _WF_LEGACY_FEATURE_SWITCH
        if (_MT_CubemapType != 2) {
#endif
#ifndef _WAM_ONLY2ND_ENABLE
            color += pickReflectionProbe(ws_vertex, ws_normal, metal_lod).rgb;
#endif
#ifdef _WF_LEGACY_FEATURE_SWITCH
        }
        // OFFでなければ SECOND_MAP を加算
        if (_MT_CubemapType != 0) {
#endif
#if defined(_WAM_ONLY2ND_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
            float3 cubemap = pickReflectionCubemap(_WAM_Cubemap, _WAM_Cubemap_HDR, ws_vertex, ws_normal, metal_lod);
            color += lerp(cubemap, pow(max(ZERO_VEC3, cubemap), NON_ZERO_FLOAT(1 - _WAM_CubemapHighCut)), step(ONE_VEC3, cubemap));
#endif
#ifdef _WF_LEGACY_FEATURE_SWITCH
        }
#endif
        return color;
    }

    void affectWaterSurfaceReflection(v2f_surface i, float3 ws_bump_normal, inout float4 color) {
FEATURE_TGL_ON_BEGIN(_WAM_ENABLE)
        float3 reflection = pickReflection(i.ws_vertex, ws_bump_normal, _WAM_Smooth);
        reflection = lerp(color.rgb * reflection.rgb, color.rgb + reflection.rgb, _WAM_Bright);
        color.rgb = lerp(color.rgb, reflection.rgb, _WAM_Power);
FEATURE_TGL_END
    }

#else
    #define affectWaterSurfaceReflection(i, ws_bump_normal, color)
#endif

    ////////////////////////////
    // Distance Fade (Water)
    ////////////////////////////

    #ifdef _WAD_ENABLE

        float calcDistanceFadeDistanceSq(float3 ws_vertex) {
            float3 cam_vec1 = ws_vertex - worldSpaceViewPointPos();
            return dot(cam_vec1, cam_vec1);
        }

        void affectWaterDistanceFade(IN_FRAG i, inout float4 color) {
FEATURE_TGL_ON_BEGIN(_WAD_Enable)
            float dist = sqrt(calcDistanceFadeDistanceSq(i.ws_vertex.xyz));
            color.rgb *= lerp(ONE_VEC3, _WAD_Color.rgb * unity_ColorSpaceDouble.rgb, _WAD_Power * smoothstep(_WAD_MinDist, max(_WAD_MinDist + NZF, _WAD_MaxDist), dist));
FEATURE_TGL_END
        }
    #else
        #define affectWaterDistanceFade(i, color)
    #endif

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_surface vert_top(appdata_surface v) {
        v2f_surface o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_surface, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        float3 ws_vertex = UnityObjectToWorldPos(v.vertex);

        o.vs_vertex = UnityWorldToClipPos(ws_vertex);
        o.uv = v.uv;
        o.ws_vertex = ws_vertex;
        o.uv_lmap = v.uv2;

        localNormalToWorldTangentSpace(v.normal, v.tangent, o.ws_normal, o.ws_tangent, o.ws_bitangent, 0);

        o.ws_light_dir = calcWorldSpaceLightDir(o.ws_vertex);

        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        return o;
    }

    half4 frag_top(v2f_surface i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        i.ws_normal        = normalize(i.ws_normal);
        i.ws_tangent       = normalize(i.ws_tangent);
        i.ws_bitangent     = normalize(i.ws_bitangent);

        // ハイトマップ
        float height = calcWavingHeight(i);
        // ノーマルマップ
        float3 ws_bump_normal = calcWavingNormal(i);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        half4 color = PICK_MAIN_TEX2D(_MainTex, uv_main) * lerp(_Color2, _Color, height);

		// 距離フェード
		affectWaterDistanceFade(i, color);
        // アルファマスク適用
        affectAlphaMask(uv_main, color);

        // リフレクション
        affectWaterSurfaceReflection(i, ws_bump_normal, color);
        // スペキュラ
        affectWaterSurfaceSpecular(i, ws_bump_normal, color);

        // Half Lambert
        color.rgb *= saturate(dot(ws_bump_normal, i.ws_light_dir) * _ShadowPower + (1 - _ShadowPower));

        // Ambient Occlusion
        affectOcclusion(i, uv_main, color);

        // フレネル
        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        affectFresnelAlpha(uv_main, ws_bump_normal, ws_view_dir, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);
        // リフラクション
        affectRefraction(i, facing, ws_bump_normal, ws_bump_normal, color);
//color.rgb = calcWavingUV(i, _WAV_Direction_1, _WAV_Speed_1, _WAV_NormalMap_1_ST).xxy;
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

#endif
