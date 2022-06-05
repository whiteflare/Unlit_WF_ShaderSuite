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

namespace UnlitWF
{
    internal static class WFMenu
    {
        public const string PATH_ASSETS = "Assets/UnlitWF Material Tools/";

        public const string ASSETS_AUTOCNV = PATH_ASSETS + "Convert UnlitWF Material";
        public const string ASSETS_CREANUP = PATH_ASSETS + "CleanUp Material Property";
        public const string ASSETS_COPY = PATH_ASSETS + "Copy Material Property";
        public const string ASSETS_RESET = PATH_ASSETS + "Reset Material Property";
        public const string ASSETS_MIGRATION = PATH_ASSETS + "Migration Material";
        public const string ASSETS_DEBUGVIEW = PATH_ASSETS + "Switch DebugView Shader";
        public const string ASSETS_TEMPLATE = PATH_ASSETS + "Create MaterialTemplate";
        public const string ASSETS_KEEPMAT = PATH_ASSETS + "Keep Materials in the Scene";
        public const string ASSETS_CNGMOBILE = PATH_ASSETS + "Change Mobile Shader";
        public const string ASSETS_MIGALL = PATH_ASSETS + "Migration All Materials";

        public const int PRI_ASSETS_AUTOCNV = 2201;
        public const int PRI_ASSETS_CREANUP = 2301;
        public const int PRI_ASSETS_COPY = 2302;
        public const int PRI_ASSETS_RESET = 2303;
        public const int PRI_ASSETS_MIGRATION = 2304;
        public const int PRI_ASSETS_DEBUGVIEW = 2401;
        public const int PRI_ASSETS_TEMPLATE = 2501;
        public const int PRI_ASSETS_KEEPMAT = 2601;
        public const int PRI_ASSETS_CNGMOBILE = 2701;
        public const int PRI_ASSETS_MIGALL = 2702;

        public const string PATH_TOOLS = "Tools/UnlitWF/";

        public const string TOOLS_CREANUP = PATH_TOOLS + "CleanUp Material Property";
        public const string TOOLS_COPY = PATH_TOOLS + "Copy Material Property";
        public const string TOOLS_RESET = PATH_TOOLS + "Reset Material Property";
        public const string TOOLS_MIGRATION = PATH_TOOLS + "Migration Material";
        public const string TOOLS_MIGALL = PATH_TOOLS + "Migration All Materials";

        public const int PRI_TOOLS_CREANUP = 101;
        public const int PRI_TOOLS_COPY = 102;
        public const int PRI_TOOLS_RESET = 103;
        public const int PRI_TOOLS_MIGRATION = 104;
        public const int PRI_TOOLS_MIGALL = 301;

        public const string PATH_MATERIAL = "CONTEXT/Material/";

        public const string MATERIAL_AUTOCNV = PATH_MATERIAL + "Convert UnlitWF Material";
        public const string MATERIAL_DEBUGVIEW = PATH_MATERIAL + "Switch WF_DebugView Shader";
        public const string MATERIAL_CNGMOBILE = PATH_MATERIAL + "Change Mobile shader";

        public const int PRI_MATERIAL_AUTOCNV = 1654;
        public const int PRI_MATERIAL_DEBUGVIEW = 1655;
        public const int PRI_MATERIAL_CNGMOBILE = 1656;

        public const string PATH_GAMEOBJECT = "GameObject/";

        public const string GAMEOBJECT_CREANUP = PATH_GAMEOBJECT + "CleanUp Material Property";

        #region Convert UnlitWF material

        [MenuItem(WFMenu.ASSETS_AUTOCNV, priority = WFMenu.PRI_ASSETS_AUTOCNV)]
        private static void Menu_AutoConvertMaterial()
        {
            var mats = new MaterialSeeker().GetSelectionAllMaterial(MatSelectMode.FromAssetDeep);
            new Converter.WFMaterialFromOtherShaderConverter().ExecAutoConvert(mats.ToArray());
        }

        [MenuItem(WFMenu.MATERIAL_AUTOCNV, priority = WFMenu.PRI_MATERIAL_AUTOCNV)]
        private static void ContextMenu_AutoConvertMaterial(MenuCommand cmd)
        {
            new Converter.WFMaterialFromOtherShaderConverter().ExecAutoConvert(cmd.context as Material);
        }

        #endregion

        #region Migration

        [MenuItem(WFMenu.ASSETS_MIGALL, priority = WFMenu.PRI_ASSETS_MIGALL)]
        [MenuItem(WFMenu.TOOLS_MIGALL, priority = WFMenu.PRI_TOOLS_MIGALL)]
        private static void Menu_ScanAndAllMigration()
        {
            Converter.ScanAndMigrationExecutor.ExecuteByManual();
        }

        #endregion

        #region Keep materials

        [MenuItem(WFMenu.ASSETS_KEEPMAT, priority = WFMenu.PRI_ASSETS_KEEPMAT)]
        private static void Menu_KeepMaterialInScene()
        {
            var mats = new MaterialSeeker().GetSelectionAllMaterial(MatSelectMode.FromAsset);

            var go = new GameObject("MaterialKeeper");
            go.tag = "EditorOnly";
            var mr = go.AddComponent<MeshRenderer>();
            mr.enabled = false;
            mr.materials = mats.ToArray();
        }

        #endregion

        #region DebugView

        [MenuItem(WFMenu.MATERIAL_DEBUGVIEW, priority = WFMenu.PRI_MATERIAL_DEBUGVIEW)]
        private static void ContextMenu_DebugView(MenuCommand cmd)
        {
            WFCommonUtility.ChangeShader(WF_DebugViewEditor.SHADER_NAME_DEBUGVIEW, cmd.context as Material);
        }

        [MenuItem(WFMenu.ASSETS_DEBUGVIEW, priority = WFMenu.PRI_ASSETS_DEBUGVIEW)]
        private static void Menu_DebugView()
        {
            foreach (var mat in new MaterialSeeker().GetSelectionAllMaterial(MatSelectMode.FromAsset))
            {
                WFCommonUtility.ChangeShader(WF_DebugViewEditor.SHADER_NAME_DEBUGVIEW, mat);
            }
        }

        #endregion

        #region Change Mobile Shader

        [MenuItem(WFMenu.MATERIAL_CNGMOBILE, priority = WFMenu.PRI_MATERIAL_CNGMOBILE)]
        private static void ContextMenu_ChangeMobileShader(MenuCommand cmd)
        {
            ChangeMobileShader(cmd.context as Material);
        }

        [MenuItem(WFMenu.ASSETS_CNGMOBILE, priority = WFMenu.PRI_ASSETS_CNGMOBILE)]
        private static void Menu_ChangeMobileShader()
        {
            var mats = new MaterialSeeker().GetSelectionAllMaterial(MatSelectMode.FromAssetDeep);
            ChangeMobileShader(mats.ToArray());
        }

        private static void ChangeMobileShader(params Material[] mats)
        {
            if (0 < mats.Length && EditorUtility.DisplayDialog("WF change Mobile shader", WFI18N.Translate(WFMessageText.DgChangeMobile), "OK", "Cancel"))
            {
                new Converter.WFMaterialToMobileShaderConverter().ExecAutoConvert(mats);
            }
        }

        #endregion

        [MenuItem(WFMenu.ASSETS_DEBUGVIEW, validate = true)]
        [MenuItem(WFMenu.ASSETS_KEEPMAT, validate = true)]
        private static bool MenuValidation_HasMaterials()
        {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
        }
    }

    internal static class ToolCommon
    {
        public static bool IsUnlitWFMaterial(Material mm)
        {
            if (mm != null && mm.shader != null)
            {
                return mm.shader.name.Contains("UnlitWF") && !mm.shader.name.Contains("Debug");
            }
            return false;
        }

        public static bool IsNotUnlitWFMaterial(Material mm)
        {
            if (mm != null && mm.shader != null)
            {
                return !IsUnlitWFMaterial(mm);
            }
            return false;
        }

        public static Material[] FilterOnlyWFMaterial(Material[] array)
        {
            return array.Where(mat => IsUnlitWFMaterial(mat)).ToArray();
        }

        public static bool NoticeIfIllegalMaterials(Material[] array, bool showRemoveButton = true)
        {
            foreach (var mm in array)
            {
                if (ToolCommon.IsNotUnlitWFMaterial(mm))
                {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    if (showRemoveButton && GUILayout.Button("Remove other materials"))
                    {
                        return true;
                    }
                    break;
                }
            }
            return false;
        }

        public static void WindowHeader(string title, string subtitle, string helptext)
        {
            // タイトル
            EditorGUILayout.Space();
            EditorGUILayout.LabelField(title, new GUIStyle(EditorStyles.boldLabel)
            {
                fontSize = 18,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            });
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            // メイン
            EditorGUILayout.LabelField(subtitle, new GUIStyle(EditorStyles.boldLabel)
            {
                fontSize = 16,
                fontStyle = FontStyle.Bold,
                fixedHeight = 32,
            });
            EditorGUILayout.Space();
            EditorGUILayout.HelpBox(helptext, MessageType.Info);
            EditorGUILayout.Space();
        }

        public static bool ExecuteButton(string label, bool disable = false)
        {
            using (new EditorGUI.DisabledGroupScope(disable))
            {
                var oldColor = GUI.color;
                GUI.color = new Color(0.75f, 0.75f, 1f);
                bool exec = GUILayout.Button(label);
                GUI.color = oldColor;
                return exec;
            }
        }

        private static readonly List<Material> arguments = new List<Material>();

        public static void SetSelectedMaterials(MatSelectMode mode)
        {
            arguments.Clear();
            arguments.AddRange(new MaterialSeeker().GetSelectionAllMaterial(mode));
        }

        public static void SetMaterials(Material[] mats)
        {
            arguments.Clear();
            arguments.AddRange(mats);
        }

        public static void GetSelectedMaterials(ref Material[] array)
        {
            if (array != null && 0 < arguments.Count)
            {
                array = arguments.Distinct().Where(mat => mat != null).OrderBy(mat => mat.name).ToArray();
                arguments.Clear();
            }
        }

    }

    #region クリンナップ系

    public class ToolCreanUpWindow : EditorWindow
    {
        [MenuItem(WFMenu.ASSETS_CREANUP, priority = WFMenu.PRI_ASSETS_CREANUP)]
        private static void OpenWindowFromMenu_Asset()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromAssetDeep);
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        [MenuItem(WFMenu.GAMEOBJECT_CREANUP, priority = 10)] // GameObject/配下は priority の扱いがちょっと特殊
        private static void OpenWindowFromMenu_GameObject()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromScene);
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        [MenuItem(WFMenu.TOOLS_CREANUP, priority = WFMenu.PRI_TOOLS_CREANUP)]
        private static void OpenWindowFromMenu_Tool()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromSceneOrAsset);
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        [MenuItem(WFMenu.GAMEOBJECT_CREANUP, validate = true)]
        private static bool MenuValidation_HasGameObjects()
        {
            return Selection.GetFiltered<GameObject>(SelectionMode.Unfiltered).Length != 0;
        }

        internal static void OpenWindowFromShaderGUI(Material[] mats)
        {
            ToolCommon.SetMaterials(mats);
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        Vector2 scroll = Vector2.zero;
        private CleanUpParameter param;

        private void OnEnable()
        {
            minSize = new Vector2(480, 640);
            param = CleanUpParameter.Create();
            ToolCommon.GetSelectedMaterials(ref param.materials);
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / CleanUp material property", "CleanUp disabled values", "materialsから無効化されている機能の設定値をクリアします。");

            var so = new SerializedObject(param);
            so.Update();

            SerializedProperty prop;

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty(nameof(CleanUpParameter.materials)), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);
            EditorGUILayout.Space();

            // オプション
            EditorGUILayout.LabelField("options", EditorStyles.boldLabel);
            prop = so.FindProperty(nameof(CleanUpParameter.resetUnused));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnUsed Properties (未使用の値) も一緒にクリアする");
            prop = so.FindProperty(nameof(CleanUpParameter.resetKeywords));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "ShaderKeywords (Shaderキーワード) も一緒にクリアする");

            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther)
            {
                param.materials = ToolCommon.FilterOnlyWFMaterial(param.materials);
            }

            if (ToolCommon.ExecuteButton("CleanUp", param.materials.Length == 0))
            {
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
        [MenuItem(WFMenu.ASSETS_RESET, priority = WFMenu.PRI_ASSETS_RESET)]
        private static void OpenWindowFromMenu_Asset()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromAssetDeep);
            GetWindow<ToolResetWindow>("UnlitWF/Reset material property");
        }

        [MenuItem(WFMenu.TOOLS_RESET, priority = WFMenu.PRI_TOOLS_RESET)]
        private static void OpenWindowFromMenu_Tool()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromSceneOrAsset);
            GetWindow<ToolResetWindow>("UnlitWF/Reset material property");
        }

        Vector2 scroll = Vector2.zero;
        private ResetParameter param;

        private void OnEnable()
        {
            minSize = new Vector2(480, 640);
            param = ResetParameter.Create();
            ToolCommon.GetSelectedMaterials(ref param.materials);
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / Reset material property", "Reset properties", "materialsの設定値を初期化します。");

            var so = new SerializedObject(param);
            so.Update();

            SerializedProperty prop;

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty(nameof(ResetParameter.materials)), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);

            EditorGUILayout.Space();

            // 対象(種類から)
            EditorGUILayout.LabelField("Reset by Type", EditorStyles.boldLabel);
            prop = so.FindProperty(nameof(ResetParameter.resetColor));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Color (色) をデフォルトに戻す");
            prop = so.FindProperty(nameof(ResetParameter.resetTexture));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Texture (テクスチャ) をデフォルトに戻す");
            prop = so.FindProperty(nameof(ResetParameter.resetFloat));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Float (数値) をデフォルトに戻す");

            EditorGUILayout.Space();

            // 対象(機能から)
            EditorGUILayout.LabelField("Reset by Function", EditorStyles.boldLabel);
            prop = so.FindProperty(nameof(ResetParameter.resetColorAlpha));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Color (色) の Alpha を 1.0 にする");
            prop = so.FindProperty(nameof(ResetParameter.resetLit));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "Lit & Lit Advance の設定をデフォルトに戻す");

            EditorGUILayout.Space();

            // オプション
            EditorGUILayout.LabelField("options", EditorStyles.boldLabel);
            prop = so.FindProperty(nameof(ResetParameter.resetUnused));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "UnUsed Properties (未使用の値) も一緒にクリアする");
            prop = so.FindProperty(nameof(ResetParameter.resetKeywords));
            prop.boolValue = GUILayout.Toggle(prop.boolValue, "ShaderKeywords (Shaderキーワード) も一緒にクリアする");

            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther)
            {
                param.materials = ToolCommon.FilterOnlyWFMaterial(param.materials);
            }

            if (ToolCommon.ExecuteButton("Reset Values", param.materials.Length == 0))
            {
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

        [MenuItem(WFMenu.ASSETS_COPY, priority = WFMenu.PRI_ASSETS_COPY)]
        private static void OpenWindowFromMenu_Asset()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromAssetDeep);
            GetWindow<ToolCopyWindow>("UnlitWF/Copy material property");
        }

        [MenuItem(WFMenu.TOOLS_COPY, priority = WFMenu.PRI_TOOLS_COPY)]
        private static void OpenWindowFromMenu_Tool()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromSceneOrAsset);
            GetWindow<ToolCopyWindow>("UnlitWF/Copy material property");
        }

        Vector2 scroll = Vector2.zero;
        private CopyPropParameter param;

        private void OnEnable()
        {
            minSize = new Vector2(480, 640);
            param = CopyPropParameter.Create();
            ToolCommon.GetSelectedMaterials(ref param.materialDestination);
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / Copy material property", "Copy properties", "source material の設定値を destination materials にコピーします。");

            var so = new SerializedObject(param);
            so.Update();

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("destination materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty(nameof(CopyPropParameter.materialDestination)), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materialDestination);
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("source materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty(nameof(CopyPropParameter.materialSource)), new GUIContent("material"), true);
            EditorGUILayout.Space();

            ToolCommon.NoticeIfIllegalMaterials(new Material[] { param.materialSource }, false);
            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // 対象
            EditorGUILayout.LabelField("copy target functions", EditorStyles.boldLabel);

            var updatedFunctions = new List<string>();
            foreach (var func in WFShaderFunction.GetEnableFunctionList(param.materialSource))
            {
                bool value = param.labels.Contains(func.Label);
                if (GUILayout.Toggle(value, string.Format("[{0}] {1}", func.Label, func.Name)))
                {
                    updatedFunctions.Add(func.Label);
                }
            }
            if (!updatedFunctions.SequenceEqual(param.labels))
            {
                param.labels = updatedFunctions.ToArray();
            }

            EditorGUILayout.Space();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther)
            {
                param.materialDestination = ToolCommon.FilterOnlyWFMaterial(param.materialDestination);
            }

            using (new EditorGUI.DisabledGroupScope(param.labels.Length == 0))
            {
                if (ToolCommon.ExecuteButton("Copy Values", param.materialSource == null || param.materialDestination.Length == 0))
                {
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
        [MenuItem(WFMenu.ASSETS_MIGRATION, priority = WFMenu.PRI_ASSETS_MIGRATION)]
        private static void OpenWindowFromMenu_Asset()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromAssetDeep);
            GetWindow<ToolMigrationWindow>("UnlitWF/Migration material");
        }

        [MenuItem(WFMenu.TOOLS_MIGRATION, priority = WFMenu.PRI_TOOLS_MIGRATION)]
        private static void OpenWindowFromMenu_Tool()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromSceneOrAsset);
            GetWindow<ToolMigrationWindow>("UnlitWF/Migration material");
        }

        Vector2 scroll = Vector2.zero;
        private MigrationParameter param;

        private void OnEnable()
        {
            minSize = new Vector2(480, 640);
            param = MigrationParameter.Create();
            ToolCommon.GetSelectedMaterials(ref param.materials);
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / Migration material", "Migration materials", "古いバージョンのUnlitWFで設定されたmaterialsを最新版に変換します。");

            var so = new SerializedObject(param);
            so.Update();

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty(nameof(MigrationParameter.materials)), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);
            EditorGUILayout.Space();

            so.ApplyModifiedPropertiesWithoutUndo();
            so.SetIsDifferentCacheDirty();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther)
            {
                param.materials = ToolCommon.FilterOnlyWFMaterial(param.materials);
            }

            if (ToolCommon.ExecuteButton("Convert", param.materials.Length == 0))
            {
                // 変換
                WFMaterialEditUtility.MigrationMaterial(param);
                // ShaderGUI側のマテリアルキャッシュをリセット
                ShaderCustomEditor.ResetOldMaterialTable();
                // 変更したマテリアルを保存
                AssetDatabase.SaveAssets();
            }

            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion

}

#endif
