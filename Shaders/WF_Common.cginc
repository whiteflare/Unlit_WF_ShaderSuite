/*
 *  The MIT License
 *
 *  Copyright 2018 whiteflare.
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

#ifndef INC_UNLIT_WF_COMMON
#define INC_UNLIT_WF_COMMON

    /*
     * authors:
     *      ver:2019/03/07 whiteflare,
     */

    #define _MATCAP_VIEW_CORRECT_ENABLE
    #define _MATCAP_ROTATE_CORRECT_ENABLE

    static const float3 MEDIAN_GRAY = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : GammaToLinearSpace( float3(0.5, 0.5, 0.5) );
    static const float3 BT709 = { 0.21, 0.72, 0.07 };

    inline float calcBrightness(float3 color) {
        return dot(color, BT709);
    }

    inline float3 calcPointLight1Pos() {
        return float3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
    }

    inline float3 calcPointLight1Color(float3 ws_pos) {
        float3 ls_lightPos = calcPointLight1Pos() - ws_pos;
        float lengthSq = dot(ls_lightPos, ls_lightPos);
        float atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0.x);
        return unity_LightColor[0].rgb * atten;
    }

    inline float4 calcLocalSpaceLightDir(float4 ls_pos) {
        float3 ws_pos = mul(unity_ObjectToWorld, ls_pos);
        float3 pointLight1Color = calcPointLight1Color(ws_pos);

        float3 ws_lightDir;
        float lightType;
        if (calcBrightness(_LightColor0.rgb) < calcBrightness(pointLight1Color)) {
            // ディレクショナルよりポイントライトのほうが明るいならばそちらの方向を採用
            ws_lightDir = calcPointLight1Pos() - ws_pos;
            lightType = -1;

        } else if (any(_WorldSpaceLightPos0.xyz)) {
            // ディレクショナルライトが入っているならばそれを採用
            ws_lightDir = _WorldSpaceLightPos0.xyz;
            lightType = +1;

        } else {
            // 手頃なライトが無いのでワールドスペースの方向決め打ち
            ws_lightDir = float3(1, 1, -1);
            lightType = 0;
        }
        return float4( UnityWorldToObjectDir(ws_lightDir), lightType );
    }

    inline float3 calcLocalSpaceLightColor(float4 ls_pos, float lightType) {
        if (0.5 < lightType) {
            return _LightColor0.rgb; // ディレクショナルライト
        }
        float3 ws_pos = mul(unity_ObjectToWorld, ls_pos);
        float3 pointLight1Color = calcPointLight1Color(ws_pos);
        if (lightType < -0.5) {
            return pointLight1Color;
        }

        float3 ws_lightColor;
        if (calcBrightness(_LightColor0.rgb) < calcBrightness(pointLight1Color)) {
            // ディレクショナルよりポイントライトのほうが明るいならばそちらの方向を採用
            return pointLight1Color;

        } else if (any(_WorldSpaceLightPos0.xyz)) {
            // ディレクショナルライトが入っているならばそれを採用
            return _LightColor0.rgb;

        } else {
            // 手頃なライトが無い
            return float3(0, 0, 0);
        }
    }

    inline float3 OmniDirectional_ShadeSH9() {
        // UnityCG.cginc にある ShadeSH9 の等方向版
        float3 col = 0;
        col = max(col, ShadeSH9( float4(+1, +0, +0, 1) ));
        col = max(col, ShadeSH9( float4(+0, +1, +0, 1) ));
        col = max(col, ShadeSH9( float4(+0, +0, +1, 1) ));
        col = max(col, ShadeSH9( float4(-1, -0, -0, 1) ));
        col = max(col, ShadeSH9( float4(-0, -1, -0, 1) ));
        col = max(col, ShadeSH9( float4(-0, -0, -1, 1) ));
        return col;
    }

    inline float3 OmniDirectional_Shade4PointLights(
        float4 lpX, float4 lpY, float4 lpZ,
        float3 col0, float3 col1, float3 col2, float3 col3,
        float4 lightAttenSq, float3 ws_pos) {
        // UnityCG.cginc にある Shade4PointLights の等方向版

        float4 toLightX = lpX - ws_pos.x;
        float4 toLightY = lpY - ws_pos.y;
        float4 toLightZ = lpZ - ws_pos.z;

        float4 lengthSq
            = toLightX * toLightX
            + toLightY * toLightY
            + toLightZ * toLightZ;
        // ws_normal との内積は取らない。これによって反射光の強さではなく、頂点に当たるライトの強さが取れる。

        // attenuation
        float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);

        float3 col
            = col0 * atten.x
            + col1 * atten.y
            + col2 * atten.z
            + col3 * atten.w;
        return col;
    }

    inline float calcLightPower(float4 ls_vertex) {
        // directional light
        float3 lightColor = _LightColor0;
        #if UNITY_SHOULD_SAMPLE_SH
            // ambient
            lightColor += OmniDirectional_ShadeSH9();
            #ifdef VERTEXLIGHT_ON
                // not important lights
                lightColor += OmniDirectional_Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb,
                    unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb,
                    unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    mul(unity_ObjectToWorld, ls_vertex)
                );
            #endif
        #endif
        return calcBrightness(saturate(lightColor));
    }

    inline float3 worldSpaceCameraPos() {
        #ifdef USING_STEREO_MATRICES
            return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
        #else
            return _WorldSpaceCameraPos;
        #endif
    }

    inline float3 worldSpaceViewDir(float4 ls_vertex) {
        float4 ws_vertex = mul(unity_ObjectToWorld, ls_vertex);
        return normalize(worldSpaceCameraPos() - ws_vertex.xyz);
    }

    inline float3 localSpaceViewDir(float4 ls_vertex) {
        float4 ls_camera_pos = mul(unity_WorldToObject, float4(worldSpaceCameraPos(), 1));
        return normalize(ls_camera_pos.xyz - ls_vertex.xyz);
    }


    ////////////////////////////
    // Alpha Transparent
    ////////////////////////////

    int             _AL_Source;
    float           _AL_Power;
    sampler2D       _AL_MaskTex;

    #ifndef _AL_CustomValue
        #define _AL_CustomValue 1
    #endif

    #ifdef _AL_ENABLE
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

    ////////////////////////////
    // Anti Glare
    ////////////////////////////

    int             _GL_Level;

    inline float calcAntiGlareLevel(float4 ls_vertex) {
        return saturate(calcLightPower(ls_vertex) * 2 + (100 - _GL_Level) * 0.01);
    }
    #define SET_ANTIGLARE_LEVEL(ls_vertex, out) out = calcAntiGlareLevel(ls_vertex)

    inline void affectAntiGlare(float glLevel, inout float4 color) {
        color.rgb = saturate(color.rgb * glLevel);
    }

    ////////////////////////////
    // Highlight and Shadow Matcap
    ////////////////////////////

    inline float3 calcMatcapVector(in float4 ls_vertex, in float3 ls_normal) {
        float3 vs_normal = mul(UNITY_MATRIX_IT_MV, float4(ls_normal, 1)).xyz;

        #ifdef _MATCAP_VIEW_CORRECT_ENABLE
            float3 ws_view_dir = worldSpaceViewDir(ls_vertex);
            float3 base = mul( (float3x3)UNITY_MATRIX_V, ws_view_dir ) * float3(-1, -1, 1) + float3(0, 0, 1);
            float3 detail = vs_normal.xyz * float3(-1, -1, 1);
            vs_normal = base * dot(base, detail) / base.z - detail;
        #endif

        #ifdef _MATCAP_ROTATE_CORRECT_ENABLE
            float2 vs_topdir = mul( (float3x3)UNITY_MATRIX_V, float3(0, 1, 0) ).xy;
            if (any(vs_topdir)) {
                vs_topdir = normalize(vs_topdir);
                float top_angle = sign(vs_topdir.x) * acos( clamp(vs_topdir.y, -1, 1) );
                float2x2 matrixRotate = { cos(top_angle), sin(top_angle), -sin(top_angle), cos(top_angle) };
                vs_normal.xy = mul( vs_normal.xy, matrixRotate );
            }
        #endif

        return normalize( vs_normal );
    }

    #ifdef _HL_ENABLE
        sampler2D   _HL_MatcapTex;
        sampler2D   _HL_MaskTex;
        float4      _HL_MedianColor;
        float       _HL_Range;
        float       _HL_Power;

        inline void affectMatcapColor(float2 matcapVector, float2 mask_uv, inout float4 color) {
            float2 matcap_uv = matcapVector.xy * 0.5 * _HL_Range + 0.5;
            float3 blend_param = (tex2D(_HL_MatcapTex, saturate(matcap_uv) ).rgb - _HL_MedianColor.rgb) * tex2D(_HL_MaskTex, mask_uv).rgb * _HL_Power;

            // 明るすぎ・暗すぎ防止の補正処理
            #if defined(_HL_SOFT_SHADOW) || defined(_HL_SOFT_LIGHT)
            {
                float bb = (blend_param.r + blend_param.g + blend_param.b) / 3;
                float bc = (color.r + color.g + color.b) / 3 - 0.5;
                #ifdef _HL_SOFT_SHADOW
                    // 暗いところに暗い影は落とさない
                    blend_param *= bb < 0 && bc < 0 ? saturate( (bc + 0.5) * 2 ) : 1;
                #endif
                #ifdef _HL_SOFT_LIGHT
                    // 明るいところに明るい光は差さない
                    blend_param *= 0 < bb && 0 < bc ? saturate( 1 - (bc + 0.5) * 2 ) : 1;
                #endif
            }
            #endif

            // ブレンド
            color.rgb = saturate(color.rgb + blend_param);
        }

    #else
        // Dummy
        #define affectMatcapColor(matcapVector, mask_uv, color)
    #endif

    ////////////////////////////
    // Color Change
    ////////////////////////////

    #ifdef _CL_ENABLE
        inline float3 rgb2hsv(float3 c) {
            // i see "https://qiita.com/_nabe/items/c8ba019f26d644db34a8"
            static float4 k = float4( 0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0 );
            static float e = 1.0e-10;
            float4 p = lerp( float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g) );
            float4 q = lerp( float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r) );
            float d = q.x - min(q.w, q.y);
            return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x );
        }

        inline float3 hsv2rgb(float3 c) {
            // i see "https://qiita.com/_nabe/items/c8ba019f26d644db34a8"
            static float4 k = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
            float3 p = abs( frac(c.xxx + k.xyz) * 6.0 - k.www );
            return c.z * lerp( k.xxx, saturate(p - k.xxx), c.y );
        }

        float       _CL_DeltaH;
        float       _CL_DeltaS;
        float       _CL_DeltaV;
        int         _CL_Monochrome;

        inline void affectColorChange(inout float4 color) {
            if (_CL_Monochrome == 1) {
                color.r += color.g + color.b;
                color.g = (color.r - 1) / 2;
                color.b = (color.r - 1) / 2;
            }
            float3 hsv = rgb2hsv( saturate(color.rgb) );
            hsv += float3( _CL_DeltaH, _CL_DeltaS, _CL_DeltaV);
            hsv.r = frac(hsv.r);
            color.rgb = saturate( hsv2rgb( saturate(hsv) ) );
        }

    #else
        // Dummy
        #define affectColorChange(color)
    #endif

    ////////////////////////////
    // Emissive Scroll
    ////////////////////////////

    #ifdef _ES_ENABLE
        int         _ES_Shape;
        float4      _ES_Direction;
        float       _ES_LevelOffset;
        float       _ES_Sharpness;
        float       _ES_Speed;
        int         _ES_AlphaScroll;

        inline float calcEmissivePower(float3 ls_vertex) {
            float time = _Time.y * _ES_Speed - dot(ls_vertex, _ES_Direction.xyz);
            // 周期 2PI、値域 [-1, +1] の関数で光量を決める
            if (_ES_Shape == 0) {
                // 励起波
                float v = pow( 1 - frac(time * UNITY_INV_TWO_PI), _ES_Sharpness + 2 );
                float es_power = 8 * v * (1 - v) - 1;
                return saturate(es_power + _ES_LevelOffset);
            }
            else if (_ES_Shape == 1) {
                // のこぎり波
                float es_power = 1 - 2 * frac(time * UNITY_INV_TWO_PI);
                return saturate(es_power * _ES_Sharpness + _ES_LevelOffset);
            }
            else if (_ES_Shape == 2) {
                // 正弦波
                float es_power = sin( time );
                return saturate(es_power * _ES_Sharpness + _ES_LevelOffset);
            }
            else {
                // 定数
                float es_power = 1;
                return saturate(es_power + _ES_LevelOffset);
            }
        }

        sampler2D   _ES_MaskTex;
        float4      _ES_Color;

        inline void affectEmissiveScroll(float4 ls_vertex, float2 mask_uv, inout float4 color) {
            float es_power = calcEmissivePower(ls_vertex);
            color.rgb = max(0, color.rgb + _ES_Color.rgb * es_power * tex2D(_ES_MaskTex, mask_uv).rgb);
            if (_ES_AlphaScroll) {
                color.a = max(color.a, _ES_Color.a * es_power);
            }
        }

    #else
        // Dummy
        #define affectEmissiveScroll(ls_vertex, mask_uv, color)
    #endif

#endif
