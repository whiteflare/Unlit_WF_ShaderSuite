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

#ifndef INC_UNLIT_WF_MATCAPSHADOWS
#define INC_UNLIT_WF_MATCAPSHADOWS

    /*
     * authors:
     *      ver:2019/02/09 whiteflare,
     */

    #define _MATCAP_VIEW_CORRECT_ENABLE
    #define _MATCAP_ROTATE_CORRECT_ENABLE

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
        #ifndef _GL_LEVEL_OFF
            float lightPower    : COLOR0;
        #endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    sampler2D       _MainTex;
    float4          _MainTex_ST;
    float4          _Color;

    float           _AL_Power;
    sampler2D       _AL_MaskTex;
    float           _AL_CutOff;

    #ifdef _CL_ENABLE
        float       _CL_DeltaH;
        float       _CL_DeltaS;
        float       _CL_DeltaV;
    #endif

    #ifdef _NM_ENABLE
        sampler2D   _BumpMap;
        float       _NM_Power;
    #endif

    #ifdef _HL_ENABLE
        sampler2D   _HL_MatcapTex;
        float4      _HL_MedianColor;
        float       _HL_Range;
        float       _HL_Power;
        sampler2D   _HL_MaskTex;
    #endif

    #ifdef _OL_ENABLE
        sampler2D   _OL_OverlayTex;
        float4      _OL_OverlayTex_ST;
        float       _OL_Power;
        float       _OL_Scroll_U;
        float       _OL_Scroll_V;
    #endif

    #ifdef _ES_ENABLE
        sampler2D   _ES_MaskTex;
        float4      _ES_Color;
        float4      _ES_Direction;
        float       _ES_LevelOffset;
        float       _ES_Sharpness;
        float       _ES_Speed;
    #endif

    inline float3 calcMatcapVector(in float4 ls_vertex, in float3 ls_normal) {
        float3 vs_normal = mul(UNITY_MATRIX_IT_MV, float4(ls_normal, 1)).xyz;

        #ifdef _MATCAP_VIEW_CORRECT_ENABLE
            float3 cameraPos =
                #ifdef USING_STEREO_MATRICES
                    (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
                #else
                    _WorldSpaceCameraPos;
                #endif
            float4 ws_vertex = mul(unity_ObjectToWorld, ls_vertex);
            float3 ws_view_dir = normalize(cameraPos.xyz - ws_vertex.xyz);
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

    inline float3 calcLocalSpaceLightDir() {
        float4 ws_light_pos = lerp( float4(0, 20, 0, 1), _WorldSpaceLightPos0, any(_WorldSpaceLightPos0.xyz) );
        float4 ls_light_pos = mul(unity_WorldToObject, ws_light_pos);
        return normalize(ls_light_pos.xyz);
    }

    inline float calcBrightness(float3 color) {
        static float3 BT709 = { 0.21, 0.72, 0.07 };
        return dot(color, BT709);
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
    #endif

    #ifdef _OL_ENABLE
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
            #ifdef _OL_SCREEN_VIEW_XY
                 float4 screenPos = computeNonStereoGrabScreenPos(vs_vertex);
                 float2 scr = screenPos.xy / screenPos.w;
                 scr.y *= _ScreenParams.y / _ScreenParams.x;
             #else
                float2 scr = uv;
             #endif
             scr.x += frac(_OL_Scroll_U * _Time.x);
             scr.y += frac(_OL_Scroll_V * _Time.x);
             return TRANSFORM_TEX(scr, _OL_OverlayTex);
        }
        inline float3 blendOverlayColor(float3 color, float3 ov_color) {
            #ifdef _OL_BLENDTYPE_ADD
                // 加算
                return color + ov_color * _OL_Power;
            #elif _OL_BLENDTYPE_MUL
                // 重み付き乗算
                return color * lerp( float3(1, 1, 1), ov_color, _OL_Power);
            #else
                // ブレンド
                return lerp(color, ov_color, _OL_Power);
            #endif
        }
    #endif

    #ifdef _ES_ENABLE
        inline float calcEmissivePower(float3 ls_vertex) {
            float time = _Time.y * _ES_Speed - dot(ls_vertex, _ES_Direction.xyz);
            float es_power =
                // 周期 2PI、値域 [-1, +1] の関数で光量を決める
                #ifdef _ES_SHAPE_SIN_WAVE
                    // 正弦波
                    sin( time );
                #elif _ES_SHAPE_SAWTOOTH_WAVE
                    // のこぎり波
                    1 - 2 * frac(time * UNITY_INV_TWO_PI);
                #else
                    // 定数
                    1;
                #endif
            return saturate( es_power * _ES_Sharpness + _ES_LevelOffset);
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

        #ifdef _NM_ENABLE
            o.normal = v.normal;
            o.tangent = v.tangent;
            o.bitangent = cross(o.normal, o.tangent);
            o.lightDir = calcLocalSpaceLightDir();
        #else
            // NormalMapを使用しないときは頂点側でMatcap計算してnormalに突っ込む
            o.normal = calcMatcapVector(v.vertex, v.normal);
        #endif

        #ifdef _OL_ENABLE
            o.vs_vertex = o.vertex;
        #endif

        #ifndef _GL_LEVEL_OFF
            o.lightPower = saturate(calcLightPower(v.vertex) * 2
                #ifdef _GL_LEVEL_BRIGHT
                    + 0.2
                #elif _GL_LEVEL_DARK
                    + 0.03
                #endif
            );
        #endif

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
        #ifdef _CL_ENABLE
            #ifdef _CL_MONOCHROME
                color.r += color.g + color.b;
                color.g = (color.r - 1) / 2;
                color.b = (color.r - 1) / 2;
            #endif
            float3 hsv = rgb2hsv( saturate(color.rgb) );
            hsv += float3( _CL_DeltaH, _CL_DeltaS, _CL_DeltaV);
            hsv.r = frac(hsv.r);
            color.rgb = saturate( hsv2rgb( saturate(hsv) ) );
        #endif

        // BumpMap
        #ifdef _NM_ENABLE
            // 法線計算
            float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal); // vertexのworld回転行列
            float3 ls_normal = UnpackNormal( tex2D(_BumpMap, i.uv) ); // 法線マップ参照
            float3 ws_normal = normalize( mul(ls_normal, tangentTransform) ); // world内の法線を作成
            // 光源とブレンド
            float diffuse = saturate((dot(ws_normal, i.lightDir.xyz) / 2 + 0.5) * _NM_Power + (1.0 - _NM_Power));
            color.rgb *= diffuse; // Unlitなのでライトの色は考慮しない
            // Matcap計算
            float3 matcapVector = calcMatcapVector(i.ls_vertex, ws_normal);
        #else
            // NormalMap未使用時はvertで計算したMatcapVectorを使う
            float3 matcapVector = i.normal;
        #endif

        // Highlight
        #ifdef _HL_ENABLE
            float2 matcap_uv = matcapVector.xy * 0.5 * _HL_Range + 0.5;
            float3 blend_param = (tex2D(_HL_MatcapTex, saturate(matcap_uv) ).rgb - _HL_MedianColor.rgb) * tex2D(_HL_MaskTex, i.uv).rgb * _HL_Power;
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
        #endif

        // Overlay
        #ifdef _OL_ENABLE
            float2 overlay = computeOverlayTex(i.vs_vertex, i.uv);
            color.rgb = blendOverlayColor(color.rgb, tex2D(_OL_OverlayTex, overlay).rgb);
        #endif

        // Anti-Glare
        #ifndef _GL_LEVEL_OFF
            color.rgb = saturate(color.rgb * i.lightPower);
        #endif

        // Alpha
        #ifdef _AL_SOURCE_MAIN_TEX_ALPHA
            color.a = color.a * _AL_Power;
        #elif _AL_SOURCE_MASK_TEX_RED
            color.a = tex2D(_AL_MaskTex, i.uv).r * _AL_Power;
        #elif _AL_SOURCE_MASK_TEX_ALPHA
            color.a = tex2D(_AL_MaskTex, i.uv).a * _AL_Power;
        #else
            color.a = 1.0;
        #endif
        #ifdef _AL_CustomValue
            color.a *= _AL_CustomValue;
        #endif

        // EmissiveScroll
        #ifdef _ES_ENABLE
            float es_power = calcEmissivePower(i.ls_vertex);
            color.rgb = max(0, color.rgb + _ES_Color.rgb * es_power * tex2D(_ES_MaskTex, i.uv).rgb);
            #ifdef _ES_ALPHASCROLL
                color.a = max(color.a, _ES_Color.a * es_power);
            #endif
        #endif

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
