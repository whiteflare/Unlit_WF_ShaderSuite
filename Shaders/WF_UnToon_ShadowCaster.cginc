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

#ifndef INC_UNLIT_WF_UNTOON_SHADOWCASTER
#define INC_UNLIT_WF_UNTOON_SHADOWCASTER

    /*
     * authors:
     *      ver:2020/10/13 whiteflare,
     */

    #include "WF_Common.cginc"

    struct v2f_shadow {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    float           _GL_CastShadow;
    DECL_MAIN_TEX2D(_MainTex);
    float4          _MainTex_ST;
    float4          _Color;
    float           _Cutoff;

    #ifndef WF_TEX2D_ALPHA_MAIN_ALPHA
        #define WF_TEX2D_ALPHA_MAIN_ALPHA(uv)   alpha
    #endif
    #ifndef WF_TEX2D_ALPHA_MASK_RED
        #define WF_TEX2D_ALPHA_MASK_RED(uv)     PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).r
    #endif
    #ifndef WF_TEX2D_ALPHA_MASK_ALPHA
        #define WF_TEX2D_ALPHA_MASK_ALPHA(uv)   PICK_SUB_TEX2D(_AL_MaskTex, _MainTex, uv).a
    #endif

    #ifdef _AL_ENABLE
        int             _AL_Source;
        float           _AL_Power;
        DECL_SUB_TEX2D(_AL_MaskTex);

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
                if (baseAlpha < 0.5) {
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

    #else
        #define affectAlpha(uv, color) color.a = 1.0
    #endif

    v2f_shadow vert_shadow(appdata_base v) {
        v2f_shadow o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f_shadow, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
        if (TGL_OFF(_GL_CastShadow)) {
            // 無効化
            o.pos = UnityObjectToClipPos( float3(0, 0, 0) );
        }
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

        UNITY_TRANSFER_INSTANCE_ID(v, o);
        return o;
    }

    float4 frag_shadow_caster(v2f_shadow i) {
        SHADOW_CASTER_FRAGMENT(i)
    }

    float4 frag_shadow(v2f_shadow i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        if (TGL_OFF(_GL_CastShadow)) {
            discard;
            return float4(0, 0, 0, 0);
        }

        // アルファ計算
        #ifdef _AL_ENABLE
            float4 color = PICK_MAIN_TEX2D(_MainTex, i.uv) * _Color;
            affectAlpha(i.uv, color);
            if (color.a < 0.5) {
                discard;
                return float4(0, 0, 0, 0);
            }
        #endif

        return frag_shadow_caster(i);
    }

#endif
