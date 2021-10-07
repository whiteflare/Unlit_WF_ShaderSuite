/*
 *  The MIT License
 *
 *  Copyright 2018-2021 whiteflare.
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

    ////////////////////////////
    // uniform variable
    ////////////////////////////

    #include "WF_INPUT_UnToon.cginc"

    ////////////////////////////
    // main structure
    ////////////////////////////

    struct appdata {
        float4 vertex           : POSITION;
#if defined(_VC_ENABLE) || defined(_OL_ENABLE)
        float4 vertex_color     : COLOR0;
#endif
        float2 uv               : TEXCOORD0;
        float2 uv_lmap          : TEXCOORD1;
        float3 normal           : NORMAL;
#ifdef _NM_ENABLE
            float4 tangent      : TANGENT;
#endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vs_vertex        : SV_POSITION;
#if defined(_VC_ENABLE) || defined(_OL_ENABLE)
        float4 vertex_color     : COLOR0;
#endif
        float3 light_color      : COLOR1;
#ifdef _TS_ENABLE
        float shadow_power      : COLOR2;
#endif
        float2 uv               : TEXCOORD0;
        float2 uv_lmap          : TEXCOORD1;
        float3 ws_vertex        : TEXCOORD2;
        float4 ws_light_dir     : TEXCOORD3;
        float3 normal           : TEXCOORD4;    // world space
#ifdef _NM_ENABLE
            float3 tangent      : TEXCOORD5;    // world space
            float3 bitangent    : TEXCOORD6;    // world space
#endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

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

        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
#ifndef _WF_MAIN_Z_SHIFT
        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);   // 通常の ToClipPos を使う
#else
        o.vs_vertex = shiftDepthVertex(o.ws_vertex, _WF_MAIN_Z_SHIFT);      // Zシフトした値を使う
#endif
#if defined(_VC_ENABLE) || defined(_OL_ENABLE)
        o.vertex_color = v.vertex_color;
#endif
        o.uv = v.uv;
        o.uv_lmap = v.uv_lmap;
        o.ws_light_dir = calcWorldSpaceLightDir(o.ws_vertex);

        #ifdef _NM_ENABLE
            localNormalToWorldTangentSpace(v.normal, v.tangent, o.normal, o.tangent, o.bitangent, _NM_FlipMirror & 1, _NM_FlipMirror & 2);
        #else
            localNormalToWorldTangentSpace(v.normal, o.normal);
        #endif

        // 環境光取得
        float3 ambientColor = calcAmbientColorVertex(v.uv_lmap);
        // 影コントラスト
        calcToonShadeContrast(o.ws_vertex, o.ws_light_dir, ambientColor, o.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(o.ws_vertex, ambientColor);

        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        return o;
    }

    float4 frag(v2f i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        float4 color;
        float2 uv_main;

        // メイン
        affectBaseColor(i.uv, facing, uv_main, color);
        // 頂点カラー
        affectVertexColor(i.vertex_color, color);

        // カラーマスク
        affect3chColorMask(uv_main, color);
        // アルファマスク適用
        affectAlphaMask(uv_main, color);

        // 色変換
        affectColorChange(color);
        // BumpMap
        float3 ws_normal = i.normal;
        float3 ws_bump_normal;
        affectBumpNormal(i, uv_main, ws_bump_normal, color);

        // ビューポイントへの方向
        float3 ws_view_dir = worldSpaceViewPointDir(i.ws_vertex);
        // カメラへの方向
        float3 ws_camera_dir = worldSpaceCameraDir(i.ws_vertex);
        // カメラとライトの位置関係: -1(逆光) ～ +1(順光)
        float angle_light_camera = calcAngleLightCamera(i.ws_vertex, i.ws_light_dir.xyz);

        // matcapベクトルの配列
        float4x4 matcapVector = calcMatcapVectorArray(ws_view_dir, ws_camera_dir, ws_normal, ws_bump_normal);

        // メタリック
        affectMetallic(i, ws_camera_dir, uv_main, ws_normal, ws_bump_normal, color);
        // Highlight
        affectMatcapColor(calcMatcapVector(matcapVector, _HL_BlendNormal, _HL_Parallax).xy, uv_main, color);
        // ラメ
        affectLame(i, uv_main, ws_normal, color);
        // 階調影
        affectToonShade(i, uv_main, ws_normal, ws_bump_normal, angle_light_camera, color);
        // リムライト
        affectRimLight(i, uv_main, calcMatcapVector(matcapVector, _TR_BlendNormal, 0), angle_light_camera, color);
        // Decal
        affectOverlayTexture(i, uv_main, calcMatcapVector(matcapVector, 1, 0.5), color);
        // Outline
        affectOutline(uv_main, color);

        // Anti-Glare とライト色ブレンドを同時に計算
        color.rgb *= i.light_color;
        // Ambient Occlusion
        affectOcclusion(i, uv_main, color);

        // EmissiveScroll
        affectEmissiveScroll(i, uv_main, color);
        // ToonFog
        affectToonFog(i, ws_view_dir, color);

        // フレネル
        affectFresnelAlpha(uv_main, ws_normal, ws_view_dir, color);
        // Alpha は 0-1 にクランプ
        color.a = saturate(color.a);

        // fog
        UNITY_APPLY_FOG(i.fogCoord, color);

        return color;
    }

    ////////////////////////////
    // アウトライン用 vertex&fragment shader
    ////////////////////////////

    float4 shiftOutlineVertex(inout v2f o, float width, float shift) {
        return shiftOutlineVertex(o.ws_vertex, o.normal, width, shift);
    }

    float4 shiftOutlineVertex(inout v2f o) {
        #ifdef _TL_ENABLE
            return shiftOutlineVertex(o, getOutlineShiftWidth(TRANSFORM_TEX(o.uv, _MainTex)), -_TL_Z_Shift);
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
#if SHADER_TARGET >= 40
    [maxvertexcount(16)]
    void geom_outline(triangle v2f v[3], inout TriangleStream<v2f> triStream) {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(v[0]);

#ifdef _TL_ENABLE

#ifdef _WF_LEGACY_FEATURE_SWITCH
        if (TGL_ON(_TL_Enable)) {
#endif

            float width0 = getOutlineShiftWidth(TRANSFORM_TEX(v[0].uv, _MainTex));
            float width1 = getOutlineShiftWidth(TRANSFORM_TEX(v[1].uv, _MainTex));
            float width2 = getOutlineShiftWidth(TRANSFORM_TEX(v[2].uv, _MainTex));
            float shift0 = -_TL_Z_Shift - (TGL_ON(_TL_LineType) ? width0 * 10 : 0);
            float shift1 = -_TL_Z_Shift - (TGL_ON(_TL_LineType) ? width1 * 10 : 0);
            float shift2 = -_TL_Z_Shift - (TGL_ON(_TL_LineType) ? width2 * 10 : 0);

            v2f p0 = v[0];
            v2f p1 = v[1];
            v2f p2 = v[2];
            p0.vs_vertex = shiftOutlineVertex(p0, width0, shift0);
            p1.vs_vertex = shiftOutlineVertex(p1, width1, shift1);
            p2.vs_vertex = shiftOutlineVertex(p2, width2, shift2);

#ifdef _WF_LEGACY_FEATURE_SWITCH
            if (TGL_OFF(_TL_LineType)) {
#endif

#if defined(_WF_LEGACY_FEATURE_SWITCH) | !defined(_TL_EDGE_ENABLE)
            // NORMAL
            triStream.Append(p0);
            triStream.Append(p1);
            triStream.Append(p2);
#endif

#ifdef _WF_LEGACY_FEATURE_SWITCH
            } else {
#endif

#ifdef _TL_EDGE_ENABLE
            // EDGE
            v2f n0 = v[0];
            v2f n1 = v[1];
            v2f n2 = v[2];
            n0.vs_vertex = shiftOutlineVertex(n0, -width0, shift0);
            n1.vs_vertex = shiftOutlineVertex(n1, -width1, shift1);
            n2.vs_vertex = shiftOutlineVertex(n2, -width2, shift2);
            triStream.Append(p2);
            triStream.Append(n2);
            triStream.Append(p0);
            triStream.Append(n0);
            triStream.Append(p1);
            triStream.Append(n1);
            triStream.Append(p2);
            triStream.Append(n2);
            triStream.Append(p1);   // 折り返すことで裏面まで描画する
            triStream.Append(n1);
            triStream.Append(p0);
            triStream.Append(n0);
            triStream.Append(p2);
            triStream.Append(n2);
#endif

#ifdef _WF_LEGACY_FEATURE_SWITCH
            }
#endif

            triStream.RestartStrip();

#ifdef _WF_LEGACY_FEATURE_SWITCH
        }
#endif

#endif  // _TL_ENABLE
    }
#endif  // SHADER_TARGET >= 40

#endif
