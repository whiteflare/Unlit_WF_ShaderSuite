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

#ifndef INC_UNLIT_WF_UNTOON
#define INC_UNLIT_WF_UNTOON

    /*
     * authors:
     *      ver:2019/03/02 whiteflare,
     */

    #include "WF_Common.cginc"

    struct appdata {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        float3 normal           : NORMAL;
        #ifdef _NM_ENABLE
            float4 tangent      : TANGENT;
        #endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vertex           : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float4 ls_vertex        : TEXCOORD1;
        float4 ls_light_dir     : TEXCOORD2;
        float3 ls_camera_dir    : TEXCOORD3;
        float  shadow_power     : COLOR0;
        float3 normal           : TEXCOORD4;
        #ifdef _NM_ENABLE
            float3 tangent      : TEXCOORD5;
            float3 bitangent    : TEXCOORD6;
        #endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_OUTPUT_STEREO
    };

    sampler2D       _MainTex;
    float4          _MainTex_ST;
    float4          _Color;
    float           _AL_CutOff;

    #ifdef _NM_ENABLE
        sampler2D   _BumpMap;
        float       _NM_Power;
    #endif

    #ifdef _TS_ENABLE
        float4      _TS_1stColor;
        float4      _TS_2ndColor;
        float       _TS_1stBorder;
        float       _TS_2ndBorder;
        float       _TS_Feather;
    #endif

    #ifdef _TR_ENABLE
        float4      _TR_Color;
        float4      _TR_MedianColor;
        float       _TR_PowerTop;
        float       _TR_PowerSide;
        float       _TR_PowerBottom;
        sampler2D   _TR_MaskTex;
        float       _TR_InvMaskTex;
    #endif

    #ifdef _TL_ENABLE
        float4      _TL_LineColor;
        float       _TL_LineWidth;
        sampler2D   _TL_MaskTex;
        float       _TL_InvMaskTex;
        float       _TL_Z_Shift;
    #endif

    v2f vert(in appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.ls_vertex = v.vertex;
        o.ls_light_dir = calcLocalSpaceLightDir(o.ls_vertex) * float4(1, 0.5, 1, 1); // 高さ方向のライト位置にはあまり影響されないように
        o.ls_camera_dir = localSpaceViewDir(o.ls_vertex);

        // 影コントラスト
        {
            float main = saturate( calcBrightness(calcLocalSpaceLightColor(o.ls_vertex, o.ls_light_dir.w)) );
            float pt4 = saturate( calcBrightness(OmniDirectional_Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    0 < o.ls_light_dir.w ? unity_LightColor[0].rgb : float3(0, 0, 0),
                    unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb,
                    unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    mul(unity_ObjectToWorld, o.ls_vertex)
                )) );
            float ambient = saturate( calcBrightness(OmniDirectional_ShadeSH9()) );
            o.shadow_power = min( saturate( abs(main - pt4) / max(main + pt4, 0.0001) ) * 0.5 + 0.5, saturate(1 - ambient * 0.5) );
        }

        o.normal = v.normal;
        #ifdef _NM_ENABLE
            o.tangent = v.tangent;
            o.bitangent = cross(o.normal, o.tangent);
        #endif

        UNITY_TRANSFER_FOG(o, o.vertex);
        return o;
    }

    #define MASK_VALUE(tex, uv, inv)        saturate( inv < 0.5 ? tex2D(tex, uv).rgb : 1 - tex2D(tex, uv).rgb )
    #define MASK_VALUE_LOD(tex, uv, inv)    saturate( inv < 0.5 ? tex2Dlod(tex, float4(uv.x, uv.y, 0, 0)).rgb : 1 - tex2Dlod(tex, float4(uv.x, uv.y, 0, 0)).rgb )

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
        {
            // 法線計算
            float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal); // vertex周辺のlocal法線空間
            ls_normal = normalize( mul(UnpackNormal( tex2D(_BumpMap, i.uv) ), tangentTransform) ); // 法線マップ参照
            // 陰影を付けるために若干の影を追加する
            color.rgb *= saturate((dot(ls_normal, i.ls_light_dir.xyz) / 2 + 0.5) * _NM_Power + (1.0 - _NM_Power)); // ここではライトの色を考慮しない
        }
        #endif

        // matcapベクトル算出
        float3 vs_normal = calcMatcapVector(i.ls_vertex, ls_normal);
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = dot(i.ls_light_dir.xyz, i.ls_camera_dir);

        // 光源とブレンド
        #ifdef _TS_ENABLE
        {
            float brightness = 
            #ifdef _TS_BOOSTLIGHT
                dot(ls_normal, i.ls_light_dir.xyz) * 0.25 + 0.75;
            #else
                dot(ls_normal, i.ls_light_dir.xyz) * 0.5 + 0.5;
            #endif
            // ビュー相対位置シフト
            brightness *= saturate(angle_light_camera * 2 + 2);
            // 色計算
            color.rgb = lerp(
                lerp(
                    // 影2
                    color.rgb * lerp(float3(1, 1, 1), _TS_2ndColor.rgb, i.shadow_power),
                    // 影1
                    color.rgb * lerp(float3(1, 1, 1), _TS_1stColor.rgb, i.shadow_power),
                    smoothstep(_TS_2ndBorder - max(0.0001, _TS_Feather), _TS_2ndBorder, brightness) ),
                // ベースカラー
                color.rgb,
                smoothstep(_TS_1stBorder, _TS_1stBorder + max(0.0001, _TS_Feather), brightness));
        }
        #endif

        // リムライト加算
        #ifdef _TR_ENABLE
        {
            // matcapベクトルからリムライト範囲を計算
            float2 rim_uv = float2(
                vs_normal.x * (_TR_PowerSide + 1),
                vs_normal.y * ( (_TR_PowerTop + _TR_PowerBottom) / 2 + 1) + (_TR_PowerTop - _TR_PowerBottom) / 2 );
            // 順光の場合はリムライトを暗くする
            float rimPower = saturate(1 - angle_light_camera) * _TR_Color.a * MASK_VALUE(_TR_MaskTex, i.uv, _TR_InvMaskTex).rgb;
            // 色計算
            color.rgb = lerp(color.rgb, color.rgb + (_TR_Color.rgb - MEDIAN_GRAY) * rimPower,
                smoothstep(1, 1.05, length(rim_uv)) );
        }
        #endif

        // Alpha
        affectAlpha(i.uv, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    // アウトライン用
    v2f vert_outline(appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.ls_vertex = v.vertex;
        o.normal = v.normal;
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);

        #ifdef _TL_ENABLE
            // マスクテクスチャ参照
            float mask = MASK_VALUE_LOD(_TL_MaskTex, o.uv, _TL_InvMaskTex).r;
            // 外側にシフトする
            o.ls_vertex.xyz += normalize( v.normal ).xyz * _TL_LineWidth * 0.01 * mask;
            // カメラ方向の z シフト量を計算
            // ここは view space の計算が必要なので ObjSpaceViewDir を直に使用する
            float3 vecZShift = normalize( ObjSpaceViewDir(o.ls_vertex) ) * _TL_Z_Shift;
            if (unity_OrthoParams.w < 0.5) {
                // カメラが perspective のときは単にカメラ方向の逆にシフトする
                o.ls_vertex.xyz -= vecZShift;
                o.vertex = UnityObjectToClipPos( o.ls_vertex );
            } else {
                // カメラが orthographic のときはシフト後の z のみ採用する
                o.vertex = UnityObjectToClipPos( o.ls_vertex );
                o.ls_vertex.xyz -= vecZShift;
                o.vertex.z = UnityObjectToClipPos( o.ls_vertex ).z;
            }
        #else
            o.vertex = UnityObjectToClipPos( o.ls_vertex );
        #endif

        UNITY_TRANSFER_FOG(o, o.vertex);
        return o;
    }

    float4 frag_outline(v2f i) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
        #ifdef _TL_ENABLE
            // アウトライン側の色を計算
            float4 lineColor = _TL_LineColor;
            UNITY_APPLY_FOG(i.fogCoord, lineColor);
            // ベース側の色を計算
            float4 baseColor = frag(i);
            // ブレンドして返却
            return float4( lerp(baseColor.rgb, lineColor.rgb, lineColor.a), 1);
        #else
            // 無効のときはクリッピングする
            clip(-1);
            return float4(0, 0, 0, 0);
        #endif
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
