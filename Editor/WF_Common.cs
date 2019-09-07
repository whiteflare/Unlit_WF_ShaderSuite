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

#if UNITY_EDITOR

using System;
using System.Collections.Generic;
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine;

namespace UnlitWF
{
    internal static class WFCommonUtility
    {
        private static readonly Regex PAT_DISP_NAME = new Regex(@"^\[(?<label>[A-Z][A-Z0-9]*)\]\s+(?<name>.+)$");
        private static readonly Regex PAT_PROP_NAME = new Regex(@"^_(?<prefix>[A-Z][A-Z0-9]*)_(?<name>.+?)(?<suffix>(?:_\d+)?)$");

        public static bool FormatDispName(string text, out string label, out string name, out string dispName) {
            var mm = PAT_DISP_NAME.Match(text ?? "");
            if (mm.Success) {
                label = mm.Groups["label"].Value.ToUpper();
                name = mm.Groups["name"].Value;
                dispName = "[" + label + "] " + name;
                return true;
            }
            else {
                label = null;
                name = text;
                dispName = text;
                return false;
            }
        }

        public static bool FormatPropName(string text, out string label, out string name) {
            var mm = PAT_PROP_NAME.Match(text ?? "");
            if (mm.Success) {
                label = mm.Groups["prefix"].Value.ToUpper() + mm.Groups["suffix"].Value.ToUpper();
                name = mm.Groups["name"].Value;
                return true;
            }
            else {
                label = null;
                name = text;
                return false;
            }
        }

        public static bool IsEnableToggle(string label, string name) {
            return label != null && name.ToLower() == "enable";
        }
    }

    internal static class WFI18N
    {
        private static readonly string KEY_EDITOR_LANG = "UnlitWF.ShaderEditor/Lang";

        private static readonly Dictionary<string, string> EN = new Dictionary<string, string>();

        private static readonly Dictionary<string, string> JA = new Dictionary<string, string>() {
            // Common
            { "Enable", "有効" },
            { "Invert Mask Value", "マスク反転" },
            { "Blend Normal", "ノーマルマップ強度" },
            // Lit
            { "Anti-Glare", "まぶしさ防止" },
            { "Blend Light Color", "ライト色の混合強度" },
            { "Cast Shadows", "他の物体に影を落とす" },
            // Alpha
            { "[AL] Alpha Source", "[AL] アルファソース" },
            { "[AL] Alpha Mask Texture", "[AL] アルファマスク" },
            { "[AL] Power", "[AL] アルファ強度" },
            { "[AL] Fresnel Power", "[AL] フレネル強度" },
            { "[AL] Cutoff Threshold", "[AL] カットアウトしきい値" },
            // Tessellation
            { "Tessellation", "テッセレーション分割強度" },
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
            { "[MT] MetallicMap Texture", "[MT] メタリックマップ" },
            { "[MT] 2nd CubeMap Blend", "[MT] キューブマップ混合タイプ" },
            { "[MT] 2nd CubeMap", "[MT] キューブマップ" },
            // Light Matcap
            { "[HL] Matcap Type", "[HL] matcapタイプ" },
            { "[HL] Matcap Sampler", "[HL] matcapサンプラ" },
            { "[HL] Matcap Color", "[HL] matcap色調整" },
            { "[HL] Power", "[HL] matcap強度" },
            { "[HL] Mask Texture", "[HL] マスクテクスチャ" },
            // ToonShade
            { "[SH] Base Color", "[SH] ベース色" },
            { "[SH] Base Shade Texture", "[SH] ベース色テクスチャ" },
            { "[SH] 1st Shade Color", "[SH] 1影色" },
            { "[SH] 1st Shade Texture", "[SH] 1影色テクスチャ" },
            { "[SH] 2nd Shade Color", "[SH] 2影色" },
            { "[SH] 2nd Shade Texture", "[SH] 2影色テクスチャ" },
            { "[SH] Shade Power", "[SH] 影の強度" },
            { "[SH] 1st Border", "[SH] 1影の境界位置" },
            { "[SH] 2nd Border", "[SH] 2影の境界位置" },
            { "[SH] Feather", "[SH] 境界のぼかし強度" },
            { "[SH] BoostLight Mask Texture", "[SH] ブーストライトマスク" },
            { "[SH] Shade Color Suggest", "[SH] 影色を自動設定する" },
            // RimLight
            { "[RM] Rim Color", "[RM] リムライト色" },
            { "[RM] Power Top", "[RM] 強度(上)" },
            { "[RM] Power Side", "[RM] 強度(横)" },
            { "[RM] Power Bottom", "[RM] 強度(下)" },
            { "[RM] RimLight Mask Texture", "[RM] マスクテクスチャ" },
            // Overlay or ScreenTone
            { "[OL] Texture", "[OL] テクスチャ" },
            { "[OL] Blend Type", "[OL] 混合タイプ" },
            { "[OL] Blend Power", "[OL] 混合の強度" },
            { "[OL] ScreenTone Mask Texture", "[OL] マスクテクスチャ" },
            // EmissiveScroll
            { "[ES] Emissive Color", "[ES] Emissive色" },
            { "[ES] Mask Texture", "[ES] マスクテクスチャ" },
            { "[ES] Wave Type", "[ES] 波形" },
            { "[ES] Direction", "[ES] 方向" },
            { "[ES] LevelOffset", "[ES] ゼロ点調整" },
            { "[ES] Sharpness", "[ES] 鋭さ" },
            { "[ES] ScrollSpeed", "[ES] スピード" },
            { "[ES] Cull Mode", "[ES] カリングモード" },
            { "[ES] Z-shift", "[ES] Z方向の調整" },
            // Outline
            { "[LI] Line Color", "[LI] 線の色" },
            { "[LI] Line Width", "[LI] 線の太さ" },
            { "[LI] Outline Mask Texture", "[LI] マスクテクスチャ" },
            { "[LI] Z-shift (tweak)", "[LI] Z方向の調整" },
            // Ambient Occlusion
            { "[AO] Occlusion Map", "[AO] オクルージョンマップ" },
            { "[AO] Clamp Min", "[AO] 最小値" },
            { "[AO] Clamp Max", "[AO] 最大値" },
            { "[AO] Power", "[AO] 強度" },
            // Lit Advance
            { "Sun Source", "太陽光のモード" },
            { "Custom Sun Azimuth", "カスタム太陽の方角" },
            { "Custom Sun Altitude", "カスタム太陽の高度" },
            { "Disable BackLit", "逆光補正しない" },
            // Gem Reflection
            { "[GM] CubeMap", "[GM] キューブマップ" },
            { "[GM] Brightness", "[GM] 明るさ" },
            { "[GM] Monochrome Reflection", "[GM] モノクロ反射" },
        };

        private static EditorLanguage? langMode = null;

        public static EditorLanguage LangMode
        {
            get {
                if (langMode == null) {
                    string lang = EditorPrefs.GetString(KEY_EDITOR_LANG);
                    if (lang == "ja") {
                        langMode = EditorLanguage.日本語;
                    }
                    else {
                        langMode = EditorLanguage.English;
                    }
                }
                return langMode.Value;
            }
            set {
                if (langMode != value) {
                    langMode = value;
                    switch (langMode) {
                        case EditorLanguage.日本語:
                            EditorPrefs.SetString(KEY_EDITOR_LANG, "ja");
                            break;
                        default:
                            EditorPrefs.DeleteKey(KEY_EDITOR_LANG);
                            break;
                    }
                }
            }
        }

        static Dictionary<string, string> GetDict() {
            switch (LangMode) {
                case EditorLanguage.日本語:
                    return JA;
                default:
                    return EN;
            }
        }

        public static string GetDisplayName(string text) {
            text = text ?? "";
            Dictionary<string, string> current = GetDict();
            if (current != null) {
                string ret;
                if (current.TryGetValue(text, out ret)) {
                    return ret;
                }
                string label, name2;
                if (WFCommonUtility.FormatDispName(text, out label, out name2, out ret)) {
                    if (current.TryGetValue(name2, out ret)) {
                        return "[" + label + "] " + ret;
                    }
                }
            }
            return text;
        }

        public static GUIContent GetGUIContent(string text) {
            return GetGUIContent(text, null);
        }

        public static GUIContent GetGUIContent(string text, string tooltip) {
            text = text ?? "";
            string disp = GetDisplayName(text);
            if (text != disp) {
                if (tooltip == null) {
                    tooltip = text;
                }
                text = disp;
            }
            return new GUIContent(text, tooltip);
        }
    }

    internal enum EditorLanguage
    {
        English, 日本語
    }
}

#endif
