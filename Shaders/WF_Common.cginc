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
     *      ver:2020/05/14 whiteflare,
     */

    #include "UnityCG.cginc"
    #include "Lighting.cginc"

    #define _MATCAP_VIEW_CORRECT_ENABLE
    #define _MATCAP_ROTATE_CORRECT_ENABLE

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

#if 1
    // サンプラー節約のための差し替えマクロ
    // 節約にはなるけど最適化などで _MainTex のサンプリングが消えると途端に破綻する諸刃の剣
    #define DECL_MAIN_TEX2D(name)           UNITY_DECLARE_TEX2D(name)
    #define DECL_SUB_TEX2D(name)            UNITY_DECLARE_TEX2D_NOSAMPLER(name)
    #define PICK_MAIN_TEX2D(tex, uv)        UNITY_SAMPLE_TEX2D(tex, uv)
    #define PICK_SUB_TEX2D(tex, name, uv)   UNITY_SAMPLE_TEX2D_SAMPLER(tex, name, uv)
#else
    // 通常版
    #define DECL_MAIN_TEX2D(name)           sampler2D name
    #define DECL_SUB_TEX2D(name)            sampler2D name
    #define PICK_MAIN_TEX2D(tex, uv)        tex2D(tex, uv)
    #define PICK_SUB_TEX2D(tex, name, uv)   tex2D(tex, uv)
#endif

    #define INVERT_MASK_VALUE(rgba, inv)            saturate( TGL_OFF(inv) ? rgba : float4(1 - rgba.rgb, rgba.a) )
    #define SAMPLE_MASK_VALUE(tex, uv, inv)         INVERT_MASK_VALUE( PICK_SUB_TEX2D(tex, _MainTex, uv), inv )
    #define SAMPLE_MASK_VALUE_LOD(tex, uv, inv)     INVERT_MASK_VALUE( tex2Dlod(tex, float4(uv.x, uv.y, 0, 0)), inv )

    #define NZF                                     0.00390625
    #define NON_ZERO_FLOAT(v)                       max(v, NZF)
    #define NON_ZERO_VEC3(v)                        max(v, float3(NZF, NZF, NZF))
    #define ZERO_VEC3                               float3(0, 0, 0)
    #define ONE_VEC3                                float3(1, 1, 1)

    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        #define _LMAP_ENABLE
    #endif

    inline float2 SafeNormalizeVec2(float2 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < 0.0001) {
            return float2(0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    inline float3 SafeNormalizeVec3(float3 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < 0.0001) {
            return float3(0, 0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    ////////////////////////////
    // Lighting
    ////////////////////////////

    static const float3 BT601 = { 0.299, 0.587, 0.114 };
    static const float3 BT709 = { 0.21, 0.72, 0.07 };

    inline float calcBrightness(float3 color) {
        return dot(color, BT601);
    }

    inline float3 calcPointLight1Pos() {
        return float3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
    }

    inline float3 calcPointLight1Color(float3 ws_vertex) {
        float3 ws_lightPos = calcPointLight1Pos();
        if (ws_lightPos.x == 0 && ws_lightPos.y == 0 && ws_lightPos.z == 0) {
            return float3(0, 0, 0); // XYZすべて0はポイントライト未設定と判定する
        }
        float3 ls_lightPos = ws_lightPos - ws_vertex;
        float lengthSq = dot(ls_lightPos, ls_lightPos);
        float atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0.x);
        return unity_LightColor[0].rgb * atten;
    }

    inline float3 OmniDirectional_ShadeSH9() {
        // UnityCG.cginc にある ShadeSH9 の等方向版
        float3 col = 0;
        col += ShadeSH9( float4(+1, 0, 0, 1) );
        col += ShadeSH9( float4(-1, 0, 0, 1) );
        col += ShadeSH9( float4(0, 0, +1, 1) );
        col += ShadeSH9( float4(0, 0, -1, 1) );
        col /= 4;
        col += ShadeSH9( float4(0, +1, 0, 1) );
        col += ShadeSH9( float4(0, -1, 0, 1) );
        return col / 3;
    }

    inline float3 OmniDirectional_Shade4PointLights(
        float4 lpX, float4 lpY, float4 lpZ,
        float3 col0, float3 col1, float3 col2, float3 col3,
        float4 lightAttenSq, float3 ws_vertex) {
        // UnityCG.cginc にある Shade4PointLights の等方向版

        if ( !any(float3(lpX.x, lpY.x, lpZ.x)) ) {
            col0.rgb = 0;
        }

        float4 toLightX = lpX - ws_vertex.x;
        float4 toLightY = lpY - ws_vertex.y;
        float4 toLightZ = lpZ - ws_vertex.z;

        float4 lengthSq
            = toLightX * toLightX
            + toLightY * toLightY
            + toLightZ * toLightZ;
        // ws_normal との内積は取らない。これによって反射光の強さではなく、頂点に当たるライトの強さが取れる。

        // attenuation
        float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);

        float3 col
            = col0 * atten.x
            + col1 * atten.y
            + col2 * atten.z
            + col3 * atten.w;
        return col;
    }

    inline float3 calcPointLight1WorldDir(float3 ws_vertex) {
        ws_vertex = calcPointLight1Pos() - ws_vertex;
        if (dot(ws_vertex, ws_vertex) < 0.1) {
            ws_vertex = float3(0, 1, 0);
        }
        return SafeNormalizeVec3( ws_vertex );
    }

    inline float3 calcPointLight1Dir(float3 ws_vertex) {
        ws_vertex = calcPointLight1Pos() - ws_vertex;
        if (dot(ws_vertex, ws_vertex) < 0.1) {
            ws_vertex = float3(0, 1, 0);
        }
        return UnityWorldToObjectDir( ws_vertex );
    }

    inline float3 calcHorizontalCoordSystem(float azimuth, float alt) {
        azimuth = radians(azimuth + 90);
        alt = radians(alt);
        return normalize( float3(cos(azimuth) * cos(alt), sin(alt), -sin(azimuth) * cos(alt)) );
    }

    ////////////////////////////
    // Camera management
    ////////////////////////////

    inline float3 worldSpaceCameraPos() {
        #ifdef USING_STEREO_MATRICES
            return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
        #else
            return _WorldSpaceCameraPos;
        #endif
    }

    inline float3 worldSpaceCameraPosStereoLerp(float x) {
        return lerp(worldSpaceCameraPos(), _WorldSpaceCameraPos, x);
    }

    inline float3 worldSpaceViewDir(float3 ws_vertex) {
        return SafeNormalizeVec3(worldSpaceCameraPos() - ws_vertex);
    }

    inline float3 worldSpaceViewDirStereoLerp(float3 ws_vertex, float x) {
        return SafeNormalizeVec3(worldSpaceCameraPosStereoLerp(x) - ws_vertex);
    }

//    inline float3 localSpaceViewDir(float3 ws_vertex) {
//        return UnityWorldToObjectDir(worldSpaceCameraPos() - ws_vertex);
//    }

    inline bool isInMirror() {
        return unity_CameraProjection[2][0] != 0.0f || unity_CameraProjection[2][1] != 0.0f;
    }

    ////////////////////////////
    // Matcap
    ////////////////////////////

    inline float3 calcMatcapVector(in float3 ws_camera_dir, in float3 ws_normal) {
        float3 vs_normal = mul(float4(ws_normal, 1), UNITY_MATRIX_I_V).xyz;

        #ifdef _MATCAP_VIEW_CORRECT_ENABLE
            float3 base = mul( (float3x3)UNITY_MATRIX_V, ws_camera_dir ) * float3(-1, -1, 1) + float3(0, 0, 1);
            float3 detail = vs_normal.xyz * float3(-1, -1, 1);
            vs_normal = base * dot(base, detail) / base.z - detail;
        #endif

        #ifdef _MATCAP_ROTATE_CORRECT_ENABLE
            float2 vs_topdir = mul( (float3x3)UNITY_MATRIX_V, float3(0, 1, 0) ).xy;
            if (any(vs_topdir)) {
                vs_topdir = normalize(vs_topdir);
                float top_angle = sign(vs_topdir.x) * acos( clamp(vs_topdir.y, -1, 1) );
                float2x2 matrixRotate = { cos(top_angle), sin(top_angle), -sin(top_angle), cos(top_angle) };
                vs_normal.xy = mul( vs_normal.xy, matrixRotate );
            }
        #endif

        return normalize( vs_normal );
    }

    ////////////////////////////
    // RGB-HSV convert
    ////////////////////////////

    inline float3 rgb2hsv(float3 c) {
        // i see "https://qiita.com/_nabe/items/c8ba019f26d644db34a8"
        static float4 k = float4( 0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0 );
        static float e = 1.0e-10;
        float4 p = lerp( float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g) );
        float4 q = lerp( float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r) );
        float d = q.x - min(q.w, q.y);
        return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x );
    }

    inline float3 hsv2rgb(float3 c) {
        // i see "https://qiita.com/_nabe/items/c8ba019f26d644db34a8"
        static float4 k = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
        float3 p = abs( frac(c.xxx + k.xyz) * 6.0 - k.www );
        return c.z * lerp( k.xxx, saturate(p - k.xxx), c.y );
    }

    ////////////////////////////
    // Lightmap Sampler
    ////////////////////////////

    inline float3 pickLightmap(float2 uv_lmap) {
        float3 color = ZERO_VEC3;
        #ifdef LIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            float4 lmap_tex = UNITY_SAMPLE_TEX2D(unity_Lightmap, uv);
            float3 lmap_color = DecodeLightmap(lmap_tex);
            color += lmap_color;
        }
        #endif
        #ifdef DYNAMICLIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
            float4 lmap_tex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, uv);
            float3 lmap_color = DecodeRealtimeLightmap(lmap_tex);
            color += lmap_color;
        }
        #endif
        return color;
    }

    inline float3 pickLightmapLod(float2 uv_lmap) {
        float3 color = ZERO_VEC3;
        #ifdef SHADER_API_D3D11
            #define WF_SAMPLE_TEX2D_LOD(tex, coord, lod)                        tex.SampleLevel(sampler##tex,coord, lod)
            #define WF_SAMPLE_TEX2D_SAMPLER_LOD(tex, samplertex, coord, lod)    tex.SampleLevel(sampler##samplertex, coord, lod)

            #ifdef LIGHTMAP_ON
            {
                float2 uv = uv_lmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                float4 lmap_tex = WF_SAMPLE_TEX2D_LOD(unity_Lightmap, uv, 0);
                float3 lmap_color = DecodeLightmap(lmap_tex);
                color += lmap_color;
            }
            #endif
            #ifdef DYNAMICLIGHTMAP_ON
            {
                float2 uv = uv_lmap.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                float4 lmap_tex = WF_SAMPLE_TEX2D_LOD(unity_DynamicLightmap, uv, 0);
                float3 lmap_color = DecodeRealtimeLightmap(lmap_tex);
                color += lmap_color;
            }
            #endif
        #else
            color = ONE_VEC3;
        #endif
        return color;
    }

    ////////////////////////////
    // ReflectionProbe Sampler
    ////////////////////////////

    inline float4 pickReflectionProbe(float3 ws_vertex, float3 ws_normal, float lod) {
        float3 ws_camera_dir = normalize(_WorldSpaceCameraPos.xyz - ws_vertex );
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float3 dir0 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        float3 dir1 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

        float4 color0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dir0, lod);
        float4 color1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, dir1, lod);

        color0.rgb = DecodeHDR(color0, unity_SpecCube0_HDR);
        color1.rgb = DecodeHDR(color1, unity_SpecCube1_HDR);

        return lerp(color1, color0, unity_SpecCube0_BoxMin.w);
    }

    inline float3 pickReflectionCubemap(samplerCUBE cubemap, half4 cubemap_HDR, float3 ws_vertex, float3 ws_normal, float lod) {
        float3 ws_camera_dir = normalize(_WorldSpaceCameraPos.xyz - ws_vertex );
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float4 color = texCUBElod(cubemap, float4(reflect_dir, lod) );
        return DecodeHDR(color, cubemap_HDR);
    }

#endif
