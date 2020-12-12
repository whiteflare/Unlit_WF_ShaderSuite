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
     *      ver:2020/12/13 whiteflare,
     */

    ////////////////////////////
    // Textureピックアップ関数
    ////////////////////////////

    /* このセクションでは、どのテクスチャから何色を参照するかを定義する */

    #ifndef WF_TEX2D_ALPHA_MAIN_ALPHA
        #define WF_TEX2D_ALPHA_MAIN_ALPHA(uv)   saturate( TGL_OFF(_AL_InvMaskVal) ? alpha : 1 - alpha )
    #endif
    #ifndef WF_TEX2D_ALPHA_MASK_RED
        #define WF_TEX2D_ALPHA_MASK_RED(uv)     saturate( TGL_OFF(_AL_InvMaskVal) ? PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).r : 1 - PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).r )
    #endif
    #ifndef WF_TEX2D_ALPHA_MASK_ALPHA
        #define WF_TEX2D_ALPHA_MASK_ALPHA(uv)   saturate( TGL_OFF(_AL_InvMaskVal) ? PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).a : 1 - PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).a )
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

    #ifndef WF_TEX2D_LAME_TEX
        #define WF_TEX2D_LAME_TEX(uv)           PICK_SUB_TEX2D(_LM_Texture, _MainTex, uv).rgb
    #endif
    #ifndef WF_TEX2D_LAME_MASK
        #define WF_TEX2D_LAME_MASK(uv)          SAMPLE_MASK_VALUE(_LM_MaskTex, uv, _LM_InvMaskVal).r
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
    #ifndef WF_TEX2D_SHADE_3RD
        #ifndef _WF_MOBILE
            #define WF_TEX2D_SHADE_3RD(uv)      PICK_SUB_TEX2D(_TS_3rdTex, _MainTex, uv).rgb
        #else
            #define WF_TEX2D_SHADE_3RD(uv)      ONE_VEC3
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

    #if defined(_WF_ALPHA_BLEND) || defined(_WF_ALPHA_FRESNEL) || defined(_WF_ALPHA_CUT_UPPER) || defined(_WF_ALPHA_CUT_LOWER)
        #ifndef _WF_ALPHA_BLEND
            #define _WF_ALPHA_BLEND
        #endif
    #endif

    #if defined(_WF_ALPHA_BLEND) || defined(_WF_ALPHA_CUTOUT)
        #ifndef _AL_ENABLE
            #define _AL_ENABLE
        #endif
    #endif

    #ifdef _AL_ENABLE
        #ifndef _AL_CustomValue
            #define _AL_CustomValue 1
        #endif

        inline float pickAlpha(float2 uv, float alpha) {
            return _AL_Source == 1 ? WF_TEX2D_ALPHA_MASK_RED(uv)
                 : _AL_Source == 2 ? WF_TEX2D_ALPHA_MASK_ALPHA(uv)
                 : WF_TEX2D_ALPHA_MAIN_ALPHA(uv);
        }

        inline float affectAlphaMask(float2 uv, inout float4 color) {
            float baseAlpha = pickAlpha(uv, color.a);
            float alpha = baseAlpha;

            /*
             * カットアウト処理
             * cutoutに使うものは、pickAlpha と _AL_CustomValue の値。
             * 一方、Fresnel は cutout には巻き込まない。
             * _AL_CustomValue を使っている MaskOut_Blend は cutout を使わない。
             */

            #if defined(_WF_ALPHA_CUTOUT)
                alpha = smoothstep(_Cutoff - 0.0625, _Cutoff + 0.0625, alpha);
                if (TGL_OFF(_AL_AlphaToMask) && alpha < 0.5) {
                    discard;
                }
            #elif defined(_WF_ALPHA_CUT_UPPER)
                if (alpha < _Cutoff) {
                    discard;
                } else {
                    alpha *= _AL_Power;
                }
            #elif defined(_WF_ALPHA_CUT_LOWER)
                if (alpha < _Cutoff) {
                    alpha *= _AL_Power;
                } else {
                    discard;
                }
            #else
                alpha *= _AL_Power * _AL_CustomValue;
            #endif

            color.a = alpha;

            return baseAlpha; // ベースアルファを返却する
        }

        inline void affectFresnelAlpha(float2 uv, float3 ws_normal, float3 ws_viewdir, float baseAlpha, inout float4 color) {
            #ifdef _WF_ALPHA_FRESNEL
                // フレネルアルファ
                float maxValue = max( baseAlpha * _AL_Power, _AL_Fresnel ) * _AL_CustomValue;
                float fa = 1 - abs( dot( ws_normal, ws_viewdir ) );
                color.a = lerp( color.a, maxValue, fa * fa * fa * fa );
            #endif
        }
    #else
        #define affectAlphaMask(uv, color)                                      color.a = 1.0
        #define affectFresnelAlpha(uv, ws_normal, ws_viewdir, baseAlpha, color)	color.a = 1.0
    #endif

    ////////////////////////////
    // Anti Glare & Light Configuration
    ////////////////////////////

    #define LIT_MODE_AUTO               0
    #define LIT_MODE_ONLY_DIR_LIT       1
    #define LIT_MODE_ONLY_POINT_LIT     2
    #define LIT_MODE_CUSTOM_WORLDSPACE  3
    #define LIT_MODE_CUSTOM_LOCALSPACE  4

    inline uint calcAutoSelectMainLight(float3 ws_vertex) {
        float3 pointLight1Color = samplePoint1LightColor(ws_vertex);

        if (calcBrightness(sampleMainLightColor()) < calcBrightness(pointLight1Color)) {
            // ディレクショナルよりポイントライトのほうが明るいならばそちらを採用
            return LIT_MODE_ONLY_POINT_LIT;

        } else if (any(getMainLightDirection())) {
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
            return UnityObjectToWorldPos(ZERO_VEC3);
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
            return float4( getMainLightDirection() , +1 );
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
        return TGL_ON(-lightType) ? samplePoint1LightColor(ws_vertex) : sampleMainLightColor();
    }

    inline void affectAntiGlare(float glLevel, inout float4 color) {
        color.rgb = saturate(color.rgb * glLevel);
    }

    inline float3 calcLightColorVertex(float3 ws_vertex, float3 ambientColor) {
        float3 lightColorMain = sampleMainLightColor();
        float3 lightColorSub4 = sampleAdditionalLightColor(ws_vertex);

        float3 color = NON_ZERO_VEC3(lightColorMain + lightColorSub4 + ambientColor);   // 合成
        float power = AVE_RGB(color);                                       // 明度
        color = lerp( power.xxx, color, _GL_BlendPower);                    // 色の混合
        color = saturate( color / AVE_RGB(color) );                         // 正規化
        color = color * lerp(saturate(power / NON_ZERO_FLOAT(_GL_LevelMax)), 1, _GL_LevelMin);  // アンチグレア
        return color;
    }

    inline float calcAngleLightCamera(float3 ws_vertex, float3 ws_light_dir) {
        if (TGL_ON(_GL_DisableBackLit)) {
            return 0;
        }
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float2 xz_camera_pos = worldSpaceViewPointPos().xz - calcWorldSpaceBasePos(ws_vertex).xz;
        float angle_light_camera = dot( SafeNormalizeVec2(ws_light_dir.xz), SafeNormalizeVec2(xz_camera_pos) )
            * (1 - smoothstep(0.9, 1, abs(ws_light_dir.y))) * smoothstep(0, 1, length(xz_camera_pos) * 3);
        return angle_light_camera;
    }

    ////////////////////////////
    // Color Change
    ////////////////////////////

    #ifdef _CL_ENABLE
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

    #ifdef _ES_SIMPLE_ENABLE
        #define calcEmissiveWaving(ws_vertex)   (1)
    #else
        inline float calcEmissiveWaving(float3 ws_vertex) {
            if (_ES_Shape == 3) {
                // 定数
                return saturate(1 + _ES_LevelOffset);
            }
            // 周期 2PI、値域 [-1, +1] の関数で光量を決める
            float time = _Time.y * _ES_Speed - dot( _ES_DirType == 0 ? ws_vertex : UnityWorldToObjectPos(ws_vertex), _ES_Direction.xyz);
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

                #if !defined(_ES_SIMPLE_ENABLE) && !defined(_WF_ALPHA_CUTOUT)
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

    float smoothnessToSpecularPower(float3 ws_camera_dir, float3 ws_normal, float3 ws_light_dir, float smoothness) {
        float roughness     = (1 - smoothness) * (1 - smoothness);
        float3 halfVL       = normalize(ws_camera_dir + ws_light_dir);
        float NdotH         = max(0, dot( ws_normal, halfVL ));
        return max(0, GGXTerm(NdotH, roughness));
    }

    #ifdef _MT_ENABLE

        inline float3 pickReflection(float3 ws_vertex, float3 ws_normal, float smoothness) {
            float metal_lod = (1 - smoothness) * 10;
#ifdef _WF_MOBILE
            return pickReflectionProbe(ws_vertex, ws_normal, metal_lod).rgb;
#else
            float3 color = ZERO_VEC3;
            // ONLYでなければ PROBE を加算
            if (_MT_CubemapType != 2) {
                color += pickReflectionProbe(ws_vertex, ws_normal, metal_lod).rgb;
            }
            // OFFでなければ SECOND_MAP を加算
            if (_MT_CubemapType != 0) {
                float3 cubemap = pickReflectionCubemap(_MT_Cubemap, _MT_Cubemap_HDR, ws_vertex, ws_normal, metal_lod);
                color += lerp(cubemap, pow(max(ZERO_VEC3, cubemap), NON_ZERO_FLOAT(1 - _MT_CubemapHighCut)), step(ONE_VEC3, cubemap)) * _MT_CubemapPower;
            }
            return color;
#endif
        }

        inline float3 pickSpecular(float3 ws_camera_dir, float3 ws_normal, float3 ws_light_dir, float3 spec_color, float smoothness) {
            return spec_color * smoothnessToSpecularPower(ws_camera_dir, ws_normal, ws_light_dir, smoothness);
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
                        specular = pickSpecular(ws_camera_dir, ws_metal_normal, i.ws_light_dir.xyz, i.light_color.rgb * color.rgb, metallicSmoothness.y * _MT_SpecSmooth);
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

        inline void affectMatcapColor(float2 matcapVector, float2 uv_main, inout float4 color) {
            if (TGL_ON(_HL_Enable)) {
                // matcap サンプリング
                float2 matcap_uv = matcapVector.xy * 0.5 + 0.5;
                float3 matcap_color = PICK_MAIN_TEX2D(_HL_MatcapTex, saturate(matcap_uv)).rgb;
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
    // Lame
    ////////////////////////////

    #ifdef _LM_ENABLE

        float random1(float2 st) {  // float2 -> float [0-1)
            return frac(sin(dot(st ,float2(12.9898, 78.233))) * 43758.5453);
        }

        float2 random2(float2 st) { // float2 -> float2 [0-1)
            float2 ret = 0;
            ret.x = random1(st);
            ret.y = random1(st + ret);
            return ret;
        }

        float3 random3(float2 st) { // float2 -> float3 [0-1)
            float3 ret = 0;
            ret.x = random1(st);
            ret.y = random1(st + ret.xy);
            ret.z = random1(st + ret.xy);
            return ret;
        }

        void affectLame(v2f i, float2 uv_main, float3 ws_normal, inout float4 color) {
            if (TGL_ON(_LM_Enable)) {
                float power = WF_TEX2D_LAME_MASK(uv_main);
                if (0 < power) {
                    float   scale = NON_ZERO_FLOAT(_LM_Scale) / 100;
                    float2  st = uv_main / scale;

                    float2  ist = floor(st);
                    float2  fst = frac(st);
                    float3  min_pos = float3(0, 0, 5);

                    for (int y = -1; y <= 1; y++) {
                        for (int x = -1; x <= 1; x++) {
                            float2 neighbor = float2(x, y);
                            float3 pos;
                            pos.xy  = 0.5 + 0.5 * sin( random2((ist + neighbor) * scale) * 2 - 1 );
                            pos.z   = length(neighbor + pos.xy - fst);
                            min_pos = pos.z < min_pos.z ? pos : min_pos;
                        }
                    }

                    float3 ws_camera_vec = worldSpaceCameraVector(i.ws_vertex);

                    // アニメーション項
                    power *= _LM_AnimSpeed < NZF ? 1 : sin(frac(_Time.y * _LM_AnimSpeed + random1(min_pos.yx)) * UNITY_TWO_PI) / 2 + 0.5;
                    // Glitter項
                    power = lerp(power, max(power, pow(power + 0.1, 32)), _LM_Glitter);
                    // 密度項
                    power *= step(1 - _LM_Dencity / 4, abs(min_pos.x));
                    // フレークのばらつき項
                    power *= random1(min_pos.xy);
                    // 距離フェード項
                    power *= 1 - smoothstep(_LM_MinDist, _LM_MinDist + 1, length(ws_camera_vec));
                    // NdotV起因の強度項
                    power *= pow(abs(dot(normalize(ws_camera_vec), ws_normal)), NON_ZERO_FLOAT(_LM_Spot));
                    // 形状
                    power *= _LM_Shape == 0 ? 1 : step(min_pos.z, 0.2); // 通常の多角形 or 点

                    float3 lame_color = _LM_Color.rgb;
                    lame_color *= WF_TEX2D_LAME_TEX(uv_main);
                    lame_color += _LM_RandColor * (random3(min_pos.xy) * 2 - 1);

                    color.rgb += max(ZERO_VEC3, lame_color) * power;
                }
            }
        }
    #else
        #define affectLame(i, uv_main, ws_normal, color)
    #endif

    ////////////////////////////
    // ToonShade
    ////////////////////////////

    #ifdef _TS_ENABLE

        inline void calcToonShadeContrast(float3 ws_vertex, float4 ws_light_dir, float3 ambientColor, out float shadow_power) {
            if (TGL_ON(_TS_Enable)) {
                float3 lightColorMain = calcWorldSpaceLightColor(ws_vertex, ws_light_dir.w);
                float3 lightColorSub4 = 0 < ws_light_dir.w ? sampleAdditionalLightColor(ws_vertex) : sampleAdditionalLightColorExclude1(ws_vertex);

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
                // 3影
#ifdef _TS_TRISHADE_ENABLE
                calcShadowColor(_TS_3rdColor, WF_TEX2D_SHADE_3RD(uv_main), base_color, i.shadow_power, _TS_3rdBorder, brightness, shadow_color);
#endif
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
                : _OL_BlendType == 6 ? lerp(2 * color * ov_color.rgb, 1 - 2 * (1 - color) * (1 - ov_color.rgb), step(calcBrightness(ov_color.rgb), 0.5))   // オーバーレイ
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
                color.rgb = blendOverlayColor(color.rgb, PICK_MAIN_TEX2D(_OL_OverlayTex, uv_overlay) * _OL_Color, power);
            }
        }
    #else
        #define affectOverlayTexture(i, uv_main, vs_normal, color)
    #endif

    ////////////////////////////
    // Outline
    ////////////////////////////

    #ifdef _TL_ENABLE

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
            #ifndef _WF_ALPHA_CUTOUT
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

    float4 shiftDepthVertex(float3 ws_vertex, float width) { // これは複数箇所から使うので _TL_ENABLE には入れない
        // ワールド座標でのカメラ方向と距離を計算
        float3 ws_camera_dir = _WorldSpaceCameraPos - ws_vertex; // ワールド座標で計算する。理由は width をモデルスケール非依存とするため。
        // カメラ方向の z シフト量を加算
        float3 zShiftVec = SafeNormalizeVec3(ws_camera_dir) * min(width, length(ws_camera_dir) * 0.5);

        float4 vertex;
        if (unity_OrthoParams.w < 0.5) {
            // カメラが perspective のときは単にカメラ方向にシフトする
            vertex = UnityWorldToClipPos( ws_vertex + zShiftVec );
        } else {
            // カメラが orthographic のときはシフト後の z のみ採用する
            vertex = UnityWorldToClipPos( ws_vertex );
            vertex.z = UnityWorldToClipPos( ws_vertex + zShiftVec ).z;
        }
        return vertex;
    }

    float4 shiftOutlineVertex(inout float3 ws_vertex, float3 ws_normal, float width, float shift) {
        #ifdef _TL_ENABLE
        if (TGL_ON(_TL_Enable)) {
            // 外側にシフトする
            ws_vertex.xyz += ws_normal * width;
            // Zシフト
            return shiftDepthVertex(ws_vertex, shift);
        } else {
            return UnityObjectToClipPos( ZERO_VEC3 );
        }
        #else
            return UnityObjectToClipPos( ZERO_VEC3 );
        #endif
    }

    ////////////////////////////
    // Ambient Occlusion
    ////////////////////////////

    #ifdef _AO_ENABLE

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

    inline float3 calcAmbientColorVertex(float2 uv_lmap) {
        // ライトマップもしくは環境光を取得
        #ifdef _LMAP_ENABLE
            float3 color = pickLightmapLod(uv_lmap);
            #if defined(_AO_ENABLE)
            if (TGL_ON(_AO_Enable)) {
                // ライトマップが使えてAOが有効の場合は、AO側で色を合成するので明るさだけ取得する
                return AVE_RGB(color).xxx;
            }
            #endif
            return color;
        #else
            return sampleSHLightColor();
        #endif
    }

    ////////////////////////////
    // Fog
    ////////////////////////////

    #ifdef _FG_ENABLE

        inline void affectToonFog(v2f i, float3 ws_view_dir, inout float4 color) {
            if (TGL_ON(_FG_Enable)) {
                float3 ws_base_position = UnityObjectToWorldPos(_FG_BaseOffset);
                float3 ws_offset_vertex = (i.ws_vertex - ws_base_position) / max(float3(NZF, NZF, NZF), _FG_Scale);
                float power = 
                    // 原点からの距離の判定
                    smoothstep(_FG_MinDist, max(_FG_MinDist + 0.0001, _FG_MaxDist), length( ws_offset_vertex ))
                    // 前後の判定
                    * smoothstep(0, 0.2, -dot(ws_view_dir.xz, ws_offset_vertex.xz))
                    // カメラと原点の水平距離の判定
                    * smoothstep(_FG_MinDist, max(_FG_MinDist + 0.0001, _FG_MaxDist), length( ws_base_position.xz - worldSpaceViewPointPos().xz ));
                color.rgb = lerp(color.rgb, _FG_Color.rgb * i.light_color, _FG_Color.a * pow(power, _FG_Exponential));
            }
        }
    #else
        #define affectToonFog(i, ws_view_dir, color)
    #endif

#endif
