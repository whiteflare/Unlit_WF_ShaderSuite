/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2026 whiteflare.
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

#ifndef INC_UNLIT_WF_GRASS
#define INC_UNLIT_WF_GRASS

    #include "WF_INPUT_Grass.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4  vertex              : POSITION;
        half4   vertex_color        : COLOR0;
        float2  uv                  : TEXCOORD0;
        float2  uv2                 : TEXCOORD1;
        float2  uv3                 : TEXCOORD2;
        float4  normal              : NORMAL; // ShadowCasterから使用される
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4  vs_vertex           : SV_POSITION;
        half    height              : COLOR0;
        half3   light_color         : COLOR1;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color        : COLOR2;
#endif
        float2  uv                  : TEXCOORD0;
#ifdef _V2F_HAS_UV_LMAP
        float2  uv2                 : TEXCOORD1;
#endif
#ifdef _GRS_ERSSIDE_ENABLE
        half3   ws_normal           : TEXCOORD2;
#endif
        float3  ws_vertex           : TEXCOORD3;
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f

    struct drawing {
        half4   color;
        float2  uv1;
#ifdef _V2F_HAS_UV_LMAP
        float2  uv2;
#endif
        float2  uv_main;
        float3  ws_vertex;
#ifdef _GRS_ERSSIDE_ENABLE
        half3   ws_normal;
#endif
        half3   ws_view_dir;
        half3   ws_camera_dir;
        half3   ws_light_dir;
        half3   light_color;
        half    height;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color;
#endif
    };

    drawing prepareDrawing(IN_FRAG i) {
        drawing d = (drawing) 0;

        d.color         = half4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;
        d.light_color   = i.light_color;
        d.height        = i.height;
#ifdef _V2F_HAS_UV_LMAP
        d.uv2           = i.uv2;
#endif
        d.ws_vertex     = i.ws_vertex;
#ifdef _GRS_ERSSIDE_ENABLE
        d.ws_normal     = normalize(i.ws_normal);
        d.ws_view_dir   = worldSpaceViewPointDir(d.ws_vertex);
        d.ws_camera_dir = worldSpaceCameraDir(d.ws_vertex);
#endif
#ifdef _V2F_HAS_VERTEXCOLOR
        d.vertex_color  = i.vertex_color;
#endif

        return d;
    }

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // Grass
    ////////////////////////////

    half calcGrassHeightVertex(appdata v, float3 ws_vertex) {
        half result = 0;

        // ベース高の算出
#if defined(_GRS_MASKTEX_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
        if (_GRS_HeightType == 2) {    // MASK_TEX
            float2 uv =
                _GRS_HeightUVType == 1 ? v.uv2 :
                _GRS_HeightUVType == 2 ? v.uv3 :
                v.uv;
            uv = TRANSFORM_TEX(uv, _GRS_HeightMaskTex);
            half4 color = SAMPLE_MASK_VALUE_LOD(_GRS_HeightMaskTex, uv, _GRS_InvMaskVal);
            half3 height = color.rgb * _GRS_ColorFactor.rgb;
            result = MAX_RGB(height);
        }
#endif
#if defined(_WF_LEGACY_FEATURE_SWITCH)
        else
#endif
#if !defined(_GRS_MASKTEX_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
        if (_GRS_HeightType == 1) { // UV
            float2 uv =
                _GRS_HeightUVType == 1 ? v.uv2 :
                _GRS_HeightUVType == 2 ? v.uv3 :
                v.uv;
            half2 height = uv * _GRS_UVFactor.xy + _GRS_UVFactor.zw;
            result = height.x + height.y;
        }
        else if (_GRS_HeightType == 3) {    // VERTEX_COLOR
            half4 color = v.vertex_color;
            half3 height = color.rgb * _GRS_ColorFactor.rgb;
            result = MAX_RGB(height);
        }
        else { // WORLD_Y
            result = SafeDiv(ws_vertex.y - _GRS_WorldYBase, _GRS_WorldYScale, 0.001);
        }
#endif

        return max(0, result);
    }

    ////////////////////////////
    // Grass Wave
    ////////////////////////////

    #ifdef _GRW_ENABLE

        void calcGrassWaveVertex(half height, inout float3 ws_vertex) {
FEATURE_TGL_ON_BEGIN(_GRW_Enable)
            // ウェーブ生成
            float3 phase = SafeDivVec3(ws_vertex, _GRW_WindVector, 0.01);
            float time = _Time.y * _GRW_WaveSpeed + phase.x + phase.y + phase.z;
            float value = pow(sin(frac(time) * UNITY_TWO_PI) * 0.5 + 0.5, _GRW_WaveExponent) * 2 - 1 + _GRW_WaveOffset;

            // ベース高を加味
            value *= height;

            ws_vertex.xyz += value * _GRW_WaveWidth.xyz;
FEATURE_TGL_END
        }

    #else
        #define calcGrassWaveVertex(height, ws_vertex)
    #endif

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f vert(in appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        float3 ws_vertex = UnityObjectToWorldPos(v.vertex);

        // ベース高の算出
        o.height = calcGrassHeightVertex(v, ws_vertex);
        // ウェーブ生成
        calcGrassWaveVertex(o.height, ws_vertex);

        // 環境光取得
        float3 ambientColor = calcAmbientColorVertex(ws_vertex, v.uv2);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(ws_vertex, ambientColor);

        o.vs_vertex = UnityWorldToClipPos(ws_vertex);
        o.uv = v.uv;
        o.ws_vertex = ws_vertex;
#ifdef _GRS_ERSSIDE_ENABLE
        o.ws_normal = UnityObjectToWorldNormal(v.normal);
#endif
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif
#ifdef _V2F_HAS_UV_LMAP
        o.uv2 = v.uv2;
#endif

        UNITY_TRANSFER_FOG(o, o.vs_vertex);

        return o;
    }

    half4 frag(v2f i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        drawing d = prepareDrawing(i);

        prepareMainTex(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawVertexColor(d);         // 頂点カラー

        d.color.rgb *= lerp(_GRS_ColorBottom.rgb, _GRS_ColorTop.rgb, saturate(d.height));
        // Anti-Glare とライト色ブレンドを同時に計算
        d.color.rgb *= calcLightColorFrag(d.ws_vertex, d.light_color);

        drawOcclusion(d);           // オクルージョンとライトマップ

        clip(d.color.a - _Cutoff);

#ifdef _GRS_ERSSIDE_ENABLE
        if (abs(dot(d.ws_normal, worldSpaceViewPointDir(d.ws_vertex))) < _GRS_EraseSide) {
            discard;
        }
#endif

        UNITY_APPLY_FOG(i.fogCoord, d.color);

        return d.color;
    }

    ////////////////////////////
    // ShadowCaster
    ////////////////////////////

    struct v2f_shadow {
        V2F_SHADOW_CASTER;          // TEXCOORD0
        float2 uv : TEXCOORD1;
#ifdef _GRS_ERSSIDE_ENABLE
        half3 ws_normal             : TEXCOORD2;
#endif
        float3 ws_vertex            : TEXCOORD3;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4 vertex_color          : COLOR1;
#endif
        UNITY_VERTEX_OUTPUT_STEREO
    };

    v2f_shadow vert_shadow(appdata v) {
        v2f_shadow o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_shadow, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        float3 ws_vertex = UnityObjectToWorldPos(v.vertex);
        half height;

        // ベース高の算出
        height = calcGrassHeightVertex(v, ws_vertex);
        // ウェーブ生成
        calcGrassWaveVertex(height, ws_vertex);
        // 書き戻し
        v.vertex.xyz = UnityWorldToObjectPos(ws_vertex);

        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

        o.uv = v.uv;
        o.ws_vertex = ws_vertex;
#ifdef _GRS_ERSSIDE_ENABLE
        o.ws_normal = UnityObjectToWorldNormal(v.normal);
#endif
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif

        return o;
    }

    half4 frag_shadow_caster(v2f_shadow i) {
        SHADOW_CASTER_FRAGMENT(i)
    }

    half4 frag_shadow(v2f_shadow i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
        UNITY_APPLY_DITHER_CROSSFADE(i.pos);

        half2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        half4 color = PICK_MAIN_TEX2D(_MainTex, uv_main);

#ifdef _VC_ENABLE
        color *= lerp(ONE_VEC4, i.vertex_color, _UseVertexColor);
#endif

        clip(color.a - _Cutoff);

#ifdef _GRS_ERSSIDE_ENABLE
        if (abs(dot(normalize(i.ws_normal), worldSpaceViewPointDir(i.ws_vertex))) < _GRS_EraseSide) {
            discard;
        }
#endif

        return frag_shadow_caster(i);
    }

    ////////////////////////////
    // Meta
    ////////////////////////////


    struct v2f_meta {
        float4 pos                  : SV_POSITION;
        float2 uv                   : TEXCOORD0;
        half height                 : COLOR0;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4 vertex_color          : COLOR1;
#endif
#ifdef EDITOR_VISUALIZATION
        float2 vizUV                : TEXCOORD1;
        float4 lightCoord           : TEXCOORD2;
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

        float3 ws_vertex = UnityObjectToWorldPos(v.vertex);

        // ベース高の算出
        o.height = calcGrassHeightVertex(v, ws_vertex);

        o.pos   = UnityMetaVertexPosition(v.vertex, v.uv2.xy, v.uv3.xy, unity_LightmapST, unity_DynamicLightmapST);
        o.uv    = TRANSFORM_TEX(v.uv, _MainTex);
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif

#ifdef EDITOR_VISUALIZATION
        if (unity_VisualizationMode == EDITORVIZ_TEXTURE) {
            o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv.xy, v.uv2.xy, v.uv3.xy, unity_EditorViz_Texture_ST);
        }
        else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK) {
            o.vizUV         = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            o.lightCoord    = mul(unity_EditorViz_WorldToLight, UnityObjectToWorldPos(v.vertex));
        }
#endif

        return o;
    }

    half4 frag_meta(v2f_meta i) : SV_Target {
        UnityMetaInput o;
        UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);

        float4 color    = PICK_MAIN_TEX2D(_MainTex, uv_main);
#ifdef _VC_ENABLE
        color *= lerp(ONE_VEC4, i.vertex_color, _UseVertexColor);
#endif
        color.rgb *= lerp(_GRS_ColorBottom.rgb, _GRS_ColorTop.rgb, saturate(i.height));

        // 単色化
        color.rgb = max(ZERO_VEC3, lerp(AVE_RGB(color.rgb).xxx, color.rgb, lerp(1, _LBE_IndirectChroma, _LBE_Enable)));

        o.Albedo        = color.rgb * lerp(1, _LBE_IndirectMultiplier, _LBE_Enable);
        o.SpecularColor = o.Albedo;
        o.Emission      = ZERO_VEC3;

#ifdef EDITOR_VISUALIZATION
        o.VizUV         = i.vizUV;
        o.LightCoord    = i.lightCoord;
#endif

        return UnityMetaFragment(o);
    }

#endif
