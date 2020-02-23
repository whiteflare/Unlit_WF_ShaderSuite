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

#ifndef INC_UNLIT_WF_UNTOON_FUNCTION
#define INC_UNLIT_WF_UNTOON_FUNCTION

    /*
     * authors:
     *      ver:2020/02/01 whiteflare,
     */

    ////////////////////////////
    // Alpha Transparent
    ////////////////////////////

    float           _Cutoff;

    #ifdef _AL_ENABLE
        int             _AL_Source;
        float           _AL_Power;
        sampler2D       _AL_MaskTex;
        float           _AL_Fresnel;

        #ifndef _AL_CustomValue
            #define _AL_CustomValue 1
        #endif

        inline float pickAlpha(float2 uv, float alpha) {
            if (_AL_Source == 1) {
                return tex2D(_AL_MaskTex, uv).r;
            }
            else if (_AL_Source == 2) {
                return tex2D(_AL_MaskTex, uv).a;
            }
            else {
                return alpha;
            }
        }

        inline void affectAlpha(float2 uv, inout float4 color) {
            float baseAlpha = pickAlpha(uv, color.a);

            #if defined(_AL_CUTOUT)
                if (baseAlpha < _Cutoff) {
                    discard;
                } else {
                    color.a = 1.0;
                }
            #elif defined(_AL_CUTOUT_UPPER)
                if (baseAlpha < _Cutoff) {
                    discard;
                } else {
                    baseAlpha *= _AL_Power * _AL_CustomValue;
                }
            #elif defined(_AL_CUTOUT_LOWER)
                if (baseAlpha < _Cutoff) {
                    baseAlpha *= _AL_Power * _AL_CustomValue;
                } else {
                    discard;
                }
            #else
                baseAlpha *= _AL_Power * _AL_CustomValue;
            #endif

            color.a = baseAlpha;
        }

        inline void affectAlphaWithFresnel(float2 uv, float3 ws_normal, float3 ws_viewdir, inout float4 color) {
            float baseAlpha = pickAlpha(uv, color.a);

            #if defined(_AL_CUTOUT)
                if (baseAlpha < _Cutoff) {
                    discard;
                } else {
                    color.a = 1.0;
                }
            #elif defined(_AL_CUTOUT_UPPER)
                if (baseAlpha < _Cutoff) {
                    discard;
                } else {
                    baseAlpha *= _AL_Power * _AL_CustomValue;
                }
            #elif defined(_AL_CUTOUT_LOWER)
                if (baseAlpha < _Cutoff) {
                    baseAlpha *= _AL_Power * _AL_CustomValue;
                } else {
                    discard;
                }
            #else
                baseAlpha *= _AL_Power * _AL_CustomValue;
            #endif

            #ifndef _AL_FRESNEL_ENABLE
                // ベースアルファ
                color.a = baseAlpha;
            #else
                // フレネルアルファ
                float maxValue = max( pickAlpha(uv, color.a) * _AL_Power, _AL_Fresnel ) * _AL_CustomValue;
                float fa = 1 - abs( dot( ws_normal, ws_viewdir ) );
                color.a = lerp( baseAlpha, maxValue, fa * fa * fa * fa );
            #endif
        }
    #else
        #define affectAlpha(uv, color)                                      color.a = 1.0
        #define affectAlphaWithFresnel(uv, ws_normal, ws_viewdir, color)    color.a = 1.0
    #endif

    ////////////////////////////
    // Anti Glare & Light Configuration
    ////////////////////////////

    #define LIT_MODE_AUTO               0
    #define LIT_MODE_ONLY_DIR_LIT       1
    #define LIT_MODE_ONLY_POINT_LIT     2
    #define LIT_MODE_CUSTOM_WORLDSPACE  3
    #define LIT_MODE_CUSTOM_LOCALSPACE  4

    int             _GL_Level;
    float           _GL_BlendPower;
    uint            _GL_LightMode;
    float           _GL_CustomAzimuth;
    float           _GL_CustomAltitude;
    float           _GL_DisableBackLit;

    inline uint calcAutoSelectMainLight(float3 ws_vertex) {
        float3 pointLight1Color = calcPointLight1Color(ws_vertex);

        if (calcBrightness(_LightColor0.rgb) < calcBrightness(pointLight1Color)) {
            // ディレクショナルよりポイントライトのほうが明るいならばそちらを採用
            return LIT_MODE_ONLY_POINT_LIT;

        } else if (any(_WorldSpaceLightPos0.xyz)) {
            // ディレクショナルライトが入っているならばそれを採用
            return LIT_MODE_ONLY_DIR_LIT;

        } else {
            // 手頃なライトが無いのでワールドスペースの方向決め打ち
            return LIT_MODE_CUSTOM_WORLDSPACE;
        }
    }

    inline float4 calcWorldSpaceBasePos(float4 ls_vertex) {
        // この実装は Batching で問題となる、ので問題となる実装を 1 箇所に集約
        return mul(unity_ObjectToWorld, float4(0, 0, 0, ls_vertex.w));
    }

    inline float4 calcWorldSpaceLightDir(float4 ls_vertex) {
        float3 ws_vertex = calcWorldSpaceBasePos(ls_vertex);
        uint mode = _GL_LightMode;
        if (mode == LIT_MODE_AUTO) {
            mode = calcAutoSelectMainLight(ws_vertex);
        }
        if (mode == LIT_MODE_ONLY_DIR_LIT) {
            return float4( _WorldSpaceLightPos0.xyz , +1 );
        }
        if (mode == LIT_MODE_ONLY_POINT_LIT) {
            return float4( calcPointLight1WorldDir(ws_vertex) , -1 );
        }
        if (mode == LIT_MODE_CUSTOM_WORLDSPACE) {
            return float4( calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude) , 0 );
        }
        if (mode == LIT_MODE_CUSTOM_LOCALSPACE) {
            return float4( UnityObjectToWorldDir(calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude)) , 0 );
        }
        return float4( calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude) , 0 );
    }

    inline float3 calcWorldSpaceLightColor(float3 ws_vertex, float lightType) {
        if ( TGL_ON(-lightType) ) {
            float3 pointLight1Color = calcPointLight1Color(ws_vertex);
            return pointLight1Color; // ポイントライト
        }
        return _LightColor0.rgb; // ディレクショナルライト
    }

    inline void affectAntiGlare(float glLevel, inout float4 color) {
        color.rgb = saturate(color.rgb * glLevel);
    }

    inline float3 calcLightColorVertex(float3 ws_vertex, float3 ambientColor) {
        float3 lightColorMain = _LightColor0.rgb;
        float3 lightColorSub4 = OmniDirectional_Shade4PointLights(
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb,
                unity_LightColor[1].rgb,
                unity_LightColor[2].rgb,
                unity_LightColor[3].rgb,
                unity_4LightAtten0,
                ws_vertex
            );
        float3 color = NON_ZERO_VEC3(lightColorMain + lightColorSub4 + ambientColor);   // 合成
        float power = AVE_RGB(color);                                       // 明度
        color = lerp( power.xxx, color, _GL_BlendPower);                    // 色の混合
        color = saturate( color / AVE_RGB(color) );                         // 正規化
        color = color * saturate( power * 2 + (100 - _GL_Level) * 0.01 );   // アンチグレア
        return color;
    }

    inline float calcAngleLightCamera(v2f i) {
        if (TGL_ON(_GL_DisableBackLit)) {
            return 0;
        }
        if (isInMirror()) {
            return 0; // 鏡の中のときは、視差問題が生じないように強制的に 0 にする
        }
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float2 xz_camera_pos = worldSpaceCameraPos().xz - calcWorldSpaceBasePos(float4(0, 0, 0, 1)).xz;
        float angle_light_camera = dot( SafeNormalizeVec2(i.ws_light_dir.xz), SafeNormalizeVec2(xz_camera_pos) )
            * (1 - smoothstep(0.9, 1, abs(i.ws_light_dir.y))) * smoothstep(0, 1, length(xz_camera_pos) * 3);
        return angle_light_camera;
    }

    ////////////////////////////
    // Color Change
    ////////////////////////////

    #ifdef _CL_ENABLE
        float       _CL_Enable;
        float       _CL_DeltaH;
        float       _CL_DeltaS;
        float       _CL_DeltaV;
        float       _CL_Monochrome;

        inline void affectColorChange(inout float4 color) {
            if (TGL_ON(_CL_Enable)) {
                if (TGL_ON(_CL_Monochrome)) {
                    color.r += color.g + color.b;
                    color.g = (color.r - 1) / 2;
                    color.b = (color.r - 1) / 2;
                }
                float3 hsv = rgb2hsv( saturate(color.rgb) );
                hsv += float3( _CL_DeltaH, _CL_DeltaS, _CL_DeltaV);
                hsv.r = frac(hsv.r);
                color.rgb = saturate( hsv2rgb( saturate(hsv) ) );
            }
        }

    #else
        // Dummy
        #define affectColorChange(color)
    #endif

    ////////////////////////////
    // Emissive Scroll
    ////////////////////////////

    #ifdef _ES_ENABLE
        float       _ES_Enable;
        sampler2D   _EmissionMap;
        float4      _EmissionColor;
        float       _ES_BlendType;

    #ifdef _ES_SIMPLE_ENABLE
        #define calcEmissiveWaving(ws_vertex)   (1)
    #else
        int         _ES_Shape;
        float4      _ES_Direction;
        float       _ES_LevelOffset;
        float       _ES_Sharpness;
        float       _ES_Speed;
        float       _ES_AlphaScroll;

        inline float calcEmissiveWaving(float3 ws_vertex) {
            float time = _Time.y * _ES_Speed - dot(ws_vertex, _ES_Direction.xyz);
            // 周期 2PI、値域 [-1, +1] の関数で光量を決める
            if (_ES_Shape == 0) {
                // 励起波
                float v = pow( 1 - frac(time * UNITY_INV_TWO_PI), _ES_Sharpness + 2 );
                float waving = 8 * v * (1 - v) - 1;
                return saturate(waving + _ES_LevelOffset);
            }
            else if (_ES_Shape == 1) {
                // のこぎり波
                float waving = 1 - 2 * frac(time * UNITY_INV_TWO_PI);
                return saturate(waving * _ES_Sharpness + _ES_LevelOffset);
            }
            else if (_ES_Shape == 2) {
                // 正弦波
                float waving = sin( time );
                return saturate(waving * _ES_Sharpness + _ES_LevelOffset);
            }
            else {
                // 定数
                float waving = 1;
                return saturate(waving + _ES_LevelOffset);
            }
        }
    #endif

        inline void affectEmissiveScroll(float3 ws_vertex, float2 mask_uv, inout float4 color) {
            if (TGL_ON(_ES_Enable)) {
                float waving    = calcEmissiveWaving(ws_vertex);
                float3 es_mask  = tex2D(_EmissionMap, mask_uv).rgb;
                float es_power  = MAX_RGB(es_mask);
                float3 es_color = _EmissionColor.rgb * es_mask.rgb + lerp(color.rgb, ZERO_VEC3, _ES_BlendType);

                color.rgb = lerp(color.rgb,
                    lerp(color.rgb, es_color, waving),
                    es_power);

                #ifndef _ES_SIMPLE_ENABLE
                    #ifdef _ES_FORCE_ALPHASCROLL
                        color.a = max(color.a, waving * _EmissionColor.a * es_power);
                    #else
                        if (TGL_ON(_ES_AlphaScroll)) {
                            color.a = max(color.a, waving * _EmissionColor.a * es_power);
                        }
                    #endif
                #endif
            }
        }

    #else
        // Dummy
        #define affectEmissiveScroll(ws_vertex, mask_uv, color)
    #endif

    ////////////////////////////
    // Normal Map
    ////////////////////////////

    #ifdef _NM_ENABLE
        float       _NM_Enable;
        // 1st NormalMap
        DECL_SUB_TEX2D(_BumpMap);
        float       _BumpScale;
        float       _NM_Power;
        float       _NM_FlipTangent;
#ifndef _WF_MOBILE
        // 2nd NormalMap
        float       _NM_2ndType;
        DECL_MAIN_TEX2D(_DetailNormalMap);
        float4      _DetailNormalMap_ST;
        float       _DetailNormalMapScale;
        DECL_SUB_TEX2D(_NM_2ndMaskTex);
        float       _NM_InvMaskVal;
#endif

        inline void affectBumpNormal(v2f i, float2 uv_main, out float3 ws_bump_normal, inout float4 color) {
            if (TGL_ON(_NM_Enable)) {
                // 1st NormalMap
                float3 normalTangent = UnpackScaleNormal( PICK_SUB_TEX2D(_BumpMap, _MainTex, uv_main), _BumpScale );

#ifndef _WF_MOBILE
                // 2nd NormalMap
                float2 uv_dtl = TRANSFORM_TEX(i.uv, _DetailNormalMap);
                if (_NM_2ndType == 1) { // BLEND
                    float dtlPower = SAMPLE_MASK_VALUE(_NM_2ndMaskTex, uv_main, _NM_InvMaskVal);
                    float3 dtlNormalTangent = UnpackScaleNormal( PICK_MAIN_TEX2D(_DetailNormalMap, uv_dtl), _DetailNormalMapScale);
                    normalTangent = lerp(normalTangent, BlendNormals(normalTangent, dtlNormalTangent), dtlPower);
                }
                else if (_NM_2ndType == 2) { // SWITCH
                    float dtlPower = SAMPLE_MASK_VALUE(_NM_2ndMaskTex, uv_main, _NM_InvMaskVal);
                    float3 dtlNormalTangent = UnpackScaleNormal( PICK_MAIN_TEX2D(_DetailNormalMap, uv_dtl), _DetailNormalMapScale);
                    normalTangent = lerp(normalTangent, dtlNormalTangent, dtlPower);
                }
#endif

                // 法線計算
                float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal); // vertex周辺のworld法線空間
                ws_bump_normal = mul( normalTangent, tangentTransform);

                // NormalMap は陰影として描画する
                // 影側を暗くしすぎないために、ws_normal と ws_bump_normal の差を加算することで明暗を付ける
                color.rgb += (dot(ws_bump_normal, i.ws_light_dir.xyz) - dot(i.normal, i.ws_light_dir.xyz)) * _NM_Power;
            }
            else {
                ws_bump_normal = i.normal;
            }
        }
    #else
        #define affectBumpNormal(i, uv_main, ws_bump_normal, color)  ws_bump_normal = i.normal
    #endif

    ////////////////////////////
    // Metallic
    ////////////////////////////

    #ifdef _MT_ENABLE
        float       _MT_Enable;
        float       _MT_Metallic;
        float       _MT_ReflSmooth;
        float       _MT_BlendNormal;
        float       _MT_Brightness;
        float       _MT_Monochrome;
        float       _MT_Specular;
        float       _MT_SpecSmooth;
        DECL_SUB_TEX2D(_MetallicGlossMap);
        float       _MT_InvMaskVal;
#ifndef _WF_MOBILE
        int         _MT_CubemapType;
        samplerCUBE _MT_Cubemap;
        float4      _MT_Cubemap_HDR;
#endif

        inline float3 pickReflection(float3 ws_vertex, float3 ws_normal, float smoothness) {
            float metal_lod = (1 - smoothness) * 10;
#ifdef _WF_MOBILE
            return pickReflectionProbe(ws_vertex, ws_normal, metal_lod);
#else
            float3 color = ZERO_VEC3;
            // ONLYでなければ PROBE を加算
            if (_MT_CubemapType != 2) {
                color += pickReflectionProbe(ws_vertex, ws_normal, metal_lod);
            }
            // OFFでなければ SECOND_MAP を加算
            if (_MT_CubemapType != 0) {
                color += pickReflectionCubemap(_MT_Cubemap, _MT_Cubemap_HDR, ws_vertex, ws_normal, metal_lod);
            }
            return color;
#endif
        }

        inline float3 pickSpecular(float3 ws_vertex, float3 ws_normal, float3 ws_light_dir, float3 spec_color, float smoothness) {
            float roughness         = (1 - smoothness) * (1 - smoothness);

            float3 ws_camera_dir    = worldSpaceViewDir(ws_vertex);

            float3 halfVL           = normalize(ws_camera_dir + ws_light_dir);
            float NdotH             = max(0, dot( ws_normal, halfVL ));
            float3 specular         = spec_color * GGXTerm(NdotH, roughness);

            return max(ZERO_VEC3, specular);
        }

        inline void affectMetallic(v2f i, float3 ws_vertex, float2 uv_main, float3 ws_normal, float3 ws_bump_normal, inout float4 color) {
            if (TGL_ON(_MT_Enable)) {
                float3 ws_metal_normal = normalize(lerp(ws_normal, ws_bump_normal, _MT_BlendNormal));
                float2 metallicSmoothness = SAMPLE_MASK_VALUE(_MetallicGlossMap, uv_main, _MT_InvMaskVal).ra;
                float metallic = _MT_Metallic * metallicSmoothness.x;
                if (0.01 < metallic) {
                    // リフレクション
                    float3 reflection = pickReflection(ws_vertex, ws_metal_normal, metallicSmoothness.y * _MT_ReflSmooth);
                    if (TGL_ON(_MT_Monochrome)) {
                        reflection = calcBrightness(reflection);
                    }

                    // スペキュラ
                    float3 specular = ZERO_VEC3;
                    if (0.01 < _MT_Specular) {
                        specular = pickSpecular(ws_vertex, ws_metal_normal, i.ws_light_dir, i.light_color.rgb * color.rgb, metallicSmoothness.y * _MT_SpecSmooth);
                    }

                    // 合成
                    color.rgb = lerp(
                        color.rgb,
                        lerp(color.rgb * reflection.rgb, color.rgb + reflection.rgb, _MT_Brightness) + specular.rgb * _MT_Specular,
                        metallic);
                }
            }
        }
    #else
        #define affectMetallic(i, ws_vertex, uv_main, ws_normal, ws_bump_normal, color)
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

        inline void affectMatcapColor(float2 matcapVector, float2 uv_main, inout float4 color) {
            if (TGL_ON(_HL_Enable)) {
                // matcap サンプリング
                float2 matcap_uv = matcapVector.xy * 0.5 + 0.5;
                float3 matcap_color = tex2D(_HL_MatcapTex, saturate(matcap_uv)).rgb;
                // マスク参照
                float3 matcap_mask = SAMPLE_MASK_VALUE(_HL_MaskTex, uv_main, _HL_InvMaskVal).rgb;
                // 色合成
                if (_HL_CapType == 1) {
                    // 加算合成
                    float3 lightcap_power = saturate(matcap_mask * LinearToGammaSpace(_HL_MatcapColor) * 2);
                    color.rgb += matcap_color * lightcap_power * _HL_Power;
                } else if(_HL_CapType == 2) {
                    // 乗算合成
                    float3 lightcap_power = saturate(matcap_mask * LinearToGammaSpace(_HL_MatcapColor) * 2);
                    color.rgb *= ONE_VEC3 + (matcap_color * lightcap_power - ONE_VEC3) * _HL_Power * MAX_RGB(matcap_mask);
                } else {
                    // 中間色合成
                    float3 lightcap_power = saturate(matcap_mask * _HL_MatcapColor * 2);
                    float3 shadecap_power = (1 - lightcap_power) * MAX_RGB(matcap_mask);
                    float3 lightcap_color = saturate( (matcap_color - MEDIAN_GRAY) * lightcap_power );
                    float3 shadecap_color = saturate( (MEDIAN_GRAY - matcap_color) * shadecap_power );
                    color.rgb += (lightcap_color - shadecap_color) * _HL_Power;
                }
            }
        }
    #else
        #define affectMatcapColor(matcapVector, uv_main, color)
    #endif

    ////////////////////////////
    // ToonShade
    ////////////////////////////

    #ifdef _TS_ENABLE
        float       _TS_Enable;
        float4      _TS_BaseColor;
        float4      _TS_1stColor;
        float4      _TS_2ndColor;
#ifndef _WF_MOBILE
        DECL_SUB_TEX2D(_TS_BaseTex);
        DECL_SUB_TEX2D(_TS_1stTex);
        DECL_SUB_TEX2D(_TS_2ndTex);
#endif
        float       _TS_Power;
        float       _TS_1stBorder;
        float       _TS_2ndBorder;
        float       _TS_Feather;
        float       _TS_BlendNormal;
        DECL_SUB_TEX2D(_TS_MaskTex);
        float       _TS_InvMaskVal;

        inline void calcToonShadeContrast(float3 ws_vertex, float4 ws_light_dir, float3 ambientColor, out float shadow_power) {
            if (TGL_ON(_TS_Enable)) {
                float3 lightColorMain = calcWorldSpaceLightColor(ws_vertex, ws_light_dir.w);
                float3 lightColorSub4 = OmniDirectional_Shade4PointLights(
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        0 < ws_light_dir.w ? unity_LightColor[0].rgb : ZERO_VEC3,
                        unity_LightColor[1].rgb,
                        unity_LightColor[2].rgb,
                        unity_LightColor[3].rgb,
                        unity_4LightAtten0,
                        ws_vertex
                    );
                float main = saturate(calcBrightness( lightColorMain ));
                float sub4 = saturate(calcBrightness( lightColorSub4 ));
                float ambient = saturate(calcBrightness( ambientColor ));
                shadow_power = saturate( abs(main - sub4) / max(main + sub4, 0.0001) ) * 0.5 + 0.5;
                shadow_power = min( shadow_power, 1 - smoothstep(0.8, 1, abs(ws_light_dir.y)) * 0.5 );
                shadow_power = min( shadow_power, 1 - saturate(ambient) * 0.5 );
            } else {
                shadow_power = 0;
            }
        }

        inline void affectToonShade(v2f i, float2 uv_main, float3 ws_normal, float3 ws_bump_normal, float angle_light_camera, inout float4 color) {
            if (TGL_ON(_TS_Enable)) {
                float boostlight = 0.5 + 0.25 * SAMPLE_MASK_VALUE(_TS_MaskTex, uv_main, _TS_InvMaskVal).r;
                float3 ws_shade_normal = normalize(lerp(ws_normal, ws_bump_normal, _TS_BlendNormal));
                float brightness = dot(ws_shade_normal, i.ws_light_dir.xyz) * (1 - boostlight) + boostlight;
                // ビュー相対位置シフト
                brightness *= smoothstep(-1.01, -1.0 + (_TS_1stBorder + _TS_2ndBorder) / 2, angle_light_camera);
                // 影色計算
#ifndef _WF_MOBILE
                float3 base_color = NON_ZERO_VEC3( _TS_BaseColor.rgb * PICK_SUB_TEX2D(_TS_BaseTex, _MainTex, i.uv).rgb );
                float3 shadow_color_1st = _TS_1stColor.rgb * PICK_SUB_TEX2D(_TS_1stTex, _MainTex, i.uv).rgb / base_color.rgb;
                float3 shadow_color_2nd = _TS_2ndColor.rgb * PICK_SUB_TEX2D(_TS_2ndTex, _MainTex, i.uv).rgb / base_color.rgb;
#else
                float3 base_color = NON_ZERO_VEC3( _TS_BaseColor.rgb );
                float3 shadow_color_1st = _TS_1stColor.rgb / base_color.rgb;
                float3 shadow_color_2nd = _TS_2ndColor.rgb / base_color.rgb;
#endif
                shadow_color_1st = lerp(ONE_VEC3, shadow_color_1st, i.shadow_power * _TS_Power * _TS_1stColor.a);
                shadow_color_2nd = lerp(ONE_VEC3, shadow_color_2nd, i.shadow_power * _TS_Power * _TS_2ndColor.a);
                // 色計算
                color.rgb *= lerp(
                    lerp(shadow_color_2nd, shadow_color_1st, smoothstep(_TS_2ndBorder - max(_TS_Feather, 0.001), _TS_2ndBorder, brightness) ),
                    ONE_VEC3,
                    smoothstep(_TS_1stBorder, _TS_1stBorder + max(_TS_Feather, 0.001), brightness));
            }
        }
    #else
        #define calcToonShadeContrast(ws_vertex, ws_light_dir, ambientColor, shadow_power)
        #define affectToonShade(i, uv_main, ws_normal, ws_bump_normal, angle_light_camera, color)
    #endif

    ////////////////////////////
    // Rim Light
    ////////////////////////////

    #ifdef _TR_ENABLE
        float       _TR_Enable;
        float4      _TR_Color;
        float       _TR_BlendType;
        float       _TR_PowerTop;
        float       _TR_PowerSide;
        float       _TR_PowerBottom;
        DECL_SUB_TEX2D(_TR_MaskTex);
        float       _TR_InvMaskVal;

        inline void affectRimLight(v2f i, float2 uv_main, float3 vs_normal, float angle_light_camera, inout float4 color) {
            if (TGL_ON(_TR_Enable)) {
                // vs_normalからリムライト範囲を計算
                float2 rim_uv = vs_normal.xy;
                rim_uv.x *= _TR_PowerSide + 1;
                rim_uv.y *= (_TR_PowerTop + _TR_PowerBottom) / 2 + 1;
                rim_uv.y += (_TR_PowerTop - _TR_PowerBottom) / 2;
                // 順光の場合はリムライトを暗くする
                float3 rimPower = saturate(0.8 - angle_light_camera) * _TR_Color.a * SAMPLE_MASK_VALUE(_TR_MaskTex, uv_main, _TR_InvMaskVal).rgb;
                // 色計算
                float3 rimColor = _TR_Color.rgb - (TGL_OFF(_TR_BlendType) ? MEDIAN_GRAY : color.rgb);
                color.rgb = lerp(color.rgb, color.rgb + rimColor * rimPower, smoothstep(1, 1.05, length(rim_uv)) );
            }
        }
    #else
        #define affectRimLight(i, uv_main, vs_normal, angle_light_camera, color)
    #endif

    ////////////////////////////
    // ScreenTone Texture
    ////////////////////////////

    #ifdef _OL_ENABLE
        float       _OL_Enable;
        sampler2D   _OL_OverlayTex;
        float4      _OL_OverlayTex_ST;
        int         _OL_BlendType;
        float       _OL_Power;
        DECL_SUB_TEX2D(_OL_MaskTex);
        float       _OL_InvMaskVal;

        inline float2 computeOverlayTex(float3 ws_vertex) {
            float3 ws_view_dir = normalize( ws_vertex - _WorldSpaceCameraPos.xyz );

            float lon = atan2( ws_view_dir.z, ws_view_dir.x );  // -PI ~ +PI
            float lat = acos( ws_view_dir.y );                  // -PI ~ +PI
            float2 uv = float2(-lon, -lat) * UNITY_INV_TWO_PI + 0.5;

            return TRANSFORM_TEX(uv, _OL_OverlayTex);
        }

        inline float3 blendOverlayColor(float3 color, float3 ov_color, float3 power) {
            if (_OL_BlendType == 1) {
                return color + ov_color * power;    // 加算
            }
            if (_OL_BlendType == 2) {
                return color * lerp( ONE_VEC3, ov_color, power);    // 重み付き乗算
            }
            return lerp(color, ov_color, power);    // ブレンド
        }

        inline void affectOverlayTexture(float3 ws_vertex, float2 uv_main, inout float4 color) {
            if (TGL_ON(_OL_Enable)) {
                float2 uv_overlay = computeOverlayTex(ws_vertex);
                float3 power = _OL_Power * SAMPLE_MASK_VALUE(_OL_MaskTex, uv_main, _OL_InvMaskVal).rgb;
                color.rgb = blendOverlayColor(color.rgb, tex2D(_OL_OverlayTex, uv_overlay).rgb, power);
            }
        }
    #else
        #define affectOverlayTexture(ws_vertex, uv_main, color)
    #endif

    ////////////////////////////
    // Outline
    ////////////////////////////

    #ifdef _TL_ENABLE
        float       _TL_Enable;
        float4      _TL_LineColor;
        float       _TL_LineWidth;
        int         _TL_LineType;
        float       _TL_BlendBase;
        DECL_SUB_TEX2D(_TL_MaskTex);
        float       _TL_InvMaskVal;
        float       _TL_Z_Shift;

        inline void affectOutline(float2 uv_main, inout float4 color) {
            if (TGL_ON(_TL_Enable)) {
                // アウトライン色をベースと合成
                color.rgb = lerp(_TL_LineColor.rgb, color.rgb, _TL_BlendBase);
            }
        }

        inline void affectOutlineAlpha(float2 uv_main, inout float4 color) {
            if (TGL_ON(_TL_Enable)) {
                // アウトラインAlphaをベースと合成
                float mask = SAMPLE_MASK_VALUE(_TL_MaskTex, uv_main, _TL_InvMaskVal).r;
                if (mask < 0.1) {
                    color.a = 0;
                    discard;
                } else {
                    #ifdef _AL_ENABLE
                        color.a = _TL_LineColor.a * mask;
                    #else
                        color.a = 1;
                    #endif
                }
            }
        }
    #else
        #define affectOutline(uv_main, color)
        #define affectOutlineAlpha(uv_main, color)
    #endif

    ////////////////////////////
    // Ambient Occlusion
    ////////////////////////////

    #ifdef _AO_ENABLE
        float       _AO_Enable;
        float       _AO_UseLightMap;
#ifndef _WF_MOBILE
        DECL_SUB_TEX2D(_OcclusionMap);
#endif
        float       _AO_Contrast;
        float       _AO_Brightness;

        inline void affectOcclusion(v2f i, float2 uv_main, inout float4 color) {
            if (TGL_ON(_AO_Enable)) {
                float3 occlusion = ONE_VEC3;
#ifndef _WF_MOBILE
                occlusion *= SAMPLE_MASK_VALUE(_OcclusionMap, uv_main, 0).rgb;
#endif
                #ifdef _LMAP_ENABLE
                if (TGL_ON(_AO_UseLightMap)) {
                    occlusion *= pickLightmap(i.uv_lmap);
                }
                #endif
                occlusion = lerp(AVE_RGB(occlusion).xxx, occlusion, _GL_BlendPower); // 色の混合
                occlusion = (occlusion - 1) * _AO_Contrast + 1 + _AO_Brightness;
                color.rgb *= max(ZERO_VEC3, occlusion.rgb);
            }
        }
    #else
        #define affectOcclusion(i, uv_main, color)
    #endif

    inline float3 calcAmbientColorVertex(appdata v) {
        // ライトマップもしくは環境光を取得
        #ifdef _LMAP_ENABLE
            float3 color = pickLightmapLod(v.uv_lmap);
            #if defined(_AO_ENABLE)
            if (TGL_ON(_AO_Enable)) {
                // ライトマップが使えてAOが有効の場合は、AO側で色を合成するので明るさだけ取得する
                return AVE_RGB(color).xxx;
            }
            #endif
            return color;
        #else
            return OmniDirectional_ShadeSH9();
        #endif
    }

    ////////////////////////////
    // Debug View
    ////////////////////////////

//    #ifdef _WF_DEBUGVIEW_MAGENTA
//        #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256; color.rb += 1
//    #elif _WF_DEBUGVIEW_CLIP
//        #define WF_AFFECT_DEBUGVIEW     discard
//    #elif _WF_DEBUGVIEW_POSITION
//        #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256; color.rgb += saturate( abs(mul(unity_WorldToObject, i.ws_vertex) ) )
//    #elif _WF_DEBUGVIEW_NORMAL
//        #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256; color.rgb += UnityWorldToObjectDir(ws_normal).rgb / 2 + 0.5
//    #elif _WF_DEBUGVIEW_TANGENT
//        #ifdef _NM_ENABLE
//            #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256; color.rgb += UnityWorldToObjectDir(i.tangent.rgb) / 2 + 0.5
//        #else
//            #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256
//        #endif
//    #elif _WF_DEBUGVIEW_BUMPED_NORMAL
//        #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256; color.rgb += UnityWorldToObjectDir(ws_bump_normal).rgb / 2 + 0.5
//    #elif _WF_DEBUGVIEW_LIGHT_COLOR
//        #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256; color.rgb += i.light_color.rgb
//    #elif _WF_DEBUGVIEW_LIGHT_MAP
//        #ifdef _LMAP_ENABLE
//            #define WF_AFFECT_DEBUGVIEW     color.rgb /= 256; color.rgb += pickLightmap(i.uv_lmap).rgb
//        #else
//            #define WF_AFFECT_DEBUGVIEW     discard
//        #endif
//    #else
//        #define WF_AFFECT_DEBUGVIEW
//    #endif

#endif
