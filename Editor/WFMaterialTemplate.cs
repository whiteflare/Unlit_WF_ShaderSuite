/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2025 whiteflare.
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

using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

#if UNITY_EDITOR

namespace UnlitWF
{
    public class WFMaterialTemplate : ScriptableObject
    {
        public Material material;
        public string displayName;
        public string memo;
        public bool copyMaterialColor;
        public bool forceChangeShader;

        //[MenuItem(WFMenu.ASSETS_TEMPLATE, priority = WFMenu.PRI_ASSETS_TEMPLATE)]
        //public static void CreateAsset()
        //{
        //    var mat = new Material(Shader.Find("UnlitWF/WF_UnToon_Opaque"));
        //    CreateAsset(mat);
        //}

        public static void CreateAsset(Material copy)
        {
            var path = AssetFileSaver.SaveFilePanelInProject("Save WF Material Template", "", "asset");
            if (string.IsNullOrWhiteSpace(path))
            {
                return;
            }
            CreateAsset(copy, path);
        }

        public static void CreateAsset(Material copy, string path)
        {
            if (copy == null || string.IsNullOrWhiteSpace(path))
            {
                return;
            }

            var tmp = CreateInstance<WFMaterialTemplate>();

            tmp.material = new Material(copy);
            tmp.material.name = copy.shader.name;
            tmp.material.hideFlags = HideFlags.None;

            AssetDatabase.CreateAsset(tmp, path);
            AssetDatabase.AddObjectToAsset(tmp.material, tmp);
        }

        public static bool IsAvailable(WFMaterialTemplate template)
        {
            if (template == null || template.material == null)
            {
                return false;
            }
            return WFCommonUtility.IsSupportedShader(template.material);
        }

        public string GetDisplayString()
        {
            return string.IsNullOrWhiteSpace(displayName) ? this.name : displayName;
        }

        public void ApplyToMaterial(IEnumerable<Material> mats)
        {
            if (material == null)
            {
                Debug.LogWarningFormat("[WF] Material is not set in the template: {0}", name);
                return;
            }
            Undo.RecordObjects(mats.ToArray(), "WF apply Template");

            // テンプレートからコピーする機能の特定
            var activeLabels = WFShaderFunction.GetEnableFunctionList(material).Select(f => f.Label).ToArray();

            // 適用先のプロパティが揃っているかを確認し、揃っていないならシェーダを変更する
            foreach (var mat in mats)
            {
                if (mat.shader != material.shader)
                {
                    if (!forceChangeShader && IsMatchFeature(mat, activeLabels))
                    {
                        continue;
                    }
                    mat.shader = material.shader;
                    mat.renderQueue = WFAccessor.GetMaterialRenderQueueValue(material);
                }
            }

            // プロパティ類をコピー
            var prm = CopyPropParameter.Create();
            prm.materialSource = material;
            prm.materialDestination = mats.ToArray();
            prm.labels = activeLabels;
            prm.onlyOverrideBuiltinTextures = true; // テクスチャ類はビルトインテクスチャのみ上書き可能
            prm.copyMaterialColor = copyMaterialColor; // チェックされている場合は Material Color 他もコピーする

            WFMaterialEditUtility.CopyPropertiesWithoutUndo(prm);
        }

        private bool IsMatchFeature(Material mat, string[] activeLabels)
        {
            var pns = WFAccessor.GetAllPropertyNames(mat.shader).Select(WFCommonUtility.GetPrefixFromPropName).Where(lb => lb != null).Distinct().ToArray();
            return activeLabels.All(pns.Contains);
        }
    }

    [CustomEditor(typeof(WFMaterialTemplate))]
    class WFMaterialTemplateEditor : Editor
    {
        void OnEnable()
        {
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            using (new EditorGUI.DisabledGroupScope(true))
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(WFMaterialTemplate.material)));
            }

            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(WFMaterialTemplate.displayName)));
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(WFMaterialTemplate.copyMaterialColor)));
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(WFMaterialTemplate.forceChangeShader)));

            var style = new GUIStyle(EditorStyles.textArea);
            style.wordWrap = true;

            var m_memo = serializedObject.FindProperty(nameof(WFMaterialTemplate.memo));
            EditorGUILayout.PrefixLabel("memo");
            m_memo.stringValue = EditorGUILayout.TextArea(m_memo.stringValue, style, GUILayout.Height(80));

            serializedObject.ApplyModifiedProperties();
        }
    }
}

#endif
