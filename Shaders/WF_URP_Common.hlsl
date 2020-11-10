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

#ifndef INC_UNLIT_WF_COMMON
#define INC_UNLIT_WF_COMMON

    /*
     * authors:
     *      ver:2020/10/13 whiteflare,
     */

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
    #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"

    ////////////////////////////
    // Common Utility
    ////////////////////////////

    #define TGL_ON(value)   (0.5 <= value)
    #define TGL_OFF(value)  (value < 0.5)
    #define TGL_01(value)   step(0.5, value)

    static const float3 MEDIAN_GRAY =
        #ifdef UNITY_COLORSPACE_GAMMA
            float3(0.5, 0.5, 0.5);
        #else
            SRGBToLinear( float3(0.5, 0.5, 0.5) );
        #endif

    #define MAX3(r, g, b)   max(r, max(g, b) )
    #define AVE3(r, g, b)   ((r + g + b) / 3)
    #define MAX_RGB(v)      max(v.r, max(v.g, v.b))
    #define AVE_RGB(v)      ((v.r + v.g + v.b) / 3)

    #define DECL_MAIN_TEX2D(name)           TEXTURE2D(name); SAMPLER(sampler##name)
    #define DECL_SUB_TEX2D(name)            TEXTURE2D(name)
    #define PICK_MAIN_TEX2D(tex, uv)        SAMPLE_TEXTURE2D(tex, sampler##tex, uv)
    #define PICK_SUB_TEX2D(tex, name, uv)   SAMPLE_TEXTURE2D(tex, sampler##name, uv)


// Unity BuiltinRP で定義されていた関数を LightweightRP で定義しなおして差異を吸収する

    #define UnityObjectToClipPos        TransformObjectToHClip
    #define UnityWorldToClipPos         TransformWorldToHClip
    #define UnityObjectToWorldDir       TransformObjectToWorldDir
    #define UnityWorldToObjectDir       TransformWorldToObjectDir
    #define UnityObjectToWorldNormal    TransformObjectToWorldNormal

    #define UNITY_INITIALIZE_OUTPUT(name, val)  val = (name) 0
    #define UNITY_SAMPLE_TEXCUBE_LOD(tex, dir, lod)                     SAMPLE_TEXTURECUBE_LOD(tex, sampler##tex, dir, lod)
    #define UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(tex, name, dir, lod)       SAMPLE_TEXTURECUBE_LOD(tex, sampler##name, dir, lod)

    #define _LightColor0                _MainLightColor
    #define _WorldSpaceLightPos0        _MainLightPosition
    #define UNITY_INV_TWO_PI            0.15915494309f



    #define INVERT_MASK_VALUE(rgba, inv)            saturate( TGL_OFF(inv) ? rgba : float4(1 - rgba.rgb, rgba.a) )
    #define SAMPLE_MASK_VALUE(tex, uv, inv)         INVERT_MASK_VALUE( PICK_SUB_TEX2D(tex, _MainTex, uv), inv )
    #define SAMPLE_MASK_VALUE_LOD(tex, uv, inv)     INVERT_MASK_VALUE( tex2Dlod(tex, float4(uv.x, uv.y, 0, 0)), inv )

    #define NZF                                     0.00390625
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
        if (lenSq < 0.0001) {
            return float2(0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    float3 SafeNormalizeVec3(float3 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < 0.0001) {
            return float3(0, 0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    float3 SafeNormalizeVec3Normal(float3 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < 0.0001) {
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

    void localNormalToWorldTangentSpace(float3 normal, float4 tangent, out float3 out_normal, out float3 out_tangent, out float3 out_bitangent, float flipTangent) {
        // Normalは普通に計算
        localNormalToWorldTangentSpace(normal, out_normal);

        float tan_sign = step(0, tangent.w) * 2 - 1;
        if (TGL_OFF(flipTangent)) {
            // 通常のtangent算出
            out_tangent = UnityObjectToWorldNormal(tangent.xyz);
            out_bitangent = cross(out_normal, out_tangent) * tan_sign;
        } else {
            // tangentフリップ版
            out_tangent = UnityObjectToWorldNormal(tangent.xyz) * tan_sign;
            out_bitangent = cross(out_normal, out_tangent);
        }
    }

    ////////////////////////////
    // Lighting
    ////////////////////////////

    static const float3 BT601 = { 0.299, 0.587, 0.114 };
    static const float3 BT709 = { 0.21, 0.72, 0.07 };

    float calcBrightness(float3 color) {
        return dot(color, BT601);
    }

    float3 calcPointLight1Pos() {
        return 1 <= GetAdditionalLightsCount() ? _AdditionalLightsPosition[0].xyz : ZERO_VEC3;
    }

    float3 calcPointLight1Color(float3 ws_vertex) {
        float3 ws_lightPos = calcPointLight1Pos();
        if (ws_lightPos.x == 0 && ws_lightPos.y == 0 && ws_lightPos.z == 0) {
            return float3(0, 0, 0); // XYZすべて0はポイントライト未設定と判定する
        }
        float3 ls_lightPos = ws_lightPos - ws_vertex;
        float lengthSq = dot(ls_lightPos, ls_lightPos);
        float atten = DistanceAttenuation(lengthSq, _AdditionalLightsAttenuation[0].xy) * AngleAttenuation(_AdditionalLightsSpotDir[0].xyz, SafeNormalizeVec3(ls_lightPos), _AdditionalLightsAttenuation[0].zw);
        return _AdditionalLightsColor[0].rgb * atten;
    }

    float3 OmniDirectional_ShadeSH9() {
        // UnityCG.cginc にある ShadeSH9 の等方向版
        float3 col = 0;
        col += SampleSH( float3(+1, 0, 0) );
        col += SampleSH( float3(-1, 0, 0) );
        col += SampleSH( float3(0, 0, +1) );
        col += SampleSH( float3(0, 0, -1) );
        col /= 4;
        col += SampleSH( float3(0, +1, 0) );
        col += SampleSH( float3(0, -1, 0) );
        return col / 3;
    }

    float3 calcAllAdditionalLightColor(float3 ws_vertex) {
        float3 col = ZERO_VEC3;

        int pixelLightCount = GetAdditionalLightsCount();
        for (int i = 0; i < pixelLightCount; ++i) {
            Light light = GetAdditionalLight(i, ws_vertex);
            col += light.color * light.distanceAttenuation;
        }

        return col;
    }

    float3 calcPointLight1WorldDir(float3 ws_vertex) {
        ws_vertex = calcPointLight1Pos() - ws_vertex;
        if (dot(ws_vertex, ws_vertex) < 0.1) {
            ws_vertex = float3(0, 1, 0);
        }
        return SafeNormalizeVec3( ws_vertex );
    }

    float3 calcPointLight1Dir(float3 ws_vertex) {
        ws_vertex = calcPointLight1Pos() - ws_vertex;
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

    float3 worldSpaceCameraDir(float3 ws_vertex) {
        return normalize(_WorldSpaceCameraPos - ws_vertex);
    }

    float3 worldSpaceViewPointPos() {
        #ifdef USING_STEREO_MATRICES
            return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
        #else
            return _WorldSpaceCameraPos;
        #endif
    }

    float3 worldSpaceViewPointDir(float3 ws_vertex) {
        return SafeNormalizeVec3(worldSpaceViewPointPos() - ws_vertex);
    }

    float3 worldSpaceViewDirStereoLerp(float3 ws_vertex, float x) {
        return SafeNormalizeVec3(lerp(worldSpaceViewPointPos(), _WorldSpaceCameraPos, x) - ws_vertex);
    }

    bool isInMirror() {
        return unity_CameraProjection[2][0] != 0.0f || unity_CameraProjection[2][1] != 0.0f;
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
    // Lightmap Sampler
    ////////////////////////////

    float3 pickLightmap(float2 uv_lmap) {
        float3 color = ZERO_VEC3;
        #ifdef LIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            float4 lmap_tex = SAMPLE_TEXTURE2D(unity_Lightmap, samplerunity_Lightmap, uv);
            float3 lmap_color = DecodeLightmap(lmap_tex, half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h));
            color += lmap_color;
        }
        #endif
        #ifdef DYNAMICLIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
            float4 lmap_tex = SAMPLE_TEXTURE2D(unity_DynamicLightmap, samplerunity_DynamicLightmap, uv);
            float3 lmap_color = DecodeLightmap(lmap_tex, half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h));
            color += lmap_color;
        }
        #endif
        return color;
    }

    float3 pickLightmapLod(float2 uv_lmap) {
        float3 color = ZERO_VEC3;

        #ifdef LIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            float4 lmap_tex = SAMPLE_TEXTURE2D_LOD(unity_Lightmap, samplerunity_Lightmap, uv, 0);
            float3 lmap_color = DecodeLightmap(lmap_tex, half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h));
            color += lmap_color;
        }
        #endif
        #ifdef DYNAMICLIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
            float4 lmap_tex = WF_SAMPLE_TEX2D_LOD(unity_DynamicLightmap, samplerunity_DynamicLightmap, uv, 0);
            float3 lmap_color = DecodeLightmap(lmap_tex, half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h));
            color += lmap_color;
        }
        #endif
        return color;
    }

    ////////////////////////////
    // ReflectionProbe Sampler
    ////////////////////////////

    float4 pickReflectionProbe(float3 ws_vertex, float3 ws_normal, float lod) {
        float3 ws_camera_dir = worldSpaceCameraDir(ws_vertex);
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float3 dir0 = reflect_dir; // BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        // float3 dir1 = reflect_dir; // BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

        float4 color0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dir0, lod);
        // float4 color1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, dir1, lod);

        color0.rgb = DecodeHDREnvironment(color0, unity_SpecCube0_HDR);
        // color1.rgb = DecodeHDREnvironment(color1, unity_SpecCube1_HDR);

        return color0;
        // return lerp(color1, color0, unity_SpecCube0_BoxMin.w);
    }

    float3 pickReflectionCubemap(samplerCUBE cubemap, half4 cubemap_HDR, float3 ws_vertex, float3 ws_normal, float lod) {
        float3 ws_camera_dir = worldSpaceCameraDir(ws_vertex);
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float4 color = texCUBElod(cubemap, float4(reflect_dir, lod) );
        return DecodeHDREnvironment(color, cubemap_HDR);
    }

#endif
