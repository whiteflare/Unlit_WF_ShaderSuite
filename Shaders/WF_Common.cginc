﻿/*
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

#ifndef INC_UNLIT_WF_COMMON
#define INC_UNLIT_WF_COMMON

    ////////////////////////////
    // Platform Glue
    ////////////////////////////

#if !defined(UNITY_OLD_PREPROCESSOR) && UNITY_VERSION < 202003
    // 未定義だけどUnity2020.3未満のときは定義する
    #define UNITY_OLD_PREPROCESSOR
#endif

#ifdef _WF_PLATFORM_LWRP
    // Lightweight RP 向け定義
    #include "WF_Common_LightweightRP.cginc"
#else
    // Builtin RP 向け定義
    #include "WF_Common_BuiltinRP.cginc"
#endif

#ifdef _WF_FORCE_USE_SAMPLER
    // サンプラーを強制的に使用する場合は、_SUB_ 側を undef して MAIN 側を使うように置き換える
    #undef  DECL_SUB_TEX2D
    #define DECL_SUB_TEX2D(name)            DECL_MAIN_TEX2D(name)
    #undef  PICK_SUB_TEX2D
    #define PICK_SUB_TEX2D(tex, name, uv)   PICK_MAIN_TEX2D(tex, uv)
#endif

    ////////////////////////////
    // Common Utility
    ////////////////////////////

    #define TGL_ON(value)   (0.5 <= value)
    #define TGL_OFF(value)  (value < 0.5)
    #define TGL_01(value)   step(0.5, value)

    float GammaToCurrentColorSpaceExact(float v) {
#ifdef UNITY_COLORSPACE_GAMMA
        return v;
#else
        return GammaToLinearSpaceExact(v);
#endif
    }

    half3 GammaToCurrentColorSpace(half3 v) {
#ifdef UNITY_COLORSPACE_GAMMA
        return v;
#else
        return GammaToLinearSpace(v);
#endif
    }

    static const half3 MEDIAN_GRAY = GammaToCurrentColorSpace(half3(0.5, 0.5, 0.5));

    #define MAX3(r, g, b)   max(r, max(g, b) )
    #define AVE3(r, g, b)   ((r + g + b) / 3)
    #define MAX_RGB(v)      max(v.r, max(v.g, v.b))
    #define MIN_RGB(v)      min(v.r, min(v.g, v.b))
    #define AVE_RGB(v)      ((v.r + v.g + v.b) / 3)

    #define INVERT_MASK_VALUE(rgba, inv)            saturate( TGL_OFF(inv) ? rgba : half4(1 - rgba.rgb, rgba.a) )
    #define SAMPLE_MASK_VALUE(tex, uv, inv)         INVERT_MASK_VALUE( PICK_SUB_TEX2D(tex, _MainTex, uv), inv )
    #define SAMPLE_MASK_VALUE_LOD(tex, uv, inv)     INVERT_MASK_VALUE( PICK_VERT_TEX2D_LOD(tex, uv, 0), inv )

    #define NZF                                     0.000001
    #define NON_ZERO_FLOAT(v)                       max(v, NZF)
    #define NON_ZERO_VEC3(v)                        max(v, float3(NZF, NZF, NZF))
    #define ZERO_VEC3                               half3(0, 0, 0)
    #define ZERO_VEC4                               half4(0, 0, 0, 0)
    #define ONE_VEC3                                half3(1, 1, 1)
    #define ONE_VEC4                                half4(1, 1, 1, 1)

    #define DISCARD_VS_VERTEX_ZERO                  UnityObjectToClipPos( float3(0, 0, 0) )

    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        #define _LMAP_ENABLE
    #endif

    #ifdef _WF_LEGACY_FEATURE_SWITCH
        #define FEATURE_TGL(name)               half name
        #define FEATURE_TGL_ON_BEGIN(name)      if (TGL_ON(name)) {
        #define FEATURE_TGL_OFF_BEGIN(name)     if (TGL_OFF(name)) {
        #define FEATURE_TGL_END                 }
    #else
        #define FEATURE_TGL(name)
        #define FEATURE_TGL_ON_BEGIN(name)
        #define FEATURE_TGL_OFF_BEGIN(name)
        #define FEATURE_TGL_END
    #endif

    float SafeDiv(float x, float y, float eps) {
        return abs(y) < eps ? 0 : x / y;
    }

    float3 SafeDivVec3(float3 x, float3 y, float eps) {
        return float3(SafeDiv(x.x, y.x, eps), SafeDiv(x.y, y.y, eps), SafeDiv(x.z, y.z, eps));
    }

    float2 SafeNormalizeVec2(float2 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < NZF) {
            return float2(0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    float3 SafeNormalizeVec3(float3 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < NZF) {
            return float3(0, 0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    float3 SafeNormalizeVec3Normal(float3 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < NZF) {
            return float3(0, 0, 1);
        }
        return in_vec * rsqrt(lenSq);
    }

    float3 lerpNormals(float3 n1, float3 n2, float v) {
        return normalize(lerp(n1, n2, v));
    }

    ////////////////////////////
    // Normal
    ////////////////////////////

    void localNormalToWorldTangentSpace(half3 normal, out float3 out_normal) {
        out_normal = UnityObjectToWorldNormal(normal);
    }

    void localNormalToWorldTangentSpace(half3 normal, half4 tangent, out half3 out_normal, out half3 out_tangent, out half3 out_bitangent, float flipMirrorX, float flipMirrorY) {
        // Normalは普通に計算
        localNormalToWorldTangentSpace(normal, out_normal);

        float tan_sign = step(0, tangent.w) * 2 - 1;
        tan_sign *= unity_WorldTransformParams.w;

        out_tangent = UnityObjectToWorldDir(tangent.xyz);
        out_bitangent = cross(out_normal, out_tangent) * tan_sign;

        if (0 < tan_sign) {
            if (TGL_ON(flipMirrorX)) {
                out_tangent = -out_tangent;
            }
            if (TGL_ON(flipMirrorY)) {
                out_bitangent = -out_bitangent;
            }
        }
    }

    void localNormalToWorldTangentSpace(half3 normal, half4 tangent, out half3 out_normal, out half3 out_tangent, out half3 out_bitangent, float flipTangent) {
        localNormalToWorldTangentSpace(normal, tangent, out_normal, out_tangent, out_bitangent, flipTangent, flipTangent);
    }

    float3 transformTangentToWorldNormal(float3 v, half3 ws_normal, half3 ws_tangent, half3 ws_bitangent) {
        half3x3 tangentTransform = half3x3(ws_tangent, ws_bitangent, ws_normal);
        return mul(v, tangentTransform);
    }

    float3 transformWorldToTangentNormal(float3 v, half3 ws_normal, half3 ws_tangent, half3 ws_bitangent) {
        half3x3 tangentTransform = half3x3(ws_tangent, ws_bitangent, ws_normal);
        return mul(tangentTransform, v);
    }

    ////////////////////////////
    // Lighting
    ////////////////////////////

    static const float3 BT601 = { 0.299, 0.587, 0.114 };
    static const float3 BT709 = { 0.21, 0.72, 0.07 };

    float calcBrightness(float3 color) {
        return dot(color, BT601);
    }

    float3 calcHorizontalCoordSystem(float azimuth, float alt) {
        azimuth = radians(azimuth + 90);
        alt = radians(alt);
        return normalize( float3(cos(azimuth) * cos(alt), sin(alt), -sin(azimuth) * cos(alt)) );
    }

    ////////////////////////////
    // Camera management
    ////////////////////////////

    float3 worldSpaceCameraVector(float3 ws_vertex) {
        // カメラへの正規化されていないベクトル
        return _WorldSpaceCameraPos - ws_vertex;
    }

    float3 worldSpaceCameraDistance(float3 ws_vertex) {
        // カメラへの距離
        return length(worldSpaceCameraVector(ws_vertex));
    }

    float3 worldSpaceCameraDir(float3 ws_vertex) {
        // カメラ方向(正規化されたベクトル)
        return normalize(worldSpaceCameraVector(ws_vertex));
    }

    float3 worldSpaceViewPointPos() {
        // ビューポイントの座標。これは SinglePass Stereo のときは左目と右目の中点になる。
        #ifdef USING_STEREO_MATRICES
            return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
        #else
            return _WorldSpaceCameraPos;
        #endif
    }

    float3 worldSpaceViewPointVector(float3 ws_vertex) {
        // ビューポイントへの正規化されていないベクトル
        return worldSpaceViewPointPos() - ws_vertex;
    }

    float3 worldSpaceViewPointDistance(float3 ws_vertex) {
        // ビューポイントへの距離
        return length(worldSpaceViewPointVector(ws_vertex));
    }

    float3 worldSpaceViewPointDir(float3 ws_vertex) {
        // ビューポイント方向(正規化されたベクトル)
        return SafeNormalizeVec3(worldSpaceViewPointVector(ws_vertex));
    }

    float3 worldSpaceViewDirStereoLerp(float3 ws_vertex, float x) {
        return SafeNormalizeVec3(lerp(worldSpaceViewPointPos(), _WorldSpaceCameraPos, x) - ws_vertex);
    }

    bool isInMirror() {
        return unity_CameraProjection[2][0] != 0.0f || unity_CameraProjection[2][1] != 0.0f;
    }

    ////////////////////////////
    // Color Utility
    ////////////////////////////

    inline half3 blendColor_Alpha(half3 base, half3 over, float power) {
        // アルファブレンド
        half3 c = over;
        return lerp(base, c, power);
    }

    inline half3 blendColor_Add(half3 base, half3 over, float power) {
        // 加算
        half3 c = base + over;
        return lerp(base, c, power);
    }

    inline half3 blendColor_Mul(half3 base, half3 over, float power) {
        // 乗算
        half3 c = base * over;
        return lerp(base, c, power);
    }

    inline half3 blendColor_AddAndSub(half3 base, half3 over, float power) {
        // 半加算
        half3 c = base + over - MEDIAN_GRAY;
        return lerp(base, c, power);
    }

    inline half3 blendColor_Screen(half3 base, half3 over, float power) {
        // スクリーン
        half3 c = 1 - (1 - base) * (1 - over);
        return lerp(base, c, power);
    }

    inline half3 blendColor_Overlay(half3 base, half3 over, float power) {
        // オーバーレイ
        half3 c = lerp(
                2 * base * over,
                1 - 2 * (1 - base) * (1 - over.rgb),
                step(AVE_RGB(base), 0.5)
            );
        return lerp(base, c, power);
    }

    inline half3 blendColor_HardLight(half3 base, half3 over, float power) {
        // ハードライト
        half3 c = lerp(
                2 * base * over,
                1 - 2 * (1 - base) * (1 - over.rgb),
                step(AVE_RGB(over), 0.5)
            );
        return lerp(base, c, power);
    }

    ////////////////////////////
    // Matcap
    ////////////////////////////

    float3 matcapViewCorrect(float3 vs_normal, half3 ws_view_dir) {
        float3 base = mul( (float3x3)UNITY_MATRIX_V, ws_view_dir ) * float3(-1, -1, 1) + float3(0, 0, 1);
        float3 detail = vs_normal.xyz * float3(-1, -1, 1);
        return base * dot(base, detail) / base.z - detail;
    }

    float2x2 matcapRotateCorrectMatrix() {
        float2 vs_topdir = mul( (float3x3)UNITY_MATRIX_V, float3(0, 1, 0) ).xy;
        float top_angle = 0;
        if (any(vs_topdir)) {
            vs_topdir = normalize(vs_topdir);
            top_angle = sign(vs_topdir.x) * acos( clamp(vs_topdir.y, -1, 1) );
        }
        float2x2 matrixRotate = { cos(top_angle), sin(top_angle), -sin(top_angle), cos(top_angle) };
        return matrixRotate;
    }

    float3 calcMatcapVector(in half3 ws_view_dir, in half3 ws_normal) {
        // このメソッドは ws_bump_normal を考慮しないバージョン。考慮するバージョンは WF_UnToon_Function.cginc にある。

        // ワールド法線をビュー法線に変換
        float3 vs_normal = mul(half4(ws_normal, 1), UNITY_MATRIX_I_V).xyz;

        // カメラ位置にて補正する
        vs_normal = matcapViewCorrect(vs_normal, ws_view_dir);
        // 真上を揃える
        vs_normal.xy = mul( vs_normal.xy, matcapRotateCorrectMatrix() );

        return normalize( vs_normal );
    }

    ////////////////////////////
    // RGB-HSV convert
    ////////////////////////////

    float3 rgb2hsv(float3 c) {
        // i see "https://qiita.com/_nabe/items/c8ba019f26d644db34a8"
        static float4 k = float4( 0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0 );
        static float e = 1.0e-10;
        float4 p = lerp( float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g) );
        float4 q = lerp( float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r) );
        float d = q.x - min(q.w, q.y);
        return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x );
    }

    float3 hsv2rgb(float3 c) {
        // i see "https://qiita.com/_nabe/items/c8ba019f26d644db34a8"
        static float4 k = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
        float3 p = abs( frac(c.xxx + k.xyz) * 6.0 - k.www );
        return c.z * lerp( k.xxx, saturate(p - k.xxx), c.y );
    }

    ////////////////////////////
    // ReflectionProbe Sampler
    ////////////////////////////

    #define pickReflectionCubemap(cubemap, hdrInst, ws_vertex, ws_normal, lod)  \
        ( DecodeHDR( PICK_MAIN_TEXCUBE_LOD(cubemap, reflect(-worldSpaceCameraDir(ws_vertex), ws_normal), lod ), hdrInst) )

/*
    float3 pickReflectionCubemap(samplerCUBE cubemap, half4 cubemap_HDR, float3 ws_vertex, half3 ws_normal, float lod) {
        half3 ws_camera_dir = worldSpaceCameraDir(ws_vertex);
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float4 color = texCUBElod(cubemap, float4(reflect_dir, lod) );
        return DecodeHDR(color, cubemap_HDR);
    }
*/

    ////////////////////////////
    // Random
    ////////////////////////////

    float random2to1(float2 st) {  // float2 -> float [0-1)
        float vec;
        vec.x = dot(st, float2(12.9898, 78.233));
        return frac(sin(vec) * 43758.5453);
    }

    float2 random2to2(float2 st) { // float2 -> float2 [0-1)
        float2 vec;
        vec.x = dot(st, float2(12.9898, 78.233));
        vec.y = dot(st, float2(31.5649, 51.877));
        return frac(sin(vec) * 43758.5453);
    }

    float3 random2to3(float2 st) { // float2 -> float3 [0-1)
        float3 vec;
        vec.x = dot(st, float2(12.9898, 78.233));
        vec.y = dot(st, float2(31.5649, 51.877));
        vec.z = dot(st, float2(29.1773, 33.499));
        return frac(sin(vec) * 43758.5453);
    }

#endif
