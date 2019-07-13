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
    public class ShaderCustomEditor : ShaderGUI
    {
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
            materialEditor.SetDefaultGUIWidths();

            // 現在無効なラベルを保持するリスト
            var disable = new List<string>();
            // プロパティを順に描画
            foreach (var prop in properties) {
                // ラベル付き displayName を、ラベルと名称に分割
                var mm = Regex.Match(prop.displayName, @"^\[(?<label>[A-Z]+)\]\s+(?<name>.+)$");
                if (mm.Success) {
                    string label = mm.Groups["label"].Value.ToUpper();
                    if (mm.Groups["name"].Value.ToLower() == "enable") {
                        // Enable チェックボックスなら有効無効をリストに追加
                        if ((int)prop.floatValue == 0) {
                            disable.Add(label);
                        }
                    }
                    else {
                        // それ以外の要素は disable に入っているならばスキップする
                        if (disable.Contains(label)) {
                            continue;
                        }
                    }
                }
                if ((prop.flags & MaterialProperty.PropFlags.HideInInspector) != MaterialProperty.PropFlags.None) {
                    continue;
                }
                // 描画
                materialEditor.ShaderProperty(prop, prop.displayName);

                if (prop.name == "_TS_BaseTex") {
                    Rect position = EditorGUILayout.GetControlRect(true, 24);
                    Rect fieldpos = EditorGUI.PrefixLabel(position, new GUIContent("[SH] Shade Color Suggest", "ベース色をもとに1影2影色を設定します"));
                    fieldpos.height = 20;
                    if (GUI.Button(fieldpos, "APPLY")) {
                        SuggestShadowColor(materialEditor.targets);
                    }
                }
            }

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
            //materialEditor.DoubleSidedGIField();
        }

        private void SuggestShadowColor(object[] targets) {
            foreach (object obj in targets) {
                Material m = obj as Material;
                if (m == null) {
                    continue;
                }
                Undo.RecordObject(m, "shade color change");
                // ベース色を取得
                Color baseColor = m.GetColor("_TS_BaseColor");
                float hur, sat, val;
                Color.RGBToHSV(baseColor, out hur, out sat, out val);
                // 影1
                Color shade1Color = Color.HSVToRGB(ShiftHur(hur, sat, 0.6f), sat + 0.1f, val * 0.9f);
                m.SetColor("_TS_1stColor", shade1Color);
                // 影2
                Color shade2Color = Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f);
                m.SetColor("_TS_2ndColor", shade2Color);
            }
        }

        private static float ShiftHur(float hur, float sat, float mul) {
            if (sat < 0.05f) {
                return 4 / 6f;
            }
            // R = 0/6f, G = 2/6f, B = 4/6f
            float[] COLOR = { 0 / 6f, 2 / 6f, 4 / 6f, 6 / 6f };
            // Y = 1/6f, C = 3/6f, M = 5/6f
            float[] LIMIT = { 1 / 6f, 3 / 6f, 5 / 6f, 10000 };
            for (int i = 0; i < COLOR.Length; i++) {
                if (hur < LIMIT[i]) {
                    return (hur - COLOR[i]) * mul + COLOR[i];
                }
            }
            return hur;
        }
    }

    internal class MaterialToggleNoKwdDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty property, GUIContent label, MaterialEditor materialEditor) {
            if (property.type != MaterialProperty.PropType.Float && property.type != MaterialProperty.PropType.Range) {
                return;
            }
            // [Toggle] はキーワードを生成してしまうため、キーワードを生成しない版の偽トグルを使う
            // Unity最新版では [ToggleUI] という名前で使えるらしい……
            EditorGUI.BeginChangeCheck();
            bool value = (Math.Abs(property.floatValue) > 0.001f);
            EditorGUI.showMixedValue = property.hasMixedValue;
            value = EditorGUI.Toggle(position, label, value);
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck()) {
                // Debug.Log("set value: " + property + " = " + value);
                property.floatValue = value ? 1.0f : 0.0f;
            }
        }
    }
}

#endif
