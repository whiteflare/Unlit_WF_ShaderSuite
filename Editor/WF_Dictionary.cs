/*
 *  The MIT License
 *
 *  Copyright 2018-2022 whiteflare.
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
            new WFShaderName("UnToon", "Basic", "Transparent_Refracted",        "UnlitWF/WF_UnToon_Transparent_Refracted"),

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

            new WFShaderName("UnToon(URP)", "Outline", "Opaque",                "UnlitWF_URP/UnToon_Outline/WF_UnToon_Outline_Opaque"),
            new WFShaderName("UnToon(URP)", "Outline", "TransCutout",           "UnlitWF_URP/UnToon_Outline/WF_UnToon_Outline_TransCutout"),

            new WFShaderName("UnToon(URP)", "Outline_LineOnly", "Opaque",       "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_Opaque"),
            new WFShaderName("UnToon(URP)", "Outline_LineOnly", "TransCutout",  "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_TransCutout"),

            new WFShaderName("UnToon(URP)", "Mobile_Outline", "Opaque",         "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Outline_Opaque"),
            new WFShaderName("UnToon(URP)", "Mobile_Outline", "TransCutout",    "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Outline_TransCutout"),

            new WFShaderName("UnToon(URP)", "Mobile_LineOnly", "Opaque",        "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque"),
            new WFShaderName("UnToon(URP)", "Mobile_LineOnly", "TransCutout",   "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_TransCutout"),

            new WFShaderName("Gem(URP)", "Basic", "Opaque",                     "UnlitWF_URP/WF_Gem_Opaque"),
            new WFShaderName("Gem(URP)", "Basic", "Transparent",                "UnlitWF_URP/WF_Gem_Transparent"),

            new WFShaderName("FakeFur(URP)", "Basic", "TransCutout",            "UnlitWF_URP/WF_FakeFur_TransCutout"),
            new WFShaderName("FakeFur(URP)", "Basic", "Transparent",            "UnlitWF_URP/WF_FakeFur_Transparent"),

            new WFShaderName("FakeFur(URP)", "FurOnly", "TransCutout",          "UnlitWF_URP/WF_FakeFur_FurOnly_TransCutout"),
            new WFShaderName("FakeFur(URP)", "FurOnly", "Transparent",          "UnlitWF_URP/WF_FakeFur_FurOnly_Transparent"),
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
                new WFShaderFunction("DF", "DF", "Distance Fade"),
                new WFShaderFunction("FG", "FG", "ToonFog"),
                new WFShaderFunction("RF", "RF", "Refraction"),
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
        public static readonly Dictionary<string, WFCustomKeywordSetting> SpecialPropNameToKeywordMap = new Dictionary<string, WFCustomKeywordSetting>() {
            { "_UseVertexColor", new WFCustomKeywordSettingBool("_UseVertexColor", "_VC_ENABLE") },
            { "_TL_LineType", new WFCustomKeywordSettingBool("_TL_LineType", "_TL_EDGE_ENABLE") {
                enablePropName = "_TL_Enable",
            } },
            { "_MT_CubemapType", new WFCustomKeywordSettingEnum("_MT_CubemapType", "_", "_MT_ADD2ND_ENABLE", "_MT_ONLY2ND_ENABLE") {
                enablePropName = "_MT_Enable",
            } },
            { "_NM_2ndType", new WFCustomKeywordSettingEnum("_NM_2ndType", "_", "_NM_BL2ND_ENABLE", "_NM_SW2ND_ENABLE") {
                enablePropName = "_NM_Enable",
            } },
            { "_TS_Steps", new WFCustomKeywordSettingEnum("_TS_Steps", "_", "_TS_STEP1_ENABLE", "_TS_STEP2_ENABLE", "_TS_STEP3_ENABLE") {
                enablePropName = "_TS_Enable",
            } },
            { "_ES_Shape", new WFCustomKeywordSettingEnum("_ES_Shape", "_ES_SCROLL_ENABLE", "_ES_SCROLL_ENABLE", "_ES_SCROLL_ENABLE", "_") {
                enablePropName = "_ES_Enable",
            } },
            { "_TS_FixContrast", new WFCustomKeywordSettingEnum("_TS_FixContrast", "_", "_TS_FIXC_ENABLE") {
                enablePropName = "_TS_Enable",
            } },
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
            new WFI18NTranslation("Mask Texture (R)", "マスクテクスチャ (R)"),
            new WFI18NTranslation("Mask Texture (RGB)", "マスクテクスチャ (RGB)"),
            new WFI18NTranslation("Invert Mask Value", "マスク反転"),
            new WFI18NTranslation("UV Type", "UVタイプ"),
            new WFI18NTranslation("Brightness", "明るさ"),
            new WFI18NTranslation("Blend Type", "混合タイプ"),
            new WFI18NTranslation("Blend Power", "混合の強度"),
            new WFI18NTranslation("Blend Normal", "ノーマルマップ強度"),
            new WFI18NTranslation("Shape", "形状"),
            new WFI18NTranslation("Scale", "スケール"),
            new WFI18NTranslation("Direction", "方向"),
            new WFI18NTranslation("Distance", "距離"),
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
            new WFI18NTranslation("NM", "2nd NormalMap Mask Texture (R)", "2ndノーマルのマスク (R)"),
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
            new WFI18NTranslation("HL", "Change Alpha Transparency", "透明度も反映する"),
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
            new WFI18NTranslation("SH", "Anti-Shadow Mask Texture (R)", "アンチシャドウマスク (R)"),
            new WFI18NTranslation("SH", "Shade Color Suggest", "影色を自動設定する"),
            new WFI18NTranslation("SH", "Align the boundaries equally", "境界を等間隔に整列"),
            new WFI18NTranslation("SH", "Dont Ajust Contrast", "影コントラストを調整しない"),
            // RimLight
            new WFI18NTranslation("RM", "Rim Color", "リムライト色"),
            new WFI18NTranslation("RM", "Power", "強度(マスター)"),
            new WFI18NTranslation("RM", "Feather", "境界のぼかし強度"),
            new WFI18NTranslation("RM", "Power Top", "強度(上)"),
            new WFI18NTranslation("RM", "Power Side", "強度(横)"),
            new WFI18NTranslation("RM", "Power Bottom", "強度(下)"),
            // Overlay Texture
            new WFI18NTranslation("OL", "Overlay Color", "オーバーレイ テクスチャ"),
            new WFI18NTranslation("OL", "Overlay Texture", "オーバーレイ テクスチャ"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Overlay Texture", "頂点カラーをオーバーレイテクスチャに乗算する"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Mask Texture", "頂点カラーをマスクに乗算する"),
            new WFI18NTranslation("OL", "UV Scroll", "UVスクロール"),
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
            new WFI18NTranslation("AO", "Occlusion Map (RGB)", "オクルージョンマップ (RGB)"),
            new WFI18NTranslation("AO", "Use LightMap", "ライトマップも使用する"),
            new WFI18NTranslation("AO", "Contrast", "コントラスト"),
            // Distance Fade
            new WFI18NTranslation("DF", "Color", "色"),
            new WFI18NTranslation("DF", "Fade Distance (Near)", "フェード距離"),
            new WFI18NTranslation("DF", "Fade Distance (Far)", "フェード距離"),
            new WFI18NTranslation("DF", "Power", "強度"),
            new WFI18NTranslation("DF", "BackFace Shadow", "裏面は影にする"),
            // Toon Fog
            new WFI18NTranslation("FG", "Color", "フォグの色"),
            new WFI18NTranslation("FG", "Exponential", "変化の鋭さ"),
            new WFI18NTranslation("FG", "Base Offset", "フォグ原点の位置(オフセット)"),
            new WFI18NTranslation("FG", "Scale", "フォグ範囲のスケール"),
            // Tessellation
            new WFI18NTranslation("TE", "Tess Factor", "分割数"),
            new WFI18NTranslation("TE", "Smoothing", "スムーズ"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture", "スムーズマスク"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture (R)", "スムーズマスク (R)"),
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
            new WFI18NTranslation("FR", "Fur Repeat (Cutout)", "ファーの枚数 (Cutout側)"),
            new WFI18NTranslation("FR", "Fur Repeat (Transparent)", "ファーの枚数 (Transparent側)"),
            new WFI18NTranslation("FR", "Fur ShadowPower", "影の強さ"),
            new WFI18NTranslation("FR", "Tint Color (Base)", "色調整 (根元)"),
            new WFI18NTranslation("FR", "Tint Color (Tip)", "色調整 (先端)"),
            // Refraction
            new WFI18NTranslation("RF", "Refractive Index", "屈折率"),

            // メニュー
            new WFI18NTranslation("Copy material", "コピー"),
            new WFI18NTranslation("Paste value", "貼り付け"),
            new WFI18NTranslation("Paste (without Textures)", "貼り付け (Texture除く)"),
            new WFI18NTranslation("Reset", "リセット"),

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
            new WFI18NTranslation(WFMessageText.DgMigrationAuto, "UnlitWFシェーダのバージョンが更新されました。\nプロジェクト内のマテリアルをスキャンして、最新のマテリアル値へと更新しますか？"),
            new WFI18NTranslation(WFMessageText.DgMigrationManual, "プロジェクト内のマテリアルをスキャンして、最新のマテリアル値へと更新しますか？"),


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
            new WFI18NTranslation("OL", "Decal Color", "デカール テクスチャ"),
            new WFI18NTranslation("OL", "Decal Texture", "デカール テクスチャ"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Decal Texture", "頂点カラーをデカールに乗算する"),
        };


        /// <summary>
        /// ラベル名などの物理名 → 韓国語訳の変換マップ。
        /// </summary>
        public static readonly List<WFI18NTranslation> LangEnToKo = new List<WFI18NTranslation>() {
            // Base
            new WFI18NTranslation("Main Texture", "메인 텍스처"),
            new WFI18NTranslation("Color", "머티리얼 색상"),
            new WFI18NTranslation("Cull Mode", "컬링 모드"),
            new WFI18NTranslation("Use Vertex Color", "버텍스 컬러"),
            new WFI18NTranslation("Alpha CutOff Level", "컷 아웃 레벨"),
            // Common
            new WFI18NTranslation("Enable", "가능"),
            new WFI18NTranslation("Texture", "텍스처"),
            new WFI18NTranslation("Mask Texture", "텍스처 마스크"),
            new WFI18NTranslation("Mask Texture (R)", "텍스처 마스크 (R)"),
            new WFI18NTranslation("Mask Texture (RGB)", "텍스처 마스크 (RGB)"),
            new WFI18NTranslation("Invert Mask Value", "마스크 반전"),
            new WFI18NTranslation("UV Type", "UV타입"),
            new WFI18NTranslation("Brightness", "밝기"),
            new WFI18NTranslation("Blend Type", "혼합 타입"),
            new WFI18NTranslation("Blend Power", "혼합 강도"),
            new WFI18NTranslation("Blend Normal", "노멀맵 강도"),
            new WFI18NTranslation("Shape", "모양"),
            new WFI18NTranslation("Scale", "스케일"),
            new WFI18NTranslation("Direction", "방향"),
            new WFI18NTranslation("Distance", "거리"),
            new WFI18NTranslation("Roughen", "거칠기"),
            new WFI18NTranslation("Finer", "잘게 나누기"),
            new WFI18NTranslation("Tint Color", "색상 조정"),
            new WFI18NTranslation("FadeOut Distance (Near)", "페이드 아웃 거리(가까워짐)"),
            new WFI18NTranslation("FadeOut Distance (Far)", "페이드 아웃 거리(멀어짐)"),
            // Lit
            new WFI18NTranslation("Unlit Intensity", "Unlit Intensity (최소 명도값)"),
            new WFI18NTranslation("Saturate Intensity", "Saturate Intensity (최대 명도값)"),
            new WFI18NTranslation("Chroma Reaction", "Chroma Reaction (채도)"),
            new WFI18NTranslation("Cast Shadows", "타 오브젝트의 그림자 영향"),
            // Alpha
            new WFI18NTranslation("AL", "Alpha Source", "알파 소스"),
            new WFI18NTranslation("AL", "Alpha Mask Texture", "알파 텍스처"),
            new WFI18NTranslation("AL", "Power", "알파 강도"),
            new WFI18NTranslation("AL", "Fresnel Power", "프레넬 강도"),
            new WFI18NTranslation("AL", "Cutoff Threshold", "컷 아웃 임계값"),
            // BackFace Texture
            new WFI18NTranslation("BK", "Back Texture", "뒷면 텍스처"),
            new WFI18NTranslation("BK", "Back Color", "뒷면 색상"),
            // Color Change
            new WFI18NTranslation("CL", "monochrome", "단색화"),
            new WFI18NTranslation("CL", "Hur", "색상"),
            new WFI18NTranslation("CL", "Saturation", "채도"),
            new WFI18NTranslation("CL", "Brightness", "명도"),
            // Normal
            new WFI18NTranslation("NM", "NormalMap Texture", "노멀맵").AddTag("FR"),
            new WFI18NTranslation("NM", "Bump Scale", "범프 스케일"),
            new WFI18NTranslation("NM", "Shadow Power", "그림자 강도"),
            new WFI18NTranslation("NM", "Flip Mirror", "거울 XY 반전").AddTag("FR"),
            new WFI18NTranslation("NM", "2nd Normal Blend", "2nd맵 혼합"),
            new WFI18NTranslation("NM", "2nd NormalMap Texture", "2nd노멀맵"),
            new WFI18NTranslation("NM", "2nd Bump Scale", "2nd범프 스케일"),
            new WFI18NTranslation("NM", "2nd NormalMap Mask Texture", "2nd노멀 텍스처"),
            new WFI18NTranslation("NM", "2nd NormalMap Mask Texture (R)", "2nd노멀맵 마스크 (R)"),
            // Metallic
            new WFI18NTranslation("MT", "Metallic", "메탈릭 강도"),
            new WFI18NTranslation("MT", "Smoothness", "부드럽게"),
            new WFI18NTranslation("MT", "Monochrome Reflection", "흑백 반사"),
            new WFI18NTranslation("MT", "Specular", "스펙큘러"),
            new WFI18NTranslation("MT", "MetallicMap Type", "Metallic맵 타입"),
            new WFI18NTranslation("MT", "MetallicSmoothnessMap Texture", "MetallicSmoothness맵"),
            new WFI18NTranslation("MT", "RoughnessMap Texture", "Roughness맵"),
            new WFI18NTranslation("MT", "2nd CubeMap Blend", "큐브 맵 혼합"),
            new WFI18NTranslation("MT", "2nd CubeMap", "큐브 맵"),
            new WFI18NTranslation("MT", "2nd CubeMap Power", "큐브 맵 강도"),
            // Light Matcap
            new WFI18NTranslation("HL", "Matcap Type", "matcap 타입").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Sampler", "matcap 샘플러").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Base Color", "matcap 베이스 색상").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Tint Color", "matcap 색상 조절").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Parallax", "시차값(Parallax)").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Power", "matcap 강도").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Change Alpha Transparency", "알파값 반영"),
            // Lame
            new WFI18NTranslation("LM", "Color", "LM색상・텍스처"),
            new WFI18NTranslation("LM", "Texture", "LM색상・텍스처"),
            new WFI18NTranslation("LM", "Random Color", "랜덤 색상"),
            new WFI18NTranslation("LM", "Change Alpha Transparency", "알파값 반영"),
            new WFI18NTranslation("LM", "Dencity", "밀도"),
            new WFI18NTranslation("LM", "Glitter", "반짝거림"),
            new WFI18NTranslation("LM", "FadeOut Angle", "페이드 아웃 앵글"),
            new WFI18NTranslation("LM", "Anim Speed", "애니메이션 속도"),
            // ToonShade
            new WFI18NTranslation("SH", "Steps", "반복값"),
            new WFI18NTranslation("SH", "Base Color", "베이스 색상"),
            new WFI18NTranslation("SH", "Base Shade Texture", "베이스 텍스처"),
            new WFI18NTranslation("SH", "1st Shade Color", "1st 그림자 색상"),
            new WFI18NTranslation("SH", "1st Shade Texture", "1st 그림자 텍스처"),
            new WFI18NTranslation("SH", "2nd Shade Color", "2nd 그림자 색상"),
            new WFI18NTranslation("SH", "2nd Shade Texture", "2nd 그림자 텍스처"),
            new WFI18NTranslation("SH", "3rd Shade Color", "3rd 그림자 색상"),
            new WFI18NTranslation("SH", "3rd Shade Texture", "3rd 그림자 텍스처"),
            new WFI18NTranslation("SH", "Shade Power", "그림자 강도"),
            new WFI18NTranslation("SH", "1st Border", "1st 그림자 경계값"),
            new WFI18NTranslation("SH", "2nd Border", "2nd 그림자 경계값"),
            new WFI18NTranslation("SH", "3rd Border", "3rd 그림자 경계값"),
            new WFI18NTranslation("SH", "Feather", "그림자 경계의 흐림값"),
            new WFI18NTranslation("SH", "Anti-Shadow Mask Texture", "안티 그림자 마스크"),
            new WFI18NTranslation("SH", "Anti-Shadow Mask Texture (R)", "안티 그림자 마스크 (R)"),
            new WFI18NTranslation("SH", "Shade Color Suggest", "그림자 자동 설정"),
            new WFI18NTranslation("SH", "Align the boundaries equally", "경계값 동일 정렬 "),
            new WFI18NTranslation("SH", "Dont Ajust Contrast", "그림자 콘트라스트를 조정하지 않는다"),
            // RimLight
            new WFI18NTranslation("RM", "Rim Color", "림라이트 색상"),
            new WFI18NTranslation("RM", "Power", "강도(최대)"),
            new WFI18NTranslation("RM", "Feather", "흐림값"),
            new WFI18NTranslation("RM", "Power Top", "강도(위)"),
            new WFI18NTranslation("RM", "Power Side", "강도(좌우)"),
            new WFI18NTranslation("RM", "Power Bottom", "강도(아래)"),
            // Overlay Texture
            new WFI18NTranslation("OL", "Overlay Color", "한국어 텍스처"),
            new WFI18NTranslation("OL", "Overlay Texture", "한국어 텍스처"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Overlay Texture", "버텍스 컬러에 한국어 텍스처 곱하기"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Mask Texture", "버텍스 컬러에 마스크 텍스처 곱하기"),
            new WFI18NTranslation("OL", "UV Scroll", "UV스크롤"),
            // EmissiveScroll
            new WFI18NTranslation("ES", "Emission", "Emission"),
            new WFI18NTranslation("ES", "Emission Texture", "Emission 텍스처"),
            new WFI18NTranslation("ES", "Wave Type", "웨이브 타입"),
            new WFI18NTranslation("ES", "Change Alpha Transparency", "알파값 반영"),
            new WFI18NTranslation("ES", "Direction Type", "방향의 타입"),
            new WFI18NTranslation("ES", "LevelOffset", "영점 조절"),
            new WFI18NTranslation("ES", "Sharpness", "날카롭게"),
            new WFI18NTranslation("ES", "ScrollSpeed", "스크롤 스피드"),
            // Outline
            new WFI18NTranslation("LI", "Line Color", "선 색상"),
            new WFI18NTranslation("LI", "Line Width", "선 굵기"),
            new WFI18NTranslation("LI", "Line Type", "선 타입"),
            new WFI18NTranslation("LI", "Custom Color Texture", "선 색상 텍스처"),
            new WFI18NTranslation("LI", "Blend Custom Color Texture", "선 색상 텍스처와 블랜드"),
            new WFI18NTranslation("LI", "Blend Base Color", "블렌드 베이스 색상"),
            new WFI18NTranslation("LI", "Z-shift (tweak)", "카메라로 부터 멀리함"),
            // Ambient Occlusion
            new WFI18NTranslation("AO", "Occlusion Map", "오클루전 맵"),
            new WFI18NTranslation("AO", "Occlusion Map (RGB)", "오클루전 맵 (RGB)"),
            new WFI18NTranslation("AO", "Use LightMap", "라이트 맵 사용"),
            new WFI18NTranslation("AO", "Contrast", "콘트라스트"),
            // Distance Fade
            new WFI18NTranslation("DF", "Color", "색상"),
            new WFI18NTranslation("DF", "Fade Distance (Near)", "페이드 거리(가까워짐)"),
            new WFI18NTranslation("DF", "Fade Distance (Far)", "페이드 거리(멀어짐)"),
            new WFI18NTranslation("DF", "Power", "강도"),
            new WFI18NTranslation("DF", "BackFace Shadow", "이면은 그림자"),
            // Toon Fog
            new WFI18NTranslation("FG", "Color", "Fog색상"),
            new WFI18NTranslation("FG", "Exponential", "Fog변화값"),
            new WFI18NTranslation("FG", "Base Offset", "Fog의 원점(오프셋)"),
            new WFI18NTranslation("FG", "Scale", "Fog 스케일"),
            // Tessellation
            new WFI18NTranslation("TE", "Tess Factor", "분할값"),
            new WFI18NTranslation("TE", "Smoothing", "Smooth"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture", "Smooth 마스크 텍스처"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture (R)", "Smooth 마스크 텍스처 (R)"),
            // Lit Advance
            new WFI18NTranslation("Sun Source", "태양광 모드"),
            new WFI18NTranslation("Custom Sun Azimuth", "커스텀 태양광 방향"),
            new WFI18NTranslation("Custom Sun Altitude", "커스텀 태양광 고도"),
            new WFI18NTranslation("Disable BackLit", "역광 무보정"),
            new WFI18NTranslation("Disable ObjectBasePos", "매쉬의 원점을 취득하지 않음"),
            // Light Bake Effects
            new WFI18NTranslation("GI", "Indirect Multiplier", "간접광 배율"),
            new WFI18NTranslation("GI", "Emission Multiplier", "Emission 배율"),
            new WFI18NTranslation("GI", "Indirect Chroma", "간접광 채도"),
            // Gem Background
            new WFI18NTranslation("GB", "Background Color", "배경 색상 (뒷면 색상)"),
            // Gem Reflection
            new WFI18NTranslation("GR", "CubeMap", "큐브맵"),
            new WFI18NTranslation("GR", "Monochrome Reflection", "흑백 반사"),
            new WFI18NTranslation("GR", "2nd CubeMap Power", "큐브맵 강도"),
            // Gem Flake
            new WFI18NTranslation("GF", "Flake Size (front)", "크기 (표면)"),
            new WFI18NTranslation("GF", "Flake Size (back)", "크기 (뒷면)"),
            new WFI18NTranslation("GF", "Shear", "시어값"),
            new WFI18NTranslation("GF", "Brighten", "밝기"),
            new WFI18NTranslation("GF", "Darken", "어둡기"),
            new WFI18NTranslation("GF", "Twinkle", "깜빡거림"),
            // Fake Fur
            new WFI18NTranslation("FR", "Fur Noise Texture", "Fur 노이즈 텍스처"),
            new WFI18NTranslation("FR", "Fur Height", "Fur 높이"),
            new WFI18NTranslation("FR", "Fur Height (Cutout)", "Fur 높이 (Cutout)"),
            new WFI18NTranslation("FR", "Fur Height (Transparent)", "Fur 높이 (Transparent)"),
            new WFI18NTranslation("FR", "Fur Vector", "Fur 방향"),
            new WFI18NTranslation("FR", "Fur Repeat", "Fur 개수"),
            new WFI18NTranslation("FR", "Fur Repeat (Cutout)", "Fur 개수 (Cutout)"),
            new WFI18NTranslation("FR", "Fur Repeat (Transparent)", "Fur 개수 (Transparent)"),
            new WFI18NTranslation("FR", "Fur ShadowPower", "Fur 강도"),
            new WFI18NTranslation("FR", "Tint Color (Base)", "색조절 (뿌리 부분)"),
            new WFI18NTranslation("FR", "Tint Color (Tip)", "색조절 (끝 부분)"),
            // Refraction
            new WFI18NTranslation("RF", "Refractive Index", "한국어"),

            // メニュー
            new WFI18NTranslation("Copy material", "복사"),
            new WFI18NTranslation("Paste value", "붙여넣기"),
            new WFI18NTranslation("Paste (without Textures)", "붙여넣기 (Texture제외)"),
            new WFI18NTranslation("Reset", "리셋"),

            // その他のテキスト
            new WFI18NTranslation(WFMessageText.NewerVersion, "신버전이 출시되었습니다. \n최신판: "),
            new WFI18NTranslation(WFMessageText.PlzMigration, "이 머티리얼은 구버전에서 작성된 것 같습니다. \n최신버전으로 변환하시겠습니까?"),
            new WFI18NTranslation(WFMessageText.PlzBatchingStatic, "이 머티리얼은 Batching Static을 설정한 MeshRenderer 에서 사용되는 것 같습니다. \nBatching Static용 설정으로 변경하시겠습니까?"),
            new WFI18NTranslation(WFMessageText.PlzLightmapStatic, "이 머티리얼은 Lightmap Static을 설정한 MeshRenderer 에서 사용되는 것 같습니다. \nLightmap을 활성화하시겠습니까?"),
            new WFI18NTranslation(WFMessageText.PsAntiShadowMask, "안티 섀도우 마스크는 아바타 얼굴을 새하얗게 칠한 마스크 텍스처를 지정해 주세요. 마스크 반전을 체크하시면 머티리얼 전체를 얼굴로 간주할 수도 있습니다."),

            new WFI18NTranslation(WFMessageText.PsCapTypeMedian, "MEDIAN_CAP은 회색을 기준으로 한 가산과 감산 합성을 실시하는 matcap 입니다."),
            new WFI18NTranslation(WFMessageText.PsCapTypeLight, "LIGHT_CAP은 검정색을 기준으로 한 가산 합성을 실시하는 matcap입니다."),
            new WFI18NTranslation(WFMessageText.PsCapTypeShade, "SHADE_CAP은 흰색을 기준으로 한 곱셉 합성을 실시하는matcap입니다."),

            new WFI18NTranslation(WFMessageText.DgChangeMobile, "셰이더를 모바일용으로 전환하시겠습니까? \n\n전환 후 되돌릴 수 있으나 백업을 해놓는 것을 추천드립니다."),
            new WFI18NTranslation(WFMessageText.DgMigrationAuto, "UnlitWF의 버전이 갱신되었습니다. \n프로젝트 내의 머티리얼을 검사하여 최신 머티리얼값으로 갱신하시겠습니까?"),
            new WFI18NTranslation(WFMessageText.DgMigrationManual, "프로젝트 내의 머티리얼을 검사하여 최신 머티리얼값으로 갱신하시겠습니까?"),


            new WFI18NTranslation(WFMessageButton.Cleanup, "머티리얼 내에서 불필요한 데이터 삭제"),
            new WFI18NTranslation(WFMessageButton.ApplyTemplate, "템플릿부터 적용"),
            new WFI18NTranslation(WFMessageButton.SaveTemplate, "템플릿으로 저장"),

            // 今は使っていないはずの項目
            new WFI18NTranslation("OL", "Decal Color", "데칼 텍스처"),
            new WFI18NTranslation("OL", "Decal Texture", "데칼 텍스처"),
            new WFI18NTranslation("OL", "Multiply VertexColor To Decal Texture", "버텍스 컬러에 데칼 텍스처 곱하기"),
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
        public static readonly string DgMigrationAuto = "The version of the UnlitWF shader has been updated.\nDo you want to scan the materials in your project and update them to the latest material values?";
        public static readonly string DgMigrationManual = "Do you want to scan the materials in your project and update them to the latest material values?";
    }

    internal static class WFMessageButton
    {
        public static readonly string Cleanup = "Remove unused properties from Materials";
        public static readonly string ApplyTemplate = "Apply from Template";
        public static readonly string SaveTemplate = "Save as Template";
    }
}

#endif
