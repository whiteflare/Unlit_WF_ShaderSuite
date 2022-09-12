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
        float4 vertex           : POSITION;
        float2 uv0              : TEXCOORD0;
        float2 uv1              : TEXCOORD1;
        float2 uv2              : TEXCOORD2;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR0;
#endif
    };

    struct v2f_meta {
        float4 pos              : SV_POSITION;
        float2 uv               : TEXCOORD0;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR0;
#endif
    };

    ////////////////////////////
    // Unity Meta function
    ////////////////////////////

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_meta vert_meta(appdata i) {
        v2f_meta o;
        UNITY_INITIALIZE_OUTPUT(v2f_meta, o);

        o.pos   = MetaVertexPosition(i.vertex, i.uv1, i.uv2, unity_LightmapST, unity_DynamicLightmapST);

        o.uv    = TRANSFORM_TEX(i.uv0, _MainTex);
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = i.vertex_color;
#endif

        return o;
    }

    float4 frag_meta(v2f_meta i) : SV_Target {
        MetaInput o;
        UNITY_INITIALIZE_OUTPUT(MetaInput, o);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);

        float4 color    = _Color * PICK_MAIN_TEX2D(_MainTex, uv_main);
#ifdef _VC_ENABLE
        color *= lerp(ONE_VEC4, i.vertex_color, _UseVertexColor);
#endif

        // 単色化
        color.rgb = max(ZERO_VEC3, lerp(AVE_RGB(color.rgb).xxx, color.rgb, lerp(1, _LBE_IndirectChroma, _LBE_Enable)));

        o.Albedo        = color.rgb * lerp(1, _LBE_IndirectMultiplier, _LBE_Enable);
#if UNITY_VERSION < 202103
        o.SpecularColor = o.Albedo;
#endif
        o.Emission      = ZERO_VEC3;    // 初期化

#ifdef _ES_ENABLE

FEATURE_TGL_ON_BEGIN(_ES_Enable)
        float4 es_mask  = PICK_SUB_TEX2D(_EmissionMap, _MainTex, uv_main).rgba;
        float4 es_color = _EmissionColor * es_mask;
        o.Emission  = es_color.rgb * es_color.a * lerp(1, _LBE_EmissionMultiplier, _LBE_Enable);
FEATURE_TGL_END

#endif

        return MetaFragment(o);
    }

    float4 frag_meta_black(v2f_meta i) : SV_Target {
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
