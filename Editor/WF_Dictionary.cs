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

#if UNITY_EDITOR

using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace UnlitWF
{
    /// <summary>
    /// 辞書本体。ユーティリティ関数は他のクラスにて定義する。
    /// </summary>
    static class WFShaderDictionary
    {
        /// <summary>
        /// シェーダ名のリスト。
        /// </summary>
        public static readonly List<WFShaderName> ShaderNameList = new List<WFShaderName>() {

            // ================
            // UnToon 系列
            // ================

            new WFShaderName("BRP", "UnToon", "Basic", "Opaque",                       "UnlitWF/WF_UnToon_Opaque", represent: true),
            new WFShaderName("BRP", "UnToon", "Basic", "TransCutout",                  "UnlitWF/WF_UnToon_TransCutout"),
            new WFShaderName("BRP", "UnToon", "Basic", "Transparent",                  "UnlitWF/WF_UnToon_Transparent"),
            new WFShaderName("BRP", "UnToon", "Basic", "Transparent3Pass",             "UnlitWF/WF_UnToon_Transparent3Pass"),
            new WFShaderName("BRP", "UnToon", "Basic", "Transparent_Mask",             "UnlitWF/WF_UnToon_Transparent_Mask"),
            new WFShaderName("BRP", "UnToon", "Basic", "Transparent_MaskOut",          "UnlitWF/WF_UnToon_Transparent_MaskOut"),
            new WFShaderName("BRP", "UnToon", "Basic", "Transparent_MaskOut_Blend",    "UnlitWF/WF_UnToon_Transparent_MaskOut_Blend"),
            
            new WFShaderName("BRP", "UnToon", "Outline", "Opaque",                     "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Opaque"),
            new WFShaderName("BRP", "UnToon", "Outline", "TransCutout",                "UnlitWF/UnToon_Outline/WF_UnToon_Outline_TransCutout"),
            new WFShaderName("BRP", "UnToon", "Outline", "Transparent",                "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent"),
            new WFShaderName("BRP", "UnToon", "Outline", "Transparent3Pass",           "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent3Pass"),
            new WFShaderName("BRP", "UnToon", "Outline", "Transparent_MaskOut",        "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut"),
            new WFShaderName("BRP", "UnToon", "Outline", "Transparent_MaskOut_Blend",  "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut_Blend"),

            new WFShaderName("BRP", "UnToon", "Outline_LineOnly", "Opaque",            "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Opaque"),
            new WFShaderName("BRP", "UnToon", "Outline_LineOnly", "TransCutout",       "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_TransCutout"),
            new WFShaderName("BRP", "UnToon", "Outline_LineOnly", "Transparent",       "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Transparent"),
            new WFShaderName("BRP", "UnToon", "Outline_LineOnly", "Transparent_MaskOut",   "UnlitWF/UnToon_Outline/WF_UnToon_OutlineOnly_Transparent_MaskOut"),

            new WFShaderName("BRP", "UnToon", "Mobile", "Opaque",                      "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"),
            new WFShaderName("BRP", "UnToon", "Mobile", "TransCutout",                 "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransCutout"),
            new WFShaderName("BRP", "UnToon", "Mobile", "Transparent",                 "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"),
            new WFShaderName("BRP", "UnToon", "Mobile", "TransparentOverlay",          "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransparentOverlay"),

            new WFShaderName("BRP", "UnToon", "Mobile_Outline", "Opaque",              "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Outline_Opaque"),
            new WFShaderName("BRP", "UnToon", "Mobile_Outline", "TransCutout",         "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Outline_TransCutout"),

            new WFShaderName("BRP", "UnToon", "Mobile_LineOnly", "Opaque",             "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque"),
            new WFShaderName("BRP", "UnToon", "Mobile_LineOnly", "TransCutout",        "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_TransCutout"),

            new WFShaderName("BRP", "UnToon", "PowerCap", "Opaque",                    "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Opaque"),
            new WFShaderName("BRP", "UnToon", "PowerCap", "TransCutout",               "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_TransCutout"),
            new WFShaderName("BRP", "UnToon", "PowerCap", "Transparent",               "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent"),
            new WFShaderName("BRP", "UnToon", "PowerCap", "Transparent3Pass",          "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent3Pass"),

            new WFShaderName("BRP", "UnToon", "Tessellation", "Opaque",                "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Opaque"),
            new WFShaderName("BRP", "UnToon", "Tessellation", "TransCutout",           "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_TransCutout"),
            new WFShaderName("BRP", "UnToon", "Tessellation", "Transparent",           "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Transparent"),
            new WFShaderName("BRP", "UnToon", "Tessellation", "Transparent3Pass",      "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Transparent3Pass"),

            // ================
            // FakeFur 系列
            // ================

            new WFShaderName("BRP", "FakeFur", "Basic", "TransCutout",                 "UnlitWF/WF_FakeFur_TransCutout"),
            new WFShaderName("BRP", "FakeFur", "Basic", "Transparent",                 "UnlitWF/WF_FakeFur_Transparent"),
            new WFShaderName("BRP", "FakeFur", "Basic", "Mix",                         "UnlitWF/WF_FakeFur_Mix", represent: true),

            new WFShaderName("BRP", "FakeFur", "FurOnly", "TransCutout",               "UnlitWF/WF_FakeFur_FurOnly_TransCutout"),
            new WFShaderName("BRP", "FakeFur", "FurOnly", "Transparent",               "UnlitWF/WF_FakeFur_FurOnly_Transparent"),
            new WFShaderName("BRP", "FakeFur", "FurOnly", "Mix",                       "UnlitWF/WF_FakeFur_FurOnly_Mix"),

            // ================
            // Gem 系列
            // ================

            new WFShaderName("BRP", "Gem", "Basic", "Opaque",                          "UnlitWF/WF_Gem_Opaque"),
            new WFShaderName("BRP", "Gem", "Basic", "Transparent",                     "UnlitWF/WF_Gem_Transparent", represent: true),

            // ================
            // Grass 系列
            // ================

            new WFShaderName("BRP", "Grass", "Basic", "TransCutout",                   "UnlitWF/WF_Grass_TransCutout", represent: true),

            // ================
            // Water 系列
            // ================

            new WFShaderName("BRP", "Water", "Surface", "Opaque",                      "UnlitWF/WF_Water_Surface_Opaque", represent: true),
            new WFShaderName("BRP", "Water", "Surface", "TransCutout",                 "UnlitWF/WF_Water_Surface_TransCutout"),
            new WFShaderName("BRP", "Water", "Surface", "Transparent",                 "UnlitWF/WF_Water_Surface_Transparent"),
            new WFShaderName("BRP", "Water", "Surface", "Transparent_Refracted",       "UnlitWF/WF_Water_Surface_Transparent_Refracted"),
            new WFShaderName("BRP", "Water", "FX_Caustics", "Addition",                "UnlitWF/WF_Water_Caustics_Addition"),
            new WFShaderName("BRP", "Water", "FX_DepthFog", "Transparent",             "UnlitWF/WF_Water_DepthFog_Fade"),
            new WFShaderName("BRP", "Water", "FX_Sun", "Addition",                     "UnlitWF/WF_Water_Sun_Addition"),
            new WFShaderName("BRP", "Water", "FX_Lamp", "Addition",                    "UnlitWF/WF_Water_Lamp_Addition"),

            // ================
            // Particle 系列
            // ================

#if UNITY_2019_1_OR_NEWER // Particle系は2018には入れないのでスキップする
            new WFShaderName("BRP", "Particle", "Basic", "Opaque",                     "UnlitWF/WF_Particle_Opaque"),
            new WFShaderName("BRP", "Particle", "Basic", "TransCutout",                "UnlitWF/WF_Particle_TransCutout"),
            new WFShaderName("BRP", "Particle", "Basic", "Transparent",                "UnlitWF/WF_Particle_Transparent"),
            new WFShaderName("BRP", "Particle", "Basic", "Addition",                   "UnlitWF/WF_Particle_Addition"),
            new WFShaderName("BRP", "Particle", "Basic", "Multiply",                   "UnlitWF/WF_Particle_Multiply"),
#endif

            // ================
            // UnToon 系列(URP)
            // ================

            new WFShaderName("URP", "UnToon", "Basic", "Opaque",                       "UnlitWF_URP/WF_UnToon_Opaque", represent: true),
            new WFShaderName("URP", "UnToon", "Basic", "TransCutout",                  "UnlitWF_URP/WF_UnToon_TransCutout"),
            new WFShaderName("URP", "UnToon", "Basic", "Transparent",                  "UnlitWF_URP/WF_UnToon_Transparent"),
            new WFShaderName("URP", "UnToon", "Basic", "Transparent_Mask",             "UnlitWF_URP/WF_UnToon_Transparent_Mask"),
            new WFShaderName("URP", "UnToon", "Basic", "Transparent_MaskOut",          "UnlitWF_URP/WF_UnToon_Transparent_MaskOut"),

            new WFShaderName("URP", "UnToon", "Mobile", "Opaque",                      "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Opaque"),
            new WFShaderName("URP", "UnToon", "Mobile", "TransCutout",                 "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_TransCutout"),
            new WFShaderName("URP", "UnToon", "Mobile", "Transparent",                 "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Transparent"),
            new WFShaderName("URP", "UnToon", "Mobile", "TransparentOverlay",          "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_TransparentOverlay"),

            new WFShaderName("URP", "UnToon", "Outline", "Opaque",                     "UnlitWF_URP/UnToon_Outline/WF_UnToon_Outline_Opaque"),
            new WFShaderName("URP", "UnToon", "Outline", "TransCutout",                "UnlitWF_URP/UnToon_Outline/WF_UnToon_Outline_TransCutout"),

            new WFShaderName("URP", "UnToon", "Outline_LineOnly", "Opaque",            "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_Opaque"),
            new WFShaderName("URP", "UnToon", "Outline_LineOnly", "TransCutout",       "UnlitWF_URP/UnToon_Outline/WF_UnToon_OutlineOnly_TransCutout"),

            new WFShaderName("URP", "UnToon", "Mobile_Outline", "Opaque",              "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Outline_Opaque"),
            new WFShaderName("URP", "UnToon", "Mobile_Outline", "TransCutout",         "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_Outline_TransCutout"),

            new WFShaderName("URP", "UnToon", "Mobile_LineOnly", "Opaque",             "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_Opaque"),
            new WFShaderName("URP", "UnToon", "Mobile_LineOnly", "TransCutout",        "UnlitWF_URP/UnToon_Mobile/WF_UnToon_Mobile_OutlineOnly_TransCutout"),

            // ================
            // FakeFur 系列(URP)
            // ================

            new WFShaderName("URP", "FakeFur", "Basic", "TransCutout",                 "UnlitWF_URP/WF_FakeFur_TransCutout", represent: true),
            new WFShaderName("URP", "FakeFur", "Basic", "Transparent",                 "UnlitWF_URP/WF_FakeFur_Transparent"),

            new WFShaderName("URP", "FakeFur", "FurOnly", "TransCutout",               "UnlitWF_URP/WF_FakeFur_FurOnly_TransCutout"),
            new WFShaderName("URP", "FakeFur", "FurOnly", "Transparent",               "UnlitWF_URP/WF_FakeFur_FurOnly_Transparent"),

            // ================
            // Gem 系列(URP)
            // ================

            new WFShaderName("URP", "Gem", "Basic", "Opaque",                          "UnlitWF_URP/WF_Gem_Opaque"),
            new WFShaderName("URP", "Gem", "Basic", "Transparent",                     "UnlitWF_URP/WF_Gem_Transparent", represent: true),

            // ================
            // Water 系列(URP)
            // ================

            new WFShaderName("URP", "Water", "Surface", "Opaque",                      "UnlitWF_URP/WF_Water_Surface_Opaque", represent: true),
            new WFShaderName("URP", "Water", "Surface", "TransCutout",                 "UnlitWF_URP/WF_Water_Surface_TransCutout"),
            new WFShaderName("URP", "Water", "Surface", "Transparent",                 "UnlitWF_URP/WF_Water_Surface_Transparent"),
        };

        private static bool HasPropertyPrefix(Material mat, string prefix)
        {
            if (mat == null || mat.shader == null)
            {
                return false;
            }
            foreach(var pn in WFAccessor.GetAllPropertyNames(mat.shader))
            {
                if (pn.StartsWith(prefix))
                {
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// シェーダ機能のリスト。
        /// </summary>
        public static readonly List<WFShaderFunction> ShaderFuncList = new List<WFShaderFunction>() {
                // 基本機能
                new WFShaderFunction("AL", "AL", "Transparent Alpha", (self, mat) => mat.shader.name.Contains("Trans") && mat.HasProperty("_AL_Source")),
                new WFShaderFunction("NM", "NM", "NormalMap"),
                new WFShaderFunction("NS", "NS", "Detail NormalMap"),
                new WFShaderFunction("MT", "MT", "Metallic"),
                new WFShaderFunction("ES", "ES", "Emission"),
                new WFShaderFunction("AO", "AO", "Ambient Occlusion"),
                new WFShaderFunction("TE", "TE", "Tessellation", (self, mat) => mat.shader.name.Contains("Tess")),

                // Toon系機能
                new WFShaderFunction("TS", "TS", "ToonShade"),
                new WFShaderFunction("TR", "TR", "RimLight"),
                new WFShaderFunction("TL", "TL", "Outline"),
                new WFShaderFunction("TFG", "TFG", "ToonFog"),

                // matcap一味
                new WFShaderFunction("HL", "HL", "Light Matcap"),
                new WFShaderFunction("HA", "HL_1", "Light Matcap 2", (self, mat) => WFShaderFunction.IsEnable("_HL_Enable_1", mat)),
                new WFShaderFunction("HB", "HL_2", "Light Matcap 3", (self, mat) => WFShaderFunction.IsEnable("_HL_Enable_2", mat)),
                new WFShaderFunction("HC", "HL_3", "Light Matcap 4", (self, mat) => WFShaderFunction.IsEnable("_HL_Enable_3", mat)),
                new WFShaderFunction("HD", "HL_4", "Light Matcap 5", (self, mat) => WFShaderFunction.IsEnable("_HL_Enable_4", mat)),
                new WFShaderFunction("HE", "HL_5", "Light Matcap 6", (self, mat) => WFShaderFunction.IsEnable("_HL_Enable_5", mat)),
                new WFShaderFunction("HF", "HL_6", "Light Matcap 7", (self, mat) => WFShaderFunction.IsEnable("_HL_Enable_6", mat)),
                new WFShaderFunction("HG", "HL_7", "Light Matcap 8", (self, mat) => WFShaderFunction.IsEnable("_HL_Enable_7", mat)),

                // 個別機能
                new WFShaderFunction("GMB", "GMB", "Gem Background"),
                new WFShaderFunction("GMF", "GMF", "Gem Flake"),
                new WFShaderFunction("GMR", "GMR", "Gem Reflection"),
                new WFShaderFunction("FUR", "FUR", "Fake Fur", (self, mat) => mat.shader.name.Contains("Fur")),
                new WFShaderFunction("GRS", "GRS", "Grass", (self, mat) => mat.shader.name.Contains("Grass")),
                new WFShaderFunction("GRW", "GRW", "Grass Wave"),

                new WFShaderFunction("WAD", "WAD", "Distance Fade"),
                new WFShaderFunction("WA1", "WAV_1", "Waving 1", (self, mat) => WFShaderFunction.IsEnable("_WAV_Enable_1", mat)),
                new WFShaderFunction("WA2", "WAV_2", "Waving 2", (self, mat) => WFShaderFunction.IsEnable("_WAV_Enable_2", mat)),
                new WFShaderFunction("WA3", "WAV_3", "Waving 3", (self, mat) => WFShaderFunction.IsEnable("_WAV_Enable_3", mat)),
                new WFShaderFunction("WAS", "WAS", "Water Specular"),
                new WFShaderFunction("WAM", "WAM", "Water Reflection"),
                new WFShaderFunction("WAR", "WAR", "Water Lamp&Sun Reflection"),
                new WFShaderFunction("WMI", "WMI", "Water VRC Mirror Reflection"),

                new WFShaderFunction("PA", "PA", "Particle System"),

                // その他の機能
                new WFShaderFunction("BKT", "BKT", "BackFace Texture"),
                new WFShaderFunction("CHM", "CHM", "3ch Color Mask"),
                new WFShaderFunction("CGR", "CGR", "Gradient Map"),
                new WFShaderFunction("CLC", "CLC", "Color Change"),
                new WFShaderFunction("LME", "LME", "Lame"),
                new WFShaderFunction("OVL", "OVL", "Overlay Texture"),
                new WFShaderFunction("DFD", "DFD", "Distance Fade"),
                new WFShaderFunction("DSV", "DSV", "Dissolve"),
                new WFShaderFunction("LBE", "LBE", "Light Bake Effects"),

                // カスタムシェーダ系
                new WFShaderFunction("CRF", "CRF", "Refraction"),
                new WFShaderFunction("CGL", "CGL", "Frosted Glass"),
                new WFShaderFunction("CGO", "CGO", "Ghost Transparent"),
                new WFShaderFunction("CCT", "CCT", "ClearCoat"),

                new WFShaderFunction("GL", "GL", "Lit & Lit Advance", (self, mat) => HasPropertyPrefix(mat, "_GL")),

                // 以下のプレフィックスは昔使っていたものなので使わない方が良い
                // GB, GF, GR, FG, BK, CH, CL, LM, OL, DF, GI, RF
            };

        /// <summary>
        /// プレフィックス名のついてない特殊なプロパティ名 → ラベルの変換マップ。
        /// </summary>
        public static readonly Dictionary<string, string> SpecialPropNameToLabelMap = new Dictionary<string, string>() {
            { "_Cutoff", "AL" },
            { "_BumpMap", "NM" },
            { "_BumpScale", "NM" },
            { "_DetailNormalMap", "NS" },
            { "_DetailNormalMapScale", "NS" },
            { "_MetallicGlossMap", "MT" },
            { "_SpecGlossMap", "MT" },
            { "_EmissionColor", "ES" },
            { "_EmissionMap", "ES" },
            { "_OcclusionMap", "AO" },
        };

        /// <summary>
        /// ENABLEキーワードに対応していない特殊なプロパティ名 → キーワードの変換マップ。
        /// </summary>
        public static readonly List<WFCustomKeywordSetting> SpecialPropNameToKeywordList = new List<WFCustomKeywordSetting>() {
            // 基本機能
            new WFCustomKeywordSettingBool("_UseVertexColor", "_VC_ENABLE"),
            new WFCustomKeywordSettingBool("_PA_UseFlipBook", "_PF_ENABLE"),
            new WFCustomKeywordSettingEnum("_GL_LightMode", "_GL_AUTO_ENABLE", "_GL_ONLYDIR_ENABLE", "_GL_ONLYPOINT_ENABLE", "_GL_WSDIR_ENABLE", "_GL_LSDIR_ENABLE", "_GL_WSPOS_ENABLE"),
            new WFCustomKeywordSettingBool("_GL_NCC_Enable", "_GL_NCC_ENABLE"),
            new WFCustomKeywordSettingBool("_TL_LineType", "_TL_EDGE_ENABLE") {
                enablePropName = "_TL_Enable",
            },
            new WFCustomKeywordSettingCustom("_SpecGlossMap",
                mat => WFAccessor.GetTexture(mat, "_SpecGlossMap") == null && WFAccessor.GetInt(mat, "_MT_InvRoughnessMaskVal", 0) == 0 , "_MT_NORHMAP_ENABLE") {
                enablePropName = "_MT_Enable",
            },
            new WFCustomKeywordSettingCustom("_MT_InvRoughnessMaskVal",
                mat => WFAccessor.GetTexture(mat, "_SpecGlossMap") == null && WFAccessor.GetInt(mat, "_MT_InvRoughnessMaskVal", 0) == 0 , "_MT_NORHMAP_ENABLE") {
                enablePropName = "_MT_Enable",
            },
            new WFCustomKeywordSettingEnum("_MT_CubemapType", "_", "_", "_MT_ONLY2ND_ENABLE") {
                enablePropName = "_MT_Enable",
            },
            new WFCustomKeywordSettingEnum("_TS_Steps", "_", "_TS_STEP1_ENABLE", "_TS_STEP2_ENABLE", "_TS_STEP3_ENABLE") {
                enablePropName = "_TS_Enable",
            },
            new WFCustomKeywordSettingBool("_ES_ScrollEnable", "_ES_SCROLL_ENABLE") {
                enablePropName = "_ES_Enable",
            },
            new WFCustomKeywordSettingBool("_ES_AuLinkEnable", "_ES_AULINK_ENABLE") {
                enablePropName = "_ES_Enable",
            },
            new WFCustomKeywordSettingEnum("_TS_FixContrast", "_", "_TS_FIXC_ENABLE") {
                enablePropName = "_TS_Enable",
            },
            // 特殊シェーダ用
            new WFCustomKeywordSettingEnum("_CGL_BlurMode", "_", "_CGL_BLURFAST_ENABLE") {
                enablePropName = "_CGL_Enable",
            },
            new WFCustomKeywordSettingEnum("_GRS_HeightType", "_", "_", "_GRS_MASKTEX_ENABLE", "_"),
            new WFCustomKeywordSettingBool("_GRS_EraseSide", "_GRS_ERSSIDE_ENABLE"),
            new WFCustomKeywordSettingEnum("_WAM_CubemapType", "_", "_", "_WAM_ONLY2ND_ENABLE") {
                enablePropName = "_WAM_Enable",
            },
        };

        /// <summary>
        /// ENABLEキーワードに対応していない特殊なプロパティ名 → キーワードの変換マップ。
        /// </summary>
        public static readonly Dictionary<string, WFCustomKeywordSetting> SpecialPropNameToKeywordMap = ToWFCustomKeywordSettingMap(SpecialPropNameToKeywordList);

        private static Dictionary<string, WFCustomKeywordSetting> ToWFCustomKeywordSettingMap(IEnumerable<WFCustomKeywordSetting> list)
        {
            var result = new Dictionary<string, WFCustomKeywordSetting>();
            foreach(var c in list)
            {
                result[c.propertyName] = c;
            }
            return result;
        }

        /// <summary>
        /// ラベル名などの物理名 → 日本語訳の変換マップ。
        /// </summary>
        public static readonly List<WFI18NTranslation> LangEnToJa = new List<WFI18NTranslation>() {
            // HeaderTitle
            new WFI18NTranslation("3ch Color Mask", "3chカラーマスク"),
            new WFI18NTranslation("Ambient Occlusion", "AOマップとライトマップ"),
            new WFI18NTranslation("BackFace Texture", "裏面テクスチャ"),
            new WFI18NTranslation("Base", "基本設定"),
            new WFI18NTranslation("ClearCoat", "クリアコート"),
            new WFI18NTranslation("Gradient Map", "グラデーションマップ"),
            new WFI18NTranslation("Color Change", "色変更"),
            new WFI18NTranslation("Detail NormalMap", "ディテールノーマルマップ"),
            new WFI18NTranslation("Distance Fade", "距離フェード"),
            new WFI18NTranslation("Dissolve", "ディゾルブ"),
            new WFI18NTranslation("Emission", "エミッション"),
            new WFI18NTranslation("Fake Fur", "ファー"),
            new WFI18NTranslation("Fog", "フォグ"),
            new WFI18NTranslation("FrostedGlass", "すりガラス"),
            new WFI18NTranslation("Gem Background", "ジェム(裏面)"),
            new WFI18NTranslation("Gem Flake", "ジェム(フレーク)"),
            new WFI18NTranslation("Gem Reflection", "ジェム(反射)"),
            new WFI18NTranslation("Gem Surface", "ジェム(表面)"),
            new WFI18NTranslation("Ghost Transparent", "ゴースト透過"),
            new WFI18NTranslation("Grass Wave", "草の揺れ"),
            new WFI18NTranslation("Grass", "草"),
            new WFI18NTranslation("Lame", "ラメ"),
            new WFI18NTranslation("Light Bake Effects", "ライトベイク調整"),
            new WFI18NTranslation("Light Matcap 2", "マットキャップ2"),
            new WFI18NTranslation("Light Matcap 3", "マットキャップ3"),
            new WFI18NTranslation("Light Matcap 4", "マットキャップ4"),
            new WFI18NTranslation("Light Matcap 5", "マットキャップ5"),
            new WFI18NTranslation("Light Matcap 6", "マットキャップ6"),
            new WFI18NTranslation("Light Matcap 7", "マットキャップ7"),
            new WFI18NTranslation("Light Matcap 8", "マットキャップ8"),
            new WFI18NTranslation("Light Matcap", "マットキャップ"),
            new WFI18NTranslation("Lit Advance", "ライト設定(拡張)"),
            new WFI18NTranslation("Lit", "ライト設定"),
            new WFI18NTranslation("Material Options", "マテリアル設定"),
            new WFI18NTranslation("Metallic", "メタリック"),
            new WFI18NTranslation("Mirror Control", "ミラー制御"),
            new WFI18NTranslation("NormalMap", "ノーマルマップ"),
            new WFI18NTranslation("Outline", "アウトライン"),
            new WFI18NTranslation("Overlay Texture", "オーバーレイテクスチャ"),
            new WFI18NTranslation("Reflection", "反射(リフレクション)"),
            new WFI18NTranslation("Refraction", "屈折"),
            new WFI18NTranslation("RimLight", "リムライト"),
            new WFI18NTranslation("Specular", "光沢(スペキュラ)"),
            new WFI18NTranslation("Stencil Mask", "ステンシル"),
            new WFI18NTranslation("Tessellation", "細分化"),
            new WFI18NTranslation("ToonShade", "トゥーン影"),
            new WFI18NTranslation("Transparent Alpha", "透過"),
            new WFI18NTranslation("Utility", "ユーティリティ"),
            new WFI18NTranslation("Water", "水"),
            new WFI18NTranslation("Waving 1", "波面の生成1"),
            new WFI18NTranslation("Waving 2", "波面の生成2"),
            new WFI18NTranslation("Waving 3", "波面の生成3"),
            new WFI18NTranslation("Particle System", "パーティクル"),
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
            new WFI18NTranslation("Blend Normal 2nd", "ノーマルマップ(2nd)強度"),
            new WFI18NTranslation("Shape", "形状"),
            new WFI18NTranslation("Scale", "スケール"),
            new WFI18NTranslation("Direction", "方向"),
            new WFI18NTranslation("Distance", "距離"),
            new WFI18NTranslation("Speed", "スピード"),
            new WFI18NTranslation("Power", "強度"),
            new WFI18NTranslation("Roughen", "粗くする"),
            new WFI18NTranslation("Finer", "細かくする"),
            new WFI18NTranslation("Tint Color", "色調整"),
            new WFI18NTranslation("Fade Distance", "フェード距離"),
            new WFI18NTranslation("Fade Distance (Near)", "フェード距離 (Near)"),
            new WFI18NTranslation("Fade Distance (Far)", "フェード距離 (Far)"),
            new WFI18NTranslation("FadeOut Distance", "フェードアウト距離"),
            new WFI18NTranslation("FadeOut Distance (Near)", "フェードアウト距離 (Near)"),
            new WFI18NTranslation("FadeOut Distance (Far)", "フェードアウト距離 (Far)"),
            new WFI18NTranslation("Shadow Power", "影の濃さ"),
            new WFI18NTranslation("Preview", "プレビュー"),
            new WFI18NTranslation("Save", "保存"),
            new WFI18NTranslation("Gamma", "ガンマ"),
            new WFI18NTranslation("Create GradationMap Texture", "グラデーションマップ用テクスチャを作成"),
            // Lit
            new WFI18NTranslation("Unlit Intensity", "Unlit Intensity (最小明度)"),
            new WFI18NTranslation("Saturate Intensity", "Saturate Intensity (飽和明度)"),
            new WFI18NTranslation("Chroma Reaction", "Chroma Reaction (彩度)"),
            new WFI18NTranslation("Cast Shadows", "他の物体に影を落とす"),
            new WFI18NTranslation("Shadow Cutoff Threshold", "影のカットアウトしきい値"),
            // Alpha
            new WFI18NTranslation("AL", "Alpha Source", "アルファソース"),
            new WFI18NTranslation("AL", "Alpha Mask Texture", "アルファマスク"),
            new WFI18NTranslation("AL", "Power", "アルファ強度"),
            new WFI18NTranslation("AL", "Fresnel Power", "フレネル強度"),
            new WFI18NTranslation("AL", "Cutoff Threshold", "カットアウトしきい値"),
            // BackFace Texture
            new WFI18NTranslation("BKT", "Back Texture", "裏面テクスチャ"),
            new WFI18NTranslation("BKT", "Back Color", "裏面色"),
            // Color Change
            new WFI18NTranslation("CLC", "monochrome", "単色化"),
            new WFI18NTranslation("CLC", "Hur", "色相"),
            new WFI18NTranslation("CLC", "Saturation", "彩度"),
            new WFI18NTranslation("CLC", "Brightness", "明度"),
            // Normal
            new WFI18NTranslation("NM", "NormalMap Texture", "ノーマルマップ").AddTag("FUR"),
            new WFI18NTranslation("NM", "Bump Scale", "凹凸スケール"),
            new WFI18NTranslation("NM", "Flip Mirror", "ミラーXY反転").AddTag("NS", "FUR"),
            new WFI18NTranslation("NM", "Use DirectX NormalMap", "DirectXのノーマルマップを使用"),
            // Normal 2nd
            new WFI18NTranslation("NS", "2nd Normal Blend", "2ndマップの混合タイプ"),
            new WFI18NTranslation("NS", "2nd Normal UV Type", "2ndマップのUVタイプ"),
            new WFI18NTranslation("NS", "2nd NormalMap Texture", "2ndノーマルマップ"),
            new WFI18NTranslation("NS", "2nd Bump Scale", "凹凸スケール"),
            new WFI18NTranslation("NS", "2nd NormalMap Mask Texture", "2ndノーマルのマスク"),
            new WFI18NTranslation("NS", "2nd NormalMap Mask Texture (R)", "2ndノーマルのマスク (R)"),
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
            new WFI18NTranslation("HL", "Change Alpha Transparency", "透明度も反映する").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Monochrome", "matcapモノクロ化").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            // Lame
            new WFI18NTranslation("LME", "Color", "ラメ色・テクスチャ"),
            new WFI18NTranslation("LME", "Texture", "ラメ色・テクスチャ"),
            new WFI18NTranslation("LME", "Random Color", "ランダム色パラメタ"),
            new WFI18NTranslation("LME", "Change Alpha Transparency", "透明度も反映する"),
            new WFI18NTranslation("LME", "Dencity", "密度"),
            new WFI18NTranslation("LME", "Glitter", "きらきら"),
            new WFI18NTranslation("LME", "FadeOut Angle", "フェードアウト角度"),
            new WFI18NTranslation("LME", "Anim Speed", "アニメ速度"),
            // ToonShade
            new WFI18NTranslation("TS", "Steps", "繰り返し数"),
            new WFI18NTranslation("TS", "Base Color", "ベース色"),
            new WFI18NTranslation("TS", "Base Shade Texture", "ベース色テクスチャ"),
            new WFI18NTranslation("TS", "1st Shade Color", "1影色"),
            new WFI18NTranslation("TS", "1st Shade Texture", "1影色テクスチャ"),
            new WFI18NTranslation("TS", "2nd Shade Color", "2影色"),
            new WFI18NTranslation("TS", "2nd Shade Texture", "2影色テクスチャ"),
            new WFI18NTranslation("TS", "3rd Shade Color", "3影色"),
            new WFI18NTranslation("TS", "3rd Shade Texture", "3影色テクスチャ"),
            new WFI18NTranslation("TS", "Shade Power", "影の強度"),
            new WFI18NTranslation("TS", "1st Border", "1影の境界位置"),
            new WFI18NTranslation("TS", "2nd Border", "2影の境界位置"),
            new WFI18NTranslation("TS", "3rd Border", "3影の境界位置"),
            new WFI18NTranslation("TS", "1st Feather", "1影の境界ぼかし強度"),
            new WFI18NTranslation("TS", "2nd Feather", "2影の境界ぼかし強度"),
            new WFI18NTranslation("TS", "3rd Feather", "3影の境界ぼかし強度"),
            new WFI18NTranslation("TS", "Anti-Shadow Mask Texture", "アンチシャドウマスク"),
            new WFI18NTranslation("TS", "Anti-Shadow Mask Texture (R)", "アンチシャドウマスク (R)"),
            new WFI18NTranslation("TS", "Shade Color Suggest", "影色を自動設定する"),
            new WFI18NTranslation("TS", "Align the boundaries equally", "境界を等間隔に整列"),
            new WFI18NTranslation("TS", "Dont Ajust Contrast", "影コントラストを調整しない"),
            // RimLight
            new WFI18NTranslation("TR", "Rim Color", "リムライト色"),
            new WFI18NTranslation("TR", "Width", "幅"),
            new WFI18NTranslation("TR", "Width Top", "幅(上)"),
            new WFI18NTranslation("TR", "Width Side", "幅(横)"),
            new WFI18NTranslation("TR", "Width Bottom", "幅(下)"),
            new WFI18NTranslation("TR", "Feather", "ぼかし幅"),
            new WFI18NTranslation("TR", "Exponent", "ぼかし指数"),
            new WFI18NTranslation("TR", "Assign MainTex to MaskTexture", "MainTexをマスクに設定する"),
            // Overlay Texture
            new WFI18NTranslation("OVL", "Overlay Color", "オーバーレイ テクスチャ"),
            new WFI18NTranslation("OVL", "Overlay Texture", "オーバーレイ テクスチャ"),
            new WFI18NTranslation("OVL", "Multiply VertexColor To Overlay Texture", "頂点カラーをオーバーレイテクスチャに乗算する"),
            new WFI18NTranslation("OVL", "Multiply VertexColor To Mask Texture", "頂点カラーをマスクに乗算する"),
            new WFI18NTranslation("OVL", "UV Scroll", "UVスクロール"),
            new WFI18NTranslation("OVL", "Out of UV Mode", "UV外の扱い"),
            // EmissiveScroll
            new WFI18NTranslation("ES", "Emission", "Emission テクスチャ"),
            new WFI18NTranslation("ES", "Emission Texture", "Emission テクスチャ"),
            new WFI18NTranslation("ES", "Enable EmissiveScroll", "スクロールを使用する"),
            new WFI18NTranslation("ES", "Wave Type", "波形"),
            new WFI18NTranslation("ES", "Change Alpha Transparency", "透明度も反映する"),
            new WFI18NTranslation("ES", "Direction Type", "方向の種類"),
            new WFI18NTranslation("ES", "LevelOffset", "ゼロ点調整"),
            new WFI18NTranslation("ES", "Sharpness", "鋭さ"),
            new WFI18NTranslation("ES", "ScrollSpeed", "スピード"),
            new WFI18NTranslation("ES", "Enable AudioLink", "AudioLink を使用する"),
            new WFI18NTranslation("ES", "Emission Multiplier", "エミッション倍率"),
            new WFI18NTranslation("ES", "Emission Multiplier (Min)", "エミッション倍率 (Min)"),
            new WFI18NTranslation("ES", "Emission Multiplier (Max)", "エミッション倍率 (Max)"),
            new WFI18NTranslation("ES", "Band", "バンド"),
            new WFI18NTranslation("ES", "Slope", "傾き"),
            new WFI18NTranslation("ES", "Threshold", "しきい値"),
            new WFI18NTranslation("ES", "Threshold (Min)", "しきい値 (Min)"),
            new WFI18NTranslation("ES", "Threshold (Max)", "しきい値 (Max)"),
            new WFI18NTranslation("ES", "Dont Emit when AudioLink is disabled", "AudioLink無効時は光らせない"),
            // Outline
            new WFI18NTranslation("TL", "Line Color", "線の色"),
            new WFI18NTranslation("TL", "Line Width", "線の太さ"),
            new WFI18NTranslation("TL", "Line Type", "線の種類"),
            new WFI18NTranslation("TL", "Custom Color Texture", "線色テクスチャ"),
            new WFI18NTranslation("TL", "Blend Custom Color Texture", "線色テクスチャとブレンド"),
            new WFI18NTranslation("TL", "Blend Base Color", "ベース色とブレンド"),
            new WFI18NTranslation("TL", "Z-shift (tweak)", "カメラから遠ざける"),
            // Ambient Occlusion
            new WFI18NTranslation("AO", "Occlusion Map", "オクルージョンマップ"),
            new WFI18NTranslation("AO", "Occlusion Map (RGB)", "オクルージョンマップ (RGB)"),
            new WFI18NTranslation("AO", "Use LightMap", "ライトマップも使用する"),
            new WFI18NTranslation("AO", "Contrast", "コントラスト"),
            // Distance Fade
            new WFI18NTranslation("DFD", "Color", "色"),
            new WFI18NTranslation("DFD", "Color Texture", "色テクスチャ"),
            new WFI18NTranslation("DFD", "Fade Distance", "フェード距離"),
            new WFI18NTranslation("DFD", "Fade Distance (Near)", "フェード距離 (Near)"),
            new WFI18NTranslation("DFD", "Fade Distance (Far)", "フェード距離 (Far)"),
            new WFI18NTranslation("DFD", "Power", "強度"),
            new WFI18NTranslation("DFD", "BackFace Shadow", "裏面は影にする"),
            // Dissolve
            new WFI18NTranslation("DSV", "Dissolve", "ディゾルブ"),
            new WFI18NTranslation("DSV", "Invert", "反転"),
            new WFI18NTranslation("DSV", "Control Texture (R)", "制御テクスチャ (R)"),
            new WFI18NTranslation("DSV", "Spark Color", "スパーク色"),
            new WFI18NTranslation("DSV", "Spark Width", "スパーク幅"),
            // Toon Fog
            new WFI18NTranslation("TFG", "Color", "フォグの色"),
            new WFI18NTranslation("TFG", "Exponential", "変化の鋭さ"),
            new WFI18NTranslation("TFG", "Base Offset", "フォグ原点の位置(オフセット)"),
            new WFI18NTranslation("TFG", "Scale", "フォグ範囲のスケール"),
            // Tessellation
            new WFI18NTranslation("TE", "Tess Factor", "分割数"),
            new WFI18NTranslation("TE", "Smoothing", "スムーズ"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture", "スムーズマスク"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture (R)", "スムーズマスク (R)"),
            // Lit Advance
            new WFI18NTranslation("Sun Source", "太陽光のモード"),
            new WFI18NTranslation("Custom Sun Azimuth", "カスタム太陽の方角"),
            new WFI18NTranslation("Custom Sun Altitude", "カスタム太陽の高度"),
            new WFI18NTranslation("Custom Light Pos", "カスタムライトの位置"),
            new WFI18NTranslation("Disable BackLit", "逆光補正しない"),
            new WFI18NTranslation("Disable ObjectBasePos", "メッシュ原点を取得しない"),
            new WFI18NTranslation("Cancel Near Clipping", "カメラのニアクリップを無視"),
            // Light Bake Effects
            new WFI18NTranslation("LBE", "Indirect Multiplier", "間接光の倍率"),
            new WFI18NTranslation("LBE", "Emission Multiplier", "Emissionの倍率"),
            new WFI18NTranslation("LBE", "Indirect Chroma", "間接光の彩度"),
            // Gem Background
            new WFI18NTranslation("GMB", "Background Color", "背景色 (裏面色)"),
            // Gem Reflection
            new WFI18NTranslation("GMR", "CubeMap", "キューブマップ"),
            new WFI18NTranslation("GMR", "Monochrome Reflection", "モノクロ反射"),
            new WFI18NTranslation("GMR", "2nd CubeMap Power", "キューブマップ強度"),
            // Gem Flake
            new WFI18NTranslation("GMF", "Flake Size (front)", "大きさ (表面)"),
            new WFI18NTranslation("GMF", "Flake Size (back)", "大きさ (裏面)"),
            new WFI18NTranslation("GMF", "Shear", "シア"),
            new WFI18NTranslation("GMF", "Brighten", "明るさ"),
            new WFI18NTranslation("GMF", "Darken", "暗さ"),
            new WFI18NTranslation("GMF", "Twinkle", "またたき"),
            // Fake Fur
            new WFI18NTranslation("FUR", "Fur Noise Texture", "ノイズテクスチャ"),
            new WFI18NTranslation("FUR", "Fur Height", "高さ"),
            new WFI18NTranslation("FUR", "Fur Height (Cutout)", "高さ (Cutout側)"),
            new WFI18NTranslation("FUR", "Fur Height (Transparent)", "高さ (Transparent側)"),
            new WFI18NTranslation("FUR", "Fur Vector", "方向"),
            new WFI18NTranslation("FUR", "Fur Vector Randomize", "方向のランダム化"),
            new WFI18NTranslation("FUR", "Fur Repeat", "ファーの枚数"),
            new WFI18NTranslation("FUR", "Fur Repeat (Cutout)", "ファーの枚数 (Cutout側)"),
            new WFI18NTranslation("FUR", "Fur Repeat (Transparent)", "ファーの枚数 (Transparent側)"),
            new WFI18NTranslation("FUR", "Fur ShadowPower", "影の強さ"),
            new WFI18NTranslation("FUR", "Tint Color (Base)", "色調整 (根元)"),
            new WFI18NTranslation("FUR", "Tint Color (Tip)", "色調整 (先端)"),
            // Refraction
            new WFI18NTranslation("CRF", "Refractive Index", "屈折率"),
            // Frosted Glass
            new WFI18NTranslation("CGL", "Blur", "ブラー"),
            new WFI18NTranslation("CGL", "Blur Min", "ブラー(下限)"),
            new WFI18NTranslation("CGL", "Blur Mode", "ブラーモード"),
            // Grass
            new WFI18NTranslation("GRS", "Height Type", "高さ指定タイプ"),
            new WFI18NTranslation("GRS", "Ground Y coordinate", "地面Y座標"),
            new WFI18NTranslation("GRS", "Height scale", "高さスケール"),
            new WFI18NTranslation("GRS", "Height UV Type", "高さ指定UVタイプ"),
            new WFI18NTranslation("GRS", "Height Mask Tex", "高さ指定マスクテクスチャ"),
            new WFI18NTranslation("GRS", "UV Factor", "UV係数"),
            new WFI18NTranslation("GRS", "Color Factor", "カラー係数"),
            new WFI18NTranslation("GRS", "Tint Color Top", "色調整(先端)"),
            new WFI18NTranslation("GRS", "Tint Color Bottom", "色調整(根元)"),
            new WFI18NTranslation("GRS", "Erase Side", "側面を非表示"),
            // GrassWave
            new WFI18NTranslation("GRW", "Wave Speed", "波スピード"),
            new WFI18NTranslation("GRW", "Wave Amplitude", "波の振幅"),
            new WFI18NTranslation("GRW", "Wave Exponent", "指数"),
            new WFI18NTranslation("GRW", "Wave Offset", "オフセット"),
            new WFI18NTranslation("GRW", "Wind Vector", "風ベクトル"),
            // Water
            new WFI18NTranslation("Water Color", "水面の色"),
            new WFI18NTranslation("Water Color 2", "水面の色 2"),
            new WFI18NTranslation("Caustics Color", "コースティクスの色"),
            new WFI18NTranslation("Fog Color", "フォグの色"),
            new WFI18NTranslation("WA", "Water Level (World Y Coord)", "水面高 (ワールドY座標)"),
            new WFI18NTranslation("WA", "Hide Caustics above water", "水上ではコースティクスを非表示"),
            new WFI18NTranslation("WA", "Water Transparency", "水の透明度"),
            new WFI18NTranslation("WA1", "Wave NormalMap", "波面ノーマルマップ").AddTag("WA2", "WA3"),
            new WFI18NTranslation("WA1", "Wave Normal Scale", "凹凸スケール").AddTag("WA2", "WA3"),
            new WFI18NTranslation("WA1", "Wave HeightMap", "波面ハイトマップ").AddTag("WA2", "WA3"),
            new WFI18NTranslation("WA1", "Caustics Tex", "コースティクステクスチャ").AddTag("WA2", "WA3"),
            new WFI18NTranslation("WAM", "Smoothness", "滑らかさ"),
            new WFI18NTranslation("WAM", "2nd CubeMap Blend", "キューブマップ混合タイプ"),
            new WFI18NTranslation("WAM", "Cube Map", "キューブマップ"),
            new WFI18NTranslation("WAS", "Specular Power", "スペキュラ強度"),
            new WFI18NTranslation("WAS", "Specular Color", "スペキュラ色"),
            new WFI18NTranslation("WAS", "Specular Smoothness", "滑らかさ"),
            new WFI18NTranslation("WAS", "Specular 2 Power", "スペキュラ強度 2"),
            new WFI18NTranslation("WAS", "Specular 2 Color", "スペキュラ色 2"),
            new WFI18NTranslation("WAS", "Specular 2 Smoothness", "滑らかさ 2"),
            new WFI18NTranslation("WAR", "Sun Azimuth", "太陽の方角"),
            new WFI18NTranslation("WAR", "Sun Altitude", "太陽の高度"),
            new WFI18NTranslation("WAR", "Size", "サイズ"),
            new WFI18NTranslation("WAR", "Base Pos", "位置"),
            new WFI18NTranslation("WAR", "Hide Back", "後側を非表示"),
            // Particle
            new WFI18NTranslation("PA", "Vertex Color Blend Mode", "頂点カラーの混合モード"),

            // メニュー
            new WFI18NTranslation("Copy material", "コピー"),
            new WFI18NTranslation("Paste value", "貼り付け"),
            new WFI18NTranslation("Paste (without Textures)", "貼り付け (Texture除く)"),
            new WFI18NTranslation("Reset", "リセット"),

            // 列挙体
            new WFI18NTranslation("UnlitWF.BlendModeOVL.ALPHA", "アルファ合成"),
            new WFI18NTranslation("UnlitWF.BlendModeOVL.ADD", "加算"),
            new WFI18NTranslation("UnlitWF.BlendModeOVL.MUL", "乗算"),
            new WFI18NTranslation("UnlitWF.BlendModeOVL.ADD_AND_SUB", "加算・減算"),
            new WFI18NTranslation("UnlitWF.BlendModeOVL.SCREEN", "スクリーン"),
            new WFI18NTranslation("UnlitWF.BlendModeOVL.OVERLAY", "オーバーレイ"),
            new WFI18NTranslation("UnlitWF.BlendModeOVL.HARD_LIGHT", "ハードライト"),
            new WFI18NTranslation("UnlitWF.BlendModeHL.ADD_AND_SUB", "加算・減算"),
            new WFI18NTranslation("UnlitWF.BlendModeHL.ADD", "加算"),
            new WFI18NTranslation("UnlitWF.BlendModeHL.MUL", "乗算"),
            new WFI18NTranslation("UnlitWF.BlendModeES.ADD", "加算"),
            new WFI18NTranslation("UnlitWF.BlendModeES.ALPHA", "アルファ合成"),
            new WFI18NTranslation("UnlitWF.BlendModeES.LEGACY_ALPHA", "アルファ合成(旧タイプ)"),
            new WFI18NTranslation("UnlitWF.BlendModeTR.ADD", "加算"),
            new WFI18NTranslation("UnlitWF.BlendModeTR.ALPHA", "アルファ合成"),
            new WFI18NTranslation("UnlitWF.BlendModeTR.ADD_AND_SUB", "加算・減算"),
            new WFI18NTranslation("UnlitWF.BlendModeTR.MUL", "乗算"),
            new WFI18NTranslation("UnlitWF.BlendModeVC.MUL", "乗算"),
            new WFI18NTranslation("UnlitWF.BlendModeVC.ADD", "加算"),
            new WFI18NTranslation("UnlitWF.BlendModeVC.SUB", "減算"),
            new WFI18NTranslation("UnlitWF.SunSourceMode.AUTO", "自動"),
            new WFI18NTranslation("UnlitWF.SunSourceMode.ONLY_DIRECTIONAL_LIT", "DirectionalLightのみ"),
            new WFI18NTranslation("UnlitWF.SunSourceMode.ONLY_POINT_LIT", "PointLightのみ"),
            new WFI18NTranslation("UnlitWF.SunSourceMode.CUSTOM_WORLD_DIR", "カスタム(ワールド方向)"),
            new WFI18NTranslation("UnlitWF.SunSourceMode.CUSTOM_LOCAL_DIR", "カスタム(ローカル方向)"),
            new WFI18NTranslation("UnlitWF.SunSourceMode.CUSTOM_WORLD_POS", "カスタム(ワールド座標)"),

            // WFEditorSetting
            new WFI18NTranslation("WFEditorSetting", "This is the current setting used.", "これは現在有効な設定です。"),
            new WFI18NTranslation("WFEditorSetting", "This is not the setting used now.", "これは現在有効の設定ではなく、他に有効な設定があります。"),
            new WFI18NTranslation("WFEditorSetting", "Enable Stripping", "不要コードを除去する"),
            new WFI18NTranslation("WFEditorSetting", "Strip Unused Variant", "未使用のバリアントを除去する"),
            new WFI18NTranslation("WFEditorSetting", "Strip Unused Lod Fade", "未使用のLODクロスフェードを除去"),
            new WFI18NTranslation("WFEditorSetting", "Strip Fallback", "Fallbackを除去"),
            new WFI18NTranslation("WFEditorSetting", "Strip Meta Pass", "Metaパスを除去"),
            new WFI18NTranslation("WFEditorSetting", "Validate Scene Materials", "ビルド時に古いマテリアルが含まれていないか検査する"),
            new WFI18NTranslation("WFEditorSetting", "Cleanup Materials Before Avatar Build", "アバタービルド前にマテリアルをクリンナップする"),
            new WFI18NTranslation("WFEditorSetting", "Enable Scan Projects", "Shaderインポート時にプロジェクトをスキャン"),
            new WFI18NTranslation("WFEditorSetting", "Enable Migration When Import", "マテリアルインポート時にマテリアルを最新化"),
            new WFI18NTranslation("WFEditorSetting", "Auto Switch Quest Shader", "Quest向けシェーダに自動で切り替える"),
            new WFI18NTranslation("WFEditorSetting", "Create New Settings asset", "設定アセットファイルを新規作成"),

            // その他のテキスト
            new WFI18NTranslation(WFMessageText.NewerVersion, "新しいバージョンがリリースされています。\n最新版: "),
            new WFI18NTranslation(WFMessageText.PlzMigration, "このマテリアルは古いバージョンで作成されたようです。\n最新版に変換しますか？"),
            new WFI18NTranslation(WFMessageText.PlzBatchingStatic, "このマテリアルは Batching Static な MeshRenderer から使われているようです。\nBatching Static 用の設定へ変更しますか？"),
            new WFI18NTranslation(WFMessageText.PlzLightmapStatic, "このマテリアルは Lightmap Static な MeshRenderer から使われているようです。\nライトマップを有効にしますか？"),
            new WFI18NTranslation(WFMessageText.PlzFixQueue, "半透明マテリアルのQueueが2500以下です。\nRenderQueueを修正しますか？"),
            new WFI18NTranslation(WFMessageText.PlzFixQueueWithClearBg, "半透明マテリアルのQueueが2500以下です。\n背景消去パスが有効化されます。"),
            new WFI18NTranslation(WFMessageText.PlzFixDoubleSidedGI, "マテリアルの DoubleSidedGI がチェックされていません。\nこのマテリアルは片面としてライトベイクされます。\nDoubleSidedGI を修正しますか？"),
            new WFI18NTranslation(WFMessageText.PlzFixParticleVertexStreams, "ParticleSystem の VertexStreams が不一致です。\nParticleSystem の設定値を修正しますか？"),
            new WFI18NTranslation(WFMessageText.PlzQuestSupport, "このマテリアルは Quest 非対応シェーダを使用しています。"),
            new WFI18NTranslation(WFMessageText.PlzDeprecatedFeature, "今後削除される予定の機能がマテリアルから使用されています。"),

            new WFI18NTranslation(WFMessageText.PsAntiShadowMask, "アンチシャドウマスクにはアバターの顔を白く塗ったマスクテクスチャを指定してください。マスク反転をチェックすることでマテリアル全体を顔とみなすこともできます。"),
            new WFI18NTranslation(WFMessageText.PsCapTypeMedian, "MEDIAN_CAPは灰色を基準とした加算＆減算合成を行うmatcapです"),
            new WFI18NTranslation(WFMessageText.PsCapTypeLight, "LIGHT_CAPは黒色を基準とした加算合成を行うmatcapです"),
            new WFI18NTranslation(WFMessageText.PsCapTypeShade, "SHADE_CAPは白色を基準とした乗算合成を行うmatcapです"),
            new WFI18NTranslation(WFMessageText.PsPreviewTexture, "プレビューテクスチャが設定されています。\nプレビューテクスチャは保存されません。"),

            new WFI18NTranslation(WFMessageText.DgChangeMobile, "シェーダをMobile向けに切り替えますか？\n\nこの操作はUndoできますが、バックアップを取ることをお勧めします。"),
            new WFI18NTranslation(WFMessageText.DgMigrationAuto, "UnlitWFシェーダがインポートされました。\nプロジェクト内に古いマテリアルが残っていないかスキャンしますか？"),
            new WFI18NTranslation(WFMessageText.DgMigrationManual, "プロジェクト内のマテリアルをスキャンして、最新のマテリアル値へと更新しますか？"),
            new WFI18NTranslation(WFMessageText.DgDontImportUnityPackage, "パッケージは UPM(VPM) で管理されています。\nunitypackage からインポートするかわりに VCC 等の管理ツールを使用してください。"),

            new WFI18NTranslation(WFMessageText.LgWarnOlderVersion, "古いバージョンで作成されたマテリアルがあります。"),
            new WFI18NTranslation(WFMessageText.LgWarnNotSupportAndroid, "Android非対応のシェーダが使われているマテリアルがあります。"),

            new WFI18NTranslation(WFMessageButton.Cleanup, "マテリアルから不要データを削除"),
            new WFI18NTranslation(WFMessageButton.ApplyTemplate, "テンプレートから適用"),
            new WFI18NTranslation(WFMessageButton.SaveTemplate, "テンプレートとして保存"),
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
            new WFI18NTranslation("Blend Normal (2nd)", "노멀맵 (2nd) 강도"),
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
            new WFI18NTranslation("BKT", "Back Texture", "뒷면 텍스처"),
            new WFI18NTranslation("BKT", "Back Color", "뒷면 색상"),
            // Color Change
            new WFI18NTranslation("CLC", "monochrome", "단색화"),
            new WFI18NTranslation("CLC", "Hur", "색상"),
            new WFI18NTranslation("CLC", "Saturation", "채도"),
            new WFI18NTranslation("CLC", "Brightness", "명도"),
            // Normal
            new WFI18NTranslation("NM", "NormalMap Texture", "노멀맵").AddTag("FUR"),
            new WFI18NTranslation("NM", "Bump Scale", "범프 스케일"),
            new WFI18NTranslation("NM", "Shadow Power", "그림자 강도"),
            new WFI18NTranslation("NM", "Flip Mirror", "거울 XY 반전").AddTag("NS", "FUR"),
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
            new WFI18NTranslation("HL", "Change Alpha Transparency", "알파값 반영").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            new WFI18NTranslation("HL", "Matcap Monochrome", "matcap 단색화").AddTag("HA", "HB", "HC", "HD", "HE", "HF", "HG"),
            // Lame
            new WFI18NTranslation("LME", "Color", "LM색상・텍스처"),
            new WFI18NTranslation("LME", "Texture", "LM색상・텍스처"),
            new WFI18NTranslation("LME", "Random Color", "랜덤 색상"),
            new WFI18NTranslation("LME", "Change Alpha Transparency", "알파값 반영"),
            new WFI18NTranslation("LME", "Dencity", "밀도"),
            new WFI18NTranslation("LME", "Glitter", "반짝거림"),
            new WFI18NTranslation("LME", "FadeOut Angle", "페이드 아웃 앵글"),
            new WFI18NTranslation("LME", "Anim Speed", "애니메이션 속도"),
            // ToonShade
            new WFI18NTranslation("TS", "Steps", "반복값"),
            new WFI18NTranslation("TS", "Base Color", "베이스 색상"),
            new WFI18NTranslation("TS", "Base Shade Texture", "베이스 텍스처"),
            new WFI18NTranslation("TS", "1st Shade Color", "1st 그림자 색상"),
            new WFI18NTranslation("TS", "1st Shade Texture", "1st 그림자 텍스처"),
            new WFI18NTranslation("TS", "2nd Shade Color", "2nd 그림자 색상"),
            new WFI18NTranslation("TS", "2nd Shade Texture", "2nd 그림자 텍스처"),
            new WFI18NTranslation("TS", "3rd Shade Color", "3rd 그림자 색상"),
            new WFI18NTranslation("TS", "3rd Shade Texture", "3rd 그림자 텍스처"),
            new WFI18NTranslation("TS", "Shade Power", "그림자 강도"),
            new WFI18NTranslation("TS", "1st Border", "1st 그림자 경계값"),
            new WFI18NTranslation("TS", "2nd Border", "2nd 그림자 경계값"),
            new WFI18NTranslation("TS", "3rd Border", "3rd 그림자 경계값"),
            new WFI18NTranslation("TS", "Feather", "그림자 경계의 흐림값"),
            new WFI18NTranslation("TS", "Anti-Shadow Mask Texture", "안티 그림자 마스크"),
            new WFI18NTranslation("TS", "Anti-Shadow Mask Texture (R)", "안티 그림자 마스크 (R)"),
            new WFI18NTranslation("TS", "Shade Color Suggest", "그림자 자동 설정"),
            new WFI18NTranslation("TS", "Align the boundaries equally", "경계값 동일 정렬 "),
            new WFI18NTranslation("TS", "Dont Ajust Contrast", "그림자 콘트라스트를 조정하지 않는다"),
            // RimLight
            new WFI18NTranslation("TR", "Rim Color", "림라이트 색상"),
            new WFI18NTranslation("TR", "Power", "강도(최대)"),
            new WFI18NTranslation("TR", "Feather", "흐림값"),
            new WFI18NTranslation("TR", "Power Top", "강도(위)"),
            new WFI18NTranslation("TR", "Power Side", "강도(좌우)"),
            new WFI18NTranslation("TR", "Power Bottom", "강도(아래)"),
            // Overlay Texture
            new WFI18NTranslation("OVL", "Overlay Color", "한국어 텍스처"),
            new WFI18NTranslation("OVL", "Overlay Texture", "한국어 텍스처"),
            new WFI18NTranslation("OVL", "Multiply VertexColor To Overlay Texture", "버텍스 컬러에 한국어 텍스처 곱하기"),
            new WFI18NTranslation("OVL", "Multiply VertexColor To Mask Texture", "버텍스 컬러에 마스크 텍스처 곱하기"),
            new WFI18NTranslation("OVL", "UV Scroll", "UV스크롤"),
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
            new WFI18NTranslation("TL", "Line Color", "선 색상"),
            new WFI18NTranslation("TL", "Line Width", "선 굵기"),
            new WFI18NTranslation("TL", "Line Type", "선 타입"),
            new WFI18NTranslation("TL", "Custom Color Texture", "선 색상 텍스처"),
            new WFI18NTranslation("TL", "Blend Custom Color Texture", "선 색상 텍스처와 블랜드"),
            new WFI18NTranslation("TL", "Blend Base Color", "블렌드 베이스 색상"),
            new WFI18NTranslation("TL", "Z-shift (tweak)", "카메라로 부터 멀리함"),
            // Ambient Occlusion
            new WFI18NTranslation("AO", "Occlusion Map", "오클루전 맵"),
            new WFI18NTranslation("AO", "Occlusion Map (RGB)", "오클루전 맵 (RGB)"),
            new WFI18NTranslation("AO", "Use LightMap", "라이트 맵 사용"),
            new WFI18NTranslation("AO", "Contrast", "콘트라스트"),
            // Distance Fade
            new WFI18NTranslation("DFD", "Color", "색상"),
            new WFI18NTranslation("DFD", "Fade Distance (Near)", "페이드 거리(가까워짐)"),
            new WFI18NTranslation("DFD", "Fade Distance (Far)", "페이드 거리(멀어짐)"),
            new WFI18NTranslation("DFD", "Power", "강도"),
            new WFI18NTranslation("DFD", "BackFace Shadow", "이면은 그림자"),
            // Toon Fog
            new WFI18NTranslation("TFG", "Color", "Fog색상"),
            new WFI18NTranslation("TFG", "Exponential", "Fog변화값"),
            new WFI18NTranslation("TFG", "Base Offset", "Fog의 원점(오프셋)"),
            new WFI18NTranslation("TFG", "Scale", "Fog 스케일"),
            // Tessellation
            new WFI18NTranslation("TE", "Tess Factor", "분할값"),
            new WFI18NTranslation("TE", "Smoothing", "Smooth"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture", "Smooth 마스크 텍스처"),
            new WFI18NTranslation("TE", "Smoothing Mask Texture (R)", "Smooth 마스크 텍스처 (R)"),
            // Lit Advance
            new WFI18NTranslation("Sun Source", "태양광 모드"),
            new WFI18NTranslation("Custom Sun Azimuth", "커스텀 태양광 방향"),
            new WFI18NTranslation("Custom Sun Altitude", "커스텀 태양광 고도"),
            new WFI18NTranslation("Custom Light Pos", "커스텀 라이트의 위치"),
            new WFI18NTranslation("Disable BackLit", "역광 무보정"),
            new WFI18NTranslation("Disable ObjectBasePos", "매쉬의 원점을 취득하지 않음"),
            // Light Bake Effects
            new WFI18NTranslation("LBE", "Indirect Multiplier", "간접광 배율"),
            new WFI18NTranslation("LBE", "Emission Multiplier", "Emission 배율"),
            new WFI18NTranslation("LBE", "Indirect Chroma", "간접광 채도"),
            // Gem Background
            new WFI18NTranslation("GMB", "Background Color", "배경 색상 (뒷면 색상)"),
            // Gem Reflection
            new WFI18NTranslation("GMR", "CubeMap", "큐브맵"),
            new WFI18NTranslation("GMR", "Monochrome Reflection", "흑백 반사"),
            new WFI18NTranslation("GMR", "2nd CubeMap Power", "큐브맵 강도"),
            // Gem Flake
            new WFI18NTranslation("GMF", "Flake Size (front)", "크기 (표면)"),
            new WFI18NTranslation("GMF", "Flake Size (back)", "크기 (뒷면)"),
            new WFI18NTranslation("GMF", "Shear", "시어값"),
            new WFI18NTranslation("GMF", "Brighten", "밝기"),
            new WFI18NTranslation("GMF", "Darken", "어둡기"),
            new WFI18NTranslation("GMF", "Twinkle", "깜빡거림"),
            // Fake Fur
            new WFI18NTranslation("FUR", "Fur Noise Texture", "Fur 노이즈 텍스처"),
            new WFI18NTranslation("FUR", "Fur Height", "Fur 높이"),
            new WFI18NTranslation("FUR", "Fur Height (Cutout)", "Fur 높이 (Cutout)"),
            new WFI18NTranslation("FUR", "Fur Height (Transparent)", "Fur 높이 (Transparent)"),
            new WFI18NTranslation("FUR", "Fur Vector", "Fur 방향"),
            new WFI18NTranslation("FUR", "Fur Vector Randomize", "Fur 방향 랜덤"),
            new WFI18NTranslation("FUR", "Fur Repeat", "Fur 개수"),
            new WFI18NTranslation("FUR", "Fur Repeat (Cutout)", "Fur 개수 (Cutout)"),
            new WFI18NTranslation("FUR", "Fur Repeat (Transparent)", "Fur 개수 (Transparent)"),
            new WFI18NTranslation("FUR", "Fur ShadowPower", "Fur 강도"),
            new WFI18NTranslation("FUR", "Tint Color (Base)", "색조절 (뿌리 부분)"),
            new WFI18NTranslation("FUR", "Tint Color (Tip)", "색조절 (끝 부분)"),
            // Refraction
            new WFI18NTranslation("CRF", "Refractive Index", "한국어"),

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
        };
    }

    static class WFMessageText
    {
        public static readonly string NewerVersion = "A newer version is available now!\nLatest version: ";
        public static readonly string PlzMigration = "This Material may have been created in an older version.\nConvert to new version?";
        public static readonly string PlzBatchingStatic = "This material seems to be used by the Batching Static MeshRenderer.\nDo you want to change the settings for Batching Static?";
        public static readonly string PlzLightmapStatic = "This material seems to be used by the Lightmap Static MeshRenderer.\nDo you want to enable Lightmap?";
        public static readonly string PlzFixQueue = "The Queue for the transparency material is less or equal to 2500, do you want to fix the RenderQueue?";
        public static readonly string PlzFixQueueWithClearBg = "The Queue for the transparency material is less or equal to 2500.\nBackground Clear pass is activated.";
        public static readonly string PlzFixDoubleSidedGI = "The material's DoubleSidedGI is unchecked.\nThis material will be lightbaked as single sided.\nDo you want to fix DoubleSidedGI?";
        public static readonly string PlzFixParticleVertexStreams = "Vertex Streams do not match the ParticleSystem settings.\nDo you want to fix ParticleSystem property?";
        public static readonly string PlzQuestSupport = "This material uses a shader that does not support Quest.";
        public static readonly string PlzDeprecatedFeature = "Features that will be removed in the future are used from this material.";
        public static readonly string PsAntiShadowMask = "In the Anti-Shadow Mask field, specify a mask texture with the avatar face painted white. You can also check the InvertMask checkbox to make the entire material a face.";
        public static readonly string PsCapTypeMedian = "MEDIAN_CAP is a matcap that performs gray-based additive and subtractive blending.";
        public static readonly string PsCapTypeLight = "LIGHT_CAP is a matcap that performs black-based additive blending.";
        public static readonly string PsCapTypeShade = "SHADE_CAP is a matcap that performs white-based multiply blending.";
        public static readonly string PsPreviewTexture = "A preview texture is set that cannot be saved.";
        public static readonly string DgChangeMobile = "Do you want to change those shader for Mobile?\n\nYou can undo this operation, but we recommend that you make a backup.";
        public static readonly string DgMigrationAuto = "UnlitWF shaders have been imported.\nDo you want to scan for old materials still in the project?";
        public static readonly string DgMigrationManual = "Do you want to scan the materials in your project and update them to the latest material values?";
        public static readonly string DgDontImportUnityPackage = "The package is managed by UPM(VPM).\nUse a management tool such as VCC instead of importing from unitypackage.";
        public static readonly string LgWarnOlderVersion = "A material was created with an older shader version.";
        public static readonly string LgWarnNotSupportAndroid = "A material uses a shader that is not supported by Android.";
    }

    static class WFMessageButton
    {
        public static readonly string Cleanup = "Remove unused properties from Materials";
        public static readonly string ApplyTemplate = "Apply from Template";
        public static readonly string SaveTemplate = "Save as Template";
    }
}

#endif
