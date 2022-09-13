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

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using System.Text.RegularExpressions;

namespace UnlitWF
{
    public class MigrationParameter : ScriptableObject
    {
        public Material[] materials = { };

        public static MigrationParameter Create()
        {
            var result = ScriptableObject.CreateInstance<MigrationParameter>();
            result.hideFlags = HideFlags.HideInHierarchy | HideFlags.DontSave;
            return result;
        }
    }

    public class CopyPropParameter : ScriptableObject
    {
        public Material materialSource = null;
        public Material[] materialDestination = { };
        public string[] labels = { };
        public string[] prefixs = { };
        public bool withoutTextures = false;
        public bool onlyOverrideBuiltinTextures = false;
        public bool copyMaterialColor = false;

        public static CopyPropParameter Create()
        {
            var result = ScriptableObject.CreateInstance<CopyPropParameter>();
            result.hideFlags = HideFlags.HideInHierarchy | HideFlags.DontSave;
            return result;
        }
    }

    public class CleanUpParameter : ScriptableObject
    {
        public Material[] materials = { };

        public static CleanUpParameter Create()
        {
            var result = ScriptableObject.CreateInstance<CleanUpParameter>();
            result.hideFlags = HideFlags.HideInHierarchy | HideFlags.DontSave;
            return result;
        }
    }

    public class ResetParameter : ScriptableObject
    {
        public Material[] materials = { };
        public bool resetColor = false;
        public bool resetFloat = false;
        public bool resetTexture = false;
        public bool resetColorAlpha = false;
        public bool resetLit = false;
        public bool resetUnused = false;
        public bool resetKeywords = false;
        public string[] resetPrefixs = { };

        public static ResetParameter Create()
        {
            var result = ScriptableObject.CreateInstance<ResetParameter>();
            result.hideFlags = HideFlags.HideInHierarchy | HideFlags.DontSave;
            return result;
        }
    }

    public abstract class PropertyNameReplacement
    {
        public readonly Action<ShaderSerializedProperty> onAfterCopy;

        public PropertyNameReplacement(Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            this.onAfterCopy = onAfterCopy ?? (p => { });
        }

        public abstract bool IsMatch(string beforeName);

        protected abstract string Replace(string beforeName);

        public virtual bool TryReplace(string beforeName, out string afterName)
        {
            if (IsMatch(beforeName))
            {
                afterName = Replace(beforeName);
                return true;
            }
            else
            {
                afterName = null;
                return false;
            }
        }

        public static PropertyNameReplacement Match(string bn, string an, Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            return new MatchRename(bn, an, onAfterCopy);
        }

        public static PropertyNameReplacement Prefix(string beforePrefix, string afterPrefix, Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            return new PrefixRename(beforePrefix, afterPrefix, onAfterCopy);
        }

        public static PropertyNameReplacement Regex(string pattern, string replacement, Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            return new RegexRename(new Regex(pattern, RegexOptions.Compiled), replacement, onAfterCopy);
        }

        private class MatchRename : PropertyNameReplacement
        {
            private readonly string beforeName;
            private readonly string afterName;

            public MatchRename(string beforeName, string afterName, Action<ShaderSerializedProperty> onAfterCopy) : base(onAfterCopy)
            {
                this.beforeName = beforeName;
                this.afterName = afterName;
            }

            public override bool IsMatch(string beforeName) => this.beforeName == beforeName;
            protected override string Replace(string beforeName) => afterName;
        }

        private class PrefixRename : PropertyNameReplacement
        {
            private readonly string beforePrefix;
            private readonly string afterPrefix;

            public PrefixRename(string beforePrefix, string afterPrefix, Action<ShaderSerializedProperty> onAfterCopy) : base(onAfterCopy)
            {
                this.beforePrefix = beforePrefix;
                this.afterPrefix = afterPrefix;
            }

            public override bool IsMatch(string beforeName) => beforeName.StartsWith(beforePrefix);
            protected override string Replace(string beforeName) => afterPrefix + beforeName.Substring(beforePrefix.Length);
        }

        private class RegexRename : PropertyNameReplacement
        {
            private readonly Regex pattern;
            private readonly string replacement;

            public RegexRename(Regex pattern, string replacement, Action<ShaderSerializedProperty> onAfterCopy) : base(onAfterCopy)
            {
                this.pattern = pattern;
                this.replacement = replacement;
            }

            public override bool IsMatch(string beforeName) => pattern.IsMatch(beforeName);
            protected override string Replace(string beforeName) => pattern.Replace(beforeName, replacement);
        }
    }

    public static class WFMaterialEditUtility
    {
        #region マイグレーション

        public static bool ExistsOldNameProperty(params Material[] mats)
        {
            return Converter.WFMaterialMigrationConverter.ExistsNeedsMigration(mats);
        }

        public static void MigrationMaterial(MigrationParameter param)
        {
            MigrationMaterial(param.materials);
        }

        public static void MigrationMaterial(params Material[] mats)
        {
            Undo.RecordObjects(mats, "WF Migration materials");
            new Converter.WFMaterialMigrationConverter().ExecAutoConvertWithoutUndo(mats);

            // 新旧キャッシュから指定のマテリアルを削除
            WFMaterialCache.instance.ResetOldMaterialTable(mats);
        }

        public static bool ReplacePropertyNamesWithoutUndo(Material mat, IEnumerable<PropertyNameReplacement> replacement)
        {
            return RenamePropNamesWithoutUndoInternal(mat, replacement);
        }

        public static bool ReplacePropertyNamesWithoutUndo(Material mat, params PropertyNameReplacement[] replacement)
        {
            return RenamePropNamesWithoutUndoInternal(mat, replacement);
        }

        private static bool RenamePropNamesWithoutUndoInternal(Material mat, IEnumerable<PropertyNameReplacement> replacement)
        {
            // 名称を全て変更
            var props = ShaderSerializedProperty.AsDict(mat);
            foreach (var beforeName in props.Keys)
            {
                foreach (var rep in replacement)
                {
                    if (rep.TryReplace(beforeName, out var afterName))
                    {
                        var before = props[beforeName];
                        var after = props.GetValueOrNull(afterName);
                        if (after != null)
                        {
                            before.CopyTo(after);
                            before.Remove();
                            rep.onAfterCopy(after);
                        }
                        else
                        {
                            before.Rename(afterName);
                            rep.onAfterCopy(before);
                        }
                    }
                }
            }

            // 保存
            ShaderSerializedProperty.AllApplyPropertyChange(props.Values);

            return true;
        }

        #endregion

        #region コピー

        public static void CopyProperties(CopyPropParameter param)
        {
            copyProperties(param, true);
        }
        public static void CopyPropertiesWithoutUndo(CopyPropParameter param)
        {
            copyProperties(param, false);
        }
        public static void copyProperties(CopyPropParameter param, bool undo)
        {
            if (param.materialSource == null)
            {
                return;
            }
            var src_props = new List<ShaderMaterialProperty>();

            // Label経由とPrefix経由をどちらもPrefixにする
            var copy_target = new List<string>(WFShaderFunction.LabelToPrefix(param.labels.ToList()));
            copy_target.AddRange(param.prefixs);

            foreach (var src_prop in ShaderMaterialProperty.AsList(param.materialSource))
            {
                string prefix = WFCommonUtility.GetPrefixFromPropName(src_prop.Name);
                if (prefix != null)
                {
                    // Prefixの一致判定
                    if (copy_target.Any(prefix.Contains))
                    {
                        if (!param.withoutTextures || src_prop.Type != ShaderUtil.ShaderPropertyType.TexEnv)
                        {
                            src_props.Add(src_prop);
                        }
                    }
                }
                else
                {
                    // Prefixが無いときは
                    if (param.copyMaterialColor)
                    {
                        if (src_prop.Name == "_Color" || src_prop.Name == "_Cutoff")
                        {
                            src_props.Add(src_prop);
                        }
                    }
                }
            }
            if (src_props.Count == 0)
            {
                return;
            }

            if (undo)
            {
                Undo.RecordObjects(param.materialDestination, "WF copy materials");
            }

            for (int i = 0; i < param.materialDestination.Length; i++)
            {
                var dst = param.materialDestination[i];
                if (dst == null || dst == param.materialSource)
                { // コピー先とコピー元が同じ時もコピーしない
                    continue;
                }
                var dst_props = ShaderMaterialProperty.AsDict(dst);

                // コピー
                if (CopyProperties(src_props, dst_props, param.onlyOverrideBuiltinTextures))
                {
                    // キーワードを整理する
                    WFCommonUtility.SetupShaderKeyword(dst);
                    // ダーティフラグを付ける
                    EditorUtility.SetDirty(dst);
                }
            }
            AssetDatabase.SaveAssets();
        }

        private static bool CopyProperties(List<ShaderMaterialProperty> src, Dictionary<string, ShaderMaterialProperty> dst, bool onlyOverrideBuiltinTextures)
        {
            var changed = false;
            foreach (var src_prop in src)
            {
                ShaderMaterialProperty dst_prop;
                if (dst.TryGetValue(src_prop.Name, out dst_prop))
                {

                    // もしテクスチャがAssetsフォルダ内にある場合は上書きしない
                    if (onlyOverrideBuiltinTextures)
                    {
                        if (dst_prop.Type == ShaderUtil.ShaderPropertyType.TexEnv)
                        {
                            var tex = dst_prop.Material.GetTexture(dst_prop.Name);
                            if (!string.IsNullOrEmpty(AssetDatabase.GetAssetPath(tex)))
                            {
                                continue;
                            }
                        }
                    }

                    // コピー
                    changed |= src_prop.CopyTo(dst_prop);
                }
            }
            return changed;
        }

        #endregion

        #region リセット・クリーンナップ

        public static void CleanUpProperties(CleanUpParameter param)
        {
            Undo.RecordObjects(param.materials, "WF cleanup materials");

            foreach (Material material in param.materials)
            {
                if (material != null)
                {
                    if (IsUnlitWFMaterial(material))
                    {
                        CleanUpForWFMaterial(material); // WFマテリアルのクリンナップ
                    }
                    else
                    {
                        CleanUpForNonWFMaterial(material); // WFマテリアル以外のクリンナップ
                    }
                }
            }

            // 新旧キャッシュから指定のマテリアルを削除
            WFMaterialCache.instance.ResetOldMaterialTable(param.materials);
        }

        private static bool IsUnlitWFMaterial(Material mm)
        {
            if (mm != null && mm.shader != null)
            {
                return mm.shader.name.Contains("UnlitWF") && !mm.shader.name.Contains("Debug");
            }
            return false;
        }

        private static bool IsDisabledProperty(ShaderSerializedProperty p, List<string> disabledPrefixs)
        {
            // EnableToggle自体は削除しない
            if (WFCommonUtility.IsEnableToggleFromPropName(p.name))
            {
                return false;
            }

            // ラベルを取得
            var label = WFCommonUtility.GetPrefixFromPropName(p.name);

            // ラベルなしは削除しない
            if (string.IsNullOrEmpty(label))
            {
                return false;
            }
            // 削除対象でないラベルは削除しない
            if (!disabledPrefixs.Contains(label))
            {
                return false;
            }

            // 削除する
            return true;
        }

        private static void CleanUpForWFMaterial(Material material)
        {
            var props = ShaderSerializedProperty.AsList(material);

            // 無効になってる機能のプレフィックスを集める
            var delPrefix = new List<string>();
            foreach (var p in props)
            {
                WFCommonUtility.FormatPropName(p.name, out var label, out var name);
                if (label != null && name.ToLower() == "enable" && p.FloatValue == 0)
                {
                    delPrefix.Add(label);
                }
            }

            var del_props = new HashSet<ShaderSerializedProperty>();

            // プレフィックスに合致する設定値を消去
            props.FindAll(p => IsDisabledProperty(p, delPrefix)).ForEach(p => del_props.Add(p));
            // 未使用の値を削除
            props.FindAll(p => !p.HasPropertyInShader).ForEach(p => del_props.Add(p));

            // 削除実行
            DeleteProperties(del_props, material);

            // キーワードクリア
            foreach (var so in ShaderSerializedProperty.GetUniqueSerialObject(props))
            {
                DeleteShaderKeyword(so, material);
            }

            // キーワードを整理する
            WFCommonUtility.SetupShaderKeyword(material);
            // 反映
            EditorUtility.SetDirty(material);
        }

        private static void CleanUpForNonWFMaterial(Material material)
        {
            var props = ShaderSerializedProperty.AsList(material);
            var del_props = new HashSet<ShaderSerializedProperty>();

            // 未使用の値を削除
            props.FindAll(p => !p.HasPropertyInShader).ForEach(p => del_props.Add(p));

            // 削除実行
            DeleteProperties(del_props, material);

            // 反映
            EditorUtility.SetDirty(material);
        }

        public static void ResetProperties(ResetParameter param)
        {
            Undo.RecordObjects(param.materials, "WF reset materials");
            ResetPropertiesWithoutUndo(param);
        }

        public static void ResetPropertiesWithoutUndo(ResetParameter param)
        {
            foreach (Material material in param.materials)
            {
                if (material != null)
                {
                    ResetPropertiesWithoutUndo(param, material);
                }
            }

            // 新旧キャッシュから指定のマテリアルを削除
            WFMaterialCache.instance.ResetOldMaterialTable(param.materials);
        }

        private static void ResetPropertiesWithoutUndo(ResetParameter param, Material material)
        {
            var props = ShaderSerializedProperty.AsList(material);
            var del_props = new HashSet<ShaderSerializedProperty>();

            // ColorのAlphaチャンネルのみ変更
            foreach (var p in props)
            {
                if (p.HasPropertyInShader && p.Type == ShaderUtil.ShaderPropertyType.Color)
                {
                    var c = p.ColorValue;
                    c.a = 1;
                    p.ColorValue = c;
                }
            }
            ShaderSerializedProperty.AllApplyPropertyChange(props);

            // 条件に合致するプロパティを削除
            foreach (var p in props)
            {
                if (param.resetColor && p.Type == ShaderUtil.ShaderPropertyType.Color)
                {
                    del_props.Add(p);
                }
                else if (param.resetFloat && p.Type == ShaderUtil.ShaderPropertyType.Float)
                {
                    del_props.Add(p);
                }
                else if (param.resetTexture && p.Type == ShaderUtil.ShaderPropertyType.TexEnv)
                {
                    del_props.Add(p);
                }
                else if (param.resetUnused && !p.HasPropertyInShader)
                {
                    del_props.Add(p);
                }
                else if (param.resetLit && p.name.StartsWith("_GL_"))
                {
                    del_props.Add(p);
                }
                else if (param.resetPrefixs.Contains(WFCommonUtility.GetPrefixFromPropName(p.name)))
                {
                    del_props.Add(p);
                }
            }
            // 削除実行
            var del_names = DeleteProperties(del_props, material);

            // キーワードクリア
            if (param.resetKeywords)
            {
                foreach (var so in ShaderSerializedProperty.GetUniqueSerialObject(props))
                {
                    DeleteShaderKeyword(so, material);
                }
            }

            // キーワードを整理する
            WFCommonUtility.SetupShaderKeyword(material);
            // Default割り当てTextureを再設定する
            ResetDefaultTextures(material, del_names);
            // 反映
            EditorUtility.SetDirty(material);
        }

        private static void ResetDefaultTextures(Material material, HashSet<string> del_names)
        {
            var shader = material.shader;
            var path = AssetDatabase.GetAssetPath(shader);
            if (string.IsNullOrWhiteSpace(path))
            {
                return;
            }
            var importer = AssetImporter.GetAtPath(path) as ShaderImporter;
            if (importer == null)
            {
                return;
            }

            foreach (var pn in del_names)
            {
                if (IsShaderPropertyTexture(shader, pn))
                {
                    var tex = importer.GetDefaultTexture(pn);
                    if (tex != null)
                    {
                        material.SetTexture(pn, tex);
                    }
                }
            }
        }

        private static bool IsShaderPropertyTexture(Shader shader, string name)
        {
            var idx = WFCommonUtility.FindPropertyIndex(shader, name);
            if (idx < 0)
            {
                return false;
            }
            return shader.GetPropertyType(idx) == UnityEngine.Rendering.ShaderPropertyType.Texture;
        }

        private static HashSet<string> DeleteProperties(IEnumerable<ShaderSerializedProperty> props, Material material)
        {
            var del_names = new HashSet<string>();
            foreach (var p in props)
            {
                del_names.Add(p.name);
                p.Remove();
            }
            if (0 < del_names.Count)
            {
                var names = new List<string>(del_names);
                names.Sort();
                UnityEngine.Debug.LogFormat(material, "[WF][Tool] Deleted {0} Property: {1}", material, string.Join(", ", names.ToArray()));
            }
            ShaderSerializedProperty.AllApplyPropertyChange(props);

            return del_names;
        }

        public static void DeleteShaderKeyword(SerializedObject so, Material logTarget)
        {
            var prop = so.FindProperty("m_ShaderKeywords");
            if (prop == null || string.IsNullOrEmpty(prop.stringValue))
            {
                return;
            }
            var keywords = prop.stringValue;
            keywords = string.Join(" ", keywords.Split(' ').Where(kwd => !WFCommonUtility.IsEnableKeyword(kwd)).OrderBy(kwd => kwd));
            if (!string.IsNullOrWhiteSpace(keywords))
            {
                UnityEngine.Debug.LogFormat(logTarget, "[WF][Tool] Deleted {0} Shaderkeyword: {1}", logTarget, keywords);
            }
            prop.stringValue = "";
            so.ApplyModifiedProperties();
        }

#endregion
    }

    /// <summary>
    /// マテリアルのプロパティを編集するためのユーティリティ
    /// </summary>
    public class ShaderMaterialProperty
    {
        public readonly Material Material;
        private readonly Shader shader;
        private readonly int index;

        ShaderMaterialProperty(Material material, Shader shader, int index)
        {
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

        public bool CopyTo(ShaderMaterialProperty dst)
        {
            var srcType = Type;
            var dstType = dst.Type;
            if (srcType == dstType)
            {
                switch (srcType)
                {
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

        public static List<ShaderMaterialProperty> AsList(Material material)
        {
            var shader = material.shader;
            int cnt = ShaderUtil.GetPropertyCount(shader);
            var result = new List<ShaderMaterialProperty>();
            for (int i = 0; i < cnt; i++)
            {
                result.Add(new ShaderMaterialProperty(material, shader, i));
            }
            return result;
        }

        public static Dictionary<string, ShaderMaterialProperty> AsDict(Material material)
        {
            var result = new Dictionary<string, ShaderMaterialProperty>();
            foreach (var p in AsList(material))
            {
                result[p.Name] = p;
            }
            return result;
        }
    }

    /// <summary>
    /// シリアライズされたマテリアルのプロパティを編集するためのユーティリティ
    /// </summary>
    public class ShaderSerializedProperty
    {
        public readonly string name;
        public readonly ShaderMaterialProperty materialProperty;
        private readonly SerializedObject serialObject;
        private readonly SerializedProperty parent;
        private readonly SerializedProperty property;
        private readonly SerializedProperty value;

        ShaderSerializedProperty(string name, ShaderMaterialProperty matProp, SerializedObject serialObject, SerializedProperty parent, SerializedProperty property)
        {
            this.name = name;
            this.materialProperty = matProp;
            this.serialObject = serialObject;
            this.parent = parent;
            this.property = property;

            this.value = property.FindPropertyRelative("second");
        }

        private static string GetSerializedName(SerializedProperty p)
        {
            SerializedProperty first = p.FindPropertyRelative("first");
            return first != null ? first.stringValue : null;
        }

        private static SerializedProperty GetSerializedValue(SerializedProperty p)
        {
            return p.FindPropertyRelative("second");
        }

        public bool HasPropertyInShader
        {
            get { return materialProperty != null; }
        }

        public ShaderUtil.ShaderPropertyType Type
        {
            get
            {
                if (materialProperty != null)
                {
                    return materialProperty.Type;
                }
                if (parent != null)
                {
                    if (ParentName == "m_Colors")
                    {
                        return ShaderUtil.ShaderPropertyType.Color;
                    }
                    else if (ParentName == "m_Floats")
                    {
                        return ShaderUtil.ShaderPropertyType.Float;
                    }
                    else if (ParentName == "m_TexEnvs")
                    {
                        return ShaderUtil.ShaderPropertyType.TexEnv;
                    }
                }
                switch (value.propertyType)
                {
                    case SerializedPropertyType.Generic: // Texture
                        return ShaderUtil.ShaderPropertyType.TexEnv;
                    case SerializedPropertyType.Float:
                    case SerializedPropertyType.Integer:
                    case SerializedPropertyType.Boolean:
                    case SerializedPropertyType.Enum:
                        return ShaderUtil.ShaderPropertyType.Float;
                    case SerializedPropertyType.Color:
                        return ShaderUtil.ShaderPropertyType.Color;
                    case SerializedPropertyType.Vector2:
                    case SerializedPropertyType.Vector3:
                    case SerializedPropertyType.Vector4:
                    case SerializedPropertyType.Vector2Int:
                    case SerializedPropertyType.Vector3Int:
                        return ShaderUtil.ShaderPropertyType.Vector;
                }
                return ShaderUtil.ShaderPropertyType.Float; // 分からなかったら float を返す
            }
        }

        public string ParentName { get { return parent.name; } }

        public int IntValue {  get { return (int)value.floatValue;  } set { this.value.floatValue = value;  } }
        public float FloatValue { get { return value.floatValue; } set { this.value.floatValue = value; } }
        public Color ColorValue { get { return value.colorValue; } set { this.value.colorValue = value; } }
        public Vector4 VectorValue { get { return value.vector4Value; } set { this.value.vector4Value = value; } }
        public Texture TextureValue
        {
            get
            {
                var child = value.FindPropertyRelative("m_Texture");
                return child == null ? null : child.objectReferenceValue as Texture;
            }
        }

        public void Rename(string newName)
        {
            property.FindPropertyRelative("first").stringValue = newName;
        }

        private static void TryCopyValue(SerializedProperty src, SerializedProperty dst)
        {
            if (src == null || dst == null)
            {
                return;
            }

            switch (src.propertyType)
            {
                case SerializedPropertyType.Generic:
                    // テクスチャ系の子をコピーする
                    TryCopyValue(src.FindPropertyRelative("m_Texture"), dst.FindPropertyRelative("m_Texture"));
                    TryCopyValue(src.FindPropertyRelative("m_Scale"), dst.FindPropertyRelative("m_Scale"));
                    TryCopyValue(src.FindPropertyRelative("m_Offset"), dst.FindPropertyRelative("m_Offset"));
                    break;
                case SerializedPropertyType.Float:
                    dst.floatValue = src.floatValue;
                    break;
                case SerializedPropertyType.Color:
                    dst.colorValue = src.colorValue;
                    break;
                case SerializedPropertyType.ObjectReference:
                    dst.objectReferenceValue = src.objectReferenceValue;
                    break;
                case SerializedPropertyType.Integer:
                    dst.intValue = src.intValue;
                    break;
                case SerializedPropertyType.Boolean:
                    dst.boolValue = src.boolValue;
                    break;
                case SerializedPropertyType.Enum:
                    dst.enumValueIndex = src.enumValueIndex;
                    break;
                case SerializedPropertyType.Vector2:
                    dst.vector2Value = src.vector2Value;
                    break;
                case SerializedPropertyType.Vector3:
                    dst.vector3Value = src.vector3Value;
                    break;
                case SerializedPropertyType.Vector4:
                    dst.vector4Value = src.vector4Value;
                    break;
                case SerializedPropertyType.Vector2Int:
                    dst.vector2IntValue = src.vector2IntValue;
                    break;
                case SerializedPropertyType.Vector3Int:
                    dst.vector3IntValue = src.vector3IntValue;
                    break;
            }
        }

        public void CopyTo(ShaderSerializedProperty other)
        {
            TryCopyValue(this.value, other.value);
        }

        public void Remove()
        {
            for (int i = parent.arraySize - 1; 0 <= i; i--)
            {
                var prop = parent.GetArrayElementAtIndex(i);
                if (GetSerializedName(prop) == this.name)
                {
                    parent.DeleteArrayElementAtIndex(i);
                }
            }
        }

        public static void AllApplyPropertyChange(IEnumerable<ShaderSerializedProperty> props)
        {
            foreach (var so in GetUniqueSerialObject(props))
            {
                so.ApplyModifiedProperties();
            }
        }

        public static HashSet<SerializedObject> GetUniqueSerialObject(IEnumerable<ShaderSerializedProperty> props)
        {
            var ret = new HashSet<SerializedObject>();
            foreach (var prop in props)
            {
                if (prop != null && prop.serialObject != null)
                {
                    ret.Add(prop.serialObject);
                }
            }
            return ret;
        }

        public static Dictionary<string, ShaderSerializedProperty> AsDict(Material material)
        {
            var result = new Dictionary<string, ShaderSerializedProperty>();
            foreach (var prop in AsList(material))
            {
                result[prop.name] = prop;
            }
            return result;
        }

        public static List<ShaderSerializedProperty> AsList(IEnumerable<Material> matlist)
        {
            var result = new List<ShaderSerializedProperty>();
            foreach (Material mat in matlist)
            {
                result.AddRange(AsList(mat));
            }
            return result;
        }

        public static List<ShaderSerializedProperty> AsList(Material material)
        {
            var matProps = ShaderMaterialProperty.AsDict(material);
            SerializedObject so = new SerializedObject(material);
            so.Update();
            var result = new List<ShaderSerializedProperty>();
            var m_SavedProperties = so.FindProperty("m_SavedProperties");
            if (m_SavedProperties != null)
            {
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_Floats"), matProps));
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_Colors"), matProps));
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_TexEnvs"), matProps));
            }
            return result;
        }

        private static List<ShaderSerializedProperty> AsList(Material material, SerializedObject so, SerializedProperty parent, Dictionary<string, ShaderMaterialProperty> matProps)
        {
            var result = new List<ShaderSerializedProperty>();
            if (parent != null)
            {
                for (int i = 0; i < parent.arraySize; i++)
                {
                    var prop = parent.GetArrayElementAtIndex(i);
                    var name = GetSerializedName(prop);
                    if (name != null)
                    {
                        result.Add(new ShaderSerializedProperty(name, matProps.GetValueOrNull(name), so, parent, prop));
                    }
                }
            }
            return result;
        }
    }
}

#endif
