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

#ifndef INC_UNLIT_WF_COMMON_BUILTIN_RP
#define INC_UNLIT_WF_COMMON_BUILTIN_RP

    #include "UnityCG.cginc"
    #include "Lighting.cginc"

    ////////////////////////////
    // Texture Definition
    ////////////////////////////

    #define DECL_MAIN_TEX2D(name)                       UNITY_DECLARE_TEX2D(name)
    #define PICK_MAIN_TEX2D(tex, uv)                    UNITY_SAMPLE_TEX2D(tex, uv)

    #define DECL_SUB_TEX2D(name)                        UNITY_DECLARE_TEX2D_NOSAMPLER(name)
    #define PICK_SUB_TEX2D(tex, name, uv)               UNITY_SAMPLE_TEX2D_SAMPLER(tex, name, uv)

    #define DECL_MAIN_TEXCUBE(name)                     UNITY_DECLARE_TEXCUBE(name)
    #define PICK_MAIN_TEXCUBE_LOD(tex, dir, lod)        UNITY_SAMPLE_TEXCUBE_LOD(tex, dir, lod)

    #define PICK_SUB_TEXCUBE_LOD(tex, name, dir, lod)   UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(tex, name, dir, lod)

#ifdef SHADER_API_D3D11
    #define DECL_VERT_TEX2D(name)                       UNITY_DECLARE_TEX2D(name)
    #define PICK_VERT_TEX2D_LOD(tex, uv, lod)           tex.SampleLevel(sampler##tex, uv, lod)
#else
    #define DECL_VERT_TEX2D(name)                       sampler2D name
    #define PICK_VERT_TEX2D_LOD(tex, uv, lod)           tex2Dlod(tex, float4(uv.x, uv.y, 0, lod))
#endif

    ////////////////////////////
    // Compatible
    ////////////////////////////

    #define UnityObjectToWorldPos(v)    ( mul(unity_ObjectToWorld, float4(v.xyz, 1)).xyz )
    #define UnityWorldToObjectPos(v)    ( mul(unity_WorldToObject, float4(v.xyz, 1)).xyz )

    ////////////////////////////
    // Lighting
    ////////////////////////////

    float3 getMainLightDirection() {
        return _WorldSpaceLightPos0.xyz;
    }

    float3 sampleMainLightColor() {
        return _LightColor0.rgb;
    }

    float3 sampleSHLightColor() {
        float3 col = float3(0, 0, 0);
        col += ShadeSH9( float4(+1, 0, 0, 1) );
        col += ShadeSH9( float4(-1, 0, 0, 1) );
        col += ShadeSH9( float4(0, 0, +1, 1) );
        col += ShadeSH9( float4(0, 0, -1, 1) );
        col /= 4;
        col += ShadeSH9( float4(0, +1, 0, 1) );
        col += ShadeSH9( float4(0, -1, 0, 1) );
        return col / 3;
    }

    float3 getPoint1LightPos() {
#ifdef VERTEXLIGHT_ON
        return float3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
#else
        return float3(0, 0, 0);
#endif
    }

    float3 samplePoint1LightColor(float3 ws_vertex) {
#ifdef VERTEXLIGHT_ON
        float3 ws_lightPos = getPoint1LightPos();
        if (ws_lightPos.x == 0 && ws_lightPos.y == 0 && ws_lightPos.z == 0) {
            return float3(0, 0, 0); // XYZすべて0はポイントライト未設定と判定する
        }
        float3 ls_lightPos = ws_lightPos - ws_vertex;
        float lengthSq = dot(ls_lightPos, ls_lightPos);
        float atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0.x);
        return unity_LightColor[0].rgb * atten;
#else
        return float3(0, 0, 0);
#endif
    }

    float3 OmniDirectional_Shade4PointLights(
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


    float3 sampleAdditionalLightColor(float3 ws_vertex) {
#ifdef VERTEXLIGHT_ON
        return OmniDirectional_Shade4PointLights(
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb,
                unity_LightColor[1].rgb,
                unity_LightColor[2].rgb,
                unity_LightColor[3].rgb,
                unity_4LightAtten0,
                ws_vertex
            );
#else
        return float3(0, 0, 0);
#endif
    }

    float3 sampleAdditionalLightColorExclude1(float3 ws_vertex) {
#ifdef VERTEXLIGHT_ON
        return OmniDirectional_Shade4PointLights(
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                float3(0, 0, 0),
                unity_LightColor[1].rgb,
                unity_LightColor[2].rgb,
                unity_LightColor[3].rgb,
                unity_4LightAtten0,
                ws_vertex
            );
#else
        return float3(0, 0, 0);
#endif
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
#ifdef SHADER_API_D3D11
        float3 color = float3(0, 0, 0);
        #ifdef LIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            float4 lmap_tex = PICK_VERT_TEX2D_LOD(unity_Lightmap, uv, 0);
            float3 lmap_color = DecodeLightmap(lmap_tex);
            color += lmap_color;
        }
        #endif
        #ifdef DYNAMICLIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
            float4 lmap_tex = PICK_VERT_TEX2D_LOD(unity_DynamicLightmap, uv, 0);
            float3 lmap_color = DecodeRealtimeLightmap(lmap_tex);
            color += lmap_color;
        }
        #endif
        return color;
#else
        return float3(1, 1, 1);
#endif
    }

    ////////////////////////////
    // ReflectionProbe Sampler
    ////////////////////////////

    float4 pickReflectionProbe(float3 ws_vertex, float3 ws_normal, float lod) {
        float3 ws_camera_dir = normalize(_WorldSpaceCameraPos - ws_vertex);
        float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

        float3 dir0 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        float3 dir1 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

        float4 color0 = PICK_MAIN_TEXCUBE_LOD(unity_SpecCube0, dir0, lod);
        float4 color1 = PICK_SUB_TEXCUBE_LOD(unity_SpecCube1, unity_SpecCube0, dir1, lod);

        color0.rgb = DecodeHDR(color0, unity_SpecCube0_HDR);
        color1.rgb = DecodeHDR(color1, unity_SpecCube1_HDR);

        return lerp(color1, color0, unity_SpecCube0_BoxMin.w);
    }

#endif
