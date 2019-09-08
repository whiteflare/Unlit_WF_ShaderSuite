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

            Material mat = materialEditor.target as Material;
            if (mat != null) {
                var rect = EditorGUILayout.GetControlRect();
                rect.y += 2;
                GUI.Label(rect, "Current Shader", EditorStyles.boldLabel);
                GUILayout.Label(new Regex(@".*/").Replace(mat.shader.name, ""));
            }

            // 現在無効なラベルを保持するリスト
            var disable = new List<string>();
            // プロパティを順に描画
            foreach (var prop in properties) {
                // ラベル付き displayName を、ラベルと名称に分割
                string label, name, disp;
                WFCommonUtility.FormatDispName(prop.displayName, out label, out name, out disp);

                // ラベルが指定されていてdisableに入っているならばスキップ(ただしenable以外)
                if (label != null && disable.Contains(label) && !WFCommonUtility.IsEnableToggle(label, name)) {
                    continue;
                }

                // _TS_1stColorの直前にボタンを追加する
                if (prop.name == "_TS_1stColor") {
                    Rect position = EditorGUILayout.GetControlRect(true, 24);
                    Rect fieldpos = EditorGUI.PrefixLabel(position, WFI18N.GetGUIContent("[SH] Shade Color Suggest", "ベース色をもとに1影2影色を設定します"));
                    fieldpos.height = 20;
                    if (GUI.Button(fieldpos, "APPLY")) {
                        SuggestShadowColor(materialEditor.targets);
                    }
                }

                // HideInInspectorをこのタイミングで除外するとFix*Drawerが動作しないのでそのまま通す
                // 非表示はFix*Drawerが担当
                // Fix*Drawerと一緒にHideInInspectorを付けておけば、このcsが無い環境でも非表示のまま変わらないはず
                // if ((prop.flags & MaterialProperty.PropFlags.HideInInspector) != MaterialProperty.PropFlags.None) {
                //     continue;
                // }

                // 描画
                GUIContent guiContent = WFI18N.GetGUIContent(prop.displayName);
                if (COLOR_TEX_COBINATION.ContainsKey(prop.name)) {
                    MaterialProperty propTex = FindProperty(COLOR_TEX_COBINATION[prop.name], properties, false);
                    if (propTex != null) {
                        materialEditor.TexturePropertySingleLine(guiContent, propTex, prop);
                    }
                    else {
                        materialEditor.ShaderProperty(prop, guiContent);
                    }
                }
                else if (COLOR_TEX_COBINATION.ContainsValue(prop.name)) {
                    // nop
                }
                else {
                    materialEditor.ShaderProperty(prop, guiContent);
                }

                // ラベルが指定されていてenableならば有効無効をリストに追加
                // このタイミングで確認する理由は、ShaderProperty内でFix*Drawerが動作するため
                if (WFCommonUtility.IsEnableToggle(label, name)) {
                    if ((int)prop.floatValue == 0) {
                        disable.Add(label);
                    }
                    else {
                        disable.Remove(label);
                    }
                }
            }

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
            //materialEditor.DoubleSidedGIField();
            WFI18N.LangMode = (EditorLanguage)EditorGUILayout.EnumPopup("Editor language", WFI18N.LangMode);

            // DebugView の NONE ならばキーワードを削除する
            foreach(object t in materialEditor.targets) {
                Material mm = t as Material;
                if (mm == null || Array.IndexOf(mm.shaderKeywords, "_WF_DEBUGVIEW_NONE") < 0) {
                    continue;
                }
                mm.DisableKeyword("_WF_DEBUGVIEW_NONE");
            }
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

        private readonly Dictionary<string, string> COLOR_TEX_COBINATION = new Dictionary<string, string>() {
            { "_TS_BaseColor", "_TS_BaseTex" },
            { "_TS_1stColor", "_TS_1stTex" },
            { "_TS_2ndColor", "_TS_2ndTex" },
            { "_ES_Color", "_ES_MaskTex" },
        };
    }

    internal class MaterialFixFloatDrawer : MaterialPropertyDrawer
    {
        public readonly float value;

        public MaterialFixFloatDrawer() {
            this.value = 0;
        }

        public MaterialFixFloatDrawer(float value) {
            this.value = value;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            prop.floatValue = this.value;
        }
    }

    internal class MaterialFixNoTextureDrawer : MaterialPropertyDrawer
    {

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            prop.textureValue = null;
        }
    }
}

#endif
