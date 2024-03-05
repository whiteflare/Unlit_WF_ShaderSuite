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
        #define WF_TEX2D_3CH_MASK(uv)           PICK_SUB_TEX2D(_CHM_3chMaskTex, _MainTex, uv).rgb
    #endif

    #ifndef WF_TEX2D_GRADMAP
        #define WF_TEX2D_GRADMAP(uv)            PICK_MAIN_TEX2D(_CGR_GradMapTex, uv)
    #endif
    #ifndef WF_TEX2D_GRADMAP_MASK
        #define WF_TEX2D_GRADMAP_MASK(uv)       SAMPLE_MASK_VALUE(_CGR_MaskTex, uv, _CGR_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_CLC_MASK
        #define WF_TEX2D_CLC_MASK(uv)           SAMPLE_MASK_VALUE(_CLC_MaskTex, uv, _CLC_InvMaskVal).r
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
        #define WF_TEX2D_NORMAL_DTL_MASK(uv)    SAMPLE_MASK_VALUE(_NS_2ndMaskTex, uv, _NS_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_METAL_GLOSS
        #if !defined(_MT_NORHMAP_ENABLE)
            #define WF_TEX2D_METAL_GLOSS(uv)    (SAMPLE_MASK_VALUE(_MetallicGlossMap, uv, _MT_InvMaskVal).rgba * half4(1, 1, 1, 1 - SAMPLE_MASK_VALUE(_SpecGlossMap, uv, _MT_InvRoughnessMaskVal).r))
        #else
            #define WF_TEX2D_METAL_GLOSS(uv)    SAMPLE_MASK_VALUE(_MetallicGlossMap, uv, _MT_InvMaskVal).rgba
        #endif
    #endif

    #ifndef WF_TEX2D_LAME_TEX
        #define WF_TEX2D_LAME_TEX(uv)           PICK_SUB_TEX2D(_LME_Texture, _MainTex, uv).rgba
    #endif
    #ifndef WF_TEX2D_LAME_MASK
        #define WF_TEX2D_LAME_MASK(uv)          SAMPLE_MASK_VALUE(_LME_MaskTex, uv, _LME_InvMaskVal).r
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

    #ifndef WF_TEX2D_RIM_SHADOW_MASK
        #define WF_TEX2D_RIM_SHADOW_MASK(uv)    SAMPLE_MASK_VALUE(_TM_MaskTex, uv, _TM_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_SCREEN_MASK
        #define WF_TEX2D_SCREEN_MASK(uv)        SAMPLE_MASK_VALUE(_OVL_MaskTex, uv, _OVL_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_DFD_COLOR
        #define WF_TEX2D_DFD_COLOR(uv)          PICK_SUB_TEX2D(_DFD_ColorTex, _MainTex, uv).rgb
    #endif

    #ifndef WF_TEX2D_OUTLINE_COLOR
        #define WF_TEX2D_OUTLINE_COLOR(uv)      PICK_SUB_TEX2D(_TL_CustomColorTex, _MainTex, uv).rgb
    #endif

    #ifndef WF_TEX2D_OUTLINE_MASK
        #define WF_TEX2D_OUTLINE_MASK(uv)       SAMPLE_MASK_VALUE_LOD(_TL_MaskTex, uv, _TL_InvMaskVal).r
    #endif

    #ifndef WF_TEX2D_OCCLUSION
        #define WF_TEX2D_OCCLUSION(uv)          SAMPLE_MASK_VALUE(_OcclusionMap, uv, 0).rgb
    #endif

    #ifndef IN_FRAG
        #define IN_FRAG     v2f
    #endif

    ////////////////////////////
    // Base Color
    ////////////////////////////

    void prepareMainTex(IN_FRAG i, inout drawing d) {
        d.uv_main = TRANSFORM_TEX(i.uv, _MainTex);
    }

    void drawMainTex(inout drawing d) {
        d.color *= PICK_MAIN_TEX2D(_MainTex, d.uv_main);
    }

    void drawBackTex(inout drawing d) {
#ifdef _BKT_ENABLE
FEATURE_TGL_ON_BEGIN(_BKT_Enable)
        if (!d.facing) {
            float2 uv_back = _BKT_UVType == 1 ? d.uv2 : d.uv1;
            uv_back = TRANSFORM_TEX(uv_back, _BKT_BackTex);
            d.color = PICK_MAIN_TEX2D(_BKT_BackTex, uv_back) * _BKT_BackColor;
        }
FEATURE_TGL_END
#endif
    }

    void drawVertexColor(inout drawing d) {
#ifdef _VC_ENABLE
        d.color *= lerp(ONE_VEC4, d.vertex_color, _UseVertexColor);
#endif
    }

    ////////////////////////////
    // Alpha Transparent
    ////////////////////////////

    #if defined(_WF_ALPHA_FRESNEL)
        #ifndef _WF_ALPHA_BLEND
            #define _WF_ALPHA_BLEND
        #endif
    #endif

    #if defined(_WF_ALPHA_BLEND) || defined(_WF_ALPHA_CUTOUT) || defined(_WF_ALPHA_CUTFADE) || defined(_WF_ALPHA_CUSTOM)
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

        void alphaCutoutOutline(inout float alpha) {
#ifdef _TL_ENABLE
            if (TGL_ON(_TL_UseCutout) && alpha < _Cutoff) {
                discard;
            }
#endif
            alpha = 1;
        }

        void alpha3PassCutout(inout float alpha) {
            if (alpha < _Cutoff) {
                discard;
                alpha = 0;
            }
            else {
                alpha = 1;
            }
        }

        void alpha3PassFade(inout float alpha) {
            if (alpha < _Cutoff) {
                alpha *= _AL_Power;
            }
            else {
                discard;
                alpha = 0;
            }
        }

        void drawAlphaMask(inout drawing d) {
            float alpha = pickAlpha(d.uv_main, d.color.a);

            #if defined(_WF_ALPHA_CUSTOM)
                _WF_ALPHA_CUSTOM
            #elif defined(_WF_ALPHA_CUTOUT) || defined(_WF_ALPHA_CUTFADE)
                alpha = smoothstep(_Cutoff - 0.0625, _Cutoff + 0.0625, alpha);
                #if defined(_WF_ALPHA_CUTFADE)
                    if (TGL_OFF(_AL_AlphaToMask)) {
                #endif
                    if (alpha < 0.5) {
                        discard;
                        alpha = 0;
                    } else {
                        alpha = 1;
                    }
                #if defined(_WF_ALPHA_CUTFADE)
                    }
                #endif
            #else
                alpha *= _AL_Power;
                if (_AL_MaskMode == 1) {
                    alpha = max(0, 1 - alpha);
                }
                alpha *= _AL_CustomValue;
            #endif

            d.color.a = alpha;
        }

        void drawFresnelAlpha(inout drawing d) {
            #ifdef _WF_ALPHA_FRESNEL
                // フレネルアルファ
                float maxValue = max(d.color.a, _AL_Fresnel * _AL_CustomValue);
                float fa = 1 - abs( dot( d.ws_normal, d.ws_view_dir ) );
                d.color.a = lerp( d.color.a, maxValue, fa * fa * fa * fa );
            #endif
            #ifndef _WF_PB_GRAB_TEXTURE
                if (d.color.a <= 0) {
                    discard;
                }
            #endif
        }
    #else
        #define drawAlphaMask(d) d.color.a = 1.0
        #define drawFresnelAlpha(d)
    #endif

    ////////////////////////////
    // Anti Glare & Light Configuration
    ////////////////////////////

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

    #define LIT_MODE_AUTO               0
    #define LIT_MODE_ONLY_DIR_LIT       1
    #define LIT_MODE_ONLY_POINT_LIT     2
    #define LIT_MODE_CUSTOM_WORLDSPACE  3
    #define LIT_MODE_CUSTOM_LOCALSPACE  4
    #define LIT_MODE_CUSTOM_WORLDPOS    5

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

    float3 calcWorldSpaceCustomSunDir() {
        return calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude);
    }

    float4 calcWorldSpaceLightDir(float3 ws_vertex) {
        ws_vertex = calcWorldSpaceBasePos(ws_vertex);

#if defined(_GL_AUTO_ENABLE)

        uint mode = calcAutoSelectMainLight(ws_vertex);
        if (mode == LIT_MODE_ONLY_DIR_LIT) {
            return float4( getMainLightDirection() , +1 );
        }
        if (mode == LIT_MODE_ONLY_POINT_LIT) {
            return float4( calcPointLight1WorldDir(ws_vertex) , -1 );
        }
        return float4( calcWorldSpaceCustomSunDir() , 0 );

#elif defined(_GL_ONLYDIR_ENABLE)

        float3 dir = getMainLightDirection();
        if (any(dir)) {
            return float4( dir , +1 );
        }
        return float4( calcWorldSpaceCustomSunDir() , 0 );

#elif defined(_GL_ONLYPOINT_ENABLE)

        float3 dir = calcPointLight1WorldDir(ws_vertex);
        if (any(dir)) {
            return float4( dir , -1 );
        }
        return float4( calcWorldSpaceCustomSunDir() , 0 );

#elif defined(_GL_WSDIR_ENABLE)

        return float4( calcWorldSpaceCustomSunDir() , 0 );

#elif defined(_GL_LSDIR_ENABLE)

        return float4( UnityObjectToWorldDir(calcWorldSpaceCustomSunDir()) , 0 );

#elif defined(_GL_WSPOS_ENABLE)

        return float4( calcPointLightWorldDir(_GL_CustomLitPos, ws_vertex) , 0 );

#else

        uint mode = _GL_LightMode;
        if (mode == LIT_MODE_AUTO) {
            mode = calcAutoSelectMainLight(ws_vertex);
        }
        if (mode == LIT_MODE_ONLY_DIR_LIT) {
            float3 dir = getMainLightDirection();
            if (any(dir)) {
                return float4( dir , +1 );
            }
            mode = LIT_MODE_CUSTOM_WORLDSPACE;
        }
        if (mode == LIT_MODE_ONLY_POINT_LIT) {
            float3 dir = calcPointLight1WorldDir(ws_vertex);
            if (any(dir)) {
                return float4( dir , -1 );
            }
            mode = LIT_MODE_CUSTOM_WORLDSPACE;
        }
        if (mode == LIT_MODE_CUSTOM_WORLDSPACE) {
            return float4( calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude) , 0 );
        }
        if (mode == LIT_MODE_CUSTOM_LOCALSPACE) {
            return float4( UnityObjectToWorldDir(calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude)) , 0 );
        }
        if (mode == LIT_MODE_CUSTOM_WORLDPOS) {
            return float4( calcPointLightWorldDir(_GL_CustomLitPos, ws_vertex) , 0 );
        }
        return float4( calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude) , 0 );

#endif
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

    float calcAngleLightCamera(float3 ws_vertex, half3 ws_light_dir) {
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float2 xz_camera_pos = worldSpaceViewPointPos().xz - calcWorldSpaceBasePos(ws_vertex).xz;
        half angle_light_camera = dot( SafeNormalizeVec2(ws_light_dir.xz), SafeNormalizeVec2(xz_camera_pos) )
            * (1 - smoothstep(0.9, 1, abs(ws_light_dir.y))) * smoothstep(0, 1, length(xz_camera_pos) * 3);
        return angle_light_camera;
    }

    #ifdef _GL_NCC_ENABLE

        void affectNearClipCancel(inout float4 vs_vertex) {
FEATURE_TGL_ON_BEGIN(_GL_NCC_Enable)
            if(vs_vertex.w < _ProjectionParams.y * 1.01 && 0 < vs_vertex.w && !isInMirror()) {
                #if defined(UNITY_REVERSED_Z)
                    vs_vertex.z = vs_vertex.z * 0.0001 + vs_vertex.w * 0.999;
                #else
                    vs_vertex.z = vs_vertex.z * 0.0001 - vs_vertex.w * 0.999;
                #endif
            }
FEATURE_TGL_END
        }

    #else
        #define affectNearClipCancel(vs_vertex)
    #endif

    ////////////////////////////
    // Gradient Map
    ////////////////////////////

    #ifdef _CGR_ENABLE

        void drawGradientMap(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_CGR_Enable)
            float x = saturate(calcBrightness(d.color.rgb));
            float3 cgr = WF_TEX2D_GRADMAP(float2(x, 0)).rgb;
            d.color.rgb = lerp(d.color.rgb, cgr, WF_TEX2D_GRADMAP_MASK(d.uv_main));
FEATURE_TGL_END
        }

    #else
        #define drawGradientMap(d)
    #endif

    ////////////////////////////
    // Color Change
    ////////////////////////////

    #ifdef _CLC_ENABLE

        void drawColorChange(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_CLC_Enable)
            float3 clc = d.color.rgb;
            // モノクロ化
            if (TGL_ON(_CLC_Monochrome)) {
                clc.r += clc.g + clc.b;
                clc.gb = (clc.r - 1) / 2;
            }
            // HSVで調整
            float3 hsv = rgb2hsv( saturate(clc.rgb) );
            hsv += float3( _CLC_DeltaH, _CLC_DeltaS, _CLC_DeltaV);
            hsv.r = frac(hsv.r);
            clc = saturate( hsv2rgb( saturate(hsv) ) );
            // ガンマ調整
            clc = pow(clc, NON_ZERO_FLOAT(_CLC_Gamma));
            // 合成
            d.color.rgb = lerp(d.color.rgb, clc, WF_TEX2D_CLC_MASK(d.uv_main));
FEATURE_TGL_END
        }

    #else
        #define drawColorChange(d)
    #endif

    ////////////////////////////
    // 3ch Color Mask
    ////////////////////////////

    #ifdef _CHM_ENABLE

        void draw3chColorMask(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_CHM_Enable)
            float3 mask  = WF_TEX2D_3CH_MASK(d.uv_main);
            float4 c1 = d.color * _CHM_ColorR;
            float4 c2 = d.color * _CHM_ColorG;
            float4 c3 = d.color * _CHM_ColorB;
            d.color = lerp(d.color, c1, mask.r);
            d.color = lerp(d.color, c2, mask.g);
            d.color = lerp(d.color, c3, mask.b);
FEATURE_TGL_END
        }

    #else
        #define draw3chColorMask(d)
    #endif

    ////////////////////////////
    // Emissive Scroll
    ////////////////////////////

    #ifdef _ES_ENABLE

    #if defined(_ES_SCROLL_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)

        float calcEmissiveWaving(inout drawing d) {
            float3 uv =
                    _ES_SC_DirType == 1 ? UnityWorldToObjectPos(d.ws_vertex)    // ローカル座標
                    : _ES_SC_DirType == 2 ? (                                   // UV
                        _ES_SC_UVType == 1 ? float3(d.uv2, 0) : float3(d.uv_main, 0)
                    )
                    : d.ws_vertex                                               // ワールド座標
                    ;

            // 0 -> 1 への時間関数
            float time = _Time.y * _ES_SC_Speed - dot(uv, _ES_SC_Direction.xyz);
            time *= UNITY_INV_TWO_PI;

            // 周期 2PI、値域 [-1, +1]
            float waving = 0;
            if (_ES_SC_Shape == 0) {
                float v = pow( 1 - frac(time), _ES_SC_Sharpness + 2 );
                waving = 8 * v * (1 - v) - 1;
            }
            else if (_ES_SC_Shape == 1) {
                waving = (1 - 2 * frac(time)) * _ES_SC_Sharpness;
            }
            else {
                waving = sin( time * UNITY_TWO_PI ) * _ES_SC_Sharpness;
            }

            return saturate(waving + _ES_SC_LevelOffset);
        }

        half enableEmissiveScroll(inout drawing d) {
            return TGL_ON(_ES_ScrollEnable);
        }

    #else
        #define calcEmissiveWaving(d)       (1)
        #define enableEmissiveScroll(d)     (0)
    #endif

    #if defined(_ES_AULINK_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
        #include "WF_UnToon_AudioLink.cginc"

        float   _ES_AuLinkEnable;
        float   _ES_AU_MinValue;
        float   _ES_AU_MaxValue;
        float   _ES_AU_Band;
        float   _ES_AU_Slope;
        float   _ES_AU_MinThreshold;
        float   _ES_AU_MaxThreshold;
        float   _ES_AU_BlackOut;
        float   _ES_AU_AlphaLink;

        float calcEmissiveAudioLink(inout drawing d) {
            float au = saturate(AudioLinkLerp( ALPASS_AUDIOLINK + float2( 0, _ES_AU_Band ) ).r);
            au = lerp(au * _ES_AU_Slope, lerp(1, au, _ES_AU_Slope), smoothstep(_ES_AU_MinThreshold, _ES_AU_MaxThreshold, au));
            return lerp(_ES_AU_MinValue, _ES_AU_MaxValue, au);
        }

        half enableEmissiveAudioLink(inout drawing d) {
            return TGL_ON(_ES_AuLinkEnable) ? ( AudioLinkIsAvailable() ? 1 : ( TGL_ON(_ES_AU_BlackOut) ? -1 : 0 ) ) : 0;
        }

    #else
        #define calcEmissiveAudioLink(d)    (1)
        #define enableEmissiveAudioLink(d)  (0)
    #endif

        void drawEmissiveScroll(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_ES_Enable)
            half au_status = enableEmissiveAudioLink(d);
            if (au_status < 0) {
                return; // Emission自体を無効にする
            }
            half es_status = enableEmissiveScroll(d);

            float waving;
            if (0 < au_status) {
                waving = calcEmissiveAudioLink(d);
            }
            else if(0 < es_status) {
                waving = calcEmissiveWaving(d);
            }
            else {
                waving = 1;
            }

            float4 es_mask  = WF_TEX2D_EMISSION(d.uv_main);
            float4 es_color = _EmissionColor * es_mask;
            float es_power  = MAX_RGB(es_mask.rgb);

            // RGB側の合成
            d.color.rgb =
                // 加算合成
                _ES_BlendType == 0 ? d.color.rgb + es_color.rgb * waving :
                // 旧形式のブレンド
                _ES_BlendType == 1 ? lerp(d.color.rgb, es_color.rgb, waving * es_power) :
                // ブレンド
                lerp(d.color.rgb, es_color.rgb, waving);

            // Alpha側の合成
#if defined(_WF_ALPHA_BLEND)
            if (0 < au_status) {
    #if defined(_ES_AULINK_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
                if (0 < au_status && TGL_ON(_ES_AU_AlphaLink)) {
                    d.color.a = max(d.color.a, waving * es_power);
                }
    #endif
            }
            else if(0 < es_status) {
    #if defined(_ES_SCROLL_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
                if (0 < es_status && TGL_ON(_ES_SC_AlphaScroll)) {
                    d.color.a = max(d.color.a, waving * es_power);
                }
    #endif
            }
            else {
                if (TGL_ON(_ES_ChangeAlpha)) {
                    d.color.a = max(d.color.a, es_color.a * es_power);
                }
            }
#endif
FEATURE_TGL_END
        }

    #else
        #define drawEmissiveScroll(d)
    #endif

    ////////////////////////////
    // Normal Map
    ////////////////////////////

    #ifdef _NM_ENABLE

        void prepareBumpNormal(IN_FRAG i, inout drawing d) {
            d.ws_bump_normal = d.ws_normal;

FEATURE_TGL_ON_BEGIN(_NM_Enable)
            half3 normalTangent = WF_TEX2D_NORMAL(d.uv_main);
            if (TGL_ON(_NM_InvConvex)) {
                normalTangent.y = -normalTangent.y;
            }

            // 法線計算
            d.ws_bump_normal = transformTangentToWorldNormal(normalTangent, d.ws_normal, d.ws_tangent, d.ws_bitangent);

FEATURE_TGL_END
        }

        void drawBumpNormal(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_NM_Enable)
            // NormalMap は陰影として描画する
            // 影側を暗くしすぎないために、ws_normal と ws_bump_normal の差を乗算することで明暗を付ける
            d.color.rgb *= max(0.0, 1.0 + (dot(d.ws_bump_normal, d.ws_light_dir) - dot(d.ws_normal, d.ws_light_dir)) * _NM_Power * 2);
FEATURE_TGL_END
        }

    #else
        #define prepareBumpNormal(i, d)     d.ws_bump_normal = d.ws_normal
        #define drawBumpNormal(d)
        #define calcBumpNormal(d)  d.ws_normal
    #endif

    ////////////////////////////
    // Detail Normal Map
    ////////////////////////////

    #ifdef _NS_ENABLE

        void prepareDetailNormal(IN_FRAG i, inout drawing d) {
            d.ws_detail_normal = d.ws_normal;

FEATURE_TGL_ON_BEGIN(_NS_Enable)
            // 2nd NormalMap
            float2 uv_dtl = _NS_UVType == 1 ? i.uv2 : i.uv;
            float3 dtlNormalTangent = WF_TEX2D_NORMAL_DTL( TRANSFORM_TEX(uv_dtl, _DetailNormalMap) );

            // 法線計算
            d.ws_detail_normal = transformTangentToWorldNormal(dtlNormalTangent, d.ws_normal, d.ws_tangent, d.ws_bitangent);

            float dtlPower = WF_TEX2D_NORMAL_DTL_MASK(d.uv_main);
            d.ws_detail_normal = lerpNormals(d.ws_normal, d.ws_detail_normal, dtlPower);
FEATURE_TGL_END
        }

    #else
        #define prepareDetailNormal(i, d)  d.ws_detail_normal = d.ws_bump_normal
    #endif

    ////////////////////////////
    // Metallic
    ////////////////////////////

    float smoothnessToSpecularPower(half3 ws_camera_dir, half3 ws_normal, half3 ws_light_dir, float smoothness) {
        float roughness     = (1 - smoothness) * (1 - smoothness);
        float3 halfVL       = normalize(ws_camera_dir + ws_light_dir);
        float NdotH         = max(0, dot( ws_normal, halfVL ));
        return max(0, GGXTerm(NdotH, roughness));
    }

    #ifdef _MT_ENABLE

        float3 pickReflection(float3 ws_vertex, half3 ws_normal, float smoothness) {
            float metal_lod = (1 - smoothness) * 10;
            float3 color = ZERO_VEC3;

            // ONLYでなければ PROBE を加算
#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (_MT_CubemapType != 2) {
#endif
#ifndef _MT_ONLY2ND_ENABLE
                color += pickReflectionProbe(ws_vertex, ws_normal, metal_lod).rgb;
#endif
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
            // OFFでなければ SECOND_MAP を加算
            if (_MT_CubemapType != 0) {
#endif
#if defined(_MT_ONLY2ND_ENABLE) || defined(_WF_LEGACY_FEATURE_SWITCH)
                float3 cubemap = pickReflectionCubemap(_MT_Cubemap, _MT_Cubemap_HDR, ws_vertex, ws_normal, metal_lod);
                color += lerp(cubemap, pow(max(ZERO_VEC3, cubemap), NON_ZERO_FLOAT(1 - _MT_CubemapHighCut)), step(ONE_VEC3, cubemap)) * _MT_CubemapPower;
#endif
#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif
            return color;
        }

        float3 pickSpecular(half3 ws_camera_dir, half3 ws_normal, half3 ws_light_dir, float3 spec_color, float smoothness) {
            return spec_color * smoothnessToSpecularPower(ws_camera_dir, ws_normal, ws_light_dir, smoothness);
        }

        void drawMetallic(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_MT_Enable)
            float metallic = _MT_Metallic;
            float monochrome = _MT_Monochrome;
            float4 metalGlossMap = WF_TEX2D_METAL_GLOSS(d.uv_main);

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
                float3 ws_metal_normal = d.ws_normal;
#ifdef _NM_ENABLE
                ws_metal_normal = lerpNormals(ws_metal_normal, d.ws_bump_normal, _MT_BlendNormal);
#endif
#ifdef _NS_ENABLE
                ws_metal_normal = lerpNormals(ws_metal_normal, d.ws_detail_normal, _MT_BlendNormal2);
#endif
                float reflSmooth = metalGlossMap.a * _MT_ReflSmooth;
                float specSmooth = metalGlossMap.a * _MT_SpecSmooth;

                if (TGL_ON(_MT_GeomSpecAA)) {
                    half3 normal_ddx = ddx(ws_metal_normal);
                    half3 normal_ddy = ddy(ws_metal_normal);
                    float geom_roughness = pow(saturate(max(dot(normal_ddx, normal_ddx), dot(normal_ddy, normal_ddy))), 0.333);
                    reflSmooth = min(reflSmooth, 1.0 - geom_roughness);
                    specSmooth = min(specSmooth, 1.0 - geom_roughness);
                }

                // リフレクション
                float3 reflection = pickReflection(d.ws_vertex, ws_metal_normal, reflSmooth);
                reflection = lerp(reflection, calcBrightness(reflection).xxx, monochrome);

                // スペキュラ
                float3 specular = ZERO_VEC3;
                if (0.01 < _MT_Specular) {
                    specular = pickSpecular(d.ws_camera_dir, ws_metal_normal, d.ws_light_dir, d.light_color.rgb * d.color.rgb, specSmooth);
                }

                // 合成
                d.color.rgb = lerp(
                    d.color.rgb,
                    lerp(d.color.rgb * reflection.rgb, d.color.rgb + reflection.rgb, _MT_Brightness) + specular.rgb * _MT_Specular,
                    metallic);
            }
FEATURE_TGL_END
        }

    #else
        #define drawMetallic(d)
    #endif

    ////////////////////////////
    // Light Matcap
    ////////////////////////////

#ifdef WF_TYP_MATVEC

    WF_TYP_MATVEC calcMatcapVectorArray(in half3 ws_view_dir, in half3 ws_camera_dir, in half3 ws_normal, in half3 ws_bump_normal, in half3 ws_detail_normal) {
        // このメソッドは ws_bump_normal を考慮するバージョン。考慮しないバージョンは WF_Common.cginc にある。

        WF_TYP_MATVEC matcapVector;
        UNITY_INITIALIZE_OUTPUT(WF_TYP_MATVEC, matcapVector);

        // 真上を揃える回転行列
        float2x2 rotate = matcapRotateCorrectMatrix();

        // ワールド法線をビュー法線に変換
        float3 vs_normal = mul(float4(ws_normal, 1), UNITY_MATRIX_I_V).xyz;
        // カメラ位置にて補正する
        float3 vs_normal_center = matcapViewCorrect(vs_normal, ws_view_dir);
        // 真上を揃える
        vs_normal_center.xy = mul( vs_normal_center.xy, rotate );
        // 正規化して格納
        matcapVector.vs_normal_center = normalize(vs_normal_center);

#ifdef _MV_HAS_PARALLAX
        // カメラ位置にて補正する
        float3 vs_normal_side = matcapViewCorrect(vs_normal, ws_camera_dir);
        // 真上を揃える
        vs_normal_side.xy = mul( vs_normal_side.xy, rotate );
        // 正規化して格納
        matcapVector.diff_parallax = normalize(vs_normal_side) - matcapVector.vs_normal_center;
#endif

#ifdef _MV_HAS_NML
        // ワールド法線をビュー法線に変換
        float3 vs_bump_normal = mul(float4(ws_bump_normal, 1), UNITY_MATRIX_I_V).xyz;
        // カメラ位置にて補正する
        float3 vs_bump_normal_center = matcapViewCorrect(vs_bump_normal, ws_view_dir);
        // 真上を揃える
        vs_bump_normal_center.xy = mul( vs_bump_normal_center.xy, rotate );
        // 正規化して格納
        matcapVector.diff_normal = normalize(vs_bump_normal_center) - matcapVector.vs_normal_center;
#endif

#ifdef _MV_HAS_NML2
        // ワールド法線をビュー法線に変換
        float3 vs_detail_normal = mul(float4(ws_detail_normal, 1), UNITY_MATRIX_I_V).xyz;
        // カメラ位置にて補正する
        float3 vs_detail_normal_center = matcapViewCorrect(vs_detail_normal, ws_view_dir);
        // 真上を揃える
        vs_detail_normal_center.xy = mul( vs_detail_normal_center.xy, rotate );
        // 正規化して格納
        matcapVector.diff_normal2 = normalize(vs_detail_normal_center) - matcapVector.vs_normal_center;
#endif

        return matcapVector;
    }

    float3 calcMatcapVector(WF_TYP_MATVEC matcapVector, float normal, float normal2, float parallax) {
        float3 vs_normal = matcapVector.vs_normal_center;
#ifdef _MV_HAS_PARALLAX
        vs_normal += matcapVector.diff_parallax * parallax;
#endif
#ifdef _MV_HAS_NML
        vs_normal += matcapVector.diff_normal * normal;
#endif
#ifdef _MV_HAS_NML2
        vs_normal += matcapVector.diff_normal2 * normal2;
#endif
        return SafeNormalizeVec3(vs_normal);
    }

    float3 calcMatcapVector(WF_TYP_MATVEC matcapVector, float normal, float parallax) {
        return calcMatcapVector(matcapVector, normal, normal, parallax);
    }

#endif // WF_TYP_MATVEC

    void calcMatcapColor(
            float4  matcap_color,
            float3  matcap_mask,
            float   power,
            float   monochrome,
            float3  arrange_color,
            float3  median_color,
            float   change_alpha,
            uint    cap_type,
            inout float4 color) {

        // 色調整前のマスクを元に強度を計算
        power *= MAX_RGB(matcap_mask);
        // マスク色調整
        float3 matcap_mask_color = matcap_mask * arrange_color * 2;
        // matcap彩度調整
        matcap_color.rgb = lerp(matcap_color.rgb, AVE_RGB(matcap_color.rgb), monochrome);

        // 色合成
        if (cap_type == 1) {
            // 加算合成
            matcap_color.rgb *= LinearToGammaSpace(matcap_mask_color);
            color.rgb = blendColor_Add(color.rgb, matcap_color.rgb, power);
        } else if(cap_type == 2) {
            // 乗算合成
            matcap_color.rgb *= LinearToGammaSpace(matcap_mask_color);
            color.rgb = blendColor_Mul(color.rgb, matcap_color.rgb, power);
        } else {
            // 中間色合成
            matcap_color.rgb -= median_color;
            float3 lighten_color = max(ZERO_VEC3, matcap_color.rgb);
            float3 darken_color  = min(ZERO_VEC3, matcap_color.rgb);
            matcap_color.rgb = lerp(darken_color, lighten_color, matcap_mask_color);
            color.rgb = blendColor_Add(color.rgb, matcap_color.rgb, power);
        }

        // アルファ側の合成
#if defined(_WF_ALPHA_FRESNEL)
        if (TGL_ON(change_alpha)) {
            color.a = min(color.a, lerp(1, matcap_color.a, power));
        }
#endif
    }

    #define WF_CALC_MATCAP_COLOR(id)                                                                                                                        \
        FEATURE_TGL_ON_BEGIN(_HL_Enable##id)                                                                                                                \
                    calcMatcapColor(                                                                                                                        \
                        PICK_MAIN_TEX2D(_HL_MatcapTex##id,                                                                                                  \
                        saturate(calcMatcapVector(d.matcapVector, _HL_BlendNormal##id, _HL_BlendNormal2##id, _HL_Parallax##id).xy * 0.5 + 0.5)),            \
                        SAMPLE_MASK_VALUE(_HL_MaskTex##id, d.uv_main, _HL_InvMaskVal##id).rgb,                                                              \
                        _HL_Power##id, _HL_MatcapMonochrome##id, _HL_MatcapColor##id, _HL_MedianColor##id, _HL_ChangeAlpha##id, _HL_CapType##id, d.color);  \
        FEATURE_TGL_END

    void drawMatcapColor(inout drawing d) {
#ifdef _HL_ENABLE
    #ifdef UNITY_OLD_PREPROCESSOR
        WF_CALC_MATCAP_COLOR(##)
    #else
        WF_CALC_MATCAP_COLOR()
    #endif
#endif

#ifndef _WF_MOBILE
#ifdef _HL_ENABLE_1
        WF_CALC_MATCAP_COLOR(_1)
#endif
#endif

#ifdef _WF_UNTOON_POWERCAP

#ifdef _HL_ENABLE_2
        WF_CALC_MATCAP_COLOR(_2)
#endif
#ifdef _HL_ENABLE_3
        WF_CALC_MATCAP_COLOR(_3)
#endif
#ifdef _HL_ENABLE_4
        WF_CALC_MATCAP_COLOR(_4)
#endif
#ifdef _HL_ENABLE_5
        WF_CALC_MATCAP_COLOR(_5)
#endif
#ifdef _HL_ENABLE_6
        WF_CALC_MATCAP_COLOR(_6)
#endif
#ifdef _HL_ENABLE_7
        WF_CALC_MATCAP_COLOR(_7)
#endif

#endif
    }

    ////////////////////////////
    // Lame
    ////////////////////////////

    #ifdef _LME_ENABLE

        void drawLame(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_LME_Enable)
            float power = WF_TEX2D_LAME_MASK(d.uv_main);
            if (0 < power) {
                float2 uv_lame = _LME_UVType == 1 ? d.uv2 : d.uv1;
                uv_lame = TRANSFORM_TEX(uv_lame, _LME_Texture);

                float   scale = NON_ZERO_FLOAT(_LME_Scale) / 100;
                float2  st = uv_lame / scale;

                float2  ist = floor(st);
                float2  fst = frac(st);
                float3  min_pos = float3(0, 0, 5);

                for (int y = -1; y <= 1; y++) {
                    for (int x = -1; x <= 1; x++) {
                        float2 neighbor = float2(x, y);
                        float3 pos;
                        pos.xy  = 0.5 + 0.5 * sin( random2to2((ist + neighbor) * scale) * 2 - 1 );
                        pos.z   = length(neighbor + pos.xy - fst);
                        min_pos = pos.z < min_pos.z ? pos : min_pos;
                    }
                }

                float3 ws_camera_vec = worldSpaceCameraVector(d.ws_vertex);

                // アニメーション項
                power *= _LME_AnimSpeed < NZF ? 1 : sin(frac(_Time.y * _LME_AnimSpeed + random2to1(min_pos.yx)) * UNITY_TWO_PI) / 2 + 0.5;
                // Glitter項
                power = lerp(power, max(power, pow(power + 0.1, 32)), _LME_Glitter);
                // 密度項
                power *= step(1 - _LME_Dencity / 4, abs(min_pos.x));
                // フレークのばらつき項
                power *= random2to1(min_pos.xy);
                // 距離フェード項
                power *= 1 - smoothstep(_LME_MinDist, max(_LME_MinDist + NZF, _LME_MaxDist), length(ws_camera_vec));
                // NdotV起因の強度項
                power *= pow(abs(dot(normalize(ws_camera_vec), d.ws_normal)), NON_ZERO_FLOAT(_LME_Spot));
                // 形状
                power *= _LME_Shape == 0 ? 1 : step(min_pos.z, 0.2); // 通常の多角形 or 点

                float4 lame_color = _LME_Color * WF_TEX2D_LAME_TEX(uv_lame);
                lame_color.rgb += _LME_RandColor * (random2to3(min_pos.xy) * 2 - 1);

                d.color.rgb += max(ZERO_VEC3, lame_color.rgb) * power;
                #ifdef _WF_ALPHA_BLEND
                    d.color.a = max(d.color.a, lerp(d.color.a, lame_color.a, saturate(power * _LME_ChangeAlpha)));
                #endif
            }
FEATURE_TGL_END
        }

    #else
        #define drawLame(d)
    #endif

    ////////////////////////////
    // ToonShade
    ////////////////////////////

    #ifdef _TS_ENABLE

        float calcShadowPower(float3 ws_vertex, half4 ws_light_dir, float3 ambientColor) {
            float3 lightColorMain = calcWorldSpaceLightColor(ws_vertex, ws_light_dir.w);
            float3 lightColorSub4 = 0 < ws_light_dir.w ? sampleAdditionalLightColor(ws_vertex) : sampleAdditionalLightColorExclude1(ws_vertex);
            float main = saturate(calcBrightness( lightColorMain ));
            float sub4 = saturate(calcBrightness( lightColorSub4 ));
            float ambient = saturate(calcBrightness( ambientColor ));

            // メインライトとそれ以外のライトの明るさの差が影の強さになる
            half shadow_power = saturate( abs(main - sub4) / max(main + sub4, 0.0001) ) * 0.5 + 0.5;

            // メインライトが真上または真下から当たっている場合は影を弱める
            shadow_power = min( shadow_power, 1 - smoothstep(0.8, 1, abs(ws_light_dir.y)) * 0.5 );

            // 環境光が強い場合は影を弱める
            shadow_power = min( shadow_power, 1 - ambient * 0.5 );

            // 距離が離れているときは影を弱める
            if (TGL_OFF(_GL_DisableBasePos)) {  // BatchingStatic のときには DisableBasePos が ON になるのでそのときは影を弱めない
                float3 cam_vec = worldSpaceViewPointPos() - calcWorldSpaceBasePos(ws_vertex);
                half angle_light_camera = dot( SafeNormalizeVec2(ws_light_dir.xz), SafeNormalizeVec2(cam_vec.xz) );
                shadow_power = min( shadow_power, 1 - smoothstep(_TS_MinDist, max(_TS_MinDist + NZF, _TS_MaxDist), length(cam_vec)) * saturate(-angle_light_camera) );
            }

            return shadow_power;
        }

        void calcToonShadeContrast(float3 ws_vertex, half4 ws_light_dir, float3 ambientColor, out half shadow_power) {
#ifndef _WF_LEGACY_FEATURE_SWITCH
    #if !defined(_TS_FIXC_ENABLE)
            shadow_power = calcShadowPower(ws_vertex, ws_light_dir, ambientColor);
    #else
            shadow_power = 1;
    #endif
#else
            if (TGL_ON(_TS_Enable)) {
                if (TGL_OFF(_TS_FixContrast)) {
                    shadow_power = calcShadowPower(ws_vertex, ws_light_dir, ambientColor);
                } else {
                    shadow_power = 1;
                }
            } else {
                shadow_power = 0;
            }
#endif
        }

        void calcShadowColor(float3 color, float3 shadow_tex, float3 base_color, float power, float border, float feather, float brightness, inout float3 shadow_color) {
            shadow_color = lerp(
                max(ZERO_VEC3, lerp(ONE_VEC3, color.rgb * shadow_tex / base_color, power * _TS_Power)),
                shadow_color,
                smoothstep(border, border + max(feather, 0.001), brightness) );
        }

        void drawToonShade(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_TS_Enable)
            half angle_light_camera = d.angle_light_camera;
            if (isInMirror() || TGL_ON(_TS_DisableBackLit)) {
                angle_light_camera = 0; // 鏡の中のときは、視差問題が生じないように強制的に 0 にする
            }

            // 陰用法線とライト方向から Harf-Lambert
            float3 ws_shade_normal = d.ws_normal;
#ifdef _NM_ENABLE
            ws_shade_normal = lerpNormals(ws_shade_normal, d.ws_bump_normal, _TS_BlendNormal);
#endif
#ifdef _NS_ENABLE
            ws_shade_normal = lerpNormals(ws_shade_normal, d.ws_detail_normal, _TS_BlendNormal2);
#endif
            float brightness = lerp(dot(ws_shade_normal, d.ws_light_dir), 1, 0.5);  // 0.0 ～ 1.0

            // アンチシャドウマスク加算
            float anti_shade = WF_TEX2D_SHADE_MASK(d.uv_main);
            brightness = lerp(brightness, lerp(brightness, 1, 0.5), anti_shade);
            // ビュー相対位置シフト
            brightness *= smoothstep(-1.01, -1.0 + (_TS_1stBorder + _TS_2ndBorder) / 2, angle_light_camera);

            // 影色計算
            float3 base_color = NON_ZERO_VEC3( _TS_BaseColor.rgb * WF_TEX2D_SHADE_BASE(d.uv_main) );
            float3 shadow_color = ONE_VEC3;

#ifndef _WF_LEGACY_FEATURE_SWITCH

            // 1影
            calcShadowColor(_TS_1stColor, WF_TEX2D_SHADE_1ST(d.uv_main), base_color, d.shadow_power, _TS_1stBorder, _TS_1stFeather, brightness, shadow_color);

#if !defined(_TS_STEP1_ENABLE) || defined(_TS_STEP3_ENABLE)
            // 2影
            calcShadowColor(_TS_2ndColor, WF_TEX2D_SHADE_2ND(d.uv_main), base_color, d.shadow_power, _TS_2ndBorder, _TS_2ndFeather, brightness, shadow_color);
#endif
#if defined(_TS_STEP3_ENABLE)
            // 3影
            calcShadowColor(_TS_3rdColor, WF_TEX2D_SHADE_3RD(d.uv_main), base_color, d.shadow_power, _TS_3rdBorder, _TS_3rdFeather, brightness, shadow_color);
#endif

#else
            // 1影まで
            calcShadowColor(_TS_1stColor, WF_TEX2D_SHADE_1ST(d.uv_main), base_color, d.shadow_power, _TS_1stBorder, _TS_1stFeather, brightness, shadow_color);
            if (_TS_Steps == 2 || _TS_Steps == 3) {
                calcShadowColor(_TS_2ndColor, WF_TEX2D_SHADE_2ND(d.uv_main), base_color, d.shadow_power, _TS_2ndBorder, _TS_2ndFeather, brightness, shadow_color);
            }
            if (_TS_Steps == 3) {
                calcShadowColor(_TS_3rdColor, WF_TEX2D_SHADE_3RD(d.uv_main), base_color, d.shadow_power, _TS_3rdBorder, _TS_3rdFeather, brightness, shadow_color);
            }
#endif

            // 乗算
            d.color.rgb *= shadow_color;
FEATURE_TGL_END
        }

    #else
        #define calcToonShadeContrast(ws_vertex, ws_light_dir, ambientColor, shadow_power)
        #define drawToonShade(d)
    #endif

    ////////////////////////////
    // Rim Shadow
    ////////////////////////////

    #ifdef _TM_ENABLE

        float calcRimShadowPower(float3 vs_normal) {
            float rimPower = length(vs_normal.xy);
            if (rimPower < NZF) {
                return 0;
            }
            else {
                float2 dir_vec = vs_normal.xy / rimPower;
                dir_vec.x *= _TM_WidthSide * 2;
                dir_vec.y *= (_TM_WidthTop + _TM_WidthBottom);
                dir_vec.y += (_TM_WidthTop - _TM_WidthBottom);

                float dir_pwr = length(dir_vec);
                float width = _TM_Width * 0.1;
                float rim_max = 1 - width * dir_pwr;
                float rim_min = 1 - (width + _TM_Feather) * dir_pwr;

                return pow(smoothstep(rim_min - NZF, rim_max, rimPower), max(NZF, _TM_Exponent));
            }
        }

        void drawRimShadow(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_TM_Enable)
            float rimPower = WF_TEX2D_RIM_SHADOW_MASK(d.uv_main);
            // 合成
            d.color.rgb = lerp(d.color.rgb, d.color.rgb * _TM_Color.rgb, rimPower * calcRimShadowPower(calcMatcapVector(d.matcapVector, _TM_BlendNormal, _TM_BlendNormal2, 0)));
FEATURE_TGL_END
        }

    #else
        #define drawRimShadow(d)
    #endif

    ////////////////////////////
    // Rim Light
    ////////////////////////////

    #ifdef _TR_ENABLE

        float calcRimLightPower(float3 vs_normal) {
            float rimPower = length(vs_normal.xy);
            if (rimPower < NZF) {
                return 0;
            }
            else {
                float2 dir_vec = vs_normal.xy / rimPower;
                dir_vec.x *= _TR_WidthSide * 2;
                dir_vec.y *= (_TR_WidthTop + _TR_WidthBottom);
                dir_vec.y += (_TR_WidthTop - _TR_WidthBottom);

                float dir_pwr = length(dir_vec);
                float width = _TR_Width * 0.1;
                float rim_max = 1 - width * dir_pwr;
                float rim_min = 1 - (width + _TR_Feather) * dir_pwr;

                return pow(smoothstep(rim_min - NZF, rim_max, rimPower), max(NZF, _TR_Exponent));
            }
        }

        float3 calcRimLightColor(float3 color) {
            float3 rimColor =
                    _TR_BlendType == 0 ? (_TR_Color.rgb - MEDIAN_GRAY)  // ADD_AND_SUB
                    : _TR_BlendType == 1 ? (_TR_Color.rgb - color)      // ALPHA
                    : _TR_BlendType == 3 ? (_TR_Color.rgb - ONE_VEC3) * color   // MUL
                    : _TR_Color.rgb // ADD
                ;
            return rimColor;
        }

        void drawRimLight(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_TR_Enable)
            half angle_light_camera = d.angle_light_camera;
            if (_TR_BlendType == 3) {
                angle_light_camera = -0.2; // 乗算のときは常に最大
            }
            else if (isInMirror() || TGL_ON(_TR_DisableBackLit)) {
                angle_light_camera = 0; // 鏡の中のときは、視差問題が生じないように強制的に 0 にする
            }
            // 順光の場合はリムライトを暗くする
            float3 rimPower = saturate(0.8 - angle_light_camera) * WF_TEX2D_RIM_MASK(d.uv_main);
            // 色計算
            float3 rimColor = calcRimLightColor(d.color.rgb);
            // 合成
            d.color.rgb = lerp(d.color.rgb, d.color.rgb + rimColor * rimPower, calcRimLightPower(calcMatcapVector(d.matcapVector, _TR_BlendNormal, _TR_BlendNormal2, 0)));
FEATURE_TGL_END
        }

    #else
        #define drawRimLight(d)
    #endif

    ////////////////////////////
    // Overlay Texture
    ////////////////////////////

    #ifdef _OVL_ENABLE

        float2 computeOverlayTex(float3 ws_vertex) {
            half3 ws_view_dir = normalize( ws_vertex - _WorldSpaceCameraPos.xyz );

            float lon = atan2( ws_view_dir.z, ws_view_dir.x );  // -PI ~ +PI
            float lat = acos( ws_view_dir.y );                  // -PI ~ +PI
            float2 uv = float2(-lon, -lat) * UNITY_INV_TWO_PI + 0.5;

            return uv;
        }

        float2 computeAngelRingUV(float3 vs_normal, float2 uv2) {
            return float2(vs_normal.x / 2 + 0.5, lerp(uv2.y, vs_normal.y / 2 + 0.5, _OVL_CustomParam1));
        }

        float3 blendOverlayColor(float3 base, float4 decal, float power) {
            power *= decal.a;
            return
                  _OVL_BlendType == 0 ? blendColor_Alpha(base, decal.rgb, power)
                : _OVL_BlendType == 1 ? blendColor_Add(base, decal.rgb, power)
                : _OVL_BlendType == 2 ? blendColor_Mul(base, decal.rgb, power)
                : _OVL_BlendType == 3 ? blendColor_AddAndSub(base, decal.rgb, power)
                : _OVL_BlendType == 4 ? blendColor_Screen(base, decal.rgb, power)
                : _OVL_BlendType == 5 ? blendColor_Overlay(base, decal.rgb, power)
                : _OVL_BlendType == 6 ? blendColor_HardLight(base, decal.rgb, power)
                : base  // 何もしない
                ;
        }

        void drawOverlayTexture(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_OVL_Enable)
            float2 uv_overlay =
                _OVL_UVType == 1 ? d.uv2                                                 // UV2
                : _OVL_UVType == 2 ? computeOverlayTex(d.ws_vertex)                          // SKYBOX
                : _OVL_UVType == 3 ? computeAngelRingUV(calcMatcapVector(d.matcapVector, 1, 1, 0.5), d.uv2)                // ANGELRING
                : _OVL_UVType == 4 ? calcMatcapVector(d.matcapVector, 1, 1, 0.5).xy / 2 + 0.5                                  // MATCAP
                : d.uv1                                                                      // UV1
                ;
            uv_overlay = TRANSFORM_TEX(uv_overlay, _OVL_OverlayTex);
            if (_OVL_OutUVType == 1) {  // Clip
                if (uv_overlay.x < 0 || 1 < uv_overlay.x || uv_overlay.y < 0 || 1 < uv_overlay.y) {
                    return;
                }
            }
            else {  // Repeat
                uv_overlay += frac(_OVL_UVScroll * _Time.xx);
            }
            float4 ov_color = PICK_MAIN_TEX2D(_OVL_OverlayTex, uv_overlay) * _OVL_Color;
            float ov_power = _OVL_Power * WF_TEX2D_SCREEN_MASK(d.uv_main);

            // 頂点カラーを加味
            ov_color *= lerp(ONE_VEC4, d.vertex_color, _OVL_VertColToDecal);
            ov_power *= lerp(1, saturate(TGL_OFF(_OVL_InvMaskVal) ? d.vertex_color.r : 1 - d.vertex_color.r), _OVL_VertColToMask);

            d.color.rgb = blendOverlayColor(d.color.rgb, ov_color, ov_power);
FEATURE_TGL_END
        }

    #else
        #define drawOverlayTexture(d)
    #endif

    ////////////////////////////
    // Outline
    ////////////////////////////

    float3 shiftNormalVertex(inout float3 ws_vertex, half3 ws_normal, float width) {
        // 外側にシフトする
        return ws_vertex.xyz + ws_normal * width; // ws_normal は normalizeされている前提
    }

    float4 shiftDepthVertex(float3 ws_vertex, float width) {
        // ワールド座標でのカメラ方向と距離を計算
        half3 ws_camera_dir = _WorldSpaceCameraPos - ws_vertex; // ワールド座標で計算する。理由は width をモデルスケール非依存とするため。
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

    float4 shiftNormalAndDepthVertex(float3 ws_vertex, half3 ws_normal, float width, float shift) {
        return shiftDepthVertex(shiftNormalVertex(ws_vertex, ws_normal, width), shift);
    }

    #ifdef _TL_ENABLE

        float getOutlineShiftWidth(float2 uv_main) {
            // マスクをシフト時に太さに反映する
            float mask = WF_TEX2D_OUTLINE_MASK(uv_main);
            return _TL_LineWidth * 0.01 * mask;
        }

        void drawOutline(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_TL_Enable)
            // アウトライン色をカスタムカラーと合成
            float3 line_color = lerp(_TL_LineColor.rgb, WF_TEX2D_OUTLINE_COLOR(d.uv_main), _TL_BlendCustom);
            // アウトライン色をベースと合成
            d.color.rgb = lerp(line_color, d.color.rgb, _TL_BlendBase);

            // アウトラインアルファを反映
            #ifdef _WF_ALPHA_BLEND
                d.color.a = _TL_LineColor.a;
            #endif
FEATURE_TGL_END
        }

    #else
        #define drawOutline(d)
    #endif

    float4 shiftOutlineVertex(inout float3 ws_vertex, half3 ws_normal, float width, float shift) { // 4
        #ifdef _TL_ENABLE
#ifdef _WF_LEGACY_FEATURE_SWITCH
        if (TGL_ON(_TL_Enable)) {
#endif
            // Normal方向にシフトとCamera方向にZ-Shiftを行う
            float4 vs_vertex = shiftNormalAndDepthVertex(ws_vertex, ws_normal, width, shift);
            affectNearClipCancel(vs_vertex);
            return vs_vertex;
#ifdef _WF_LEGACY_FEATURE_SWITCH
        } else {
            return DISCARD_VS_VERTEX_ZERO;
        }
#endif
        #else
            return DISCARD_VS_VERTEX_ZERO;
        #endif
    }

    ////////////////////////////
    // Ambient Occlusion
    ////////////////////////////

    #ifndef SHADOWS_SHADOWMASK
        #define _AO_PICK_LMAP(uv_lmap)      pickLightmap(uv_lmap)
        #define _AO_PICK_LMAP_LOD(uv_lmap)  pickLightmapLod(uv_lmap)
    #else
        #define _AO_PICK_LMAP(uv_lmap)      (pickLightmap(uv_lmap) + ONE_VEC3)
        #define _AO_PICK_LMAP_LOD(uv_lmap)  (pickLightmapLod(uv_lmap) + ONE_VEC3)
        // SHADOWS_SHADOWMASK が有るときは、ライトマップに直接光はベイクされていないので白色を加算する
        // BakedIndirect もここを通したかったが MixedLight 無しの場合と区別できなかったので妥協
    #endif

    #ifdef _AO_ENABLE

        void drawOcclusion(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_AO_Enable)
            float3 occlusion = ONE_VEC3;
#ifndef _WF_AO_ONLY_LMAP
            float2 uv_aomap = _AO_UVType == 1 ? d.uv2 : d.uv_main;
            float3 aomap_var = WF_TEX2D_OCCLUSION(uv_aomap);
            occlusion *= TGL_OFF(_AO_UseGreenMap) ? aomap_var.rgb : aomap_var.ggg;
            occlusion = blendColor_Screen(occlusion, _AO_TintColor.rgb, _AO_TintColor.a);
#endif
#if defined(_LMAP_ENABLE) && !defined(_WF_EDITOR_HIDE_LMAP)
    #ifndef _WF_AO_ONLY_LMAP
            if (TGL_ON(_AO_UseLightMap)) {
    #endif
                occlusion *= _AO_PICK_LMAP(d.uv2);
    #ifndef _WF_AO_ONLY_LMAP
            }
    #endif
#endif
            occlusion = lerp(AVE_RGB(occlusion).xxx, occlusion, _GL_BlendPower); // 色の混合
            occlusion = (occlusion - 1) * _AO_Contrast + 1 + _AO_Brightness;
            d.color.rgb *= max(ZERO_VEC3, occlusion.rgb);
FEATURE_TGL_END
        }

    #else
        #define drawOcclusion(d)
    #endif

    float3 calcAmbientColorVertex(float2 uv_lmap) {
        // ライトマップもしくは環境光を取得
        #ifdef _LMAP_ENABLE
            #ifdef _AO_ENABLE
                #ifdef _WF_AO_ONLY_LMAP
                    return ONE_VEC3;    // Lightmap が使えてAOが有効、かつONLYのときはAO側で色を合成するので白を返す
                #else
                    #ifndef _WF_LEGACY_FEATURE_SWITCH
                        return TGL_ON(_AO_UseLightMap) ? ONE_VEC3 : _AO_PICK_LMAP_LOD(uv_lmap);
                    #else
                        return TGL_ON(_AO_Enable) && TGL_ON(_AO_UseLightMap) ? ONE_VEC3 : _AO_PICK_LMAP_LOD(uv_lmap);
                    #endif
                #endif
            #else
                return _AO_PICK_LMAP_LOD(uv_lmap);    // Lightmap が使えるがAOが無効のときは、Lightmap から明るさを取得
            #endif
        #else
            return sampleSHLightColor();    // Lightmap が使えないときは SH を返す
        #endif
    }

    ////////////////////////////
    // Distance Fade
    ////////////////////////////

    #ifdef _DFD_ENABLE

        float calcDistanceFadeDistanceSq(float3 ws_vertex) {
            float3 cam_vec1 = ws_vertex - worldSpaceViewPointPos();
            float lenSq_vec1 = dot(cam_vec1, cam_vec1);

            #ifndef USING_STEREO_MATRICES
                return lenSq_vec1;
            #else
                float3 cam_vec2 = ws_vertex - unity_StereoWorldSpaceCameraPos[0];
                float3 cam_vec3 = ws_vertex - unity_StereoWorldSpaceCameraPos[1];
                float lenSq_vec2 = dot(cam_vec2, cam_vec2);
                float lenSq_vec3 = dot(cam_vec3, cam_vec3);
                return min(lenSq_vec1, min(lenSq_vec2, lenSq_vec3));
            #endif
        }

        void drawDistanceFade(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_DFD_Enable)
            float dist = sqrt(calcDistanceFadeDistanceSq(d.ws_vertex.xyz));
            if (!d.facing && TGL_ON(_DFD_BackShadow)) {
                dist = 0;
            }
            d.color.rgb = lerp(d.color.rgb, _DFD_Color.rgb * WF_TEX2D_DFD_COLOR(d.uv_main), _DFD_Power * (1 - smoothstep(_DFD_MinDist, max(_DFD_MinDist + NZF, _DFD_MaxDist), dist)));
FEATURE_TGL_END
        }

    #else
        #define drawDistanceFade(d)
    #endif

    ////////////////////////////
    // Dissolve
    ////////////////////////////

    #ifdef _DSV_ENABLE

        void drawDissolve(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_DSV_Enable)
            if (1 - NZF < _DSV_Dissolve) {
                // nop
            }
            else if (_DSV_Dissolve < NZF) {
                discard;
            }
            else {
                float2 uv   = TRANSFORM_TEX(d.uv1, _DSV_CtrlTex);
                float3 tex  = PICK_MAIN_TEX2D(_DSV_CtrlTex, uv);
                tex = TGL_OFF(_DSV_TexIsSRGB) ? tex : LinearToGammaSpace(tex);

                float pos = _DSV_Dissolve / (1 - _DSV_SparkWidth) - (TGL_OFF(_DSV_Invert) ? tex.r : 1 - tex.r);
                if (pos < 0) {
                    discard;
                }

                d.color.rgb += _DSV_SparkColor * (1 - smoothstep(0, NON_ZERO_FLOAT(_DSV_SparkWidth), pos));
            }
FEATURE_TGL_END
        }

    #else
        #define drawDissolve(d)
    #endif

    ////////////////////////////
    // Fog
    ////////////////////////////

    #ifdef _TFG_ENABLE

        void drawToonFog(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_TFG_Enable)
            float3 ws_base_position = UnityObjectToWorldPos(_TFG_BaseOffset);
            float3 ws_offset_vertex = (d.ws_vertex - ws_base_position) / max(float3(NZF, NZF, NZF), _TFG_Scale);
            float power =
                // 原点からの距離の判定
                smoothstep(_TFG_MinDist, max(_TFG_MinDist + NZF, _TFG_MaxDist), length( ws_offset_vertex ))
                // 前後の判定
                * smoothstep(0, 0.2, -dot(d.ws_view_dir.xz, ws_offset_vertex.xz))
                // カメラと原点の水平距離の判定
                * smoothstep(_TFG_MinDist, max(_TFG_MinDist + NZF, _TFG_MaxDist), length( ws_base_position.xz - worldSpaceViewPointPos().xz ));
            d.color.rgb = lerp(d.color.rgb, _TFG_Color.rgb * d.light_color, _TFG_Color.a * pow(power, _TFG_Exponential));
FEATURE_TGL_END
        }

    #else
        #define drawToonFog(d)
    #endif

    ////////////////////////////
    // GhostTransparent
    ////////////////////////////

    #ifdef _CGO_ENABLE

        void drawGhostTransparent(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_CGO_Enable)
            // GrabScreenPos 計算
            float4 grab_uv = ComputeGrabScreenPos(mul(UNITY_MATRIX_VP, float4(d.ws_vertex.xyz, 1)));
            grab_uv.xy /= grab_uv.w;

            float3 back_color = PICK_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE, grab_uv).rgb;

            d.color.rgb = lerp(back_color.rgb, d.color.rgb, saturate(d.color.a * _CGO_Power));
            d.color.a = 1;
FEATURE_TGL_END
        }

    #else
        #define drawGhostTransparent(d)
    #endif

    ////////////////////////////
    // Refraction
    ////////////////////////////

    #ifdef _CRF_ENABLE

        float isCancelEyeDepth(float2 grab_uv, float depth) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            return TGL_ON(_CRF_UseDepthTex) && LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, grab_uv)) < depth;
#else
    #if _CRF_DEPTH_ENABLE
            return LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, grab_uv)) < depth;
    #else
            return 0;
    #endif
#endif
        }

        void drawRefraction(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_CRF_Enable)
            float3 view_dir = normalize(d.ws_vertex - _WorldSpaceCameraPos.xyz);

            float3 refract_normal = lerpNormals(d.ws_normal, d.ws_bump_normal, _CRF_BlendNormal);
            float3 refract_dir = refract(view_dir, d.facing ? refract_normal : -refract_normal, 1.0 / _CRF_RefractiveIndex);
            float3 refract_pos = d.ws_vertex + refract_dir * _CRF_Distance;

            float4 refract_scr_pos = mul(UNITY_MATRIX_VP, float4(refract_pos, 1));
            refract_scr_pos.xy = clamp(refract_scr_pos.xy, -refract_scr_pos.w, refract_scr_pos.w);

            float4 grab_uv = ComputeGrabScreenPos(refract_scr_pos);
            grab_uv.xy /= grab_uv.w;

            float depth = -mul(UNITY_MATRIX_V, float4(d.ws_vertex.xyz, 1.0)).z;
            if (isCancelEyeDepth(grab_uv, depth)) {
                return;
            }

            float4 grab_color = PICK_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE, grab_uv.xy);
            float3 back_color = grab_color.rgb * (_CRF_Tint.rgb * unity_ColorSpaceDouble.rgb);

            d.color.rgb = lerp(lerp(d.color.rgb, back_color.rgb, grab_color.a), d.color.rgb, saturate(d.color.a));
            d.color.a = lerp(d.color.a, 1, grab_color.a);
FEATURE_TGL_END
        }

    #else
        #define drawRefraction(d)
    #endif

    ////////////////////////////
    // FrostedGlass
    ////////////////////////////

    #ifdef _CGL_ENABLE

        float isCancelEyeDepth(float2 grab_uv, float depth) {
#ifdef _WF_LEGACY_FEATURE_SWITCH
            return TGL_ON(_CGL_UseDepthTex) && LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, grab_uv)) < depth;
#else
    #if _CGL_DEPTH_ENABLE
            return LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, grab_uv)) < depth;
    #else
            return 0;
    #endif
#endif
        }

        float3 sampleScreenTextureBlur1(float2 uv, float2 scale, float depth) {    // GAUSSIAN
            static const int    BLUR_SAMPLE_COUNT = 7;
            static const float  BLUR_KERNEL[BLUR_SAMPLE_COUNT] = { -1, -2.0/3, -1.0/3, 0, 1.0/3, 2.0/3, 1 };
            static const half   BLUR_WEIGHTS[BLUR_SAMPLE_COUNT] = { 0.036, 0.113, 0.216, 0.269, 0.216, 0.113, 0.036 };

            float3 color = ZERO_VEC3;
            for (int j = 0; j < BLUR_SAMPLE_COUNT; j++) {
                for (int k = 0; k < BLUR_SAMPLE_COUNT; k++) {
                    float2 offset = float2(BLUR_KERNEL[j], BLUR_KERNEL[k]) * scale * (1 - random2to1(uv + fixed2(j, k)) * _CGL_BlurRandom);
                    float2 uv2 = uv + offset;
                    if (isCancelEyeDepth(uv2, depth)) {
                        uv2 = uv;
                    }
                    color += PICK_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE, uv2).rgb * BLUR_WEIGHTS[j] * BLUR_WEIGHTS[k];
                }
            }
            return color;
        }

        float3 sampleScreenTextureBlur2(float2 uv, float2 scale, float depth) {    // FAST
            static const int    BLUR_SAMPLE_COUNT = 8;
            static const float2 BLUR_KERNEL[BLUR_SAMPLE_COUNT] = {
                float2(-1.0, -1.0),
                float2(-1.0, +1.0),
                float2(+1.0, -1.0),
                float2(+1.0, +1.0),
                float2(-0.70711, 0),
                float2(0, +0.70711),
                float2(+0.70711, 0),
                float2(0, -0.70711),
            };
            static const float  BLUR_WEIGHT = 1.0 / BLUR_SAMPLE_COUNT;

            float3 color = ZERO_VEC3;
            for (int j = 0; j < BLUR_SAMPLE_COUNT; j++) {
                float2 offset = BLUR_KERNEL[j] * scale * (1 - random2to1(uv + j.xx) * _CGL_BlurRandom);
                float2 uv2 = uv + offset;
                if (isCancelEyeDepth(uv2, depth)) {
                    uv2 = uv;
                }
                color += PICK_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE, uv2).rgb * BLUR_WEIGHT;
            }
            return color;
        }

        float3 sampleScreenTextureBlur3(float2 uv, float2 scale, float depth) {    // OCTAGON
            static const int    BLUR_SAMPLE_COUNT = 8;
            static const float2 BLUR_KERNEL[BLUR_SAMPLE_COUNT] = {
                float2(+0.0, +1.0),
                float2(+1.0, +0.0),
                float2(+0.0, -1.0),
                float2(-1.0, +0.0),
                float2(+0.7, +0.7),
                float2(+0.7, -0.7),
                float2(-0.7, +0.7),
                float2(-0.7, -0.7),
            };
            static const float  BLUR_WEIGHT = 1.0 / BLUR_SAMPLE_COUNT;

            float3 color = ZERO_VEC3;
            for (int j = 0; j < BLUR_SAMPLE_COUNT; j++) {
                float2 offset = BLUR_KERNEL[j] * scale * (1 - random2to1(uv + j.xx) * _CGL_BlurRandom);
                float2 uv2 = uv + offset;
                if (isCancelEyeDepth(uv2, depth)) {
                    uv2 = uv;
                }
                color += PICK_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE, uv2).rgb * BLUR_WEIGHT;
            }
            return color;
        }

        float3 sampleScreenTextureBlur4(float2 uv, float2 scale, float depth) {    // HEXAGON
            static const int    BLUR_SAMPLE_COUNT = 6;
            static const float2 BLUR_KERNEL[BLUR_SAMPLE_COUNT] = {
                float2(0, 1),
                float2(+0.866, +0.5),
                float2(+0.866, -0.5),
                float2(0, -1),
                float2(-0.866, -0.5),
                float2(-0.866, +0.5),
            };
            static const float  BLUR_WEIGHT = 1.0 / BLUR_SAMPLE_COUNT;

            float3 color = ZERO_VEC3;
            for (int j = 0; j < BLUR_SAMPLE_COUNT; j++) {
                float2 offset = BLUR_KERNEL[j] * scale * (1 - random2to1(uv + j.xx) * _CGL_BlurRandom);
                float2 uv2 = uv + offset;
                if (isCancelEyeDepth(uv2, depth)) {
                    uv2 = uv;
                }
                color += PICK_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE, uv2).rgb * BLUR_WEIGHT;
            }
            return color;
        }

        float3 sampleScreenTextureBlur5(float2 uv, float2 scale, float depth) {    // SQUARE
            static const int    BLUR_SAMPLE_COUNT = 4;
            static const float2 BLUR_KERNEL[BLUR_SAMPLE_COUNT] = {
                float2(+0.0, +1.0),
                float2(+1.0, +0.0),
                float2(+0.0, -1.0),
                float2(-1.0, +0.0),
            };
            static const float  BLUR_WEIGHT = 1.0 / BLUR_SAMPLE_COUNT;

            float3 color = ZERO_VEC3;
            for (int j = 0; j < BLUR_SAMPLE_COUNT; j++) {
                float2 offset = BLUR_KERNEL[j] * scale * (1 - random2to1(uv + j.xx) * _CGL_BlurRandom);
                float2 uv2 = uv + offset;
                if (isCancelEyeDepth(uv2, depth)) {
                    uv2 = uv;
                }
                color += PICK_GRAB_TEX2D(_WF_PB_GRAB_TEXTURE, uv2).rgb * BLUR_WEIGHT;
            }
            return color;
        }

#ifdef _WF_LEGACY_FEATURE_SWITCH
        float3 sampleScreenTextureBlur(float2 grab_uv, float2 scale, float depth) {
            return
                _CGL_BlurMode == 0 ? sampleScreenTextureBlur1(grab_uv, scale, depth).rgb :
                _CGL_BlurMode == 1 ? sampleScreenTextureBlur2(grab_uv, scale, depth).rgb :
                _CGL_BlurMode == 2 ? sampleScreenTextureBlur3(grab_uv, scale, depth).rgb :
                _CGL_BlurMode == 3 ? sampleScreenTextureBlur4(grab_uv, scale, depth).rgb :
                sampleScreenTextureBlur5(grab_uv, scale, depth).rgb;
        }
        #define SAMPLE_BLUR sampleScreenTextureBlur
#else
    #if defined(_CGL_BLURFAST_ENABLE)
        #define SAMPLE_BLUR sampleScreenTextureBlur2
    #elif defined(_CGL_BLUROCT_ENABLE)
        #define SAMPLE_BLUR sampleScreenTextureBlur3
    #elif defined(_CGL_BLURHEX_ENABLE)
        #define SAMPLE_BLUR sampleScreenTextureBlur4
    #elif defined(_CGL_BLURSQ_ENABLE)
        #define SAMPLE_BLUR sampleScreenTextureBlur5
    #else
        #define SAMPLE_BLUR sampleScreenTextureBlur1
    #endif
#endif

        void drawFrostedGlass(inout drawing d) {
FEATURE_TGL_ON_BEGIN(_CGL_Enable)
            // GrabScreenPos 計算
            float4 grab_uv = ComputeGrabScreenPos(mul(UNITY_MATRIX_VP, float4(d.ws_vertex.xyz, 1)));
            grab_uv.xy /= grab_uv.w;

            // Scale 計算
            float2 scale = max(_CGL_BlurMin.xx, _CGL_Blur.xx / max(1, length( d.ws_vertex.xyz - worldSpaceViewPointPos() )));
            scale *= UNITY_MATRIX_P._m11 / 100;
#ifdef UNITY_SINGLE_PASS_STEREO
            scale.x *= 0.5;
#endif
            scale.y *= _ScreenParams.x / _ScreenParams.y;

            float depth = -mul(UNITY_MATRIX_V, float4(d.ws_vertex.xyz, 1.0)).z;
            float3 back_color = SAMPLE_BLUR(grab_uv, scale, depth).rgb;

            d.color.rgb = lerp(back_color.rgb, d.color.rgb, saturate(d.color.a));
            d.color.a = 1;
FEATURE_TGL_END
        }

    #else
        #define drawFrostedGlass(d)
    #endif

#endif
