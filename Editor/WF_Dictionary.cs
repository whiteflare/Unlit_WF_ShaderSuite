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

using System.Collections.Generic;

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

            new WFShaderName("UnToon", "Outline", "Opaque",                     "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Opaque"),
            new WFShaderName("UnToon", "Outline", "TransCutout",                "UnlitWF/UnToon_Outline/WF_UnToon_Outline_TransCutout"),
            new WFShaderName("UnToon", "Outline", "Transparent",                "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent"),
            new WFShaderName("UnToon", "Outline", "Transparent3Pass",           "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent3Pass"),
            new WFShaderName("UnToon", "Outline", "Transparent_MaskOut",        "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut"),
            new WFShaderName("UnToon", "Outline", "Transparent_MaskOut_Blend",  "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut_Blend"),

            new WFShaderName("UnToon", "Outline_LineOnly", "Opaque",            "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Opaque"),
            new WFShaderName("UnToon", "Outline_LineOnly", "TransCutout",       "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_TransCutout"),
            new WFShaderName("UnToon", "Outline_LineOnly", "Transparent",       "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Transparent"),
            new WFShaderName("UnToon", "Outline_LineOnly", "Transparent_MaskOut",   "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Transparent_MaskOut"),

            new WFShaderName("UnToon", "Mobile", "Opaque",                      "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"),
            new WFShaderName("UnToon", "Mobile", "TransCutout",                 "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransCutout"),
            new WFShaderName("UnToon", "Mobile", "Transparent",                 "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"),
            new WFShaderName("UnToon", "Mobile", "TransparentOverlay",          "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransparentOverlay"),

            new WFShaderName("UnToon", "Mobile_Outline", "Opaque",              "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Outline_Opaque"),
            new WFShaderName("UnToon", "Mobile_Outline", "TransCutout",         "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Outline_TransCutout"),

            new WFShaderName("UnToon", "Mobile_LineOnly", "Opaque",             "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque"),
            new WFShaderName("UnToon", "Mobile_LineOnly", "TransCutout",        "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_TransCutout"),

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
            new WFShaderName("FakeFur", "Basic", "Mix",                         "UnlitWF/WF_FakeFur_Mix"),

            new WFShaderName("FakeFur", "FurOnly", "TransCutout",               "UnlitWF/WF_FakeFur_FurOnly_TransCutout"),
            new WFShaderName("FakeFur", "FurOnly", "Transparent",               "UnlitWF/WF_FakeFur_FurOnly_Transparent"),
            new WFShaderName("FakeFur", "FurOnly", "Mix",                       "UnlitWF/WF_FakeFur_FurOnly_Mix"),

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
            new WFShaderName("UnToon(URP)", "Mobile", "TransparentOverlay",     "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_TransparentOverlay"),

            new WFShaderName("UnToon(URP)", "Outline_LineOnly", "Opaque",       "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_Opaque"),
            new WFShaderName("UnToon(URP)", "Outline_LineOnly", "TransCutout",  "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_TransCutout"),

            new WFShaderName("UnToon(URP)", "Mobile_LineOnly", "Opaque",        "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque"),
            new WFShaderName("UnToon(URP)", "Mobile_LineOnly", "TransCutout",   "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_TransCutout"),

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
                new WFShaderFunction("BK", "BK", "BackFace Texture"),
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
                new WFShaderFunction("GI", "GI", "Light Bake Effects"),
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
            // 今は使っていないはずの項目
            { "_TessType", "TE" },
            { "_TessFactor", "TE" },
            { "_Smoothing", "TE" },
            { "_DispMap", "TE" },
            { "_DispMapScale", "TE" },
            { "_DispMapLevel", "TE" },
        };

        /// <summary>
        /// ENABLEキーワードに対応していない特殊なプロパティ名 → キーワードの変換マップ。
        /// </summary>
        public static readonly Dictionary<string, string> SpecialPropNameToKeywordMap = new Dictionary<string, string>() {
            { "_UseVertexColor", "_VC_ENABLE" },
        };

        /// <summary>
        /// 古いマテリアルのマイグレーション：プロパティ名のリネーム辞書
        /// </summary>
        public static readonly List<PropertyNameReplacement> OldPropNameToNewPropNameList = new List<PropertyNameReplacement>() {
            new PropertyNameReplacement("_AL_CutOff", "_Cutoff"),
            new PropertyNameReplacement("_CutOffLevel", "_Cutoff"),
            new PropertyNameReplacement("_ES_Color", "_EmissionColor"),
            new PropertyNameReplacement("_ES_MaskTex", "_EmissionMap"),
            new PropertyNameReplacement("_FurHeight", "_FR_Height"),
            new PropertyNameReplacement("_FurMaskTex", "_FR_MaskTex"),
            new PropertyNameReplacement("_FurNoiseTex", "_FR_NoiseTex"),
            new PropertyNameReplacement("_FurRepeat", "_FR_Repeat"),
            new PropertyNameReplacement("_FurShadowPower", "_FR_ShadowPower"),
            new PropertyNameReplacement("_FG_BumpMap", "_FR_BumpMap"),
            new PropertyNameReplacement("_FG_FlipTangent", "_FR_FlipTangent"),
            new PropertyNameReplacement("_GL_BrendPower", "_GL_BlendPower"),
            new PropertyNameReplacement("_MT_BlendType", "_MT_Brightness"),
            new PropertyNameReplacement("_MT_MaskTex", "_MetallicGlossMap"),
            new PropertyNameReplacement("_MT_Smoothness", "_MT_ReflSmooth"),
            new PropertyNameReplacement("_MT_Smoothness2", "_MT_SpecSmooth"),
            new PropertyNameReplacement("_TessFactor", "_TE_Factor"),
            new PropertyNameReplacement("_Smoothing", "_TE_SmoothPower"),
            // new OldPropertyReplacement("_FurVector", "_FR_Vector"), // FurVectorの値は再設定が必要なので変換しない
        };

        /// <summary>
        /// ラベル名などの物理名 → 日本語訳の変換マップ。
        /// </summary>
        public static readonly List<WFI18NTranslation> LangEnToJa = new List<WFI18NTranslation>() {
            // Base
            new WFI18NTranslation("Main Texture", "メイン テクスチャ"),
            new WFI18NTranslation("Color", "マテリアルカラー"),
            new WFI18NTranslation("Cull Mode", "カリングモード"),
            new WFI18NTranslation("Use Vertex Color", "頂点カラーを乗算する"),
            new WFI18NTranslation("Alpha CutOff Level", "カットアウトしきい値"),
            // Common
            new WFI18NTranslation("Enable", "有効"),
            new WFI18NTranslation("Texture", "テクスチャ"),
            new WFI18NTranslation("Mask Texture", "マスクテクスチャ"),
            new WFI18NTranslation("Invert Mask Value", "マスク反転"),
            new WFI18NTranslation("UV Type", "UVタイプ"),
            new WFI18NTranslation("Brightness", "明るさ"),
            new WFI18NTranslation("Blend Type", "混合タイプ"),
            new WFI18NTranslation("Blend Power", "混合の強度"),
            new WFI18NTranslation("Blend Normal", "ノーマルマップ強度"),
            new WFI18NTranslation("Shape", "形状"),
            new WFI18NTranslation("Scale", "スケール"),
            new WFI18NTranslation("Direction", "方向"),
            new WFI18NTranslation("Roughen", "粗くする"),
            new WFI18NTranslation("Finer", "細かくする"),
            new WFI18NTranslation("Tint Color", "色調整"),
            new WFI18NTranslation("FadeOut Distance (Near)", "フェードアウト距離"),
            new WFI18NTranslation("FadeOut Distance (Far)", "フェードアウト距離"),
            // Lit
            new WFI18NTranslation("Unlit Intensity", "Unlit Intensity (最小明度)"),
            new WFI18NTranslation("Saturate Intensity", "Saturate Intensity (飽和明度)"),
            new WFI18NTranslation("Chroma Reaction", "Chroma Reaction (彩度)"),
            new WFI18NTranslation("Cast Shadows", "他の物体に影を落とす"),
            // Alpha
            new WFI18NTranslation("AL", "Alpha Source", "アルファソース"),
            new WFI18NTranslation("AL", "Alpha Mask Texture", "アルファマスク"),
            new WFI18NTranslation("AL", "Power", "アルファ強度"),
            new WFI18NTranslation("AL", "Fresnel Power", "フレネル強度"),
            new WFI18NTranslation("AL", "Cutoff Threshold", "カットアウトしきい値"),
            // BackFace Texture
            new WFI18NTranslation("BK", "Back Texture", "裏面テクスチャ"),
            new WFI18NTranslation("BK", "Back Color", "裏面色"),
            // Color Change
            new WFI18NTranslation("CL", "monochrome", "単色化"),
            new WFI18NTranslation("CL", "Hur", "色相"),
            new WFI18NTranslation("CL", "Saturation", "彩度"),
            new WFI18NTranslation("CL", "Brightness", "明度"),
            // Normal
            new WFI18NTranslation("NM", "NormalMap Texture", "ノーマルマップ").AddTag("FR"),
            new WFI18NTranslation("NM", "Bump Scale", "凹凸スケール"),
            new WFI18NTranslation("NM", "Shadow Power", "影の濃さ"),
            new WFI18NTranslation("NM", "Flip Mirror", "ミラーXY反転").AddTag("FR"),
            new WFI18NTranslation("NM", "2nd Normal Blend", "2ndマップの混合タイプ"),
            new WFI18NTranslation("NM", "2nd NormalMap Texture", "2ndノーマルマップ"),
            new WFI18NTranslation("NM", "2nd Bump Scale", "凹凸スケール"),
            new WFI18NTranslation("NM", "2nd NormalMap Mask Texture", "2ndノーマルのマスク"),
            // Metallic
            new WFI18NTranslation("MT", "Metallic", "メタリック強度"),
            new WFI18NTranslation("MT", "Smoothness", "滑らかさ"),
            new WFI18NTranslation("MT", "Monochrome Reflection", "モノクロ反射"),
            new WFI18NTranslation("MT", "Specular", "スペキュラ反射"),
            new WFI18NTranslation("MT", "MetallicMap Type", "Metallicマップの種類"),
            new WFI18NTranslation("MT", "MetallicSmoothnessMap Texture", "MetallicSmoothnessマップ"),
            new WFI18NTranslation("MT", "RoughnessMap Texture", "Roughnessマップ"),
            new WFI18NTranslation("MT", "2nd CubeMap Blend", "キューブマップ混合タイプ"),
            new WFI18NTranslation("MT", "2nd CubeMap", "キューブマップ"),
            new WFI18NTranslation("MT", "2nd CubeMap Power", "キューブマップ強度"),
            // Light Matcap
            new WFI18NTranslation("HL", "Matcap Type", "matcapタイプ").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Sampler", "matcapサンプラ").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Base Color", "matcapベース色").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Tint Color", "matcap色調整").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Parallax", "視差(Parallax)").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Power", "matcap強度").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            // Lame
            new WFI18NTranslation("LM", "Color", "ラメ色・テクスチャ"),
            new WFI18NTranslation("LM", "Texture", "ラメ色・テクスチャ"),
            new WFI18NTranslation("LM", "Random Color", "ランダム色パラメタ"),
            new WFI18NTranslation("LM", "Change Alpha Transparency", "透明度も反映する"),
            new WFI18NTranslation("LM", "Dencity", "密度"),
            new WFI18NTranslation("LM", "Glitter", "きらきら"),
            new WFI18NTranslation("LM", "FadeOut Angle", "フェードアウト角度"),
            new WFI18NTranslation("LM", "Anim Speed", "アニメ速度"),
            // ToonShade
            new WFI18NTranslation("SH", "Steps", "繰り返し数"),
            new WFI18NTranslation("SH", "Base Color", "ベース色"),
            new WFI18NTranslation("SH", "Base Shade Texture", "ベース色テクスチャ"),
            new WFI18NTranslation("SH", "1st Shade Color", "1影色"),
            new WFI18NTranslation("SH", "1st Shade Texture", "1影色テクスチャ"),
            new WFI18NTranslation("SH", "2nd Shade Color", "2影色"),
            new WFI18NTranslation("SH", "2nd Shade Texture", "2影色テクスチャ"),
            new WFI18NTranslation("SH", "3rd Shade Color", "3影色"),
            new WFI18NTranslation("SH", "3rd Shade Texture", "3影色テクスチャ"),
            new WFI18NTranslation("SH", "Shade Power", "影の強度"),
            new WFI18NTranslation("SH", "1st Border", "1影の境界位置"),
            new WFI18NTranslation("SH", "2nd Border", "2影の境界位置"),
            new WFI18NTranslation("SH", "3rd Border", "3影の境界位置"),
            new WFI18NTranslation("SH", "Feather", "境界のぼかし強度"),
            new WFI18NTranslation("SH", "Anti-Shadow Mask Texture", "アンチシャドウマスク"),
            new WFI18NTranslation("SH", "Shade Color Suggest", "影色を自動設定する"),
            new WFI18NTranslation("SH", "Align the boundaries equally", "境界を等間隔に整列"),
            // RimLight
            new WFI18NTranslation("RM", "Rim Color", "リムライト色"),
            new WFI18NTranslation("RM", "Power", "強度(マスター)"),
            new WFI18NTranslation("RM", "Feather", "境界のぼかし強度"),
            new WFI18NTranslation("RM", "Power Top", "強度(上)"),
            new WFI18NTranslation("RM", "Power Side", "強度(横)"),
            new WFI18NTranslation("RM", "Power Bottom", "強度(下)"),
            // Decal
            new WFI18NTranslation("OL", "Decal Color", "デカール テクスチャ"),
            new WFI18NTranslation("OL", "Decal Texture", "デカール テクスチャ"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Decal Texture", "頂点カラーをデカールに乗算する"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Mask Texture", "頂点カラーをマスクに乗算する"),
            // EmissiveScroll
            new WFI18NTranslation("ES", "Emission", "Emission テクスチャ"),
            new WFI18NTranslation("ES", "Emission Texture", "Emission テクスチャ"),
            new WFI18NTranslation("ES", "Wave Type", "波形"),
            new WFI18NTranslation("ES", "Change Alpha Transparency", "透明度も反映する"),
            new WFI18NTranslation("ES", "Direction Type", "方向の種類"),
            new WFI18NTranslation("ES", "LevelOffset", "ゼロ点調整"),
            new WFI18NTranslation("ES", "Sharpness", "鋭さ"),
            new WFI18NTranslation("ES", "ScrollSpeed", "スピード"),
            // Outline
            new WFI18NTranslation("LI", "Line Color", "線の色"),
            new WFI18NTranslation("LI", "Line Width", "線の太さ"),
            new WFI18NTranslation("LI", "Line Type", "線の種類"),
            new WFI18NTranslation("LI", "Custom Color Texture", "線色テクスチャ"),
            new WFI18NTranslation("LI", "Blend Custom Color Texture", "線色テクスチャとブレンド"),
            new WFI18NTranslation("LI", "Blend Base Color", "ベース色とブレンド"),
            new WFI18NTranslation("LI", "Z-shift (tweak)", "カメラから遠ざける"),
            // Ambient Occlusion
            new WFI18NTranslation("AO", "Occlusion Map", "オクルージョンマップ"),
            new WFI18NTranslation("AO", "Use LightMap", "ライトマップも使用する"),
            new WFI18NTranslation("AO", "Contrast", "コントラスト"),
            // Toon Fog
            new WFI18NTranslation("FG", "Color", "フォグの色"),
            new WFI18NTranslation("FG", "Exponential", "変化の鋭さ"),
            new WFI18NTranslation("FG", "Base Offset", "フォグ原点の位置(オフセット)"),
            new WFI18NTranslation("FG", "Scale", "フォグ範囲のスケール"),
            // Tessellation
            new WFI18NTranslation("TE", "Tess Factor", "分割数"),
            new WFI18NTranslation("TE", "Smoothing", "スムーズ"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture", "スムーズマスク"),
            // Lit Advance
            new WFI18NTranslation("Sun Source", "太陽光のモード"),
            new WFI18NTranslation("Custom Sun Azimuth", "カスタム太陽の方角"),
            new WFI18NTranslation("Custom Sun Altitude", "カスタム太陽の高度"),
            new WFI18NTranslation("Disable BackLit", "逆光補正しない"),
            new WFI18NTranslation("Disable ObjectBasePos", "メッシュ原点を取得しない"),
            // Light Bake Effects
            new WFI18NTranslation("GI", "Indirect Multiplier", "間接光の倍率"),
            new WFI18NTranslation("GI", "Emission Multiplier", "Emissionの倍率"),
            new WFI18NTranslation("GI", "Indirect Chroma", "間接光の彩度"),
            // Gem Background
            new WFI18NTranslation("GB", "Background Color", "背景色 (裏面色)"),
            // Gem Reflection
            new WFI18NTranslation("GR", "CubeMap", "キューブマップ"),
            new WFI18NTranslation("GR", "Monochrome Reflection", "モノクロ反射"),
            new WFI18NTranslation("GR", "2nd CubeMap Power", "キューブマップ強度"),
            // Gem Flake
            new WFI18NTranslation("GF", "Flake Size (front)", "大きさ (表面)"),
            new WFI18NTranslation("GF", "Flake Size (back)", "大きさ (裏面)"),
            new WFI18NTranslation("GF", "Shear", "シア"),
            new WFI18NTranslation("GF", "Brighten", "明るさ"),
            new WFI18NTranslation("GF", "Darken", "暗さ"),
            new WFI18NTranslation("GF", "Twinkle", "またたき"),
            // Fake Fur
            new WFI18NTranslation("FR", "Fur Noise Texture", "ノイズテクスチャ"),
            new WFI18NTranslation("FR", "Fur Height", "高さ"),
            new WFI18NTranslation("FR", "Fur Height (Cutout)", "高さ (Cutout側)"),
            new WFI18NTranslation("FR", "Fur Height (Transparent)", "高さ (Transparent側)"),
            new WFI18NTranslation("FR", "Fur Vector", "方向"),
            new WFI18NTranslation("FR", "Fur Repeat", "ファーの枚数"),
            new WFI18NTranslation("FR", "Fur ShadowPower", "影の強さ"),
            new WFI18NTranslation("FR", "Tint Color (Base)", "色調整 (根元)"),
            new WFI18NTranslation("FR", "Tint Color (Tip)", "色調整 (先端)"),

            // その他のテキスト
            new WFI18NTranslation(WFMessageText.NewerVersion, "新しいバージョンがリリースされています。\n最新版: "),
            new WFI18NTranslation(WFMessageText.PlzMigration, "このマテリアルは古いバージョンで作成されたようです。\n最新版に変換しますか？"),
            new WFI18NTranslation(WFMessageText.PlzBatchingStatic, "このマテリアルは Batching Static な MeshRenderer から使われているようです。\nBatching Static 用の設定へ変更しますか？"),
            new WFI18NTranslation(WFMessageText.PlzLightmapStatic, "このマテリアルは Lightmap Static な MeshRenderer から使われているようです。\nライトマップを有効にしますか？"),
            new WFI18NTranslation(WFMessageText.PsAntiShadowMask, "アンチシャドウマスクにはアバターの顔を白く塗ったマスクテクスチャを指定してください。マスク反転をチェックすることでマテリアル全体を顔とみなすこともできます。"),

            new WFI18NTranslation(WFMessageText.PsCapTypeMedian, "MEDIAN_CAPは灰色を基準とした加算＆減算合成を行うmatcapです"),
            new WFI18NTranslation(WFMessageText.PsCapTypeLight, "LIGHT_CAPは黒色を基準とした加算合成を行うmatcapです"),
            new WFI18NTranslation(WFMessageText.PsCapTypeShade, "SHADE_CAPは白色を基準とした乗算合成を行うmatcapです"),

            new WFI18NTranslation(WFMessageText.DgChangeMobile, "シェーダをMobile向けに切り替えますか？\n\nこの操作はUndoできますが、バックアップを取ることをお勧めします。"),

            new WFI18NTranslation(WFMessageButton.Cleanup, "マテリアルから不要データを削除"),
            new WFI18NTranslation(WFMessageButton.ApplyTemplate, "テンプレートから適用"),
            new WFI18NTranslation(WFMessageButton.SaveTemplate, "テンプレートとして保存"),

            // 今は使っていないはずの項目
            new WFI18NTranslation("Anti-Glare", "まぶしさ防止"),
            new WFI18NTranslation("Debug View", "デバッグ表示"),
            new WFI18NTranslation("HL", "Matcap Color", "matcap色調整").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("RM", "RimLight Mask Texture", "マスクテクスチャ"),
            new WFI18NTranslation("LI", "Outline Mask Texture", "マスクテクスチャ"),
            new WFI18NTranslation("AO", "Occlusion Mask Texture", "マスクテクスチャ"),
            new WFI18NTranslation("OL", "Decal Mask Texture", "マスクテクスチャ"),
            new WFI18NTranslation("FR", "Fur Mask Texture", "マスクテクスチャ"),
            new WFI18NTranslation("MT", "MetallicMap Texture", "MetallicSmoothnessマップ"),
            new WFI18NTranslation("Displacement HeightMap", "ハイトマップ"),
            new WFI18NTranslation("HeightMap Scale", "ハイトマップのスケール"),
            new WFI18NTranslation("HeightMap Level", "ハイトマップのゼロ点調整"),
            new WFI18NTranslation("ES", "Cull Mode", "カリングモード"),
            new WFI18NTranslation("ES", "Z-shift", "カメラに近づける"),
            new WFI18NTranslation("FG", "Fog Min Distance", "フォグが効き始める距離"),
            new WFI18NTranslation("FG", "Fog Max Distance", "フォグが最大になる距離"),
            new WFI18NTranslation("TE", "Tess Type", "Tessタイプ"),
            new WFI18NTranslation("LM", "Dist Fade Start", "フェードアウト距離"),
            new WFI18NTranslation("LM", "Spot Fade Strength", "フェードアウト角度"),
            new WFI18NTranslation("FeedOut Distance (Near)", "フェードアウト距離"),
            new WFI18NTranslation("FeedOut Distance (Far)", "フェードアウト距離"),
            new WFI18NTranslation("NM", "Flip Tangent", "タンジェント反転"),
            new WFI18NTranslation("FR", "Flip Tangent", "タンジェント反転"),
            new WFI18NTranslation("Darken (min value)", "暗さの最小値"),
            new WFI18NTranslation("Lighten (max value)", "明るさの最大値"),
            new WFI18NTranslation("Blend Light Color", "ライト色の混合強度"),
            new WFI18NTranslation("FR", "Fur Height 2", "高さ (Transparent側)"),
        };
    }

    internal static class WFMessageText
    {
        public static readonly string NewerVersion = "A newer version is available now!\nLatest version: ";
        public static readonly string PlzMigration = "This Material may have been created in an older version.\nConvert to new version?";
        public static readonly string PlzBatchingStatic = "This material seems to be used by the Batching Static MeshRenderer.\nDo you want to change the settings for Batching Static?";
        public static readonly string PlzLightmapStatic = "This material seems to be used by the Lightmap Static MeshRenderer.\nDo you want to enable Lightmap?";
        public static readonly string PsAntiShadowMask = "In the Anti-Shadow Mask field, specify a mask texture with the avatar face painted white. You can also check the InvertMask checkbox to make the entire material a face.";
        public static readonly string PsCapTypeMedian = "MEDIAN_CAP is a matcap that performs gray-based additive and subtractive blending.";
        public static readonly string PsCapTypeLight = "LIGHT_CAP is a matcap that performs black-based additive blending.";
        public static readonly string PsCapTypeShade = "SHADE_CAP is a matcap that performs white-based multiply blending.";
        public static readonly string DgChangeMobile = "Do you want to change those shader for Mobile?\n\nYou can undo this operation, but we recommend that you make a backup.";
    }

    internal static class WFMessageButton
    {
        public static readonly string Cleanup = "Remove unused properties from Materials";
        public static readonly string ApplyTemplate = "Apply from Template";
        public static readonly string SaveTemplate = "Save as Template";
    }
}

#endif
