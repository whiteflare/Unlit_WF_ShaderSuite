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

#ifndef INC_UNLIT_WF_WATER
#define INC_UNLIT_WF_WATER

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "WF_INPUT_Water.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

#ifdef _WF_WATER_SURFACE

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
        float2 uv2              : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        float3 ws_vertex        : TEXCOORD3;
        float3 ws_tangent       : TEXCOORD4;
        float3 ws_bitangent     : TEXCOORD5;
        float3 ws_light_dir     : TEXCOORD6;
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f_surface

    struct drawing {
        float4  color;
        float2  uv1;
        float2  uv2;
        float2  uv_main;
        float3  ws_vertex;
        float3  ws_normal;
        float3  ws_bump_normal;
        float3  ws_view_dir;
        float3  ws_camera_dir;
        float3  ws_light_dir;
        float3  ws_tangent;
        float3  ws_bitangent;
        uint    facing;
        float   height;
    };

    drawing prepareDrawing(IN_FRAG i, uint facing) {
        drawing d = (drawing) 0;

        d.color         = float4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;
        d.uv2           = i.uv2;
        d.ws_vertex     = i.ws_vertex;
        d.facing        = facing;
        d.ws_light_dir  = i.ws_light_dir;
        d.ws_normal     = normalize(i.ws_normal);
        d.ws_tangent    = normalize(i.ws_tangent);
        d.ws_bitangent  = normalize(i.ws_bitangent);
        d.ws_view_dir   = worldSpaceViewPointDir(d.ws_vertex);
        d.ws_camera_dir = worldSpaceCameraDir(d.ws_vertex);

        return d;
    }

#endif

#ifdef _WF_WATER_CAUSTICS

    struct appdata_caustics {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv2              : TEXCOORD1;
        float3 normal           : NORMAL;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_caustics {
        float4 vs_vertex        : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv2              : TEXCOORD1;
        float3 ws_vertex        : TEXCOORD2;
        UNITY_FOG_COORDS(3)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f_caustics

    struct drawing {
        float4  color;
        float2  uv1;
        float2  uv2;
        float2  uv_main;
        float3  ws_vertex;
    };

    drawing prepareDrawing(IN_FRAG i) {
        drawing d = (drawing) 0;

        d.color         = float4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;
        d.uv2           = i.uv2;
        d.ws_vertex     = i.ws_vertex;

        return d;
    }

#endif

#ifdef _WF_WATER_DEPTHFOG

    struct appdata_depthfog {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_depthfog {
        float4 vs_vertex        : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float3 ws_vertex        : TEXCOORD1;
        UNITY_FOG_COORDS(1)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f_depthfog

    struct drawing {
        float4  color;
        float2  uv1;
        float2  uv_main;
        float3  ws_vertex;
    };

    drawing prepareDrawing(IN_FRAG i) {
        drawing d = (drawing) 0;

        d.color         = float4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;
        d.ws_vertex     = i.ws_vertex;

        return d;
    }
#endif

#if defined(_WF_WATER_LAMP_DIR) || defined(_WF_WATER_LAMP_POINT)

    struct appdata_lamp {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv2              : TEXCOORD1;
        float3 normal           : NORMAL;
        float4 tangent          : TANGENT;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f_lamp {
        float4 vs_vertex        : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv2              : TEXCOORD1;
        float3 ws_normal        : TEXCOORD2;
        float3 ws_vertex        : TEXCOORD3;
        float3 ws_tangent       : TEXCOORD4;
        float3 ws_bitangent     : TEXCOORD5;
#ifdef _WF_WATER_LAMP_POINT
        float3 ws_base_pos      : TEXCOORD6;
#endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f_lamp

    struct drawing {
        float4  color;
        float2  uv1;
        float2  uv2;
        float2  uv_main;
        float3  ws_vertex;
        float3  ws_normal;
        float3  ws_tangent;
        float3  ws_bitangent;
        float3  ws_bump_normal;
#ifdef _WF_WATER_LAMP_POINT
        float3  ws_base_pos;
#endif
    };

    drawing prepareDrawing(IN_FRAG i) {
        drawing d = (drawing) 0;

        d.color         = float4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;
        d.uv2           = i.uv2;
        d.ws_vertex     = i.ws_vertex;
        d.ws_normal     = normalize(i.ws_normal);
        d.ws_tangent    = normalize(i.ws_tangent);
        d.ws_bitangent  = normalize(i.ws_bitangent);
#ifdef _WF_WATER_LAMP_POINT
        d.ws_base_pos   = i.ws_base_pos;
#endif

        return d;
    }
#endif

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // Waving
    ////////////////////////////

    float2 calcWavingUV(float2 uv1, float2 uv2, float3 ws_vertex, uint uvType, float4 direction, float speed, float4 map_ST) {
        float2 uv =
            uvType == 0 ? uv1 :
            uvType == 1 ? uv2 :
            ws_vertex.xz;
        uv += _Time.xx * direction.zy * max(0, speed);
        return uv * map_ST.xy + map_ST.zw;
    }

#ifndef _WF_LEGACY_FEATURE_SWITCH

    #define WF_DEF_WAVE_NORMAL(id)                                                                              \
        float3 calcWavingNormal##id(IN_FRAG i, inout uint cnt) {                                                \
            float2 uv = calcWavingUV(i.uv, i.uv2, i.ws_vertex,                                                  \
                _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_NormalMap##id##_ST);                  \
            float4 tex = PICK_MAIN_TEX2D(_WAV_NormalMap##id, uv);                                               \
            float3 normalTangent = UnpackScaleNormal( tex, _WAV_NormalScale##id ).xyz;                          \
            cnt++;                                                                                              \
            return transformTangentToWorldNormal(normalTangent, i.ws_normal, i.ws_tangent, i.ws_bitangent);     \
        }

    #define WF_DEF_WAVE_HEIGHT(id)                                                                              \
        float calcWavingHeight##id(IN_FRAG i, inout uint cnt) {                                                 \
            float2 uv = calcWavingUV(i.uv, i.uv2, i.ws_vertex,                                                  \
                _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_HeightMap##id##_ST);                  \
            cnt++;                                                                                              \
            return PICK_MAIN_TEX2D(_WAV_HeightMap##id, uv).r * 2 - 0.5;                                         \
        }

    #define WF_DEF_WAVE_CAUSTICS(id)                                                                            \
        float3 calcWavingCaustics##id(inout drawing d, inout uint cnt) {                                        \
            float2 uv = calcWavingUV(d.uv_main, d.uv2, d.ws_vertex,                                             \
                _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_CausticsTex##id##_ST);                \
            cnt++;                                                                                              \
            return PICK_MAIN_TEX2D(_WAV_CausticsTex##id, uv);                                                   \
        }

#else

    #define WF_DEF_WAVE_NORMAL(id)                                                                              \
        float3 calcWavingNormal##id(IN_FRAG i, inout uint cnt) {                                                \
            if (_WAV_Enable##id) {                                                                              \
                float2 uv = calcWavingUV(i.uv, i.uv2, i.ws_vertex,                                              \
                    _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_NormalMap##id##_ST);              \
                float4 tex = PICK_MAIN_TEX2D(_WAV_NormalMap##id, uv);                                           \
                float3 normalTangent = UnpackScaleNormal( tex, _WAV_NormalScale##id ).xyz;                      \
                cnt++;                                                                                          \
                return transformTangentToWorldNormal(normalTangent, i.ws_normal, i.ws_tangent, i.ws_bitangent); \
            } else {                                                                                            \
                return ZERO_VEC3;                                                                               \
            }                                                                                                   \
        }

    #define WF_DEF_WAVE_HEIGHT(id)                                                                              \
        float calcWavingHeight##id(IN_FRAG i, inout uint cnt) {                                                 \
            if (_WAV_Enable##id) {                                                                              \
                float2 uv = calcWavingUV(i.uv, i.uv2, i.ws_vertex,                                              \
                    _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_HeightMap##id##_ST);              \
                cnt++;                                                                                          \
                return PICK_MAIN_TEX2D(_WAV_HeightMap##id, uv).r * 2 - 0.5;                                     \
            } else {                                                                                            \
                return 0;                                                                                       \
            }                                                                                                   \
        }

    #define WF_DEF_WAVE_CAUSTICS(id)                                                                            \
        float3 calcWavingCaustics##id(inout drawing d, inout uint cnt) {                                        \
            if (_WAV_Enable##id) {                                                                              \
                float2 uv = calcWavingUV(d.uv_main, d.uv2, d.ws_vertex,                                         \
                    _WAV_UVType##id, _WAV_Direction##id, _WAV_Speed##id, _WAV_CausticsTex##id##_ST);            \
                cnt++;                                                                                          \
                return PICK_MAIN_TEX2D(_WAV_CausticsTex##id, uv);                                               \
            } else {                                                                                            \
                return ZERO_VEC3;                                                                               \
            }                                                                                                   \
        }

#endif

#ifdef _WF_WATER_SURFACE

    #ifdef _WAV_ENABLE_1
        WF_DEF_WAVE_NORMAL(_1)
        WF_DEF_WAVE_HEIGHT(_1)
    #else
        #define calcWavingNormal_1(i, cnt)      ZERO_VEC3
        #define calcWavingHeight_1(i, cnt)      0
    #endif
    #ifdef _WAV_ENABLE_2
        WF_DEF_WAVE_NORMAL(_2)
        WF_DEF_WAVE_HEIGHT(_2)
    #else
        #define calcWavingNormal_2(i, cnt)      ZERO_VEC3
        #define calcWavingHeight_2(i, cnt)      0
    #endif
    #ifdef _WAV_ENABLE_3
        WF_DEF_WAVE_NORMAL(_3)
        WF_DEF_WAVE_HEIGHT(_3)
    #else
        #define calcWavingNormal_3(i, cnt)      ZERO_VEC3
        #define calcWavingHeight_3(i, cnt)      0
    #endif

    void prepareWaveHeight(IN_FRAG i, inout drawing d) {
        uint cnt = 0;
        float height = 0;
        height += calcWavingHeight_1(i, cnt);
        height += calcWavingHeight_2(i, cnt);
        height += calcWavingHeight_3(i, cnt);
        d.height = cnt == 0 ? 1 : saturate( height / max(1, cnt) / 0.5 + 0.5 );
    }

    void prepareWaveNormal(IN_FRAG i, inout drawing d) {
        uint cnt = 0;
        float3 ws_bump_normal = ZERO_VEC3;
        ws_bump_normal += calcWavingNormal_1(i, cnt);
        ws_bump_normal += calcWavingNormal_2(i, cnt);
        ws_bump_normal += calcWavingNormal_3(i, cnt);
        d.ws_bump_normal = cnt == 0 ? d.ws_normal : SafeNormalizeVec3(ws_bump_normal / max(1, cnt));
    }

#endif

#ifdef _WF_WATER_CAUSTICS

    #ifdef _WAV_ENABLE_1
        WF_DEF_WAVE_CAUSTICS(_1)
    #else
        #define calcWavingCaustics_1(i, cnt)    ZERO_VEC3
    #endif
    #ifdef _WAV_ENABLE_2
        WF_DEF_WAVE_CAUSTICS(_2)
    #else
        #define calcWavingCaustics_2(i, cnt)    ZERO_VEC3
    #endif
    #ifdef _WAV_ENABLE_3
        WF_DEF_WAVE_CAUSTICS(_3)
    #else
        #define calcWavingCaustics_3(i, cnt)    ZERO_VEC3
    #endif

    void drawWavingCaustics(inout drawing d) {
        uint cnt = 0;
        d.color.rgb = ZERO_VEC3;
        d.color.rgb += calcWavingCaustics_1(d, cnt);
        d.color.rgb += calcWavingCaustics_2(d, cnt);
        d.color.rgb += calcWavingCaustics_3(d, cnt);
    }

#endif

#if defined(_WF_WATER_LAMP_DIR) || defined(_WF_WATER_LAMP_POINT)

    #ifdef _WAV_ENABLE_1
        WF_DEF_WAVE_NORMAL(_1)
    #else
        #define calcWavingNormal_1(i, cnt)      ZERO_VEC3
    #endif
    #ifdef _WAV_ENABLE_2
        WF_DEF_WAVE_NORMAL(_2)
    #else
        #define calcWavingNormal_2(i, cnt)      ZERO_VEC3
    #endif
    #ifdef _WAV_ENABLE_3
        WF_DEF_WAVE_NORMAL(_3)
    #else
        #define calcWavingNormal_3(i, cnt)      ZERO_VEC3
    #endif

    void prepareWaveNormal(IN_FRAG i, inout drawing d) {
        uint cnt = 0;
        float3 ws_bump_normal = ZERO_VEC3;
        ws_bump_normal += calcWavingNormal_1(i, cnt);
        ws_bump_normal += calcWavingNormal_2(i, cnt);
        ws_bump_normal += calcWavingNormal_3(i, cnt);
        d.ws_bump_normal = cnt == 0 ? d.ws_normal : SafeNormalizeVec3(ws_bump_normal / max(1, cnt));
    }

#endif

    ////////////////////////////
    // Waving Specular
    ////////////////////////////

#ifdef _WAS_ENABLE

    float3 pickSpecular(float3 ws_camera_dir, float3 ws_normal, float3 ws_light_dir, float3 spec_color, float smoothness) {
        return spec_color * smoothnessToSpecularPower(ws_camera_dir, ws_normal, ws_light_dir, smoothness);
    }

    void drawWaterSurfaceSpecular(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_WAS_Enable)
        // GGX Specular
        d.color.rgb += pickSpecular(d.ws_camera_dir, d.ws_bump_normal, d.ws_light_dir, _WAS_Color.rgb, _WAS_Smooth) * _WAS_Power;
        d.color.rgb += pickSpecular(d.ws_camera_dir, d.ws_bump_normal, d.ws_light_dir, _WAS_Color2.rgb, _WAS_Smooth2) * _WAS_Power2;
FEATURE_TGL_END
    }

#else
    #define drawWaterSurfaceSpecular(d)
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
        if (_WAM_CubemapType != 2) {
#endif
#ifndef _WAM_ONLY2ND_ENABLE
            color += pickReflectionProbe(ws_vertex, ws_normal, metal_lod).rgb;
#endif
#ifdef _WF_LEGACY_FEATURE_SWITCH
        }
        // OFFでなければ SECOND_MAP を加算
        if (_WAM_CubemapType != 0) {
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

    void drawWaterSurfaceReflection(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_WAM_Enable)
        float3 reflection = pickReflection(d.ws_vertex, d.ws_bump_normal, _WAM_Smooth);
        reflection = lerp(d.color.rgb * reflection.rgb, d.color.rgb + reflection.rgb, _WAM_Bright);
        d.color.rgb = lerp(d.color.rgb, reflection.rgb, _WAM_Power);
FEATURE_TGL_END
    }

#else
    #define drawWaterSurfaceReflection(d)
#endif

    ////////////////////////////
    // Distance Fade (Water)
    ////////////////////////////

    #ifdef _WAD_ENABLE

        float calcDistanceFadeDistanceSq(float3 ws_vertex) {
            float3 cam_vec1 = ws_vertex - worldSpaceViewPointPos();
            return dot(cam_vec1, cam_vec1);
        }

        void drawWaterDistanceFade(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_WAD_Enable)
            float dist = sqrt(calcDistanceFadeDistanceSq(d.ws_vertex.xyz));
            d.color.rgb *= lerp(ONE_VEC3, _WAD_Color.rgb * unity_ColorSpaceDouble.rgb, _WAD_Power * smoothstep(_WAD_MinDist, max(_WAD_MinDist + NZF, _WAD_MaxDist), dist));
FEATURE_TGL_END
        }
    #else
        #define drawWaterDistanceFade(d)
    #endif

    ////////////////////////////
    // VRC Mirror Reflection
    ////////////////////////////

    #ifdef _WMI_ENABLE

        FEATURE_TGL    (_WMI_Enable);
        sampler2D       _ReflectionTex0;
        sampler2D       _ReflectionTex1;
        float4          _WMI_Color;
        float           _WMI_Power;
        float           _WMI_BlendNormal;

        void drawVRCMirrorReflection(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_WMI_Enable)
            if (d.facing) {
                float4 mirror_scr_pos = mul(UNITY_MATRIX_VP, float4(d.ws_vertex.xyz + (d.ws_bump_normal - d.ws_normal * dot(d.ws_normal, d.ws_bump_normal)) * _WMI_BlendNormal, 1));
                float4 refl_pos = ComputeNonStereoScreenPos(mirror_scr_pos);
                float4 refl = unity_StereoEyeIndex == 0 ? tex2Dproj(_ReflectionTex0, UNITY_PROJ_COORD(refl_pos)) : tex2Dproj(_ReflectionTex1, UNITY_PROJ_COORD(refl_pos));
                refl.rgb *= _WMI_Color.rgb * unity_ColorSpaceDouble.rgb;
                d.color.rgb = lerp(d.color.rgb, refl.rgb, _WMI_Power * refl.a);
            }
FEATURE_TGL_END
        }
    #else
        #define drawVRCMirrorReflection(d)
    #endif

    ////////////////////////////
    // Lamp&Sun Reflection
    ////////////////////////////

    #ifdef _WAR_ENABLE

        void drawLampReflection(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_WAR_Enable)
            float3 view_dir = normalize(d.ws_vertex - _WorldSpaceCameraPos.xyz);
            float3 refl_dir = normalize(reflect(view_dir, lerpNormals(d.ws_normal, d.ws_bump_normal, _WAR_BlendNormal))) / NON_ZERO_FLOAT(_WAR_Size);

#ifdef _WF_WATER_LAMP_DIR
            float3 base_dir = calcHorizontalCoordSystem(_WAR_Azimuth, _WAR_Altitude);
            float power = _WAR_Power;
#endif
#ifdef _WF_WATER_LAMP_POINT
            float3 base_dir = SafeNormalizeVec3(d.ws_base_pos.xyz - d.ws_vertex.xyz);
            if (TGL_ON(_WAR_CullBack) && dot(view_dir, base_dir) < 0) {
                discard;
                return;
            }
            float power = _WAR_Power * (1 - smoothstep(0, NON_ZERO_FLOAT(_WAR_MaxDist - _WAR_MinDist), length(d.ws_base_pos.xyz - d.ws_vertex.xyz) - _WAR_MinDist));
#endif

            // リフレクション空間の三軸を計算(うち一軸はbase_dir)
            float3 rs_tangent = SafeNormalizeVec3(cross(d.ws_normal, base_dir));
            float3 rs_bitangent = SafeNormalizeVec3(cross(base_dir, rs_tangent));
            float2 uv_refl = float2(dot(rs_tangent, refl_dir), dot(rs_bitangent, refl_dir));
            if (uv_refl.x < -1 || 1 < uv_refl.x || uv_refl.y < -1 || 1 < uv_refl.y) {
                discard;
                return;
            }
            d.color.rgb *= power * PICK_MAIN_TEX2D(_WAR_CookieTex, uv_refl / 2 + 0.5).rgb;

FEATURE_TGL_END
        }
    #else
        #define drawLampReflection(d)
    #endif

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

#ifdef _WF_WATER_SURFACE

    v2f_surface vert_top(appdata_surface v) {
        v2f_surface o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_surface, o);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);
        o.uv = v.uv;
        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
        o.uv2 = v.uv2;

        localNormalToWorldTangentSpace(v.normal, v.tangent, o.ws_normal, o.ws_tangent, o.ws_bitangent, 0);

        o.ws_light_dir = calcWorldSpaceLightDir(o.ws_vertex).xyz;

        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        return o;
    }

    half4 frag_top(v2f_surface i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        drawing d = prepareDrawing(i, facing);

        prepareMainTex(i, d);
        prepareWaveHeight(i, d);
        prepareWaveNormal(i, d);

        d.color = PICK_MAIN_TEX2D(_MainTex, d.uv_main) * lerp(_Color2, _Color, d.height);

        drawVRCMirrorReflection(d);     // VRCミラー
        drawWaterDistanceFade(d);       // 距離フェード
        drawAlphaMask(d);               // アルファマスク

        #ifdef _WF_WATER_CUTOUT
            if (d.color.a < _Cutoff) {
                discard;
                return half4(d.color.rgb, 0);
            }
        #endif

        drawWaterSurfaceReflection(d);  // リフレクション
        drawWaterSurfaceSpecular(d);    // スペキュラ

        // Half Lambert
        d.color.rgb *= saturate(dot(d.ws_bump_normal, i.ws_light_dir) * _ShadowPower + (1 - _ShadowPower));

        drawOcclusion(d);               // オクルージョン
        drawFresnelAlpha(d);            // フレネル
        drawRefraction(d);              // リフラクション

        // fog
        UNITY_APPLY_FOG(i.fogCoord, d.color);
        // Alpha は 0-1 にクランプ
        d.color.a = saturate(d.color.a);

        return d.color;
    }

#endif

#ifdef _WF_WATER_CAUSTICS

    v2f_caustics vert_caustics(appdata_caustics v) {
        v2f_caustics o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_caustics, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);
        o.uv = v.uv;
        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
        o.uv2 = v.uv2;

        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        return o;
    }

    half4 frag_caustics(v2f_caustics i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        drawing d = prepareDrawing(i);

        prepareMainTex(i, d);

        drawWavingCaustics(d);
        d.color = PICK_MAIN_TEX2D(_MainTex, d.uv_main) * _Color * float4(d.color.rgb, 1);

        if (TGL_ON(_HideCausticsAbove) && _WaterLevel < d.ws_vertex.y) {
            discard;
        }

        drawOcclusion(d);               // オクルージョン

        // fog
        UNITY_APPLY_FOG_COLOR(i.fogCoord, d.color, fixed4(0, 0, 0, 0));   // 加算合成なので ForwardAdd と同じく FogColor を黒にして適用する

        return d.color;
    }

#endif

#ifdef _WF_WATER_DEPTHFOG

    v2f_depthfog vert_depthfog(appdata_depthfog v) {
        v2f_depthfog o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_depthfog, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);
        o.uv = v.uv;
        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);

        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        return o;
    }

    half4 frag_depthfog(v2f_depthfog i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        drawing d = prepareDrawing(i);
        d.color = _Color;

        prepareMainTex(i, d);

        float y = _WaterLevel - d.ws_vertex.y;
        if (y <= NZF) {
            // メッシュが水上のときは描画しない
            return half4(1, 1, 1, 0);
        }
        else {
            float3 ws_viewpos = worldSpaceViewPointPos();
            float ey = ws_viewpos.y - _WaterLevel;
            float dist = length(d.ws_vertex - ws_viewpos);

            dist *= ey <= NZF ? 1   // 視点が水面下のときは dist をそのまま採用する
                : y / (y + ey);     // そうではないときは水中の距離を計算する
            d.color.a *= saturate(dist / NON_ZERO_FLOAT(_WaterTransparency));

            // UNITY_APPLY_FOG(i.fogCoord, d.color); // DepthFog は Fog には対応しない
            return d.color;
        }
    }

#endif

#if defined(_WF_WATER_LAMP_DIR) || defined(_WF_WATER_LAMP_POINT)

    v2f_lamp vert_lamp(appdata_lamp v) {
        v2f_lamp o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_lamp, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);
        o.uv = v.uv;
        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
        o.uv2 = v.uv2;
#ifdef _WF_WATER_LAMP_POINT
        o.ws_base_pos = UnityObjectToWorldPos(_WAR_BasePosOffset);
#endif

        localNormalToWorldTangentSpace(v.normal, v.tangent, o.ws_normal, o.ws_tangent, o.ws_bitangent, 0);

        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        return o;
    }

    half4 frag_lamp(v2f_lamp i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        drawing d = prepareDrawing(i);

        prepareMainTex(i, d);
        prepareWaveNormal(i, d);

        d.color = float4(PICK_MAIN_TEX2D(_MainTex, d.uv_main).rgb * _Color.rgb, 1);

        drawLampReflection(d);          // Lamp&Sun リフレクション

        // fog
        UNITY_APPLY_FOG_COLOR(i.fogCoord, d.color, fixed4(0, 0, 0, 0));   // 加算合成なので ForwardAdd と同じく FogColor を黒にして適用する
        // Alpha は 0-1 にクランプ
        d.color.a = saturate(d.color.a);

        return d.color;
    }

#endif

#endif
