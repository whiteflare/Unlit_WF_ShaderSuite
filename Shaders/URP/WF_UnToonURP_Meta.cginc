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

#ifndef INC_UNLIT_WF_UNTOON_META
#define INC_UNLIT_WF_UNTOON_META

    /*
     * authors:
     *      ver:2020/10/13 whiteflare,
     */

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
#ifdef _VC_ENABLE
        float4 vertex_color     : COLOR0;
#endif
    };

    struct v2f_meta {
        float4 pos              : SV_POSITION;
        float2 uv               : TEXCOORD0;
#ifdef _VC_ENABLE
        float4 vertex_color     : COLOR0;
#endif
    };

    ////////////////////////////
    // Unity Meta function
    ////////////////////////////

#if UNITY_VERSION < 201904
    #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
#else
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
#endif

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_meta vert_meta(appdata i) {
        v2f_meta o;
        UNITY_INITIALIZE_OUTPUT(v2f_meta, o);

#ifdef UNIVERSAL_META_PASS_INCLUDED
        o.pos   = MetaVertexPosition(i.vertex, i.uv1, i.uv2, unity_LightmapST, unity_DynamicLightmapST);
#else
        o.pos   = MetaVertexPosition(i.vertex, i.uv1, i.uv2, unity_LightmapST);
#endif

        o.uv    = TRANSFORM_TEX(i.uv0, _MainTex);
#ifdef _VC_ENABLE
        o.vertex_color = i.vertex_color;
#endif

        return o;
    }

    float4 frag_meta(v2f_meta i) : SV_Target {
        MetaInput o;
        UNITY_INITIALIZE_OUTPUT(MetaInput, o);

        float4 color    = _Color * PICK_MAIN_TEX2D(_MainTex, i.uv);
#ifdef _VC_ENABLE
        color *= lerp(ONE_VEC4, i.vertex_color, _UseVertexColor);
#endif

        o.Albedo        = color.rgb * color.a;
        o.SpecularColor = o.Albedo.rgb;

        float3 emission = _EmissionColor.rgb * PICK_SUB_TEX2D(_EmissionMap, _MainTex, i.uv).rgb + lerp(color.rgb, ZERO_VEC3, _ES_BlendType);
        o.Emission      = emission * _ES_Enable * _ES_BakeIntensity;

        return MetaFragment(o);
    }

#endif
