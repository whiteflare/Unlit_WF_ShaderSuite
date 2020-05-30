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
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine;

namespace UnlitWF
{

    #region クリンナップ系

    public class CleanUpParameter : ScriptableObject
    {
        public Material[] materials = { null };
        public bool resetUnused = false;
        public bool resetKeywords = false;
    }

    public class ToolCreanUpWindow : EditorWindow
    {

        [MenuItem("Tools/UnlitWF/CleanUp material property")]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        private static readonly List<Material> arguments = new List<Material>();

        private GUIStyle styleTitle;
        private GUIStyle styleBigText;
        Vector2 scroll = Vector2.zero;
        private CleanUpParameter param;

        private void OnEnable() {
            minSize = new Vector2(480, 640);
            param = ScriptableObject.CreateInstance<CleanUpParameter>();
            if (0 < arguments.Count) {
                param.materials = arguments.ToArray();
            }

            styleTitle = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 18,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
            styleBigText = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 16,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
        }

        private void OnGUI() {
            var so = new SerializedObject(param);
            so.Update();

            SerializedProperty prop;

            // タイトル
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("UnlitWF / CleanUp material property", styleTitle);
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            // メイン
            EditorGUILayout.LabelField("CleanUp disabled values", styleBigText);
            EditorGUILayout.HelpBox("materialsから無効化されている機能の設定値をクリアします。", MessageType.Info);
            EditorGUILayout.Space();

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materials"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = false;
            foreach (Material mm in param.materials) {
                if (mm != null && mm.shader != null && !mm.shader.name.Contains("UnlitWF")) {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    if (GUILayout.Button("Remove other materials")) {
                        removeOther = true;
                    }
                    break;
                }
            }
            EditorGUILayout.Space();

            // オプション
            EditorGUILayout.LabelField("options", EditorStyles.boldLabel);
            prop = so.FindProperty("resetUnused");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnUsed Properties (未使用の値) も一緒にクリアする");
            prop = so.FindProperty("resetKeywords");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "ShaderKeywords (Shaderキーワード) も一緒にクリアする");

            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther) {
                var newlist = new List<Material>();
                newlist.AddRange(param.materials);
                newlist.RemoveAll(mm => !mm.shader.name.Contains("UnlitWF"));
                param.materials = newlist.ToArray();
            }

            if (GUILayout.Button("CleanUp")) {
                new WFMaterialEditUtility().CleanUpProperties(param);
            }
            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion

    #region リセット系

    internal class ResetParameter : ScriptableObject
    {
        public Material[] materials = { null };
        public bool resetColor = false;
        public bool resetFloat = false;
        public bool resetTexture = false;
        public bool resetUnused = false;
        public bool resetKeywords = false;
    }

    public class ToolResetWindow : EditorWindow
    {
        [MenuItem("Tools/UnlitWF/Reset material property")]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolResetWindow>("UnlitWF/Reset material property");
        }

        private static readonly List<Material> arguments = new List<Material>();

        private GUIStyle styleTitle;
        private GUIStyle styleBigText;
        Vector2 scroll = Vector2.zero;
        private ResetParameter param;

        private void OnEnable() {
            minSize = new Vector2(480, 640);
            param = ScriptableObject.CreateInstance<ResetParameter>();
            if (0 < arguments.Count) {
                param.materials = arguments.ToArray();
            }

            styleTitle = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 18,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
            styleBigText = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 16,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
        }

        private void OnGUI() {
            var so = new SerializedObject(param);
            so.Update();

            SerializedProperty prop;

            // タイトル
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("UnlitWF / Reset material property", styleTitle);
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            // メイン
            EditorGUILayout.LabelField("Reset properties", styleBigText);
            EditorGUILayout.HelpBox("materialsの設定値を初期化します。", MessageType.Info);
            EditorGUILayout.Space();

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materials"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = false;
            foreach (Material mm in param.materials) {
                if (mm != null && mm.shader != null && !mm.shader.name.Contains("UnlitWF")) {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    if (GUILayout.Button("Remove other materials")) {
                        removeOther = true;
                    }
                    break;
                }
            }
            EditorGUILayout.Space();

            // 対象
            EditorGUILayout.LabelField("reset target", EditorStyles.boldLabel);
            prop = so.FindProperty("resetColor");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Color (色) をクリアする");
            prop = so.FindProperty("resetTexture");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Texture (テクスチャ) をクリアする");
            prop = so.FindProperty("resetFloat");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Float (数値) をクリアする");

            // オプション
            EditorGUILayout.LabelField("options", EditorStyles.boldLabel);
            prop = so.FindProperty("resetUnused");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnUsed Properties (未使用の値) も一緒にクリアする");
            prop = so.FindProperty("resetKeywords");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "ShaderKeywords (Shaderキーワード) も一緒にクリアする");

            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther) {
                var newlist = new List<Material>();
                newlist.AddRange(param.materials);
                newlist.RemoveAll(mm => !mm.shader.name.Contains("UnlitWF"));
                param.materials = newlist.ToArray();
            }

            if (GUILayout.Button("Reset Values")) {
                new WFMaterialEditUtility().ResetProperties(param);
            }
            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion

    #region コピー系

    internal class CopyPropParameter : ScriptableObject
    {
        public Material materialSource = null;
        public Material[] materialDestination = { null };
        public bool copyColorChange = false;
        public bool copyMetallic = false;
        public bool copyMatcap = false;
        public bool copyToonShade = false;
        public bool copyRimLight = false;
        public bool copyOutline = false;
    }

    public class ToolCopyWindow : EditorWindow
    {
        [MenuItem("Tools/UnlitWF/Copy material property")]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolCopyWindow>("UnlitWF/Copy material property");
        }

        private static readonly List<Material> arguments = new List<Material>();

        private GUIStyle styleTitle;
        private GUIStyle styleBigText;
        Vector2 scroll = Vector2.zero;
        private CopyPropParameter param;

        private void OnEnable() {
            minSize = new Vector2(480, 640);
            param = ScriptableObject.CreateInstance<CopyPropParameter>();
            if (0 < arguments.Count) {
                param.materialDestination = arguments.ToArray();
            }

            styleTitle = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 18,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
            styleBigText = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 16,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
        }

        private void OnGUI() {
            var so = new SerializedObject(param);
            so.Update();

            SerializedProperty prop;

            // タイトル
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("UnlitWF / Copy material property", styleTitle);
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            // メイン
            EditorGUILayout.LabelField("Copy properties", styleBigText);
            EditorGUILayout.HelpBox("source material の設定値を destination materials にコピーします。", MessageType.Info);
            EditorGUILayout.Space();

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("source materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materialSource"), new GUIContent("material"), true);
            EditorGUILayout.Space();

            if (param.materialSource != null && param.materialSource.shader != null && !param.materialSource.shader.name.Contains("UnlitWF")) {
                EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                EditorGUILayout.Space();
            }

            EditorGUILayout.LabelField("destination materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materialDestination"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = false;
            foreach (Material mm in param.materialDestination) {
                if (mm != null && mm.shader != null && !mm.shader.name.Contains("UnlitWF")) {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    if (GUILayout.Button("Remove other materials")) {
                        removeOther = true;
                    }
                    break;
                }
            }
            EditorGUILayout.Space();

            // 対象
            EditorGUILayout.LabelField("copy target", EditorStyles.boldLabel);
            prop = so.FindProperty("copyColorChange");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnToon::ColorChange");
            prop = so.FindProperty("copyMetallic");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnToon::Metallic");
            prop = so.FindProperty("copyMatcap");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnToon::LightMatcaps");
            prop = so.FindProperty("copyToonShade");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnToon::ToonShade");
            prop = so.FindProperty("copyRimLight");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnToon::RimLight");
            prop = so.FindProperty("copyOutline");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnToon::Outline");

            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther) {
                var newlist = new List<Material>();
                newlist.AddRange(param.materialDestination);
                newlist.RemoveAll(mm => !mm.shader.name.Contains("UnlitWF"));
                param.materialDestination = newlist.ToArray();
            }

            if (GUILayout.Button("Copy Values")) {
                new WFMaterialEditUtility().CopyProperties(param);
            }
            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }
    #endregion

    #region マイグレーション系

    internal class MigrationParameter : ScriptableObject
    {
        public Material[] materials = { null };
    }

    public class ToolMigrationWindow : EditorWindow
    {
        [MenuItem("Tools/UnlitWF/Migration material")]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolMigrationWindow>("UnlitWF/Migration material");
        }

        private static readonly List<Material> arguments = new List<Material>();

        private GUIStyle styleTitle;
        private GUIStyle styleBigText;
        Vector2 scroll = Vector2.zero;
        private MigrationParameter param;

        private void OnEnable() {
            minSize = new Vector2(480, 640);
            param = ScriptableObject.CreateInstance<MigrationParameter>();
            if (0 < arguments.Count) {
                param.materials = arguments.ToArray();
            }

            styleTitle = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 18,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
            styleBigText = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 16,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            };
        }

        private void OnGUI() {
            var so = new SerializedObject(param);
            so.Update();

            // タイトル
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("UnlitWF / Migration material", styleTitle);
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            // メイン
            EditorGUILayout.LabelField("Migration materials", styleBigText);
            EditorGUILayout.HelpBox("古いバージョンのUnlitWFで設定されたmaterialsを最新版に変換します。", MessageType.Info);
            EditorGUILayout.Space();

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materials"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = false;
            foreach (Material mm in param.materials) {
                if (mm != null && mm.shader != null && !mm.shader.name.Contains("UnlitWF")) {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    if (GUILayout.Button("Remove other materials")) {
                        removeOther = true;
                    }
                    break;
                }
            }
            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther) {
                var newlist = new List<Material>();
                newlist.AddRange(param.materials);
                newlist.RemoveAll(mm => !mm.shader.name.Contains("UnlitWF"));
                param.materials = newlist.ToArray();
            }

            if (GUILayout.Button("Convert")) {
                if (new WFMaterialEditUtility().RenameOldNameProperties(param)) {
                    // ShaderGUI側のマテリアルキャッシュをリセット
                    ShaderCustomEditor.ResetOldMaterialTable();
                    // 変更したマテリアルを保存
                    AssetDatabase.SaveAssets();
                }
            }

            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion

    internal class WFMaterialEditUtility
    {
        /// <summary>
        /// 古いマテリアルのマイグレーション：プロパティ名のリネーム辞書
        /// </summary>
        private readonly Dictionary<string, string> MIGRATION_PROP_RENAME = new Dictionary<string, string>() {
            { "_AL_CutOff", "_Cutoff" },
            { "_MT_MaskTex", "_MetallicGlossMap" },
            { "_MT_BlendType", "_MT_Brightness" },
            { "_MT_Smoothness", "_MT_ReflSmooth" },
            { "_MT_Smoothness2", "_MT_SpecSmooth" },
            { "_ES_MaskTex", "_EmissionMap" },
            { "_ES_Color", "_EmissionColor" },
            { "_GL_BrendPower", "_GL_BlendPower" },
        };

        #region マイグレーション

        public bool ExistsOldNameProperty(params object[] objlist) {
            return 0 < CreateOldNamePropertyList(objlist).Count;
        }

        public bool RenameOldNameProperties(MigrationParameter param) {
            return RenameOldNameProperties(param.materials);
        }

        public bool RenameOldNameProperties(object[] objlist) {
            var oldPropList = CreateOldNamePropertyList(objlist);
            // 名称を全て変更
            foreach (var prop in oldPropList) {
                prop.Rename(MIGRATION_PROP_RENAME[prop.name]);
            }
            // 保存
            foreach (var so in ShaderPropertyView.GetUniqueSerialObject(oldPropList)) {
                so.ApplyModifiedProperties();
            }
            return 0 < oldPropList.Count;
        }

        private List<ShaderPropertyView> CreateOldNamePropertyList(object[] objlist) { // ShaderCustomEditor側から呼び出されるのでobject[]
            // 操作対象のマテリアル
            var matlist = new List<Material>();
            foreach (var obj in objlist) {
                var mat = obj as Material;
                if (mat == null) {
                    continue;
                }
                if (mat.shader.name.Contains("MatcapShadows")) {
                    // MatcapShadowsは古いので対象にしない
                    continue;
                }
                matlist.Add(mat);
            }

            var props = ShaderPropertyView.ToPropertyList(matlist);

            var oldPropList = new List<ShaderPropertyView>();
            foreach (var prop in props) {
                if (MIGRATION_PROP_RENAME.ContainsKey(prop.name)) {
                    oldPropList.Add(prop);
                }
            }

            return oldPropList;
        }

        #endregion

        #region コピー

        public void CopyProperties(CopyPropParameter param) {
            if (param.materialSource == null) {
                return;
            }
            var src_props = new List<ShaderPropertyView>();

            foreach (var src_prop in ShaderPropertyView.ToPropertyList(param.materialSource)) {
                string label = WFCommonUtility.GetPrefixFromPropName(src_prop.name);
                if (label == null) {
                    continue;
                }
                // ラベルの一致判定
                bool istarget = false;
                istarget |= param.copyColorChange && label.Contains("CL");
                istarget |= param.copyMatcap && label.Contains("HL");
                istarget |= param.copyMetallic && label.Contains("MT");
                istarget |= param.copyOutline && label.Contains("TL");
                istarget |= param.copyRimLight && label.Contains("TR");
                istarget |= param.copyToonShade && label.Contains("TS");
                if (istarget) {
                    src_props.Add(src_prop);
                    continue;
                }
            }
            if (src_props.Count == 0) {
                return;
            }

            for (int i = 0; i < param.materialDestination.Length; i++) {
                var dst = param.materialDestination[i];
                if (dst == null) {
                    continue;
                }
                var dst_props = ShaderPropertyView.ToPropertyMap(dst);

                // コピー
                CopyProperties(src_props, dst_props);
                EditorUtility.SetDirty(dst);
            }
        }

        private void CopyProperties(List<ShaderPropertyView> src, Dictionary<string, ShaderPropertyView> dst) {
            var changed = new List<ShaderPropertyView>();
            foreach (var src_prop in src) {
                ShaderPropertyView dst_prop;
                if (dst.TryGetValue(src_prop.name, out dst_prop)) {
                    src_prop.CopyTo(dst_prop);
                    changed.Add(dst_prop);
                }
                else {
                    Debug.Log("not found: " + src_prop.name);
                }
            }
            ShaderPropertyView.AllApplyPropertyChange(changed);
        }

        #endregion

        #region リセット・クリーンナップ

        public void CleanUpProperties(CleanUpParameter param) {
            foreach (Material material in param.materials) {
                if (material == null) {
                    continue;
                }
                var props = ShaderPropertyView.ToPropertyList(material);

                // 無効になってる機能のプレフィックスを集める
                var delPrefix = new List<string>();
                foreach (var p in props) {
                    string label, name;
                    WFCommonUtility.FormatPropName(p.name, out label, out name);
                    if (label != null && name.ToLower() == "enable" && p.value.floatValue == 0) {
                        delPrefix.Add(label);
                    }
                }

                var del_props = new HashSet<ShaderPropertyView>();

                // プレフィックスに合致する設定値を消去
                Predicate<ShaderPropertyView> predPrefix = p => {
                    string label = WFCommonUtility.GetPrefixFromPropName(p.name);
                    return label != null && delPrefix.Contains(label);
                };
                props.FindAll(predPrefix).ForEach(p => del_props.Add(p));
                // 未使用の値を削除
                Predicate<ShaderPropertyView> predUnused = p => param.resetUnused && !material.HasProperty(p.name);
                props.FindAll(predUnused).ForEach(p => del_props.Add(p));
                // 削除実行
                DeleteProperties(del_props);

                // キーワードクリア
                if (param.resetKeywords) {
                    foreach (var so in ShaderPropertyView.GetUniqueSerialObject(props)) {
                        DeleteShaderKeyword(so);
                    }
                }

                EditorUtility.SetDirty(material);
            }
        }

        public void ResetProperties(ResetParameter param) {
            foreach (Material material in param.materials) {
                if (material == null) {
                    continue;
                }

                var props = ShaderPropertyView.ToPropertyList(material);
                var del_props = new HashSet<ShaderPropertyView>();

                // 条件に合致するプロパティを削除
                foreach (var p in props) {
                    if (param.resetColor && p.parent.name == "m_Colors") {
                        del_props.Add(p);
                    }
                    else if (param.resetFloat && p.parent.name == "m_Floats") {
                        del_props.Add(p);
                    }
                    else if (param.resetTexture && p.parent.name == "m_TexEnvs") {
                        del_props.Add(p);
                    }
                    else if (param.resetUnused && !material.HasProperty(p.name)) {
                        del_props.Add(p);
                    }
                }
                // 削除実行
                DeleteProperties(del_props);

                // キーワードクリア
                if (param.resetKeywords) {
                    foreach (var so in ShaderPropertyView.GetUniqueSerialObject(props)) {
                        DeleteShaderKeyword(so);
                    }
                }

                // 反映
                EditorUtility.SetDirty(material);
            }
        }

        private void DeleteProperties(IEnumerable<ShaderPropertyView> props) {
            var del_names = new HashSet<string>();
            foreach (var p in props) {
                del_names.Add(p.name);
                p.Remove();
            }
            if (0 < del_names.Count) {
                var names = new List<string>(del_names);
                names.Sort();
                UnityEngine.Debug.Log("UnlitWF/MaterialTools deleted property: " + string.Join(", ", names.ToArray()));
            }
            ShaderPropertyView.AllApplyPropertyChange(props);
        }

        public void DeleteShaderKeyword(SerializedObject so) {
            var prop = so.FindProperty("m_ShaderKeywords");
            if (prop == null || string.IsNullOrEmpty(prop.stringValue)) {
                return;
            }
            UnityEngine.Debug.Log("UnlitWF/MaterialTools deleted shaderkeyword: " + prop.stringValue);
            prop.stringValue = "";
            so.ApplyModifiedProperties();
        }

        #endregion
    }
}

#endif
