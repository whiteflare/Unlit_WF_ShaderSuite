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

#ifndef INC_UNLIT_WF_UNTOON_META
#define INC_UNLIT_WF_UNTOON_META

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "WF_INPUT_UnToon.cginc"

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
#ifdef EDITOR_VISUALIZATION
        float2 vizUV            : TEXCOORD1;
        float4 lightCoord       : TEXCOORD2;
#endif
    };

    ////////////////////////////
    // Unity Meta function
    ////////////////////////////

    #include "UnityMetaPass.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_meta vert_meta(appdata v) {
        v2f_meta o;
        UNITY_INITIALIZE_OUTPUT(v2f_meta, o);

        o.pos   = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
        o.uv    = TRANSFORM_TEX(v.uv0, _MainTex);
#ifdef _VC_ENABLE
        o.vertex_color = v.vertex_color;
#endif

#ifdef EDITOR_VISUALIZATION
        if (unity_VisualizationMode == EDITORVIZ_TEXTURE) {
            o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv0.xy, v.uv1.xy, v.uv2.xy, unity_EditorViz_Texture_ST);
        }
        else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK) {
            o.vizUV         = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            o.lightCoord    = mul(unity_EditorViz_WorldToLight, UnityObjectToWorldPos(v.vertex));
        }
#endif

        return o;
    }

    float4 frag_meta(v2f_meta i) : SV_Target {
        UnityMetaInput o;
        UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);

        float4 color    = _Color * PICK_MAIN_TEX2D(_MainTex, uv_main);
#ifdef _VC_ENABLE
        color *= lerp(ONE_VEC4, i.vertex_color, _UseVertexColor);
#endif

        // 単色化
        color.rgb = max(ZERO_VEC3, lerp(AVE_RGB(color.rgb).xxx, color.rgb, lerp(1, _GI_IndirectChroma, _GI_Enable)));

        o.Albedo        = color.rgb * lerp(1, _GI_IndirectMultiplier, _GI_Enable);
        o.SpecularColor = o.Albedo;

#ifdef _ES_ENABLE
#ifdef _WF_LEGACY_FEATURE_SWITCH
        if (TGL_ON(_ES_Enable)) {
#endif
            float4 es_mask  = PICK_SUB_TEX2D(_EmissionMap, _MainTex, uv_main).rgba;
            float4 es_color = _EmissionColor * es_mask;
            o.Emission  = es_color.rgb * es_color.a * lerp(1, _GI_EmissionMultiplier, _GI_Enable);
#ifdef _WF_LEGACY_FEATURE_SWITCH
        } else {
            o.Emission  = ZERO_VEC3;
        }
#endif
#endif

#ifdef EDITOR_VISUALIZATION
        o.VizUV         = i.vizUV;
        o.LightCoord    = i.lightCoord;
#endif

        return UnityMetaFragment(o);
    }

    float4 frag_meta_black(v2f_meta i) : SV_Target {
        UnityMetaInput o;
        UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

        o.Albedo        = ZERO_VEC3;
        o.SpecularColor = ZERO_VEC3;
        o.Emission      = ZERO_VEC3;

#ifdef EDITOR_VISUALIZATION
        o.VizUV         = i.vizUV;
        o.LightCoord    = i.lightCoord;
#endif

        return UnityMetaFragment(o);
    }

#endif
