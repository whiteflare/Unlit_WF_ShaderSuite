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

#ifndef INC_UNLIT_WF_COMMON_LIGHTWEIGHT_RP
#define INC_UNLIT_WF_COMMON_LIGHTWEIGHT_RP

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#if UNITY_VERSION < 201904
    #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
#else
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#endif

    ////////////////////////////
    // Texture Definition
    ////////////////////////////

    #define DECL_MAIN_TEX2D(name)                       TEXTURE2D(name); SAMPLER(sampler##name)
    #define PICK_MAIN_TEX2D(tex, uv)                    SAMPLE_TEXTURE2D(tex, sampler##tex, uv)

    #define DECL_SUB_TEX2D(name)                        TEXTURE2D(name)
    #define PICK_SUB_TEX2D(tex, name, uv)               SAMPLE_TEXTURE2D(tex, sampler##name, uv)

    #define DECL_MAIN_TEXCUBE(name)                     TEXTURECUBE(name); SAMPLER(sampler##name)
    #define PICK_MAIN_TEXCUBE_LOD(tex, dir, lod)        SAMPLE_TEXTURECUBE_LOD(tex, sampler##tex, dir, lod)

    #define PICK_SUB_TEXCUBE_LOD(tex, name, dir, lod)   SAMPLE_TEXTURECUBE_LOD(tex, sampler##name, dir, lod)

    #define DECL_VERT_TEX2D(name)                       TEXTURE2D(name); SAMPLER(sampler##name)
    #define PICK_VERT_TEX2D_LOD(tex, uv, lod)           SAMPLE_TEXTURE2D_LOD(tex, sampler##tex, uv, lod)

    ////////////////////////////
    // Compatible
    ////////////////////////////

    // Unity BuiltinRP で定義されていた関数を LightweightRP で定義しなおして差異を吸収する

    float IsGammaSpace() {
        #ifdef UNITY_COLORSPACE_GAMMA
            return 1;
        #else
            return 0;
        #endif
    }

    #define UnityObjectToClipPos        TransformObjectToHClip
    #define UnityWorldToClipPos         TransformWorldToHClip
    #define UnityObjectToWorldDir       TransformObjectToWorldDir
    #define UnityWorldToObjectDir       TransformWorldToObjectDir
    #define UnityObjectToWorldNormal    TransformObjectToWorldNormal

    #define UnityObjectToWorldPos(v)    TransformObjectToWorld(v)
    #define UnityWorldToObjectPos(v)    TransformWorldToObject(v)

    #define UNITY_FOG_COORDS(id)        half fogCoord : TEXCOORD##id;
    #define UNITY_TRANSFER_FOG(o, p)    o.fogCoord = ComputeFogFactor(p.z)
    #define UNITY_APPLY_FOG(f, c)       c.rgb = MixFog(c.rgb, f)

    #define UNITY_INITIALIZE_OUTPUT(name, val)  val = (name) 0
    #define UNITY_SAMPLE_TEXCUBE_LOD(tex, dir, lod)                     SAMPLE_TEXTURECUBE_LOD(tex, sampler##tex, dir, lod)
    #define UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(tex, name, dir, lod)       SAMPLE_TEXTURECUBE_LOD(tex, sampler##name, dir, lod)

    #define GammaToLinearSpace          SRGBToLinear
    #define LinearToGammaSpace          LinearToSRGB
    #define UNITY_TWO_PI                6.28318530718f
    #define UNITY_INV_TWO_PI            0.15915494309f
    #define UnpackScaleNormal           UnpackNormalScale
    #define BlendNormals                BlendNormal
    #define GGXTerm                     D_GGX

    float3 DecodeLightmap(float4 lmap_tex) {
        return DecodeLightmap(lmap_tex, half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h));
    }
    float3 DecodeRealtimeLightmap(float4 lmap_tex) {
        return DecodeLightmap(lmap_tex, half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h));
    }

    float3 DecodeHDR(float4 color, float4 inst) {
        return DecodeHDREnvironment(color, inst);
    }

    ////////////////////////////
    // Lighting
    ////////////////////////////

    float3 getMainLightDirection() {
        return _MainLightPosition.xyz;
    }

    float3 sampleMainLightColor() {
        return _MainLightColor.rgb;
    }

    float3 sampleSHLightColor() {
        float3 col = float3(0, 0, 0);
        col += SampleSH( float3(+1, 0, 0) );
        col += SampleSH( float3(-1, 0, 0) );
        col += SampleSH( float3(0, 0, +1) );
        col += SampleSH( float3(0, 0, -1) );
        col /= 4;
        col += SampleSH( float3(0, +1, 0) );
        col += SampleSH( float3(0, -1, 0) );
        return col / 3;
    }

    float3 getPoint1LightPos() {
        return 1 <= GetAdditionalLightsCount() ? _AdditionalLightsPosition[0].xyz : float3(0, 0, 0);
    }

    float3 samplePoint1LightColor(float3 ws_vertex) {
        if (GetAdditionalLightsCount() < 1) {
            return float3(0, 0, 0);
        } else {
            Light light = GetAdditionalLight(0, ws_vertex);
            return light.color * light.distanceAttenuation;
        }
    }

    float3 sampleAdditionalLightColor(float3 ws_vertex) {
        float3 col = float3(0, 0, 0);

        int pixelLightCount = GetAdditionalLightsCount();
        for (int i = 0; i < pixelLightCount; ++i) {
            Light light = GetAdditionalLight(i, ws_vertex);
            col += light.color * light.distanceAttenuation;
        }

        return col;
    }

    float3 sampleAdditionalLightColorExclude1(float3 ws_vertex) {
        float3 col = float3(0, 0, 0);

        int pixelLightCount = GetAdditionalLightsCount();
        for (int i = 1; i < pixelLightCount; ++i) {
            Light light = GetAdditionalLight(i, ws_vertex);
            col += light.color * light.distanceAttenuation;
        }

        return col;
    }

    ////////////////////////////
    // Lightmap Sampler
    ////////////////////////////

    float3 pickLightmap(float2 uv_lmap) {
        float3 color = float3(0, 0, 0);
        #ifdef LIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            float4 lmap_tex = PICK_MAIN_TEX2D(unity_Lightmap, uv);
            float3 lmap_color = DecodeLightmap(lmap_tex);
            color += lmap_color;
        }
        #endif
        #ifdef DYNAMICLIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
            float4 lmap_tex = PICK_MAIN_TEX2D(unity_DynamicLightmap, uv);
            float3 lmap_color = DecodeRealtimeLightmap(lmap_tex);
            color += lmap_color;
        }
        #endif
        return color;
    }

    float3 pickLightmapLod(float2 uv_lmap) {
        return float3(1, 1, 1);
        // SRP Batcher を有効にするために、vertシェーダとfragシェーダの両方から読むことを諦め、fragシェーダの方を生かす。vertでは白色を返す。
    }

    ////////////////////////////
    // ReflectionProbe Sampler
    ////////////////////////////

    float4 pickReflectionProbe(float3 ws_vertex, float3 ws_normal, float lod) {
        float4 color0 = float4(0, 0, 0, 1);

#if !defined(_ENVIRONMENTREFLECTIONS_OFF)
        float3 ws_camera_dir = normalize(_WorldSpaceCameraPos - ws_vertex);
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float3 dir0 = reflect_dir;

        color0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dir0, lod);

#if !defined(UNITY_USE_NATIVE_HDR)
        color0.rgb = DecodeHDR(color0, unity_SpecCube0_HDR);
#endif

#endif

        return color0;
    }

#endif
