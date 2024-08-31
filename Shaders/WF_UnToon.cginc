/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
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
        float4  vertex              : POSITION;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color        : COLOR0;
#endif
        float2  uv                  : TEXCOORD0;
        float2  uv2                 : TEXCOORD1;
        half3   normal              : NORMAL;
#ifdef _V2F_HAS_TANGENT
        half4   tangent             : TANGENT;
#endif
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4  vs_vertex           : SV_POSITION;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color        : COLOR0;
#endif
        half3   light_color         : COLOR1;
#ifdef _V2F_HAS_SHADOWPOWER
        half    shadow_power        : COLOR2;
#endif
        float2  uv                  : TEXCOORD0;
        float2  uv2                 : TEXCOORD1;
        float3  ws_vertex           : TEXCOORD2;
        half3   ws_light_dir        : TEXCOORD3;
        half3   ws_normal           : TEXCOORD4;
#ifdef _V2F_HAS_TANGENT
        half3   ws_tangent          : TEXCOORD5;
        half3   ws_bitangent        : TEXCOORD6;
#endif
        UNITY_FOG_COORDS(7)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    #define IN_FRAG v2f

    #if defined(USING_STEREO_MATRICES)
        #define _MV_HAS_PARALLAX
    #endif
    #if defined(_NM_ENABLE) && !defined(_WF_LEGACY_FEATURE_SWITCH)
        #define _MV_HAS_NML
    #endif
    #if defined(_NS_ENABLE) && !defined(_WF_LEGACY_FEATURE_SWITCH)
        #define _MV_HAS_NML2
    #endif

    struct MatcapVector {
        float3  vs_normal_center;
#ifdef _MV_HAS_PARALLAX
        float3  diff_parallax;
#endif
#ifdef _MV_HAS_NML
        float3  diff_normal;
#endif
#ifdef _MV_HAS_NML2
        float3  diff_normal2;
#endif
    };
    #define WF_TYP_MATVEC   MatcapVector

    struct drawing {
        half4   color;
        float2  uv1;
        float2  uv2;
        float2  uv_main;
        float3  ws_vertex;
        half3   ws_normal;
#ifdef _V2F_HAS_TANGENT
        half3   ws_tangent;
        half3   ws_bitangent;
#endif
        half3   ws_bump_normal;
        half3   ws_detail_normal;
        half3   ws_view_dir;
        half3   ws_camera_dir;
        half3   ws_light_dir;
        half    angle_light_camera;
        half3   light_color;
        uint    facing;
        WF_TYP_MATVEC matcapVector;
#ifdef _V2F_HAS_VERTEXCOLOR
        half4   vertex_color;
#endif
#ifdef _V2F_HAS_SHADOWPOWER
        half    shadow_power;
#endif
    };

    drawing prepareDrawing(IN_FRAG i, uint facing) {
        drawing d = (drawing) 0;

        d.color         = half4(1, 1, 1, 1);
        d.uv1           = i.uv;
        d.uv_main       = i.uv;
        d.uv2           = i.uv2;
        d.facing        = facing;
        d.ws_vertex     = i.ws_vertex;
        d.light_color   = i.light_color;
        d.ws_light_dir  = i.ws_light_dir;
        d.ws_normal     = normalize(i.ws_normal);
#ifdef _V2F_HAS_TANGENT
        d.ws_tangent    = normalize(i.ws_tangent);
        d.ws_bitangent  = normalize(i.ws_bitangent);
#endif
#ifdef _V2F_HAS_VERTEXCOLOR
        d.vertex_color  = i.vertex_color;
#endif
#ifdef _V2F_HAS_SHADOWPOWER
        d.shadow_power  = i.shadow_power;
#endif
        d.ws_view_dir   = worldSpaceViewPointDir(d.ws_vertex);
        d.ws_camera_dir = worldSpaceCameraDir(d.ws_vertex);

        return d;
    }

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
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.ws_vertex = UnityObjectToWorldPos(v.vertex.xyz);
#ifndef _WF_MAIN_Z_SHIFT
        o.vs_vertex = UnityObjectToClipPos(v.vertex.xyz);   // 通常の ToClipPos を使う
#else
        o.vs_vertex = shiftDepthVertex(o.ws_vertex, _WF_MAIN_Z_SHIFT);      // Zシフトした値を使う
#endif
#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color = v.vertex_color;
#endif
        o.uv = v.uv;
        o.uv2 = v.uv2;
        half4 ws_light_dir = calcWorldSpaceLightDir(o.ws_vertex);
        o.ws_light_dir = ws_light_dir.xyz;

#ifdef _V2F_HAS_TANGENT
        localNormalToWorldTangentSpace(v.normal, v.tangent, o.ws_normal, o.ws_tangent, o.ws_bitangent, _FlipMirror & 1, _FlipMirror & 2);
#else
        localNormalToWorldTangentSpace(v.normal, o.ws_normal);
#endif

        // 環境光取得
        float3 ambientColor = calcAmbientColorVertex(v.uv2);
        // 影コントラスト
        calcToonShadeContrast(o.ws_vertex, ws_light_dir, ambientColor, o.shadow_power);
        // Anti-Glare とライト色ブレンドを同時に計算
        o.light_color = calcLightColorVertex(o.ws_vertex, ambientColor);

        UNITY_TRANSFER_FOG(o, o.vs_vertex);
        affectNearClipCancel(o.vs_vertex);

        return o;
    }

    half4 frag(v2f i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        drawing d = prepareDrawing(i, facing);
        d.color = _Color;

        prepareMainTex(i, d);
        prepareBumpNormal(i, d);
        prepareDetailNormal(i, d);
        d.angle_light_camera    = calcAngleLightCamera(d.ws_vertex, d.ws_light_dir);
        d.matcapVector = calcMatcapVectorArray(d.ws_view_dir, d.ws_camera_dir, d.ws_normal, d.ws_bump_normal, d.ws_detail_normal);

        drawMainTex(d);             // メインテクスチャ
        drawMainTex2nd(d);          // メインテクスチャ2nd
        drawBackTex(d);             // 裏面テクスチャ
        drawVertexColor(d);         // 頂点カラー
        drawAlphaMask(d);           // アルファ

        drawGradientMap(d);         // グラデーションマップ
        drawColorChange(d);         // 色変換

        drawBumpNormal(d);          // ノーマルマップ
        drawMetallic(d);            // メタリック

        drawMatcapColor(d);         // マットキャップ
        drawLame(d);                // ラメ

        drawToonShade(d);           // 階調影
        drawRimShadow(d);           // リムシャドウ
        drawRimLight(d);            // リムライト

        drawOverlayTexture(d);      // オーバーレイ
        drawOutline(d);             // アウトライン

        // Anti-Glare とライト色ブレンドを同時に計算
        d.color.rgb *= d.light_color;

        drawOcclusion(d);           // オクルージョンとライトマップ
        drawDistanceFade(d);        // 距離フェード
        drawEmissiveScroll(d);      // エミッション

        drawToonFog(d);             // トゥーンフォグ
        drawFresnelAlpha(d);        // フレネル

        drawDissolve(d);            // ディゾルブ

        drawRefraction(d);          // リフラクション
        drawFrostedGlass(d);        // すりガラス
        drawGhostTransparent(d);    // ゴースト

        // fog
        UNITY_APPLY_FOG(i.fogCoord, d.color);
        // Alpha は 0-1 にクランプ
        d.color.a = saturate(d.color.a);

        return d.color;
    }

    ////////////////////////////
    // アウトライン用 vertex&fragment shader
    ////////////////////////////

    float4 shiftOutlineVertex(inout v2f o, float width, float shift) {
        return shiftOutlineVertex(o.ws_vertex, o.ws_normal, width, shift); // NCC済み
    }

    float4 shiftOutlineVertex(inout v2f o) {
        #ifdef _TL_ENABLE
            return shiftOutlineVertex(o, getOutlineShiftWidth(TRANSFORM_TEX(o.uv, _MainTex)), -_TL_Z_Shift); // NCC済み
        #else
            return DISCARD_VS_VERTEX_ZERO;
        #endif
    }

    // vertex シェーダでアウトラインメッシュを張るタイプ。NORMALのみサポートする。
    v2f vert_outline(appdata v) {
        // 通常の vert を使う
        v2f o = vert(v);
        // SV_POSITION を上書き
        o.vs_vertex = shiftOutlineVertex(o); // NCC済み

        return o;
    }

    // geometry シェーダでアウトラインメッシュを張るタイプ。NORMALとEDGEをどちらもサポートする。
#if SHADER_TARGET >= 40
    [maxvertexcount(16)]
    void geom_outline(triangle v2f v[3], inout TriangleStream<v2f> triStream) {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(v[0]);

#ifdef _TL_ENABLE

FEATURE_TGL_ON_BEGIN(_TL_Enable)

        float width0 = getOutlineShiftWidth(TRANSFORM_TEX(v[0].uv, _MainTex));
        float width1 = getOutlineShiftWidth(TRANSFORM_TEX(v[1].uv, _MainTex));
        float width2 = getOutlineShiftWidth(TRANSFORM_TEX(v[2].uv, _MainTex));
        float shift0 = -_TL_Z_Shift - (TGL_ON(_TL_LineType) ? width0 * 10 : 0);
        float shift1 = -_TL_Z_Shift - (TGL_ON(_TL_LineType) ? width1 * 10 : 0);
        float shift2 = -_TL_Z_Shift - (TGL_ON(_TL_LineType) ? width2 * 10 : 0);

        v2f p0 = v[0];
        v2f p1 = v[1];
        v2f p2 = v[2];
        p0.vs_vertex = shiftOutlineVertex(p0, width0, shift0); // NCC済み
        p1.vs_vertex = shiftOutlineVertex(p1, width1, shift1); // NCC済み
        p2.vs_vertex = shiftOutlineVertex(p2, width2, shift2); // NCC済み

#ifdef _WF_LEGACY_FEATURE_SWITCH
        if (TGL_OFF(_TL_LineType)) {
#endif

#if defined(_WF_LEGACY_FEATURE_SWITCH) || !defined(_TL_EDGE_ENABLE)
        // NORMAL
        triStream.Append(p0);
        triStream.Append(p1);
        triStream.Append(p2);
#endif

#ifdef _WF_LEGACY_FEATURE_SWITCH
        } else {
#endif

#if defined(_WF_LEGACY_FEATURE_SWITCH) || defined(_TL_EDGE_ENABLE)
        // EDGE
        v2f n0 = v[0];
        v2f n1 = v[1];
        v2f n2 = v[2];
        n0.vs_vertex = shiftOutlineVertex(n0, -width0, shift0); // NCC済み
        n1.vs_vertex = shiftOutlineVertex(n1, -width1, shift1); // NCC済み
        n2.vs_vertex = shiftOutlineVertex(n2, -width2, shift2); // NCC済み
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

FEATURE_TGL_END

#endif  // _TL_ENABLE
    }
#endif  // SHADER_TARGET >= 40

    ////////////////////////////
    // Depth&Normal のみ描く fragment shader
    ////////////////////////////

    half4 frag_depth(v2f i, uint facing: SV_IsFrontFace) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        drawing d = prepareDrawing(i, facing);
        d.color = _Color;

        prepareMainTex(i, d);
        prepareBumpNormal(i, d);

        drawMainTex(d);             // メインテクスチャ
        drawVertexColor(d);         // 頂点カラー

        // アルファ計算
        #ifdef _AL_ENABLE
            drawAlphaMask(d);       // アルファ

            if (d.color.a < 0.5) {
                discard;
                return ZERO_VEC4;
            }
        #endif

        return half4(d.ws_bump_normal, 0);
    }

#endif
