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

#ifndef INC_UNLIT_WF_GRASS
#define INC_UNLIT_WF_GRASS

    #include "WF_INPUT_Grass.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4 vertex           : POSITION;
        float4 vertex_color     : COLOR0;
        float4 normal           : NORMAL;
        float2 uv               : TEXCOORD0;
        float2 uv2              : TEXCOORD1;
        float2 uv3              : TEXCOORD2;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vs_vertex        : SV_POSITION;
        float  height           : COLOR0;
        float  light_color      : COLOR1;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR2;
#endif
        float2 uv               : TEXCOORD0;
#ifdef _V2F_HAS_UV_LMAP
        float2 uv_lmap          : TEXCOORD1;
#endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #ifdef _VC_ENABLE
        void affectVertexColor(float4 vertex_color, inout float4 color) {
            color.rgb *= lerp(ONE_VEC4, vertex_color.rgb, _UseVertexColor);
        }
    #else
        #define affectVertexColor(vertex_color, color)
    #endif

    ////////////////////////////
    // Anti Glare & Light Configuration
    ////////////////////////////

    float3 calcLightColorVertex(float3 ws_vertex, float3 ambientColor) {
        float3 lightColorMain = sampleMainLightColor();
        float3 lightColorSub4 = sampleAdditionalLightColor(ws_vertex);

        float3 color = NON_ZERO_VEC3(lightColorMain + lightColorSub4 + ambientColor);   // 合成
        float power = MAX_RGB(color);                       // 明度
        color = lerp( power.xxx, color, _GL_BlendPower);    // 色の混合
        color /= power;                                     // 正規化(colorはゼロではないのでpowerが0除算になることはない)
        color *= lerp(saturate(power / NON_ZERO_FLOAT(_GL_LevelMax)), 1, _GL_LevelMin);  // 明度のsaturateと書き戻し
        return color;
    }

    ////////////////////////////
    // Grass
    ////////////////////////////

    float calcGrassHeightVertex(appdata v, float3 ws_vertex) {
        float result = 0;

        // ベース高の算出
#if defined(_GRS_MASKTEX_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
        if (_GRS_HeightType == 2) {    // MASK_TEX
            float2 uv = 
                _GRS_HeightUVType == 1 ? v.uv2 :
                _GRS_HeightUVType == 2 ? v.uv3 :
                v.uv;
            uv = TRANSFORM_TEX(uv, _GRS_HeightMaskTex);
            half4 color = SAMPLE_MASK_VALUE_LOD(_GRS_HeightMaskTex, uv, _GRS_InvMaskVal);
            float3 height = color.rgb * _GRS_ColorFactor.rgb;
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
            float2 height = uv * _GRS_UVFactor.xy + _GRS_UVFactor.zw;
            result = height.x + height.y;
        }
        else if (_GRS_HeightType == 3) {    // VERTEX_COLOR
            half4 color = v.vertex_color;
            float3 height = color.rgb * _GRS_ColorFactor.rgb;
            result = MAX_RGB(height);
        }
        else { // WORLD_Y
            result = (ws_vertex.y - _GRS_WorldYBase) * _GRS_WorldYScale;
        }
#endif

        return max(0, result);
    }

    ////////////////////////////
    // Grass Wave
    ////////////////////////////

    #ifdef _GRW_ENABLE

        void calcGrassWaveVertex(float height, inout float3 ws_vertex) {
FEATURE_TGL_ON_BEGIN(_GRW_Enable)
            // ウェーブ生成
            float3 phase = ws_vertex.xyz * _GRW_WindVector.xyz;
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
    // Ambient Occlusion
    ////////////////////////////

    #ifdef _AO_ENABLE

        void affectOcclusion(v2f i, float2 uv_main, inout float4 color) {
FEATURE_TGL_ON_BEGIN(_AO_Enable)
            float3 occlusion = ONE_VEC3;
            #ifdef _LMAP_ENABLE
            if (TGL_ON(_AO_UseLightMap)) {
                occlusion *= pickLightmap(i.uv_lmap);
            }
            #endif
            occlusion = lerp(AVE_RGB(occlusion).xxx, occlusion, _GL_BlendPower); // 色の混合
            occlusion = (occlusion - 1) * _AO_Contrast + 1 + _AO_Brightness;
            color.rgb *= max(ZERO_VEC3, occlusion.rgb);
FEATURE_TGL_END
        }
    #else
        #define affectOcclusion(i, uv_main, color)
    #endif

    float3 calcAmbientColorVertex(float2 uv_lmap) {
        // ライトマップもしくは環境光を取得
        #ifdef _LMAP_ENABLE
            #if defined(_AO_ENABLE)
                // ライトマップが使えてAOが有効の場合は、AO側で色を合成するので固定値を返す
#ifdef _WF_LEGACY_FEATURE_SWITCH
                return TGL_ON(_AO_Enable) && TGL_ON(_AO_UseLightMap) ? ONE_VEC3 : pickLightmapLod(uv_lmap);
#else
                return TGL_ON(_AO_UseLightMap) ? ONE_VEC3 : pickLightmapLod(uv_lmap);
#endif
            #else
                return pickLightmapLod(uv_lmap);
            #endif
        #else
            return sampleSHLightColor();
        #endif
    }

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
        float3 ambientColor = calcAmbientColorVertex(v.uv2);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(ws_vertex, ambientColor);

        o.vs_vertex = UnityWorldToClipPos(ws_vertex);
        o.uv = v.uv;
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif
#ifdef _V2F_HAS_UV_LMAP
        o.uv_lmap = v.uv2;
#endif

        UNITY_TRANSFER_FOG(o, o.vs_vertex);

        return o;
    }

    half4 frag(v2f i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        half2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        half4 color = PICK_MAIN_TEX2D(_MainTex, uv_main);
        affectVertexColor(i.vertex_color, color);

        color.rgb *= lerp(_GRS_ColorBottom.rgb, _GRS_ColorTop.rgb, saturate(i.height));

        color.rgb *= i.light_color;
        // Ambient Occlusion
        affectOcclusion(i, uv_main, color);

        clip(color.a - _Cutoff);

        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    ////////////////////////////
    // ShadowCaster
    ////////////////////////////

    struct v2f_shadow {
        V2F_SHADOW_CASTER;  // TEXCOORD0
        float2 uv : TEXCOORD1;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR1;
#endif
        UNITY_VERTEX_OUTPUT_STEREO
    };

    v2f_shadow vert_shadow(appdata v) {
        v2f_shadow o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_shadow, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        float3 ws_vertex = UnityObjectToWorldPos(v.vertex);
        float height;

        // ベース高の算出
        height = calcGrassHeightVertex(v, ws_vertex);
        // ウェーブ生成
        calcGrassWaveVertex(height, ws_vertex);
        // 書き戻し
        v.vertex.xyz = UnityWorldToObjectPos(ws_vertex);

        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

        o.uv = v.uv;
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif

        return o;
    }

    float4 frag_shadow_caster(v2f_shadow i) {
        SHADOW_CASTER_FRAGMENT(i)
    }

    float4 frag_shadow(v2f_shadow i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
        UNITY_APPLY_DITHER_CROSSFADE(i.pos);

        half2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        half4 color = PICK_MAIN_TEX2D(_MainTex, uv_main);
        affectVertexColor(i.vertex_color, color);

        clip(color.a - _Cutoff);

        return frag_shadow_caster(i);
    }

    ////////////////////////////
    // Meta
    ////////////////////////////


    struct v2f_meta {
        float4 pos              : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float  height           : COLOR0;
#ifdef _V2F_HAS_VERTEXCOLOR
        float4 vertex_color     : COLOR1;
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

    float4 frag_meta(v2f_meta i) : SV_Target {
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
