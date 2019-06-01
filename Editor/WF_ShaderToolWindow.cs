/*
 *  The MIT License
 *
 *  Copyright 2018-2019 whiteflare.
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
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine;

namespace UnlitWF
{
    public class ShaderToolWindow : EditorWindow
    {
        [MenuItem("Tools/UnlitWF/Material Tools")]
        private static void OpenWindowFromMenu() {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ShaderToolWindow>(true, "UnlitWF/Material Tools", true);
        }

        [MenuItem("CONTEXT/Material/Open UnlitWF.Material Tools")]
        private static void OpenWindowFromContext(MenuCommand cmd) {
            arguments.Clear();
            arguments.AddRange(Selection.GetFiltered<Material>(SelectionMode.Assets));
            GetWindow<ShaderToolWindow>(true, "UnlitWF/Material Tools", true);
        }

        private static readonly List<Material> arguments = new List<Material>();

        private List<Material> materials = null;

        private bool expand_reset = false;
        private bool expand_cleanup = false;
        private bool expand_copy = false;

        private bool reset_color = false;
        private bool reset_float = false;
        private bool reset_texture = false;
        private bool reset_unused = false;
        private bool reset_keywords = false;

        private bool copy_colorchg = false;
        private bool copy_metallic = false;
        private bool copy_matcaps = false;
        private bool copy_shadows = false;
        private bool copy_rimlight = false;
        private bool copy_outlines = false;

        Vector2 scroll = Vector2.zero;

        private void OnEnable() {
            if (arguments.Count == 0) {
                materials = new List<Material> {
                    null
                };
            } else {
                materials = new List<Material>(arguments);
            }
        }

        #region OnGUI

        private void OnGUI() {
            GUIStyle title = new GUIStyle(EditorStyles.boldLabel) {
                fontSize = 18,
                fontStyle = FontStyle.Bold,
                fixedHeight = 20,
            };

            GUIStyle foldout = new GUIStyle("Foldout") {
                fontSize = 14,
                fontStyle = FontStyle.Bold,
            };

            // タイトル
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("UnlitWF / MaterialTools", title);
            EditorGUILayout.Space();
            EditorGUILayout.HelpBox("This is EXPERIMENTAL tools. Do Backup please.\nこのツールは実験的機能です。バックアップを忘れずに。", MessageType.Warning);

            // メインのマテリアル
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("target material", EditorStyles.boldLabel);
            materials[0] = EditorGUILayout.ObjectField(
                "target material",
                materials[0],
                typeof(Material),
                true
            ) as Material;

            // スクロールビュー開始
            EditorGUILayout.Space();
            scroll = EditorGUILayout.BeginScrollView(scroll);

            // その他のマテリアルを追加削除するボタン
            using (new EditorGUILayout.HorizontalScope()) {
                EditorGUILayout.LabelField("other materials", EditorStyles.boldLabel);
                if (GUILayout.Button("+")) {
                    materials.Add(null);
                }
                if (GUILayout.Button("-")) {
                    if (2 <= materials.Count) {
                        materials.RemoveAt(materials.Count - 1);
                    }
                }
            }
            // その他のマテリアル
            for (int i = 1; i < materials.Count; i++) {
                materials[i] = EditorGUILayout.ObjectField(
                    "other material " + i,
                    materials[i],
                    typeof(Material),
                    true
                ) as Material;
            }

            // マテリアルに UnlitWF 以外のシェーダが紛れている場合には警告
            foreach (Material mm in materials) {
                if (mm != null && mm.shader != null && !mm.shader.name.Contains("UnlitWF")) {
                    EditorGUILayout.HelpBox("Found Not-UnlitWF materials. Continue?\n(UnlitWF以外のマテリアルが紛れていますが大丈夫ですか？)", MessageType.Warning);
                    break;
                }
            }

            // コピー関係
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            expand_copy = GUILayout.Toggle(expand_copy, "Copy values", foldout);
            if (expand_copy) {
                EditorGUILayout.HelpBox("target material の設定値を other materials にコピーします。 ただしテクスチャはコピーできません。", MessageType.Info);

                copy_colorchg = GUILayout.Toggle(copy_colorchg, "UnToon::Color Change");
                copy_metallic = GUILayout.Toggle(copy_metallic, "UnToon::Metallic");
                copy_matcaps = GUILayout.Toggle(copy_matcaps, "UnToon::Light Matcaps");
                copy_shadows = GUILayout.Toggle(copy_shadows, "UnToon::ToonShade");
                copy_rimlight = GUILayout.Toggle(copy_rimlight, "UnToon::RimLight");
                copy_outlines = GUILayout.Toggle(copy_outlines, "UnToon::Outline");

                EditorGUILayout.Space();
                if (GUILayout.Button("Copy")) {
                    CopyProperties();
                }
            }

            // クリンナップ関係
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            expand_cleanup = GUILayout.Toggle(expand_cleanup, "CleanUp disabled values", foldout);
            if (expand_cleanup) {
                EditorGUILayout.HelpBox("target material と other materials から、無効化されている機能の設定値をクリアします。", MessageType.Info);

                reset_unused = GUILayout.Toggle(reset_unused, "UnUsed Properties (未使用の値) も一緒にクリアする");
                reset_keywords = GUILayout.Toggle(reset_keywords, "ShaderKeywords (Shaderキーワード) も一緒にクリアする");

                EditorGUILayout.Space();
                if (GUILayout.Button("CleanUp")) {
                    CleanupProperties();
                }
            }

            // リセット関係
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            expand_reset = GUILayout.Toggle(expand_reset, "Reset values", foldout);
            if (expand_reset) {
                EditorGUILayout.HelpBox("target material と other materials の設定値を初期化します。", MessageType.Info);

                reset_color = GUILayout.Toggle(reset_color, "Color (色)");
                reset_texture = GUILayout.Toggle(reset_texture, "Texture (テクスチャ)");
                reset_float = GUILayout.Toggle(reset_float, "Float (数値)");
                reset_unused = GUILayout.Toggle(reset_unused, "UnUsed Properties (未使用の値) も一緒にクリアする");
                reset_keywords = GUILayout.Toggle(reset_keywords, "ShaderKeywords (Shaderキーワード) も一緒にクリアする");

                EditorGUILayout.Space();
                if (GUILayout.Button("Reset")) {
                    ResetProperties();
                }
            }

            // スクロールビュー終了
            EditorGUILayout.Space();
            EditorGUILayout.EndScrollView();
        }

        #endregion

        #region コピー系

        private void CopyProperties(SerializedProperty src, SerializedProperty dst, List<string> prefix) {
            var dst_list = ToPropertyList(dst);
            foreach (var src_prop in ToPropertyList(src)) {
                if (prefix.Exists(src_prop.name.StartsWith)) {
                    var dst_prop = dst_list.Find(p => p.name == src_prop.name);
                    if (dst_prop != null) {
                        src_prop.CopyTo(dst_prop);
                    }
                }
            }
        }

        private void CopyProperties() {

            var prefix = new List<string>();
            if (copy_colorchg) {
                prefix.Add("_CL_");
            }
            if (copy_metallic) {
                prefix.Add("_MT_");
            }
            if (copy_matcaps) {
                prefix.Add("_HL_");
            }
            if (copy_shadows) {
                prefix.Add("_TS_");
            }
            if (copy_rimlight) {
                prefix.Add("_TR_");
            }
            if (copy_outlines) {
                prefix.Add("_TL_");
            }

            var src = materials[0];
            if (src == null) {
                return;
            }
            var so_src = new SerializedObject(src);
            so_src.Update();

            var src_saved = so_src.FindProperty("m_SavedProperties");

            for (int i = 1; i < materials.Count; i++) {
                var dst = materials[i];
                if (dst == null) {
                    continue;
                }
                var so_dst = new SerializedObject(dst);
                so_dst.Update();

                var dst_saved = so_dst.FindProperty("m_SavedProperties");
                {
                    CopyProperties(src_saved.FindPropertyRelative("m_Colors"), dst_saved.FindPropertyRelative("m_Colors"), prefix);
                    CopyProperties(src_saved.FindPropertyRelative("m_Floats"), dst_saved.FindPropertyRelative("m_Floats"), prefix);
                    CopyProperties(src_saved.FindPropertyRelative("m_TexEnvs"), dst_saved.FindPropertyRelative("m_TexEnvs"), prefix);
                }

                // 反映
                so_dst.ApplyModifiedProperties();
                EditorUtility.SetDirty(dst);
            }
        }

        #endregion

        private void DeleteProperties(SerializedProperty prop, Predicate<ShaderPropertyView> pred) {
            var delNames = new List<string>();
            var list = ToPropertyList(prop);
            for (int i = list.Count - 1; 0 <= i; i--) {
                if (pred(list[i])) {    // 条件に合致したら削除
                    delNames.Add(list[i].name);
                    prop.DeleteArrayElementAtIndex(i);
                }
            }
            if (0 < delNames.Count) {
                delNames.Sort();
                UnityEngine.Debug.Log("UnlitWF/MaterialTools deleted property: " + string.Join(", ", delNames.ToArray()));
            }
        }

        private void DeleteShaderKeyword(SerializedProperty prop) {
            if (string.IsNullOrEmpty(prop.stringValue)) {
                return;
            }
            UnityEngine.Debug.Log("UnlitWF/MaterialTools deleted shaderkeyword: " + prop.stringValue);
            prop.stringValue = "";
        }

        #region クリンナップ系

        private void CleanupProperties() {

            foreach (Material material in materials) {
                if (material == null) {
                    continue;
                }
                var so = new SerializedObject(material);
                so.Update();

                var saved = so.FindProperty("m_SavedProperties");

                // 無効になってる機能のプレフィックスを集める
                var delPrefix = new List<string>();
                {
                    var prop = saved.FindPropertyRelative("m_Floats");
                    foreach (var p in ToPropertyList(prop)) {
                        var mm = Regex.Match(p.name, @"\A(_[A-Z]+_)Enable\z");
                        if (mm.Success && p.value.floatValue == 0) {
                            delPrefix.Add(mm.Groups[1].Value);
                        }
                    }
                }
                // プレフィックスに合致する設定値を消去
                Predicate<ShaderPropertyView> predPrefix = p => delPrefix.Exists(p.name.StartsWith);
                DeleteProperties(saved.FindPropertyRelative("m_Colors"), predPrefix);
                DeleteProperties(saved.FindPropertyRelative("m_TexEnvs"), predPrefix);
                DeleteProperties(saved.FindPropertyRelative("m_Floats"), predPrefix);

                // 未使用の値を削除
                Predicate<ShaderPropertyView> predUnused = p => reset_unused && !material.HasProperty(p.name);
                DeleteProperties(saved.FindPropertyRelative("m_Colors"), predUnused);
                DeleteProperties(saved.FindPropertyRelative("m_Floats"), predUnused);
                DeleteProperties(saved.FindPropertyRelative("m_TexEnvs"), predUnused);

                // キーワードクリア
                if (reset_keywords) {
                    DeleteShaderKeyword(so.FindProperty("m_ShaderKeywords"));
                }

                // 反映
                so.ApplyModifiedProperties();
                EditorUtility.SetDirty(material);
            }
        }

        #endregion

        #region リセット系

        private void ResetProperties() {

            foreach (Material material in materials) {
                if (material == null) {
                    continue;
                }

                var so = new SerializedObject(material);
                so.Update();

                var saved = so.FindProperty("m_SavedProperties");

                // 条件に合致するプロパティを削除
                Predicate<ShaderPropertyView> predUnused = p => reset_unused && !material.HasProperty(p.name);
                DeleteProperties(saved.FindPropertyRelative("m_Colors"), p => reset_color || predUnused(p));
                DeleteProperties(saved.FindPropertyRelative("m_Floats"), p => reset_float || predUnused(p));
                DeleteProperties(saved.FindPropertyRelative("m_TexEnvs"), p => reset_texture || predUnused(p));

                // キーワードクリア
                if (reset_keywords) {
                    DeleteShaderKeyword(so.FindProperty("m_ShaderKeywords"));
                }

                // 反映
                so.ApplyModifiedProperties();
                EditorUtility.SetDirty(material);
            }

        }

        #endregion

        public static List<ShaderPropertyView> ToPropertyList(SerializedProperty prop) {
            var list = new List<ShaderPropertyView>();
            for (int i = 0; i < prop.arraySize; i++) {
                list.Add(new ShaderPropertyView(prop.GetArrayElementAtIndex(i)));
            }
            return list;
        }

        public class ShaderPropertyView
        {
            public readonly SerializedProperty property;

            public ShaderPropertyView(SerializedProperty property) {
                this.property = property;
            }

            public String name { get { return property.FindPropertyRelative("first").stringValue; } }

            public SerializedProperty value { get { return property.FindPropertyRelative("second"); } }

            public void CopyTo(ShaderPropertyView other) {
                var src_value = this.value;
                var dst_value = other.value;
                switch (src_value.propertyType) {
                    case SerializedPropertyType.Float:
                        dst_value.floatValue = src_value.floatValue;
                        break;
                    case SerializedPropertyType.Color:
                        dst_value.colorValue = src_value.colorValue;
                        break;
                    case SerializedPropertyType.ObjectReference:
                        dst_value.objectReferenceValue = src_value.objectReferenceValue;
                        break;

                    case SerializedPropertyType.Integer:
                        dst_value.intValue = src_value.intValue;
                        break;
                    case SerializedPropertyType.Boolean:
                        dst_value.boolValue = src_value.boolValue;
                        break;
                    case SerializedPropertyType.Enum:
                        dst_value.enumValueIndex = src_value.enumValueIndex;
                        break;
                    case SerializedPropertyType.Vector2:
                        dst_value.vector2Value = src_value.vector2Value;
                        break;
                    case SerializedPropertyType.Vector3:
                        dst_value.vector3Value = src_value.vector3Value;
                        break;
                    case SerializedPropertyType.Vector4:
                        dst_value.vector4Value = src_value.vector4Value;
                        break;
                    case SerializedPropertyType.Vector2Int:
                        dst_value.vector2IntValue = src_value.vector2IntValue;
                        break;
                    case SerializedPropertyType.Vector3Int:
                        dst_value.vector3IntValue = src_value.vector3IntValue;
                        break;
                }
            }
        }
    }
}

#endif
