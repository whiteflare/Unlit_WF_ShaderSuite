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
        private readonly Dictionary<string, string> COMBI_COLOR_TEX = new Dictionary<string, string>() {
            { "_TS_BaseColor", "_TS_BaseTex" },
            { "_TS_1stColor", "_TS_1stTex" },
            { "_TS_2ndColor", "_TS_2ndTex" },
            { "_TS_3rdColor", "_TS_3rdTex" },
            { "_ES_Color", "_ES_MaskTex" },
            { "_EmissionColor", "_EmissionMap" },
            { "_LM_Color", "_LM_Texture" },
            { "_TL_LineColor", "_TL_CustomColorTex" },
        };

        /// <summary>
        /// MinMaxSliderを使って1行で表示するやつのプロパティ名辞書
        /// </summary>
        private readonly Dictionary<string, string> COMBI_MIN_MAX = new Dictionary<string, string>() {
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
                // もし EmissionColor の Alpha が 0 になっていたら 1 にしちゃう
                if (!WFCommonUtility.IsSupportedShader(oldShader) && material.HasProperty("_EmissionColor")) {
                    var em = material.GetColor("_EmissionColor");
                    if (em.a < 1e-4) {
                        em.a = 1.0f;
                        material.SetColor("_EmissionColor", em);
                    }
                }
            }
        }

        public static bool IsSupportedShader(Shader shader) {
            return WFCommonUtility.IsSupportedShader(shader) && !shader.name.Contains("WF_DebugView");
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
                OnGuiSub_ShaderProperty(materialEditor, properties, prop);

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

        private void OnGuiSub_ShaderProperty(MaterialEditor materialEditor, MaterialProperty[] properties, MaterialProperty prop) {
            // GUIContent 作成
            GUIContent guiContent = WFI18N.GetGUIContent(prop.displayName);

            // テクスチャとカラーを1行で表示する
            if (COMBI_COLOR_TEX.ContainsKey(prop.name)) {
                MaterialProperty another = FindProperty(COMBI_COLOR_TEX[prop.name], properties, false);
                if (another != null) {
                    DoSingleLineTextureProperty(materialEditor, guiContent, prop, another);
                    return;
                }
            }
            else if (COMBI_COLOR_TEX.ContainsValue(prop.name)) {
                return; // 相方の側は何もしない
            }

            // MinMaxSlider
            if (COMBI_MIN_MAX.ContainsKey(prop.name)) {
                MaterialProperty another = FindProperty(COMBI_MIN_MAX[prop.name], properties, false);
                if (another != null) {
                    DoMinMaxProperty(materialEditor, guiContent, prop, another);
                    return;
                }
            }
            else if (COMBI_MIN_MAX.ContainsValue(prop.name)) {
                return; // 相方の側は何もしない
            }

            materialEditor.ShaderProperty(prop, guiContent);
        }

        private static void DoSingleLineTextureProperty(MaterialEditor materialEditor, GUIContent label, MaterialProperty propColor, MaterialProperty propTexture) {
            // 1行テクスチャプロパティ
            materialEditor.TexturePropertySingleLine(label, propTexture, propColor);

            // もし NoScaleOffset がないなら ScaleOffset も追加で表示する
            if (!propTexture.flags.HasFlag(MaterialProperty.PropFlags.NoScaleOffset)) {
                using (new EditorGUI.IndentLevelScope()) {
                    materialEditor.TextureScaleOffsetProperty(propTexture);
                    EditorGUILayout.Space();
                }
            }
        }

        private static void DoMinMaxProperty(MaterialEditor materialEditor, GUIContent label, MaterialProperty propMin, MaterialProperty propMax) {
            Vector2 propMinLimit = propMin.type == MaterialProperty.PropType.Range ? propMin.rangeLimits : new Vector2(0, 1);
            Vector2 propMaxLimit = propMax.type == MaterialProperty.PropType.Range ? propMax.rangeLimits : propMinLimit;

            float minValue = propMin.floatValue;
            float maxValue = propMax.floatValue;
            float minLimit = Mathf.Min(propMinLimit.x, propMaxLimit.x);
            float maxLimit = Mathf.Max(propMinLimit.y, propMaxLimit.y);

            var rect = EditorGUILayout.GetControlRect();
            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;

            EditorGUI.BeginChangeCheck();

            // MinMaxSlider

            rect.width -= EditorGUIUtility.fieldWidth + 5;
            EditorGUI.showMixedValue = propMin.hasMixedValue || propMax.hasMixedValue;
            EditorGUI.MinMaxSlider(rect, label, ref minValue, ref maxValue, minLimit, maxLimit);

            // propMin の FloatField

            rect.width = EditorGUIUtility.fieldWidth / 2 - 1;
            rect.x += oldLabelWidth;
            EditorGUI.FloatField(rect, minValue);

            // propMax の FloatField

            rect.x += EditorGUIUtility.fieldWidth / 2 + 1;
            EditorGUI.FloatField(rect, maxValue);

            EditorGUI.showMixedValue = false;
            EditorGUIUtility.labelWidth = oldLabelWidth;

            if (EditorGUI.EndChangeCheck()) {
                propMin.floatValue = Mathf.Clamp(minValue, propMinLimit.x, propMinLimit.y);
                propMax.floatValue = Mathf.Clamp(maxValue, propMaxLimit.x, propMaxLimit.y);
            }
        }

        private void OnGuiSub_ShowCurrentShaderName(MaterialEditor materialEditor, Material mat) {
            // シェーダ名の表示
            var rect = EditorGUILayout.GetControlRect();
            rect.y += 2;
            GUI.Label(rect, "Current Shader", EditorStyles.boldLabel);
            GUILayout.Label(new Regex(@".*/").Replace(mat.shader.name, ""));

            for (int idx = ShaderUtil.GetPropertyCount(mat.shader) - 1; 0 <= idx; idx--) {
                if ("_CurrentVersion" == ShaderUtil.GetPropertyName(mat.shader, idx)) {
                    rect = EditorGUILayout.GetControlRect();
                    rect.y += 2;
                    GUI.Label(rect, "Current Version", EditorStyles.boldLabel);
                    GUILayout.Label(ShaderUtil.GetPropertyDescription(mat.shader, idx));
                    break;
                }
            }

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
                if (m.HasProperty("_TS_1stColor")) {
                    Color shade1Color = Color.HSVToRGB(ShiftHur(hur, sat, 0.6f), sat + 0.1f, val * 0.9f);
                    m.SetColor("_TS_1stColor", shade1Color);
                }
                // 影2
                if (m.HasProperty("_TS_2ndColor")) {
                    Color shade2Color = Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f);
                    m.SetColor("_TS_2ndColor", shade2Color);
                }
                if (m.HasProperty("_TS_3rdColor")) {
                    Color shade3Color = Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.7f);
                    m.SetColor("_TS_3rdColor", shade3Color);
                }
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

        public static void DrawShurikenStyleHeader(Rect position, string text, MaterialProperty prop = null, bool alwaysOn = false) {
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
                if (alwaysOn) {
                    if (prop.hasMixedValue || prop.floatValue == 0.0f) {
                        prop.floatValue = 1.0f;
                    }
                }
                else {
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
            ShaderCustomEditor.DrawShurikenStyleHeader(position, text);
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

    internal class MaterialWFHeaderAlwaysOnDrawer : MaterialPropertyDrawer
    {
        public readonly string text;

        public MaterialWFHeaderAlwaysOnDrawer(string text) {
            this.text = text;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 32;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor) {
            ShaderCustomEditor.DrawShurikenStyleHeader(position, text, prop, true);
        }
    }

    [Obsolete]
    internal class MaterialFixFloatDrawer : MaterialWF_FixFloatDrawer
    {
        public MaterialFixFloatDrawer() : base() {
        }

        public MaterialFixFloatDrawer(float value) : base(value) {
        }
    }

    internal class MaterialWF_FixFloatDrawer : MaterialPropertyDrawer
    {
        public readonly float value;

        public MaterialWF_FixFloatDrawer() {
            this.value = 0;
        }

        public MaterialWF_FixFloatDrawer(float value) {
            this.value = value;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            prop.floatValue = this.value;
        }
    }

    [Obsolete]
    internal class MaterialFixNoTextureDrawer : MaterialWF_FixNoTextureDrawer
    {
    }

    internal class MaterialWF_FixNoTextureDrawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            prop.textureValue = null;
        }
    }

    internal class MaterialWF_Vector2Drawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return base.GetPropertyHeight(prop, label, editor) * 2;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;
            EditorGUI.showMixedValue = prop.hasMixedValue;

            Vector2 value = prop.vectorValue;
            EditorGUI.BeginChangeCheck();
            value = EditorGUI.Vector2Field(position, label, value);
            if (EditorGUI.EndChangeCheck()) {
                prop.vectorValue = new Vector4(value.x, value.y, 0, 0);
            }

            EditorGUI.showMixedValue = false;
            EditorGUIUtility.labelWidth = oldLabelWidth;
        }
    }

    internal class MaterialWF_Vector3Drawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return base.GetPropertyHeight(prop, label, editor) * 2;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;
            EditorGUI.showMixedValue = prop.hasMixedValue;

            Vector3 value = prop.vectorValue;
            EditorGUI.BeginChangeCheck();
            value = EditorGUI.Vector3Field(position, label, value);
            if (EditorGUI.EndChangeCheck()) {
                prop.vectorValue = new Vector4(value.x, value.y, value.z, 0);
            }

            EditorGUI.showMixedValue = false;
            EditorGUIUtility.labelWidth = oldLabelWidth;
        }
    }
}

#endif
