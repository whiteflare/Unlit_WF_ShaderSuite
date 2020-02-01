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

#ifndef INC_UNLIT_WF_COMMON
#define INC_UNLIT_WF_COMMON

    /*
     * authors:
     *      ver:2019/11/24 whiteflare,
     */

    #define _MATCAP_VIEW_CORRECT_ENABLE
    #define _MATCAP_ROTATE_CORRECT_ENABLE

    #define TGL_ON(value)   (0.5 <= value)
    #define TGL_OFF(value)  (value < 0.5)
    #define TGL_01(value)   step(0.5, value)

    static const float3 MEDIAN_GRAY = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : GammaToLinearSpace( float3(0.5, 0.5, 0.5) );
    static const float3 BT601 = { 0.299, 0.587, 0.114 };
    static const float3 BT709 = { 0.21, 0.72, 0.07 };

    #define MAX3(r, g, b)   max(r, max(g, b) )
    #define AVE3(r, g, b)   ((r + g + b) / 3)
    #define MAX_RGB(v)      max(v.r, max(v.g, v.b))
    #define AVE_RGB(v)      ((v.r + v.g + v.b) / 3)


    inline float2 SafeNormalizeVec2(float2 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < 0.0001) {
            return float2(0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    inline float3 SafeNormalizeVec3(float3 in_vec) {
        float lenSq = dot(in_vec, in_vec);
        if (lenSq < 0.0001) {
            return float3(0, 0, 0);
        }
        return in_vec * rsqrt(lenSq);
    }

    inline float calcBrightness(float3 color) {
        return dot(color, BT601);
    }

    inline float3 calcPointLight1Pos() {
        return float3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
    }

    inline float3 calcPointLight1Color(float3 ws_pos) {
        float3 ws_lightPos = calcPointLight1Pos();
        if (ws_lightPos.x == 0 && ws_lightPos.y == 0 && ws_lightPos.z == 0) {
            return float3(0, 0, 0); // XYZすべて0はポイントライト未設定と判定する
        }
        float3 ls_lightPos = ws_lightPos - ws_pos;
        float lengthSq = dot(ls_lightPos, ls_lightPos);
        float atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0.x);
        return unity_LightColor[0].rgb * atten;
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

        if ( !any(float3(lpX.x, lpY.x, lpZ.x)) ) {
            col0.rgb = 0;
        }

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
        // ambient
        lightColor += OmniDirectional_ShadeSH9();
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
        return SafeNormalizeVec3(worldSpaceCameraPos() - ws_vertex.xyz);
    }

    inline float3 localSpaceViewDir(float4 ls_vertex) {
        float4 ls_camera_pos = mul(unity_WorldToObject, float4(worldSpaceCameraPos(), 1));
        return SafeNormalizeVec3(ls_camera_pos.xyz - ls_vertex.xyz);
    }

    inline bool isInMirror() {
        return unity_CameraProjection[2][0] != 0.0f || unity_CameraProjection[2][1] != 0.0f;
    }

    ////////////////////////////
    // Alpha Transparent
    ////////////////////////////

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
            float baseAlpha = pickAlpha(uv, color.a) * _AL_Power * _AL_CustomValue;
            color.a = baseAlpha;
        }

        inline void affectAlphaWithFresnel(float2 uv, float3 normal, float3 viewdir, inout float4 color) {
            float baseAlpha = pickAlpha(uv, color.a) * _AL_Power * _AL_CustomValue;

            #ifndef _AL_FRESNEL_ENABLE
                // ベースアルファ
                color.a = baseAlpha;
            #else
                // フレネルアルファ
                float maxValue = max( pickAlpha(uv, color.a) * _AL_Power, _AL_Fresnel ) * _AL_CustomValue;
                float fa = 1 - abs( dot( SafeNormalizeVec3(normal), SafeNormalizeVec3(viewdir) ) );
                color.a = lerp( baseAlpha, maxValue, fa * fa * fa * fa );
            #endif
        }
    #else
        #define affectAlpha(uv, color)                              color.a = 1.0
        #define affectAlphaWithFresnel(uv, normal, viewdir, color)  color.a = 1.0
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
    uint            _GL_LightMode;
    float           _GL_CustomAzimuth;
    float           _GL_CustomAltitude;

    inline uint calcAutoSelectMainLight(float3 ws_pos) {
        float3 pointLight1Color = calcPointLight1Color(ws_pos);

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

    inline float3 calcHorizontalCoordSystem(float azimuth, float alt) {
        azimuth = radians(azimuth + 90);
        alt = radians(alt);
        return normalize( float3(cos(azimuth) * cos(alt), sin(alt), -sin(azimuth) * cos(alt)) );
    }

    inline float3 calcPointLight1Dir(float3 ws_pos) {
        ws_pos = calcPointLight1Pos() - ws_pos;
        if (dot(ws_pos, ws_pos) < 0.1) {
            ws_pos = float3(0, 1, 0);
        }
        return UnityWorldToObjectDir( ws_pos );
    }

    inline float4 calcLocalSpaceLightDir(float4 ls_pos) {
        float3 ws_pos = mul(unity_ObjectToWorld, ls_pos);

        uint mode = _GL_LightMode;
        if (mode == LIT_MODE_AUTO) {
            mode = calcAutoSelectMainLight(ws_pos);
        }
        if (mode == LIT_MODE_ONLY_DIR_LIT) {
            return float4( UnityWorldToObjectDir( _WorldSpaceLightPos0.xyz ), +1 );
        }
        if (mode == LIT_MODE_ONLY_POINT_LIT) {
            return float4( calcPointLight1Dir(ws_pos) , -1 );
        }
        if (mode == LIT_MODE_CUSTOM_WORLDSPACE) {
            return float4( UnityWorldToObjectDir(calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude)), 0 );
        }
        if (mode == LIT_MODE_CUSTOM_LOCALSPACE) {
            return float4( calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude), 0 );
        }
        return float4( UnityWorldToObjectDir(calcHorizontalCoordSystem(_GL_CustomAzimuth, _GL_CustomAltitude)), 0 );
    }

    inline float3 calcLocalSpaceLightColor(float4 ls_pos, float lightType) {
        if ( TGL_ON(-lightType) ) {
            float3 ws_pos = mul(unity_ObjectToWorld, ls_pos);
            float3 pointLight1Color = calcPointLight1Color(ws_pos);
            return pointLight1Color; // ポイントライト
        }
        return _LightColor0.rgb; // ディレクショナルライト
    }

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
        int         _ES_Shape;
        float4      _ES_Direction;
        float       _ES_LevelOffset;
        float       _ES_Sharpness;
        float       _ES_Speed;
        float       _ES_AlphaScroll;

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
            if (TGL_ON(_ES_Enable)) {
                float es_power = calcEmissivePower(ls_vertex);
                float3 es_color = tex2D(_ES_MaskTex, mask_uv).rgb;

                color.rgb = lerp(color.rgb,
                    color.rgb * (1 - es_power) + es_power * _ES_Color.rgb * es_color.rgb,
                    MAX_RGB(es_color) );

                #ifdef _ES_FORCE_ALPHASCROLL
                    color.a = max(color.a, es_power * _ES_Color.a * MAX_RGB(es_color));
                #else
                    if (TGL_ON(_ES_AlphaScroll)) {
                        color.a = max(color.a, es_power * _ES_Color.a * MAX_RGB(es_color));
                    }
                #endif
            }
        }

    #else
        // Dummy
        #define affectEmissiveScroll(ls_vertex, mask_uv, color)
    #endif

    ////////////////////////////
    // ReflectionProbe Sampler
    ////////////////////////////

    inline float4 pickReflectionProbe(float4 ls_vertex, float3 ls_normal, float lod) {
        float4 ws_vertex = mul(unity_ObjectToWorld, ls_vertex);
        float3 ws_camera_dir = normalize(_WorldSpaceCameraPos.xyz - ws_vertex );
        float3 reflect_dir = reflect(-ws_camera_dir, UnityObjectToWorldNormal(ls_normal));

        float3 dir0 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        float3 dir1 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

        float4 color0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dir0, lod);
        float4 color1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, dir1, lod);

        color0.rgb = DecodeHDR(color0, unity_SpecCube0_HDR);
        color1.rgb = DecodeHDR(color1, unity_SpecCube1_HDR);

        return lerp(color1, color0, unity_SpecCube0_BoxMin.w);
    }

    inline float3 pickReflectionCubemap(samplerCUBE cubemap, half4 cubemap_HDR, float4 ls_vertex, float3 ls_normal, float lod) {
        float4 ws_vertex = mul(unity_ObjectToWorld, ls_vertex);
        float3 ws_camera_dir = normalize(_WorldSpaceCameraPos.xyz - ws_vertex );
        float3 reflect_dir = reflect(-ws_camera_dir, UnityObjectToWorldNormal(ls_normal));

        float4 color = texCUBElod(cubemap, float4(reflect_dir, lod) );
        return DecodeHDR(color, cubemap_HDR);
    }

#endif

#ifndef INC_UNLIT_WF_MATCAPSHADOWS
#define INC_UNLIT_WF_MATCAPSHADOWS

    /*
     * authors:
     *      ver:2019/03/17 whiteflare,
     */

    struct appdata {
        float4 vertex       : POSITION;
        float2 uv           : TEXCOORD0;
        float3 normal       : NORMAL;
        #ifdef _NM_ENABLE
            float4 tangent  : TANGENT;
        #endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vertex           : SV_POSITION;
        float4 ls_vertex        : TEXCOORD0;
        float2 uv               : TEXCOORD1;
        float3 normal           : TEXCOORD2;
        #ifdef _NM_ENABLE
            float3 tangent      : TEXCOORD3;
            float3 bitangent    : TEXCOORD4;
            float3 lightDir     : TEXCOORD5;
        #endif
        #ifdef _OL_ENABLE
            float4 vs_vertex    : TEXCOORD6;
        #endif
        float lightPower        : COLOR0;
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    sampler2D       _MainTex;
    float4          _MainTex_ST;
    float4          _Color;
    float           _AL_CutOff;

    float           _NM_Enable;
    #ifdef _NM_ENABLE
        sampler2D   _BumpMap;
        float       _NM_Power;
    #endif


    #ifdef _HL_ENABLE
        float       _HL_Enable;
        sampler2D   _HL_MatcapTex;
        sampler2D   _HL_MaskTex;
        float4      _HL_MedianColor;
        float       _HL_Range;
        float       _HL_Power;
        float       _HL_SoftShadow;
        float       _HL_SoftLight;

        inline void affectMatcapColor(float2 matcapVector, float2 mask_uv, inout float4 color) {
            if (TGL_ON(_HL_Enable)) {
                float2 matcap_uv = matcapVector.xy * 0.5 * _HL_Range + 0.5;
                float3 blend_param = (tex2D(_HL_MatcapTex, saturate(matcap_uv) ).rgb - _HL_MedianColor.rgb) * tex2D(_HL_MaskTex, mask_uv).rgb * _HL_Power;

                // 明るすぎ・暗すぎ防止の補正処理
                if (TGL_ON(_HL_SoftShadow) || TGL_ON(_HL_SoftLight)) {
                    float bb = (blend_param.r + blend_param.g + blend_param.b) / 3;
                    float bc = (color.r + color.g + color.b) / 3 - 0.5;
                    if (TGL_ON(_HL_SoftShadow)) {
                        // 暗いところに暗い影は落とさない
                        blend_param *= bb < 0 && bc < 0 ? saturate( (bc + 0.5) * 2 ) : 1;
                    }
                    if (TGL_ON(_HL_SoftLight)) {
                        // 明るいところに明るい光は差さない
                        blend_param *= 0 < bb && 0 < bc ? saturate( 1 - (bc + 0.5) * 2 ) : 1;
                    }
                }

                // ブレンド
                color.rgb = saturate(color.rgb + blend_param);
            }
        }

    #else
        // Dummy
        #define affectMatcapColor(matcapVector, mask_uv, color)
    #endif

    #ifdef _OL_ENABLE
        float       _OL_Enable;
        sampler2D   _OL_OverlayTex;
        float4      _OL_OverlayTex_ST;
        float       _OL_Power;
        int         _OL_ScreenType;
        int         _OL_BlendType;
        float       _OL_Scroll_U;
        float       _OL_Scroll_V;

        inline float4 computeNonStereoGrabScreenPos(float4 pos) {
            // UnityCG.cginc にある ComputeGrabScreenPos の UNITY_SINGLE_PASS_STEREO を考慮しない版
            #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
            #else
                float scale = 1.0;
            #endif
            float4 o = pos * 0.5f;
            o.xy = float2(o.x, o.y * scale) + o.w;
            o.zw = pos.zw;
            return o;
        }
        inline float2 computeOverlayTex(float4 vs_vertex, float2 uv) {
            float2 scr;
            if (_OL_ScreenType == 1) {
                 float4 screenPos = computeNonStereoGrabScreenPos(vs_vertex);
                 scr = screenPos.xy / screenPos.w;
                 scr.y *= _ScreenParams.y / _ScreenParams.x;
             } else {
                scr = uv;
             }
             scr.x += frac(_OL_Scroll_U * _Time.x);
             scr.y += frac(_OL_Scroll_V * _Time.x);
             return TRANSFORM_TEX(scr, _OL_OverlayTex);
        }
        inline float3 blendOverlayColor(float3 color, float3 ov_color) {
            if (_OL_BlendType == 1) {
                // 加算
                return color + ov_color * _OL_Power;
            }
            if (_OL_BlendType == 2) {
                // 重み付き乗算
                return color * lerp( float3(1, 1, 1), ov_color, _OL_Power);
            }
            // ブレンド
            return lerp(color, ov_color, _OL_Power);
        }
    #endif

    v2f vert(in appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vertex = UnityObjectToClipPos(v.vertex);
        o.ls_vertex = v.vertex;
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);

        if (TGL_ON(_NM_Enable)) {
            o.normal = v.normal;
            #ifdef _NM_ENABLE
                o.tangent = v.tangent;
                o.bitangent = cross(o.normal, o.tangent);
                o.lightDir = calcLocalSpaceLightDir(o.ls_vertex);
            #endif
        } else {
            // NormalMapを使用しないときは頂点側でMatcap計算してnormalに突っ込む
            o.normal = calcMatcapVector(v.vertex, v.normal);
        }

        #ifdef _OL_ENABLE
            o.vs_vertex = o.vertex;
        #endif

        SET_ANTIGLARE_LEVEL(v.vertex, o.lightPower);

        UNITY_TRANSFER_FOG(o, o.vertex);
        return o;
    }

    float4 frag(v2f i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float4 color =
        #ifdef _SOLID_COLOR
            _Color;
        #else
            tex2D(_MainTex, i.uv);
        #endif

        // 色変換
        affectColorChange(color);

        // BumpMap
        float3 ls_normal = i.normal;
        #ifdef _NM_ENABLE
        if (TGL_ON(_NM_Enable)) {
            // 法線計算
            float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal); // vertex周辺のlocal法線空間
            ls_normal = normalize( mul(UnpackNormal( tex2D(_BumpMap, i.uv) ), tangentTransform) ); // 法線マップ参照
            // 光源とブレンド
            float diffuse = saturate((dot(ls_normal, i.lightDir.xyz) / 2 + 0.5) * _NM_Power + (1.0 - _NM_Power));
            color.rgb *= diffuse; // Unlitなのでライトの色は考慮しない
        }
        #endif

        // Highlight
        float3 matcapVector =
            TGL_ON(_NM_Enable) ?
                calcMatcapVector(i.ls_vertex, ls_normal) // Matcap計算
                : i.normal; // NormalMap未使用時はvertで計算したMatcapVectorを使う
        affectMatcapColor(matcapVector, i.uv, color);

        // Overlay
        #ifdef _OL_ENABLE
        if (TGL_ON(_OL_Enable)) {
            float2 overlay = computeOverlayTex(i.vs_vertex, i.uv);
            color.rgb = blendOverlayColor(color.rgb, tex2D(_OL_OverlayTex, overlay).rgb);
        }
        #endif

        // Anti-Glare
        affectAntiGlare(i.lightPower, color);

        // Alpha
        affectAlpha(i.uv, color);

        // EmissiveScroll
        affectEmissiveScroll(i.ls_vertex, i.uv, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    fixed4 frag_cutout_upper(v2f i) : SV_Target {
        float4 color = frag(i);
        clip(color.a - _AL_CutOff);
        return color;
    }

    fixed4 frag_cutout_lower(v2f i) : SV_Target {
        float4 color = frag(i);
        clip(_AL_CutOff - color.a);
        return color;
    }

#endif
