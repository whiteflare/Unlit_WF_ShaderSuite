﻿/*
 *  The MIT License
 *
 *  Copyright 2018-2023 whiteflare.
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

// VRCSDK有無の判定ここから //////
#if VRC_SDK_VRCSDK3
#define ENV_VRCSDK3
#if UDON
#define ENV_VRCSDK3_WORLD
#else
#define ENV_VRCSDK3_AVATAR
#endif
#endif
// VRCSDK有無の判定ここまで //////

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace UnlitWF
{
    static class WFMenu
    {
        public const string PATH_ASSETS = "Assets/UnlitWF Material Tools/";
        public const string PATH_TOOLS = "Tools/UnlitWF/";
        public const string PATH_MATERIAL = "CONTEXT/Material/";
        public const string PATH_GAMEOBJECT = "GameObject/";

#if WF_ML_JP
        public const string ASSETS_AUTOCNV = PATH_ASSETS + "UnlitWF のマテリアルに変換する";

        public const string ASSETS_DEBUGVIEW = PATH_ASSETS + "シェーダ切替/DebugView シェーダに切り替える";
        public const string ASSETS_CNGMOBILE = PATH_ASSETS + "シェーダ切替/モバイル向けシェーダに変換する";

        public const string TOOLS_REIMPORT = PATH_TOOLS + "Reimport UnlitWF Shaders";
        public const string ASSETS_CREANUP = PATH_ASSETS + "マテリアルのクリンナップ";
        public const string ASSETS_COPY = PATH_ASSETS + "マテリアル設定値のコピー";
        public const string ASSETS_RESET = PATH_ASSETS + "マテリアル設定値のリセット";
        public const string ASSETS_MIGRATION = PATH_ASSETS + "マテリアルを最新に変換する";
        public const string ASSETS_DLSET = PATH_ASSETS + "シーンDL方向をマテリアルに焼き込む";

        public const string TOOLS_CREANUP = PATH_TOOLS + "マテリアルのクリンナップ";
        public const string TOOLS_COPY = PATH_TOOLS + "マテリアル設定値のコピー";
        public const string TOOLS_RESET = PATH_TOOLS + "マテリアル設定値のリセット";
        public const string TOOLS_MIGRATION = PATH_TOOLS + "マテリアルを最新に変換する";
        public const string TOOLS_MIGALL = PATH_TOOLS + "全てのマテリアルを最新に変換する";
        public const string TOOLS_DLSET = PATH_TOOLS + "シーンDL方向をマテリアルに焼き込む";
        public const string TOOLS_HIDELMAP = PATH_TOOLS + "ライトマップを一時的に非表示 %&L";
        public const string TOOLS_VALIDATE = PATH_TOOLS + "シーン内のマテリアルを検査";

        public const string MATERIAL_AUTOCNV = PATH_MATERIAL + "UnlitWF のマテリアルに変換する";
        public const string MATERIAL_DEBUGVIEW = PATH_MATERIAL + "DebugView シェーダに切り替える";
        public const string MATERIAL_CNGMOBILE = PATH_MATERIAL + "モバイル向けシェーダに変換する";

        public const string GAMEOBJECT_CREANUP = PATH_GAMEOBJECT + "UnlitWFマテリアルのクリンナップ";
#else
        public const string ASSETS_AUTOCNV = PATH_ASSETS + "Convert UnlitWF Material";

        public const string ASSETS_DEBUGVIEW = PATH_ASSETS + "SwitchShader/Switch DebugView Shader";
        public const string ASSETS_CNGMOBILE = PATH_ASSETS + "SwitchShader/Change Mobile Shader";

        public const string ASSETS_CREANUP = PATH_ASSETS + "CleanUp Material Property";
        public const string ASSETS_COPY = PATH_ASSETS + "Copy Material Property";
        public const string ASSETS_RESET = PATH_ASSETS + "Reset Material Property";
        public const string ASSETS_MIGRATION = PATH_ASSETS + "Migration Material";
        public const string ASSETS_DLSET = PATH_ASSETS + "Bake DL into Material";

        public const string TOOLS_REIMPORT = PATH_TOOLS + "Reimport UnlitWF Shaders";
        public const string TOOLS_CREANUP = PATH_TOOLS + "CleanUp Material Property";
        public const string TOOLS_COPY = PATH_TOOLS + "Copy Material Property";
        public const string TOOLS_RESET = PATH_TOOLS + "Reset Material Property";
        public const string TOOLS_MIGRATION = PATH_TOOLS + "Migration Material";
        public const string TOOLS_MIGALL = PATH_TOOLS + "Migration All Materials";
        public const string TOOLS_DLSET = PATH_TOOLS + "Bake DL into Material";
        public const string TOOLS_HIDELMAP = PATH_TOOLS + "Hide LightMap temporarily %&L";
        public const string TOOLS_VALIDATE = PATH_TOOLS + "Validate Materials in Scene";

        public const string MATERIAL_AUTOCNV = PATH_MATERIAL + "Convert UnlitWF Material";
        public const string MATERIAL_DEBUGVIEW = PATH_MATERIAL + "Switch WF_DebugView Shader";
        public const string MATERIAL_CNGMOBILE = PATH_MATERIAL + "Change Mobile shader";

        public const string GAMEOBJECT_CREANUP = PATH_GAMEOBJECT + "CleanUp UnlitWF Material Property";
#endif

        public const string TOOLS_LNG_EN = PATH_TOOLS + "Menu Language Change To English";
        public const string TOOLS_LNG_JP = PATH_TOOLS + "メニューの言語を日本語にする";

        public const int PRI_ASSETS_AUTOCNV = 2101;
        public const int PRI_ASSETS_DEBUGVIEW = 2202;
        public const int PRI_ASSETS_CNGMOBILE = 2203;
        public const int PRI_ASSETS_CREANUP = 2304;
        public const int PRI_ASSETS_COPY = 2305;
        public const int PRI_ASSETS_RESET = 2306;
        public const int PRI_ASSETS_MIGRATION = 2307;
        public const int PRI_ASSETS_DLSET = 2308;

        public const int PRI_TOOLS_REIMPORT = 101;
        public const int PRI_TOOLS_CREANUP = 201;
        public const int PRI_TOOLS_COPY = 202;
        public const int PRI_TOOLS_RESET = 203;
        public const int PRI_TOOLS_MIGRATION = 204;
        public const int PRI_TOOLS_VALIDATE = 205;
        public const int PRI_TOOLS_DLSET = 206;
        public const int PRI_TOOLS_HIDELMAP = 301;
        public const int PRI_TOOLS_MIGALL = 401;
        public const int PRI_TOOLS_CNGLANG = 501;

        public const int PRI_MATERIAL_AUTOCNV = 1654;
        public const int PRI_MATERIAL_DEBUGVIEW = 1655;
        public const int PRI_MATERIAL_CNGMOBILE = 1656;

        #region Convert UnlitWF material

        [MenuItem(WFMenu.MATERIAL_AUTOCNV, priority = WFMenu.PRI_MATERIAL_AUTOCNV)]
        private static void ContextMenu_AutoConvertMaterial(MenuCommand cmd)
        {
            new Converter.WFMaterialFromOtherShaderConverter().ExecAutoConvert(cmd.context as Material);
        }

        [MenuItem(WFMenu.ASSETS_AUTOCNV, priority = WFMenu.PRI_ASSETS_AUTOCNV)]
        private static void Menu_AutoConvertMaterial()
        {
            var converter = new Converter.WFMaterialFromOtherShaderConverter();
            Undo.SetCurrentGroupName("WF " + converter.GetShortName());

            var seeker = new MaterialSeeker();
            seeker.progressBarTitle = WFCommonUtility.DialogTitle;
            seeker.progressBarText = "Convert Materials...";
            seeker.progressBarSpan = 2;
            seeker.VisitAllMaterialsInSelection(MatSelectMode.FromAssetDeep, mat => converter.ExecAutoConvert(mat) != 0);
        }

        #endregion

        #region Migration

        [MenuItem(WFMenu.TOOLS_MIGALL, priority = WFMenu.PRI_TOOLS_MIGALL)]
        private static void Menu_ScanAndAllMigration()
        {
            Converter.ScanAndMigrationExecutor.ExecuteScanByManual();
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
            foreach (var mat in new MaterialSeeker().GetAllMaterialsInSelection(MatSelectMode.FromAsset))
            {
                WFCommonUtility.ChangeShader(WF_DebugViewEditor.SHADER_NAME_DEBUGVIEW, mat);
            }
        }

        #endregion

        #region Change Mobile Shader

        [MenuItem(WFMenu.MATERIAL_CNGMOBILE, priority = WFMenu.PRI_MATERIAL_CNGMOBILE)]
        private static void ContextMenu_ChangeMobileShader(MenuCommand cmd)
        {
            if (!EditorUtility.DisplayDialog(WFCommonUtility.DialogTitle, WFI18N.Translate(WFMessageText.DgChangeMobile), "OK", "Cancel"))
            {
                return;
            }
            new Converter.WFMaterialToMobileShaderConverter().ExecAutoConvert(cmd.context as Material);
        }

        [MenuItem(WFMenu.ASSETS_CNGMOBILE, priority = WFMenu.PRI_ASSETS_CNGMOBILE)]
        private static void Menu_ChangeMobileShader()
        {
            if (!EditorUtility.DisplayDialog(WFCommonUtility.DialogTitle, WFI18N.Translate(WFMessageText.DgChangeMobile), "OK", "Cancel"))
            {
                return;
            }
            var converter = new Converter.WFMaterialToMobileShaderConverter();
            Undo.SetCurrentGroupName("WF " + converter.GetShortName());

            var seeker = new MaterialSeeker();
            seeker.progressBarTitle = WFCommonUtility.DialogTitle;
            seeker.progressBarText = "Convert Materials...";
            seeker.progressBarSpan = 2;
            seeker.VisitAllMaterialsInSelection(MatSelectMode.FromAssetDeep, mat => converter.ExecAutoConvert(mat) != 0);
        }

        #endregion

        #region Change Lang

#if WF_ML_JP
        [MenuItem(TOOLS_LNG_EN, priority = WFMenu.PRI_TOOLS_CNGLANG)]
        private static void Menu_ChangeLang()
        {
            if (!EditorUtility.DisplayDialog(WFCommonUtility.DialogTitle, "Do you want to switch the menu about UnlitWF to English?\nIt may take a few minutes to switch.", "OK", "Cancel"))
            {
                return;
            }
            BuildTargetGroup currentTarget = EditorUserBuildSettings.selectedBuildTargetGroup;
            var symbols = new List<string>(PlayerSettings.GetScriptingDefineSymbolsForGroup(currentTarget).Split(';'));
            symbols.Remove("WF_ML_JP");
            PlayerSettings.SetScriptingDefineSymbolsForGroup(currentTarget, string.Join(";", symbols));
        }
#else
        [MenuItem(TOOLS_LNG_JP, priority = WFMenu.PRI_TOOLS_CNGLANG)]
        private static void Menu_ChangeLang()
        {
            if (!EditorUtility.DisplayDialog(WFCommonUtility.DialogTitle, "UnlitWF に関するメニューを日本語にしますか？\n切り替えには数分の時間がかかる場合があります。", "OK", "Cancel"))
            {
                return;
            }
            BuildTargetGroup currentTarget = EditorUserBuildSettings.selectedBuildTargetGroup;
            var symbols = new List<string>(PlayerSettings.GetScriptingDefineSymbolsForGroup(currentTarget).Split(';'));
            symbols.Remove("WF_ML_JP");
            symbols.Add("WF_ML_JP");
            PlayerSettings.SetScriptingDefineSymbolsForGroup(currentTarget, string.Join(";", symbols));
        }
#endif

        #endregion

        #region Hide Lightmap

        [MenuItem(TOOLS_HIDELMAP, priority = PRI_TOOLS_HIDELMAP)]
        private static void Menu_HideLightmap()
        {
            var hideLmap = WFCommonUtility.IsKwdEnableHideLmap();
            WFCommonUtility.SetKwdEnableHideLmap(!hideLmap);
        }

        [MenuItem(TOOLS_HIDELMAP, true)]
        private static bool MenuValidation_HideLightmap()
        {
            var hideLmap = WFCommonUtility.IsKwdEnableHideLmap();
            Menu.SetChecked(TOOLS_HIDELMAP, hideLmap);
            return true;
        }

        #endregion

        [MenuItem(WFMenu.ASSETS_DEBUGVIEW, validate = true)]
        private static bool MenuValidation_HasMaterials()
        {
            return Selection.GetFiltered<Material>(SelectionMode.Assets).Length != 0;
        }

        #region Reimport Shaders

        [MenuItem(TOOLS_REIMPORT, priority = PRI_TOOLS_REIMPORT)]
        private static void Menu_ReloadShaders()
        {
            var folders = GetWFPackageFolders();
            if (folders.Length == 0)
            {
                return;
            }
            AssetDatabase.StartAssetEditing();
            try
            {
                foreach (var path in AssetDatabase.FindAssets("t:Shader", folders).Select(AssetDatabase.GUIDToAssetPath).Where(path => !string.IsNullOrWhiteSpace(path)))
                {
                    AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.DontDownloadFromCacheServer);
                }
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
            }
        }

        private static string[] GetWFPackageFolders()
        {
            var folders = new List<string>();
            if (AssetDatabase.LoadAssetAtPath<DefaultAsset>("Packages/jp.whiteflare.unlitwf") != null)
            {
                folders.Add("Packages/jp.whiteflare.unlitwf");
            }
            else
            {
                folders.AddRange(AssetDatabase.FindAssets("Unlit_WF_ShaderSuite").Select(AssetDatabase.GUIDToAssetPath).Where(path => !string.IsNullOrWhiteSpace(path)));
            }
            return folders.ToArray();
        }

        #endregion
    }

    static class ToolCommon
    {
        public static readonly Texture2D infoIcon = EditorGUIUtility.Load("icons/console.infoicon.png") as Texture2D;
        public static readonly Texture2D warnIcon = EditorGUIUtility.Load("icons/console.warnicon.png") as Texture2D;

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

        public static Material[] FilterOnlyNotWFMaterial(Material[] array)
        {
            return array.Where(mat => IsNotUnlitWFMaterial(mat)).ToArray();
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
            arguments.AddRange(new MaterialSeeker().GetAllMaterialsInSelection(mode));
        }

        public static void SetMaterials(Material[] mats)
        {
            arguments.Clear();
            arguments.AddRange(mats);
        }

        public static void GetSelectedMaterials(ref Material[] array)
        {
            if (0 < arguments.Count)
            {
                array = arguments.Distinct().Where(mat => mat != null).OrderBy(mat => mat.name).ToArray();
                arguments.Clear();
            }
        }

        public static void MaterialProperty(UnityEngine.Object obj, string name)
        {
            var so = new SerializedObject(obj);
            so.Update();

            SerializedProperty property = so.FindProperty(name);
            if (property == null)
            {
                return;
            }

            EditorGUI.BeginChangeCheck();
            if (property.isArray)
            {
                // 複数行マテリアルフィールド
                EditorGUILayout.PropertyField(property, new GUIContent("list (" + property.arraySize + ")"), true);
            }
            else
            {
                // 1行マテリアルフィールド
                EditorGUILayout.PropertyField(property, new GUIContent("material"), true);
            }
            if (EditorGUI.EndChangeCheck())
            {
                so.ApplyModifiedPropertiesWithoutUndo();
                so.SetIsDifferentCacheDirty();
            }
        }

        public static void SetArrayPropertyExpanded(UnityEngine.Object obj, string name)
        {
            var so = new SerializedObject(obj);
            so.Update();

            SerializedProperty property = so.FindProperty(name);
            if (property == null || !property.isArray)
            {
                return;
            }
            property.isExpanded = property.arraySize <= 10;
        }

        public static GUIContent GetMessageContent(MessageType type, string msg)
        {
            switch(type)
            {
                case MessageType.Warning:
                    return new GUIContent(msg, warnIcon);
                case MessageType.Info:
                    return new GUIContent(msg, infoIcon);
                default:
                    return new GUIContent(msg);
            }
        }

        public static void SetupSize(EditorWindow window)
        {
            window.minSize = new Vector2(480, 640);
        }
    }

    #region クリンナップ系

    class ToolCreanUpWindow : EditorWindow
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
            if (Selection.GetFiltered<GameObject>(SelectionMode.Unfiltered).Length == 0)
            {
                ToolCommon.SetMaterials(new MaterialSeeker().GetAllMaterialsInScene().ToArray());
            }
            else
            {
                ToolCommon.SetSelectedMaterials(MatSelectMode.FromScene);
            }
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
        }

        [MenuItem(WFMenu.TOOLS_CREANUP, priority = WFMenu.PRI_TOOLS_CREANUP)]
        private static void OpenWindowFromMenu_Tool()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromSceneOrAsset);
            GetWindow<ToolCreanUpWindow>("UnlitWF/CleanUp material property");
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
            ToolCommon.SetupSize(this);
            param = CleanUpParameter.Create();
            param.execNonWFMaterials = true; // ツール経由のときはNonWFマテリアルのクリンナップも行う
            ToolCommon.GetSelectedMaterials(ref param.materials);
            ToolCommon.SetArrayPropertyExpanded(param, nameof(param.materials));
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / CleanUp material property", "CleanUp disabled values", "materialsから無効化されている機能の設定値をクリアします。");

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            ToolCommon.MaterialProperty(param, nameof(param.materials));
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);
            EditorGUILayout.Space();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther)
            {
                param.materials = ToolCommon.FilterOnlyWFMaterial(param.materials);
            }

            // マテリアルにUnlitWF以外のシェーダが紛れている場合は追加の情報を表示
            if (param.materials.Any(ToolCommon.IsNotUnlitWFMaterial))
            {
                EditorGUILayout.Space();
                EditorGUILayout.HelpBox("UnlitWF以外のマテリアルは、未使用の値のみ除去します。", MessageType.Info);
                EditorGUILayout.Space();
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

    class ToolResetWindow : EditorWindow
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
            ToolCommon.SetupSize(this);
            param = ResetParameter.Create();
            ToolCommon.GetSelectedMaterials(ref param.materials);
            ToolCommon.SetArrayPropertyExpanded(param, nameof(param.materials));
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / Reset material property", "Reset properties", "materialsの設定値を初期化します。");

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            ToolCommon.MaterialProperty(param, nameof(param.materials));
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);

            EditorGUILayout.Space();

            // 対象(種類から)
            EditorGUILayout.LabelField("Reset by Type", EditorStyles.boldLabel);
            param.resetColor = GUILayout.Toggle(param.resetColor, "Color (色) をデフォルトに戻す");
            param.resetTexture = GUILayout.Toggle(param.resetTexture, "Texture (テクスチャ) をデフォルトに戻す");
            param.resetFloat = GUILayout.Toggle(param.resetFloat, "Float (数値) をデフォルトに戻す");

            EditorGUILayout.Space();

            // 対象(機能から)
            EditorGUILayout.LabelField("Reset by Function", EditorStyles.boldLabel);
            param.resetColorAlpha = GUILayout.Toggle(param.resetColorAlpha, "Color (色) の Alpha を 1.0 にする");
            param.resetLit = GUILayout.Toggle(param.resetLit, "Lit & Lit Advance の設定をデフォルトに戻す");

            EditorGUILayout.Space();

            // オプション
            EditorGUILayout.LabelField("options", EditorStyles.boldLabel);
            param.resetUnused = GUILayout.Toggle(param.resetUnused, "UnUsed Properties (未使用の値) も一緒にクリアする");
            param.resetKeywords = GUILayout.Toggle(param.resetKeywords, "ShaderKeywords (Shaderキーワード) も一緒にクリアする");

            EditorGUILayout.Space();

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

    class ToolCopyWindow : EditorWindow
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
            ToolCommon.SetupSize(this);
            param = CopyPropParameter.Create();
            ToolCommon.GetSelectedMaterials(ref param.materialDestination);
            ToolCommon.SetArrayPropertyExpanded(param, nameof(param.materialDestination));
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / Copy material property", "Copy properties", "source material の設定値を destination materials にコピーします。");

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("destination materials", EditorStyles.boldLabel);
            ToolCommon.MaterialProperty(param, nameof(param.materialDestination));
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materialDestination);
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("source materials", EditorStyles.boldLabel);
            ToolCommon.MaterialProperty(param, nameof(param.materialSource));
            EditorGUILayout.Space();

            ToolCommon.NoticeIfIllegalMaterials(new Material[] { param.materialSource }, false);
            EditorGUILayout.Space();

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

    class ToolMigrationWindow : EditorWindow
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
            ToolCommon.SetupSize(this);
            param = MigrationParameter.Create();
            ToolCommon.GetSelectedMaterials(ref param.materials);
            ToolCommon.SetArrayPropertyExpanded(param, nameof(param.materials));
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / Migration material", "Migration materials", "古いバージョンのUnlitWFで設定されたmaterialsを最新版に変換します。");

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            ToolCommon.MaterialProperty(param, nameof(param.materials));
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);
            EditorGUILayout.Space();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther)
            {
                param.materials = ToolCommon.FilterOnlyWFMaterial(param.materials);
            }

            if (ToolCommon.ExecuteButton("Convert", param.materials.Length == 0))
            {
                // 変換
                WFMaterialEditUtility.MigrationMaterial(param);
                // 変更したマテリアルを保存
                AssetDatabase.SaveAssets();
            }

            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion

    #region DL焼き込み系

    class ToolDirectionalSetWindow : EditorWindow
    {

#if ENV_VRCSDK3_WORLD
        [MenuItem(WFMenu.ASSETS_DLSET, priority = WFMenu.PRI_ASSETS_DLSET)]
        private static void OpenWindowFromMenu_Asset()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromAssetDeep);
            GetWindow<ToolDirectionalSetWindow>("UnlitWF/DirectionalLight Setting");
        }

        [MenuItem(WFMenu.TOOLS_DLSET, priority = WFMenu.PRI_TOOLS_DLSET)]
        private static void OpenWindowFromMenu_Tool()
        {
            ToolCommon.SetSelectedMaterials(MatSelectMode.FromSceneOrAsset);
            GetWindow<ToolDirectionalSetWindow>("UnlitWF/DirectionalLight Setting");
        }
#endif

        Vector2 scroll = Vector2.zero;
        private Light directionalLight;
        [SerializeField]
        private Material[] materials = { };

        private void OnEnable()
        {
            ToolCommon.SetupSize(this);
            directionalLight = RenderSettings.sun;
            ToolCommon.GetSelectedMaterials(ref materials);
            ToolCommon.SetArrayPropertyExpanded(this, nameof(this.materials));
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / DirectionalLight Setting", "DirectionalLight Setting", "マテリアルにシーン DirectionalLight を焼き込みます。");

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // DirectionalLight
            directionalLight = (Light)EditorGUILayout.ObjectField("Directional Light", directionalLight, typeof(Light), true);
            if (directionalLight != null && directionalLight.type != LightType.Directional)
            {
                EditorGUILayout.HelpBox(string.Format("{0} is NOT DirectionalLight.", directionalLight), MessageType.Warning);
            }
            EditorGUILayout.Space();

            // マテリアルリスト
            EditorGUILayout.LabelField("materials", EditorStyles.boldLabel);
            ToolCommon.MaterialProperty(this, nameof(this.materials));
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(materials);
            EditorGUILayout.Space();

            // UnlitWF 以外のマテリアルを除去
            if (removeOther)
            {
                materials = ToolCommon.FilterOnlyWFMaterial(materials);
            }

            if (ToolCommon.ExecuteButton("Bake DirectionalLight", directionalLight == null || directionalLight.type != LightType.Directional || materials.Length == 0))
            {
                // 実行
                ExecuteDLBake();
                // 変更したマテリアルを保存
                AssetDatabase.SaveAssets();
            }

            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }

        private void ExecuteDLBake()
        {
            var lightWorldDir = directionalLight.transform.TransformVector(new Vector3(0, 0, 1));
            var azm = Mathf.RoundToInt(Mathf.Rad2Deg * Mathf.Atan2(lightWorldDir.x, lightWorldDir.z));
            if (azm < 0)
            {
                azm += 360;
            }
            var alt = Mathf.Rad2Deg * -Mathf.Atan2(lightWorldDir.y, new Vector2(lightWorldDir.x, lightWorldDir.z).magnitude);

            var targets = WFCommonUtility.AsMaterials(materials);
            Undo.RecordObjects(targets, "Bake DirectionalLight");
            foreach (var mat in targets)
            {
                if (!WFCommonUtility.IsSupportedShader(mat))
                {
                    continue;
                }
                mat.SetInt("_GL_LightMode", 3); // CUSTOM_WORLD_DIR
                mat.SetFloat("_GL_CustomAzimuth", azm);
                mat.SetFloat("_GL_CustomAltitude", alt);
                EditorUtility.SetDirty(mat);
            }
        }
    }

    #endregion

    #region バリデート系

    class ToolValidateSceneMaterial : EditorWindow
    {
        [MenuItem(WFMenu.TOOLS_VALIDATE, priority = WFMenu.PRI_TOOLS_VALIDATE)]
        private static void OpenWindowFromMenu_Tool()
        {
            var window = GetWindow<ToolValidateSceneMaterial>("UnlitWF/Material Validation");
            window.rootObject = Selection.activeGameObject;
        }

        Vector2 scroll = Vector2.zero;
        private GameObject rootObject;

        private void OnEnable()
        {
            ToolCommon.SetupSize(this);
        }

        private void OnGUI()
        {
            ToolCommon.WindowHeader("UnlitWF / Material Validation", "List material validation result", "UnlitWF のマテリアルの警告を一覧表示します。");

            rootObject = EditorGUILayout.ObjectField("Root GameObject", rootObject, typeof(GameObject), true) as GameObject;

            var materials = rootObject != null ? new MaterialSeeker().GetAllMaterials(rootObject).Distinct().ToArray() : new MaterialSeeker().GetAllMaterialsInScene().Distinct().ToArray();
            var advices = WFMaterialValidators.ValidateAll(materials);

            if (advices.Count == 0)
            {
                EditorGUILayout.Space();
                EditorGUILayout.HelpBox("問題は見つかりませんでした。 / No problems were found.", MessageType.Info, true);
                return;
            }

            // スクロール開始
            scroll = EditorGUILayout.BeginScrollView(scroll);

            foreach (var advice in advices)
            {
                EditorGUILayout.Space();
                GUILayout.Box("", GUILayout.ExpandWidth(true), GUILayout.Height(1));
                EditorGUILayout.Space();

                var messageContent = ToolCommon.GetMessageContent(advice.messageType, advice.message);
                var contentRect = GUILayoutUtility.GetRect(messageContent, EditorStyles.label);
                GUI.Label(contentRect, messageContent);

                var exec = false;

                if (advice.action != null)
                {
                    var buttonContent = new GUIContent("Fix Now");
                    var buttonRect = GUILayoutUtility.GetRect(1, 25);
                    buttonRect = new Rect(buttonRect.xMax - 64, buttonRect.y, 60, 20);
                    exec = GUI.Button(buttonRect, buttonContent);
                }

                using (new EditorGUI.IndentLevelScope())
                using (new EditorGUI.DisabledGroupScope(true))
                {
                    for (int i = 0; i < advice.targets.Length; i++)
                    {
                        EditorGUILayout.ObjectField("Material " + i, advice.targets[i], typeof(Material), false);
                    }
                }

                if (exec)
                {
                    advice.action();
                }
            }
            EditorGUILayout.Space();

            // スクロール終了
            EditorGUILayout.EndScrollView();
        }
    }

    #endregion
}

#endif
