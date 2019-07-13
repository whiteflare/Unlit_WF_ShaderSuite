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

#ifndef INC_UNLIT_WF_UNTOON
#define INC_UNLIT_WF_UNTOON

    /*
     * authors:
     *      ver:2019/07/06 whiteflare,
     */

    #include "WF_Common.cginc"

    #define WF_SAMPLE_TEX2D_LOD(tex, coord, lod)                        tex.SampleLevel(sampler##tex,coord, lod)
    #define WF_SAMPLE_TEX2D_SAMPLER_LOD(tex, samplertex, coord, lod)    tex.SampleLevel(sampler##samplertex, coord, lod)

#if 1
    // サンプラー節約のための差し替えマクロ
    // 節約にはなるけど最適化などで _MainTex のサンプリングが消えると途端に破綻する諸刃の剣
    #define DECL_MAIN_TEX2D(name)           UNITY_DECLARE_TEX2D(name)
    #define DECL_SUB_TEX2D(name)            UNITY_DECLARE_TEX2D_NOSAMPLER(name)
    #define PICK_MAIN_TEX2D(tex, uv)        UNITY_SAMPLE_TEX2D(tex, uv)
    #define PICK_SUB_TEX2D(tex, name, uv)   UNITY_SAMPLE_TEX2D_SAMPLER(tex, name, uv)
#else
    // 通常版
    #define DECL_MAIN_TEX2D(name)           sampler2D name
    #define DECL_SUB_TEX2D(name)            sampler2D name
    #define PICK_MAIN_TEX2D(tex, uv)        tex2D(tex, uv)
    #define PICK_SUB_TEX2D(tex, name, uv)   tex2D(tex, uv)
#endif

    #define SAMPLE_MASK_VALUE(tex, uv, inv)         saturate( TGL_OFF(inv) ? PICK_SUB_TEX2D(tex, _MainTex, uv).rgb : 1 - PICK_SUB_TEX2D(tex, _MainTex, uv).rgb )
    #define SAMPLE_MASK_VALUE_LOD(tex, uv, inv)     saturate( TGL_OFF(inv) ? tex2Dlod(tex, float4(uv.x, uv.y, 0, 0)).rgb : 1 - tex2Dlod(tex, float4(uv.x, uv.y, 0, 0)).rgb )
    #define NZF                                     0.00390625
    #define NON_ZERO_FLOAT(v)                       max(v, NZF)
    #define NON_ZERO_VEC3(v)                        max(v, float3(NZF, NZF, NZF))

    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        #define _LMAP_ENABLE
    #endif

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        #ifdef _LMAP_ENABLE
            float2 uv_lmap      : TEXCOORD1;
        #endif
        float3 normal           : NORMAL;
        #ifdef _NM_ENABLE
            float4 tangent      : TANGENT;
        #endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float2 uv               : TEXCOORD0;
        float4 ls_vertex        : TEXCOORD1;
        float4 ls_light_dir     : TEXCOORD2;
        float3 light_color      : COLOR0;
        #ifdef _TS_ENABLE
            float shadow_power  : COLOR1;
        #endif
        float3 normal           : TEXCOORD3;
        #ifdef _NM_ENABLE
            float3 tangent      : TEXCOORD4;
            float3 bitangent    : TEXCOORD5;
            float2 uv_dtl       : TEXCOORD6;
        #endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
        // SV_POSITION は vert の out パラメタで設定するのでv2fには含めない
    };

    DECL_MAIN_TEX2D(_MainTex);
    float4          _MainTex_ST;
    float4          _Color;
    float           _AL_CutOff;
    float           _GL_BrendPower;

    ////////////////////////////
    // Normal Map
    ////////////////////////////

    #ifdef _NM_ENABLE
        float       _NM_Enable;
        // 1st NormalMap
        DECL_SUB_TEX2D(_BumpMap);
        float       _BumpScale;
        float       _NM_Power;
        // 2nd NormalMap
        float       _NM_2ndType;
        DECL_MAIN_TEX2D(_DetailNormalMap);
        float4      _DetailNormalMap_ST;
        float       _DetailNormalMapScale;
        DECL_SUB_TEX2D(_NM_2ndMaskTex);
        float       _NM_InvMaskVal;

        inline void affectBumpNormal(v2f i, out float3 ls_bump_normal, inout float4 color) {
            float3 ls_normal = i.normal;
            if (TGL_ON(_NM_Enable)) {
                // 1st NormalMap
                float3 normalTangent = UnpackScaleNormal( PICK_SUB_TEX2D(_BumpMap, _MainTex, i.uv), _BumpScale );

                // 2nd NormalMap
                if (_NM_2ndType == 1) { // BLEND
                    float dtlPower = SAMPLE_MASK_VALUE(_NM_2ndMaskTex, i.uv, _NM_InvMaskVal);
                    float3 dtlNormalTangent = UnpackScaleNormal( PICK_MAIN_TEX2D(_DetailNormalMap, i.uv_dtl), _DetailNormalMapScale);
                    normalTangent = lerp(normalTangent, BlendNormals(normalTangent, dtlNormalTangent), dtlPower);
                }
                else if (_NM_2ndType == 2) { // SWITCH
                    float dtlPower = SAMPLE_MASK_VALUE(_NM_2ndMaskTex, i.uv, _NM_InvMaskVal);
                    float3 dtlNormalTangent = UnpackScaleNormal( PICK_MAIN_TEX2D(_DetailNormalMap, i.uv_dtl), _DetailNormalMapScale);
                    normalTangent = lerp(normalTangent, dtlNormalTangent, dtlPower);
                }

                // 法線計算
                float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal); // vertex周辺のlocal法線空間
                ls_bump_normal = mul( normalTangent, tangentTransform);
                // NormalMap は陰影として描画する(ls_bump_normal自体は後でも使う)
                // 影側を暗くしすぎないために、ls_normal と ls_bump_normal の差を加算することで明暗を付ける
                color.rgb += (dot(ls_bump_normal, i.ls_light_dir.xyz) - dot(ls_normal, i.ls_light_dir.xyz)) * _NM_Power;
            }
            else {
                ls_bump_normal = ls_normal;
            }
        }
    #else
        #define affectBumpNormal(i, ls_bump_normal, color)  ls_bump_normal = i.normal
    #endif

    ////////////////////////////
    // Metallic
    ////////////////////////////

    #ifdef _MT_ENABLE
        float       _MT_Enable;
        float       _MT_Metallic;
        float       _MT_Smoothness;
        float       _MT_Specular;
        float       _MT_BlendNormal;
        float       _MT_BlendType;
        float       _MT_Monochrome;
        DECL_SUB_TEX2D(_MT_MaskTex);
        float       _MT_InvMaskVal;
        int         _MT_CubemapType;
        samplerCUBE _MT_Cubemap;
        float4      _MT_Cubemap_HDR;

        inline float3 calcNdotH(float3 normal, float3 view, float3 light) {
            float3 h = (view + light) / length(view + light);
            return max(0, dot(normal, h));
        }

        inline float3 pickSpecular(float4 ls_vertex, float3 ls_normal, float smoothness) {
            float3 specular = float3(0, 0, 0);
            float ppp = pow(2, smoothness * 8 + 2);

            float4 ws_vertex = mul(unity_ObjectToWorld, ls_vertex);
            float3 ws_normal = UnityObjectToWorldNormal(ls_normal);
            float3 ws_camera_dir = normalize(worldSpaceCameraPos() - ws_vertex.xyz);

            // メインライト
            {
                float3 ws_light_dir = _WorldSpaceLightPos0.xyz;
                float NdotH = calcNdotH(ws_normal, ws_camera_dir, ws_light_dir);
                specular += saturate( _LightColor0.rgb * pow(NdotH, ppp) );
            }
            // ポイント4ライト
            {
                float4 toLightX = unity_4LightPosX0 - ws_vertex.x;
                float4 toLightY = unity_4LightPosY0 - ws_vertex.y;
                float4 toLightZ = unity_4LightPosZ0 - ws_vertex.z;

                float4 lengthSq = toLightX * toLightX + toLightY * toLightY + toLightZ * toLightZ;
                float4 corr = rsqrt( max(lengthSq, 0.000001) );

                float4 NdotH;
                NdotH.x = calcNdotH(ws_normal, ws_camera_dir, float3(toLightX.x, toLightY.x, toLightZ.x));
                NdotH.y = calcNdotH(ws_normal, ws_camera_dir, float3(toLightX.y, toLightY.y, toLightZ.y));
                NdotH.z = calcNdotH(ws_normal, ws_camera_dir, float3(toLightX.z, toLightY.z, toLightZ.z));
                NdotH.w = calcNdotH(ws_normal, ws_camera_dir, float3(toLightX.w, toLightY.w, toLightZ.w));
                float4 atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0) * corr * pow(NdotH, ppp);

                specular += saturate( unity_LightColor[0].rgb * atten.x );
                specular += saturate( unity_LightColor[1].rgb * atten.y );
                specular += saturate( unity_LightColor[2].rgb * atten.z );
                specular += saturate( unity_LightColor[3].rgb * atten.w );
            }
            return specular;
        }

        inline void affectMetallic(v2f i, float3 ls_normal, float3 ls_bump_normal, inout float4 color) {
            if (TGL_ON(_MT_Enable)) {
                float3 ls_metal_normal = lerp(ls_normal, ls_bump_normal, _MT_BlendNormal);
                float power = _MT_Metallic * SAMPLE_MASK_VALUE(_MT_MaskTex, i.uv, _MT_InvMaskVal);
                if (0.01 < power) {
                    // リフレクション
                    float metal_lod = (1 - _MT_Smoothness) * 10;
                    float3 reflection;
                    if (_MT_CubemapType == 1) { // ADDITION
                        reflection
                            = pickReflectionProbe(i.ls_vertex, ls_metal_normal, metal_lod)
                            + pickReflectionCubemap(_MT_Cubemap, _MT_Cubemap_HDR, i.ls_vertex, ls_metal_normal, metal_lod);
                    }
                    else if (_MT_CubemapType == 2) {    // ONLY_SECOND_MAP
                        reflection
                            = pickReflectionCubemap(_MT_Cubemap, _MT_Cubemap_HDR, i.ls_vertex, ls_metal_normal, metal_lod);
                    }
                    else {  // OFF
                        reflection
                            = pickReflectionProbe(i.ls_vertex, ls_metal_normal, metal_lod);
                    }
                    if (TGL_ON(_MT_Monochrome)) {
                        reflection = calcBrightness(reflection);
                    }
                    // スペキュラ
                    float3 specular = float3(0, 0, 0);
                    if (TGL_ON(_MT_Specular)) {
                        specular = pickSpecular(i.ls_vertex, ls_metal_normal, _MT_Smoothness);
                    }
                    color.rgb = lerp(color.rgb,
                        lerp(color.rgb * reflection.rgb, color.rgb + reflection.rgb, _MT_BlendType) + specular.rgb,
                        power);
                }
            }
        }
    #else
        #define affectMetallic(i, ls_normal, ls_bump_normal, color)
    #endif

    ////////////////////////////
    // Light Matcap
    ////////////////////////////

    #ifdef _HL_ENABLE
        float       _HL_Enable;
        int         _HL_CapType;
        sampler2D   _HL_MatcapTex;  // MainTexと大きく構造が異なるので独自のサンプラーを使う
        float3      _HL_MatcapColor;
        float       _HL_Power;
        float       _HL_BlendNormal;
        DECL_SUB_TEX2D(_HL_MaskTex);
        float       _HL_InvMaskVal;

        #define _HL_Range 1

        inline void affectMatcapColor(float2 matcapVector, float2 mask_uv, inout float4 color) {
            if (TGL_ON(_HL_Enable)) {
                // matcap サンプリング
                float2 matcap_uv = matcapVector.xy * 0.5 * _HL_Range + 0.5;
                float3 matcap_color = tex2D(_HL_MatcapTex, saturate(matcap_uv)).rgb;
                // maskcolor 決定
                float3 matcap_mask = SAMPLE_MASK_VALUE(_HL_MaskTex, mask_uv, _HL_InvMaskVal).rgb;
                float3 lightcap_power = saturate(matcap_mask * _HL_MatcapColor * 2);    // _HL_MatcapColorは灰色を基準とするので2倍する
                float3 shadecap_power = (1 - lightcap_power) * MAX3(matcap_mask.r, matcap_mask.g, matcap_mask.b);
                // 合成
                float3 median_color = _HL_CapType == 0 ? MEDIAN_GRAY : float3(0, 0, 0);
                float3 lightcap_color = saturate( (matcap_color - median_color) * lightcap_power );
                float3 shadecap_color = saturate( (median_color - matcap_color) * shadecap_power );
                color.rgb += (lightcap_color - shadecap_color) * _HL_Power;
            }
        }
    #else
        #define affectMatcapColor(matcapVector, mask_uv, color)
    #endif

    ////////////////////////////
    // ToonShade
    ////////////////////////////

    #ifdef _TS_ENABLE
        float       _TS_Enable;
        float4      _TS_BaseColor;
        DECL_SUB_TEX2D(_TS_BaseTex);
        float4      _TS_1stColor;
        DECL_SUB_TEX2D(_TS_1stTex);
        float4      _TS_2ndColor;
        DECL_SUB_TEX2D(_TS_2ndTex);
        float       _TS_Power;
        float       _TS_1stBorder;
        float       _TS_2ndBorder;
        float       _TS_Feather;
        float       _TS_BlendNormal;
        DECL_SUB_TEX2D(_TS_MaskTex);
        float       _TS_InvMaskVal;

        inline void calcToonShadeContrast(float4 ls_vertex, float4 ls_light_dir, float3 ambientColor, out float shadow_power) {
            if (TGL_ON(_TS_Enable)) {
                float3 lightColorMain = calcLocalSpaceLightColor(ls_vertex, ls_light_dir.w);
                float3 lightColorSub4 = OmniDirectional_Shade4PointLights(
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        0 < ls_light_dir.w ? unity_LightColor[0].rgb : float3(0, 0, 0),
                        unity_LightColor[1].rgb,
                        unity_LightColor[2].rgb,
                        unity_LightColor[3].rgb,
                        unity_4LightAtten0,
                        mul(unity_ObjectToWorld, ls_vertex)
                    );
                float main = saturate(calcBrightness( lightColorMain ));
                float sub4 = saturate(calcBrightness( lightColorSub4 ));
                float ambient = saturate(calcBrightness( ambientColor ));
                shadow_power = saturate( abs(main - sub4) / max(main + sub4, 0.0001) ) * 0.5 + 0.5;
                shadow_power = min( shadow_power, 1 - smoothstep(0.8, 1, abs(ls_light_dir.y)) * 0.5 );
                shadow_power = min( shadow_power, 1 - saturate(ambient) * 0.5 );
            } else {
                shadow_power = 0;
            }
        }

        inline void affectToonShade(v2f i, float3 ls_normal, float3 ls_bump_normal, float angle_light_camera, inout float4 color) {
            if (TGL_ON(_TS_Enable)) {
                float boostlight = 0.5 + 0.25 * SAMPLE_MASK_VALUE(_TS_MaskTex, i.uv, _TS_InvMaskVal).r;
                float brightness = dot(lerp(ls_normal, ls_bump_normal, _TS_BlendNormal), i.ls_light_dir.xyz) * (1 - boostlight) + boostlight;
                // ビュー相対位置シフト
                brightness *= smoothstep(-1.01, -1.0 + (_TS_1stBorder + _TS_2ndBorder) / 2, angle_light_camera);
                // 影色計算
                float3 base_color = NON_ZERO_VEC3( _TS_BaseColor.rgb * PICK_SUB_TEX2D(_TS_BaseTex, _MainTex, i.uv).rgb );
                float3 shadow_color_1st = _TS_1stColor.rgb * PICK_SUB_TEX2D(_TS_1stTex, _MainTex, i.uv).rgb / base_color.rgb;
                float3 shadow_color_2nd = _TS_2ndColor.rgb * PICK_SUB_TEX2D(_TS_2ndTex, _MainTex, i.uv).rgb / base_color.rgb;
                shadow_color_1st = lerp(float3(1, 1, 1), shadow_color_1st, i.shadow_power * _TS_Power * _TS_1stColor.a);
                shadow_color_2nd = lerp(float3(1, 1, 1), shadow_color_2nd, i.shadow_power * _TS_Power * _TS_2ndColor.a);
                // 色計算
                color.rgb *= saturate(lerp(
                    lerp(shadow_color_2nd, shadow_color_1st, smoothstep(_TS_2ndBorder - max(_TS_Feather, 0.001), _TS_2ndBorder, brightness) ),
                    float3(1, 1, 1),
                    smoothstep(_TS_1stBorder, _TS_1stBorder + max(_TS_Feather, 0.001), brightness)));
            }
        }
    #else
        #define calcToonShadeContrast(ls_vertex, ls_light_dir, ambientColor, shadow_power)
        #define affectToonShade(i, ls_normal, ls_bump_normal, angle_light_camera, color)
    #endif

    ////////////////////////////
    // Rim Light
    ////////////////////////////

    #ifdef _TR_ENABLE
        float       _TR_Enable;
        float4      _TR_Color;
        float       _TR_PowerTop;
        float       _TR_PowerSide;
        float       _TR_PowerBottom;
        DECL_SUB_TEX2D(_TR_MaskTex);
        float       _TR_InvMaskVal;

        inline void affectRimLight(v2f i, float3 vs_normal, float angle_light_camera, inout float4 color) {
            if (TGL_ON(_TR_Enable)) {
                // vs_normalからリムライト範囲を計算
                float2 rim_uv = vs_normal.xy;
                rim_uv.x *= _TR_PowerSide + 1;
                rim_uv.y *= (_TR_PowerTop + _TR_PowerBottom) / 2 + 1;
                rim_uv.y += (_TR_PowerTop - _TR_PowerBottom) / 2;
                // 順光の場合はリムライトを暗くする
                float3 rimPower = saturate(1 - angle_light_camera) * _TR_Color.a * SAMPLE_MASK_VALUE(_TR_MaskTex, i.uv, _TR_InvMaskVal).rgb;
                // 色計算
                color.rgb = lerp(color.rgb, color.rgb + (_TR_Color.rgb - MEDIAN_GRAY) * rimPower,
                    smoothstep(1, 1.05, length(rim_uv)) );
            }
        }
    #else
        #define affectRimLight(i, vs_normal, angle_light_camera, color)
    #endif

    ////////////////////////////
    // Outline
    ////////////////////////////

    #ifdef _TL_ENABLE
        float       _TL_Enable;
        float4      _TL_LineColor;
        float       _TL_LineWidth;
        sampler2D   _TL_MaskTex;    // vert内で取得するので独自のサンプラーを使う
        float       _TL_InvMaskVal;
        float       _TL_Z_Shift;

        inline void affectOutline(inout float4 color) {
            if (TGL_ON(_TL_Enable)) {
                // アウトライン色をベースと合成
                color.rgb = lerp(color.rgb, _TL_LineColor.rgb, _TL_LineColor.a);
            }
        }
    #else
        #define affectOutline(color)
    #endif

    ////////////////////////////
    // common function
    ////////////////////////////

    inline float3 calcLightColorVertex(float4 ls_vertex, float3 ambientColor) {
        float3 lightColorMain = _LightColor0.rgb;
        float3 lightColorSub4 = OmniDirectional_Shade4PointLights(
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb,
                unity_LightColor[1].rgb,
                unity_LightColor[2].rgb,
                unity_LightColor[3].rgb,
                unity_4LightAtten0,
                mul(unity_ObjectToWorld, ls_vertex)
            );
        float3 color = lightColorMain + lightColorSub4 + ambientColor;
        float power = calcBrightness(color);
        float3 light_color = (saturate( NON_ZERO_VEC3(color) / NON_ZERO_FLOAT(power) ) - 1) * _GL_BrendPower + 1;
        light_color *= saturate( power * 2 + (100 - _GL_Level) * 0.01 );
        return light_color;
    }

    inline float3 pickLightmapLod(float2 uv_lmap, float3 ls_normal) {
        float3 color = float3(0, 0, 0);
        float3 ws_normal = UnityObjectToWorldNormal(ls_normal);
        #ifdef LIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            float4 lmap_tex = WF_SAMPLE_TEX2D_LOD(unity_Lightmap, uv, 0);
            float3 lmap_color = DecodeLightmap(lmap_tex);
            #ifdef DIRLIGHTMAP_COMBINED
                fixed4 dir_tex = WF_SAMPLE_TEX2D_SAMPLER_LOD(unity_LightmapInd, unity_Lightmap, uv, 0);
                color += DecodeDirectionalLightmap(lmap_color, dir_tex, ws_normal);
            #else
                color += lmap_color;
            #endif
        }
        #endif
        #ifdef DYNAMICLIGHTMAP_ON
        {
            float2 uv = uv_lmap.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
            float4 lmap_tex = WF_SAMPLE_TEX2D_LOD(unity_DynamicLightmap, uv, 0);
            float3 lmap_color = DecodeRealtimeLightmap (lmap_tex);
            #ifdef DIRLIGHTMAP_COMBINED
                half4 dir_tex = WF_SAMPLE_TEX2D_SAMPLER_LOD(unity_DynamicDirectionality, unity_DynamicLightmap, uv, 0);
                color += DecodeDirectionalLightmap(lmap_color, dir_tex, ws_normal);
            #else
                color += lmap_color;
            #endif
        }
        #endif
        return color;
    }

    inline float calcAngleLightCamera(v2f i) {
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float3 ws_light_dir = UnityObjectToWorldDir(i.ls_light_dir); // ワールド座標系にてangle_light_cameraを計算する(モデル回転には依存しない)
        float3 ws_camera_dir = worldSpaceViewDir( float4(0, 0, 0, i.ls_vertex.w) );
        float angle_light_camera = dot( SafeNormalizeVec2(ws_light_dir.xz), SafeNormalizeVec2(ws_camera_dir.xz) )
            * (1 - smoothstep(0.9, 1, ws_light_dir.y)) * (1 - smoothstep(0.9, 1, ws_camera_dir.y));
        if (isInMirror()) {
            angle_light_camera = 0; // 鏡の中のときは、視差問題が生じないように強制的に 0 にする
        }
        return angle_light_camera;
    }

    #ifdef _LMAP_ENABLE
        #define WF_GET_AMBIENT  pickLightmapLod(v.uv_lmap, o.normal)
    #else
        #define WF_GET_AMBIENT  OmniDirectional_ShadeSH9()
    #endif

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f vert(in appdata v, out float4 vertex : SV_POSITION) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        vertex = UnityObjectToClipPos(v.vertex);

        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.ls_vertex = v.vertex;
        o.ls_light_dir = calcLocalSpaceLightDir( float4(0, 0, 0, v.vertex.w) );

        o.normal = normalize(v.normal.xyz);
        #ifdef _NM_ENABLE
            o.tangent = normalize(v.tangent.xyz);
            o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
            o.uv_dtl = TRANSFORM_TEX(v.uv, _DetailNormalMap);
        #endif

        // 環境光取得
        float3 ambientColor = WF_GET_AMBIENT;
        // 影コントラスト
        calcToonShadeContrast(o.ls_vertex, o.ls_light_dir, ambientColor, o.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(o.ls_vertex, ambientColor);

        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_TRANSFER_FOG(o, vertex);
        return o;
    }

    float4 frag(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        // メイン
        float4 color = PICK_MAIN_TEX2D(_MainTex, i.uv) * _Color;

        // 色変換
        affectColorChange(color);
        // BumpMap
        float3 ls_normal = i.normal;
        float3 ls_bump_normal;
        affectBumpNormal(i, ls_bump_normal, color);

        // ビュー空間法線
        float3 vs_normal = calcMatcapVector(i.ls_vertex, ls_normal);
        float3 vs_bump_normal = calcMatcapVector(i.ls_vertex, ls_bump_normal);
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i);

        // メタリック
        affectMetallic(i, ls_normal, ls_bump_normal, color);
        // Highlight
        affectMatcapColor(lerp(vs_normal, vs_bump_normal, _HL_BlendNormal), i.uv, color);
        // 階調影
        affectToonShade(i, ls_normal, ls_bump_normal, angle_light_camera, color);
        // リムライト
        affectRimLight(i, vs_normal, angle_light_camera, color);
        // Outline
        affectOutline(color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;

        // Alpha
        affectAlphaWithFresnel(i.uv, ls_normal, localSpaceViewDir(i.ls_vertex), color);
        // EmissiveScroll
        affectEmissiveScroll(i.ls_vertex, i.uv, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    ////////////////////////////
    // カットアウト用 fragment shader
    ////////////////////////////

    float4 frag_cutout_upper(v2f i) : SV_Target {
        float4 color = frag(i);
        clip(color.a - _AL_CutOff);
        return color;
    }

    float4 frag_cutout_lower(v2f i) : SV_Target {
        float4 color = frag(i);
        clip(_AL_CutOff - color.a);
        return color;
    }

    ////////////////////////////
    // アウトライン用 vertex&fragment shader
    ////////////////////////////

    v2f vert_outline(appdata v, out float4 vertex : SV_POSITION) {
        // 通常の vert を使う
        v2f o = vert(v, vertex);

        // SV_POSITION を上書き
        #ifdef _TL_ENABLE
        if (TGL_ON(_TL_Enable)) {
            // マスクテクスチャ参照
            float mask = SAMPLE_MASK_VALUE_LOD(_TL_MaskTex, o.uv, _TL_InvMaskVal).r;
            // 外側にシフトする
            o.ls_vertex.xyz += normalize( v.normal ).xyz * (_TL_LineWidth * 0.01) * mask;
            // カメラ方向の z シフト量を計算
            // ここは view space の計算が必要なので ObjSpaceViewDir を直に使用する
            float3 vecZShift = normalize( ObjSpaceViewDir(o.ls_vertex) ) * (_TL_LineWidth + _TL_Z_Shift) * 0.01;
            if (unity_OrthoParams.w < 0.5) {
                // カメラが perspective のときは単にカメラ方向の逆にシフトする
                o.ls_vertex.xyz -= vecZShift;
                vertex = UnityObjectToClipPos( o.ls_vertex );
            } else {
                // カメラが orthographic のときはシフト後の z のみ採用する
                vertex = UnityObjectToClipPos( o.ls_vertex );
                o.ls_vertex.xyz -= vecZShift;
                vertex.z = UnityObjectToClipPos( o.ls_vertex ).z;
            }
        } else {
            vertex = UnityObjectToClipPos( float3(0, 0, 0) );
        }
        #endif

        return o;
    }

    ////////////////////////////
    // アウトラインキャンセラ用 vertex&fragment shader
    ////////////////////////////

    sampler2D _UnToonTransparentOutlineCanceller;

    struct v2f_canceller {
        float4      vertex  : SV_POSITION;
        float4      uv_grab : TEXCOORD0;
    };

    v2f_canceller vert_outline_canceller(appdata v) {
        v2f_canceller o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv_grab = o.vertex;
        o.uv_grab.xy = ComputeGrabScreenPos(o.vertex);
        return o;
    }

    float4 frag_outline_canceller(v2f_canceller i) : SV_Target {
        return tex2Dproj(_UnToonTransparentOutlineCanceller, UNITY_PROJ_COORD(i.uv_grab));
    }

    ////////////////////////////
    // EmissiveScroll専用パス用 vertex&fragment shader
    ////////////////////////////

    float _ES_Z_Shift;

    v2f vert_emissiveScroll(appdata v, out float4 vertex : SV_POSITION) {
        // 通常の vert を使う
        v2f o = vert(v, vertex);

        // SV_POSITION を上書き

        #ifdef _ES_ENABLE
        if (TGL_ON(_ES_Enable)) {

            // カメラ方向の z シフト量を計算
            float3 ls_camera_dir = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz - o.ls_vertex.xyz;
            // ここは view space の計算が必要なので ObjSpaceViewDir を直に使用する
            float3 vecZShift = normalize( ls_camera_dir ) * min( _ES_Z_Shift, length( ls_camera_dir ) * 0.5 );  // 指定の量だけ近づける。ただしカメラとの距離の 1/2 を超えない
            if (unity_OrthoParams.w < 0.5) {
                // カメラが perspective のときは単にカメラ方向にシフトする
                o.ls_vertex.xyz += vecZShift;
                vertex = UnityObjectToClipPos( o.ls_vertex );
            } else {
                // カメラが orthographic のときはシフト後の z のみ採用する
                vertex = UnityObjectToClipPos( o.ls_vertex );
                o.ls_vertex.xyz += vecZShift;
                vertex.z = UnityObjectToClipPos( o.ls_vertex ).z;
            }

        } else {
            vertex = UnityObjectToClipPos( float3(0, 0, 0) );
        }
        #else
            vertex = UnityObjectToClipPos( float3(0, 0, 0) );
        #endif

        return o;
    }

    float4 frag_emissiveScroll(v2f i) : SV_Target {
        float4 color = float4(0, 0, 0, 0);

        #ifdef _ES_ENABLE
        if (TGL_ON(_ES_Enable)) {

            // EmissiveScroll
            affectEmissiveScroll(i.ls_vertex, i.uv, color);

            // Alpha は 0-1 にクランプ
            color.a = saturate(color.a);
            if (color.a < 0.1) {
                discard;
            }

        } else {
            // 無効のときはクリッピングする
            discard;
        }
        #else
            // 無効のときはクリッピングする
            discard;
        #endif

        return color;
    }

#endif
