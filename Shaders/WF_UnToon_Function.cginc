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

#ifndef INC_UNLIT_WF_UNTOON_FUNCTION
#define INC_UNLIT_WF_UNTOON_FUNCTION

    /*
     * authors:
     *      ver:2020/10/13 whiteflare,
     */

    ////////////////////////////
    // Textureピックアップ関数
    ////////////////////////////

    /* このセクションでは、どのテクスチャから何色を参照するかを定義する */

    #ifndef WF_TEX2D_ALPHA_MAIN_ALPHA
        #define WF_TEX2D_ALPHA_MAIN_ALPHA(uv)   alpha
    #endif
    #ifndef WF_TEX2D_ALPHA_MASK_RED
        #define WF_TEX2D_ALPHA_MASK_RED(uv)     PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).r
    #endif
    #ifndef WF_TEX2D_ALPHA_MASK_ALPHA
        #define WF_TEX2D_ALPHA_MASK_ALPHA(uv)   PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).a
    #endif

    #ifndef WF_TEX2D_3CH_MASK
        #define WF_TEX2D_3CH_MASK(uv)           PICK_SUB_TEX2D(_CH_3chMaskTex, _MainTex, uv).rgb
    #endif

    #ifndef WF_TEX2D_EMISSION
        #define WF_TEX2D_EMISSION(uv)           PICK_SUB_TEX2D(_EmissionMap, _MainTex, uv).rgb
    #endif

    #ifndef WF_TEX2D_NORMAL
        #define WF_TEX2D_NORMAL(uv)             UnpackScaleNormal( PICK_MAIN_TEX2D(_BumpMap, uv), _BumpScale ).xyz
    #endif
    #ifndef WF_TEX2D_NORMAL_DTL
        #define WF_TEX2D_NORMAL_DTL(uv)         UnpackScaleNormal( PICK_MAIN_TEX2D(_DetailNormalMap, uv), _DetailNormalMapScale ).xyz
    #endif
    #ifndef WF_TEX2D_NORMAL_DTL_MASK
        #define WF_TEX2D_NORMAL_DTL_MASK(uv)    SAMPLE_MASK_VALUE(_NM_2ndMaskTex, uv, _NM_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_METAL_GLOSS
        #ifndef _WF_MOBILE
            #define WF_TEX2D_METAL_GLOSS(uv)    (SAMPLE_MASK_VALUE(_MetallicGlossMap, uv, _MT_InvMaskVal).ra * float2(1, 1 - SAMPLE_MASK_VALUE(_SpecGlossMap, uv, _MT_InvRoughnessMaskVal).r))
        #else
            #define WF_TEX2D_METAL_GLOSS(uv)    SAMPLE_MASK_VALUE(_MetallicGlossMap, uv, _MT_InvMaskVal).ra
        #endif
    #endif

    #ifndef WF_TEX2D_MATCAP_MASK
        #define WF_TEX2D_MATCAP_MASK(uv)        SAMPLE_MASK_VALUE(_HL_MaskTex, uv, _HL_InvMaskVal).rgb
    #endif

    #ifndef WF_TEX2D_SHADE_BASE
        #ifndef _WF_MOBILE
            #define WF_TEX2D_SHADE_BASE(uv)     PICK_SUB_TEX2D(_TS_BaseTex, _MainTex, uv).rgb
        #else
            #define WF_TEX2D_SHADE_BASE(uv)     ONE_VEC3
        #endif
    #endif
    #ifndef WF_TEX2D_SHADE_1ST
        #ifndef _WF_MOBILE
            #define WF_TEX2D_SHADE_1ST(uv)      PICK_SUB_TEX2D(_TS_1stTex, _MainTex, uv).rgb
        #else
            #define WF_TEX2D_SHADE_1ST(uv)      ONE_VEC3
        #endif
    #endif
    #ifndef WF_TEX2D_SHADE_2ND
        #ifndef _WF_MOBILE
            #define WF_TEX2D_SHADE_2ND(uv)      PICK_SUB_TEX2D(_TS_2ndTex, _MainTex, uv).rgb
        #else
            #define WF_TEX2D_SHADE_2ND(uv)      ONE_VEC3
        #endif
    #endif
    #ifndef WF_TEX2D_SHADE_MASK
        #define WF_TEX2D_SHADE_MASK(uv)         SAMPLE_MASK_VALUE(_TS_MaskTex, uv, _TS_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_RIM_MASK
        #define WF_TEX2D_RIM_MASK(uv)           SAMPLE_MASK_VALUE(_TR_MaskTex, uv, _TR_InvMaskVal).rgb
    #endif

    #ifndef WF_TEX2D_SCREEN_MASK
        #define WF_TEX2D_SCREEN_MASK(uv)        SAMPLE_MASK_VALUE(_OL_MaskTex, uv, _OL_InvMaskVal).rgb
    #endif

    #ifndef WF_TEX2D_OUTLINE_COLOR
        #define WF_TEX2D_OUTLINE_COLOR(uv)      PICK_SUB_TEX2D(_TL_CustomColorTex, _MainTex, uv).rgb
    #endif

    #ifndef WF_TEX2D_OUTLINE_MASK
        #ifndef _TL_MASK_APPLY_LEGACY
            #define WF_TEX2D_OUTLINE_MASK(uv)   SAMPLE_MASK_VALUE_LOD(_TL_MaskTex, uv, _TL_InvMaskVal).r
        #else
            #define WF_TEX2D_OUTLINE_MASK(uv)   SAMPLE_MASK_VALUE(_TL_MaskTex, uv, _TL_InvMaskVal).r
        #endif
    #endif

    #ifndef WF_TEX2D_OCCLUSION
        #define WF_TEX2D_OCCLUSION(uv)          SAMPLE_MASK_VALUE(_OcclusionMap, uv, 0).rgb
    #endif

    ////////////////////////////
    // Alpha Transparent
    ////////////////////////////

    float           _Cutoff;

    #ifdef _AL_ENABLE
        uint            _AL_Source;
        float           _AL_Power;
        DECL_SUB_TEX2D(_AL_MaskTex);
        float           _AL_Fresnel;
        float           _AL_AlphaToMask;

        #ifndef _AL_CustomValue
            #define _AL_CustomValue 1
        #endif

        inline float pickAlpha(float2 uv, float alpha) {
            if (_AL_Source == 1) {
                return WF_TEX2D_ALPHA_MASK_RED(uv);
            }
            else if (_AL_Source == 2) {
                return WF_TEX2D_ALPHA_MASK_ALPHA(uv);
            }
            else {
                return WF_TEX2D_ALPHA_MAIN_ALPHA(uv);
            }
        }

        inline void affectAlpha(float2 uv, inout float4 color) {
            float baseAlpha = pickAlpha(uv, color.a);

            #if defined(_AL_CUTOUT)
                baseAlpha = smoothstep(_Cutoff - 0.0625, _Cutoff + 0.0625, baseAlpha);
                if (TGL_OFF(_AL_AlphaToMask) && baseAlpha < 0.5) {
                    discard;
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
                baseAlpha = smoothstep(_Cutoff - 0.0625, _Cutoff + 0.0625, baseAlpha);
                if (TGL_OFF(_AL_AlphaToMask) && baseAlpha < 0.5) {
                    discard;
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

    float           _GL_LevelMin;
    float           _GL_LevelMax;
    float           _GL_BlendPower;
    uint            _GL_LightMode;
    float           _GL_CustomAzimuth;
    float           _GL_CustomAltitude;
    float           _GL_DisableBackLit;
    float           _GL_DisableBasePos;

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

    inline float3 calcWorldSpaceBasePos(float3 ws_vertex) {
        if (TGL_OFF(_GL_DisableBasePos)) {
            // Object原点をBasePosとして使用する
            return mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
        }
        else {
            // 現在の座標をBasePosとして使用する
            return ws_vertex;
        }
    }

    inline float4 calcWorldSpaceLightDir(float3 ws_vertex) {
        ws_vertex = calcWorldSpaceBasePos(ws_vertex);
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
        color = color * lerp(saturate(power / NON_ZERO_FLOAT(_GL_LevelMax)), 1, _GL_LevelMin);  // アンチグレア
        return color;
    }

    inline float calcAngleLightCamera(v2f i) {
        if (TGL_ON(_GL_DisableBackLit)) {
            return 0;
        }
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float2 xz_camera_pos = worldSpaceViewPointPos().xz - calcWorldSpaceBasePos(i.ws_vertex).xz;
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
    // 3ch Color Mask
    ////////////////////////////

    #ifdef _CH_ENABLE
        float       _CH_Enable;
        DECL_SUB_TEX2D(_CH_3chMaskTex);
        float4		_CH_ColorR;
        float4		_CH_ColorG;
        float4		_CH_ColorB;

        inline void affect3chColorMask(float2 mask_uv, inout float4 color) {
            if (TGL_ON(_CH_Enable)) {
                float3 mask  = WF_TEX2D_3CH_MASK(mask_uv);
                float4 c1 = color * _CH_ColorR;
                float4 c2 = color * _CH_ColorG;
                float4 c3 = color * _CH_ColorB;
                color = lerp(color, c1, mask.r);
                color = lerp(color, c2, mask.g);
                color = lerp(color, c3, mask.b);
            }
        }

    #else
        // Dummy
        #define affect3chColorMask(mask_uv, color)
    #endif

    ////////////////////////////
    // Emissive Scroll
    ////////////////////////////

    #ifdef _ES_ENABLE
        float       _ES_Enable;
        DECL_SUB_TEX2D(_EmissionMap);
        float4      _EmissionColor;
        float       _ES_BlendType;

    #ifdef _ES_SIMPLE_ENABLE
        #define calcEmissiveWaving(ws_vertex)   (1)
    #else
        uint        _ES_Shape;
        uint        _ES_DirType;
        float4      _ES_Direction;
        float       _ES_LevelOffset;
        float       _ES_Sharpness;
        float       _ES_Speed;
        float       _ES_AlphaScroll;

        inline float calcEmissiveWaving(float3 ws_vertex) {
            if (_ES_Shape == 3) {
                // 定数
                return saturate(1 + _ES_LevelOffset);
            }
            // 周期 2PI、値域 [-1, +1] の関数で光量を決める
            float time = _Time.y * _ES_Speed - dot( _ES_DirType == 0 ? ws_vertex : mul(unity_WorldToObject, float4(ws_vertex, 1)).xyz, _ES_Direction.xyz);
            float v = pow( 1 - frac(time * UNITY_INV_TWO_PI), _ES_Sharpness + 2 );
            float waving =
                // 励起波
                _ES_Shape == 0 ? 8 * v * (1 - v) - 1 :
                // のこぎり波
                _ES_Shape == 1 ? (1 - 2 * frac(time * UNITY_INV_TWO_PI)) * _ES_Sharpness :
                // 正弦波
                sin( time ) * _ES_Sharpness;
            return saturate(waving + _ES_LevelOffset);
        }
    #endif

        inline void affectEmissiveScroll(float3 ws_vertex, float2 mask_uv, inout float4 color) {
            if (TGL_ON(_ES_Enable)) {
                float waving    = calcEmissiveWaving(ws_vertex);
                float3 es_mask  = WF_TEX2D_EMISSION(mask_uv);
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
        DECL_MAIN_TEX2D(_BumpMap);  // UVはMainTexと共通だが別のFilterを使えるようにsampler2Dで定義する
        float       _BumpScale;
        float       _NM_Power;
        float       _NM_FlipTangent;
#ifndef _WF_MOBILE
        // 2nd NormalMap
        uint        _NM_2ndType;
        DECL_MAIN_TEX2D(_DetailNormalMap);
        float4      _DetailNormalMap_ST;
        float       _DetailNormalMapScale;
        DECL_SUB_TEX2D(_NM_2ndMaskTex);
        float       _NM_InvMaskVal;
#endif

        inline float3 calcBumpNormal(v2f i, float2 uv_main) {
            if (TGL_ON(_NM_Enable)) {
                // 1st NormalMap
                float3 normalTangent = WF_TEX2D_NORMAL(uv_main);

#ifndef _WF_MOBILE
                // 2nd NormalMap
                float2 uv_dtl = TRANSFORM_TEX(i.uv, _DetailNormalMap);
                if (_NM_2ndType == 1) { // BLEND
                    float dtlPower = WF_TEX2D_NORMAL_DTL_MASK(uv_main);
                    float3 dtlNormalTangent = WF_TEX2D_NORMAL_DTL(uv_dtl);
                    normalTangent = lerp(normalTangent, BlendNormals(normalTangent, dtlNormalTangent), dtlPower);
                }
                else if (_NM_2ndType == 2) { // SWITCH
                    float dtlPower = WF_TEX2D_NORMAL_DTL_MASK(uv_main);
                    float3 dtlNormalTangent = WF_TEX2D_NORMAL_DTL(uv_dtl);
                    normalTangent = lerp(normalTangent, dtlNormalTangent, dtlPower);
                }
#endif

                // 法線計算
                float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal); // vertex周辺のworld法線空間
                return mul( normalTangent, tangentTransform);
            }
            else {
                return i.normal;
            }
        }

        inline void affectBumpNormal(v2f i, float2 uv_main, out float3 ws_bump_normal, inout float4 color) {
            // bump_normal 計算
            ws_bump_normal = calcBumpNormal(i, uv_main);
            
            if (TGL_ON(_NM_Enable)) {
                // NormalMap は陰影として描画する
                // 影側を暗くしすぎないために、ws_normal と ws_bump_normal の差を加算することで明暗を付ける
                color.rgb += (dot(ws_bump_normal, i.ws_light_dir.xyz) - dot(i.normal, i.ws_light_dir.xyz)) * _NM_Power;
            }
        }
    #else
        #define calcBumpNormal(i, uv_main) i.normal
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
        DECL_SUB_TEX2D(_SpecGlossMap);
        float       _MT_InvRoughnessMaskVal;
        uint        _MT_CubemapType;
        samplerCUBE _MT_Cubemap;
        float4      _MT_Cubemap_HDR;
        float       _MT_CubemapPower;
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
                color += pickReflectionCubemap(_MT_Cubemap, _MT_Cubemap_HDR, ws_vertex, ws_normal, metal_lod) * _MT_CubemapPower;
            }
            return color;
#endif
        }

        inline float3 pickSpecular(float3 ws_camera_dir, float3 ws_normal, float3 ws_light_dir, float3 spec_color, float smoothness) {
            float roughness         = (1 - smoothness) * (1 - smoothness);

            float3 halfVL           = normalize(ws_camera_dir + ws_light_dir);
            float NdotH             = max(0, dot( ws_normal, halfVL ));
            float3 specular         = spec_color * GGXTerm(NdotH, roughness);

            return max(ZERO_VEC3, specular);
        }

        inline void affectMetallic(v2f i, float3 ws_camera_dir, float2 uv_main, float3 ws_normal, float3 ws_bump_normal, inout float4 color) {
            if (TGL_ON(_MT_Enable)) {
                float3 ws_metal_normal = normalize(lerp(ws_normal, ws_bump_normal, _MT_BlendNormal));
                float2 metallicSmoothness = WF_TEX2D_METAL_GLOSS(uv_main);
                float metallic = _MT_Metallic * metallicSmoothness.x;
                if (0.01 < metallic) {
                    // リフレクション
                    float3 reflection = pickReflection(i.ws_vertex, ws_metal_normal, metallicSmoothness.y * _MT_ReflSmooth);
                    reflection = lerp(reflection, calcBrightness(reflection), _MT_Monochrome);

                    // スペキュラ
                    float3 specular = ZERO_VEC3;
                    if (0.01 < _MT_Specular) {
                        specular = pickSpecular(ws_camera_dir, ws_metal_normal, i.ws_light_dir, i.light_color.rgb * color.rgb, metallicSmoothness.y * _MT_SpecSmooth);
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
        #define affectMetallic(i, ws_camera_dir, uv_main, ws_normal, ws_bump_normal, color)
    #endif

    ////////////////////////////
    // Light Matcap
    ////////////////////////////

    #ifdef _HL_ENABLE
        float       _HL_Enable;
        uint        _HL_CapType;
        sampler2D   _HL_MatcapTex;  // MainTexと大きく構造が異なるので独自のサンプラーを使う
        float3      _HL_MatcapColor;
        float       _HL_Power;
        float       _HL_BlendNormal;
        float       _HL_Parallax;
        DECL_SUB_TEX2D(_HL_MaskTex);
        float       _HL_InvMaskVal;

        inline void affectMatcapColor(float2 matcapVector, float2 uv_main, inout float4 color) {
            if (TGL_ON(_HL_Enable)) {
                // matcap サンプリング
                float2 matcap_uv = matcapVector.xy * 0.5 + 0.5;
                float3 matcap_color = tex2D(_HL_MatcapTex, saturate(matcap_uv)).rgb;
                // マスク参照
                float3 matcap_mask = WF_TEX2D_MATCAP_MASK(uv_main);
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

        inline void calcShadowColor(float4 color, float3 shadow_tex, float3 base_color, float power, float border, float brightness, inout float3 shadow_color) {
            shadow_color = lerp( 
                lerp(ONE_VEC3, color.rgb * shadow_tex / base_color, power * _TS_Power * color.a),
                shadow_color,
                smoothstep(border, border + max(_TS_Feather, 0.001), brightness) );
        }

        inline void affectToonShade(v2f i, float2 uv_main, float3 ws_normal, float3 ws_bump_normal, float angle_light_camera, inout float4 color) {
            if (TGL_ON(_TS_Enable)) {
                // 陰用法線とライト方向から Harf-Lambert
                float3 ws_shade_normal = normalize(lerp(ws_normal, ws_bump_normal, _TS_BlendNormal));
                float brightness = lerp(dot(ws_shade_normal, i.ws_light_dir.xyz), 1, 0.5);  // 0.0 ～ 1.0

                // アンチシャドウマスク加算
                float anti_shade = WF_TEX2D_SHADE_MASK(uv_main);
                brightness = lerp(brightness, lerp(brightness, 1, 0.5), anti_shade);
                if (isInMirror()) {
                    angle_light_camera *= anti_shade;
                }

                // ビュー相対位置シフト
                brightness *= smoothstep(-1.01, -1.0 + (_TS_1stBorder + _TS_2ndBorder) / 2, angle_light_camera);

                // 影色計算
                float3 base_color = NON_ZERO_VEC3( _TS_BaseColor.rgb * WF_TEX2D_SHADE_BASE(uv_main) );
                float3 shadow_color = ONE_VEC3;
                // 1影
                calcShadowColor(_TS_1stColor, WF_TEX2D_SHADE_1ST(uv_main), base_color, i.shadow_power, _TS_1stBorder, brightness, shadow_color);
                // 2影
                calcShadowColor(_TS_2ndColor, WF_TEX2D_SHADE_2ND(uv_main), base_color, i.shadow_power, _TS_2ndBorder, brightness, shadow_color);
                // 乗算
                color.rgb *= shadow_color;
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
        float       _TR_BlendNormal;

        inline void affectRimLight(v2f i, float2 uv_main, float3 vs_normal, float angle_light_camera, inout float4 color) {
            if (TGL_ON(_TR_Enable)) {
                if (isInMirror()) {
                    angle_light_camera = 0; // 鏡の中のときは、視差問題が生じないように強制的に 0 にする
                }
                // vs_normalからリムライト範囲を計算
                float2 rim_uv = vs_normal.xy;
                rim_uv.x *= _TR_PowerSide + 1;
                rim_uv.y *= (_TR_PowerTop + _TR_PowerBottom) / 2 + 1;
                rim_uv.y += (_TR_PowerTop - _TR_PowerBottom) / 2;
                // 順光の場合はリムライトを暗くする
                float3 rimPower = saturate(0.8 - angle_light_camera) * _TR_Color.a * WF_TEX2D_RIM_MASK(uv_main);
                // 色計算
                float3 rimColor = _TR_Color.rgb - (TGL_OFF(_TR_BlendType) ? MEDIAN_GRAY : color.rgb);
                color.rgb = lerp(color.rgb, color.rgb + rimColor * rimPower, smoothstep(1, 1.05, length(rim_uv)) );
            }
        }
    #else
        #define affectRimLight(i, uv_main, vs_normal, angle_light_camera, color)
    #endif

    ////////////////////////////
    // Decal Texture
    ////////////////////////////

    #ifdef _OL_ENABLE
        float       _OL_Enable;
        uint        _OL_UVType;
        float4      _OL_Color;
        sampler2D   _OL_OverlayTex; // MainTexと大きく構造が異なるので独自のサンプラーを使う
        float4      _OL_OverlayTex_ST;
        uint        _OL_BlendType;
        float       _OL_Power;
        float       _OL_CustomParam1;
        DECL_SUB_TEX2D(_OL_MaskTex);
        float       _OL_InvMaskVal;

        float2 computeOverlayTex(float3 ws_vertex) {
            float3 ws_view_dir = normalize( ws_vertex - _WorldSpaceCameraPos.xyz );

            float lon = atan2( ws_view_dir.z, ws_view_dir.x );  // -PI ~ +PI
            float lat = acos( ws_view_dir.y );                  // -PI ~ +PI
            float2 uv = float2(-lon, -lat) * UNITY_INV_TWO_PI + 0.5;

            return uv;
        }

        float2 computeAngelRingUV(float3 vs_normal, float2 uv2) {
            return float2(vs_normal.x / 2 + 0.5, lerp(uv2.y, vs_normal.y / 2 + 0.5, _OL_CustomParam1));
        }

        inline float3 blendOverlayColor(float3 color, float4 ov_color, float3 power) {
            float3 rgb = 
                _OL_BlendType == 0 ? ov_color.rgb                           // ブレンド
                : _OL_BlendType == 1 ? color + ov_color.rgb                 // 加算
                : _OL_BlendType == 2 ? color * ov_color.rgb                 // 乗算
                : _OL_BlendType == 3 ? color + ov_color.rgb - MEDIAN_GRAY   // 加減算
                : _OL_BlendType == 4 ? 1 - (1 - color) * (1 - ov_color.rgb) // スクリーン
                : _OL_BlendType == 5 ? lerp(2 * color * ov_color.rgb, 1 - 2 * (1 - color) * (1 - ov_color.rgb), step(calcBrightness(color), 0.5))   // オーバーレイ
                : _OL_BlendType == 6 ? lerp(2 * color * ov_color.rgb, 1 - 2 * (1 - color) * (1 - ov_color.rgb), step(calcBrightness(ov_color), 0.5))   // オーバーレイ
                : color                                                     // 何もしない
                ;
            return lerp(color, rgb, ov_color.a * power);
        }

        inline void affectOverlayTexture(v2f i, float2 uv_main, float3 vs_normal, inout float4 color) {
            if (TGL_ON(_OL_Enable)) {
                float2 uv_overlay =
                    _OL_UVType == 1 ? i.uv_lmap                                                 // UV2
                    : _OL_UVType == 2 ? computeOverlayTex(i.ws_vertex)                          // SKYBOX
                    : _OL_UVType == 3 ? computeAngelRingUV(vs_normal, i.uv_lmap)                // ANGELRING
                    : i.uv                                                                      // UV1
                    ;
                uv_overlay = TRANSFORM_TEX(uv_overlay, _OL_OverlayTex);
                float3 power = _OL_Power * WF_TEX2D_SCREEN_MASK(uv_main);
                color.rgb = blendOverlayColor(color.rgb, tex2D(_OL_OverlayTex, uv_overlay) * _OL_Color, power);
            }
        }
    #else
        #define affectOverlayTexture(i, uv_main, vs_normal, color)
    #endif

    ////////////////////////////
    // Outline
    ////////////////////////////

    #ifdef _TL_ENABLE
        float       _TL_Enable;
        float       _TL_LineWidth;
        uint        _TL_LineType;
        float       _TL_Z_Shift;
        float4      _TL_LineColor;
        float       _TL_BlendBase;
        DECL_SUB_TEX2D(_TL_CustomColorTex);
        float       _TL_BlendCustom;
        #ifndef _TL_MASK_APPLY_LEGACY
            // マスクをシフト時に太さに反映する場合
            sampler2D   _TL_MaskTex;
        #else
            // マスクをfragmentでアルファに反映する場合
            DECL_SUB_TEX2D(_TL_MaskTex);
        #endif
        float       _TL_InvMaskVal;

        inline float getOutlineShiftWidth(float2 uv_main) {
            #ifndef _TL_MASK_APPLY_LEGACY
                float mask = WF_TEX2D_OUTLINE_MASK(uv_main);
            #else
                float mask = 1;
            #endif
            return _TL_LineWidth * 0.01 * mask;
        }

        inline void affectOutline(float2 uv_main, inout float4 color) {
            if (TGL_ON(_TL_Enable)) {
                // アウトライン色をカスタムカラーと合成
                float3 line_color = lerp(_TL_LineColor.rgb, WF_TEX2D_OUTLINE_COLOR(uv_main), _TL_BlendCustom);
                // アウトライン色をベースと合成
                color.rgb = lerp(line_color, color.rgb, _TL_BlendBase);
            }
        }

        inline void affectOutlineAlpha(float2 uv_main, inout float4 color) {
            #ifndef _AL_CUTOUT
                if (TGL_ON(_TL_Enable)) {
                    #ifndef _TL_MASK_APPLY_LEGACY
                        // マスクをシフト時に太さに反映する場合
                        #ifdef _AL_ENABLE
                            color.a = _TL_LineColor.a;
                        #else
                            color.a = 1;
                        #endif
                    #else
                        // マスクをfragmentでアルファに反映する場合
                        float mask = WF_TEX2D_OUTLINE_MASK(uv_main);
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
                    #endif
                }
            #endif
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
                occlusion *= WF_TEX2D_OCCLUSION(uv_main);
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
