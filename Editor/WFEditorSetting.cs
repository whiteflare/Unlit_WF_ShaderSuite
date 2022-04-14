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

using System.Linq;
using UnityEngine;
using UnityEditor;

namespace UnlitWF
{
    // [CreateAssetMenu(menuName = "UnlitWF/EditorSettingAsset")]
    public class WFEditorSetting : ScriptableObject
    {
        public int settingPriority = 0;

        [Header("Shader Build Settings")]
        public bool enableStripping = true;
        public bool stripUnusedVariant = true;
        public bool stripFallback = true;
        public bool stripMetaPass = true;

        [Header("Editor Behaviour Settings")]
        public bool enableScanProjects = true;

        public static WFEditorSetting GetOneOfSettings()
        {
            var settings = LoadAllSettingsFromAssetDatabase();
            if (settings.Length == 0)
            {
                // 見つからないなら一時オブジェクトを作成して返却
                return ScriptableObject.CreateInstance<WFEditorSetting>();
            }
            // Debug.LogFormat("[WF][Settings] Load Settings: {0}", AssetDatabase.GetAssetPath(settings[0]));
            return settings[0];
        }

        public static WFEditorSetting[] GetAllSettings()
        {
            return LoadAllSettingsFromAssetDatabase();
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

    [CustomEditor(typeof(WFEditorSetting))]
    public class WFEditorSettingEditor : Editor
    {
        SerializedProperty p_settingPriority;
        SerializedProperty p_enableStripping;
        SerializedProperty p_stripUnusedVariant;
        SerializedProperty p_stripFallback;
        SerializedProperty p_stripMetaPass;
        SerializedProperty p_enableScanProjects;

        private void OnEnable()
        {
            this.p_settingPriority = serializedObject.FindProperty(nameof(WFEditorSetting.settingPriority));
            this.p_enableStripping = serializedObject.FindProperty(nameof(WFEditorSetting.enableStripping));
            this.p_stripUnusedVariant = serializedObject.FindProperty(nameof(WFEditorSetting.stripUnusedVariant));
            this.p_stripFallback = serializedObject.FindProperty(nameof(WFEditorSetting.stripFallback));
            this.p_stripMetaPass = serializedObject.FindProperty(nameof(WFEditorSetting.stripMetaPass));
            this.p_enableScanProjects = serializedObject.FindProperty(nameof(WFEditorSetting.enableScanProjects));
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUI.BeginChangeCheck();

            // 優先度

            EditorGUILayout.PropertyField(p_settingPriority);

            // Shader Build Settings

            EditorGUILayout.PropertyField(p_enableStripping);
            using (new EditorGUI.DisabledGroupScope(!p_enableStripping.boolValue))
            using (new EditorGUI.IndentLevelScope())
            {
                EditorGUILayout.PropertyField(p_stripUnusedVariant);
                EditorGUILayout.PropertyField(p_stripFallback);
                EditorGUILayout.PropertyField(p_stripMetaPass);
            }

            // Editor Behaviour Settings

            EditorGUILayout.PropertyField(p_enableScanProjects);

            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }

            // Common Material Settings

            EditorGUILayout.Space();
            GUI.Label(EditorGUILayout.GetControlRect(), "Common Material Settings", EditorStyles.boldLabel);

            WFEditorPrefs.LangMode = (EditorLanguage)EditorGUILayout.EnumPopup("Editor language", WFEditorPrefs.LangMode);
        }
    }
}

#endif
