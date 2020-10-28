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

        delegate void DefaultValueSetter(MaterialProperty prop, MaterialProperty[] properties);

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
            (p, all) => {
                if (p.name == "_AL_MaskTex" && p.textureValue != null) {
                    var target = FindProperty("_AL_Source", all, false);
                    if (target != null && target.floatValue == 0) { // MAIN_TEX_ALPHA
                        target.floatValue = 1; // MASK_TEX_RED
                    }
                }
            },
        };

        /// <summary>
        /// 見つけ次第削除するシェーダキーワード
        /// </summary>
        private static readonly List<string> DELETE_KEYWORD = new List<string>() {
            "_",
            "_ALPHATEST_ON",
            "_ALPHABLEND_ON",
            "_ALPHAPREMULTIPLY_ON",
        };

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader) {
            PreChangeShader(material, oldShader, newShader);

            // 割り当て
            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            PostChangeShader(material, oldShader, newShader);
        }

        public static void PreChangeShader(Material material, Shader oldShader, Shader newShader) {
            // nop
        }

        public static void PostChangeShader(Material material, Shader oldShader, Shader newShader) {
            if (material != null) {
                // DebugViewの保存に使っているタグはクリア
                WF_DebugViewEditor.ClearDebugOverrideTag(material);
                // 不要なシェーダキーワードは削除
                foreach (var key in DELETE_KEYWORD) {
                    if (material.IsKeywordEnabled(key)) {
                        material.DisableKeyword(key);
                    }
                }
            }
        }

        public static bool IsSupportedShader(Shader shader) {
            return shader != null && shader.name.Contains("UnlitWF/") && !shader.name.Contains("WF_DebugView");
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
            materialEditor.SetDefaultGUIWidths();

            Material mat = materialEditor.target as Material;
            if (mat != null) {
                // CurrentShader
                OnGuiSub_ShowCurrentShaderName(materialEditor, mat);
                // マイグレーションHelpBox
                OnGUISub_MigrationHelpBox(materialEditor);
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
                        SuggestShadowColor(WFCommonUtility.AsMaterials(materialEditor.targets));
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
                        if (!propTex.flags.HasFlag(MaterialProperty.PropFlags.NoScaleOffset)) {
                            using (new EditorGUI.IndentLevelScope()) {
                                materialEditor.TextureScaleOffsetProperty(propTex);
                                EditorGUILayout.Space();
                            }
                        }
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

            if (EditorGUILayout.Popup("Change DebugView shader", 0, new string[] { "OFF", "DEBUG" }) == 1) {
                WFCommonUtility.ChangeShader(WF_DebugViewEditor.SHADER_NAME_DEBUGVIEW, WFCommonUtility.AsMaterials(materialEditor.targets));
            }

            // 不要なシェーダキーワードは削除
            foreach (object t in materialEditor.targets) {
                Material mm = t as Material;
                if (mm != null) {
                    foreach (var key in DELETE_KEYWORD) {
                        if (mm.IsKeywordEnabled(key)) {
                            mm.DisableKeyword(key);
                        }
                    }
                }
            }
        }

        private void OnGuiSub_ShowCurrentShaderName(MaterialEditor materialEditor, Material mat) {
            // シェーダ名の表示
            var rect = EditorGUILayout.GetControlRect();
            rect.y += 2;
            GUI.Label(rect, "Current Shader", EditorStyles.boldLabel);
            GUILayout.Label(new Regex(@".*/").Replace(mat.shader.name, ""));

            // シェーダ切り替えボタン
            var snm = WFShaderNameDictionary.TryFindFromName(mat.shader.name);
            if (snm != null) {
                var targets = WFCommonUtility.AsMaterials(materialEditor.targets);

                rect = EditorGUILayout.GetControlRect();
                rect.y += 2;
                GUI.Label(rect, "Current Shader Variants", EditorStyles.boldLabel);
                // バリアント
                {
                    var variants = WFShaderNameDictionary.GetVariantList(snm);
                    var labels = variants.Select(nm => nm.Variant).ToArray();
                    int idx = Array.IndexOf(labels, snm.Variant);
                    EditorGUI.BeginChangeCheck();
                    int select = EditorGUILayout.Popup("Variant", idx, labels);
                    if (EditorGUI.EndChangeCheck() && idx != select) {
                        WFCommonUtility.ChangeShader(variants[select].Name, targets);
                    }
                }
                // Render Type
                {
                    var variants = WFShaderNameDictionary.GetRenderTypeList(snm);
                    var labels = variants.Select(nm => nm.RenderType).ToArray();
                    int idx = Array.IndexOf(labels, snm.RenderType);
                    EditorGUI.BeginChangeCheck();
                    int select = EditorGUILayout.Popup("RenderType", idx, labels);
                    if (EditorGUI.EndChangeCheck() && idx != select) {
                        WFCommonUtility.ChangeShader(variants[select].Name, targets);
                    }
                }
            }
        }

        private void OnGUISub_MigrationHelpBox(MaterialEditor materialEditor) {
            var mats = WFCommonUtility.AsMaterials(materialEditor.targets);

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

        static WeakRefCache<Material> oldMaterialVersionCache = new WeakRefCache<Material>();
        static WeakRefCache<Material> newMaterialVersionCache = new WeakRefCache<Material>();

        private static bool IsOldMaterial(params object[] mats) {
            var editor = new WFMaterialEditUtility();

            bool result = false;
            foreach (Material mat in mats) {
                if (mat == null) {
                    continue;
                }
                if (newMaterialVersionCache.Contains(mat)) {
                    continue;
                }
                if (oldMaterialVersionCache.Contains(mat)) {
                    result |= true;
                    return true;
                }
                bool old = editor.ExistsOldNameProperty(mat);
                if (old) {
                    oldMaterialVersionCache.Add(mat);
                }
                else {
                    newMaterialVersionCache.Add(mat);
                }
                result |= old;
            }
            return result;
        }

        public static void ResetOldMaterialTable(params object[] values) {
            var mats = values.Select(mat => mat as Material).Where(mat => mat != null).ToArray();
            oldMaterialVersionCache.RemoveAll(mats);
            newMaterialVersionCache.RemoveAll(mats);
        }

        private void SuggestShadowColor(Material[] mats) {
            foreach (var m in mats) {
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
