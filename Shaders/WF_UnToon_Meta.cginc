/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
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
#ifdef EDITOR_VISUALIZATION
        float2  vizUV               : TEXCOORD3;
        float4  lightCoord          : TEXCOORD4;
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

    #include "UnityMetaPass.cginc"

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f_meta vert_meta(appdata v) {
        v2f_meta o;
        UNITY_INITIALIZE_OUTPUT(v2f_meta, o);

        o.pos   = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
        o.uv = v.uv0;
        o.uv2 = v.uv1;
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif
        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);

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

    half4 frag_meta(v2f_meta i) : SV_Target {
        UnityMetaInput o;
        UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

        drawing d = prepareDrawing(i);
        d.color = _Color;

        prepareMainTex(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawVertexColor(d);         // 頂点カラー

        // 単色化
        d.color.rgb = max(ZERO_VEC3, lerp(AVE_RGB(d.color.rgb).xxx, d.color.rgb, lerp(1, _LBE_IndirectChroma, _LBE_Enable)));

        o.Albedo        = d.color.rgb * lerp(1, _LBE_IndirectMultiplier, _LBE_Enable);
        o.SpecularColor = o.Albedo;
        o.Emission      = ZERO_VEC3;    // 初期化

#ifdef _ES_ENABLE

FEATURE_TGL_ON_BEGIN(_ES_Enable)
        float4 es_mask  = PICK_SUB_TEX2D(_EmissionMap, _MainTex, d.uv_main).rgba;
        float4 es_color = _EmissionColor * es_mask;
        o.Emission  = es_color.rgb * lerp(1, _LBE_EmissionMultiplier, _LBE_Enable);
FEATURE_TGL_END

#endif

#ifdef EDITOR_VISUALIZATION
        o.VizUV         = i.vizUV;
        o.LightCoord    = i.lightCoord;
#endif

        return UnityMetaFragment(o);
    }

    half4 frag_meta_black(v2f_meta i) : SV_Target {
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
