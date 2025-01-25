/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2025 whiteflare.
 *
 *  This software is provided ‘as-is’, without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
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

    public enum BakeMainTextureMode
    {
        OnlyBakeTexture,
        BakeAndUpdate,
        BakeAndNew,
    }

    public class BakeTextureParameter : ScriptableObject
    {
        public Material[] materials = { };
        public BakeMainTextureMode mode = BakeMainTextureMode.OnlyBakeTexture;

        public static BakeTextureParameter Create()
        {
            var result = ScriptableObject.CreateInstance<BakeTextureParameter>();
            result.hideFlags = HideFlags.HideInHierarchy | HideFlags.DontSave;
            return result;
        }
    }

    /// <summary>
    /// UnlitWFのマテリアルを外部から編集するユーティリティ。
    /// </summary>
    public static class WFMaterialEditUtility
    {
        #region マイグレーション

        /// <summary>
        /// マテリアルがマイグレーションを必要としているかを返却する。<br/>
        /// <br/>
        /// UnlitWFのマテリアルではない場合およびnullの場合はfalseを返却する。<br/>
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
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

        /// <summary>
        /// マテリアルをマイグレーションする。<br/>
        /// <br/>
        /// この処理はマテリアルのUndo.RecordObjectsを呼び出す。<br/>
        /// </summary>
        /// <param name="param"></param>
        public static void MigrationMaterial(MigrationParameter param)
        {
            MigrationMaterial(param.materials);
        }

        /// <summary>
        /// マテリアルをマイグレーションする。<br/>
        /// <br/>
        /// この処理はマテリアルのUndo.RecordObjectsを呼び出す。<br/>
        /// </summary>
        /// <param name="mats"></param>
        public static void MigrationMaterial(params Material[] mats)
        {
            Undo.RecordObjects(mats, "WF Migration materials");
            new Converter.WFMaterialMigrationConverter().ExecAutoConvertWithoutUndo(mats);

            // 新旧キャッシュから指定のマテリアルを削除
            WFMaterialCache.instance.ResetOldMaterialTable(mats);
        }

        private static Material editReplaceTarget = null;
        private static ShaderSerializedProperty.RemovePropertyCache editReplaceNamesCache = null;

        /// <summary>
        /// マテリアルのプロパティを連続して変更するときにキャッシュを内部で保持する。
        /// </summary>
        /// <param name="mat"></param>
        public static void BeginReplacePropertyNames(Material mat)
        {
            editReplaceTarget = mat;
            editReplaceNamesCache = null;
        }

        /// <summary>
        /// マテリアルのプロパティ編集を終了して内部のキャッシュをクリアするために呼び出される。
        /// </summary>
        /// <param name="mat"></param>
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

        /// <summary>
        /// マテリアルの設定値を別のマテリアルにコピーする。<br/>
        /// <br/>
        /// この処理はマテリアルのUndo.RecordObjectsを呼び出す。<br/>
        /// </summary>
        /// <param name="param"></param>
        public static void CopyProperties(CopyPropParameter param)
        {
            copyProperties(param, true);
        }

        /// <summary>
        /// マテリアルの設定値を別のマテリアルにコピーする。<br/>
        /// <br/>
        /// この処理はマテリアルのUndo.RecordObjectsを呼び出さない。<br/>
        /// </summary>
        /// <param name="param"></param>
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
        /// マテリアルをクリンナップし、不要なプロパティをリセットする。<br/>
        /// <br/>
        /// UnlitWFのマテリアルを渡した場合、有効化されている機能などを考慮してクリンナップを実行する。<br/>
        /// UnlitWF以外のマテリアルを渡した場合、WFマテリアル以外のクリンナップ処理が実行される。<br/>
        /// <br/>
        /// この処理はマテリアルのUndo.RecordObjectsを呼び出す。<br/>
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

        private static HashSet<string> GetResetablePropertyName(Material material)
        {
            var result = new HashSet<string>();

            // TS影
            int _TS_Steps = WFAccessor.GetInt(material, "_TS_Steps", 3);
            if (_TS_Steps < 3)
            {
                result.Add("_TS_3rdTex");
                result.Add("_TS_3rdColor");
            }
            if (_TS_Steps < 2)
            {
                result.Add("_TS_2ndTex");
                result.Add("_TS_2ndColor");
            }

            // 2nd CubeMap
            int _MT_CubemapType = WFAccessor.GetInt(material, "_MT_CubemapType", -1);
            if (_MT_CubemapType == 0)
            {
                result.Add("_MT_Cubemap");
                result.Add("_MT_CubemapPower");
                result.Add("_MT_CubemapHighCut");
            }

            // Alpha Mask
            int _AL_Source = WFAccessor.GetInt(material, "_AL_Source", -1);
            if (_AL_Source == 0) // MAIN_TEX_ALPHA
            {
                result.Add("_AL_MaskTex");
                // result.Add("_AL_InvMaskVal"); // これはMAIN_TEX_ALPHAでも使うのでリセットしない
            }

            return result;
        }

        /// <summary>
        /// WFマテリアルのクリンナップ
        /// </summary>
        /// <param name="material"></param>
        private static void CleanUpForWFMaterial(Material material)
        {
            var resetable = GetResetablePropertyName(material);

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
            foreach (var p in props)
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
                // 機能がオフされているプロパティを削除
                if (resetable.Contains(p.name))
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
        /// マテリアルの設定値をリセットする。<br/>
        /// <br/>
        /// この処理はマテリアルのUndo.RecordObjectsを呼び出す。<br/>
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
        /// マテリアルの設定値をリセットする。<br/>
        /// <br/>
        /// この処理はマテリアルのUndo.RecordObjectsを呼び出さない。<br/>
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
            foreach (var prop in ShaderMaterialProperty.AsList(material))
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

            foreach (var p in ShaderMaterialProperty.AsList(material))
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

        #region テクスチャベイク

        public static void BakeMainTexture(BakeTextureParameter param)
        {
            Func<Material, Texture2D, Texture2D> saveTexture = null;
            Func<Material, Material, Material> saveMaterial = null;

            switch (param.mode)
            {
                case BakeMainTextureMode.OnlyBakeTexture:
                    saveTexture = SaveTextureAsFile;
                    saveMaterial = (srcMaterial, newMaterial) => newMaterial;
                    break;

                case BakeMainTextureMode.BakeAndUpdate:
                    Undo.RecordObjects(param.materials, "Bake Texture and Update"); // BakeAndUpdate 以外はマテリアルを変更しないのでRecordObjectsしない
                    saveTexture = SaveTextureAsFile;
                    saveMaterial = CopyMaterialToSource;
                    break;

                case BakeMainTextureMode.BakeAndNew:
                    saveTexture = SaveTextureAsFile;
                    saveMaterial = SaveMaterialAsFile;
                    break;
            }

            foreach (var srcMaterial in param.materials)
            {
                BakeMainTexture(srcMaterial, saveTexture, saveMaterial);
            }

            Texture2D SaveTextureAsFile(Material srcMaterial, Texture2D tex)
            {
                return AssetFileSaver.SaveAsFile(tex, WFAccessor.GetTexture(srcMaterial, "_MainTex"), importer =>
                {
                    importer.maxTextureSize = tex.width <= 2048 && tex.height <= 2048 ? 2048 : 4096;
                    importer.sRGBTexture = true;
                    importer.alphaIsTransparency = true;
                    importer.alphaSource = TextureImporterAlphaSource.FromInput;
                    return true;
                });
            }

            Material SaveMaterialAsFile(Material srcMaterial, Material newMaterial)
            {
                return AssetFileSaver.SaveAsFile(newMaterial, "Save New Material", "mat");
            }

            Material CopyMaterialToSource(Material srcMaterial, Material newMaterial)
            {
                EditorUtility.CopySerialized(newMaterial, srcMaterial);
                EditorUtility.SetDirty(srcMaterial);
                return srcMaterial;
            }
        }

        public static bool BakeMainTexture(Material srcMaterial,
            Func<Material, Texture2D, Texture2D> saveTexture, Func<Material, Material, Material> saveMaterial, bool quiet = false)
        {
            // 元マテリアルをもとに判定
            if (!IsUnlitWFMaterial(srcMaterial))
            {
                return false;
            }

            // ベイクして見た目が変化する場合は警告する
            switch (ValidateMaterial(srcMaterial))
            {
                case -1: // 不要
                    return false;
                case 1: // 警告付き
                    if (quiet || !EditorUtility.DisplayDialog(WFCommonUtility.DialogTitle, WFI18N.Translate(WFMessageText.DgBakeWarning), "OK", "Cancel"))
                    {
                        Debug.LogWarningFormat(srcMaterial, "[WF][Tool] {0}, mat = {1}", WFI18N.Translate(WFMessageText.LgWarnCancelBakeTexture), srcMaterial);
                        return false;
                    }
                    break;
            }

            var transparent = srcMaterial.HasProperty("_AL_Source"); // _AL_Source がある場合はTransparentと判断する

            // ベイク用マテリアル作成
            var tempMat = new Material(srcMaterial);
#if UNITY_2022_1_OR_NEWER
            tempMat.parent = null;
#endif
            if (!WFCommonUtility.ChangeShader("Hidden/UnlitWF/WF_UnToon_BakeTexture", tempMat))
            {
                return false;
            }
            var _MainTex = WFAccessor.GetTexture(tempMat, "_MainTex");
            if (_MainTex == null)
            {
                return false;
            }
            CalcBakeTextureSize(tempMat, out var width, out var height);

            // ベイク用マテリアルの設定
            tempMat.SetTextureScale("_MainTex", Vector2.one);
            tempMat.SetTextureOffset("_MainTex", Vector2.zero);
            if (transparent)
            {
                tempMat.EnableKeyword("_WF_ALPHA_BLEND");
            }
            WFAccessor.SetFloat(tempMat, "_AL_Power", 1);
            WFAccessor.SetFloat(tempMat, "_AL_PowerMin", 0);

            var color = WFAccessor.GetColor(tempMat, "_Color", Color.white);
            var hdr = 1 < color.r || 1 < color.g || 1 < color.b;
            if (hdr)
            {
                // HDRカラーの場合は Color をリセットして続行
                WFAccessor.SetColor(tempMat, "_Color", new Color(1, 1, 1, color.a));
            }

            // ベイク本体
            Texture2D newMainTex = null;
            var oldRT = RenderTexture.active;
            var tempRT = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
            try
            {
                Graphics.Blit(_MainTex, tempRT, tempMat);

                newMainTex = new Texture2D(width, height, TextureFormat.ARGB32, false);
                RenderTexture.active = tempRT;
                newMainTex.ReadPixels(new Rect(0, 0, width, height), 0, 0);
                newMainTex.Apply();
            }
            finally
            {
                RenderTexture.ReleaseTemporary(tempRT);
                RenderTexture.active = oldRT;
            }

            // テクスチャ保存
            newMainTex = saveTexture(srcMaterial, newMainTex);
            if (newMainTex == null)
            {
                return false;
            }

            // 新マテリアル設定
            var newMaterial = new Material(srcMaterial);
            WFAccessor.SetTexture(newMaterial, "_MainTex", newMainTex);
            if (!hdr)
            {
                WFAccessor.SetColor(newMaterial, "_Color", Color.white);
            }
            WFAccessor.SetInt(newMaterial, "_AL_Source", 0);
            WFAccessor.SetTexture(newMaterial, "_AL_MaskTex", null);
            WFAccessor.SetInt(newMaterial, "_AL_InvMaskVal", 0);
            WFAccessor.SetInt(newMaterial, "_TX2_Enable", 0);
            WFAccessor.SetInt(newMaterial, "_CGR_Enable", 0);
            WFAccessor.SetInt(newMaterial, "_CLC_Enable", 0);

            WFCommonUtility.SetupMaterial(newMaterial);
            EditorUtility.SetDirty(newMaterial);

            // マテリアル保存
            newMaterial = saveMaterial(srcMaterial, newMaterial);

            return newMaterial != null;

            int ValidateMaterial(Material mat)
            {
                var _Color = WFAccessor.GetColor(mat, "_Color", Color.white);
                var _AL_Source = WFAccessor.GetInt(mat, "_AL_Source", 0);
                var _TX2_Enable = WFAccessor.GetBool(mat, "_TX2_Enable", false);
                var _CGR_Enable = WFAccessor.GetBool(mat, "_CGR_Enable", false);
                var _CLC_Enable = WFAccessor.GetBool(mat, "_CLC_Enable", false);
                if (
                    (_Color.r <= 1 && _Color.g <= 1 && _Color.b <= 1 && (_Color.r < 1 || _Color.g < 1 || _Color.b < 1))
                    || _AL_Source != 0
                    || _TX2_Enable
                    || _CGR_Enable
                    || _CLC_Enable
                    )
                {
                    var _UseVertexColor = WFAccessor.GetBool(mat, "_UseVertexColor", false);
                    var _TX2_UVType = _TX2_Enable && WFAccessor.GetBool(mat, "_TX2_UVType", false);
                    var _BKT_Enable = WFAccessor.GetBool(mat, "_BKT_Enable", false);
                    if (_UseVertexColor || _TX2_UVType || _BKT_Enable)
                    {
                        return 1; // 警告付き
                    }
                    return 0; // ベイク可能
                }
                return -1; // 不要
            }

            void CalcBakeTextureSize(Material mat, out int w, out int h)
            {
                w = 32;
                h = 32;
                foreach (var pn in new string[] { "_MainTex", "_AL_MaskTex", "_TX2_MainTex", "_TX2_MaskTex", "_CGR_MaskTex", "_CLC_MaskTex" })
                {
                    var tex = WFAccessor.GetTexture(mat, pn);
                    if (tex != null)
                    {
                        w = Math.Max(w, tex.width);
                        h = Math.Max(h, tex.height);
                    }
                }
                w = Math.Min(w, 4096);
                h = Math.Min(h, 4096);
            }
        }

        #endregion
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

        public int IntValue { get { return (int)value.floatValue; } set { this.value.floatValue = value; } }
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
