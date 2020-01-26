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

#ifndef INC_UNLIT_WF_UNTOON
#define INC_UNLIT_WF_UNTOON

    /*
     * authors:
     *      ver:2019/12/22 whiteflare,
     */

    #include "WF_Common.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4 vertex           : POSITION;
        float2 uv               : TEXCOORD0;
        #ifdef _LMAP_ENABLE
            float2 uv_lmap      : TEXCOORD1;
        #endif
        float3 normal           : NORMAL;
        #ifdef _NM_ENABLE
            float4 tangent      : TANGENT;
        #endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vs_vertex        : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float4 ls_vertex        : TEXCOORD1;
        float4 ls_light_dir     : TEXCOORD2;
        float3 light_color      : COLOR0;
        #ifdef _TS_ENABLE
            float shadow_power  : COLOR1;
        #endif
        float3 normal           : TEXCOORD3;
        #ifdef _NM_ENABLE
            float3 tangent      : TEXCOORD4;
            float3 bitangent    : TEXCOORD5;
        #endif
        #ifdef _LMAP_ENABLE
            float2 uv_lmap      : TEXCOORD6;
        #endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    DECL_MAIN_TEX2D(_MainTex);
    float4          _MainTex_ST;
    float4          _Color;

    ////////////////////////////
    // UnToon function
    ////////////////////////////

    #include "WF_UnToon_Function.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    v2f vert(in appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        float4 ws_vertex = mul(unity_ObjectToWorld, v.vertex);

        o.vs_vertex = UnityWorldToClipPos(ws_vertex);
        o.uv = v.uv;
        o.ls_vertex = v.vertex;
        o.ls_light_dir = calcLocalSpaceLightDir(v.vertex);
        #ifdef _LMAP_ENABLE
            o.uv_lmap = v.uv_lmap;
        #endif

        o.normal = normalize(v.normal.xyz);
        #ifdef _NM_ENABLE
            float tan_sign = step(0, v.tangent.w) * 2 - 1;
            if (TGL_OFF(_NM_FlipTangent)) {
                o.tangent = normalize(v.tangent.xyz);
                o.bitangent = cross(o.normal, o.tangent) * tan_sign;
            } else {
                o.tangent = normalize(v.tangent.xyz) * tan_sign;
                o.bitangent = cross(o.normal, o.tangent);
            }
        #endif

        // 環境光取得
        float3 ambientColor = calcAmbientColorVertex(v);
        // 影コントラスト
        calcToonShadeContrast(ws_vertex, o.ls_light_dir, ambientColor, o.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(ws_vertex, ambientColor);

        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        return o;
    }

    float4 frag(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
        float4 ws_vertex = mul(unity_ObjectToWorld, i.ls_vertex);

        // メイン
        float4 color = PICK_MAIN_TEX2D(_MainTex, uv_main) * _Color;

        // 色変換
        affectColorChange(color);
        // BumpMap
        float3 ls_normal = i.normal;

        float3 ws_normal = UnityObjectToWorldNormal(ls_normal);
        float3 ws_bump_normal;
        affectBumpNormal(i, uv_main, ws_bump_normal, color);

        // ビュー空間法線
        float3 vs_normal = calcMatcapVector(ws_vertex, ws_normal);
        float3 vs_bump_normal = calcMatcapVector(ws_vertex, ws_bump_normal);
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i);

        // メタリック
        affectMetallic(i, ws_vertex, uv_main, ws_normal, ws_bump_normal, color);
        // Highlight
        affectMatcapColor(lerp(vs_normal, vs_bump_normal, _HL_BlendNormal), uv_main, color);
        // 階調影
        affectToonShade(i, uv_main, ws_normal, ws_bump_normal, angle_light_camera, color);
        // リムライト
        affectRimLight(i, uv_main, vs_normal, angle_light_camera, color);
        // ScreenTone
        affectOverlayTexture(ws_vertex, uv_main, color);
        // Outline
        affectOutline(uv_main, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;
        // Ambient Occlusion
        affectOcclusion(i, uv_main, color);

        // Alpha
        affectAlphaWithFresnel(uv_main, ws_normal, worldSpaceViewDir(ws_vertex), color);
        // EmissiveScroll
        affectEmissiveScroll(ws_vertex, uv_main, color);

        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        // デバッグビュー
        WF_AFFECT_DEBUGVIEW;

        return color;
    }

    ////////////////////////////
    // アウトライン用 vertex&fragment shader
    ////////////////////////////

    float4 shiftDepthVertex(float3 ws_vertex, float width) {
        float3 ws_camera_dir = _WorldSpaceCameraPos.xyz - ws_vertex.xyz; // ワールド座標で計算する。理由は width をモデルスケール非依存とするため。
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

    float4 shiftOutlineVertex(inout v2f o, float width, float shift) {
        #ifdef _TL_ENABLE
        if (TGL_ON(_TL_Enable)) {
            // 外側にシフトする
            o.ls_vertex.xyz += o.normal.xyz * (width);
            // Zシフト
            float3 ws_vertex = mul(unity_ObjectToWorld, float4(o.ls_vertex.xyz, 1));
            return shiftDepthVertex(ws_vertex, shift);
        } else {
            return UnityObjectToClipPos( ZERO_VEC3 );
        }
        #else
            return UnityObjectToClipPos( ZERO_VEC3 );
        #endif
    }

    float4 shiftOutlineVertex(inout v2f o) {
        #ifdef _TL_ENABLE
            return shiftOutlineVertex(o, _TL_LineWidth * 0.01, -_TL_Z_Shift);
        #else
            return UnityObjectToClipPos( ZERO_VEC3 );
        #endif
    }

    // vertex シェーダでアウトラインメッシュを張るタイプ。NORMALのみサポートする。
    v2f vert_outline(appdata v) {
        // 通常の vert を使う
        v2f o = vert(v);
        // SV_POSITION を上書き
        o.vs_vertex = shiftOutlineVertex(o);

        return o;
    }

    // geometry シェーダでアウトラインメッシュを張るタイプ。NORMALとEDGEをどちらもサポートする。
    [maxvertexcount(10)]
    void geom_outline(triangle v2f v[3], inout TriangleStream<v2f> triStream) {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(v[0]);

        #ifdef _TL_ENABLE
        if (TGL_ON(_TL_Enable)) {
            float width = _TL_LineWidth * 0.01;
            float shift = -_TL_Z_Shift - (TGL_ON(_TL_LineType) ? width * 10 : 0);

            // NORMAL
            v2f p0 = v[0];
            v2f p1 = v[1];
            v2f p2 = v[2];
            p0.vs_vertex = shiftOutlineVertex(p0, width, shift);
            p1.vs_vertex = shiftOutlineVertex(p1, width, shift);
            p2.vs_vertex = shiftOutlineVertex(p2, width, shift);
            triStream.Append(p0);
            triStream.Append(p1);
            triStream.Append(p2);

            // EDGE
            if (TGL_ON(_TL_LineType)) {
                v2f n0 = v[0];
                v2f n1 = v[1];
                v2f n2 = v[2];
                n0.vs_vertex = shiftOutlineVertex(n0, -width, shift);
                n1.vs_vertex = shiftOutlineVertex(n1, -width, shift);
                n2.vs_vertex = shiftOutlineVertex(n2, -width, shift);
                triStream.Append(n2);
                triStream.Append(p0);
                triStream.Append(n0);
                triStream.Append(p1);
                triStream.Append(n1);
                triStream.Append(p2);
                triStream.Append(n2);
            }
        }
        #endif
    }

    ////////////////////////////
    // アウトラインキャンセラ用 vertex&fragment shader
    ////////////////////////////

    sampler2D _UnToonTransparentOutlineCanceller;

    struct v2f_canceller {
        float4      vertex  : SV_POSITION;
        float4      uv_grab : TEXCOORD0;
    };

    v2f_canceller vert_outline_canceller(appdata v) {
        v2f_canceller o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv_grab = o.vertex;
        o.uv_grab.xy = ComputeGrabScreenPos(o.vertex);
        return o;
    }

    float4 frag_outline_canceller(v2f_canceller i) : SV_Target {
        return tex2Dproj(_UnToonTransparentOutlineCanceller, UNITY_PROJ_COORD(i.uv_grab));
    }

    ////////////////////////////
    // EmissiveScroll専用パス用 vertex&fragment shader
    ////////////////////////////

    float _ES_Z_Shift;

    float4 shiftEmissiveScrollVertex(inout v2f o) {
        #ifdef _ES_ENABLE
        if (TGL_ON(_ES_Enable)) {
            float3 ws_vertex = mul(unity_ObjectToWorld, o.ls_vertex);
            return shiftDepthVertex(ws_vertex, _ES_Z_Shift);
        } else {
            return UnityObjectToClipPos( ZERO_VEC3 );
        }
        #else
            return UnityObjectToClipPos( ZERO_VEC3 );
        #endif
    }

    v2f vert_emissiveScroll(appdata v) {
        // 通常の vert を使う
        v2f o = vert(v);
        // SV_POSITION を上書き
        o.vs_vertex = shiftEmissiveScrollVertex(o);

        return o;
    }

    float4 frag_emissiveScroll(v2f i) : SV_Target {
        float4 color = float4(0, 0, 0, 0);

        #ifdef _ES_ENABLE
        if (TGL_ON(_ES_Enable)) {

            // EmissiveScroll
            float2 uv_main = TRANSFORM_TEX(i.uv, _MainTex);
            float4 ws_vertex = mul(unity_ObjectToWorld, i.ls_vertex);
            affectEmissiveScroll(ws_vertex, uv_main, color);

            // Alpha は 0-1 にクランプ
            color.a = saturate(color.a);

        } else {
            // 無効のときはクリッピングする
            discard;
        }
        #else
            // 無効のときはクリッピングする
            discard;
        #endif

        return color;
    }

    ////////////////////////////
    // ZOffset 付き vertex shader
    ////////////////////////////

    float _AL_Z_Offset;

    v2f vert_with_zoffset(appdata v) {
        // 通常の vert を使う
        v2f o = vert(v);
        // SV_POSITION を上書き
        float3 ws_vertex = mul(unity_ObjectToWorld, o.ls_vertex);
        o.vs_vertex = shiftDepthVertex(ws_vertex, _AL_Z_Offset);

        return o;
    }


#endif
