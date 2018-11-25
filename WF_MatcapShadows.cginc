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
     *      ver:2018/11/25 whiteflare,
     */

    #define _MATCAP_VIEW_CORRECT_ENABLE
    #define _COLOR_ARRANGE_ENABLE

    struct appdata {
        float4 vertex       : POSITION;
        float2 uv           : TEXCOORD0;
        float3 normal       : NORMAL;
        #ifdef _NM_ENABLE
            float4 tangent  : TANGENT;
        #endif
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
            float2 overlay      : TEXCOORD6;
        #endif
        #ifndef _GL_LEVEL_OFF
            float lightPower    : COLOR0;
        #endif
        UNITY_FOG_COORDS(7)
    };

    uniform sampler2D       _MainTex;
    uniform float4          _MainTex_ST;
    uniform float4          _Color;

    uniform float           _AL_Power;
    uniform sampler2D       _AL_MaskTex;
    uniform float           _AL_CutOff;

    #ifdef _NM_ENABLE
        uniform sampler2D   _BumpMap;
        uniform float       _NM_Power;
    #endif

    #ifdef _HL_ENABLE
        uniform sampler2D   _HL_MatcapTex;
        uniform float4      _HL_MedianColor;
        uniform float       _HL_Range;
        uniform float       _HL_Power;
        uniform sampler2D   _HL_MaskTex;
    #endif

    #ifdef _OL_ENABLE
        uniform sampler2D   _OL_OverlayTex;
        uniform float4      _OL_OverlayTex_ST;
        uniform float       _OL_Power;
        uniform float       _OL_Scroll_U;
        uniform float       _OL_Scroll_V;
    #endif

    #ifdef _ES_ENABLE
        uniform sampler2D   _ES_MaskTex;
        uniform float4      _ES_Color;
        uniform float4      _ES_Direction;
        uniform float       _ES_LevelOffset;
        uniform float       _ES_Sharpness;
        uniform float       _ES_Speed;
    #endif

    static float3 BT709 = { 0.21, 0.72, 0.07 };

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
            float3 base = mul( UNITY_MATRIX_V, float4(ws_view_dir, 0) ).xyz * float3(-1, -1, 1) + float3(0, 0, 1);
            float3 detail = vs_normal.xyz * float3(-1, -1, 1);
            vs_normal = base * dot(base, detail) / base.z - detail;
        #endif

        return vs_normal;
    }

    inline float3 calcLocalSpaceLightDir() {
        float4 ws_light_pos = lerp( float4(0, 20, 0, 1), _WorldSpaceLightPos0, any(_WorldSpaceLightPos0.xyz) );
        float4 ls_light_pos = mul(unity_WorldToObject, ws_light_pos);
        return normalize(ls_light_pos.xyz);
    }

    inline float calcBrightness(float3 color) {
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

    inline float calcEmissivePower(float3 ls_vertex) {
        #ifdef _ES_ENABLE
            float time = _Time.y * _ES_Speed - dot(ls_vertex, _ES_Direction.xyz);
            float es_power = sin( time ) + 0.5 + _ES_LevelOffset;
            return saturate( es_power * _ES_Sharpness );
        #else
            return 0;
        #endif
    }

    inline float3 colorize(float3 base, float3 over) {
        float bBase = (base.r + base.g + base.b) / 3;
        float bOver = (over.r + over.g + over.b) / 3;
        float3 a1 = (over - bOver) / bOver;
        float3 a2 = (over - 1 + bOver) / (1 - bOver);
        float3 s = sign(a1);
        return saturate( bBase + s * min( s * a1 * bBase, s * a2 * (1 - bBase) ) );
    }

    inline float3 blendColor(float3 base, float3 over, float rate) {
        #ifdef _COLOR_ARRANGE_ENABLE
            if (rate <= 0) {
                return base;
            }
            float3 middle = colorize(base, over);
            if (rate <= 0.5) {
                return lerp( base, middle, saturate(rate * 2) );
            }
            return lerp( middle, over, saturate( (rate - 0.5) * 2) );
        #else
            return lerp( base, over, rate);
        #endif
    }

    v2f vert(in appdata v) {
        v2f o;
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
            float4 screenPos = ComputeGrabScreenPos(o.vertex);
            float2 scr = screenPos.xy / screenPos.w;
            scr.y *= _ScreenParams.y / _ScreenParams.x;
            scr.x += frac(_OL_Scroll_U * _Time.x);
            scr.y += frac(_OL_Scroll_V * _Time.x);
            o.overlay = TRANSFORM_TEX(scr, _OL_OverlayTex);
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

    fixed4 frag(v2f i) : SV_Target {
        float4 color =
        #ifdef _SOLID_COLOR
        	_Color;
        #else
        	tex2D(_MainTex, i.uv);
        #endif

        float3 matcapVector;

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
            matcapVector = calcMatcapVector(i.ls_vertex, ws_normal);
        #else
            // NormalMap未使用時はvertで計算したMatcapVectorを使う
            matcapVector = i.normal;
        #endif

        // Highlight
        #ifdef _HL_ENABLE
            // Matcap highlight color
            float2 matcap_uv = normalize(matcapVector.xyz) * 0.5 * _HL_Range + 0.5;
            float4 hl_color = tex2D(_HL_MatcapTex, saturate(matcap_uv) );
            color.rgb += (hl_color.rgb - _HL_MedianColor.rgb) * tex2D(_HL_MaskTex, i.uv).rgb * _HL_Power;  // MatcapColor を加算(減算)合成
        #endif

        // Overlay
        #ifdef _OL_ENABLE
            float4 ov_color = tex2D(_OL_OverlayTex, i.overlay);
            #ifdef _OL_BLENDTYPE_ADD
                // 加算
                color.rgb += ov_color.rgb * _OL_Power;
            #elif _OL_BLENDTYPE_MUL
                // 重み付き乗算
                color.rgb *= lerp( float3(1, 1, 1), ov_color.rgb, _OL_Power);
            #else
                // ブレンド
                color.rgb = lerp(color.rgb, ov_color.rgb, _OL_Power);
            #endif
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

        // EmissiveScroll
        #ifdef _ES_ENABLE
            float es_power = calcEmissivePower(i.ls_vertex) * tex2D(_ES_MaskTex, i.uv).rgb;
            color.rgb = max(0, color.rgb + _ES_Color.rgb * es_power);
            color.a = max(color.a, _ES_Color.a * es_power);
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
