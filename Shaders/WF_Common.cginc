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

    float3 PositionOf(float4x4 mat) {
        return mat._m03_m13_m23;
    }

//    float3 ScaleOf(float3x3 mat) {
//        return float3(
//            length(mat._m00_m10_m20),
//            length(mat._m01_m11_m21),
//            length(mat._m02_m12_m22)
//        );
//    }
//
//    float3 ScaleOf(float4x4 mat) {
//        return ScaleOf((float3x3)mat);
//    }
//
//    float3x3 RotationOf(float3x3 mat, float3 scale) {
//        mat._m00_m10_m20 /= scale.x;
//        mat._m01_m11_m21 /= scale.y;
//        mat._m02_m12_m22 /= scale.z;
//        return mat;
//    }
//
//    float3x3 RotationOf(float4x4 mat, float3 scale) {
//        return RotationOf((float3x3)mat,scale);
//    }
//
//    float3x3 Columns(float3 column0, float3 column1, float3 column2) {
//        float3x3 ret;
//        ret._m00_m10_m20 = column0;
//        ret._m01_m11_m21 = column1;
//        ret._m02_m12_m22 = column2;
//        return ret;
//    }
//
//    float4x4 Columns(float4 column0, float4 column1, float4 column2, float4 column3) {
//        float4x4 ret;
//        ret._m00_m10_m20_m30 = column0;
//        ret._m01_m11_m21_m31 = column1;
//        ret._m02_m12_m22_m32 = column2;
//        ret._m03_m13_m23_m33 = column3;
//        return ret;
//    }

    float4x4 BuildMatrix(float3x3 mat, float3 offset) {
        return float4x4(
            float4(mat[0], offset.x),
            float4(mat[1], offset.y),
            float4(mat[2], offset.z),
            float4(0, 0, 0, 1)
        );
    }

//    float3x3 LookAt(float3 dir, float3 up) {
//        float3 x = normalize(cross(up, dir));
//        float3 y = cross(dir, x);
//        return Columns(x, y, dir);
//    }

    float3x3 InverseLookAt(float3 dir, float3 up) {
        float3 x = normalize(cross(up, dir));
        float3 y = cross(dir, x);
        return float3x3(x, y, dir);
    }

    // 回転行列の中間値を算出
    float3x3 RMatrixAverage(float3x3 a, float3x3 b) {
//        // 列優先メモリレイアウトのOpenGLと、行優先メモリレイアウトのDirectXで分岐
//        #if SHADER_TARGET_GLSL
//            float3 iy = (a._m01_m11_m21 + b._m01_m11_m21) * 0.5;
//            float3 iz = normalize((a._m02_m12_m22 + b._m02_m12_m22) * 0.5);
//            return LookAt(iz, iy);
//        #else
            float3 iy = (a[1] + b[1]) * 0.5;
            float3 iz = normalize((a[2] + b[2]) * 0.5);
            return InverseLookAt(iz, iy);
//        #endif
    }

    // 移動回転行列の中間値を算出
    float4x4 TRMatrixAverage(float4x4 a, float4x4 b) {
        return BuildMatrix( RMatrixAverage((float3x3)a, (float3x3)b), (PositionOf(a) + PositionOf(b)) * 0.5 );
    }

    #if USING_STEREO_MATRICES
       #define WorldSpaceFaceRotation   RMatrixAverage((float3x3)unity_StereoCameraToWorld[0], (float3x3)unity_StereoCameraToWorld[1])
       #define FaceToWorld              TRMatrixAverage(unity_StereoCameraToWorld[0], unity_StereoCameraToWorld[1])
    #else
       #define WorldSpaceFaceRotation   ((float3x3)unity_CameraToWorld)
       #define FaceToWorld              unity_CameraToWorld
    #endif

    inline float3 calcMatcapVector(float4 ls_vertex, float3 ls_normal) {
        float3 vs_normal = mul(mul(float4(ls_normal, 1), unity_WorldToObject), FaceToWorld);

        #ifdef _MATCAP_VIEW_CORRECT_ENABLE
            float3 ws_view_dir = worldSpaceViewDir(ls_vertex);
            float3 base = mul( ws_view_dir, WorldSpaceFaceRotation ) - float3(0, 0, 1);
            float3 detail = vs_normal.xyz;
            vs_normal = base * dot(base, detail) / base.z + detail;
        #endif

        #ifdef _MATCAP_ROTATE_CORRECT_ENABLE
            float2 vs_topdir = WorldSpaceFaceRotation[1].xy;
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
