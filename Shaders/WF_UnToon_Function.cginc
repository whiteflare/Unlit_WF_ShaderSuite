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

#ifndef INC_UNLIT_WF_UNTOON_FUNCTION
#define INC_UNLIT_WF_UNTOON_FUNCTION

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
        #define WF_TEX2D_EMISSION(uv)           PICK_SUB_TEX2D(_EmissionMap, _MainTex, uv).rgba
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
            #define WF_TEX2D_METAL_GLOSS(uv)    (SAMPLE_MASK_VALUE(_MetallicGlossMap, uv, _MT_InvMaskVal).rgba * float4(1, 1, 1, 1 - SAMPLE_MASK_VALUE(_SpecGlossMap, uv, _MT_InvRoughnessMaskVal).r))
        #else
            #define WF_TEX2D_METAL_GLOSS(uv)    SAMPLE_MASK_VALUE(_MetallicGlossMap, uv, _MT_InvMaskVal).rgba
        #endif
    #endif

    #ifndef WF_TEX2D_MATCAP_MASK
        #define WF_TEX2D_MATCAP_MASK(uv)        SAMPLE_MASK_VALUE(_HL_MaskTex, uv, _HL_InvMaskVal).rgb
    #endif

    #ifndef WF_TEX2D_LAME_TEX
        #define WF_TEX2D_LAME_TEX(uv)           PICK_SUB_TEX2D(_LM_Texture, _MainTex, uv).rgba
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
        #define WF_TEX2D_SCREEN_MASK(uv)        SAMPLE_MASK_VALUE(_OL_MaskTex, uv, _OL_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_OUTLINE_COLOR
        #define WF_TEX2D_OUTLINE_COLOR(uv)      PICK_SUB_TEX2D(_TL_CustomColorTex, _MainTex, uv).rgb
    #endif

    #ifndef WF_TEX2D_OUTLINE_MASK
        #ifndef _WF_LEGACY_TL_MASK
            #define WF_TEX2D_OUTLINE_MASK(uv)   SAMPLE_MASK_VALUE_LOD(_TL_MaskTex, uv, _TL_InvMaskVal).r
        #else
            #define WF_TEX2D_OUTLINE_MASK(uv)   SAMPLE_MASK_VALUE(_TL_MaskTex, uv, _TL_InvMaskVal).r
        #endif
    #endif

    #ifndef WF_TEX2D_OCCLUSION
        #define WF_TEX2D_OCCLUSION(uv)          SAMPLE_MASK_VALUE(_OcclusionMap, uv, 0).rgb
    #endif

    ////////////////////////////
    // Base Color
    ////////////////////////////

    void affectMainTex(float2 uv, out float2 uv_main, inout float4 color) {
        uv_main = TRANSFORM_TEX(uv, _MainTex);
        color *= PICK_MAIN_TEX2D(_MainTex, uv_main);
    }

    #ifdef _BK_ENABLE
        void affectBackTex(float2 uv, uint facing, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_BK_Enable) && !facing) {
#else
            if (!facing) {
#endif
                float2 uv_back = TRANSFORM_TEX(uv, _BK_BackTex);
                color = PICK_MAIN_TEX2D(_BK_BackTex, uv_back) * _BK_BackColor;
            }
        }
    #else
        #define affectBackTex(uv, facing, color)
    #endif

    void affectBaseColor(float2 uv, uint facing, out float2 uv_main, out float4 color) {
        color = _Color;
        // メイン
        affectMainTex(uv, uv_main, color);
        // バック
        affectBackTex(uv, facing, color);
    }

    #ifdef _VC_ENABLE
        void affectVertexColor(float4 vertex_color, inout float4 color) {
            color *= lerp(ONE_VEC4, vertex_color, _UseVertexColor);
        }
    #else
        #define affectVertexColor(vertex_color, color)
    #endif

    ////////////////////////////
    // Alpha Transparent
    ////////////////////////////

    #if defined(_WF_ALPHA_BLEND) || defined(_WF_ALPHA_FRESNEL) || defined(_WF_ALPHA_CUSTOM)
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

        float pickAlpha(float2 uv, float alpha) {
            return _AL_Source == 1 ? WF_TEX2D_ALPHA_MASK_RED(uv)
                 : _AL_Source == 2 ? WF_TEX2D_ALPHA_MASK_ALPHA(uv)
                 : WF_TEX2D_ALPHA_MAIN_ALPHA(uv);
        }

        void affectAlphaMask(float2 uv, inout float4 color) {
            float alpha = pickAlpha(uv, color.a) * _AL_CustomValue;

            /*
             * カットアウト処理
             * cutoutに使うものは、pickAlpha と _AL_CustomValue の値。
             * 一方、Fresnel は cutout には巻き込まない。
             * _AL_CustomValue を使っている MaskOut_Blend は cutout を使わない。
             */

            #if defined(_WF_ALPHA_CUSTOM)
                _WF_ALPHA_CUSTOM
            #elif defined(_WF_ALPHA_CUTOUT)
                alpha = smoothstep(_Cutoff - 0.0625, _Cutoff + 0.0625, alpha);
                if (TGL_OFF(_AL_AlphaToMask) && alpha < 0.5) {
                    discard;
                }
            #else
                alpha *= _AL_Power;
            #endif

            color.a = alpha;
        }

        void affectFresnelAlpha(float2 uv, float3 ws_normal, float3 ws_viewdir, inout float4 color) {
            #ifdef _WF_ALPHA_FRESNEL
                // フレネルアルファ
                float maxValue = max(color.a, _AL_Fresnel * _AL_CustomValue);
                float fa = 1 - abs( dot( ws_normal, ws_viewdir ) );
                color.a = lerp( color.a, maxValue, fa * fa * fa * fa );
            #endif
        }
    #else
        #define affectAlphaMask(uv, color)                              color.a = 1.0
        #define affectFresnelAlpha(uv, ws_normal, ws_viewdir, color)
    #endif

    ////////////////////////////
    // Anti Glare & Light Configuration
    ////////////////////////////

    #define LIT_MODE_AUTO               0
    #define LIT_MODE_ONLY_DIR_LIT       1
    #define LIT_MODE_ONLY_POINT_LIT     2
    #define LIT_MODE_CUSTOM_WORLDSPACE  3
    #define LIT_MODE_CUSTOM_LOCALSPACE  4

    uint calcAutoSelectMainLight(float3 ws_vertex) {
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

    float3 calcWorldSpaceBasePos(float3 ws_vertex) {
        if (TGL_OFF(_GL_DisableBasePos)) {
            // Object原点をBasePosとして使用する
            return UnityObjectToWorldPos(ZERO_VEC3);
        }
        else {
            // 現在の座標をBasePosとして使用する
            return ws_vertex;
        }
    }

    float4 calcWorldSpaceLightDir(float3 ws_vertex) {
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

    float3 calcWorldSpaceLightColor(float3 ws_vertex, float lightType) {
        return TGL_ON(-lightType) ? samplePoint1LightColor(ws_vertex) : sampleMainLightColor();
    }

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

    float calcAngleLightCamera(float3 ws_vertex, float3 ws_light_dir) {
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
        void affectColorChange(inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_CL_Enable)) {
#endif
                if (TGL_ON(_CL_Monochrome)) {
                    color.r += color.g + color.b;
                    color.g = (color.r - 1) / 2;
                    color.b = (color.r - 1) / 2;
                }
                float3 hsv = rgb2hsv( saturate(color.rgb) );
                hsv += float3( _CL_DeltaH, _CL_DeltaS, _CL_DeltaV);
                hsv.r = frac(hsv.r);
                color.rgb = saturate( hsv2rgb( saturate(hsv) ) );
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }

    #else
        // Dummy
        #define affectColorChange(color)
    #endif

    ////////////////////////////
    // 3ch Color Mask
    ////////////////////////////

    #ifdef _CH_ENABLE

        void affect3chColorMask(float2 mask_uv, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_CH_Enable)) {
#endif
                float3 mask  = WF_TEX2D_3CH_MASK(mask_uv);
                float4 c1 = color * _CH_ColorR;
                float4 c2 = color * _CH_ColorG;
                float4 c3 = color * _CH_ColorB;
                color = lerp(color, c1, mask.r);
                color = lerp(color, c2, mask.g);
                color = lerp(color, c3, mask.b);
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
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
        #define calcEmissiveWaving(i, uv_main)   (1)
    #else
        float calcEmissiveWaving(v2f i, float2 uv_main) {
            if (_ES_Shape == 3) {
                // 定数
                return saturate(1 + _ES_LevelOffset);
            }
            // 周期 2PI、値域 [-1, +1] の関数で光量を決める
            float3 uv =
                    _ES_DirType == 1 ? UnityWorldToObjectPos(i.ws_vertex)   // ローカル座標
                    : _ES_DirType == 2 ? float3(uv_main, 0)                 // UV1
                    : _ES_DirType == 3 ? float3(i.uv_lmap, 0)               // UV2
                    : i.ws_vertex                                           // ワールド座標
                    ;
            float time = _Time.y * _ES_Speed - dot(uv, _ES_Direction.xyz);
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

        void affectEmissiveScroll(v2f i, float2 uv_main, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_ES_Enable)) {
#endif
                float4 es_mask  = WF_TEX2D_EMISSION(uv_main);
                float4 es_color = _EmissionColor * es_mask;
                float waving    = calcEmissiveWaving(i, uv_main) * es_color.a;

                // RGB側の合成
                color.rgb =
                    // 加算合成
                    _ES_BlendType == 0 ? color.rgb + es_color.rgb * waving :
                    // 旧形式のブレンド
                    _ES_BlendType == 1 ? lerp(color.rgb, es_color.rgb, waving * MAX_RGB(es_mask.rgb)) :
                    // ブレンド
                    lerp(color.rgb, es_color.rgb, waving);

                // Alpha側の合成
                #if defined(_WF_ALPHA_BLEND) && !defined(_ES_SIMPLE_ENABLE)
                    #ifdef _ES_FORCE_ALPHASCROLL
                        color.a = max(color.a, waving);
                    #else
                        if (TGL_ON(_ES_AlphaScroll)) {
                            color.a = max(color.a, waving);
                        }
                    #endif
                #endif
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }

    #else
        // Dummy
        #define affectEmissiveScroll(i, uv_main, color)
    #endif

    ////////////////////////////
    // Normal Map
    ////////////////////////////

    #ifdef _NM_ENABLE
        float3 calcBumpNormal(v2f i, float2 uv_main) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_NM_Enable)) {
#endif
                // 1st NormalMap
                float3 normalTangent = WF_TEX2D_NORMAL(uv_main);

#ifndef _WF_MOBILE
                // 2nd NormalMap
                float dtlPower = _NM_2ndType == 0 ? 0 : WF_TEX2D_NORMAL_DTL_MASK(uv_main);
                float3 dtlNormalTangent = _NM_2ndType == 0 ? float3(0, 0, 1) : WF_TEX2D_NORMAL_DTL( TRANSFORM_TEX(i.uv, _DetailNormalMap) );
                if (_NM_2ndType == 1) { // BLEND
                    dtlNormalTangent = BlendNormals(normalTangent, dtlNormalTangent);
                }
                normalTangent = lerp(normalTangent, dtlNormalTangent, dtlPower);
#endif

                // 法線計算
                return transformTangentToWorldNormal(normalTangent, i.normal, i.tangent, i.bitangent); // vertex周辺のworld法線空間

#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
            else {
                return i.normal;
            }
#endif
        }

        void affectBumpNormal(v2f i, float2 uv_main, out float3 ws_bump_normal, inout float4 color) {
            // bump_normal 計算
            ws_bump_normal = calcBumpNormal(i, uv_main);

#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_NM_Enable)) {
#endif
                // NormalMap は陰影として描画する
                // 影側を暗くしすぎないために、ws_normal と ws_bump_normal の差を加算することで明暗を付ける
                color.rgb += (dot(ws_bump_normal, i.ws_light_dir.xyz) - dot(i.normal, i.ws_light_dir.xyz)) * _NM_Power;
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
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

        float3 pickReflection(float3 ws_vertex, float3 ws_normal, float smoothness) {
            float metal_lod = (1 - smoothness) * 10;
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
        }

        float3 pickSpecular(float3 ws_camera_dir, float3 ws_normal, float3 ws_light_dir, float3 spec_color, float smoothness) {
            return spec_color * smoothnessToSpecularPower(ws_camera_dir, ws_normal, ws_light_dir, smoothness);
        }

        void affectMetallic(v2f i, float3 ws_camera_dir, float2 uv_main, float3 ws_normal, float3 ws_bump_normal, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_MT_Enable)) {
#endif
                float metallic = _MT_Metallic;
                float monochrome = _MT_Monochrome;
                float4 metalGlossMap = WF_TEX2D_METAL_GLOSS(uv_main);

                // MetallicSmoothness をパラメータに反映
                if (_MT_MetallicMapType == 0) {
                    // Metallic強度に反映する方式
                    metallic *= metalGlossMap.r;
                }
                else if (_MT_MetallicMapType == 1) {
                    // Metallic強度を固定して、モノクロ反射に反映する方式
                    monochrome = saturate(1 - (1 - monochrome) * metalGlossMap.r);
                }

                // Metallic描画
                if (0.01 < metallic) {
                    float3 ws_metal_normal = normalize(lerp(ws_normal, ws_bump_normal, _MT_BlendNormal));
                    float reflSmooth = metalGlossMap.a * _MT_ReflSmooth;
                    float specSmooth = metalGlossMap.a * _MT_SpecSmooth;

                    if (TGL_ON(_MT_GeomSpecAA)) {
                        float3 normal_ddx = ddx(ws_metal_normal);
                        float3 normal_ddy = ddy(ws_metal_normal);
                        float geom_roughness = pow(saturate(max(dot(normal_ddx, normal_ddx), dot(normal_ddy, normal_ddy))), 0.333);
                        reflSmooth = min(reflSmooth, 1.0 - geom_roughness);
                        specSmooth = min(specSmooth, 1.0 - geom_roughness);
                    }

                    // リフレクション
                    float3 reflection = pickReflection(i.ws_vertex, ws_metal_normal, reflSmooth);
                    reflection = lerp(reflection, calcBrightness(reflection).xxx, monochrome);

                    // スペキュラ
                    float3 specular = ZERO_VEC3;
                    if (0.01 < _MT_Specular) {
                        specular = pickSpecular(ws_camera_dir, ws_metal_normal, i.ws_light_dir.xyz, i.light_color.rgb * color.rgb, specSmooth);
                    }

                    // 合成
                    color.rgb = lerp(
                        color.rgb,
                        lerp(color.rgb * reflection.rgb, color.rgb + reflection.rgb, _MT_Brightness) + specular.rgb * _MT_Specular,
                        metallic);
                }
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }
    #else
        #define affectMetallic(i, ws_camera_dir, uv_main, ws_normal, ws_bump_normal, color)
    #endif

    ////////////////////////////
    // Light Matcap
    ////////////////////////////

    #ifdef _HL_ENABLE

        void affectMatcapColor(float2 matcapVector, float2 uv_main, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_HL_Enable)) {
#endif
                // matcap サンプリング
                float2 matcap_uv = matcapVector.xy * 0.5 + 0.5;
                float3 matcap_color = PICK_MAIN_TEX2D(_HL_MatcapTex, saturate(matcap_uv)).rgb;

                // マスク参照
                float3 matcap_mask = WF_TEX2D_MATCAP_MASK(uv_main);
                // 色調整前のマスクを元に強度を計算
                float power = _HL_Power * MAX_RGB(matcap_mask);
                // マスク色調整
                float3 matcap_mask_color = matcap_mask * _HL_MatcapColor * 2;

                // 色合成
                if (_HL_CapType == 1) {
                    // 加算合成
                    matcap_color *= LinearToGammaSpace(matcap_mask_color);
                    color.rgb = blendColor_Add(color.rgb, matcap_color, power);
                } else if(_HL_CapType == 2) {
                    // 乗算合成
                    matcap_color *= LinearToGammaSpace(matcap_mask_color);
                    color.rgb = blendColor_Mul(color.rgb, matcap_color, power);
                } else {
                    // 中間色合成
                    matcap_color -= _HL_MedianColor;
                    float3 lighten_color = max(ZERO_VEC3, matcap_color);
                    float3 darken_color  = min(ZERO_VEC3, matcap_color);
                    matcap_color = lerp(darken_color, lighten_color, matcap_mask_color);
                    color.rgb = blendColor_Add(color.rgb, matcap_color, power);
                }
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
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
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_LM_Enable)) {
#endif
                float power = WF_TEX2D_LAME_MASK(uv_main);
                if (0 < power) {
                    float2 uv_lame = _LM_UVType == 1 ? i.uv_lmap : i.uv;
                    uv_lame = TRANSFORM_TEX(uv_lame, _LM_Texture);

                    float   scale = NON_ZERO_FLOAT(_LM_Scale) / 100;
                    float2  st = uv_lame / scale;

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

                    min_pos.xy = round(min_pos.xy * 10) / 10; // ◆◇◆ ちらつき低減のテスト中 ◆◇◆

                    // アニメーション項
                    power *= _LM_AnimSpeed < NZF ? 1 : sin(frac(_Time.y * _LM_AnimSpeed + random1(min_pos.yx)) * UNITY_TWO_PI) / 2 + 0.5;
                    // Glitter項
                    power = lerp(power, max(power, pow(power + 0.1, 32)), _LM_Glitter);
                    // 密度項
                    power *= step(1 - _LM_Dencity / 4, abs(min_pos.x));
                    // フレークのばらつき項
                    power *= random1(min_pos.xy);
                    // 距離フェード項
                    power *= 1 - smoothstep(_LM_MinDist, max(_LM_MinDist + NZF, _LM_MaxDist), length(ws_camera_vec));
                    // NdotV起因の強度項
                    power *= pow(abs(dot(normalize(ws_camera_vec), ws_normal)), NON_ZERO_FLOAT(_LM_Spot));
                    // 形状
                    power *= _LM_Shape == 0 ? 1 : step(min_pos.z, 0.2); // 通常の多角形 or 点

                    float4 lame_color = _LM_Color * WF_TEX2D_LAME_TEX(uv_lame);
                    lame_color.rgb += _LM_RandColor * (random3(min_pos.xy) * 2 - 1);

                    color.rgb += max(ZERO_VEC3, lame_color.rgb) * power;
                    #ifdef _WF_ALPHA_BLEND
                        color.a = max(color.a, lerp(color.a, lame_color.a, saturate(power * _LM_ChangeAlpha)));
                    #endif
                }
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }
    #else
        #define affectLame(i, uv_main, ws_normal, color)
    #endif

    ////////////////////////////
    // ToonShade
    ////////////////////////////

    #ifdef _TS_ENABLE

        void calcToonShadeContrast(float3 ws_vertex, float4 ws_light_dir, float3 ambientColor, out float shadow_power) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_TS_Enable)) {
#endif
                float3 lightColorMain = calcWorldSpaceLightColor(ws_vertex, ws_light_dir.w);
                float3 lightColorSub4 = 0 < ws_light_dir.w ? sampleAdditionalLightColor(ws_vertex) : sampleAdditionalLightColorExclude1(ws_vertex);

                float main = saturate(calcBrightness( lightColorMain ));
                float sub4 = saturate(calcBrightness( lightColorSub4 ));
                float ambient = saturate(calcBrightness( ambientColor ));
                shadow_power = saturate( abs(main - sub4) / max(main + sub4, 0.0001) ) * 0.5 + 0.5;
                shadow_power = min( shadow_power, 1 - smoothstep(0.8, 1, abs(ws_light_dir.y)) * 0.5 );
                shadow_power = min( shadow_power, 1 - saturate(ambient) * 0.5 );
#ifdef _WF_LEGACY_FEATURE_SWITCH
            } else {
                shadow_power = 0;
            }
#endif
        }

        void calcShadowColor(float3 color, float3 shadow_tex, float3 base_color, float power, float border, float brightness, inout float3 shadow_color) {
            shadow_color = lerp(
                max(ZERO_VEC3, lerp(ONE_VEC3, color.rgb * shadow_tex / base_color, power * _TS_Power)),
                shadow_color,
                smoothstep(border, border + max(_TS_Feather, 0.001), brightness) );
        }

        void affectToonShade(v2f i, float2 uv_main, float3 ws_normal, float3 ws_bump_normal, float angle_light_camera, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_TS_Enable)) {
#endif
                if (isInMirror()) {
                    angle_light_camera = 0; // 鏡の中のときは、視差問題が生じないように強制的に 0 にする
                }

                // 陰用法線とライト方向から Harf-Lambert
                float3 ws_shade_normal = normalize(lerp(ws_normal, ws_bump_normal, _TS_BlendNormal));
                float brightness = lerp(dot(ws_shade_normal, i.ws_light_dir.xyz), 1, 0.5);  // 0.0 ～ 1.0

                // アンチシャドウマスク加算
                float anti_shade = WF_TEX2D_SHADE_MASK(uv_main);
                brightness = lerp(brightness, lerp(brightness, 1, 0.5), anti_shade);
                // ビュー相対位置シフト
                brightness *= smoothstep(-1.01, -1.0 + (_TS_1stBorder + _TS_2ndBorder) / 2, angle_light_camera);

                // 影色計算
                float3 base_color = NON_ZERO_VEC3( _TS_BaseColor.rgb * WF_TEX2D_SHADE_BASE(uv_main) );
                float3 shadow_color = ONE_VEC3;

                if (_TS_Steps == 1) {
                    // 1影まで
                    calcShadowColor(_TS_1stColor, WF_TEX2D_SHADE_1ST(uv_main), base_color, i.shadow_power, _TS_1stBorder, brightness, shadow_color);
                }
                else if (_TS_Steps == 3) {
                    // 3影まで
                    calcShadowColor(_TS_1stColor, WF_TEX2D_SHADE_1ST(uv_main), base_color, i.shadow_power, _TS_1stBorder, brightness, shadow_color);
                    calcShadowColor(_TS_2ndColor, WF_TEX2D_SHADE_2ND(uv_main), base_color, i.shadow_power, _TS_2ndBorder, brightness, shadow_color);
                    calcShadowColor(_TS_3rdColor, WF_TEX2D_SHADE_3RD(uv_main), base_color, i.shadow_power, _TS_3rdBorder, brightness, shadow_color);
                }
                else {
                    // 2影まで
                    calcShadowColor(_TS_1stColor, WF_TEX2D_SHADE_1ST(uv_main), base_color, i.shadow_power, _TS_1stBorder, brightness, shadow_color);
                    calcShadowColor(_TS_2ndColor, WF_TEX2D_SHADE_2ND(uv_main), base_color, i.shadow_power, _TS_2ndBorder, brightness, shadow_color);
                }

                // 乗算
                color.rgb *= shadow_color;
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }
    #else
        #define calcToonShadeContrast(ws_vertex, ws_light_dir, ambientColor, shadow_power)
        #define affectToonShade(i, uv_main, ws_normal, ws_bump_normal, angle_light_camera, color)
    #endif

    ////////////////////////////
    // Rim Light
    ////////////////////////////

    #ifdef _TR_ENABLE

        float calcRimLightPower(float3 vs_normal) {
            float side      = _TR_Power * _TR_PowerSide;
            float top       = _TR_Power * _TR_PowerTop;
            float bottom    = _TR_Power * _TR_PowerBottom;

            float3x3 mat = 0;
            mat[0][0] = side + 1;
            mat[1][1] = (top + bottom) / 2 + 1;
            mat[1][2] = (top - bottom) / 2;

            float2 rim_uv = mul(mat, float3(vs_normal.xy, 1)).xy;

            return smoothstep(-NZF, _TR_Feather, length(rim_uv) - 1);
        }

        float3 calcRimLightColor(float3 color) {
            float3 rimColor = _TR_Color.rgb - (
                    _TR_BlendType == 0 ? MEDIAN_GRAY    // ADD_AND_SUB
                    : _TR_BlendType == 1 ? color        // ALPHA
                    : ZERO_VEC3                         // ADD
                );
            return rimColor;
        }

        void affectRimLight(v2f i, float2 uv_main, float3 vs_normal, float angle_light_camera, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_TR_Enable)) {
#endif
                if (isInMirror()) {
                    angle_light_camera = 0; // 鏡の中のときは、視差問題が生じないように強制的に 0 にする
                }
                // 順光の場合はリムライトを暗くする
                float3 rimPower = saturate(0.8 - angle_light_camera) * WF_TEX2D_RIM_MASK(uv_main);
                // 色計算
                float3 rimColor = calcRimLightColor(color.rgb);
                // 合成
                color.rgb = lerp(color.rgb, color.rgb + rimColor * rimPower, calcRimLightPower(vs_normal));
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
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

        float3 blendOverlayColor(float3 base, float4 decal, float power) {
            power *= decal.a;
            return
                  _OL_BlendType == 0 ? blendColor_Alpha(base, decal.rgb, power)
                : _OL_BlendType == 1 ? blendColor_Add(base, decal.rgb, power)
                : _OL_BlendType == 2 ? blendColor_Mul(base, decal.rgb, power)
                : _OL_BlendType == 3 ? blendColor_AddAndSub(base, decal.rgb, power)
                : _OL_BlendType == 4 ? blendColor_Screen(base, decal.rgb, power)
                : _OL_BlendType == 5 ? blendColor_Overlay(base, decal.rgb, power)
                : _OL_BlendType == 6 ? blendColor_HardLight(base, decal.rgb, power)
                : base  // 何もしない
                ;
        }

        void affectOverlayTexture(v2f i, float2 uv_main, float3 vs_normal, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_OL_Enable)) {
#endif
                float2 uv_overlay =
                    _OL_UVType == 1 ? i.uv_lmap                                                 // UV2
                    : _OL_UVType == 2 ? computeOverlayTex(i.ws_vertex)                          // SKYBOX
                    : _OL_UVType == 3 ? computeAngelRingUV(vs_normal, i.uv_lmap)                // ANGELRING
                    : _OL_UVType == 4 ? vs_normal.xy / 2 + 0.5                                  // MATCAP
                    : i.uv                                                                      // UV1
                    ;
                uv_overlay = TRANSFORM_TEX(uv_overlay, _OL_OverlayTex);
                float4 ov_color = PICK_MAIN_TEX2D(_OL_OverlayTex, uv_overlay) * _OL_Color;
                float ov_power = _OL_Power * WF_TEX2D_SCREEN_MASK(uv_main);

                // 頂点カラーを加味
                ov_color *= lerp(ONE_VEC4, i.vertex_color, _OL_VertColToDecal);
                ov_power *= lerp(1, saturate(TGL_OFF(_OL_InvMaskVal) ? i.vertex_color.r : 1 - i.vertex_color.r), _OL_VertColToMask);

                color.rgb = blendOverlayColor(color.rgb, ov_color, ov_power);
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }
    #else
        #define affectOverlayTexture(i, uv_main, vs_normal, color)
    #endif

    ////////////////////////////
    // Outline
    ////////////////////////////

    #ifdef _TL_ENABLE

        float getOutlineShiftWidth(float2 uv_main) {
            #ifndef _WF_LEGACY_TL_MASK
                // マスクをシフト時に太さに反映する場合
                float mask = WF_TEX2D_OUTLINE_MASK(uv_main);
            #else
                // マスクをfragmentでアルファに反映する場合
                float mask = 1;
            #endif
            return _TL_LineWidth * 0.01 * mask;
        }

        void affectOutline(float2 uv_main, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_TL_Enable)) {
#endif
                // アウトライン色をカスタムカラーと合成
                float3 line_color = lerp(_TL_LineColor.rgb, WF_TEX2D_OUTLINE_COLOR(uv_main), _TL_BlendCustom);
                // アウトライン色をベースと合成
                color.rgb = lerp(line_color, color.rgb, _TL_BlendBase);

                // アウトラインアルファを反映
                #ifdef _WF_ALPHA_BLEND
                    #ifndef _WF_LEGACY_TL_MASK
                        // マスクをシフト時に太さに反映する場合
                        color.a = _TL_LineColor.a;
                    #else
                        // マスクをfragmentでアルファに反映する場合
                        float mask = WF_TEX2D_OUTLINE_MASK(uv_main);
                        if (mask < 0.1) {
                            color.a = 0;
                            discard;
                        } else {
                            color.a = _TL_LineColor.a * mask;
                        }
                    #endif
                #endif
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }

    #else
        #define affectOutline(uv_main, color)
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
#ifdef _WF_LEGACY_FEATURE_SWITCH
        if (TGL_ON(_TL_Enable)) {
#endif
            // 外側にシフトする
            ws_vertex.xyz += ws_normal * width;
            // Zシフト
            return shiftDepthVertex(ws_vertex, shift);
#ifdef _WF_LEGACY_FEATURE_SWITCH
        } else {
            return UnityObjectToClipPos( ZERO_VEC3 );
        }
#endif
        #else
            return UnityObjectToClipPos( ZERO_VEC3 );
        #endif
    }

    ////////////////////////////
    // Ambient Occlusion
    ////////////////////////////

    #ifdef _AO_ENABLE

        void affectOcclusion(v2f i, float2 uv_main, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_AO_Enable)) {
#endif
                float3 occlusion = ONE_VEC3;
#ifndef _WF_MOBILE
                float2 uv_aomap = _AO_UVType == 1 ? i.uv_lmap : uv_main;
                occlusion *= WF_TEX2D_OCCLUSION(uv_aomap);
                occlusion = blendColor_Screen(occlusion, _AO_TintColor.rgb, _AO_TintColor.a);
#endif
                #ifdef _LMAP_ENABLE
                if (TGL_ON(_AO_UseLightMap)) {
                    occlusion *= pickLightmap(i.uv_lmap);
                }
                #endif
                occlusion = lerp(AVE_RGB(occlusion).xxx, occlusion, _GL_BlendPower); // 色の混合
                occlusion = (occlusion - 1) * _AO_Contrast + 1 + _AO_Brightness;
                color.rgb *= max(ZERO_VEC3, occlusion.rgb);
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
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
    // Fog
    ////////////////////////////

    #ifdef _FG_ENABLE

        void affectToonFog(v2f i, float3 ws_view_dir, inout float4 color) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_ON(_FG_Enable)) {
#endif
                float3 ws_base_position = UnityObjectToWorldPos(_FG_BaseOffset);
                float3 ws_offset_vertex = (i.ws_vertex - ws_base_position) / max(float3(NZF, NZF, NZF), _FG_Scale);
                float power =
                    // 原点からの距離の判定
                    smoothstep(_FG_MinDist, max(_FG_MinDist + NZF, _FG_MaxDist), length( ws_offset_vertex ))
                    // 前後の判定
                    * smoothstep(0, 0.2, -dot(ws_view_dir.xz, ws_offset_vertex.xz))
                    // カメラと原点の水平距離の判定
                    * smoothstep(_FG_MinDist, max(_FG_MinDist + NZF, _FG_MaxDist), length( ws_base_position.xz - worldSpaceViewPointPos().xz ));
                color.rgb = lerp(color.rgb, _FG_Color.rgb * i.light_color, _FG_Color.a * pow(power, _FG_Exponential));
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
        }
    #else
        #define affectToonFog(i, ws_view_dir, color)
    #endif

#endif
