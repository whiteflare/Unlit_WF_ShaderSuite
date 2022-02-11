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
using System.Text.RegularExpressions;
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
            var mats = MaterialSeeker.GetSelectionAllMaterial(MatSelectMode.FromAssetDeep);
            new WFMaterialFromOtherShaderConverter().ExecAutoConvert(mats.ToArray());
        }

        [MenuItem(WFMenu.MATERIAL_AUTOCNV, priority = WFMenu.PRI_MATERIAL_AUTOCNV)]
        private static void ContextMenu_AutoConvertMaterial(MenuCommand cmd)
        {
            new WFMaterialFromOtherShaderConverter().ExecAutoConvert(cmd.context as Material);
        }

        #endregion

        #region Migration

        [MenuItem(WFMenu.ASSETS_MIGALL, priority = WFMenu.PRI_ASSETS_MIGALL)]
        [MenuItem(WFMenu.TOOLS_MIGALL, priority = WFMenu.PRI_TOOLS_MIGALL)]
        private static void Menu_ScanAndAllMigration()
        {
            ScanAndMigrationExecutor.ExecuteByManual();
        }

        #endregion

        #region Keep materials

        [MenuItem(WFMenu.ASSETS_KEEPMAT, priority = WFMenu.PRI_ASSETS_KEEPMAT)]
        private static void Menu_KeepMaterialInScene()
        {
            var mats = MaterialSeeker.GetSelectionAllMaterial(MatSelectMode.FromAsset);

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
            foreach (var mat in MaterialSeeker.GetSelectionAllMaterial(MatSelectMode.FromAsset))
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
            var mats = MaterialSeeker.GetSelectionAllMaterial(MatSelectMode.FromAssetDeep);
            ChangeMobileShader(mats.ToArray());
        }

        private static void ChangeMobileShader(params Material[] mats)
        {
            if (0 < mats.Length && EditorUtility.DisplayDialog("WF change Mobile shader", WFI18N.Translate(WFMessageText.DgChangeMobile), "OK", "Cancel"))
            {
                new WFMaterialToMobileShaderConverter().ExecAutoConvert(mats);
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
            arguments.AddRange(MaterialSeeker.GetSelectionAllMaterial(mode));
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
            EditorGUILayout.PropertyField(so.FindProperty("materials"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);
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
            EditorGUILayout.PropertyField(so.FindProperty("materials"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materials);

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
            EditorGUILayout.PropertyField(so.FindProperty("materialDestination"), new GUIContent("list"), true);
            EditorGUILayout.Space();

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            bool removeOther = ToolCommon.NoticeIfIllegalMaterials(param.materialDestination);
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("source materials", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(so.FindProperty("materialSource"), new GUIContent("material"), true);
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
            EditorGUILayout.PropertyField(so.FindProperty("materials"), new GUIContent("list"), true);
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

    public abstract class AbstractMaterialConverter
    {
        private readonly List<Action<ConvertContext>> converters;

        protected AbstractMaterialConverter(List<Action<ConvertContext>> converters)
        {
            this.converters = converters;
        }

        public void ExecAutoConvert(params Material[] mats)
        {
            Undo.RecordObjects(mats, "WF Convert materials");
            ExecAutoConvertWithoutUndo(mats);
        }

        public void ExecAutoConvertWithoutUndo(params Material[] mats)
        {
            foreach (var mat in mats)
            {
                if (mat == null)
                {
                    continue;
                }
                if (!Validate(mat))
                {
                    continue;
                }

                var ctx = new ConvertContext();
                ctx.target = mat;
                ctx.oldMaterial = new Material(mat);
                ctx.oldProps = ShaderSerializedProperty.AsDict(ctx.oldMaterial);

                foreach (var cnv in converters)
                {
                    cnv(ctx);
                }
                Debug.LogFormat("[WF] Convert {0}: {1} -> {2}", ctx.target, ctx.oldMaterial.shader.name, ctx.target.shader.name);
            }
        }

        protected virtual bool Validate(Material mat)
        {
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

        protected static bool IsMatchShaderName(ConvertContext ctx, string name)
        {
            return IsMatchShaderName(ctx.oldMaterial.shader, name);
        }

        protected static bool IsMatchShaderName(Shader shader, string name)
        {
            return new Regex(".*" + name + ".*", RegexOptions.IgnoreCase).IsMatch(shader.name);
        }

        private static bool hasCustomValue(Dictionary<string, ShaderSerializedProperty> props, string name)
        {
            if (props.TryGetValue(name, out var prop))
            {
                switch (prop.Type)
                {
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

        protected static bool HasCustomValue(ConvertContext ctx, params string[] names)
        {
            var newProp = ShaderSerializedProperty.AsDict(ctx.target);

            foreach (var name in names)
            {
                // 新しいマテリアルから設定されていないかを調べる
                if (hasCustomValue(newProp, name))
                {
                    return true;
                }
                // 古いマテリアルの側から設定されていないかを調べる
                if (hasCustomValue(ctx.oldProps, name))
                {
                    return true;
                }
            }
            return false;
        }

        protected static bool IsURP()
        {
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
        public WFMaterialToMobileShaderConverter() : base(CreateConverterList())
        {
        }

        protected override bool Validate(Material mat)
        {
            // UnlitWFのマテリアルを対象に、URPではない場合に変換する
            return WFCommonUtility.IsSupportedShader(mat) && !WFCommonUtility.IsMobileSupportedShader(mat) && !IsURP();
        }

        protected static List<Action<ConvertContext>> CreateConverterList()
        {
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
                ctx => {
                    if (IsMatchShaderName(ctx.oldMaterial.shader, "Transparent3Pass") && !IsMatchShaderName(ctx.target.shader, "Transparent3Pass")) {
                        // Transparent3Pass からそうではないシェーダの切り替えでは、_AL_ZWrite を ON に変更する
                        ctx.target.SetInt("_AL_ZWrite", 1);
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
        public WFMaterialFromOtherShaderConverter() : base(CreateConverterList())
        {
        }

        protected override bool Validate(Material mat)
        {
            // UnlitWF系ではないマテリアルを対象に処理する
            return !WFCommonUtility.IsSupportedShader(mat);
        }

        protected static List<Action<ConvertContext>> CreateConverterList()
        {
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
                    if (IsMatchShaderName(ctx, "InternalErrorShader")) {
                        return;
                    }
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
                    // _ClippingMask の有無からシェーダタイプを判定する
                    if (ctx.renderType == ShaderType.NoMatch) {
                        if (HasCustomValue(ctx, "_ClippingMask")) {
                            ctx.renderType = ShaderType.Cutout;
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
                        if (!HasCustomValue(ctx, "_TS_BaseTex")) {
                            ctx.target.SetTexture("_TS_BaseTex", ctx.target.GetTexture("_MainTex"));
                        }
                        if (!HasCustomValue(ctx, "_TS_1stTex")) {
                            ctx.target.SetTexture("_TS_1stTex", ctx.target.GetTexture("_TS_BaseTex"));
                        }
                        if (!HasCustomValue(ctx, "_TS_2ndTex")) {
                            ctx.target.SetTexture("_TS_2ndTex", ctx.target.GetTexture("_TS_1stTex"));
                        }
                        if (!HasCustomValue(ctx, "_TS_3rdTex")) {
                            ctx.target.SetTexture("_TS_3rdTex", ctx.target.GetTexture("_TS_2ndTex"));
                        }
                        // ただし _TS_BaseTex, _TS_1stTex, _TS_2ndTex, _TS_3rdTex が全て同じ Texture を指しているならば全てクリアする
                        if (ctx.target.GetTexture("_TS_BaseTex") == ctx.target.GetTexture("_TS_1stTex")
                            && ctx.target.GetTexture("_TS_1stTex") == ctx.target.GetTexture("_TS_2ndTex")
                            && ctx.target.GetTexture("_TS_2ndTex") == ctx.target.GetTexture("_TS_3rdTex")) {
                            ctx.target.SetTexture("_TS_BaseTex", null);
                            ctx.target.SetTexture("_TS_1stTex", null);
                            ctx.target.SetTexture("_TS_2ndTex", null);
                            ctx.target.SetTexture("_TS_3rdTex", null);
                        }
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

    public static class ScanAndMigrationExecutor
    {
        public const int VERSION = 1;
        private static readonly string KEY_MIG_VERSION = "UnlitWF.ShaderEditor/autoMigrationVersion";

        public static void ExecuteAuto()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                // 実行中は何もしない
                return;
            }
            if (VERSION <= GetCurrentMigrationVersion())
            {
                // バージョンが新しいなら何もしない
                return;
            }
            if (!WFEditorSetting.GetOneOfSettings().enableScanProjects)
            {
                // 設定で無効化されているならば何もしない
                return;
            }

            var msg = WFI18N.Translate(WFMessageText.DgMigrationAuto);
            var lang = WFEditorPrefs.LangMode;
            var ok = lang == EditorLanguage.日本語 ? "実行する" : "Go Ahead";
            var cancel = lang == EditorLanguage.日本語 ? "結構です" : "No Thanks";
            var alt = lang == EditorLanguage.日本語 ? "後で聞いて" : "Ask Me Later";

            switch (EditorUtility.DisplayDialogComplex("WF migration materials", msg, ok, cancel, alt))
            {
                case 0:
                    // 実行してバージョン上書き
                    ScanAndMigration();
                    break;
                case 1:
                    // 実行せずバージョン上書き
                    break;
                case 2:
                    // あとで確認する
                    return;
            }

            // Setting の中のバージョンを上書き
            SaveCurrentMigrationVersion();
        }

        public static void ExecuteByManual()
        {
            var msg = WFI18N.Translate(WFMessageText.DgMigrationManual);
            var lang = WFEditorPrefs.LangMode;
            var ok = lang == EditorLanguage.日本語 ? "実行する" : "Go Ahead";
            var cancel = lang == EditorLanguage.日本語 ? "結構です" : "No Thanks";
            if (EditorUtility.DisplayDialog("WF migration materials", msg, ok, cancel))
            {
                ScanAndMigration();
                SaveCurrentMigrationVersion();
            }
        }

        public static int GetCurrentMigrationVersion()
        {
            if (int.TryParse(EditorUserSettings.GetConfigValue(KEY_MIG_VERSION) ?? "0", out var version))
            {
                return version;
            }
            return 0;
        }

        public static void SaveCurrentMigrationVersion()
        {
            EditorUserSettings.SetConfigValue(KEY_MIG_VERSION, VERSION.ToString());
        }

        public static void ScanAndMigration()
        {
            // Go Ahead
            var done = MaterialSeeker.SeekProjectAllMaterial("migration materials", Migration);
            if (0 < done)
            {
                AssetDatabase.SaveAssets();
                Debug.LogFormat("[WF] Scan And Migration {0} materials", done);
            }
        }

        public static bool Migration(string[] paths)
        {
            bool result = false;
            foreach (var path in paths)
            {
                result |= Migration(path);
            }
            return result;
        }

        public static bool Migration(string path)
        {
            if (string.IsNullOrWhiteSpace(path) || !path.EndsWith(".mat"))
            {
                return false;
            }
            var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
            return Migration(mat);
        }

        private static bool Migration(Material mat)
        {
            if (!WFCommonUtility.IsSupportedShader(mat))
            {
                return false;
            }
            WFMaterialEditUtility.MigrationMaterialWithoutUndo(mat);
            return true;
        }
    }
}

#endif
