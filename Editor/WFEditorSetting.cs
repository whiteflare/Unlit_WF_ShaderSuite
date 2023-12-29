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

using System.Linq;
using UnityEngine;
using UnityEditor;

namespace UnlitWF
{
    // [CreateAssetMenu(menuName = "UnlitWF/EditorSettingAsset")]
    public class WFEditorSetting : ScriptableObject
    {
        public int settingPriority = 0;

        /// <summary>
        /// ShaderStripping を有効にする
        /// </summary>
        [Header("Shader Build Settings")]
        public bool enableStripping = true;

        /// <summary>
        /// ShaderStripping にて未使用バリアントを削除する
        /// </summary>
        public bool stripUnusedVariant = true;

        /// <summary>
        /// ShaderStripping にてFallbackシェーダを削除する
        /// </summary>
        public bool stripFallback = true;

        /// <summary>
        /// ShaderStripping にてMetaパスを削除する
        /// </summary>
        public bool stripMetaPass = true;

        /// <summary>
        /// ShaderStripping にてLODGroupを使っていないなら対象コードを削除する
        /// </summary>
        public bool stripUnusedLodFade = true;

        /// <summary>
        /// ビルド時に古いマテリアルが含まれていないか検査する
        /// </summary>
        public bool validateSceneMaterials = true;

        /// <summary>
        /// アバタービルド前にマテリアルをクリンナップする
        /// </summary>
        public bool cleanupMaterialsBeforeAvatarBuild = true;

        /// <summary>
        /// shaderインポート時にプロジェクトをスキャンする
        /// </summary>
        [Header("Editor Behaviour Settings")]
        public bool enableScanProjects = true;

        /// <summary>
        /// materialインポート時にマイグレーションする
        /// </summary>
        public bool enableMigrationWhenImport = true;

        /// <summary>
        /// Quest向けシーンビルド時にMobile非対応シェーダを対応シェーダに置換する
        /// </summary>
        [Header("Quest Build Support")]
        public bool autoSwitchQuestShader = true;

        public NearClipCancelMode enableNccInVRC3Avatar = NearClipCancelMode.ForceON;

        public NearClipCancelMode enableNccInVRC3World = NearClipCancelMode.ForceOFF;

        private static WFEditorSetting currentSettings = null;
        private static int currentPriority = 0;

        public static WFEditorSetting GetOneOfSettings(bool forceReload = false)
        {
            if (forceReload)
            {
                currentSettings = null;
            }
            if (currentSettings != null && currentSettings.settingPriority == currentPriority)
            {
                return currentSettings;
            }

            var settings = LoadAllSettingsFromAssetDatabase();
            if (settings.Length == 0)
            {
                // 見つからないなら一時オブジェクトを作成して返却
                currentSettings = CreateInstance<WFEditorSetting>();
            }
            else
            {
                // Debug.LogFormat("[WF][Settings] Load Settings: {0}", AssetDatabase.GetAssetPath(settings[0]));
                currentSettings = settings[0];
            }
            currentPriority = currentSettings.settingPriority;
            return currentSettings;
        }

        private static WFEditorSetting[] LoadAllSettingsFromAssetDatabase()
        {
            // 検索
            var guids = AssetDatabase.FindAssets("t:" + typeof(WFEditorSetting).Name);

            // 読み込んで並べ替えて配列にして返却
            return guids.Select(guid => AssetDatabase.GUIDToAssetPath(guid))
                .Where(path => !string.IsNullOrWhiteSpace(path))
                .Select(path => AssetDatabase.LoadAssetAtPath<WFEditorSetting>(path))
                .Where(s => s != null)
                .OrderBy(s => s.settingPriority).ToArray();
        }
    }

    public enum NearClipCancelMode
    {
        PerMaterial = -1,
        ForceOFF = 0,
        ForceON = 1,
    }

    class WFEditorSettingReloader : AssetPostprocessor
    {
        public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromPath)
        {
            foreach (var path in importedAssets)
            {
                if (string.IsNullOrWhiteSpace(path))
                    continue;
                if (AssetDatabase.LoadAssetAtPath<WFEditorSetting>(path) == null)
                    continue;
                WFEditorSetting.GetOneOfSettings(true);
            }
        }
    }

    [CustomEditor(typeof(WFEditorSetting))]
    class WFEditorSettingEditor : Editor
    {
        SerializedProperty p_settingPriority;
        SerializedProperty p_enableStripping;
        SerializedProperty p_stripUnusedVariant;
        SerializedProperty p_stripFallback;
        SerializedProperty p_stripMetaPass;
        SerializedProperty p_stripUnusedLodFade;
        SerializedProperty p_validateSceneMaterials;
        SerializedProperty p_enableScanProjects;
        SerializedProperty p_cleanupMaterialsBeforeAvatarBuild;
        SerializedProperty p_enableMigrationWhenImport;
        SerializedProperty p_autoSwitchQuestShader;
        SerializedProperty p_enableNccInVRC3Avatar;
        SerializedProperty p_enableNccInVRC3World;

        private void OnEnable()
        {
            this.p_settingPriority = serializedObject.FindProperty(nameof(WFEditorSetting.settingPriority));

            // Shader Build Settings
            this.p_enableStripping = serializedObject.FindProperty(nameof(WFEditorSetting.enableStripping));
            this.p_stripUnusedVariant = serializedObject.FindProperty(nameof(WFEditorSetting.stripUnusedVariant));
            this.p_stripUnusedLodFade = serializedObject.FindProperty(nameof(WFEditorSetting.stripUnusedLodFade));
            this.p_stripFallback = serializedObject.FindProperty(nameof(WFEditorSetting.stripFallback));
            this.p_stripMetaPass = serializedObject.FindProperty(nameof(WFEditorSetting.stripMetaPass));

            this.p_validateSceneMaterials = serializedObject.FindProperty(nameof(WFEditorSetting.validateSceneMaterials));
            this.p_cleanupMaterialsBeforeAvatarBuild = serializedObject.FindProperty(nameof(WFEditorSetting.cleanupMaterialsBeforeAvatarBuild));

            // Editor Behaviour Settings
            this.p_enableScanProjects = serializedObject.FindProperty(nameof(WFEditorSetting.enableScanProjects));
            this.p_enableMigrationWhenImport = serializedObject.FindProperty(nameof(WFEditorSetting.enableMigrationWhenImport));

            // Quest Build Support
            this.p_autoSwitchQuestShader = serializedObject.FindProperty(nameof(WFEditorSetting.autoSwitchQuestShader));

            // EnableNCC
            this.p_enableNccInVRC3Avatar = serializedObject.FindProperty(nameof(WFEditorSetting.enableNccInVRC3Avatar));
            this.p_enableNccInVRC3World = serializedObject.FindProperty(nameof(WFEditorSetting.enableNccInVRC3World));
        }

        public override void OnInspectorGUI()
        {
            if (target == WFEditorSetting.GetOneOfSettings())
            {
                var msg = WFI18N.Translate("WFEditorSetting", "This is the current setting used.");
                EditorGUILayout.HelpBox(msg, MessageType.Info);
            }
            else
            {
                var msg = WFI18N.Translate("WFEditorSetting", "This is not the setting used now.");
                EditorGUILayout.HelpBox(msg, MessageType.Warning);
            }
            EditorGUILayout.Space();

            serializedObject.Update();

            // 優先度

            EditorGUILayout.PropertyField(p_settingPriority, toDisplay(p_settingPriority));

            // Shader Build Settings

            EditorGUILayout.PropertyField(p_enableStripping, toDisplay(p_enableStripping));
            using (new EditorGUI.DisabledGroupScope(!p_enableStripping.boolValue))
            using (new EditorGUI.IndentLevelScope())
            {
                EditorGUILayout.PropertyField(p_stripUnusedVariant, toDisplay(p_stripUnusedVariant));
                EditorGUILayout.PropertyField(p_stripUnusedLodFade, toDisplay(p_stripUnusedLodFade));
                EditorGUILayout.PropertyField(p_stripFallback, toDisplay(p_stripFallback));
                EditorGUILayout.PropertyField(p_stripMetaPass, toDisplay(p_stripMetaPass));
            }
            EditorGUILayout.PropertyField(p_validateSceneMaterials, toDisplay(p_validateSceneMaterials));
            EditorGUILayout.PropertyField(p_cleanupMaterialsBeforeAvatarBuild, toDisplay(p_cleanupMaterialsBeforeAvatarBuild));

            // Editor Behaviour Settings

            EditorGUILayout.PropertyField(p_enableScanProjects, toDisplay(p_enableScanProjects));
            EditorGUILayout.PropertyField(p_enableMigrationWhenImport, toDisplay(p_enableMigrationWhenImport));

            // Quest Build Support

            EditorGUILayout.PropertyField(p_autoSwitchQuestShader, toDisplay(p_autoSwitchQuestShader));

            // Common Material Settings

            EditorGUILayout.Space();
            GUI.Label(EditorGUILayout.GetControlRect(), "Common Material Settings", EditorStyles.boldLabel);

            EditorGUILayout.LabelField(WFI18N.Translate("WFEditorSetting", "Cancel Near Clipping"));
            using (new EditorGUI.IndentLevelScope())
            {
                EditorGUILayout.PropertyField(p_enableNccInVRC3Avatar, new GUIContent("For VRCSDK3 Avatar"));
                EditorGUILayout.PropertyField(p_enableNccInVRC3World, new GUIContent("For VRCSDK3 World"));
            }

            serializedObject.ApplyModifiedProperties();

            WFEditorPrefs.LangMode = (EditorLanguage)EditorGUILayout.EnumPopup("Editor language", WFEditorPrefs.LangMode);
        }

        private GUIContent toDisplay(SerializedProperty p)
        {
            var text = WFI18N.Translate("WFEditorSetting", p.displayName);
            var tooltip = p.tooltip;
            if (string.IsNullOrWhiteSpace(tooltip))
            {
                tooltip = text;
            }
            return new GUIContent(text, tooltip);
        }
    }
}

#endif
