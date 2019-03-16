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

#ifndef INC_UNLIT_WF_UNTOON_SHADOWCASTER
#define INC_UNLIT_WF_UNTOON_SHADOWCASTER

    /*
     * authors:
     *      ver:2019/03/12 whiteflare,
     */

    struct v2f_shadow {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
    };

    float           _GL_CastShadow;
    sampler2D       _MainTex;
    float4          _MainTex_ST;
    float           _AL_CutOff;

    #ifdef _AL_ENABLE
        int             _AL_Source;
        float           _AL_Power;
        sampler2D       _AL_MaskTex;

        #ifndef _AL_CustomValue
            #define _AL_CustomValue 1
        #endif

        inline void affectAlpha(float2 uv, inout float4 color) {
            if (_AL_Source == 1) {
                color.a = tex2D(_AL_MaskTex, uv).r * _AL_Power * _AL_CustomValue;
            }
            else if (_AL_Source == 2) {
                color.a = tex2D(_AL_MaskTex, uv).a * _AL_Power * _AL_CustomValue;
            }
            else {
                color.a = color.a * _AL_Power * _AL_CustomValue;
            }
        }
    #else
        #define affectAlpha(uv, color) color.a = 1.0
    #endif

    v2f_shadow vert_shadow(appdata_base v) {
        v2f_shadow o;
        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
        if (_GL_CastShadow < 0.5) {
            // 無効化
            o.pos = UnityObjectToClipPos( float3(0, 0, 0) );
        }
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
    }

    float4 frag_shadow_caster(v2f_shadow i) {
        SHADOW_CASTER_FRAGMENT(i)
    }

    float4 frag_shadow(v2f_shadow i) : SV_Target {
        if (_GL_CastShadow < 0.5) {
            discard;
            return float4(0, 0, 0, 0);
        }

        // ShadowCaster
        float4 color = frag_shadow_caster(i);

        // アルファ計算
        affectAlpha(i.uv, color);
        if (color.a < _AL_CutOff) {
            discard;
            return float4(0, 0, 0, 0);
        }

        return color;
    }

    float4 frag_shadow_cutout(v2f_shadow i) : SV_Target {
        float4 color = frag_shadow(i);
        if (color.a < _AL_CutOff) {
            discard;
        }
        return color;
    }

#endif
