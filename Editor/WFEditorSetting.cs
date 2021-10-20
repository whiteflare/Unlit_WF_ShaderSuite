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

using System.Linq;
using UnityEngine;
using UnityEditor;

namespace UnlitWF
{
    // [CreateAssetMenu(menuName = "UnlitWF/EditorSettingAsset")]
    public class WFEditorSetting : ScriptableObject
    {
        public int settingPriority = 0;
        [HideInInspector]
        public int autoMigrationVersion = 0;

        [Header("Shader Stripping Settings")]
        public bool enableStripping = true;
        public bool stripFallback = true;
        public bool stripMetaPass = true;
        public ShaderVariantCollection alwaysIncludeShaders = null;
        public Material[] alwaysIncludeMaterials = { };

        public static WFEditorSetting GetOneOfSettings()
        {
            var settings = LoadAllSettingsFromAssetDatabase();
            if (settings.Length == 0)
            {
                // 見つからないなら一時オブジェクトを作成して返却
                return ScriptableObject.CreateInstance<WFEditorSetting>();
            }
            Debug.LogFormat("[WF][Settings] Load Settings: {0}", AssetDatabase.GetAssetPath(settings[0]));
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
}

#endif
