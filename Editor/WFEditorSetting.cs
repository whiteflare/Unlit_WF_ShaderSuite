/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2026 whiteflare.
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

using System.Linq;
using UnityEngine;
using UnityEditor;

namespace UnlitWF
{
    // [CreateAssetMenu(menuName = "UnlitWF/EditorSettingAsset")]
    public class WFEditorSetting : ScriptableObject
    {
        public int settingPriority = 0;

        // ==================================================

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

        // ==================================================

        /// <summary>
        /// shaderインポート時にプロジェクトをスキャンする
        /// </summary>
        [Header("Editor Behaviour Settings")]
        public bool enableScanProjects = true;

        /// <summary>
        /// materialインポート時にマイグレーションする
        /// </summary>
        public bool enableMigrationWhenImport = true;

        // ==================================================

        /// <summary>
        /// Quest向けシーンビルド時にMobile非対応シェーダを対応シェーダに置換する
        /// </summary>
        [Header("Quest Build Support")]
        public bool autoSwitchQuestShader = true;

        // ==================================================

        /// <summary>
        /// カメラのニアクリップを無視(for VRC3Avatar)
        /// </summary>
        public MatForceSettingMode3 enableNccInVRC3Avatar = MatForceSettingMode3.ForceON;
        /// <summary>
        /// カメラのニアクリップを無視(for VRC3World)
        /// </summary>
        public MatForceSettingMode3 enableNccInVRC3World = MatForceSettingMode3.ForceOFF;
        /// <summary>
        /// カメラのニアクリップを無視(for OtherEnv)
        /// </summary>
        public MatForceSettingMode3 enableNccInOther= MatForceSettingMode3.PerMaterial;

        /// <summary>
        /// 逆光補正しない(for VRC3Avatar)
        /// </summary>
        public MatForceSettingMode3 disableBackLitInVRC3Avatar = MatForceSettingMode3.PerMaterial;
        /// <summary>
        /// 逆光補正しない(for VRC3World)
        /// </summary>
        public MatForceSettingMode3 disableBackLitInVRC3World = MatForceSettingMode3.ForceON;
        /// <summary>
        /// 逆光補正しない(for OtherEnv)
        /// </summary>
        public MatForceSettingMode3 disableBackLitInOther = MatForceSettingMode3.PerMaterial;

        /// <summary>
        /// CameraDepthTextureを使う(for VRC3Avatar)
        /// </summary>
        public MatForceSettingMode2 useDepthTexInVRC3Avatar = MatForceSettingMode2.ForceOFF;
        /// <summary>
        /// CameraDepthTextureを使う(for VRC3World)
        /// </summary>
        public MatForceSettingMode2 useDepthTexInVRC3World = MatForceSettingMode2.PerMaterial;
        /// <summary>
        /// CameraDepthTextureを使う(for OtherEnv)
        /// </summary>
        public MatForceSettingMode2 useDepthTexInOther = MatForceSettingMode2.PerMaterial;

        /// <summary>
        /// VRC LightVolumes を使う(for VRC3Avatar)
        /// </summary>
        public MatForceSettingMode3 enableULVInVRC3Avatar = MatForceSettingMode3.ForceON;
        /// <summary>
        /// VRC LightVolumes を使う(for VRC3World)
        /// </summary>
        public MatForceSettingMode3 enableULVInVRC3World = MatForceSettingMode3.PerMaterial;
        /// <summary>
        /// VRC LightVolumes を使う(for OtherEnv)
        /// </summary>
        public MatForceSettingMode3 enableULVInOther = MatForceSettingMode3.PerMaterial;

        // ==================================================

        private static WFEditorSetting currentSettings = null;
        private static int currentPriority = 0;

        // ==================================================

        public MatForceSettingMode3 GetEnableNccInCurrentEnvironment()
        {
            switch (WFCommonUtility.GetCurrentEntironment())
            {
                case CurrentEntironment.VRCSDK3_Avatar:
                    return enableNccInVRC3Avatar;
                case CurrentEntironment.VRCSDK3_World:
                    return enableNccInVRC3World;
                default:
                    return enableNccInOther;
            }
        }

        public MatForceSettingMode3 GetDisableBackLitInCurrentEnvironment()
        {
            switch (WFCommonUtility.GetCurrentEntironment())
            {
                case CurrentEntironment.VRCSDK3_Avatar:
                    return disableBackLitInVRC3Avatar;
                case CurrentEntironment.VRCSDK3_World:
                    return disableBackLitInVRC3World;
                default:
                    return disableBackLitInOther;
            }
        }

        public MatForceSettingMode2 GetUseDepthTexInCurrentEnvironment()
        {
            switch (WFCommonUtility.GetCurrentEntironment())
            {
                case CurrentEntironment.VRCSDK3_Avatar:
                    return useDepthTexInVRC3Avatar;
                case CurrentEntironment.VRCSDK3_World:
                    return useDepthTexInVRC3World;
                default:
                    return useDepthTexInOther;
            }
        }

        public MatForceSettingMode3 GetEnableVRCLightVolumesInCurrentEnvironment()
        {
            switch (WFCommonUtility.GetCurrentEntironment())
            {
                case CurrentEntironment.VRCSDK3_Avatar:
                    return enableULVInVRC3Avatar;
                case CurrentEntironment.VRCSDK3_World:
                    return enableULVInVRC3World;
                default:
                    return enableULVInOther;
            }
        }

        // ==================================================

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

    /// <summary>
    /// PerMaterial / ForceOFF の二択
    /// </summary>
    public enum MatForceSettingMode2
    {
        PerMaterial = -1,
        ForceOFF = 0,
    }

    /// <summary>
    /// PerMaterial / ForceOFF / ForceON の三択
    /// </summary>
    public enum MatForceSettingMode3
    {
        PerMaterial = -1,
        ForceOFF = 0,
        ForceON = 1,
    }

    class WFEditorSettingReloader : AssetPostprocessor
    {
        public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromPath)
        {
            if (importedAssets.Any(IsSettingAssetFilePath) || deletedAssets.Any(IsSettingAssetFilePath))
            {
                WFEditorSetting.GetOneOfSettings(true);
            }
        }

        private static bool IsSettingAssetFilePath(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
            {
                return false;
            }
            return path.EndsWith(".asset", System.StringComparison.InvariantCultureIgnoreCase);
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
        SerializedProperty p_enableNccInOther;
        SerializedProperty p_disableBackLitInVRC3Avatar;
        SerializedProperty p_disableBackLitInVRC3World;
        SerializedProperty p_disableBackLitInOther;
        SerializedProperty p_useDepthTexInVRC3Avatar;
        SerializedProperty p_useDepthTexInVRC3World;
        SerializedProperty p_useDepthTexInOther;
        SerializedProperty p_enableULVInVRC3Avatar;
        SerializedProperty p_enableULVInVRC3World;
        SerializedProperty p_enableULVInOther;

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
            this.p_enableNccInOther = serializedObject.FindProperty(nameof(WFEditorSetting.enableNccInOther));

            // DisableBackLit
            this.p_disableBackLitInVRC3Avatar = serializedObject.FindProperty(nameof(WFEditorSetting.disableBackLitInVRC3Avatar));
            this.p_disableBackLitInVRC3World = serializedObject.FindProperty(nameof(WFEditorSetting.disableBackLitInVRC3World));
            this.p_disableBackLitInOther = serializedObject.FindProperty(nameof(WFEditorSetting.disableBackLitInOther));

            // UseDepthTex
            this.p_useDepthTexInVRC3Avatar = serializedObject.FindProperty(nameof(WFEditorSetting.useDepthTexInVRC3Avatar));
            this.p_useDepthTexInVRC3World = serializedObject.FindProperty(nameof(WFEditorSetting.useDepthTexInVRC3World));
            this.p_useDepthTexInOther = serializedObject.FindProperty(nameof(WFEditorSetting.useDepthTexInOther));

            // EnableULV
            this.p_enableULVInVRC3Avatar = serializedObject.FindProperty(nameof(WFEditorSetting.enableULVInVRC3Avatar));
            this.p_enableULVInVRC3World = serializedObject.FindProperty(nameof(WFEditorSetting.enableULVInVRC3World));
            this.p_enableULVInOther = serializedObject.FindProperty(nameof(WFEditorSetting.enableULVInOther));
        }

        public override void OnInspectorGUI()
        {
            var isCurrentActive = target == WFEditorSetting.GetOneOfSettings();

            if (isCurrentActive)
            {
                var msg = WFI18N.Translate("WFEditorSetting", "This is the current setting used.");
                EditorGUILayout.HelpBox(msg, MessageType.Info);
            }
            else
            {
                var msg = WFI18N.Translate("WFEditorSetting", "This is not the setting used now.");
                EditorGUILayout.HelpBox(msg, MessageType.Warning);
            }

            var width = EditorGUIUtility.labelWidth + EditorGUIUtility.fieldWidth + 5;
            var rect = GUILayoutUtility.GetRect(width, width, 0, 0, EditorStyles.layerMaskField);
            EditorGUIUtility.fieldWidth = 50;
            EditorGUIUtility.labelWidth = rect.width - EditorGUIUtility.fieldWidth - 25 - 15;

            serializedObject.Update();

            // 優先度

            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(p_settingPriority, toDisplay(p_settingPriority));
            var changePriority = EditorGUI.EndChangeCheck(); // priority 変更時、ApplyModifiedProperties 後に設定リロードする

            // Common Material Settings

            EditorGUILayout.Space();
            GUI.Label(EditorGUILayout.GetControlRect(), "Common Material Settings", EditorStyles.boldLabel);

            var currentEnv = WFCommonUtility.GetCurrentEntironment();

            using (new EditorGUI.DisabledGroupScope(currentEnv != CurrentEntironment.VRCSDK3_Avatar))
            {
                EditorGUILayout.LabelField(WFI18N.Translate("WFEditorSetting", "For VRCSDK3 Avatar"));
                using (new EditorGUI.IndentLevelScope())
                {
                    EditorGUILayout.PropertyField(p_enableNccInVRC3Avatar, new GUIContent(WFI18N.Translate("WFEditorSetting", "Cancel Near Clipping")));
                    EditorGUILayout.PropertyField(p_disableBackLitInVRC3Avatar, new GUIContent(WFI18N.Translate("WFEditorSetting", "Disable BackLit")));
                    EditorGUILayout.PropertyField(p_useDepthTexInVRC3Avatar, new GUIContent(WFI18N.Translate("WFEditorSetting", "Use CameraDepthTexture")));
                    EditorGUILayout.PropertyField(p_enableULVInVRC3Avatar, new GUIContent(WFI18N.Translate("WFEditorSetting", "Use VRC LightVolumes")));
                }
            }

            using (new EditorGUI.DisabledGroupScope(currentEnv != CurrentEntironment.VRCSDK3_World))
            {
                EditorGUILayout.LabelField(WFI18N.Translate("WFEditorSetting", "For VRCSDK3 World"));
                using (new EditorGUI.IndentLevelScope())
                {
                    EditorGUILayout.PropertyField(p_enableNccInVRC3World, new GUIContent(WFI18N.Translate("WFEditorSetting", "Cancel Near Clipping")));
                    EditorGUILayout.PropertyField(p_disableBackLitInVRC3World, new GUIContent(WFI18N.Translate("WFEditorSetting", "Disable BackLit")));
                    EditorGUILayout.PropertyField(p_useDepthTexInVRC3World, new GUIContent(WFI18N.Translate("WFEditorSetting", "Use CameraDepthTexture")));
                    EditorGUILayout.PropertyField(p_enableULVInVRC3World, new GUIContent(WFI18N.Translate("WFEditorSetting", "Use VRC LightVolumes")));
                }
            }

            using (new EditorGUI.DisabledGroupScope(currentEnv != CurrentEntironment.Other))
            {
                EditorGUILayout.LabelField(WFI18N.Translate("WFEditorSetting", "Other Environment"));
                using (new EditorGUI.IndentLevelScope())
                {
                    EditorGUILayout.PropertyField(p_enableNccInOther, new GUIContent(WFI18N.Translate("WFEditorSetting", "Cancel Near Clipping")));
                    EditorGUILayout.PropertyField(p_disableBackLitInOther, new GUIContent(WFI18N.Translate("WFEditorSetting", "Disable BackLit")));
                    EditorGUILayout.PropertyField(p_useDepthTexInOther, new GUIContent(WFI18N.Translate("WFEditorSetting", "Use CameraDepthTexture")));
                    EditorGUILayout.PropertyField(p_enableULVInOther, new GUIContent(WFI18N.Translate("WFEditorSetting", "Use VRC LightVolumes")));
                }
            }

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

            // Quest Build Support

            EditorGUILayout.PropertyField(p_autoSwitchQuestShader, toDisplay(p_autoSwitchQuestShader));

            // Editor Behaviour Settings

            EditorGUILayout.PropertyField(p_enableScanProjects, toDisplay(p_enableScanProjects));
            EditorGUILayout.PropertyField(p_enableMigrationWhenImport, toDisplay(p_enableMigrationWhenImport));

            serializedObject.ApplyModifiedProperties();

            if (changePriority)
            {
                WFEditorSetting.GetOneOfSettings(true);
            }

            WFEditorPrefs.LangMode = (EditorLanguage)EditorGUILayout.EnumPopup("Editor language", WFEditorPrefs.LangMode);

            EditorGUILayout.Space();
            GUI.Label(EditorGUILayout.GetControlRect(), "Other", EditorStyles.boldLabel);

            using(new EditorGUI.DisabledGroupScope(isCurrentActive)) {
                if (GUI.Button(EditorGUILayout.GetControlRect(), WFI18N.Translate("WFEditorSetting", "Select current setting asset")))
                {
                    Selection.activeObject = WFEditorSetting.GetOneOfSettings();
                }
            }
            if (GUI.Button(EditorGUILayout.GetControlRect(), WFI18N.Translate("WFEditorSetting", "Create New Settings asset")))
            {
                CreateNewSettingsAsset();
            }
        }

        private void CreateNewSettingsAsset()
        {
            var origin = target as WFEditorSetting;
            if (origin == null)
            {
                return;
            }

            // 現在の設定をコピーして新しいアセットとする
            var newSettings = Instantiate(origin);
            // 優先度は現在有効になっている設定より小さくする
            newSettings.settingPriority = WFEditorSetting.GetOneOfSettings().settingPriority - 1;

            // 保存
            newSettings = AssetFileSaver.SaveAsFile(newSettings, "Create New Settings asset", "asset");
            if (newSettings != null)
            {
                // 選択する
                Selection.activeObject = newSettings;
                // リロード
                WFEditorSetting.GetOneOfSettings(true);
            }
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
