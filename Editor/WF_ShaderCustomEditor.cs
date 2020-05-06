/*
 *  The MIT License
 *
 *  Copyright 2018-2020 whiteflare.
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
using System.Runtime.CompilerServices;
using System.Linq;
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine;

namespace UnlitWF
{
    public class ShaderCustomEditor : ShaderGUI
    {
        /// <summary>
        /// テクスチャとカラーを1行で表示するやつのプロパティ名辞書
        /// </summary>
        private readonly Dictionary<string, string> COLOR_TEX_COBINATION = new Dictionary<string, string>() {
            { "_TS_BaseColor", "_TS_BaseTex" },
            { "_TS_1stColor", "_TS_1stTex" },
            { "_TS_2ndColor", "_TS_2ndTex" },
            { "_ES_Color", "_ES_MaskTex" },
            { "_EmissionColor", "_EmissionMap" },
        };

        /// <summary>
        /// 値を設定したら他プロパティの値を自動で設定するやつ
        /// </summary>
        private readonly List<DefaultValueSetter> DEF_VALUE_SETTER = new List<DefaultValueSetter>() {
            (p, all) => {
                if (p.name == "_DetailNormalMap" && p.textureValue != null) {
                    var target = FindProperty("_NM_2ndType", all, false);
                    if (target != null && target.floatValue == 0) { // OFF
                        target.floatValue = 1; // BLEND
                    }
                }
            },
            (p, all) => {
                if (p.name == "_MT_Cubemap" && p.textureValue != null) {
                    var target = FindProperty("_MT_CubemapType", all, false);
                    if (target != null && target.floatValue == 0) { // OFF
                        target.floatValue = 2; // ONLY_SECOND_MAP
                    }
                }
            },
        };

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
            materialEditor.SetDefaultGUIWidths();

            Material mat = materialEditor.target as Material;
            if (mat != null) {
                // シェーダ名の表示
                var rect = EditorGUILayout.GetControlRect();
                rect.y += 2;
                GUI.Label(rect, "Current Shader", EditorStyles.boldLabel);
                GUILayout.Label(new Regex(@".*/").Replace(mat.shader.name, ""));
                // マイグレーションHelpBox
                MigrationHelpBox(materialEditor);
            }

            // 現在無効なラベルを保持するリスト
            var disable = new HashSet<string>();
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

                // 更新監視
                EditorGUI.BeginChangeCheck();

                // 描画
                GUIContent guiContent = WFI18N.GetGUIContent(prop.displayName);
                if (COLOR_TEX_COBINATION.ContainsKey(prop.name)) {
                    // テクスチャとカラーを1行で表示するものにマッチした場合
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

                // 更新監視
                if (EditorGUI.EndChangeCheck()) {
                    foreach (var setter in DEF_VALUE_SETTER) {
                        setter(prop, properties);
                    }
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

            DrawShurikenStyleHeader(EditorGUILayout.GetControlRect(false, 32), "Advanced Options", null);
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
            //materialEditor.DoubleSidedGIField();
            WFI18N.LangMode = (EditorLanguage)EditorGUILayout.EnumPopup("Editor language", WFI18N.LangMode);
        }

        delegate void DefaultValueSetter(MaterialProperty prop, MaterialProperty[] properties);

        private void MigrationHelpBox(MaterialEditor materialEditor) {
            var mats = materialEditor.targets.Select(obj => obj as Material).Where(mat => mat != null).ToArray();

            if (IsOldMaterial(mats)) {
                var tex = WFI18N.LangMode == EditorLanguage.日本語 ?
                    "このマテリアルは古いバージョンで作成されたようです。最新版に変換しますか？" :
                    "This Material may have been created in an older version. Convert to new version?";
                if (materialEditor.HelpBoxWithButton(
                                    new GUIContent(tex),
                                    new GUIContent("Fix Now"))) {
                    var editor = new WFMaterialEditUtility();
                    // 名称を全て変更
                    editor.RenameOldNameProperties(mats);
                    // リセット
                    ResetOldMaterialTable(mats);
                }
            }
        }

        static ConditionalWeakTable<Material, string> oldVersionMaterials = new ConditionalWeakTable<Material, string>();

        private static bool IsOldMaterial(params object[] mats) {
            var editor = new WFMaterialEditUtility();

            bool result = false;
            lock (oldVersionMaterials) {
                foreach (Material mat in mats) {
                    if (mat == null) {
                        continue;
                    }
                    bool old = false;
                    string value;
                    if (oldVersionMaterials.TryGetValue(mat, out value)) {
                        old = bool.Parse(value);
                    }
                    else {
                        old = editor.ExistsOldNameProperty(mat);
                        oldVersionMaterials.Add(mat, old.ToString());
                    }
                    result |= old;
                }
            }
            return result;
        }

        public static void ResetOldMaterialTable(params object[] mats) {
            lock (oldVersionMaterials) {
                foreach (Material mat in mats) {
                    if (mat == null) {
                        continue;
                    }
                    oldVersionMaterials.Remove(mat);
                }
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

        public static void DrawShurikenStyleHeader(Rect position, string text, MaterialProperty prop) {
            // SurikenStyleHeader
            var style = new GUIStyle("ShurikenModuleTitle");
            style.font = EditorStyles.boldLabel.font;
            style.fixedHeight = 20;
            style.contentOffset = new Vector2(20, -2);
            // Draw
            position.y += 8;
            position = EditorGUI.IndentedRect(position);
            GUI.Box(position, text, style);

            if (prop != null) {
                // Toggle
                Rect r = EditorGUILayout.GetControlRect(true, 0, EditorStyles.layerMaskField);
                r.y -= 25;
                r.height = MaterialEditor.GetDefaultPropertyHeight(prop);

                bool value = 0.001f < Math.Abs(prop.floatValue);
                EditorGUI.showMixedValue = prop.hasMixedValue;
                EditorGUI.BeginChangeCheck();
                value = EditorGUI.Toggle(r, " ", value);
                if (EditorGUI.EndChangeCheck()) {
                    prop.floatValue = value ? 1.0f : 0.0f;
                }
                EditorGUI.showMixedValue = false;

                // ▼
                var toggleRect = new Rect(position.x + 4f, position.y + 2f, 13f, 13f);
                if (Event.current.type == EventType.Repaint) {
                    EditorStyles.foldout.Draw(toggleRect, false, false, value, false);
                }
            }
        }
    }

    internal class MaterialWFHeaderDecorator : MaterialPropertyDrawer
    {
        public readonly string text;

        public MaterialWFHeaderDecorator(string text) {
            this.text = text;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 32;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor) {
            ShaderCustomEditor.DrawShurikenStyleHeader(position, text, null);
        }
    }

    internal class MaterialWFHeaderToggleDrawer : MaterialPropertyDrawer
    {
        public readonly string text;

        public MaterialWFHeaderToggleDrawer(string text) {
            this.text = text;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 32;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor) {
            ShaderCustomEditor.DrawShurikenStyleHeader(position, text, prop);
        }
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
