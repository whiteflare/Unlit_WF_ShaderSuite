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
            }

            //EditorGUILayout.Space();
            //EditorGUILayout.Space();
            //GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
            //materialEditor.RenderQueueField();
            //materialEditor.EnableInstancingField();
            //materialEditor.DoubleSidedGIField();
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
