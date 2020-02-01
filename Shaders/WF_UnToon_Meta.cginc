/*
 *  The MIT License
 *
 *  Copyright 2018-2019 whiteflare.
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
     *      ver:2020/02/01 whiteflare,
     */

    #include "UnityCG.cginc"
    #include "UnityMetaPass.cginc"

    #define ZERO_VEC3   float3(0, 0, 0)

    struct appdata {
        float4 vertex           : POSITION;
        float2 uv0              : TEXCOORD0;
        float2 uv1              : TEXCOORD1;
        float2 uv2              : TEXCOORD2;
    };

    struct v2f_meta {
        float4 pos              : SV_POSITION;
        float2 uv               : TEXCOORD0;
        #ifdef EDITOR_VISUALIZATION
            float2 vizUV        : TEXCOORD1;
            float4 lightCoord   : TEXCOORD2;
        #endif
    };

    sampler2D       _MainTex;
    float4          _MainTex_ST;
    float4          _Color;

    float           _ES_Enable;
    sampler2D       _EmissionMap;
    float4          _EmissionColor;
    float           _ES_BlendType;

    v2f_meta vert_meta(appdata v) {
        v2f_meta o;
        UNITY_INITIALIZE_OUTPUT(v2f_meta, o);

        o.pos   = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
        o.uv    = TRANSFORM_TEX(v.uv0, _MainTex);

        #ifdef EDITOR_VISUALIZATION
            if (unity_VisualizationMode == EDITORVIZ_TEXTURE) {
                o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv0.xy, v.uv1.xy, v.uv2.xy, unity_EditorViz_Texture_ST);
            }
            else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK) {
                o.vizUV         = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                o.lightCoord    = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
            }
        #endif

        return o;
    }

    float4 frag_meta(v2f_meta i) : SV_Target {
        UnityMetaInput o;
        UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

        float4 color    = _Color * tex2D(_MainTex, i.uv);

        o.Albedo        = color.rgb * color.a;
        o.SpecularColor = o.Albedo.rgb;

        float3 emission = _EmissionColor.rgb * tex2D(_EmissionMap, i.uv).rgb + lerp(color.rgb, ZERO_VEC3, _ES_BlendType);
        o.Emission      = emission * _ES_Enable;

        #ifdef EDITOR_VISUALIZATION
            o.VizUV         = i.vizUV;
            o.LightCoord    = i.lightCoord;
        #endif

        return UnityMetaFragment(o);
    }

#endif
