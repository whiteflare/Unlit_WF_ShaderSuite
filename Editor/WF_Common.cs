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
        /// プレフィックス名のついてない特殊なプロパティ名の対応辞書
        /// </summary>
        private static readonly Dictionary<string, string> SPECIAL_PROP_NAME = new Dictionary<string, string>() {
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
        /// プロパティ物理名からラベル文字列を抽出する。特殊な名称は辞書を参照してラベル文字列を返却する。
        /// </summary>
        /// <param name="prop_name"></param>
        /// <returns></returns>
        public static string GetPrefixFromPropName(string prop_name) {
            string label;
            if (SPECIAL_PROP_NAME.TryGetValue(prop_name, out label)) {
                return label;
            }
            string name;
            WFCommonUtility.FormatPropName(prop_name, out label, out name);
            return label;
        }

        public static bool IsEnableToggle(string label, string name) {
            return label != null && name.ToLower() == "enable";
        }
    }

    internal class ShaderMaterialProperty
    {
        public readonly Material Material;
        private readonly Shader shader;
        private readonly int index;

        ShaderMaterialProperty(Material material, Shader shader, int index) {
            this.Material = material;
            this.shader = shader;
            this.index = index;
        }

        /// <summary>
        /// プロパティの物理名
        /// </summary>
        public string Name { get { return ShaderUtil.GetPropertyName(shader, index); } }
        /// <summary>
        /// プロパティの説明文
        /// </summary>
        public string Description { get { return ShaderUtil.GetPropertyDescription(shader, index); } }
        /// <summary>
        /// プロパティの型
        /// </summary>
        public ShaderUtil.ShaderPropertyType Type { get { return ShaderUtil.GetPropertyType(shader, index); } }

        public bool CopyTo(ShaderMaterialProperty dst) {
            var srcType = Type;
            var dstType = dst.Type;
            if (srcType == dstType) {
                switch (srcType) {
                    case ShaderUtil.ShaderPropertyType.Color:
                        dst.Material.SetColor(dst.Name, this.Material.GetColor(Name));
                        return true;
                    case ShaderUtil.ShaderPropertyType.Float:
                    case ShaderUtil.ShaderPropertyType.Range:
                        dst.Material.SetFloat(dst.Name, this.Material.GetFloat(Name));
                        return true;
                    case ShaderUtil.ShaderPropertyType.Vector:
                        dst.Material.SetVector(dst.Name, this.Material.GetVector(Name));
                        return true;
                    case ShaderUtil.ShaderPropertyType.TexEnv:
                        dst.Material.SetTexture(dst.Name, this.Material.GetTexture(Name));
                        dst.Material.SetTextureOffset(dst.Name, this.Material.GetTextureOffset(Name));
                        dst.Material.SetTextureScale(dst.Name, this.Material.GetTextureScale(Name));
                        return true;
                    default:
                        break;
                }
            }
            return false;
        }

        public static List<ShaderMaterialProperty> AsList(Material material) {
            var shader = material.shader;
            int cnt = ShaderUtil.GetPropertyCount(shader);
            var result = new List<ShaderMaterialProperty>();
            for (int i = 0; i < cnt; i++) {
                result.Add(new ShaderMaterialProperty(material, shader, i));
            }
            return result;
        }

        public static Dictionary<string, ShaderMaterialProperty> AsDict(Material material) {
            var result = new Dictionary<string, ShaderMaterialProperty>();
            foreach (var p in AsList(material)) {
                result.Add(p.Name, p);
            }
            return result;
        }
    }

    internal class ShaderSerializedProperty
    {
        private readonly SerializedObject serialObject;
        private readonly SerializedProperty parent;
        private readonly SerializedProperty property;
        private readonly SerializedProperty value;

        ShaderSerializedProperty(ShaderMaterialProperty matProp, SerializedObject serialObject, SerializedProperty parent, SerializedProperty property) {
            this.serialObject = serialObject;
            this.parent = parent;
            this.property = property;

            this.MaterialProperty = matProp;
            this.value = property.FindPropertyRelative("second");
        }

        private static string GetSerializedName(SerializedProperty p) {
            SerializedProperty first = p.FindPropertyRelative("first");
            return first != null ? first.stringValue : null;
        }

        private static SerializedProperty GetSerializedValue(SerializedProperty p) {
            return p.FindPropertyRelative("second");
        }

        public ShaderMaterialProperty MaterialProperty { get; }
        public string Name { get { return MaterialProperty.Name; } }
        public string Description { get { return MaterialProperty.Description; } }
        public ShaderUtil.ShaderPropertyType Type { get { return MaterialProperty.Type; } }

        public string ParentName { get { return parent.name; } }

        public float FloatValue { get { return value.floatValue; } set { this.value.floatValue = value; } }
        public Color ColorValue { get { return value.colorValue; } set { this.value.colorValue = value; } }
        public Vector4 VectorValue { get { return value.vector4Value; } set { this.value.vector4Value = value; } }

        public void Rename(string newName) {
            property.FindPropertyRelative("first").stringValue = newName;
        }

        public void Remove() {
            for (int i = parent.arraySize - 1; 0 <= i; i--) {
                var prop = parent.GetArrayElementAtIndex(i);
                if (GetSerializedName(prop) == this.Name) {
                    parent.DeleteArrayElementAtIndex(i);
                }
            }
        }

        public static void AllApplyPropertyChange(IEnumerable<ShaderSerializedProperty> props) {
            foreach (var so in GetUniqueSerialObject(props)) {
                so.ApplyModifiedProperties();
            }
        }

        public static HashSet<SerializedObject> GetUniqueSerialObject(IEnumerable<ShaderSerializedProperty> props) {
            var ret = new HashSet<SerializedObject>();
            foreach (var prop in props) {
                if (prop != null && prop.serialObject != null) {
                    ret.Add(prop.serialObject);
                }
            }
            return ret;
        }

        public static List<ShaderSerializedProperty> AsList(IEnumerable<Material> matlist) {
            var result = new List<ShaderSerializedProperty>();
            foreach (Material mat in matlist) {
                result.AddRange(AsList(mat));
            }
            return result;
        }

        public static List<ShaderSerializedProperty> AsList(Material material) {
            var matProps = ShaderMaterialProperty.AsDict(material);
            SerializedObject so = new SerializedObject(material);
            so.Update();
            var result = new List<ShaderSerializedProperty>();
            var m_SavedProperties = so.FindProperty("m_SavedProperties");
            if (m_SavedProperties != null) {
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_Floats"), matProps));
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_Colors"), matProps));
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_TexEnvs"), matProps));
            }
            return result;
        }

        private static List<ShaderSerializedProperty> AsList(Material material, SerializedObject so, SerializedProperty parent, Dictionary<string, ShaderMaterialProperty> matProps) {
            var result = new List<ShaderSerializedProperty>();
            if (parent != null) {
                for (int i = 0; i < parent.arraySize; i++) {
                    var prop = parent.GetArrayElementAtIndex(i);
                    var name = GetSerializedName(prop);
                    ShaderMaterialProperty matProp;
                    if (name != null && matProps.TryGetValue(name, out matProp)) {
                        result.Add(new ShaderSerializedProperty(matProp, so, parent, prop));
                    }
                }
            }
            return result;
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
            { "[OL] Decal Color", "[OL] Decalテクスチャ" },
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
            { "[LI] Blend Base Color", "[LI] ベース色とのブレンド" },
            { "[LI] Outline Mask Texture", "[LI] マスクテクスチャ" },
            { "[LI] Z-shift (tweak)", "[LI] カメラから遠ざける" },
            // Ambient Occlusion
            { "[AO] Occlusion Map", "[AO] オクルージョンマップ" },
            { "[AO] Use LightMap", "[AO] ライトマップも使用する" },
            { "[AO] Contrast", "[AO] コントラスト" },
            { "[AO] Brightness", "[AO] 明るさ" },
            { "[AO] Occlusion Mask Texture", "[AO] マスクテクスチャ" },
            // Lit Advance
            { "Sun Source", "太陽光のモード" },
            { "Custom Sun Azimuth", "カスタム太陽の方角" },
            { "Custom Sun Altitude", "カスタム太陽の高度" },
            { "Disable BackLit", "逆光補正しない" },
            { "Disable ObjectBasePos", "メッシュ原点を取得しない" },
            // DebugMode
            { "Debug View", "デバッグ表示" },
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

    internal class WeakRefCache<T> where T : class
    {
        private readonly List<WeakReference> refs = new List<WeakReference>();

        public bool Contains(T target) {
            lock (refs) {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 参照が存在しているならばtrue
                foreach (var r in refs) {
                    if (r.Target == target) {
                        return true;
                    }
                }
                return false;
            }
        }

        public void Add(T target) {
            lock (refs) {
                if (Contains(target)) {
                    return;
                }
                refs.Add(new WeakReference(target));
            }
        }

        public void Remove(T target) {
            RemoveAll(target);
        }

        public void RemoveAll(params object[] targets) {
            lock (refs) {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 一致しているものを全て削除
                refs.RemoveAll(r => {
                    var tgt = r.Target as T;
                    return tgt != null && targets.Contains(tgt);
                });
            }
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
        private static readonly List<WFShaderName> ShaderNameList = new List<WFShaderName>() {
            new WFShaderName("UnToon", "Basic", "Texture", "UnlitWF/WF_UnToon_Texture"),
            new WFShaderName("UnToon", "Basic", "TransCutout", "UnlitWF/WF_UnToon_TransCutout"),
            new WFShaderName("UnToon", "Basic", "Transparent", "UnlitWF/WF_UnToon_Transparent"),
            new WFShaderName("UnToon", "Basic", "Transparent3Pass", "UnlitWF/WF_UnToon_Transparent3Pass"),
            new WFShaderName("UnToon", "Basic", "Transparent_Mask", "UnlitWF/WF_UnToon_Transparent_Mask"),
            new WFShaderName("UnToon", "Basic", "Transparent_MaskOut", "UnlitWF/WF_UnToon_Transparent_MaskOut"),
            new WFShaderName("UnToon", "Basic", "Transparent_MaskOut_Blend", "UnlitWF/WF_UnToon_Transparent_MaskOut_Blend"),

            new WFShaderName("UnToon", "Mobile", "Texture", "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Texture"),
            new WFShaderName("UnToon", "Mobile", "TransCutout", "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransCutout"),
            new WFShaderName("UnToon", "Mobile", "Transparent", "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"),

            new WFShaderName("UnToon", "MobileMetallic", "Texture", "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Texture_Metallic"),
            new WFShaderName("UnToon", "MobileMetallic", "TransCutout", "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransCutout_Metallic"),
            new WFShaderName("UnToon", "MobileMetallic", "Transparent", "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent_Metallic"),

            new WFShaderName("UnToon", "MobileOverlay", "Transparent", "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_TransparentOverlay"),

            new WFShaderName("UnToon", "Outline", "Texture", "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Texture"),
            new WFShaderName("UnToon", "Outline", "TransCutout", "UnlitWF/UnToon_Outline/WF_UnToon_Outline_TransCutout"),
            new WFShaderName("UnToon", "Outline", "Transparent", "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent"),
            new WFShaderName("UnToon", "Outline", "Transparent3Pass", "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent3Pass"),
            new WFShaderName("UnToon", "Outline", "Transparent_MaskOut", "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut"),
            new WFShaderName("UnToon", "Outline", "Transparent_MaskOut_Blend", "UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent_MaskOut_Blend"),

            new WFShaderName("UnToon", "PowerCap", "Texture", "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Texture"),
            new WFShaderName("UnToon", "PowerCap", "TransCutout", "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_TransCutout"),
            new WFShaderName("UnToon", "PowerCap", "Transparent", "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent"),
            new WFShaderName("UnToon", "PowerCap", "Transparent3Pass", "UnlitWF/UnToon_PowerCap/WF_UnToon_PowerCap_Transparent3Pass"),

            new WFShaderName("UnToon", "Tessellation", "Texture", "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Texture"),
            new WFShaderName("UnToon", "Tessellation", "TransCutout", "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_TransCutout"),
            new WFShaderName("UnToon", "Tessellation", "Transparent", "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Transparent"),
            new WFShaderName("UnToon", "Tessellation", "Transparent3Pass", "UnlitWF/UnToon_Tessellation/WF_UnToon_Tess_Transparent3Pass"),

            new WFShaderName("FakeFur", "Basic", "TransCutout", "UnlitWF/WF_FakeFur_TransCutout"),
            new WFShaderName("FakeFur", "Basic", "Transparent", "UnlitWF/WF_FakeFur_Transparent"),

            new WFShaderName("Gem", "Basic", "Transparent", "UnlitWF/WF_Gem_Transparent"),
        };

        public static WFShaderName TryFindFromName(string name) {
            return ShaderNameList.Where(nm => nm.Name == name).FirstOrDefault();
        }

        public static List<WFShaderName> GetVariantList(WFShaderName name) {
            if (name == null) {
                return new List<WFShaderName>();
            }
            return ShaderNameList.Where(nm => nm.Familly == name.Familly && nm.RenderType == name.RenderType).ToList();
        }

        public static List<WFShaderName> GetRenderTypeList(WFShaderName name) {
            if (name == null) {
                return new List<WFShaderName>();
            }
            return ShaderNameList.Where(nm => nm.Familly == name.Familly && nm.Variant == name.Variant).ToList();
        }
    }
}

#endif
