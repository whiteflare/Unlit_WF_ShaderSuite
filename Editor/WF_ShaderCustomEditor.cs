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
        /// プロパティの前後に実行されるフック処理
        /// </summary>
        private static readonly List<IPropertyHook> HOOKS = new List<IPropertyHook>() {
            // _TS_Power の直前に設定ボタンを追加する
            new CustomPropertyHook("_TS_Power", ctx => {
                var guiContent = WFI18N.GetGUIContent("SH", "Shade Color Suggest", "ベース色をもとに1影2影色を設定します");
                if (DrawButtonFieldProperty(guiContent, "APPLY")) {
                    SuggestShadowColor(WFCommonUtility.AsMaterials(ctx.editor.targets));
                }
            } , null),
            // _TS_Feather の直前に設定ボタンを追加する
            new CustomPropertyHook("_TS_Feather", ctx => {
                if (GetShadowStepsFromMaterial(WFCommonUtility.AsMaterials(ctx.editor.targets)) < 2) {
                    return;
                }
                var guiContent = WFI18N.GetGUIContent("SH", "Align the boundaries equally", "影の境界線を等間隔に整列します");
                if (DrawButtonFieldProperty(guiContent, "APPLY")) {
                    SuggestShadowBorder(WFCommonUtility.AsMaterials(ctx.editor.targets));
                }
            } , null),

            // 条件付きHide
            new ConditionVisiblePropertyHook("_TS_2ndColor|_TS_2ndBorder", ctx => IsAnyIntValue(ctx, "_TS_Steps", p => p == 0 || 2 <= p)),
            new ConditionVisiblePropertyHook("_TS_3rdColor|_TS_3rdBorder", ctx => IsAnyIntValue(ctx, "_TS_Steps", p => 3 <= p)),
            new ConditionVisiblePropertyHook("_OL_CustomParam1", ctx => IsAnyIntValue(ctx, "_OL_UVType", p => p == 3)), // ANGEL_RING
            new ConditionVisiblePropertyHook("_HL_MedianColor(_[0-9]+)?", ctx => IsAnyIntValue(ctx, ctx.current.name.Replace("_MedianColor", "_CapType"), p => p == 0)), // MEDIAN_CAP
            new ConditionVisiblePropertyHook("_.+_BlendNormal(_.+)?", ctx => IsAnyIntValue(ctx, "_NM_Enable", p => p != 0)),
            new ConditionVisiblePropertyHook("_ES_Direction|_ES_DirType|_ES_LevelOffset|_ES_Sharpness|_ES_Speed|_ES_AlphaScroll", ctx => IsAnyIntValue(ctx, "_ES_Shape", p => p != 3)), // not CONSTANT

            // テクスチャとカラーを1行で表示する
            new SingleLineTexPropertyHook( "_TS_BaseColor", "_TS_BaseTex" ),
            new SingleLineTexPropertyHook( "_TS_1stColor", "_TS_1stTex" ),
            new SingleLineTexPropertyHook( "_TS_2ndColor", "_TS_2ndTex" ),
            new SingleLineTexPropertyHook( "_TS_3rdColor", "_TS_3rdTex" ),
            new SingleLineTexPropertyHook( "_ES_Color", "_ES_MaskTex" ),
            new SingleLineTexPropertyHook( "_EmissionColor", "_EmissionMap" ),
            new SingleLineTexPropertyHook( "_LM_Color", "_LM_Texture" ),
            new SingleLineTexPropertyHook( "_TL_LineColor", "_TL_CustomColorTex" ),
            new SingleLineTexPropertyHook( "_OL_Color", "_OL_OverlayTex" ),

            // MinMaxSlider
            new MinMaxSliderPropertyHook("_TE_MinDist", "_TE_MaxDist"),
            new MinMaxSliderPropertyHook("_FG_MinDist", "_FG_MaxDist"),
            new MinMaxSliderPropertyHook("_LM_MinDist", "_LM_MaxDist"),

            // _OL_CustomParam1のディスプレイ名をカスタマイズ
            new CustomPropertyHook("_OL_CustomParam1", ctx => {
                if (IsAnyIntValue(ctx, "_OL_UVType", p => p == 3)) {
                    ctx.guiContent = WFI18N.GetGUIContent("OL", "UV2.y <-> Normal.y");
                }
            }, null),

            // 値を設定したら他プロパティの値を自動で設定する
            new DefValueSetPropertyHook("_DetailNormalMap", ctx => {
                if (ctx.current.textureValue != null) {
                    CompareAndSet(ctx.all, "_NM_2ndType", 0, 1); // OFF -> BLEND
                }
            }),
            new DefValueSetPropertyHook("_MT_Cubemap", ctx => {
                if (ctx.current.textureValue != null) {
                    CompareAndSet(ctx.all, "_MT_CubemapType", 0, 2); // OFF -> ONLY_SECOND_MAP
                }
            }),
            new DefValueSetPropertyHook("_AL_MaskTex", ctx => {
                if (ctx.current.textureValue != null) {
                    CompareAndSet(ctx.all, "_AL_Source", 0, 1); // MAIN_TEX_ALPHA -> MASK_TEX_RED
                }
            }),

            // _DetailNormalMap と _FR_NoiseTex の直後に設定ボタンを追加する
            new CustomPropertyHook("_DetailNormalMap|_FR_NoiseTex", null, (ctx, changed) => {
                if (ctx.current.textureValue == null) {
                    return;
                }
                var rect = EditorGUILayout.GetControlRect();
                rect.width = rect.width / 2 - 2;
                if (GUI.Button(rect, WFI18N.GetGUIContent("Roughen"))) {
                    var so = ctx.current.textureScaleAndOffset;
                    so.x /= 2;
                    so.y /= 2;
                    ctx.current.textureScaleAndOffset = so;
                }
                rect.x += rect.width + 4;
                if (GUI.Button(rect, WFI18N.GetGUIContent("Finer"))) {
                    var so = ctx.current.textureScaleAndOffset;
                    so.x *= 2;
                    so.y *= 2;
                    ctx.current.textureScaleAndOffset = so;
                }
                EditorGUILayout.Space();
            }),
        };

        private static bool IsAnyIntValue(PropertyGUIContext ctx, string name, Predicate<int> pred) {
            var mats = WFCommonUtility.AsMaterials(ctx.editor.targets).Where(mat => mat.HasProperty(name)).ToArray();
            if (mats.Length == 0) {
                return true; // もしプロパティを持つマテリアルがないなら、trueを返却する
            }
            return mats.Any(mat => pred(mat.GetInt(name)));
        }

        public static bool CompareAndSet(MaterialProperty[] prop, string name, int before, int after) {
            var target = FindProperty(name, prop, false);
            if (target != null) {
                if (target.type == MaterialProperty.PropType.Float || target.type == MaterialProperty.PropType.Range) {
                    if (Mathf.RoundToInt(target.floatValue) == before) {
                        target.floatValue = after;
                        return true;
                    }
                }
            }
            return false;
        }

        /// <summary>
        /// 見つけ次第削除するシェーダキーワード
        /// </summary>
        private static readonly List<string> DELETE_KEYWORD = new List<string>() {
            "_",
            "_ALPHATEST_ON",
            "_ALPHABLEND_ON",
            "_ALPHAPREMULTIPLY_ON",
        };

        static class Styles
        {
            public static readonly Texture2D infoIcon = EditorGUIUtility.Load("icons/console.infoicon.png") as Texture2D;
            public static readonly Texture2D warnIcon = EditorGUIUtility.Load("icons/console.warnicon.png") as Texture2D;
        }

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
                // Batching Static対策HelpBox
                OnGUISub_BatchingStaticHelpBox(materialEditor);
                // Lightmap Static対策HelpBox
                OnGUISub_LightmapStaticHelpBox(materialEditor);
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

                // HideInInspectorをこのタイミングで除外するとFix*Drawerが動作しないのでそのまま通す
                // 非表示はFix*Drawerが担当
                // Fix*Drawerと一緒にHideInInspectorを付けておけば、このcsが無い環境でも非表示のまま変わらないはず
                // if ((prop.flags & MaterialProperty.PropFlags.HideInInspector) != MaterialProperty.PropFlags.None) {
                //     continue;
                // }

                // 描画
                var context = new PropertyGUIContext(materialEditor, properties, prop);
                context.guiContent = WFI18N.GetGUIContent(prop.displayName);
                OnGuiSub_ShaderProperty(context);

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

        private void OnGuiSub_ShaderProperty(PropertyGUIContext context) {
            // 更新チェック
            EditorGUI.BeginChangeCheck();

            // フック
            foreach (var hook in HOOKS) {
                hook.OnBefore(context);
            }

            // プロパティ表示
            if (!context.hidden && !context.custom) {
                context.editor.ShaderProperty(context.current, context.guiContent);
            }

            // チェック終了
            bool changed = EditorGUI.EndChangeCheck();

            // フック
            foreach (var hook in HOOKS) {
                hook.OnAfter(context, changed);
            }
        }

        private void OnGuiSub_ShowCurrentShaderName(MaterialEditor materialEditor, Material mat) {
            // シェーダ名の表示
            var rect = EditorGUILayout.GetControlRect();
            rect.y += 2;
            GUI.Label(rect, "Current Shader", EditorStyles.boldLabel);
            GUILayout.Label(new Regex(@".*/").Replace(mat.shader.name, ""));

            // シェーダ名辞書を参照
            var snm = WFShaderNameDictionary.TryFindFromName(mat.shader.name);

            // CurrentVersion プロパティがあるなら表示
            var currentVersion = GetShaderCurrentVersion(mat);
            if (!string.IsNullOrWhiteSpace(currentVersion)) {
                rect = EditorGUILayout.GetControlRect();
                rect.y += 2;
                GUI.Label(rect, "Current Version", EditorStyles.boldLabel);
                GUILayout.Label(currentVersion);

                // もしシェーダ名辞書にあって新しいバージョンがリリースされているならばボタンを表示
                if (snm != null && WFCommonUtility.IsOlderShaderVersion(currentVersion)) {
                    var message = WFI18N.Translate(WFMessageText.NewerVersion) + WFCommonUtility.GetLatestVersion()?.latestVersion;
                    if (materialEditor.HelpBoxWithButton(new GUIContent(message, Styles.infoIcon), new GUIContent("Go"))) {
                        WFCommonUtility.OpenDownloadPage();
                    }
                }
            }

            // シェーダ切り替えボタン
            if (snm != null) {
                var targets = WFCommonUtility.AsMaterials(materialEditor.targets);

                rect = EditorGUILayout.GetControlRect();
                rect.y += 2;
                GUI.Label(rect, "Current Shader Variants", EditorStyles.boldLabel);
                // バリアント
                {
                    // 同じ Variant のシェーダをリストに
                    var variants = WFShaderNameDictionary.GetVariantList(snm, out var other);
                    // その他の Variant もリストに追加する
                    if (0 < other.Count) {
                        variants.Add(null);
                        variants.AddRange(other.Distinct(new WFShaderNameVariantComparer()));
                    }

                    // ラベル文字列を作成
                    var labels = variants.Select(nm => nm == null ? "" : nm.Variant).ToArray();
                    int idx = Array.IndexOf(labels, snm.Variant);

                    EditorGUI.BeginChangeCheck();
                    int select = EditorGUILayout.Popup("Variant", idx, labels);
                    if (EditorGUI.EndChangeCheck() && idx != select) {
                        WFCommonUtility.ChangeShader(variants[select].Name, targets);
                    }
                }
                // Render Type
                {
                    // 同じ RenderType のシェーダをリストに
                    var variants = WFShaderNameDictionary.GetRenderTypeList(snm, out List<WFShaderName> other);
                    // その他の RenderType もリストに追加する
                    if (0 < other.Count) {
                        variants.Add(null);
                        variants.AddRange(other.Distinct(new WFShaderNameRenderTypeComparer()));
                    }

                    var labels = variants.Select(nm => nm == null ? "" : nm.RenderType).ToArray();
                    int idx = Array.IndexOf(labels, snm.RenderType);

                    EditorGUI.BeginChangeCheck();
                    int select = EditorGUILayout.Popup("RenderType", idx, labels);
                    if (EditorGUI.EndChangeCheck() && idx != select) {
                        WFCommonUtility.ChangeShader(variants[select].Name, targets);
                    }
                }
            }
        }

        private static string GetShaderCurrentVersion(Shader shader) {
            for (int idx = ShaderUtil.GetPropertyCount(shader) - 1; 0 <= idx; idx--) {
                if ("_CurrentVersion" == ShaderUtil.GetPropertyName(shader, idx)) {
                    return ShaderUtil.GetPropertyDescription(shader, idx);
                }
            }
            return null;
        }

        private static string GetShaderCurrentVersion(Material mat) {
            return mat == null ? null : GetShaderCurrentVersion(mat.shader);
        }

        private void OnGUISub_MigrationHelpBox(MaterialEditor materialEditor) {
            var mats = WFCommonUtility.AsMaterials(materialEditor.targets);

            if (IsOldMaterial(mats)) {
                var message = WFI18N.Translate(WFMessageText.PlzMigration);

                if (materialEditor.HelpBoxWithButton(new GUIContent(message, Styles.warnIcon), new GUIContent("Fix Now"))) {
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

        private static void OnGUISub_BatchingStaticHelpBox(MaterialEditor materialEditor) {
            // 現在のシェーダが DisableBatching == False のとき以外は何もしない (Batching されないので)
            var target = materialEditor.target as Material;
            if (target == null || !target.GetTag("DisableBatching", false, "False").Equals("False", StringComparison.OrdinalIgnoreCase)) {
                return;
            }
            // ターゲットが設定用プロパティをどちらも持っていないならば何もしない
            if (!target.HasProperty("_GL_DisableBackLit") && !target.HasProperty("_GL_DisableBasePos")) {
                return;
            }
            // 現在のシェーダ
            var shader = target.shader;

            // 現在編集中のマテリアルの配列
            var targets = WFCommonUtility.AsMaterials(materialEditor.targets);
            // 現在編集中のマテリアルのうち、Batching Static のときにオンにしたほうがいい設定がオフになっているマテリアル
            var allNonStaticMaterials = targets.Where(mat => mat.GetInt("_GL_DisableBackLit") == 0 || mat.GetInt("_GL_DisableBasePos") == 0).ToArray();

            if (allNonStaticMaterials.Length == 0) {
                return;
            }

            var scene = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene();
            // 現在のシーンにある BatchingStatic の付いた MeshRenderer が使っているマテリアルのうち、このShaderGUIが扱うマテリアルの配列
            var allStaticMaterialsInScene = scene.GetRootGameObjects()
                .SelectMany(go => go.GetComponentsInChildren<MeshRenderer>(true))
                .Where(mf => GameObjectUtility.AreStaticEditorFlagsSet(mf.gameObject, StaticEditorFlags.BatchingStatic))
                .SelectMany(mf => mf.sharedMaterials)
                .Where(mat => mat != null && mat.shader == shader)
                .ToArray();

            // Batching Static の付いているマテリアルが targets 内にあるならば警告
            if (allNonStaticMaterials.Any(mat => allStaticMaterialsInScene.Contains(mat))) {

                var message = WFI18N.Translate(WFMessageText.PlzBatchingStatic);

                if (materialEditor.HelpBoxWithButton(new GUIContent(message, Styles.infoIcon), new GUIContent("Fix Now"))) {
                    // _GL_DisableBackLit と _GL_DisableBasePos をオンにする
                    foreach (var mat in allNonStaticMaterials) {
                        mat.SetInt("_GL_DisableBackLit", 1);
                        mat.SetInt("_GL_DisableBasePos", 1);
                    }
                }
            }
        }

        private static void OnGUISub_LightmapStaticHelpBox(MaterialEditor materialEditor) {
            var target = materialEditor.target as Material;
            // ターゲットが設定用プロパティを持っていないならば何もしない
            if (!target.HasProperty("_AO_Enable") || !target.HasProperty("_AO_UseLightMap")) {
                return;
            }
            // 現在のシェーダ
            var shader = target.shader;

            // 現在編集中のマテリアルの配列
            var targets = WFCommonUtility.AsMaterials(materialEditor.targets);
            // 現在編集中のマテリアルのうち、Lightmap Static のときにオンにしたほうがいい設定がオフになっているマテリアル
            var allNonStaticMaterials = targets.Where(mat => mat.GetInt("_AO_Enable") == 0 || mat.GetInt("_AO_UseLightMap") == 0).ToArray();

            if (allNonStaticMaterials.Length == 0) {
                return;
            }

            var scene = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene();
            // 現在のシーンにある LightmapStatic の付いた MeshRenderer が使っているマテリアルのうち、このShaderGUIが扱うマテリアルの配列
            var allStaticMaterialsInScene = scene.GetRootGameObjects()
                .SelectMany(go => go.GetComponentsInChildren<MeshRenderer>(true))
                .Where(mf => GameObjectUtility.AreStaticEditorFlagsSet(mf.gameObject, StaticEditorFlags.LightmapStatic))
                // .Where(mf => 0 < mf.scaleInLightmap) // Unity2018では見えない
                .SelectMany(mf => mf.sharedMaterials)
                .Where(mat => mat != null && mat.shader == shader)
                .ToArray();

            // Lightmap Static の付いているマテリアルが targets 内にあるならば警告
            if (allNonStaticMaterials.Any(mat => allStaticMaterialsInScene.Contains(mat))) {

                var message = WFI18N.Translate(WFMessageText.PlzLightmapStatic);

                if (materialEditor.HelpBoxWithButton(new GUIContent(message, Styles.infoIcon), new GUIContent("Fix Now"))) {
                    // _AO_Enable と _AO_UseLightMap をオンにする
                    foreach (var mat in allNonStaticMaterials) {
                        mat.SetInt("_AO_Enable", 1);
                        mat.SetInt("_AO_UseLightMap", 1);
                    }
                }
            }
        }

        private static void SuggestShadowColor(Material[] mats) {
            foreach (var m in mats) {
                Undo.RecordObject(m, "shade color change");
                // ベース色を取得
                Color baseColor = m.GetColor("_TS_BaseColor");
                float hur, sat, val;
                Color.RGBToHSV(baseColor, out hur, out sat, out val);

                // 段数を取得
                var steps = GetShadowStepsFromMaterial(m);
                switch(steps) {
                    case 1:
                        if (m.HasProperty("_TS_1stColor")) {
                            m.SetColor("_TS_1stColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f));
                        }
                        break;
                    case 3:
                        if (m.HasProperty("_TS_1stColor")) {
                            m.SetColor("_TS_1stColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.6f), sat + 0.1f, val * 0.9f));
                        }
                        if (m.HasProperty("_TS_2ndColor")) {
                            m.SetColor("_TS_2ndColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f));
                        }
                        if (m.HasProperty("_TS_3rdColor")) {
                            m.SetColor("_TS_3rdColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.7f));
                        }
                        break;
                    default:
                        if (m.HasProperty("_TS_1stColor")) {
                            m.SetColor("_TS_1stColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.6f), sat + 0.1f, val * 0.9f));
                        }
                        if (m.HasProperty("_TS_2ndColor")) {
                            m.SetColor("_TS_2ndColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f));
                        }
                        break;
                }
            }
        }

        private static void SuggestShadowBorder(Material[] mats) {
            foreach (var m in mats) {
                Undo.RecordObject(m, "shade border change");
                // 段数を取得
                var steps = GetShadowStepsFromMaterial(m);
                // 1影
                var pos1 = m.GetFloat("_TS_1stBorder");
                // 2影
                if (2 <= steps && m.HasProperty("_TS_2ndBorder")) {
                    m.SetFloat("_TS_2ndBorder", pos1 * (steps - 1.0f) / steps);
                }
                // 3影
                if (2 <= steps && m.HasProperty("_TS_3rdBorder")) {
                    m.SetFloat("_TS_3rdBorder", pos1 * (steps - 2.0f) / steps);
                }
            }
        }

        private static int GetShadowStepsFromMaterial(Material[] mat) {
            if (mat.Length < 1) {
                return 2;
            }
            return mat.Select(GetShadowStepsFromMaterial).Max();
        }

        private static int GetShadowStepsFromMaterial(Material mat) {
            var steps = mat.HasProperty("_TS_Steps") ? mat.GetInt("_TS_Steps") : 0;
            if (steps <= 0) {
                return 2; // _TS_Stepsが無いとき、あっても初期値のときは2段
            }
            return steps;
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

        #region GUI部品

        /// <summary>
        /// Shurikenスタイルのヘッダを表示する
        /// </summary>
        /// <param name="position">位置</param>
        /// <param name="text">テキスト</param>
        /// <param name="prop">EnableトグルのProperty(またはnull)</param>
        /// <param name="alwaysOn">常時trueにするならばtrue、デフォルトはfalse</param>
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

        /// <summary>
        /// テクスチャとカラーを1行で表示する。
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="label"></param>
        /// <param name="propColor"></param>
        /// <param name="propTexture"></param>
        public static void DrawSingleLineTextureProperty(MaterialEditor materialEditor, GUIContent label, MaterialProperty propColor, MaterialProperty propTexture) {
            // 1行テクスチャプロパティ
            materialEditor.TexturePropertySingleLine(label, propTexture, propColor);

            // もし NoScaleOffset がないなら ScaleOffset も追加で表示する
            if (!propTexture.flags.HasFlag(MaterialProperty.PropFlags.NoScaleOffset)) {
                using (new EditorGUI.IndentLevelScope()) {
                    float oldLabelWidth = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth = 0f;
                    materialEditor.TextureScaleOffsetProperty(propTexture);
                    EditorGUIUtility.labelWidth = oldLabelWidth;
                    EditorGUILayout.Space();
                }
            }
        }

        /// <summary>
        /// MinMaxSliderを表示する。
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="label"></param>
        /// <param name="propMin"></param>
        /// <param name="propMax"></param>
        public static void DrawMinMaxProperty(MaterialEditor materialEditor, GUIContent label, MaterialProperty propMin, MaterialProperty propMax) {
            Vector2 propMinLimit = propMin.type == MaterialProperty.PropType.Range ? propMin.rangeLimits : new Vector2(0, 1);
            Vector2 propMaxLimit = propMax.type == MaterialProperty.PropType.Range ? propMax.rangeLimits : propMinLimit;

            float minValue = propMin.floatValue;
            float maxValue = propMax.floatValue;
            float minLimit = Mathf.Min(propMinLimit.x, propMaxLimit.x);
            float maxLimit = Mathf.Max(propMinLimit.y, propMaxLimit.y, minValue, maxValue);

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
            minValue = EditorGUI.FloatField(rect, minValue);

            // propMax の FloatField

            rect.x += EditorGUIUtility.fieldWidth / 2 + 1;
            maxValue = EditorGUI.FloatField(rect, maxValue);

            EditorGUI.showMixedValue = false;
            EditorGUIUtility.labelWidth = oldLabelWidth;

            if (EditorGUI.EndChangeCheck()) {
                if (propMin.type == MaterialProperty.PropType.Range) {
                    propMin.floatValue = Mathf.Clamp(minValue, propMinLimit.x, propMinLimit.y);
                }
                else {
                    propMin.floatValue = minValue;
                }
                if (propMax.type == MaterialProperty.PropType.Range) {
                    propMax.floatValue = Mathf.Clamp(maxValue, propMaxLimit.x, propMaxLimit.y);
                }
                else {
                    propMax.floatValue = maxValue;
                }
            }
        }

        private static bool DrawButtonFieldProperty(GUIContent label, string buttonText) {
            Rect position = EditorGUILayout.GetControlRect(true, 20);
            position.y += 1;
            Rect fieldpos = EditorGUI.PrefixLabel(position, label);
            fieldpos.y -= 2;
            fieldpos.height = 18;
            return GUI.Button(fieldpos, buttonText);
        }

        #endregion

        #region PropertyHook

        class PropertyGUIContext
        {
            public readonly MaterialEditor editor;
            public readonly MaterialProperty[] all;
            public readonly MaterialProperty current;
            public GUIContent guiContent = null;
            public bool hidden = false;
            public bool custom = false;

            public PropertyGUIContext(MaterialEditor editor, MaterialProperty[] all, MaterialProperty current) {
                this.editor = editor;
                this.all = all;
                this.current = current;
            }
        }

        /// <summary>
        /// プロパティの前後に実行されるフック処理のインタフェース
        /// </summary>
        interface IPropertyHook
        {
            void OnBefore(PropertyGUIContext context);

            void OnAfter(PropertyGUIContext context, bool changed);
        }

        abstract class AbstractPropertyHook : IPropertyHook
        {
            protected readonly Regex matcher;

            protected AbstractPropertyHook(string pattern) {
                this.matcher = new Regex(@"^(" + pattern + @")$", RegexOptions.Compiled);
            }

            public void OnBefore(PropertyGUIContext context) {
                if (matcher.IsMatch(context.current.name)) {
                    OnBeforeProp(context);
                }
            }

            public void OnAfter(PropertyGUIContext context, bool changed) {
                if (matcher.IsMatch(context.current.name)) {
                    OnAfterProp(context, changed);
                }
            }

            protected virtual void OnBeforeProp(PropertyGUIContext context) {

            }

            protected virtual void OnAfterProp(PropertyGUIContext context, bool changed) {

            }
        }

        /// <summary>
        /// テクスチャとカラーを1行のプロパティで表示する
        /// </summary>
        class SingleLineTexPropertyHook : AbstractPropertyHook
        {
            private readonly string colName;
            private readonly string texName;

            public SingleLineTexPropertyHook(string colName, string texName) : base(colName + "|" + texName) {
                this.colName = colName;
                this.texName = texName;
            }

            protected override void OnBeforeProp(PropertyGUIContext context) {
                if (context.hidden) {
                    return;
                }
                if (colName == context.current.name) {
                    // テクスチャとカラーを1行で表示する
                    MaterialProperty another = FindProperty(texName, context.all, false);
                    if (another != null) {
                        DrawSingleLineTextureProperty(context.editor, context.guiContent, context.current, another);
                        context.custom = true;
                    }
                    else {
                        // 相方がいない場合は単独で表示する (Mobile系の_TS_1stColorなどで発生)
                        context.custom = false;
                    }
                }
                else {
                    // 相方の側は何もしない
                    context.custom = true;
                }
            }
        }

        /// <summary>
        /// MinとMaxを1行のMinMaxSliderで表示する
        /// </summary>
        class MinMaxSliderPropertyHook : AbstractPropertyHook
        {
            private readonly string minName;
            private readonly string maxName;

            public MinMaxSliderPropertyHook(string minName, string maxName) : base(minName + "|" + maxName) {
                this.minName = minName;
                this.maxName = maxName;
            }

            protected override void OnBeforeProp(PropertyGUIContext context) {
                if (context.hidden) {
                    return;
                }
                if (minName == context.current.name) {
                    // MinMaxSlider
                    MaterialProperty another = FindProperty(maxName, context.all, false);
                    if (another != null) {
                        DrawMinMaxProperty(context.editor, context.guiContent, context.current, another);
                    }
                }
                context.custom = true;
                // 相方の側は何もしない
            }
        }

        /// <summary>
        /// 特定のプロパティが変更されたときに、他のプロパティのデフォルト値を設定する
        /// </summary>
        class DefValueSetPropertyHook : AbstractPropertyHook
        {
            public delegate void DefValueSetDelegate(PropertyGUIContext context);

            private readonly DefValueSetDelegate setter;

            public DefValueSetPropertyHook(string name, DefValueSetDelegate setter) : base(name) {
                this.setter = setter;
            }

            protected override void OnAfterProp(PropertyGUIContext context, bool changed) {
                if (changed) {
                    setter(context);
                }
            }
        }

        /// <summary>
        /// 指定の条件でプロパティを表示する
        /// </summary>
        class ConditionVisiblePropertyHook : AbstractPropertyHook
        {
            private readonly Predicate<PropertyGUIContext> pred;

            public ConditionVisiblePropertyHook(string pattern, Predicate<PropertyGUIContext> pred) : base(pattern) {
                this.pred = pred;
            }

            protected override void OnBeforeProp(PropertyGUIContext context) {
                if (!pred(context)) {
                    context.hidden = true;
                }
            }
        }

        /// <summary>
        /// デリゲートでカスタマイズ可能な PropertyHook オブジェクト
        /// </summary>
        class CustomPropertyHook : AbstractPropertyHook
        {
            public delegate void OnBeforeDelegate(PropertyGUIContext context);
            public delegate void OnAfterDelegate(PropertyGUIContext context, bool changed);

            private readonly OnBeforeDelegate before;
            private readonly OnAfterDelegate after;

            public CustomPropertyHook(string pattern, OnBeforeDelegate before, OnAfterDelegate after) : base(pattern) {
                this.before = before;
                this.after = after;
            }

            protected override void OnBeforeProp(PropertyGUIContext context) {
                if (before != null) {
                    before(context);
                }
            }

            protected override void OnAfterProp(PropertyGUIContext context, bool changed) {
                if (after != null) {
                    after(context, changed);
                }
            }
        }

        #endregion
    }

    #region MaterialPropertyDrawer

    /// <summary>
    /// Shurikenヘッダを表示する
    /// </summary>
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

    /// <summary>
    /// Enableトグル付きのShurikenヘッダを表示する
    /// </summary>
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

    /// <summary>
    /// 常時trueなEnableトグル付きのShurikenヘッダを表示する
    /// </summary>
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

    /// <summary>
    /// 常に指定のfloat値にプロパティを固定する、非表示のPropertyDrawer
    /// </summary>
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

    /// <summary>
    /// 常にテクスチャNoneにプロパティを固定する、非表示のPropertyDrawer
    /// </summary>
    internal class MaterialWF_FixNoTextureDrawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            prop.textureValue = null;
        }
    }

    /// <summary>
    /// 入力欄が2個あるVectorのPropertyDrawer
    /// </summary>
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

    /// <summary>
    /// 入力欄が3個あるVectorのPropertyDrawer
    /// </summary>
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

    #endregion
}

#endif
