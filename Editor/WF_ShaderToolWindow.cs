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
    internal static class MenuPathString
    {
        public const string PATH_TOOLS = "Tools/UnlitWF/";
        public const string PATH_ASSETS = "Assets/UnlitWF Material Tools/";

        public const string ASSETS_AUTOCNV = PATH_ASSETS + "Convert UnToon material";
        public const int PRI_AUTOCNV = 1;

        public const string TOOLS_CREANUP = PATH_TOOLS + "CleanUp material property";
        public const string ASSETS_CREANUP = PATH_ASSETS + "CleanUp material property";
        public const int PRI_CREANUP = 101;

        public const string TOOLS_COPY = PATH_TOOLS + "Copy material property";
        public const string ASSETS_COPY = PATH_ASSETS + "Copy material property";
        public const int PRI_COPY = 102;

        public const string TOOLS_RESET = PATH_TOOLS + "Reset material property";
        public const string ASSETS_RESET = PATH_ASSETS + "Reset material property";
        public const int PRI_RESET = 103;

        public const string TOOLS_MIGRATION = PATH_TOOLS + "Migration material";
        public const string ASSETS_MIGRATION = PATH_ASSETS + "Migration material";
        public const int PRI_MIGRATION = 104;

        public const string ASSETS_DEBUGVIEW = PATH_ASSETS + "Switch DebugView shader";
        public const string MATERIAL_DEBUGVIEW = "CONTEXT/Material/Switch WF_DebugView shader";
        public const int PRI_DEBUGVIEW = 201;

        public const string ASSETS_TEMPLATE = PATH_ASSETS + "Create MaterialTemplate";
        public const int PRI_TEMPLATE = 301;

        public const string ASSETS_KEEPMAT = PATH_ASSETS + "Keep Materials in the Scene";
        public const int PRI_KEEPMAT = 401;
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

    public class ToolMaterialKeeper
    {
        [MenuItem(MenuPathString.ASSETS_KEEPMAT, priority = MenuPathString.PRI_KEEPMAT)]
        private static void KeepMaterialInScene() {
            var mats = Selection.GetFiltered<Material>(SelectionMode.Assets);

            var go = new GameObject("MaterialKeeper");
            go.transform.Reset();
            go.tag = "EditorOnly";
            var mr = go.AddComponent<MeshRenderer>();
            mr.enabled = false;
            mr.materials = mats.ToArray();
        }

        [MenuItem(MenuPathString.ASSETS_KEEPMAT, validate = true)]
        private static bool OpenWindowFromMenuValidation() {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
        }
    }

    #region クリンナップ系

    public class ToolCreanUpWindow : EditorWindow
    {

        [MenuItem(MenuPathString.TOOLS_CREANUP, priority = MenuPathString.PRI_CREANUP)]
        [MenuItem(MenuPathString.ASSETS_CREANUP, priority = MenuPathString.PRI_CREANUP)]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        [MenuItem(MenuPathString.ASSETS_CREANUP, validate = true)]
        private static bool OpenWindowFromMenuValidation() {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
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

        [MenuItem(MenuPathString.TOOLS_RESET, priority = MenuPathString.PRI_RESET)]
        [MenuItem(MenuPathString.ASSETS_RESET, priority = MenuPathString.PRI_RESET)]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolResetWindow>("UnlitWF/Reset material property");
        }

        [MenuItem(MenuPathString.ASSETS_RESET, validate = true)]
        private static bool OpenWindowFromMenuValidation() {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
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

        [MenuItem(MenuPathString.TOOLS_COPY, priority = MenuPathString.PRI_COPY)]
        [MenuItem(MenuPathString.ASSETS_COPY, priority = MenuPathString.PRI_COPY)]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolCopyWindow>("UnlitWF/Copy material property");
        }

        [MenuItem(MenuPathString.ASSETS_COPY, validate = true)]
        private static bool OpenWindowFromMenuValidation() {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
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
        [MenuItem(MenuPathString.TOOLS_MIGRATION, priority = MenuPathString.PRI_MIGRATION)]
        [MenuItem(MenuPathString.ASSETS_MIGRATION, priority = MenuPathString.PRI_MIGRATION)]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ToolMigrationWindow>("UnlitWF/Migration material");
        }

        [MenuItem(MenuPathString.ASSETS_MIGRATION, validate = true)]
        private static bool OpenWindowFromMenuValidation() {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
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

    public class ToolAutoConvertMaterials
    {
        [MenuItem(MenuPathString.ASSETS_AUTOCNV, priority = MenuPathString.PRI_AUTOCNV)]
        private static void OpenWindowFromMenu() {
            foreach (var mat in Selection.GetFiltered<Material>(SelectionMode.Assets)) {
                ExecAutoConvert(mat);
            }
        }

        [MenuItem(MenuPathString.ASSETS_AUTOCNV, validate = true)]
        private static bool OpenWindowFromMenuValidation() {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
        }

        private static bool IsMatchShaderName(ConvertContext ctx, string name) {
            return new Regex(".*" + name + ".*", RegexOptions.IgnoreCase).IsMatch(ctx.oldMaterial.shader.name);
        }

        private static readonly List<Func<ConvertContext, bool>> selectShader = new List<Func<ConvertContext, bool>>() {
            ctx => {
                // アウトライン有無を判定する
                if (IsMatchShaderName(ctx, "outline") && !IsMatchShaderName(ctx, "nooutline")) {
                    ctx.outline = true;
                }
                else if (HasCustomValueTexture(ctx, "_OutlineMask", "_OutLineMask", "_OutlineWidthMask", "_Outline_Sampler")) {
                    ctx.outline = true;
                }
                else if (HasCustomValueFloat(ctx, "_OutLineEnable", "_OutlineMode", "_UseOutline")) {
                    ctx.outline = true;
                }
                return false; // まだ決まっていない
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
                return false;
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
                return false;
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
                return true;
            },
        };

        private static readonly List<Action<ConvertContext>> selectFeature = new List<Action<ConvertContext>>() {
            ctx => {
                // アルファマスク
                WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                    new PropertyNameReplacement("_AlphaMask", "_AL_MaskTex"),
                    new PropertyNameReplacement("_ClippingMask", "_AL_MaskTex"));
                if (HasCustomValueTexture(ctx, "_AL_MaskTex")) {
                    ctx.target.SetInt("_AL_Source", 1); // AlphaSource = MASK_TEX_RED
                }
            },
            ctx => {
                // ノーマルマップ
                if (HasCustomValueTexture(ctx, "_BumpMap", "_DetailNormalMap")) {
                    ctx.target.SetInt("_NM_Enable", 1);
                }
            },
            ctx => {
                // メタリック
                if (HasCustomValueTexture(ctx, "_MetallicGlossMap", "_SpecGlossMap")) {
                    ctx.target.SetInt("_MT_Enable", 1);
                }
            },
            ctx => {
                // AO
                if (HasCustomValueTexture(ctx, "_OcclusionMap")) {
                    ctx.target.SetInt("_AO_Enable", 1);
                }
            },
            ctx => {
                // Emission
                if (HasCustomValueTexture(ctx, "_EmissionMap") || HasCustomValueFloat(ctx, "_UseEmission", "_EmissionEnable")) {
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
            },
            ctx => {
                // リムライト
                if (HasCustomValueFloat(ctx, "_UseRim", "_RimLight", "_RimLitEnable")) {
                    ctx.target.SetInt("_TR_Enable", 1);
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_RimColor", "_TR_Color"),
                        new PropertyNameReplacement("_RimLitColor", "_TR_Color"),
                        new PropertyNameReplacement("_RimLightColor", "_TR_Color"),
                        new PropertyNameReplacement("_RimLitMask", "_TR_MaskTex"),
                        new PropertyNameReplacement("_RimBlendMask", "_TR_MaskTex"),
                        new PropertyNameReplacement("_Set_RimLightMask", "_TR_Color")
                        );
                }
            },
            ctx => {
                // アウトライン
                WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                    new PropertyNameReplacement("_OutlineColor", "_TL_LineColor"),
                    new PropertyNameReplacement("_Outline_Color", "_TL_LineColor"),
                    new PropertyNameReplacement("_OutLineColor", "_TL_LineColor"),
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
                var resetParam = new ResetParameter();
                resetParam.materials = new Material[]{ ctx.target };
                resetParam.resetColorAlpha = true;
                WFMaterialEditUtility.ResetPropertiesWithoutUndo(resetParam);
            },
        };

        public static void ExecAutoConvert(Material mat) {
            if (mat == null || mat.shader.name.Contains("UnlitWF")) {
                return;
            }

            var ctx = new ConvertContext();
            ctx.target = mat;
            ctx.oldMaterial = new Material(mat);
            ctx.oldProps = ShaderSerializedProperty.AsDict(ctx.oldMaterial);

            foreach (var cnv in selectShader) {
                if (cnv(ctx)) {
                    foreach (var act in selectFeature) {
                        act(ctx);
                    }
                    Debug.LogFormat("[WF] Convert {0}: {1} -> {2}", ctx.target, ctx.oldMaterial.shader.name, ctx.target.shader.name);
                    return;
                }
            }
        }

        private class ConvertContext
        {
            public Material target;
            public Material oldMaterial;
            public Dictionary<string, ShaderSerializedProperty> oldProps;

            public ShaderType renderType = ShaderType.NoMatch;
            public bool outline = false;
        }

        private enum ShaderType
        {
            NoMatch, Opaque, Cutout, Transparent
        }

        private static bool HasCustomValueFloat(ConvertContext ctx, params string[] names) {
            foreach (var name in names) {
                if (ctx.oldProps.TryGetValue(name, out var prop)) {
                    if (prop.Type == ShaderUtil.ShaderPropertyType.Float || prop.Type == ShaderUtil.ShaderPropertyType.Range) {
                        return 0.001f < Mathf.Abs(prop.FloatValue);
                    }
                }
            }
            return false;
        }

        private static bool HasCustomValueTexture(ConvertContext ctx, params string[] names) {
            foreach (var name in names) {
                if (ctx.oldProps.TryGetValue(name, out var prop)) {
                    if (prop.Type == ShaderUtil.ShaderPropertyType.TexEnv) {
                        var tex = prop.TextureValue;
                        if (tex != null && !string.IsNullOrEmpty(AssetDatabase.GetAssetPath(tex))) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        private static bool IsURP() {
            return UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline != null;
        }
    }
}

#endif
