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

        [NonSerialized]
        public Func<string, string> propNameReplacer = nm => nm;

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
        public bool execNonWFMaterials = false;

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

    abstract class PropertyNameReplacement
    {
        public readonly Action<ShaderSerializedProperty> onAfterCopy;

        public PropertyNameReplacement(Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            this.onAfterCopy = onAfterCopy ?? (p => { });
        }

        public virtual bool Test(string version)
        {
            return true;
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
            return new MatchRename(bn, false, an, onAfterCopy);
        }

        public static PropertyNameReplacement MatchIgnoreCase(string bn, string an, Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            return new MatchRename(bn, true, an, onAfterCopy);
        }

        public static PropertyNameReplacement Prefix(string beforePrefix, string afterPrefix, Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            return new PrefixRename(beforePrefix, afterPrefix, onAfterCopy);
        }

        public static PropertyNameReplacement Regex(string pattern, string replacement, Action<ShaderSerializedProperty> onAfterCopy = null)
        {
            return new RegexRename(new Regex(pattern, RegexOptions.Compiled), replacement, onAfterCopy);
        }

        public static PropertyNameReplacement Group(string version)
        {
            return new GroupCondition(version);
        }

        private class GroupCondition : PropertyNameReplacement
        {
            private readonly string version;

            public GroupCondition(string version) : base(null)
            {
                this.version = version;
            }

            public override bool Test(string version)
            {
                if (string.IsNullOrWhiteSpace(version))
                {
                    return true;
                }
                // このグループのバージョンが、指定されたバージョン以下である場合
                return this.version.CompareTo(version) <= 0;
            }

            public override bool IsMatch(string beforeName) => false;
            protected override string Replace(string beforeName) => beforeName;
        }


        private class MatchRename : PropertyNameReplacement
        {
            private readonly string beforeName;
            private readonly string afterName;
            private readonly bool ignoreCase;

            public MatchRename(string beforeName, bool ignoreCase, string afterName, Action<ShaderSerializedProperty> onAfterCopy) : base(onAfterCopy)
            {
                this.beforeName = beforeName;
                this.afterName = afterName;
                this.ignoreCase = ignoreCase;
            }

            public override bool IsMatch(string beforeName) => string.Equals(this.beforeName, beforeName, 
                ignoreCase ? StringComparison.InvariantCultureIgnoreCase : StringComparison.InvariantCulture);
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

        public static bool ExistsNeedsMigration(Material mat)
        {
            return Converter.WFMaterialMigrationConverter.ExistsNeedsMigration(mat);
        }

        internal static bool ExistsNeedsMigration(Material mat, IEnumerable<PropertyNameReplacement> replacement)
        {
            if (mat != null)
            {
                var version = WFAccessor.GetShaderCurrentVersion(mat);
                var props = ShaderSerializedProperty.AsDict(mat);
                foreach (var beforeName in props.Keys)
                {
                    foreach (var rep in replacement)
                    {
                        if (!rep.Test(version))
                        {
                            break;
                        }
                        if (rep.IsMatch(beforeName))
                        {
                            return true;
                        }
                    }
                }
            }
            return false;
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

        private static Material editReplaceTarget = null;
        private static ShaderSerializedProperty.RemovePropertyCache editReplaceNamesCache = null;

        public static void BeginReplacePropertyNames(Material mat)
        {
            editReplaceTarget = mat;
            editReplaceNamesCache = null;
        }

        public static void EndReplacePropertyNames(Material mat)
        {
            if (mat == editReplaceTarget)
            {
                editReplaceTarget = null;
                editReplaceNamesCache = null;
            }
        }


        internal static bool ReplacePropertyNamesWithoutUndo(Material mat, IEnumerable<PropertyNameReplacement> replacement)
        {
            return RenamePropNamesWithoutUndoInternal(mat, replacement);
        }

        internal static bool ReplacePropertyNamesWithoutUndo(Material mat, params PropertyNameReplacement[] replacement)
        {
            return RenamePropNamesWithoutUndoInternal(mat, replacement);
        }

        private static bool RenamePropNamesWithoutUndoInternal(Material mat, IEnumerable<PropertyNameReplacement> replacement)
        {
            var version = WFAccessor.GetShaderCurrentVersion(mat);
            var props = ShaderSerializedProperty.AsList(mat);
            // 名称を全て変更
            foreach (var rep in replacement)
            {
                if (!rep.Test(version))
                {
                    break;
                }
                var modified = false;
                foreach (var before in props)
                {
                    if (!rep.TryReplace(before.name, out var afterName))
                    {
                        continue;
                    }
                    var after = props.Where(pn => pn.name == afterName).FirstOrDefault();
                    if (after != null)
                    {
                        before.CopyTo(after);
                        if (mat == editReplaceTarget)
                        {
                            before.Remove(ref editReplaceNamesCache);
                        }
                        else
                        {
                            before.Remove();
                        }
                        rep.onAfterCopy(after);
                    }
                    else
                    {
                        before.Rename(afterName);
                        if (mat == editReplaceTarget)
                        {
                            editReplaceNamesCache = null;
                        }
                        rep.onAfterCopy(before);
                    }
                    modified = true;
                }
                if (modified)
                {
                    // 保存
                    ShaderSerializedProperty.AllApplyPropertyChange(props);
                    // 再取得
                    props = ShaderSerializedProperty.AsList(mat);
                    // フラグクリア
                    modified = false;
                }
            }

            return true;
        }

        #endregion

        #region コピー

        public static void CopyProperties(CopyPropParameter param)
        {
            copyProperties(param, true);
        }

        internal static void CopyPropertiesWithoutUndo(CopyPropParameter param)
        {
            copyProperties(param, false);
        }

        private static void copyProperties(CopyPropParameter param, bool undo)
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
                    if (copy_target.Contains(prefix))
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
                if (CopyProperties(src_props, dst_props, param.onlyOverrideBuiltinTextures, param.propNameReplacer))
                {
                    // キーワードを整理する
                    WFCommonUtility.SetupMaterial(dst);
                    // ダーティフラグを付ける
                    EditorUtility.SetDirty(dst);
                }
            }
            AssetDatabase.SaveAssets();
        }

        private static bool CopyProperties(List<ShaderMaterialProperty> src, Dictionary<string, ShaderMaterialProperty> dst, bool onlyOverrideBuiltinTextures, Func<string, string> propNameReplacer)
        {
            var changed = false;
            foreach (var src_prop in src)
            {
                var dst_prop_name = src_prop.Name;
                dst_prop_name = propNameReplacer(dst_prop_name);
                if (string.IsNullOrWhiteSpace(dst_prop_name))
                {
                    continue;
                }
                if (!dst.TryGetValue(dst_prop_name, out var dst_prop))
                {
                    continue;
                }

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
            return changed;
        }

        #endregion

        #region リセット・クリーンナップ

        /// <summary>
        /// クリンナップのエントリポイント
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public static bool CleanUpProperties(CleanUpParameter param)
        {
            param.materials = param.materials.Where(m => m != null).Distinct().ToArray();

            Undo.RecordObjects(param.materials, "WF cleanup materials");

            var matsWF = new List<Material>();
            var matsNonWF = new List<Material>();

            foreach (Material material in param.materials)
            {
                if (material != null)
                {
                    if (IsUnlitWFMaterial(material))
                    {
                        CleanUpForWFMaterial(material); // WFマテリアルのクリンナップ
                        matsWF.Add(material);
                    }
                    else if (param.execNonWFMaterials)
                    {
                        CleanUpForNonWFMaterial(material); // WFマテリアル以外のクリンナップ
                        matsNonWF.Add(material);
                    }
                }
            }

            // 新旧キャッシュから指定のマテリアルを削除
            WFMaterialCache.instance.ResetOldMaterialTable(matsWF.ToArray());

            bool done = 0 < matsWF.Count || 0 < matsNonWF.Count;
            if (done)
            {
                UnityEngine.Debug.LogFormat("[WF][Tool] CleanUp {0} materials, and {1} Non-WF materials", matsWF.Count, matsNonWF.Count);
            }
            return done;
        }

        private static bool IsUnlitWFMaterial(Material mm)
        {
            if (mm != null && mm.shader != null)
            {
                if (mm.shader.name.Contains("UnlitWF") && !mm.shader.name.Contains("Debug"))
                {
                    return mm.shader.name.Contains("URP") == WFCommonUtility.IsURP();
                }
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

        /// <summary>
        /// WFマテリアルのクリンナップ
        /// </summary>
        /// <param name="material"></param>
        private static void CleanUpForWFMaterial(Material material)
        {
            int steps = WFAccessor.GetInt(material, "_TS_Steps", 3);

            var props = ShaderSerializedProperty.AsList(material);

            // 無効になってる機能のプレフィックスを集める
            var delPrefix = new List<string>();
            foreach (var p in props)
            {
                WFCommonUtility.FormatPropName(p.name, out var prefix, out var name);
                if (WFCommonUtility.IsEnableToggle(prefix, name) && p.FloatValue == 0)
                {
                    delPrefix.Add(prefix);
                }
            }

            var del_props = new List<ShaderSerializedProperty>();
            foreach(var p in props)
            {
                // プレフィックスに合致する設定値を消去
                if (IsDisabledProperty(p, delPrefix))
                {
                    del_props.Add(p);
                    continue;
                }
                // 未使用の値を削除
                if (!p.HasPropertyInShader)
                {
                    del_props.Add(p);
                    continue;
                }
                // 使っていない影テクスチャ削除
                if (steps < 3 && (p.name == "_TS_3rdTex" || p.name == "_TS_3rdColor"))
                {
                    del_props.Add(p);
                    continue;
                }
                if (steps < 2 && (p.name == "_TS_2ndTex" || p.name == "_TS_2ndColor"))
                {
                    del_props.Add(p);
                    continue;
                }
            }

            // 削除実行
            DeleteProperties(del_props, material);

            // キーワードクリア
            foreach (var so in ShaderSerializedProperty.GetUniqueSerialObject(props))
            {
                DeleteShaderKeyword(so, material);
            }

            // キーワードを整理する
            WFCommonUtility.SetupMaterial(material);
            // 反映
            EditorUtility.SetDirty(material);
        }

        /// <summary>
        /// その他のマテリアルのクリンナップ
        /// </summary>
        /// <param name="material"></param>
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

        /// <summary>
        /// リセットのエントリポイント
        /// </summary>
        /// <param name="param"></param>
        public static void ResetProperties(ResetParameter param)
        {
            Undo.RecordObjects(param.materials, "WF reset materials");

            ResetPropertiesWithoutUndo(param);

            // 新旧キャッシュから指定のマテリアルを削除
            WFMaterialCache.instance.ResetOldMaterialTable(param.materials);
        }

        /// <summary>
        /// リセットのエントリポイント(Undoなし)
        /// </summary>
        /// <param name="param"></param>
        internal static void ResetPropertiesWithoutUndo(ResetParameter param)
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

        /// <summary>
        /// リセット本体
        /// </summary>
        /// <param name="param"></param>
        /// <param name="material"></param>
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

            // Default割り当てTextureを再設定する
            ResetEnabledDefaultTextures(material, del_names);

            // キーワードを整理する
            WFCommonUtility.SetupMaterial(material);
            // 反映
            EditorUtility.SetDirty(material);
        }

        /// <summary>
        /// 特定の名前のプロパティを削除する
        /// </summary>
        /// <param name="material"></param>
        /// <param name="propNames"></param>
        internal static void DeletePropertiesWithoutUndo(Material material, params string[] propNames)
        {
            var props = ShaderSerializedProperty.AsDict(material);
            var del_props = new List<ShaderSerializedProperty>();
            foreach (var name in propNames)
            {
                if (props.TryGetValue(name, out var p))
                {
                    del_props.Add(p);
                }
            }
            if (del_props.Count == 0)
            {
                return;
            }

            // 削除実行
            DeleteProperties(del_props, material);
            // 反映
            EditorUtility.SetDirty(material);
        }

        /// <summary>
        /// プロパティを削除する。クリンナップとリセットの両方から呼び出される。
        /// </summary>
        /// <param name="props"></param>
        /// <param name="material"></param>
        /// <returns></returns>
        private static HashSet<string> DeleteProperties(IEnumerable<ShaderSerializedProperty> props, Material material)
        {
            var del_names = new HashSet<string>();
            ShaderSerializedProperty.RemovePropertyCache cachedNames = null;

            foreach (var p in props)
            {
                del_names.Add(p.name);
                if (material == editReplaceTarget)
                {
                    p.Remove(ref editReplaceNamesCache);
                }
                else
                {
                    p.Remove(ref cachedNames);
                }
            }

            ShaderSerializedProperty.AllApplyPropertyChange(props);

            return del_names;
        }

        /// <summary>
        /// キーワードを削除する。クリンナップとリセットの両方から呼び出される。
        /// </summary>
        /// <param name="so"></param>
        /// <param name="logTarget"></param>
        private static void DeleteShaderKeyword(SerializedObject so, Material logTarget)
        {
            var changed = false;

            var prop = so.FindProperty("m_ShaderKeywords");
            if (prop != null && !string.IsNullOrEmpty(prop.stringValue))
            {
                prop.stringValue = "";
                changed = true;
            }

#if UNITY_2021_2_OR_NEWER
            prop = so.FindProperty("m_ValidKeywords");
            if (prop != null && 0 < prop.arraySize)
            {
                prop.ClearArray();
                changed = true;
            }
            prop = so.FindProperty("m_InvalidKeywords");
            if (prop != null && 0 < prop.arraySize)
            {
                prop.ClearArray();
                changed = true;
            }
#endif
            if (changed)
            {
                so.ApplyModifiedProperties();
            }
        }

        /// <summary>
        /// 有効になっている機能のデフォルトテクスチャを割り当てる
        /// </summary>
        /// <param name="material"></param>
        /// <param name="prefix"></param>
        private static void ResetEnabledDefaultTextures(Material material, IEnumerable<string> del_names)
        {
            // まずは削除されたプロパティのプレフィックスを全て集める
            var del_prefixs = new HashSet<string>();
            foreach (var prop_name in del_names)
            {
                if (WFCommonUtility.FormatPropName(prop_name, out var prefix, out var name))
                {
                    del_prefixs.Add(prefix);
                }
            }

            // Enableトグルがオフになっているプレフィックスは復元しないので削除
            foreach(var prop in ShaderMaterialProperty.AsList(material))
            {
                if (WFCommonUtility.FormatPropName(prop.Name, out var prefix, out var name) && WFCommonUtility.IsEnableToggle(prefix, name))
                {
                    if (!WFAccessor.GetBool(material, prop.Name, false))
                    {
                        del_prefixs.Remove(prefix);
                    }
                }
            }

            // テクスチャをデフォルトに設定
            ResetDefaultTextures(material, del_names.Where(nm => !WFCommonUtility.FormatPropName(nm, out var prefix, out var name) || del_prefixs.Contains(prefix)));
        }

        /// <summary>
        /// デフォルトテクスチャを割り当てる。WFHeaderToggle がオンになったときに呼び出される。
        /// </summary>
        /// <param name="material"></param>
        /// <param name="prefix"></param>
        internal static void ResetDefaultTextures(Material material, params string[] prefixs)
        {
            List<string> prop_names = new List<string>();

            foreach(var p in ShaderMaterialProperty.AsList(material))
            {
                var px = WFCommonUtility.GetPrefixFromPropName(p.Name);
                if (prefixs.Contains(px))
                {
                    prop_names.Add(p.Name);
                }
            }

            ResetDefaultTextures(material, prop_names);

            EditorUtility.SetDirty(material);
        }

        /// <summary>
        /// デフォルトテクスチャを割り当てる
        /// </summary>
        /// <param name="material"></param>
        /// <param name="prop_names"></param>
        private static void ResetDefaultTextures(Material material, IEnumerable<string> prop_names)
        {
            var shader = material.shader;

            List<string> tex_prop_names = new List<string>();
            foreach (var pn in prop_names)
            {
                if (WFAccessor.HasShaderPropertyTexture(shader, pn))
                {
                    var oldTex = WFAccessor.GetTexture(material, pn); // ResetDefaultTextureの直前でSerializeObject.ApplyPropertyChangeした内容はHasPropertyなどでアクセスしないとコミットされない？
                    if (oldTex == null) // テクスチャが設定されていないときだけデフォルトテクスチャを設定する
                    {
                        tex_prop_names.Add(pn);
                    }
                }
            }
            if (tex_prop_names.Count == 0)
            {
                return;
            }

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

            foreach (var pn in tex_prop_names)
            {
                var defaultTex = importer.GetDefaultTexture(pn);
                if (defaultTex != null)
                {
                    material.SetTexture(pn, defaultTex);
                }
            }
        }

        #endregion
    }

    /// <summary>
    /// マテリアルのプロパティを編集するためのユーティリティ
    /// </summary>
    class ShaderMaterialProperty
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
    class ShaderSerializedProperty
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
            RemovePropertyCache cache = null;
            Remove(ref cache);
        }

        public void Remove(ref RemovePropertyCache cache)
        {
            if (!RemovePropertyCache.Acceptable(cache, this))
            {
                cache = new RemovePropertyCache(parent);
            }

            for (int i = parent.arraySize - 1; 0 <= i; i--)
            {
                if (cache.propNames[i] == this.name)
                {
                    parent.DeleteArrayElementAtIndex(i);
                    cache.propNames.RemoveAt(i);
                }
            }
        }

        public class RemovePropertyCache
        {
            public readonly SerializedProperty parent;
            public readonly List<string> propNames;

            public RemovePropertyCache(SerializedProperty parent)
            {
                this.parent = parent;

                propNames = new List<string>();
                for (int i = 0; i < parent.arraySize; i++)
                {
                    var prop = parent.GetArrayElementAtIndex(i);
                    propNames.Add(GetSerializedName(prop));
                }
            }

            public static bool Acceptable(RemovePropertyCache cache, ShaderSerializedProperty _this)
            {
                return cache != null && cache.parent == _this.parent && cache.propNames.Count == _this.parent.arraySize;
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
