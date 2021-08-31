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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace UnlitWF
{
    internal static class WFMenu
    {
        public const string PATH_ASSETS = "Assets/UnlitWF Material Tools/";

        public const string ASSETS_AUTOCNV = PATH_ASSETS + "Convert UnlitWF material";
        public const string ASSETS_CREANUP = PATH_ASSETS + "CleanUp material property";
        public const string ASSETS_COPY = PATH_ASSETS + "Copy material property";
        public const string ASSETS_RESET = PATH_ASSETS + "Reset material property";
        public const string ASSETS_MIGRATION = PATH_ASSETS + "Migration material";
        public const string ASSETS_DEBUGVIEW = PATH_ASSETS + "Switch DebugView shader";
        public const string ASSETS_TEMPLATE = PATH_ASSETS + "Create MaterialTemplate";
        public const string ASSETS_KEEPMAT = PATH_ASSETS + "Keep Materials in the Scene";
        public const string ASSETS_CNGMOBILE = PATH_ASSETS + "Change Mobile shader";

        public const int PRI_ASSETS_AUTOCNV = 2201;
        public const int PRI_ASSETS_CREANUP = 2301;
        public const int PRI_ASSETS_COPY = 2302;
        public const int PRI_ASSETS_RESET = 2303;
        public const int PRI_ASSETS_MIGRATION = 2304;
        public const int PRI_ASSETS_DEBUGVIEW = 2401;
        public const int PRI_ASSETS_TEMPLATE = 2501;
        public const int PRI_ASSETS_KEEPMAT = 2601;
        public const int PRI_ASSETS_CNGMOBILE = 2701;

        public const string PATH_TOOLS = "Tools/UnlitWF/";

        public const string TOOLS_CREANUP = PATH_TOOLS + "CleanUp material property";
        public const string TOOLS_COPY = PATH_TOOLS + "Copy material property";
        public const string TOOLS_RESET = PATH_TOOLS + "Reset material property";
        public const string TOOLS_MIGRATION = PATH_TOOLS + "Migration material";

        public const int PRI_TOOLS_CREANUP = 101;
        public const int PRI_TOOLS_COPY = 102;
        public const int PRI_TOOLS_RESET = 103;
        public const int PRI_TOOLS_MIGRATION = 104;

        public const string PATH_MATERIAL = "CONTEXT/Material/";

        public const string MATERIAL_AUTOCNV = PATH_MATERIAL + "Convert UnlitWF material";
        public const string MATERIAL_DEBUGVIEW = PATH_MATERIAL + "Switch WF_DebugView shader";
        public const string MATERIAL_CNGMOBILE = PATH_MATERIAL + "Change Mobile shader";

        public const int PRI_MATERIAL_AUTOCNV = 1654;
        public const int PRI_MATERIAL_DEBUGVIEW = 1655;
        public const int PRI_MATERIAL_CNGMOBILE = 1656;

        #region Convert UnlitWF material

        [MenuItem(WFMenu.ASSETS_AUTOCNV, priority = WFMenu.PRI_ASSETS_AUTOCNV)]
        private static void Menu_AutoConvertMaterial() {
            new WFMaterialFromOtherShaderConverter().ExecAutoConvert(Selection.GetFiltered<Material>(SelectionMode.Assets));
        }

        [MenuItem(WFMenu.MATERIAL_AUTOCNV, priority = WFMenu.PRI_MATERIAL_AUTOCNV)]
        private static void ContextMenu_AutoConvertMaterial(MenuCommand cmd) {
            new WFMaterialFromOtherShaderConverter().ExecAutoConvert(cmd.context as Material);
        }

        #endregion

        #region Keep materials

        [MenuItem(WFMenu.ASSETS_KEEPMAT, priority = WFMenu.PRI_ASSETS_KEEPMAT)]
        private static void Menu_KeepMaterialInScene() {
            var mats = Selection.GetFiltered<Material>(SelectionMode.Assets);

            var go = new GameObject("MaterialKeeper");
            go.tag = "EditorOnly";
            var mr = go.AddComponent<MeshRenderer>();
            mr.enabled = false;
            mr.materials = mats.ToArray();
        }

        #endregion

        #region DebugView

        [MenuItem(WFMenu.MATERIAL_DEBUGVIEW, priority = WFMenu.PRI_MATERIAL_DEBUGVIEW)]
        private static void ContextMenu_DebugView(MenuCommand cmd) {
            WFCommonUtility.ChangeShader(WF_DebugViewEditor.SHADER_NAME_DEBUGVIEW, cmd.context as Material);
        }

        [MenuItem(WFMenu.ASSETS_DEBUGVIEW, priority = WFMenu.PRI_ASSETS_DEBUGVIEW)]
        private static void Menu_DebugView() {
            foreach (var mat in Selection.GetFiltered<Material>(SelectionMode.Assets)) {
                WFCommonUtility.ChangeShader(WF_DebugViewEditor.SHADER_NAME_DEBUGVIEW, mat);
            }
        }

        #endregion

        #region Change Mobile Shader

        [MenuItem(WFMenu.MATERIAL_CNGMOBILE, priority = WFMenu.PRI_MATERIAL_CNGMOBILE)]
        private static void ContextMenu_ChangeMobileShader(MenuCommand cmd) {
            ChangeMobileShader(cmd.context as Material);
        }

        [MenuItem(WFMenu.ASSETS_CNGMOBILE, priority = WFMenu.PRI_ASSETS_CNGMOBILE)]
        private static void Menu_ChangeMobileShader() {
            ChangeMobileShader(Selection.GetFiltered<Material>(SelectionMode.Assets));
        }

        private static void ChangeMobileShader(params Material[] mats) {
            if (0 < mats.Length && EditorUtility.DisplayDialog("WF change Mobile shader", WFI18N.Translate(WFMessageText.DgChangeMobile), "OK", "Cancel")) {
                new WFMaterialToMobileShaderConverter().ExecAutoConvert(mats);
            }
        }

        #endregion

        [MenuItem(WFMenu.ASSETS_AUTOCNV, validate = true)]
        [MenuItem(WFMenu.ASSETS_CREANUP, validate = true)]
        [MenuItem(WFMenu.ASSETS_RESET, validate = true)]
        [MenuItem(WFMenu.ASSETS_COPY, validate = true)]
        [MenuItem(WFMenu.ASSETS_MIGRATION, validate = true)]
        [MenuItem(WFMenu.ASSETS_DEBUGVIEW, validate = true)]
        [MenuItem(WFMenu.ASSETS_KEEPMAT, validate = true)]
        [MenuItem(WFMenu.ASSETS_CNGMOBILE, validate = true)]
        private static bool MenuValidation_HasMaterials() {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
        }

    }

    internal static class ToolCommon
    {
        public static bool IsUnlitWFMaterial(Material mm) {
            if (mm != null && mm.shader != null) {
                return mm.shader.name.Contains("UnlitWF") && !mm.shader.name.Contains("Debug");
            }
            return false;
        }

        public static bool IsNotUnlitWFMaterial(Material mm) {
            if (mm != null && mm.shader != null) {
                return !IsUnlitWFMaterial(mm);
            }
            return false;
        }
    }

    #region クリンナップ系

    public class ToolCreanUpWindow : EditorWindow
    {

        [MenuItem(WFMenu.TOOLS_CREANUP, priority = WFMenu.PRI_TOOLS_CREANUP)]
        [MenuItem(WFMenu.ASSETS_CREANUP, priority = WFMenu.PRI_ASSETS_CREANUP)]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        internal static void OpenWindowFromShaderGUI(Material[] mats) {
            arguments.Clear();
            arguments.AddRange(mats);
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        private static readonly List<Material> arguments = new List<Material>();

        private GUIStyle styleTitle;
        private GUIStyle styleBigText;
        Vector2 scroll = Vector2.zero;
        private CleanUpParameter param;

        private void OnEnable() {
            minSize = new Vector2(480, 640);
            param = CleanUpParameter.Create();
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
                if (ToolCommon.IsNotUnlitWFMaterial(mm)) {
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
                newlist.RemoveAll(mm => !ToolCommon.IsUnlitWFMaterial(mm));
                param.materials = newlist.ToArray();
            }

            if (GUILayout.Button("CleanUp")) {
                WFMaterialEditUtility.CleanUpProperties(param);
            }
            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion

    #region リセット系

    public class ToolResetWindow : EditorWindow
    {

        [MenuItem(WFMenu.TOOLS_RESET, priority = WFMenu.PRI_TOOLS_RESET)]
        [MenuItem(WFMenu.ASSETS_RESET, priority = WFMenu.PRI_ASSETS_RESET)]
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
            param = ResetParameter.Create();
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
                if (ToolCommon.IsNotUnlitWFMaterial(mm)) {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    if (GUILayout.Button("Remove other materials")) {
                        removeOther = true;
                    }
                    break;
                }
            }

            EditorGUILayout.Space();

            // 対象(種類から)
            EditorGUILayout.LabelField("Reset by Type", EditorStyles.boldLabel);
            prop = so.FindProperty("resetColor");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Color (色) をデフォルトに戻す");
            prop = so.FindProperty("resetTexture");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Texture (テクスチャ) をデフォルトに戻す");
            prop = so.FindProperty("resetFloat");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Float (数値) をデフォルトに戻す");

            EditorGUILayout.Space();

            // 対象(機能から)
            EditorGUILayout.LabelField("Reset by Function", EditorStyles.boldLabel);
            prop = so.FindProperty("resetColorAlpha");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Color (色) の Alpha を 1.0 にする");
            prop = so.FindProperty("resetLit");
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Lit & Lit Advance の設定をデフォルトに戻す");

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
                newlist.RemoveAll(mm => !ToolCommon.IsUnlitWFMaterial(mm));
                param.materials = newlist.ToArray();
            }

            if (GUILayout.Button("Reset Values")) {
                WFMaterialEditUtility.ResetProperties(param);
            }
            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion

    #region コピー系

    public class ToolCopyWindow : EditorWindow
    {

        [MenuItem(WFMenu.TOOLS_COPY, priority = WFMenu.PRI_TOOLS_COPY)]
        [MenuItem(WFMenu.ASSETS_COPY, priority = WFMenu.PRI_ASSETS_COPY)]
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
            param = CopyPropParameter.Create();
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
            EditorGUILayout.LabelField("destination materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materialDestination"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = false;
            foreach (Material mm in param.materialDestination) {
                if (ToolCommon.IsNotUnlitWFMaterial(mm)) {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    if (GUILayout.Button("Remove other materials")) {
                        removeOther = true;
                    }
                    break;
                }
            }
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("source materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materialSource"), new GUIContent("material"), true);
            EditorGUILayout.Space();

            if (ToolCommon.IsNotUnlitWFMaterial(param.materialSource)) {
                EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                EditorGUILayout.Space();
            }

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // 対象
            EditorGUILayout.LabelField("copy target functions", EditorStyles.boldLabel);

            var updatedFunctions = new List<string>();
            foreach (var func in WFShaderFunction.GetEnableFunctionList(param.materialSource)) {
                bool value = param.labels.Contains(func.Label);
                if (GUILayout.Toggle(value, string.Format("[{0}] {1}", func.Label, func.Name))) {
                    updatedFunctions.Add(func.Label);
                }
            }
            if (!updatedFunctions.SequenceEqual(param.labels)) {
                param.labels = updatedFunctions.ToArray();
            }

            EditorGUILayout.Space();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther) {
                var newlist = new List<Material>();
                newlist.AddRange(param.materialDestination);
                newlist.RemoveAll(mm => !ToolCommon.IsUnlitWFMaterial(mm));
                param.materialDestination = newlist.ToArray();
            }

            using (new EditorGUI.DisabledGroupScope(param.labels.Length == 0)) {
                if (GUILayout.Button("Copy Values")) {
                    WFMaterialEditUtility.CopyProperties(param);
                }
            }
            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }
    #endregion

    #region マイグレーション系

    public class ToolMigrationWindow : EditorWindow
    {
        [MenuItem(WFMenu.TOOLS_MIGRATION, priority = WFMenu.PRI_TOOLS_MIGRATION)]
        [MenuItem(WFMenu.ASSETS_MIGRATION, priority = WFMenu.PRI_ASSETS_MIGRATION)]
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
            param = MigrationParameter.Create();
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
                if (ToolCommon.IsNotUnlitWFMaterial(mm)) {
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
                newlist.RemoveAll(mm => !ToolCommon.IsUnlitWFMaterial(mm));
                param.materials = newlist.ToArray();
            }

            if (GUILayout.Button("Convert")) {
                if (WFMaterialEditUtility.RenameOldNameProperties(param)) {
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

    public abstract class AbstractMaterialConverter
    {
        private readonly List<Action<ConvertContext>> converters;

        protected AbstractMaterialConverter(List<Action<ConvertContext>> converters) {
            this.converters = converters;
        }

        public void ExecAutoConvert(params Material[] mats) {
            Undo.RecordObjects(mats, "WF Convert materials");
            ExecAutoConvertWithoutUndo(mats);
        }

        public void ExecAutoConvertWithoutUndo(params Material[] mats) {
            foreach (var mat in mats) {
                if (mat == null) {
                    continue;
                }
                if (!Validate(mat)) {
                    return;
                }

                var ctx = new ConvertContext();
                ctx.target = mat;
                ctx.oldMaterial = new Material(mat);
                ctx.oldProps = ShaderSerializedProperty.AsDict(ctx.oldMaterial);

                foreach (var cnv in converters) {
                    cnv(ctx);
                }
                Debug.LogFormat("[WF] Convert {0}: {1} -> {2}", ctx.target, ctx.oldMaterial.shader.name, ctx.target.shader.name);
            }
        }

        protected virtual bool Validate(Material mat) {
            return true;
        }

        protected class ConvertContext
        {
            public Material target;
            public Material oldMaterial;
            public Dictionary<string, ShaderSerializedProperty> oldProps;

            public ShaderType renderType = ShaderType.NoMatch;
            public bool outline = false;
        }

        protected enum ShaderType
        {
            NoMatch, Opaque, Cutout, Transparent
        }

        protected static bool IsMatchShaderName(ConvertContext ctx, string name) {
            return new Regex(".*" + name + ".*", RegexOptions.IgnoreCase).IsMatch(ctx.oldMaterial.shader.name);
        }

        private static bool hasCustomValue(Dictionary<string, ShaderSerializedProperty> props, string name) {
            if (props.TryGetValue(name, out var prop)) {
                switch (prop.Type) {
                    case ShaderUtil.ShaderPropertyType.Float:
                    case ShaderUtil.ShaderPropertyType.Range:
                        return 0.001f < Mathf.Abs(prop.FloatValue);

                    case ShaderUtil.ShaderPropertyType.Color:
                    case ShaderUtil.ShaderPropertyType.Vector:
                        var vec = prop.VectorValue;
                        return 0.001f < Mathf.Abs(vec.x) || 0.001f < Mathf.Abs(vec.y) || 0.001f < Mathf.Abs(vec.z);

                    case ShaderUtil.ShaderPropertyType.TexEnv:
                        var tex = prop.TextureValue;
                        return tex != null && !string.IsNullOrEmpty(AssetDatabase.GetAssetPath(tex));

                    default:
                        return false;
                }
            }
            return false;
        }

        protected static bool HasCustomValue(ConvertContext ctx, params string[] names) {
            var newProp = ShaderSerializedProperty.AsDict(ctx.target);

            foreach (var name in names) {
                // 新しいマテリアルから設定されていないかを調べる
                if (hasCustomValue(newProp, name)) {
                    return true;
                }
                // 古いマテリアルの側から設定されていないかを調べる
                if (hasCustomValue(ctx.oldProps, name)) {
                    return true;
                }
            }
            return false;
        }

        protected static bool IsURP() {
#if UNITY_2019_1_OR_NEWER
            return UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline != null;
#else
            return false;
#endif
        }
    }

    /// <summary>
    /// WFマテリアルをMobile系に変換するコンバータ
    /// </summary>
    public class WFMaterialToMobileShaderConverter : AbstractMaterialConverter
    {
        public WFMaterialToMobileShaderConverter() : base(CreateConverterList()) {
        }

        protected override bool Validate(Material mat) {
            // UnlitWFのマテリアルを対象に、URPではない場合に変換する
            return WFCommonUtility.IsSupportedShader(mat) && !IsURP();
        }

        protected static List<Action<ConvertContext>> CreateConverterList() {
            return new List<Action<ConvertContext>>() {
                ctx => {
                    bool cnv = false;
                    var shader = ctx.target.shader;
                    while (WFCommonUtility.IsSupportedShader(shader) && !WFCommonUtility.IsMobileSupportedShader(shader)) {
                        // シェーダ切り替え
                        var fallback = WFCommonUtility.GetShaderFallBackTarget(shader) ?? "Hidden/UnlitWF/WF_UnToon_Hidden";
                        WFCommonUtility.ChangeShader(fallback, ctx.target);

                        // シェーダ切り替え後に RenderQueue をコピー
                        ctx.target.renderQueue = ctx.oldMaterial.renderQueue;

                        shader = ctx.target.shader;
                        cnv = true;
                    }
                    if (cnv) {
                        WFCommonUtility.SetupShaderKeyword(ctx.target);
                        EditorUtility.SetDirty(ctx.target);
                    }
                },
            };
        }
    }

    /// <summary>
    /// WF系ではないマテリアルをWF系に変換するコンバータ
    /// </summary>
    public class WFMaterialFromOtherShaderConverter : AbstractMaterialConverter
    {
        public WFMaterialFromOtherShaderConverter() : base(CreateConverterList()) {
        }

        protected override bool Validate(Material mat) {
            // UnlitWF系ではないマテリアルを対象に処理する
            return !WFCommonUtility.IsSupportedShader(mat);
        }

        protected static List<Action<ConvertContext>> CreateConverterList() {
            return new List<Action<ConvertContext>>() {
                ctx => {
                    // アウトライン有無を判定する
                    if (IsMatchShaderName(ctx, "outline") && !IsMatchShaderName(ctx, "nooutline")) {
                        ctx.outline = true;
                    }
                    else if (HasCustomValue(ctx, "_OutlineMask", "_OutLineMask", "_OutlineWidthMask", "_Outline_Sampler", "_OutLineEnable", "_OutlineMode", "_UseOutline")) {
                        ctx.outline = true;
                    }
                },
                ctx => {
                    // シェーダ名からシェーダタイプを判定する
                    if (ctx.renderType == ShaderType.NoMatch) {
                        if (IsMatchShaderName(ctx, "opaque") || IsMatchShaderName(ctx, "texture")) {
                            ctx.renderType = ShaderType.Opaque;
                        }
                        else if (IsMatchShaderName(ctx, "cutout")) {
                            ctx.renderType = ShaderType.Cutout;
                        }
                        else if (IsMatchShaderName(ctx, "trans")) {
                            ctx.renderType = ShaderType.Transparent;
                        }
                    }
                },
                ctx => {
                    // RenderQueue からシェーダタイプを判定する
                    if (ctx.renderType == ShaderType.NoMatch) {
                        var queue = ctx.oldMaterial.renderQueue;
                        if (queue < 0) {
                            queue = ctx.oldMaterial.shader.renderQueue;
                        }
                        if (queue < 2450) {
                            ctx.renderType = ShaderType.Opaque;
                        } else if (queue < 2500) {
                            ctx.renderType = ShaderType.Cutout;
                        } else {
                            ctx.renderType = ShaderType.Transparent;
                        }
                    }
                },
                ctx => {
                    if (IsURP()) {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_TransCutout", ctx.target);
                                break;
                            default:
                                WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_Opaque", ctx.target);
                                break;
                        }
                    }
                    else if (ctx.outline) {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_TransCutout", ctx.target);
                                break;
                            default:
                                WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_Opaque", ctx.target);
                                break;
                        }
                    } else {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_TransCutout", ctx.target);
                                break;
                            default:
                                WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_Opaque", ctx.target);
                                break;
                        }
                    }
                    // シェーダ切り替え後に RenderQueue をコピー
                    ctx.target.renderQueue = ctx.oldMaterial.renderQueue;
                },
                ctx => {
                    if (HasCustomValue(ctx, "_MainTex")) {
                        // メインテクスチャがあるならば _Color は白にする
                        ctx.target.SetColor("_Color", Color.white);
                    }
                },
                ctx => {
                    // アルファマスク
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_AlphaMask", "_AL_MaskTex"),
                        new PropertyNameReplacement("_ClippingMask", "_AL_MaskTex"));
                    if (HasCustomValue(ctx, "_AL_MaskTex")) {
                        ctx.target.SetInt("_AL_Source", 1); // AlphaSource = MASK_TEX_RED
                    }
                },
                ctx => {
                    // ノーマルマップ
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_NormalMap", "_BumpMap"));
                    if (HasCustomValue(ctx, "_BumpMap", "_DetailNormalMap")) {
                        ctx.target.SetInt("_NM_Enable", 1);
                    }
                },
                ctx => {
                    // メタリック
                    if (HasCustomValue(ctx, "_MetallicGlossMap", "_SpecGlossMap")) {
                        ctx.target.SetInt("_MT_Enable", 1);
                    }
                },
                ctx => {
                    // AO
                    if (HasCustomValue(ctx, "_OcclusionMap")) {
                        ctx.target.SetInt("_AO_Enable", 1);
                    }
                },
                ctx => {
                    // Emission
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_Emissive_Tex", "_EmissionMap"),
                        new PropertyNameReplacement("_Emissive_Color", "_EmissionColor"));
                    if (HasCustomValue(ctx, "_EmissionMap", "_UseEmission", "_EmissionEnable", "_EnableEmission")) {
                        ctx.target.SetInt("_ES_Enable", 1);
                    }
                },
                ctx => {
                    // Toon影
                    ctx.target.SetInt("_TS_Enable", 1);
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        // 1影
                        new PropertyNameReplacement("_1st_ShadeMap", "_TS_1stTex"),
                        new PropertyNameReplacement("_ShadowColorTex", "_TS_1stTex"),
                        new PropertyNameReplacement("_1st_ShadeColor", "_TS_1stColor"),
                        new PropertyNameReplacement("_ShadowColor", "_TS_1stColor"),
                        // 2影
                        new PropertyNameReplacement("_2nd_ShadeMap", "_TS_2ndTex"),
                        new PropertyNameReplacement("_Shadow2ndColorTex", "_TS_2ndTex"),
                        new PropertyNameReplacement("_2nd_ShadeColor", "_TS_2ndColor"),
                        new PropertyNameReplacement("_Shadow2ndColor", "_TS_2ndColor")
                        );
                    // これらのテクスチャが設定されているならば _MainTex を _TS_BaseTex にも設定する
                    if (HasCustomValue(ctx, "_TS_1stTex", "_TS_2ndTex")) {
                        ctx.target.SetTexture("_TS_BaseTex", ctx.target.GetTexture("_MainTex"));
                    }
                },
                ctx => {
                    // リムライト
                    if (HasCustomValue(ctx, "_UseRim", "_RimLight", "_RimLitEnable", "_EnableRimLighting")) {
                        ctx.target.SetInt("_TR_Enable", 1);
                        WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                            new PropertyNameReplacement("_RimColor", "_TR_Color"),
                            new PropertyNameReplacement("_RimLitColor", "_TR_Color"),
                            new PropertyNameReplacement("_RimLightColor", "_TR_Color"),
                            new PropertyNameReplacement("_RimLitMask", "_TR_MaskTex"),
                            new PropertyNameReplacement("_RimBlendMask", "_TR_MaskTex"),
                            new PropertyNameReplacement("_Set_RimLightMask", "_TR_Color"),
                            new PropertyNameReplacement("_RimMask", "_TR_Color")
                            );
                    }
                },
                ctx => {
                    // アウトライン
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_OutlineColor", "_TL_LineColor"),
                        new PropertyNameReplacement("_Outline_Color", "_TL_LineColor"),
                        new PropertyNameReplacement("_OutLineColor", "_TL_LineColor"),
                        new PropertyNameReplacement("_LineColor", "_TL_LineColor"),
                        // ColorTex
                        new PropertyNameReplacement("_OutlineTex", "_TL_CustomColorTex"),
                        new PropertyNameReplacement("_OutLineTexture", "_TL_CustomColorTex"),
                        new PropertyNameReplacement("_OutlineTexture", "_TL_CustomColorTex"),
                        // MaskTex
                        new PropertyNameReplacement("_OutlineWidthMask", "_TL_MaskTex"),
                        new PropertyNameReplacement("_Outline_Sampler", "_TL_MaskTex"),
                        new PropertyNameReplacement("_OutlineMask", "_TL_MaskTex"),
                        new PropertyNameReplacement("_OutLineMask", "_TL_MaskTex")
                        );
                },
                ctx => {
                    // アルファをリセットし、キーワードを整理する
                    var resetParam = ResetParameter.Create();
                    resetParam.materials = new Material[]{ ctx.target };
                    resetParam.resetColorAlpha = true;
                    // resetParam.resetUnused = true;
                    resetParam.resetKeywords = true;
                    WFMaterialEditUtility.ResetPropertiesWithoutUndo(resetParam);
                },
            };
        }
    }
}

#endif
