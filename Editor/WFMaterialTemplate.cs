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

using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

#if UNITY_EDITOR

namespace UnlitWF
{
    public class WFMaterialTemplate : ScriptableObject
    {
        public string memo;
        public Material material;

        [MenuItem(WFMenu.ASSETS_TEMPLATE, priority = WFMenu.PRI_ASSETS_TEMPLATE)]
        public static void CreateAsset()
        {
            var mat = new Material(Shader.Find("UnlitWF/WF_UnToon_Opaque"));
            CreateAsset(mat);
        }

        public static void CreateAsset(Material copy)
        {
            var path = EditorUtility.SaveFilePanel("Save WF Material Template", "Assets", "", "asset");
            if (string.IsNullOrWhiteSpace(path))
            {
                return;
            }
            if (path.StartsWith(Application.dataPath, System.StringComparison.InvariantCultureIgnoreCase))
            {
                path = "Assets" + path.Substring(Application.dataPath.Length);
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

        public void ApplyToMaterial(IEnumerable<Material> mats)
        {
            if (material == null)
            {
                Debug.LogWarningFormat("[WF] Material is not set in the template: {0}", name);
                return;
            }
            Undo.RecordObjects(mats.ToArray(), "WF apply Template");

            // シェーダを揃える
            foreach (var mat in mats)
            {
                if (mat.shader != material.shader)
                {
                    mat.shader = material.shader;
                    mat.renderQueue = material.renderQueue;
                }
            }

            // プロパティ類をコピー
            var prm = CopyPropParameter.Create();
            prm.materialSource = material;
            prm.materialDestination = mats.ToArray();
            prm.labels = WFShaderFunction.GetEnableFunctionList(material).Select(f => f.Label).ToArray();
            prm.onlyOverrideBuiltinTextures = true; // テクスチャ類はビルトインテクスチャのみ上書き可能

            WFMaterialEditUtility.CopyPropertiesWithoutUndo(prm);
        }
    }

    [CustomEditor(typeof(WFMaterialTemplate))]
    public class WFMaterialTemplateEditor : Editor
    {
        void OnEnable()
        {
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            var m_material = serializedObject.FindProperty("material");
            using (new EditorGUI.DisabledGroupScope(true))
            {
                EditorGUILayout.PropertyField(m_material);
            }

            var style = new GUIStyle(EditorStyles.textArea);
            style.wordWrap = true;

            var m_memo = serializedObject.FindProperty("memo");
            EditorGUILayout.PrefixLabel("memo");
            m_memo.stringValue = EditorGUILayout.TextArea(m_memo.stringValue, style, GUILayout.Height(80));

            serializedObject.ApplyModifiedProperties();
        }
    }
}

#endif
