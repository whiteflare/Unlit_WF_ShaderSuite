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

#ifndef INC_UNLIT_WF_FAKEFUR
#define INC_UNLIT_WF_FAKEFUR

    /*
     * authors:
     *      ver:2019/05/18 whiteflare,
     */

    #include "WF_Common.cginc"

    struct appdata_fur {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float2 uv2              : TEXCOORD1;
        float3 normal           : NORMAL;
        float4 tangent          : TANGENT;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2g {
        float2 uv               : TEXCOORD0;
        float4 ls_vertex        : TEXCOORD1;
        float4 ls_light_dir     : TEXCOORD2;
        float3 ls_camera_dir    : TEXCOORD3;
        float3 light_color      : COLOR0;
        float3 light_power      : COLOR1;
        #ifdef _TS_ENABLE
            float  shadow_power : COLOR2;
        #endif
        float3 normal           : TEXCOORD4;
        float2 uv2              : TEXCOORD7;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    struct g2f {
        float4 vertex           : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float4 ls_vertex        : TEXCOORD1;
        float4 ls_light_dir     : TEXCOORD2;
        float3 ls_camera_dir    : TEXCOORD3;
        float3 light_color      : COLOR0;
        float3 light_power      : COLOR1;
        #ifdef _TS_ENABLE
            float  shadow_power : COLOR2;
        #endif
        float3 normal           : TEXCOORD4;
        float2 uv2              : TEXCOORD7;
        float height            : COLOR3;
        UNITY_FOG_COORDS(2)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    float       _CutOffLevel;

    sampler2D   _FurMaskTex;
    sampler2D   _FurNoiseTex;
    float4      _FurNoiseTex_ST;
    float       _FurHeight;
    float       _FurShadowPower;
    uint        _FurRepeat;
    float4      _FurVector;

    v2g vert_fakefur(appdata_fur v) {
        v2g o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

// ここから UnToon と同じ
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.ls_vertex = v.vertex;
        o.ls_light_dir = calcLocalSpaceLightDir(o.ls_vertex);
        o.ls_camera_dir = localSpaceViewDir(o.ls_vertex);

        float3 ambientColor = OmniDirectional_ShadeSH9();

        // 影コントラスト
        #ifdef _TS_ENABLE
        if (TGL_ON(_TS_Enable)) {
            float3 lightColorMain = calcLocalSpaceLightColor(o.ls_vertex, o.ls_light_dir.w);
            float3 lightColorSub4 = OmniDirectional_Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    0 < o.ls_light_dir.w ? unity_LightColor[0].rgb : float3(0, 0, 0),
                    unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb,
                    unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    mul(unity_ObjectToWorld, o.ls_vertex)
                );
            float main = saturate(calcBrightness( lightColorMain ));
            float sub4 = saturate(calcBrightness( lightColorSub4 ));
            float ambient = saturate(calcBrightness( ambientColor ));
            o.shadow_power = saturate( abs(main - sub4) / max(main + sub4, 0.0001) ) * 0.5 + 0.5;
            o.shadow_power = min( o.shadow_power, 1 - smoothstep(0.8, 1, abs(o.ls_light_dir.y)) * 0.5 );
            o.shadow_power = min( o.shadow_power, 1 - saturate(ambient) * 0.5 );
        }
        #endif

        // ライトカラーブレンド
        {
            float3 lightColorMain = _LightColor0.rgb;
            float3 lightColorSub4 = OmniDirectional_Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb,
                    unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb,
                    unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    mul(unity_ObjectToWorld, o.ls_vertex)
                );
            float3 color = max(lightColorMain + lightColorSub4 + ambientColor, float3(0.001, 0.001, 0.001));
            color = saturate( color / calcBrightness(color) );
            o.light_color = (color - 1) * _GL_BrendPower + 1;
        }

        o.normal = normalize(v.normal.xyz);

        SET_ANTIGLARE_LEVEL(v.vertex, o.light_power);
// ここまで UnToon と同じ

        o.uv2 = TRANSFORM_TEX(v.uv2, _FurNoiseTex);

        return o;
    }

    inline g2f initGeomOutput(v2g p) {
        g2f o;
        UNITY_INITIALIZE_OUTPUT(g2f, o);
        UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(g2f, o);
        o.uv                = p.uv;
        o.ls_vertex         = p.ls_vertex;
        o.ls_light_dir      = p.ls_light_dir;
        o.ls_camera_dir     = p.ls_camera_dir;
        o.light_color       = p.light_color;
        o.light_power       = p.light_power;
        #ifdef _TS_ENABLE
            o.shadow_power  = p.shadow_power;
        #endif
        o.normal            = p.normal;
        o.uv2               = p.uv2;
        return o;
    }

    inline void transferGeomVertex(inout g2f o, float4 vb, float4 vu, float height) {
        o.ls_vertex = lerp(vb, vu, height);
        o.vertex = UnityObjectToClipPos( o.ls_vertex );
        o.height = height;
        UNITY_TRANSFER_FOG(o, o.vertex);
    }

    inline v2g lerp_v2g(v2g x, v2g y, float div) {
        v2g o;
        UNITY_INITIALIZE_OUTPUT(v2g, o);
        o.uv                = lerp(x.uv,            y.uv,               div);
        o.ls_vertex         = lerp(x.ls_vertex,     y.ls_vertex,        div);
        o.ls_light_dir      = lerp(x.ls_light_dir,  y.ls_light_dir,     div);
        o.ls_camera_dir     = lerp(x.ls_camera_dir, y.ls_camera_dir,    div);
        o.light_color       = lerp(x.light_color,   y.light_color,      div);
        o.light_power       = lerp(x.light_power,   y.light_power,      div);
        #ifdef _TS_ENABLE
            o.shadow_power  = lerp(x.shadow_power,  y.shadow_power,     div);
        #endif
        o.normal            = lerp(x.normal,        y.normal,           div);
        o.uv2               = lerp(x.uv2,           y.uv2,              div);
        return o;
    }

    void fakefur(v2g v[3], inout TriangleStream<g2f> triStream) {
        float4 vb[3] = { v[0].ls_vertex, v[1].ls_vertex, v[2].ls_vertex };
        float4 vu[3] = vb;
        {
            for (uint i = 0; i < 3; i++) {
                vu[i].xyz += v[i].normal.xyz * _FurHeight;
            }
        }
        {
            // 1回あたり8頂点
            for (uint i = 0; i < 4; i++) {
                uint n = i % 3;
                g2f o = initGeomOutput(v[n]);
                transferGeomVertex(o, vb[n], vu[n], 0); triStream.Append(o);
                transferGeomVertex(o, vb[n], vu[n], 1); triStream.Append(o);
            }
        }
    }

    [maxvertexcount(32)]
    void geom_fakefur(triangle v2g v[3], inout TriangleStream<g2f> triStream) {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(v[0]);

        float4 vb[3] = { v[0].ls_vertex, v[1].ls_vertex, v[2].ls_vertex };
        float4 vu[3] = vb;
        {
            for (uint i = 0; i < 3; i++) {
                vu[i].xyz += v[i].normal.xyz * _FurHeight;
            }
        }
        {
            v2g c = lerp_v2g(v[0], lerp_v2g(v[1], v[2], 0.5), 2.0 / 3.0);
            for (uint i = 0; i < _FurRepeat; i++) {
                float rate = i / (float) _FurRepeat;
                v2g v2[3] = { lerp_v2g(v[0], c, rate), lerp_v2g(v[1], c, rate), lerp_v2g(v[2], c, rate) };
                fakefur(v2, triStream);
            }
        }
    }

    fixed4 frag_fakefur(g2f i) : SV_Target {

// ここから UnToon と同じ
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        // メイン
        float4 color = PICK_MAIN_TEX2D(_MainTex, i.uv) * _Color;

        // 色変換
        affectColorChange(color);

        // BumpMap
        float3 ls_normal = i.normal;
        float3 ls_bump_normal = i.normal;

        // ビュー空間法線
        float3 vs_normal = calcMatcapVector(i.ls_vertex, ls_normal);
        float3 vs_bump_normal = calcMatcapVector(i.ls_vertex, ls_bump_normal);

        // Highlight
        affectMatcapColor(lerp(vs_normal, vs_bump_normal, _HL_BlendNormal), i.uv, color);

        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float3 ws_light_dir = UnityObjectToWorldDir(i.ls_light_dir); // ワールド座標系にてangle_light_cameraを計算する(モデル回転には依存しない)
        float3 ws_camera_dir = UnityObjectToWorldDir(i.ls_camera_dir);
        float angle_light_camera = dot( SafeNormalizeVec2(ws_light_dir.xz), SafeNormalizeVec2(ws_camera_dir.xz) )
            * (1 - smoothstep(0.9, 1, ws_light_dir.y)) * (1 - smoothstep(0.9, 1, ws_camera_dir.y));

        // 階調影
        #ifdef _TS_ENABLE
        if (TGL_ON(_TS_Enable)) {
            float boostlight = 0.5 + 0.25 * SAMPLE_MASK_VALUE(_TS_MaskTex, i.uv, _TS_InvMaskVal).r;
            float brightness = dot(lerp(ls_normal, ls_bump_normal, _TS_BlendNormal), i.ls_light_dir.xyz) * (1 - boostlight) + boostlight;
            // ビュー相対位置シフト
            brightness *= smoothstep(-1, -0.9, angle_light_camera);
            // 影色計算
            float3 base_color = NON_ZERO_VEC3(_TS_BaseColor.rgb * PICK_SUB_TEX2D(_TS_BaseTex, _MainTex, i.uv));
            float3 shadow_color_1st = _TS_1stColor.rgb * PICK_SUB_TEX2D(_TS_1stTex, _MainTex, i.uv) / base_color;
            float3 shadow_color_2nd = _TS_2ndColor.rgb * PICK_SUB_TEX2D(_TS_2ndTex, _MainTex, i.uv) / base_color;
            shadow_color_1st = lerp(float3(1, 1, 1), shadow_color_1st, i.shadow_power * _TS_1stPower);
            shadow_color_2nd = lerp(float3(1, 1, 1), shadow_color_2nd, i.shadow_power * _TS_2ndPower);
            // 色計算
            color.rgb *= saturate(lerp(
                lerp(shadow_color_2nd, shadow_color_1st, smoothstep(_TS_2ndBorder - max(_TS_Feather, 0.001), _TS_2ndBorder, brightness) ),
                float3(1, 1, 1),
                smoothstep(_TS_1stBorder, _TS_1stBorder + max(_TS_Feather, 0.001), brightness)));
        }
        #endif

        // リムライト
        #ifdef _TR_ENABLE
        if (TGL_ON(_TR_Enable)) {
            // vs_normalからリムライト範囲を計算
            float2 rim_uv = vs_normal.xy;
            rim_uv.x *= _TR_PowerSide + 1;
            rim_uv.y *= (_TR_PowerTop + _TR_PowerBottom) / 2 + 1;
            rim_uv.y += (_TR_PowerTop - _TR_PowerBottom) / 2;
            // 順光の場合はリムライトを暗くする
            float3 rimPower = saturate(1 - angle_light_camera) * _TR_Color.a * SAMPLE_MASK_VALUE(_TR_MaskTex, i.uv, _TR_InvMaskVal).rgb;
            // 色計算
            color.rgb = lerp(color.rgb, color.rgb + (_TR_Color.rgb - MEDIAN_GRAY) * rimPower,
                smoothstep(1, 1.05, length(rim_uv)) );
        }
        #endif

        // ライトカラーブレンド
        color.rgb *= i.light_color.rgb;
        // Anti-Glare
        affectAntiGlare(i.light_power, color);

        // Alpha
        affectAlpha(i.uv, color);

        // EmissiveScroll
        affectEmissiveScroll(i.ls_vertex, i.uv, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);
// ここまで UnToon と同じ

        float4 maskTex = tex2D(_FurMaskTex, i.uv);
        if (maskTex.r < 0.01 || maskTex.r <= i.height) {
            discard;
        }

        float3 noise = tex2D(_FurNoiseTex, i.uv2).rgb;
        color = saturate( float4( color - (1 - noise) * _FurShadowPower, calcBrightness(noise) - pow(i.height, 3)) );

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    fixed4 frag_fakefur_cutoff(g2f i) : SV_Target {
        float4 color = frag_fakefur(i);
        if (color.a < _CutOffLevel) {
            discard;
        }
        return color;
    }

#endif
