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

#if UNITY_EDITOR

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine;

namespace UnlitWF
{
    /// <summary>
    /// 辞書本体。ユーティリティ関数は他のクラスにて定義する。
    /// </summary>
    internal static class WFShaderDictionary
    {
        /// <summary>
        /// シェーダ名のリスト。
        /// </summary>
        public static readonly List<WFShaderName> ShaderNameList = new List<WFShaderName>() {
            new WFShaderName("UnToon", "Basic", "Opaque",                       "UnlitWF/WF_UnToon_Opaque"),
            new WFShaderName("UnToon", "Basic", "TransCutout",                  "UnlitWF/WF_UnToon_TransCutout"),
            new WFShaderName("UnToon", "Basic", "Transparent",                  "UnlitWF/WF_UnToon_Transparent"),
            new WFShaderName("UnToon", "Basic", "Transparent3Pass",             "UnlitWF/WF_UnToon_Transparent3Pass"),
            new WFShaderName("UnToon", "Basic", "Transparent_Mask",             "UnlitWF/WF_UnToon_Transparent_Mask"),
            new WFShaderName("UnToon", "Basic", "Transparent_MaskOut",          "UnlitWF/WF_UnToon_Transparent_MaskOut"),
            new WFShaderName("UnToon", "Basic", "Transparent_MaskOut_Blend",    "UnlitWF/WF_UnToon_Transparent_MaskOut_Blend"),

            new WFShaderName("UnToon", "Mobile", "Opaque",                      "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"),
            new WFShaderName("UnToon", "Mobile", "TransCutout",                 "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransCutout"),
            new WFShaderName("UnToon", "Mobile", "Transparent",                 "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"),
            new WFShaderName("UnToon", "Mobile", "TransparentOverlay",          "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransparentOverlay"),
            new WFShaderName("UnToon", "Mobile", "LineOnly_Opaque",             "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque"),
            new WFShaderName("UnToon", "Mobile", "LineOnly_TransCutout",        "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_TransCutout"),

            new WFShaderName("UnToon", "Outline", "Opaque",                     "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Opaque"),
            new WFShaderName("UnToon", "Outline", "TransCutout",                "UnlitWF/UnToon_Outline/WF_UnToon_Outline_TransCutout"),
            new WFShaderName("UnToon", "Outline", "Transparent",                "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent"),
            new WFShaderName("UnToon", "Outline", "Transparent3Pass",           "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent3Pass"),
            new WFShaderName("UnToon", "Outline", "Transparent_MaskOut",        "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut"),
            new WFShaderName("UnToon", "Outline", "Transparent_MaskOut_Blend",  "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut_Blend"),
            new WFShaderName("UnToon", "Outline", "LineOnly_Opaque",            "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Opaque"),
            new WFShaderName("UnToon", "Outline", "LineOnly_TransCutout",       "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_TransCutout"),
            new WFShaderName("UnToon", "Outline", "LineOnly_Transparent",       "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Transparent"),

            new WFShaderName("UnToon", "PowerCap", "Opaque",                    "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Opaque"),
            new WFShaderName("UnToon", "PowerCap", "TransCutout",               "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_TransCutout"),
            new WFShaderName("UnToon", "PowerCap", "Transparent",               "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent"),
            new WFShaderName("UnToon", "PowerCap", "Transparent3Pass",          "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent3Pass"),

            new WFShaderName("UnToon", "Tessellation", "Opaque",                "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Opaque"),
            new WFShaderName("UnToon", "Tessellation", "TransCutout",           "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_TransCutout"),
            new WFShaderName("UnToon", "Tessellation", "Transparent",           "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Transparent"),
            new WFShaderName("UnToon", "Tessellation", "Transparent3Pass",      "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Transparent3Pass"),

            new WFShaderName("UnToon", "TriShade", "Opaque",                    "UnlitWF/UnToon_TriShade/WF_UnToon_TriShade_Opaque"),
            new WFShaderName("UnToon", "TriShade", "TransCutout",               "UnlitWF/UnToon_TriShade/WF_UnToon_TriShade_TransCutout"),
            new WFShaderName("UnToon", "TriShade", "Transparent",               "UnlitWF/UnToon_TriShade/WF_UnToon_TriShade_Transparent"),
            new WFShaderName("UnToon", "TriShade", "Transparent3Pass",          "UnlitWF/UnToon_TriShade/WF_UnToon_TriShade_Transparent3Pass"),
            new WFShaderName("UnToon", "TriShade", "Transparent_Mask",          "UnlitWF/UnToon_TriShade/WF_UnToon_TriShade_Transparent_Mask"),
            new WFShaderName("UnToon", "TriShade", "Transparent_MaskOut",       "UnlitWF/UnToon_TriShade/WF_UnToon_TriShade_Transparent_MaskOut"),
            new WFShaderName("UnToon", "TriShade", "Transparent_MaskOut_Blend", "UnlitWF/UnToon_TriShade/WF_UnToon_TriShade_Transparent_MaskOut_Blend"),

            new WFShaderName("FakeFur", "Basic", "TransCutout",                 "UnlitWF/WF_FakeFur_TransCutout"),
            new WFShaderName("FakeFur", "Basic", "Transparent",                 "UnlitWF/WF_FakeFur_Transparent"),

            new WFShaderName("Gem", "Basic", "Opaque",                          "UnlitWF/WF_Gem_Opaque"),
            new WFShaderName("Gem", "Basic", "Transparent",                     "UnlitWF/WF_Gem_Transparent"),

            new WFShaderName("UnToon(URP)", "Basic", "Opaque",                  "UnlitWF_URP/WF_UnToon_Opaque"),
            new WFShaderName("UnToon(URP)", "Basic", "TransCutout",             "UnlitWF_URP/WF_UnToon_TransCutout"),
            new WFShaderName("UnToon(URP)", "Basic", "Transparent",             "UnlitWF_URP/WF_UnToon_Transparent"),
            new WFShaderName("UnToon(URP)", "Basic", "Transparent_Mask",        "UnlitWF_URP/WF_UnToon_Transparent_Mask"),
            new WFShaderName("UnToon(URP)", "Basic", "Transparent_MaskOut",     "UnlitWF_URP/WF_UnToon_Transparent_MaskOut"),

            new WFShaderName("UnToon(URP)", "Mobile", "Opaque",                 "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Opaque"),
            new WFShaderName("UnToon(URP)", "Mobile", "TransCutout",            "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_TransCutout"),
            new WFShaderName("UnToon(URP)", "Mobile", "Transparent",            "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Transparent"),
            new WFShaderName("UnToon(URP)", "Mobile", "LineOnly_Opaque",        "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque"),
            new WFShaderName("UnToon(URP)", "Mobile", "LineOnly_TransCutout",   "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_TransCutout"),

            new WFShaderName("UnToon(URP)", "Outline", "LineOnly_Opaque",       "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_Opaque"),
            new WFShaderName("UnToon(URP)", "Outline", "LineOnly_TransCutout",  "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_TransCutout"),

            new WFShaderName("Gem(URP)", "Basic", "Opaque",                     "UnlitWF_URP/WF_Gem_Opaque"),
            new WFShaderName("Gem(URP)", "Basic", "Transparent",                "UnlitWF_URP/WF_Gem_Transparent"),
        };

        /// <summary>
        /// シェーダ機能のリスト。
        /// </summary>
        public static readonly List<WFShaderFunction> ShaderFuncList = new List<WFShaderFunction>() {
                new WFShaderFunction("AL", "AL", "Transparent Alpha", (self, mat) => mat.shader.name.Contains("Trans") && mat.HasProperty("_AL_Source")),
                new WFShaderFunction("TE", "TE", "Tessellation", (self, mat) => mat.shader.name.Contains("Tess")),
                new WFShaderFunction("GB", "GB", "Gem Background"),
                new WFShaderFunction("GF", "GF", "Gem Flake"),
                new WFShaderFunction("GR", "GR", "Gem Reflection"),
                new WFShaderFunction("FR", "FR", "Fake Fur", (self, mat) => mat.shader.name.Contains("Fur")),
                new WFShaderFunction("CH", "CH", "3ch Color Mask"),
                new WFShaderFunction("CL", "CL", "Color Change"),
                new WFShaderFunction("NM", "NM", "NormalMap"),
                new WFShaderFunction("MT", "MT", "Metallic"),
                new WFShaderFunction("HL", "HL", "Light Matcap"),
                new WFShaderFunction("LM", "LM", "Lame"),
                new WFShaderFunction("SH", "TS", "ToonShade"),
                new WFShaderFunction("RM", "TR", "RimLight"),
                new WFShaderFunction("OL", "OL", "Decal Texture"),
                new WFShaderFunction("ES", "ES", "Emission"),
                new WFShaderFunction("LI", "TL", "Outline"),
                new WFShaderFunction("AO", "AO", "Ambient Occlusion"),
                new WFShaderFunction("FG", "FG", "ToonFog"),
                new WFShaderFunction("GL", "GL", "Lit & Lit Advance", (self, mat) => true),
            };

        /// <summary>
        /// プレフィックス名のついてない特殊なプロパティ名 → ラベルの変換マップ。
        /// </summary>
        public static readonly Dictionary<string, string> SpecialPropNameToLabelMap = new Dictionary<string, string>() {
            { "_Cutoff", "AL" },
            { "_BumpMap", "NM" },
            { "_BumpScale", "NM" },
            { "_DetailNormalMap", "NM" },
            { "_DetailNormalMapScale", "NM" },
            { "_MetallicGlossMap", "MT" },
            { "_SpecGlossMap", "MT" },
            { "_EmissionColor", "ES" },
            { "_EmissionMap", "ES" },
            { "_OcclusionMap", "AO" },
            { "_TessType", "TE" },
            { "_TessFactor", "TE" },
            { "_Smoothing", "TE" },
            { "_DispMap", "TE" },
            { "_DispMapScale", "TE" },
            { "_DispMapLevel", "TE" },
        };

        /// <summary>
        /// 古いマテリアルのマイグレーション：プロパティ名のリネーム辞書
        /// </summary>
        public static readonly Dictionary<string, string> OldPropNameToNewPropNameMap = new Dictionary<string, string>() {
            { "_AL_CutOff", "_Cutoff" },
            { "_CutOffLevel", "_Cutoff" },
            { "_ES_Color", "_EmissionColor" },
            { "_ES_MaskTex", "_EmissionMap" },
            { "_FurHeight", "_FR_Height" },
            { "_FurMaskTex", "_FR_MaskTex" },
            { "_FurNoiseTex", "_FR_NoiseTex" },
            { "_FurRepeat", "_FR_Repeat" },
            { "_FurShadowPower", "_FR_ShadowPower" },
            // { "_FurVector", "_FR_Vector" }, // FurVectorの値は再設定が必要なので変換しない
            { "_FG_BumpMap", "_FR_BumpMap" },
            { "_FG_FlipTangent", "_FR_FlipTangent" },
            { "_GL_BrendPower", "_GL_BlendPower" },
            { "_MT_BlendType", "_MT_Brightness" },
            { "_MT_MaskTex", "_MetallicGlossMap" },
            { "_MT_Smoothness", "_MT_ReflSmooth" },
            { "_MT_Smoothness2", "_MT_SpecSmooth" },
        };

        /// <summary>
        /// ラベル名などの物理名 → 日本語訳の変換マップ。
        /// </summary>
        public static readonly Dictionary<string, string> LangEnToJa = new Dictionary<string, string>() {
            // Common
            { "Enable", "有効" },
            { "Invert Mask Value", "マスク反転" },
            { "Blend Normal", "ノーマルマップ強度" },
            // Lit
            { "Anti-Glare", "まぶしさ防止" },
            { "Darken (min value)", "暗さの最小値" },
            { "Lighten (max value)", "明るさの最大値" },
            { "Blend Light Color", "ライト色の混合強度" },
            { "Cast Shadows", "他の物体に影を落とす" },
            // Alpha
            { "[AL] Alpha Source", "[AL] アルファソース" },
            { "[AL] Alpha Mask Texture", "[AL] アルファマスク" },
            { "[AL] Power", "[AL] アルファ強度" },
            { "[AL] Fresnel Power", "[AL] フレネル強度" },
            { "[AL] Cutoff Threshold", "[AL] カットアウトしきい値" },
            // Tessellation
            { "Tess Type", "Tessタイプ" },
            { "Tess Factor", "Tess分割強度" },
            { "Smoothing", "Phongスムージング" },
            { "Displacement HeightMap", "ハイトマップ" },
            { "HeightMap Scale", "ハイトマップのスケール" },
            { "HeightMap Level", "ハイトマップのゼロ点調整" },
            // Color Change
            { "[CL] monochrome", "[CL] 単色化" },
            { "[CL] Hur", "[CL] 色相" },
            { "[CL] Saturation", "[CL] 彩度" },
            { "[CL] Brightness", "[CL] 明度" },
            // Normal
            { "[NM] NormalMap Texture", "[NM] ノーマルマップ" },
            { "[NM] Bump Scale", "[NM] 凹凸スケール" },
            { "[NM] Shadow Power", "[NM] 影の濃さ" },
            { "[NM] Flip Tangent", "[NM] タンジェント反転" },
            { "[NM] 2nd Normal Blend", "[NM] 2ndマップの混合タイプ" },
            { "[NM] 2nd NormalMap Texture", "[NM] 2ndノーマルマップ" },
            { "[NM] 2nd Bump Scale", "[NM] 凹凸スケール" },
            { "[NM] 2nd NormalMap Mask Texture", "[NM] 2ndノーマルのマスク" },
            // Metallic
            { "[MT] Metallic", "[MT] メタリック強度" },
            { "[MT] Smoothness", "[MT] 滑らかさ" },
            { "[MT] Brightness", "[MT] 明るさ" },
            { "[MT] Monochrome Reflection", "[MT] モノクロ反射" },
            { "[MT] Specular", "[MT] スペキュラ反射" },
            { "[MT] MetallicMap Texture", "[MT] MetallicSmoothnessマップ" },
            { "[MT] MetallicSmoothnessMap Texture", "[MT] MetallicSmoothnessマップ" },
            { "[MT] RoughnessMap Texture", "[MT] Roughnessマップ" },
            { "[MT] 2nd CubeMap Blend", "[MT] キューブマップ混合タイプ" },
            { "[MT] 2nd CubeMap", "[MT] キューブマップ" },
            { "[MT] 2nd CubeMap Power", "[MT] キューブマップ強度" },
            // Light Matcap
            { "[HL] Matcap Type", "[HL] matcapタイプ" },
            { "[HL] Matcap Sampler", "[HL] matcapサンプラ" },
            { "[HL] Matcap Color", "[HL] matcap色調整" },
            { "[HL] Parallax", "[HL] 視差(Parallax)" },
            { "[HL] Power", "[HL] matcap強度" },
            { "[HL] Mask Texture", "[HL] マスクテクスチャ" },
            // Lame
            { "[LM] Color", "[LM] ラメ色" },
            { "[LM] Texture", "[LM] ラメ色テクスチャ" },
            { "[LM] Random Color", "[LM] ランダム色パラメタ" },
            { "[LM] Change Alpha Transparency", "[LM] 透明度も反映する" },
            { "[LM] UV Type", "[LM] UVタイプ" },
            { "[LM] Shape", "[LM] 形状" },
            { "[LM] Scale", "[LM] スケール" },
            { "[LM] Dencity", "[LM] 密度" },
            { "[LM] Glitter", "[LM] きらきら" },
            { "[LM] Dist Fade Start", "[LM] 距離フェード開始" },
            { "[LM] Spot Fade Strength", "[LM] スポットフェード強度" },
            { "[LM] Anim Speed", "[LM] アニメ速度" },
            { "[LM] Mask Texture", "[LM] マスクテクスチャ" },
            // ToonShade
            { "[SH] Base Color", "[SH] ベース色" },
            { "[SH] Base Shade Texture", "[SH] ベース色テクスチャ" },
            { "[SH] 1st Shade Color", "[SH] 1影色" },
            { "[SH] 1st Shade Texture", "[SH] 1影色テクスチャ" },
            { "[SH] 2nd Shade Color", "[SH] 2影色" },
            { "[SH] 2nd Shade Texture", "[SH] 2影色テクスチャ" },
            { "[SH] 3rd Shade Color", "[SH] 3影色" },
            { "[SH] 3rd Shade Texture", "[SH] 3影色テクスチャ" },
            { "[SH] Shade Power", "[SH] 影の強度" },
            { "[SH] 1st Border", "[SH] 1影の境界位置" },
            { "[SH] 2nd Border", "[SH] 2影の境界位置" },
            { "[SH] 3rd Border", "[SH] 3影の境界位置" },
            { "[SH] Feather", "[SH] 境界のぼかし強度" },
            { "[SH] Anti-Shadow Mask Texture", "[SH] アンチシャドウマスク" },
            { "[SH] Shade Color Suggest", "[SH] 影色を自動設定する" },
            // RimLight
            { "[RM] Rim Color", "[RM] リムライト色" },
            { "[RM] Blend Type", "[RM] 混合タイプ" },
            { "[RM] Power Top", "[RM] 強度(上)" },
            { "[RM] Power Side", "[RM] 強度(横)" },
            { "[RM] Power Bottom", "[RM] 強度(下)" },
            { "[RM] RimLight Mask Texture", "[RM] マスクテクスチャ" },
            // Decal
            { "[OL] UV Type", "[OL] UVタイプ" },
            { "[OL] Decal Color", "[OL] Decal色" },
            { "[OL] Decal Texture", "[OL] Decalテクスチャ" },
            { "[OL] Texture", "[OL] テクスチャ" },
            { "[OL] Blend Type", "[OL] 混合タイプ" },
            { "[OL] Blend Power", "[OL] 混合の強度" },
            { "[OL] Decal Mask Texture", "[OL] マスクテクスチャ" },
            // EmissiveScroll
            { "[ES] Emission", "[ES] Emission" },
            { "[ES] Blend Type", "[ES] 混合タイプ" },
            { "[ES] Mask Texture", "[ES] マスクテクスチャ" },
            { "[ES] Wave Type", "[ES] 波形" },
            { "[ES] Direction", "[ES] 方向" },
            { "[ES] Change Alpha Transparency", "[ES] 透明度も反映する" },
            { "[ES] Direction Type", "[ES] 方向の種類" },
            { "[ES] LevelOffset", "[ES] ゼロ点調整" },
            { "[ES] Sharpness", "[ES] 鋭さ" },
            { "[ES] ScrollSpeed", "[ES] スピード" },
            { "[ES] Cull Mode", "[ES] カリングモード" },
            { "[ES] Z-shift", "[ES] カメラに近づける" },
            // Outline
            { "[LI] Line Color", "[LI] 線の色" },
            { "[LI] Line Width", "[LI] 線の太さ" },
            { "[LI] Line Type", "[LI] 線の種類" },
            { "[LI] Custom Color Texture", "[LI] 線色テクスチャ" },
            { "[LI] Blend Custom Color Texture", "[LI] 線色テクスチャとブレンド" },
            { "[LI] Blend Base Color", "[LI] ベース色とブレンド" },
            { "[LI] Outline Mask Texture", "[LI] マスクテクスチャ" },
            { "[LI] Z-shift (tweak)", "[LI] カメラから遠ざける" },
            // Ambient Occlusion
            { "[AO] Occlusion Map", "[AO] オクルージョンマップ" },
            { "[AO] Use LightMap", "[AO] ライトマップも使用する" },
            { "[AO] Contrast", "[AO] コントラスト" },
            { "[AO] Brightness", "[AO] 明るさ" },
            { "[AO] Occlusion Mask Texture", "[AO] マスクテクスチャ" },
            // Toon Fog
            { "[FG] Color", "[FG] フォグの色" },
            { "[FG] Fog Min Distance", "[FG] フォグが効き始める距離" },
            { "[FG] Fog Max Distance", "[FG] フォグが最大になる距離" },
            { "[FG] Exponential", "[FG] 変化の鋭さ" },
            { "[FG] Base Offset", "[FG] フォグ原点の位置(オフセット)" },
            { "[FG] Scale", "[FG] フォグ範囲のスケール" },
            // Lit Advance
            { "Sun Source", "太陽光のモード" },
            { "Custom Sun Azimuth", "カスタム太陽の方角" },
            { "Custom Sun Altitude", "カスタム太陽の高度" },
            { "Disable BackLit", "逆光補正しない" },
            { "Disable ObjectBasePos", "メッシュ原点を取得しない" },
            // DebugMode
            { "Debug View", "デバッグ表示" },
            // Gem Background
            { "[GB] Background Color", "[GR] 背景色 (裏面色)" },
            // Gem Reflection
            { "[GR] Blend Power", "[GR] ブレンド強度" },
            { "[GR] CubeMap", "[GR] キューブマップ" },
            { "[GR] Brightness", "[GR] 明るさ" },
            { "[GR] Monochrome Reflection", "[GR] モノクロ反射" },
            { "[GR] 2nd CubeMap Power", "[GR] キューブマップ強度" },
            // Gem Flake
            { "[GF] Flake Size (front)", "[GF] 大きさ (表面)" },
            { "[GF] Flake Size (back)", "[GF] 大きさ (裏面)" },
            { "[GF] Shear", "[GF] シア" },
            { "[GF] Brighten", "[GF] 明るさ" },
            { "[GF] Darken", "[GF] 暗さ" },
            { "[GF] Twinkle", "[GF] またたき" },
            // Fake Fur
            { "[FR] Fur Noise Texture", "[FR] ノイズテクスチャ" },
            { "[FR] Fur Height", "[FR] 高さ" },
            { "[FR] Fur Vector", "[FR] 方向" },
            { "[FR] NormalMap Texture", "[FR] ノーマルマップ" },
            { "[FR] Flip Tangent", "[FR] タンジェント反転" },
            { "[FR] Fur Repeat", "[FR] ファーの枚数" },
            { "[FR] Fur ShadowPower", "[FR] 影の強さ" },
            { "[FR] Fur Mask Texture", "[FR] マスクテクスチャ" },
        };
    }
}

#endif
