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

#ifndef INC_UNLIT_WF_COMMON
#define INC_UNLIT_WF_COMMON

    ////////////////////////////
    // Platform Glue
    ////////////////////////////

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

    static const float3 MEDIAN_GRAY = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : GammaToLinearSpace( float3(0.5, 0.5, 0.5) );

    #define MAX3(r, g, b)   max(r, max(g, b) )
    #define AVE3(r, g, b)   ((r + g + b) / 3)
    #define MAX_RGB(v)      max(v.r, max(v.g, v.b))
    #define AVE_RGB(v)      ((v.r + v.g + v.b) / 3)

    #define INVERT_MASK_VALUE(rgba, inv)            saturate( TGL_OFF(inv) ? rgba : float4(1 - rgba.rgb, rgba.a) )
    #define SAMPLE_MASK_VALUE(tex, uv, inv)         INVERT_MASK_VALUE( PICK_SUB_TEX2D(tex, _MainTex, uv), inv )
    #define SAMPLE_MASK_VALUE_LOD(tex, uv, inv)     INVERT_MASK_VALUE( PICK_VERT_TEX2D_LOD(tex, uv, 0), inv )

    #define NZF                                     0.0001
    #define NON_ZERO_FLOAT(v)                       max(v, NZF)
    #define NON_ZERO_VEC3(v)                        max(v, float3(NZF, NZF, NZF))
    #define ZERO_VEC3                               float3(0, 0, 0)
    #define ZERO_VEC4                               float4(0, 0, 0, 0)
    #define ONE_VEC3                                float3(1, 1, 1)
    #define ONE_VEC4                                float4(1, 1, 1, 1)

    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        #define _LMAP_ENABLE
    #endif

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

    ////////////////////////////
    // Normal
    ////////////////////////////

    void localNormalToWorldTangentSpace(float3 normal, out float3 out_normal) {
        out_normal = UnityObjectToWorldNormal(normal);
    }

    void localNormalToWorldTangentSpace(float3 normal, float4 tangent, out float3 out_normal, out float3 out_tangent, out float3 out_bitangent, float flipMirrorX, float flipMirrorY) {
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

    void localNormalToWorldTangentSpace(float3 normal, float4 tangent, out float3 out_normal, out float3 out_tangent, out float3 out_bitangent, float flipTangent) {
        localNormalToWorldTangentSpace(normal, tangent, out_normal, out_tangent, out_bitangent, flipTangent, flipTangent);
    }

    ////////////////////////////
    // Lighting
    ////////////////////////////

    static const float3 BT601 = { 0.299, 0.587, 0.114 };
    static const float3 BT709 = { 0.21, 0.72, 0.07 };

    float calcBrightness(float3 color) {
        return dot(color, BT601);
    }

    float3 calcPointLight1WorldDir(float3 ws_vertex) {
        ws_vertex = getPoint1LightPos() - ws_vertex;
        if (dot(ws_vertex, ws_vertex) < 0.1) {
            ws_vertex = float3(0, 1, 0);
        }
        return SafeNormalizeVec3( ws_vertex );
    }

    float3 calcPointLight1Dir(float3 ws_vertex) {
        ws_vertex = getPoint1LightPos() - ws_vertex;
        if (dot(ws_vertex, ws_vertex) < 0.1) {
            ws_vertex = float3(0, 1, 0);
        }
        return UnityWorldToObjectDir( ws_vertex );
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

    inline float3 blendColor_Alpha(float3 base, float3 over, float power) {
        // アルファブレンド
        float3 c = over;
        return lerp(base, c, power);
    }

    inline float3 blendColor_Add(float3 base, float3 over, float power) {
        // 加算
        float3 c = base + over;
        return lerp(base, c, power);
    }

    inline float3 blendColor_Mul(float3 base, float3 over, float power) {
        // 乗算
        float3 c = base * over;
        return lerp(base, c, power);
    }

    inline float3 blendColor_AddAndSub(float3 base, float3 over, float power) {
        // 半加算
        float3 c = base + over - MEDIAN_GRAY;
        return lerp(base, c, power);
    }

    inline float3 blendColor_Screen(float3 base, float3 over, float power) {
        // スクリーン
        float3 c = 1 - (1 - base) * (1 - over);
        return lerp(base, c, power);
    }

    inline float3 blendColor_Overlay(float3 base, float3 over, float power) {
        // オーバーレイ
        float3 c = lerp(
                2 * base * over,
                1 - 2 * (1 - base) * (1 - over.rgb),
                step(AVE_RGB(base), 0.5)
            );
        return lerp(base, c, power);
    }

    inline float3 blendColor_HardLight(float3 base, float3 over, float power) {
        // ハードライト
        float3 c = lerp(
                2 * base * over,
                1 - 2 * (1 - base) * (1 - over.rgb),
                step(AVE_RGB(over), 0.5)
            );
        return lerp(base, c, power);
    }

    ////////////////////////////
    // Matcap
    ////////////////////////////

    float3 matcapViewCorrect(float3 vs_normal, float3 ws_view_dir) {
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

    float3 calcMatcapVector(in float3 ws_view_dir, in float3 ws_normal) {
        // ワールド法線をビュー法線に変換
        float3 vs_normal = mul(float4(ws_normal, 1), UNITY_MATRIX_I_V).xyz;

        // カメラ位置にて補正する
        vs_normal = matcapViewCorrect(vs_normal, ws_view_dir);
        // 真上を揃える
        vs_normal.xy = mul( vs_normal.xy, matcapRotateCorrectMatrix() );

        return normalize( vs_normal );
    }

    float4x4 calcMatcapVectorArray(in float3 ws_view_dir, in float3 ws_camera_dir, in float3 ws_normal, in float3 ws_bump_normal) {
        // ワールド法線をビュー法線に変換
        float3 vs_normal        = mul(float4(ws_normal, 1), UNITY_MATRIX_I_V).xyz;
        float3 vs_bump_normal   = mul(float4(ws_bump_normal, 1), UNITY_MATRIX_I_V).xyz;

        // カメラ位置にて補正する
        float3 vs_normal_center         = matcapViewCorrect(vs_normal, ws_view_dir);
        float3 vs_normal_side           = matcapViewCorrect(vs_normal, ws_camera_dir);
        float3 vs_bump_normal_center    = matcapViewCorrect(vs_bump_normal, ws_view_dir);
        float3 vs_bump_normal_side      = matcapViewCorrect(vs_bump_normal, ws_camera_dir);

        // 真上を揃える
        float2x2 rotate = matcapRotateCorrectMatrix();
        vs_normal_center.xy         = mul( vs_normal_center.xy, rotate );
        vs_normal_side.xy           = mul( vs_normal_side.xy, rotate );
        vs_bump_normal_center.xy    = mul( vs_bump_normal_center.xy, rotate );
        vs_bump_normal_side.xy      = mul( vs_bump_normal_side.xy, rotate );

        float4x4 matcapVector;
        matcapVector[0] = float4( normalize(vs_normal_center), 0 );
        matcapVector[1] = float4( normalize(vs_bump_normal_center), 0 );
        matcapVector[2] = float4( normalize(vs_normal_side), 0 );
        matcapVector[3] = float4( normalize(vs_bump_normal_side), 0 );
        return matcapVector;
    }

    float3 calcMatcapVector(float4x4 matcapVector, float normal, float parallax) {
        return lerp( lerp(matcapVector[0].xyz, matcapVector[1].xyz, normal), lerp(matcapVector[2].xyz, matcapVector[3].xyz, normal), parallax);
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
    float3 pickReflectionCubemap(samplerCUBE cubemap, half4 cubemap_HDR, float3 ws_vertex, float3 ws_normal, float lod) {
        float3 ws_camera_dir = worldSpaceCameraDir(ws_vertex);
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float4 color = texCUBElod(cubemap, float4(reflect_dir, lod) );
        return DecodeHDR(color, cubemap_HDR);
    }
*/

#endif
