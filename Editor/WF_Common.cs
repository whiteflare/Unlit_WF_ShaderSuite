/*
 *  The MIT License
 *
 *  Copyright 2018-2020 whiteflare.
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

        /// <summary>
        /// プロパティ名の文字列から、Prefix+Suffixと名前を分割する。
        /// </summary>
        /// <param name="text">プロパティ名</param>
        /// <param name="label">Prefix+Suffix</param>
        /// <param name="name">名前</param>
        /// <returns></returns>
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

        /// <summary>
        /// プロパティ物理名からラベル文字列を抽出する。特殊な名称は辞書を参照してラベル文字列を返却する。
        /// </summary>
        /// <param name="prop_name"></param>
        /// <returns></returns>
        public static string GetPrefixFromPropName(string prop_name) {
            string label = WFShaderDictionary.SpecialPropNameToLabelMap.GetValueOrNull(prop_name);
            if (label != null) {
                return label;
            }
            string name;
            WFCommonUtility.FormatPropName(prop_name, out label, out name);
            return label;
        }

        public static bool IsEnableToggleFromPropName(string prop_name) {
            string label, name;
            WFCommonUtility.FormatPropName(prop_name, out label, out name);
            return IsEnableToggle(label, name);
        }

        public static bool IsEnableToggle(string label, string name) {
            return label != null && name.ToLower() == "enable";
        }

        public static void ChangeShader(string name, params Material[] mats) {
            if (string.IsNullOrWhiteSpace(name) || mats.Length == 0) {
                return; // なにもしない
            }
            var newShader = Shader.Find(name);
            if (newShader != null) {
                Undo.RecordObjects(mats, "change shader");
                foreach (var m in mats) {
                    if (m == null) {
                        continue;
                    }
                    var oldShader = m.shader;

                    // 初期化処理の呼び出し (カスタムエディタを取得してAssignNewShaderToMaterialしたかったけど手が届かなかったので静的アクセス)
                    if (WF_DebugViewEditor.IsSupportedShader(newShader)) {
                        WF_DebugViewEditor.PreChangeShader(m, oldShader, newShader);
                    }
                    else if (ShaderCustomEditor.IsSupportedShader(newShader)) {
                        ShaderCustomEditor.PreChangeShader(m, oldShader, newShader);
                    }
                    // マテリアルにシェーダ割り当て
                    m.shader = newShader;
                    // 初期化処理の呼び出し (カスタムエディタを取得してAssignNewShaderToMaterialしたかったけど手が届かなかったので静的アクセス)
                    if (WF_DebugViewEditor.IsSupportedShader(newShader)) {
                        WF_DebugViewEditor.PostChangeShader(m, oldShader, newShader);
                    }
                    else if (ShaderCustomEditor.IsSupportedShader(newShader)) {
                        ShaderCustomEditor.PostChangeShader(m, oldShader, newShader);
                    }
                }
            }
            else {
                Debug.LogErrorFormat("Shader Not Found in this projects: {0}", name);
            }
        }

        public static Material[] AsMaterials(params UnityEngine.Object[] array) {
            return array == null ? new Material[0] : array.Select(obj => obj as Material).Where(m => m != null).ToArray();
        }
    }

    public class WFShaderFunction
    {
        private static List<string> uniqueLabel = new List<string>();

        public readonly string Label;
        public readonly string Prefix;
        public readonly string Name;
        private readonly Func<WFShaderFunction, Material, bool> _contains;

        internal WFShaderFunction(string label, string prefix, string name) : this(label, prefix, name,
                (self, mat) => {
                    var nm = "_" + self.Prefix + "_Enable";
                    if (mat.HasProperty(nm)) {
                        return mat.GetInt(nm) != 0;
                    }
                    return false;
                }
            ) {
        }

        internal WFShaderFunction(string label, string prefix, string name, Func<WFShaderFunction, Material, bool> contains) {
            Label = label;
            Prefix = prefix;
            Name = name;
            _contains = contains;

            if (uniqueLabel.Contains(Label)) {
                Debug.LogWarningFormat("UnlitWF WFShaderFunction duplicate Label: " + Label);
            }
            else {
                uniqueLabel.Add(Label);
            }
        }

        public bool Contains(Material mat) {
            if (mat == null || !mat.shader.name.Contains("UnlitWF")) {
                return false;
            }
            return _contains(this, mat);
        }

        public static List<string> LabelToPrefix(List<string> labelList) {
            return labelList.Select(LabelToPrefix).Where(prefix => prefix != null).Distinct().ToList();
        }

        public static string LabelToPrefix(string label) {
            return WFShaderDictionary.ShaderFuncList.Where(func => func.Label == label).Select(func => func.Prefix).FirstOrDefault();
        }
    }

    internal enum EditorLanguage
    {
        English, 日本語
    }

    internal static class WFI18N
    {
        private static readonly string KEY_EDITOR_LANG = "UnlitWF.ShaderEditor/Lang";
        private static readonly Dictionary<string, string> EN = new Dictionary<string, string>();
        private static readonly Dictionary<string, string> JA = WFShaderDictionary.LangEnToJa;

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
                string ret = current.GetValueOrNull(text);
                if (ret != null) {
                    return ret;
                }
                if (WFCommonUtility.FormatDispName(text, out string label, out string name2, out ret)) {
                    ret = current.GetValueOrNull(name2);
                    if (ret != null) {
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

    internal class WFShaderName
    {
        public string Familly { get; private set; }
        public string Variant { get; private set; }
        public string RenderType { get; private set; }
        public string Name { get; private set; }

        public WFShaderName(string familly, string variant, string renderType, string name) {
            this.Familly = familly;
            this.Variant = variant;
            this.RenderType = renderType;
            this.Name = name;
        }
    }

    internal static class WFShaderNameDictionary
    {
        public static WFShaderName TryFindFromName(string name) {
            return WFShaderDictionary.ShaderNameList.Where(nm => nm.Name == name).FirstOrDefault();
        }

        public static List<WFShaderName> GetVariantList(WFShaderName name) {
            if (name == null) {
                return new List<WFShaderName>();
            }
            return WFShaderDictionary.ShaderNameList.Where(nm => nm.Familly == name.Familly && nm.RenderType == name.RenderType).ToList();
        }

        public static List<WFShaderName> GetRenderTypeList(WFShaderName name) {
            if (name == null) {
                return new List<WFShaderName>();
            }
            return WFShaderDictionary.ShaderNameList.Where(nm => nm.Familly == name.Familly && nm.Variant == name.Variant).ToList();
        }
    }
}

#endif
