/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2024 whiteflare.
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

#ifndef INC_UNLIT_WF_UNTOON_META
#define INC_UNLIT_WF_UNTOON_META

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "../WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4  vertex              : POSITION;
        float2  uv0                 : TEXCOORD0;
        float2  uv1                 : TEXCOORD1;
        float2  uv2                 : TEXCOORD2;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color        : COLOR0;
#endif
    };

    struct v2f_meta {
        float4  pos                 : SV_POSITION;
        float2  uv                  : TEXCOORD0;
        float2  uv2                 : TEXCOORD1;
        float3  ws_vertex           : TEXCOORD2;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color        : COLOR0;
#endif
    };

    #define IN_FRAG v2f_meta

    struct drawing {
        half4   color;
        float2  uv1;
        float2  uv2;
        float2  uv_main;
        float3  ws_vertex;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color;
#endif
    };

    drawing prepareDrawing(IN_FRAG i) {
        drawing d = (drawing) 0;

        d.color         = half4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;
        d.ws_vertex     = i.ws_vertex;
#ifdef _V2F_HAS_VERTEXCOLOR
        d.vertex_color  = i.vertex_color;
#endif

        return d;
    }

    ////////////////////////////
    // Unity Meta function
    ////////////////////////////

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "../WF_UnToon_Function.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_meta vert_meta(appdata i) {
        v2f_meta o;
        UNITY_INITIALIZE_OUTPUT(v2f_meta, o);

        o.pos   = MetaVertexPosition(i.vertex, i.uv1, i.uv2, unity_LightmapST, unity_DynamicLightmapST);
        o.uv = i.uv0;
        o.uv2 = i.uv1;
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = i.vertex_color;
#endif
        o.ws_vertex = UnityObjectToWorldPos(i.vertex.xyz);

        return o;
    }

    half4 frag_meta(v2f_meta i) : SV_Target {
        MetaInput o;
        UNITY_INITIALIZE_OUTPUT(MetaInput, o);

        drawing d = prepareDrawing(i);
        d.color = _Color;

        prepareMainTex(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawVertexColor(d);         // 頂点カラー

        // 単色化
#ifdef _WF_DEFINED_LBE
        d.color.rgb = max(ZERO_VEC3, lerp(AVE_RGB(d.color.rgb).xxx, d.color.rgb, lerp(1, _LBE_IndirectChroma, _LBE_Enable)));
        o.Albedo  = d.color.rgb * lerp(1, _LBE_IndirectMultiplier, _LBE_Enable);
#else
        o.Albedo  = d.color.rgb;
#endif

#if UNITY_VERSION < 202103
        o.SpecularColor = o.Albedo;
#endif
        o.Emission      = ZERO_VEC3;    // 初期化

#ifdef _ES_ENABLE

FEATURE_TGL_ON_BEGIN(_ES_Enable)
        float4 es_mask  = PICK_SUB_TEX2D(_EmissionMap, _MainTex, d.uv_main).rgba;
        float4 es_color = _EmissionColor * es_mask;
#ifdef _WF_DEFINED_LBE
        o.Emission  = es_color.rgb * lerp(1, _LBE_EmissionMultiplier, _LBE_Enable);
#else
        o.Emission  = es_color.rgb;
#endif
FEATURE_TGL_END

#endif

        return MetaFragment(o);
    }

    half4 frag_meta_black(v2f_meta i) : SV_Target {
        MetaInput o;
        UNITY_INITIALIZE_OUTPUT(MetaInput, o);

        o.Albedo        = ZERO_VEC3;
#if UNITY_VERSION < 202103
        o.SpecularColor = ZERO_VEC3;
#endif
        o.Emission      = ZERO_VEC3;

        return MetaFragment(o);
    }

#endif
