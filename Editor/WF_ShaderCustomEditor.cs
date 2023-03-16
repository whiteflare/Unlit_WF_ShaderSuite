/*
 *  The MIT License
 *
 *  Copyright 2018-2023 whiteflare.
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
                var guiContent = WFI18N.GetGUIContent("TS", "Shade Color Suggest", "ベース色をもとに1影2影色を設定します");
                if (DrawButtonFieldProperty(guiContent, "APPLY")) {
                    ctx.editor.RegisterPropertyChangeUndo("Shade Color Suggest");
                    SuggestShadowColor(WFCommonUtility.AsMaterials(ctx.editor.targets));
                }
            } , null),
            // _TS_Feather の直前に設定ボタンを追加する
            new CustomPropertyHook("_TS_Feather|_TS_1stFeather", ctx => {
                if (GetShadowStepsFromMaterial(WFCommonUtility.AsMaterials(ctx.editor.targets)) < 2) {
                    return;
                }
                var guiContent = WFI18N.GetGUIContent("TS", "Align the boundaries equally", "影の境界線を等間隔に整列します");
                if (DrawButtonFieldProperty(guiContent, "APPLY")) {
                    ctx.editor.RegisterPropertyChangeUndo("Align the boundaries equally");
                    SuggestShadowBorder(WFCommonUtility.AsMaterials(ctx.editor.targets));
                }
            } , null),

            // 条件付きHide
            new ConditionVisiblePropertyHook("_TS_2ndColor|_TS_2ndBorder|_TS_2ndFeather", ctx => IsAnyIntValue(ctx, "_TS_Steps", p => p == 0 || 2 <= p)),
            new ConditionVisiblePropertyHook("_TS_3rdColor|_TS_3rdBorder|_TS_3rdFeather", ctx => IsAnyIntValue(ctx, "_TS_Steps", p => 3 <= p)),
            new ConditionVisiblePropertyHook("_OVL_CustomParam1", ctx => IsAnyIntValue(ctx, "_OVL_UVType", p => p == 3)), // ANGEL_RING
            new ConditionVisiblePropertyHook("_HL_MedianColor(_[0-9]+)?", ctx => IsAnyIntValue(ctx, ctx.current.name.Replace("_MedianColor", "_CapType"), p => p == 0)), // MEDIAN_CAP
            new ConditionVisiblePropertyHook("_.+_BlendNormal(_.+)?", ctx => IsAnyIntValue(ctx, "_NM_Enable", p => p != 0)),
            new ConditionVisiblePropertyHook("_.+_BlendNormal2(_.+)?", ctx => IsAnyIntValue(ctx, "_NS_Enable", p => p != 0)),
            new ConditionVisiblePropertyHook("_ES_SC_.*", ctx => IsAnyIntValue(ctx, "_ES_ScrollEnable", p => p != 0)),
            new ConditionVisiblePropertyHook("_ES_SC_UVType", ctx => IsAnyIntValue(ctx, "_ES_SC_DirType", p => p == 2)),
            new ConditionVisiblePropertyHook("_ES_AU_.*", ctx => IsAnyIntValue(ctx, "_ES_AuLinkEnable", p => p != 0)),
            new ConditionVisiblePropertyHook("_GL_CustomAzimuth|_GL_CustomAltitude", ctx => IsAnyIntValue(ctx, "_GL_LightMode", p => p != 5)),
            new ConditionVisiblePropertyHook("_GL_CustomLitPos", ctx => IsAnyIntValue(ctx, "_GL_LightMode", p => p == 5)),
            // 条件付きHide(Grass系列)
            new ConditionVisiblePropertyHook("_GRS_WorldYBase|_GRS_WorldYScale", ctx => IsAnyIntValue(ctx, "_GRS_HeightType", p => p == 0)),
            new ConditionVisiblePropertyHook("_GRS_HeightUVType", ctx => IsAnyIntValue(ctx, "_GRS_HeightType", p => p == 1 || p == 2)),
            new ConditionVisiblePropertyHook("_GRS_HeightMaskTex|_GRS_InvMaskVal", ctx => IsAnyIntValue(ctx, "_GRS_HeightType", p => p == 2)),
            new ConditionVisiblePropertyHook("_GRS_UVFactor", ctx => IsAnyIntValue(ctx, "_GRS_HeightType", p => p == 1)),
            new ConditionVisiblePropertyHook("_GRS_ColorFactor", ctx => IsAnyIntValue(ctx, "_GRS_HeightType", p => p == 2 || p == 3)),
            // 条件付きHide(Water系列)
            new ConditionVisiblePropertyHook("_WAM_Cubemap", ctx => IsAnyIntValue(ctx, "_WAM_CubemapType", p => p != 0)),
            new ConditionVisiblePropertyHook("_WAM_CubemapHighCut", ctx => IsAnyIntValue(ctx, "_WAM_CubemapType", p => p != 0)),

            // テクスチャとカラーを1行で表示する
            new SingleLineTexPropertyHook( "_TS_BaseColor", "_TS_BaseTex" ),
            new SingleLineTexPropertyHook( "_TS_1stColor", "_TS_1stTex" ),
            new SingleLineTexPropertyHook( "_TS_2ndColor", "_TS_2ndTex" ),
            new SingleLineTexPropertyHook( "_TS_3rdColor", "_TS_3rdTex" ),
            new SingleLineTexPropertyHook( "_ES_Color", "_ES_MaskTex" ),
            new SingleLineTexPropertyHook( "_EmissionColor", "_EmissionMap" ),
            new SingleLineTexPropertyHook( "_LME_Color", "_LME_Texture" ),
            new SingleLineTexPropertyHook( "_TL_LineColor", "_TL_CustomColorTex" ),
            new SingleLineTexPropertyHook( "_OVL_Color", "_OVL_OverlayTex" ),

            // MinMaxSlider
            new MinMaxSliderPropertyHook("_TE_MinDist", "_TE_MaxDist", "[TE] FadeOut Distance"),
            new MinMaxSliderPropertyHook("_TFG_MinDist", "_TFG_MaxDist", "[TFG] FadeOut Distance"),
            new MinMaxSliderPropertyHook("_LME_MinDist", "_LME_MaxDist", "[LME] FadeOut Distance"),
            new MinMaxSliderPropertyHook("_TS_MinDist", "_TS_MaxDist", "[TS] FadeOut Distance"),
            new MinMaxSliderPropertyHook("_DFD_MinDist", "_DFD_MaxDist", "[DFD] Fade Distance"),
            new MinMaxSliderPropertyHook("_CGL_BlurMin", "_CGL_Blur", "[CGL] Blur"),
            new MinMaxSliderPropertyHook("_WAR_MinDist", "_WAR_MaxDist", "[WAR] FadeOut Distance"),
            new MinMaxSliderPropertyHook("_ES_AU_MinValue", "_ES_AU_MaxValue", "[ES] Emission Multiplier"),
            new MinMaxSliderPropertyHook("_ES_AU_MinThreshold", "_ES_AU_MaxThreshold", "[ES] Threshold"),

            // ZWrite
            new ZWriteFrontBackPropertyHook("_AL_ZWrite", "_AL_ZWriteBack"),

            // _OL_CustomParam1のディスプレイ名をカスタマイズ
            new CustomPropertyHook("_OVL_CustomParam1", ctx => {
                if (IsAnyIntValue(ctx, "_OVL_UVType", p => p == 3)) {
                    ctx.guiContent = WFI18N.GetGUIContent("OL", "UV2.y <-> Normal.y");
                }
            }, null),

            // 値を設定したら他プロパティの値を自動で設定する
            new DefValueSetPropertyHook("_MT_Cubemap", ctx => {
                if (ctx.current.textureValue != null) {
                    CompareAndSet(ctx.all, "_MT_CubemapType", 0, 2); // OFF -> ONLY_SECOND_MAP
                }
            }),
            new DefValueSetPropertyHook("_WAM_Cubemap", ctx => {
                if (ctx.current.textureValue != null) {
                    CompareAndSet(ctx.all, "_WRL_CubemapType", 0, 2); // OFF -> ONLY_SECOND_MAP
                }
            }),
            new DefValueSetPropertyHook("_AL_MaskTex", ctx => {
                if (ctx.current.textureValue != null) {
                    CompareAndSet(ctx.all, "_AL_Source", 0, 1); // MAIN_TEX_ALPHA -> MASK_TEX_RED
                }
            }),
            new DefValueSetPropertyHook("_HL_MatcapTex(_[0-9]+)?", ctx => {
                if (ctx.current.textureValue != null) {
                    var name = ctx.current.textureValue.name;
                    if (!string.IsNullOrWhiteSpace(name))
                    {
                        if (name.StartsWith("lcap_", StringComparison.InvariantCultureIgnoreCase))
                        {
                            CompareAndSet(ctx.all, ctx.current.name.Replace("_MatcapTex", "_CapType"), 0, 1); // MCAP -> LCAP
                        }
                        else if (name.StartsWith("mcap_", StringComparison.InvariantCultureIgnoreCase))
                        {
                            CompareAndSet(ctx.all, ctx.current.name.Replace("_MatcapTex", "_CapType"), 1, 0); // LCAP -> MCAP
                        }
                    }
                }
            }),

            // _DetailNormalMap と _FUR_NoiseTex の直後に設定ボタンを追加する
            new CustomPropertyHook("_DetailNormalMap|_FUR_NoiseTex|(_WAV_NormalMap|_WAV_HeightMap|_WAV_CausticsTex)(_[0-9]+)?", null, (ctx, changed) => {
                if (ctx.current.textureValue == null) {
                    return;
                }
                var rect = EditorGUILayout.GetControlRect();
                rect.width = rect.width / 2 - 2;
                if (GUI.Button(rect, WFI18N.GetGUIContent("Roughen"))) {
                    var so = ctx.current.textureScaleAndOffset;
                    so.x /= 2;
                    so.y /= 2;
                    ctx.editor.RegisterPropertyChangeUndo("Texture scale change");
                    ctx.current.textureScaleAndOffset = so;
                }
                rect.x += rect.width + 4;
                if (GUI.Button(rect, WFI18N.GetGUIContent("Finer"))) {
                    var so = ctx.current.textureScaleAndOffset;
                    so.x *= 2;
                    so.y *= 2;
                    ctx.editor.RegisterPropertyChangeUndo("Texture scale change");
                    ctx.current.textureScaleAndOffset = so;
                }
                EditorGUILayout.Space();
            }),

            // _TR_InvMaskVal の直後に設定ボタンを追加する
            new CustomPropertyHook("_TR_InvMaskVal", null, (ctx, changed) => {
                var guiContent = WFI18N.GetGUIContent("TR", "Assign MainTex to MaskTexture", "メインテクスチャをリムライトマスクに設定します");
                if (DrawButtonFieldProperty(guiContent, "APPLY")) {
                    ctx.editor.RegisterPropertyChangeUndo("Assign MainTex to MaskTexture");
                    foreach(var mat in WFCommonUtility.AsMaterials(ctx.editor.targets))
                    {
                        mat.SetTexture("_TR_MaskTex", mat.GetTexture("_MainTex"));
                        mat.SetFloat("_TR_InvMaskVal", 0);
                    }
                }
            }),

            // _NS_InvMaskVal の直後に FlipMirror を再表示
            new CustomPropertyHook("_NS_InvMaskVal", null, (ctx, changed) => {
                var prop = ctx.all.Where(p => p.name == "_FlipMirror").FirstOrDefault();
                if (prop != null)
                {
                    ctx.editor.ShaderProperty(prop, WFI18N.GetGUIContent(prop.displayName.Replace("[NM]", "[NS]")));
                }
            }),

            // _TS_InvMaskVal の後に説明文を追加する
            new CustomPropertyHook("_TS_InvMaskVal", null, (ctx, changed) => {
                EditorGUILayout.HelpBox(WFI18N.Translate(WFMessageText.PsAntiShadowMask), MessageType.Info);
            }),
            // _HL_MatcapColor の後に説明文を追加する
            new CustomPropertyHook("_HL_MatcapColor(_[0-9]+)?", null, (ctx, changed) => {
                var name = ctx.current.name.Replace("_MatcapColor", "_CapType");
                if (IsAnyIntValue(ctx, name, p => p == 0)) {
                    EditorGUILayout.HelpBox(WFI18N.Translate(WFMessageText.PsCapTypeMedian), MessageType.Info);
                }
                if (IsAnyIntValue(ctx, name, p => p == 1)) {
                    EditorGUILayout.HelpBox(WFI18N.Translate(WFMessageText.PsCapTypeLight), MessageType.Info);
                }
                if (IsAnyIntValue(ctx, name, p => p == 2)) {
                    EditorGUILayout.HelpBox(WFI18N.Translate(WFMessageText.PsCapTypeShade), MessageType.Info);
                }
            }),
        };

        private static bool IsAnyIntValue(PropertyGUIContext ctx, string name, Predicate<int> pred)
        {
            var mats = WFCommonUtility.AsMaterials(ctx.editor.targets).Where(mat => mat.HasProperty(name)).ToArray();
            if (mats.Length == 0)
            {
                return true; // もしプロパティを持つマテリアルがないなら、trueを返却する
            }
            return mats.Any(mat => pred(mat.GetInt(name)));
        }

        public static bool CompareAndSet(MaterialProperty[] prop, string name, int before, int after)
        {
            var target = FindProperty(name, prop, false);
            if (target != null)
            {
                if (target.type == MaterialProperty.PropType.Float || target.type == MaterialProperty.PropType.Range)
                {
                    if (Mathf.RoundToInt(target.floatValue) == before)
                    {
                        target.floatValue = after;
                        return true;
                    }
                }
            }
            return false;
        }

        static class Styles
        {
            public static readonly Texture2D menuTex = LoadTextureByFileName("wf_icon_menu");
        }

        private static Texture2D LoadTextureByFileName(string search_name)
        {
            string[] guids = AssetDatabase.FindAssets(search_name + " t:texture");
            if (guids.Length == 0)
            {
                return Texture2D.whiteTexture;
            }
            return AssetDatabase.LoadAssetAtPath<Texture2D>(AssetDatabase.GUIDToAssetPath(guids[0]));
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            PreChangeShader(material, oldShader, newShader);

            // 割り当て
            var oldMat = new Material(material);
            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            PostChangeShader(oldMat, material, oldShader, newShader);
        }

        public static void PreChangeShader(Material material, Shader oldShader, Shader newShader)
        {
            // nop
        }

        public static void PostChangeShader(Material oldMat, Material newMat, Shader oldShader, Shader newShader)
        {
            if (newMat != null)
            {
                // DebugViewの保存に使っているタグはクリア
                WF_DebugViewEditor.ClearDebugOverrideTag(newMat);
                // シェーダキーワードを整理する
                WFCommonUtility.SetupShaderKeyword(newMat);
                // 他シェーダからの切替時に動作
                if (!WFCommonUtility.IsSupportedShader(oldShader))
                {
                    // Color を sRGB -> Linear 変換して再設定する
                    if (newMat.HasProperty("_Color"))
                    {
#if UNITY_2019_1_OR_NEWER
                        var idx = oldShader.FindPropertyIndex("_Color");
                        if (0 <= idx)
                        {
                            var flags = oldShader.GetPropertyFlags(idx);
                            if (!flags.HasFlag(UnityEngine.Rendering.ShaderPropertyFlags.HDR))
                            {
                                var val = newMat.GetColor("_Color");
                                newMat.SetColor("_Color", val.linear);
                            }
                        }
#else
                        var val = oldMat.GetColor("_Color");
                        newMat.SetColor("_Color", val.linear);
#endif
                    }
                    // もし EmissionColor の Alpha が 0 になっていたら 1 にしちゃう
                    if (newMat.HasProperty("_EmissionColor"))
                    {
                        var val = newMat.GetColor("_EmissionColor");
                        if (val.a < 1e-4)
                        {
                            val.a = 1.0f;
                            newMat.SetColor("_EmissionColor", val);
                        }
                    }
                    // もし FakeFur への切り替えかつ _Cutoff が 0.5 だったら 0.2 を設定しちゃう
                    if (newShader.name.Contains("FakeFur") && newMat.HasProperty("_Cutoff"))
                    {
                        var val = newMat.GetFloat("_Cutoff");
                        if (Mathf.Abs(val - 0.5f) < Mathf.Epsilon)
                        {
                            val = 0.2f;
                            newMat.SetFloat("_Cutoff", val);
                        }
                    }
                }
                else
                {
                    // UnlitWFからの切替時に動作
                    if (oldShader.name.Contains("FakeFur") && newShader.name.Contains("FakeFur"))
                    {
                        // FakeFurどうしの切り替えで、
                        if (!oldShader.name.Contains("_Mix") && newShader.name.Contains("_Mix"))
                        {
                            // Mixへの切り替えならば、FR_Height2とFR_Repeat2を設定する
                            var height = newMat.GetFloat("_FUR_Height");
                            newMat.SetFloat("_FUR_Height2", height * 1.25f);
                            var repeat = newMat.GetInt("_FUR_Repeat");
                            newMat.SetInt("_FUR_Repeat2", Math.Max(1, repeat - 1));
                        }
                    }
                    // 同種シェーダの切替時には RenderQueue をコピーする
                    if (oldShader.renderQueue == newShader.renderQueue && oldMat.renderQueue != oldShader.renderQueue)
                    {
                        newMat.renderQueue = oldMat.renderQueue;
                    }
                }
            }
        }

        public static bool IsSupportedShader(Shader shader)
        {
            return WFCommonUtility.IsSupportedShader(shader) && !shader.name.Contains("WF_DebugView");
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            materialEditor.SetDefaultGUIWidths();

            // 情報(トップ)
            OnGuiSub_ShowCurrentShaderName(materialEditor, false);
            // バリデーション
            OnGUISub_MaterialValidation(materialEditor);

            // 現在無効なラベルを保持するリスト
            var disable = new HashSet<string>();
            // プロパティを順に描画
            foreach (var prop in properties)
            {
                // ラベル付き displayName を、ラベルと名称に分割
                string label, name, disp;
                WFCommonUtility.FormatDispName(prop.displayName, out label, out name, out disp);

                // ラベルが指定されていてdisableに入っているならばスキップ(ただしenable以外)
                if (label != null && disable.Contains(label) && !WFCommonUtility.IsEnableToggle(label, name))
                {
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
                if (WFCommonUtility.IsEnableToggle(label, name))
                {
                    if (WFCommonUtility.IsPropertyTrue(prop.floatValue))
                    {
                        disable.Remove(label);
                    }
                    else
                    {
                        disable.Add(label);
                    }
                }
            }

            DrawShurikenStyleHeader(EditorGUILayout.GetControlRect(false, 32), "Material Options");
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
            materialEditor.DoubleSidedGIField();

            // 情報(ボトム)
            OnGuiSub_ShowCurrentShaderName(materialEditor, true);
            // ユーティリティボタン
            OnGUISub_Utilities(materialEditor);

            // シェーダキーワードを整理する
            WFCommonUtility.SetupShaderKeyword(WFCommonUtility.AsMaterials(materialEditor.targets));
        }

        private void OnGuiSub_ShaderProperty(PropertyGUIContext context)
        {
            // 更新チェック
            EditorGUI.BeginChangeCheck();

            // フック
            foreach (var hook in HOOKS)
            {
                hook.OnBefore(context);
            }

            // プロパティ表示
            if (!context.hidden && !context.custom)
            {
                // プロパティ表示
                context.editor.ShaderProperty(context.current, context.guiContent);
                // Colorについては追加で出力
                if (context.current.type == MaterialProperty.PropType.Color)
                {
                    DrawAdditionalColorCodeField(context.current);
                }
            }

            // チェック終了
            bool changed = EditorGUI.EndChangeCheck();

            // フック
            foreach (var hook in HOOKS)
            {
                hook.OnAfter(context, changed);
            }
        }

        private void OnGuiSub_ShowCurrentShaderName(MaterialEditor materialEditor, bool isBottom)
        {
            var mat = materialEditor.target as Material;
            if (mat == null)
            {
                return;
            }
            if (isBottom != WFEditorPrefs.MenuToBottom)
            {
                return;
            }
            if (isBottom)
            {
                DrawShurikenStyleHeader(EditorGUILayout.GetControlRect(false, 32), "Information");
            }

            // シェーダ名の表示
            var rect = EditorGUILayout.GetControlRect();
            rect.y += 2;
            GUI.Label(rect, "Current Shader", EditorStyles.boldLabel);
            GUILayout.Label(new Regex(@".*/").Replace(mat.shader.name, ""));

            // シェーダ名辞書を参照
            var snm = WFShaderNameDictionary.TryFindFromName(mat.shader.name);

            // CurrentVersion プロパティがあるなら表示
            var currentVersion = WFAccessor.GetShaderCurrentVersion(mat);
            if (!string.IsNullOrWhiteSpace(currentVersion))
            {
                rect = EditorGUILayout.GetControlRect();
                rect.y += 2;
                GUI.Label(rect, "Current Version", EditorStyles.boldLabel);
                GUILayout.Label(currentVersion);

                // もしシェーダ名辞書にあって新しいバージョンがリリースされているならばボタンを表示
                if (snm != null && WFCommonUtility.IsOlderShaderVersion(currentVersion) && !WFCommonUtility.IsInSpecialProject())
                {
                    var message = WFI18N.Translate(WFMessageText.NewerVersion) + WFCommonUtility.GetLatestVersion()?.latestVersion;
                    if (materialEditor.HelpBoxWithButton(ToolCommon.GetMessageContent(MessageType.Info, message), new GUIContent("Go")))
                    {
                        WFCommonUtility.OpenDownloadPage();
                    }
                }
            }

            // シェーダ切り替えボタン
            if (snm != null)
            {
                var targets = WFCommonUtility.AsMaterials(materialEditor.targets);

                rect = EditorGUILayout.GetControlRect();
                rect.y += 2;
                GUI.Label(rect, "Current Shader Variants", EditorStyles.boldLabel);

                // 一時的にフィールド幅を変更
                EditorGUIUtility.labelWidth = 0;

                // バリアントリストを作成
                WFVariantList lists = WFShaderNameDictionary.CreateVariantList(snm);

                // ファミリー
                {
                    EditorGUI.BeginChangeCheck();
                    int idxFamily = EditorGUILayout.Popup("Family", lists.idxFamily, lists.LabelFamilyList);
                    if (EditorGUI.EndChangeCheck() && lists.idxFamily != idxFamily)
                    {
                        WFCommonUtility.ChangeShader(lists.familyList[idxFamily].Name, targets);
                    }
                }
                // バリアント
                {
                    EditorGUI.BeginChangeCheck();
                    int idxVariant = EditorGUILayout.Popup("Variant", lists.idxVariant, lists.LabelVariantList);
                    if (EditorGUI.EndChangeCheck() && lists.idxVariant != idxVariant)
                    {
                        WFCommonUtility.ChangeShader(lists.variantList[idxVariant].Name, targets);
                    }
                }
                // Render Type
                {
                    EditorGUI.BeginChangeCheck();
                    int idxRenderType = EditorGUILayout.Popup("RenderType", lists.idxRenderType, lists.LabelRenderTypeList);
                    if (EditorGUI.EndChangeCheck() && lists.idxRenderType != idxRenderType)
                    {
                        WFCommonUtility.ChangeShader(lists.renderTypeList[idxRenderType].Name, targets);
                    }
                }

                // フィールド幅を戻す
                materialEditor.SetDefaultGUIWidths();
            }
        }

        private struct GuidAndPath
        {
            public string guid;
            public string path;
            public string name;

            public GuidAndPath(string guid)
            {
                this.guid = guid;
                this.path = AssetDatabase.GUIDToAssetPath(guid) ?? "";
                this.name = string.IsNullOrWhiteSpace(path) ? "" : new Regex(@"^.*/|\.[^\.]+$").Replace(this.path, "");
            }
        }

        private static void OnGUISub_Utilities(MaterialEditor materialEditor)
        {
            EditorGUILayout.Space();
            DrawShurikenStyleHeader(EditorGUILayout.GetControlRect(false, 32), "Utility");

            // テンプレート
            var rect = EditorGUILayout.GetControlRect();
            if (GUI.Button(rect, WFI18N.GetGUIContent(WFMessageButton.ApplyTemplate)))
            {
                // WFMaterialTemplate を検索
                var guids = AssetDatabase.FindAssets("t:" + typeof(WFMaterialTemplate))
                    .Select(guid => new GuidAndPath(guid))
                    .Where(guid => !string.IsNullOrWhiteSpace(guid.path))
                    .OrderBy(guid => guid.name);
                // メニュー作成
                var menu = new GenericMenu();
                foreach (var guid in guids)
                {
                    menu.AddItem(new GUIContent(guid.name), false, () =>
                    {
                        var temp = AssetDatabase.LoadAssetAtPath<WFMaterialTemplate>(guid.path);
                        if (temp != null)
                        {
                            temp.ApplyToMaterial(WFCommonUtility.AsMaterials(materialEditor.targets));
                        }
                    });
                }
                menu.AddSeparator("");
                if (materialEditor.targets.Length <= 1)
                {
                    menu.AddItem(WFI18N.GetGUIContent(WFMessageButton.SaveTemplate), false, () =>
                    {
                        WFMaterialTemplate.CreateAsset(materialEditor.target as Material);
                    });
                }
                else
                {
                    menu.AddDisabledItem(WFI18N.GetGUIContent(WFMessageButton.SaveTemplate));
                }

                menu.DropDown(rect);
            }

            // クリンナップ
            if (ButtonWithDropdownList(WFI18N.GetGUIContent(WFMessageButton.Cleanup), new string[] { "Open Cleanup Utility" }, idx =>
            {
                switch (idx)
                {
                    case 0:
                        ToolCreanUpWindow.OpenWindowFromShaderGUI(WFCommonUtility.AsMaterials(materialEditor.targets));
                        break;
                    default:
                        break;
                }
            }))
            {
                var param = CleanUpParameter.Create();
                param.materials = WFCommonUtility.AsMaterials(materialEditor.targets);
                WFMaterialEditUtility.CleanUpProperties(param);
            }

            // ライトマップ非表示
            //var hideLmap = WFCommonUtility.IsKwdEnableHideLmap();
            //EditorGUI.BeginChangeCheck();
            //hideLmap = EditorGUILayout.Toggle("ライトマップを非表示", hideLmap);
            //if (EditorGUI.EndChangeCheck())
            //{
            //    WFCommonUtility.SetKwdEnableHideLmap(hideLmap);
            //}

            EditorGUILayout.Space();

            WFEditorPrefs.LangMode = (EditorLanguage)EditorGUILayout.EnumPopup("Editor language", WFEditorPrefs.LangMode);
            WFEditorPrefs.MenuToBottom = EditorGUILayout.Toggle("Menu To Bottom", WFEditorPrefs.MenuToBottom);
        }

        private static void OnGUISub_MaterialValidation(MaterialEditor materialEditor)
        {
            var targets = WFCommonUtility.AsMaterials(materialEditor.targets);
            foreach (var advice in WFMaterialValidators.ValidateAll(targets))
            {
                if (advice.action != null)
                {
                    // 修正 action ありの場合はボタン付き
                    var messageContent = ToolCommon.GetMessageContent(advice.messageType, advice.message);
                    if (materialEditor.HelpBoxWithButton(messageContent, new GUIContent("Fix Now")))
                    {
                        advice.action();
                    }
                }
                else
                {
                    // 修正 action なしの場合はボタンなし
                    EditorGUILayout.HelpBox(advice.message, advice.messageType, true);
                }
            }
        }

        private static void SuggestShadowColor(Material[] mats)
        {
            Undo.RecordObjects(mats, "shade color change");

            foreach (var m in mats)
            {
                // ベース色を取得
                Color baseColor = m.GetColor("_TS_BaseColor");
                float hur, sat, val;
                Color.RGBToHSV(baseColor, out hur, out sat, out val);

                // もし val が 0.7 未満ならばベース色を明るめに再設定する
                if (val < 0.7f)
                {
                    val = 0.7f;
                    m.SetColor("_TS_BaseColor", Color.HSVToRGB(hur, sat, val));
                }

                // 段数を取得
                var steps = GetShadowStepsFromMaterial(m);
                switch (steps)
                {
                    case 1:
                        if (m.HasProperty("_TS_1stColor"))
                        {
                            m.SetColor("_TS_1stColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f));
                        }
                        break;
                    default:
                        if (m.HasProperty("_TS_1stColor"))
                        {
                            m.SetColor("_TS_1stColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.6f), sat + 0.1f, val * 0.9f));
                        }
                        if (m.HasProperty("_TS_2ndColor"))
                        {
                            m.SetColor("_TS_2ndColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f));
                        }
                        break;
                    case 3:
                        if (m.HasProperty("_TS_1stColor"))
                        {
                            m.SetColor("_TS_1stColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.6f), sat + 0.1f, val * 0.9f));
                        }
                        if (m.HasProperty("_TS_2ndColor"))
                        {
                            m.SetColor("_TS_2ndColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.8f));
                        }
                        if (m.HasProperty("_TS_3rdColor"))
                        {
                            m.SetColor("_TS_3rdColor", Color.HSVToRGB(ShiftHur(hur, sat, 0.4f), sat + 0.15f, val * 0.7f));
                        }
                        break;
                }
            }
        }

        private static void SuggestShadowBorder(Material[] mats)
        {
            Undo.RecordObjects(mats, "shade border change");

            foreach (var m in mats)
            {
                // 段数を取得
                var steps = GetShadowStepsFromMaterial(m);
                // 1影
                var pos1 = m.GetFloat("_TS_1stBorder");
                // 2影
                if (2 <= steps && m.HasProperty("_TS_2ndBorder"))
                {
                    m.SetFloat("_TS_2ndBorder", pos1 * (steps - 1.0f) / steps);
                }
                // 3影
                if (2 <= steps && m.HasProperty("_TS_3rdBorder"))
                {
                    m.SetFloat("_TS_3rdBorder", pos1 * (steps - 2.0f) / steps);
                }
            }
        }

        private static int GetShadowStepsFromMaterial(Material[] mat)
        {
            if (mat.Length < 1)
            {
                return 2;
            }
            return mat.Select(GetShadowStepsFromMaterial).Max();
        }

        private static int GetShadowStepsFromMaterial(Material mat)
        {
            var steps = mat.HasProperty("_TS_Steps") ? mat.GetInt("_TS_Steps") : 0;
            if (steps <= 0)
            {
                return 2; // _TS_Stepsが無いとき、あっても初期値のときは2段
            }
            return steps;
        }

        private static float ShiftHur(float hur, float sat, float mul)
        {
            if (sat < 0.05f)
            {
                return 4 / 6f;
            }
            // R = 0/6f, G = 2/6f, B = 4/6f
            float[] COLOR = { 0 / 6f, 2 / 6f, 4 / 6f, 6 / 6f };
            // Y = 1/6f, C = 3/6f, M = 5/6f
            float[] LIMIT = { 1 / 6f, 3 / 6f, 5 / 6f, 10000 };
            for (int i = 0; i < COLOR.Length; i++)
            {
                if (hur < LIMIT[i])
                {
                    return (hur - COLOR[i]) * mul + COLOR[i];
                }
            }
            return hur;
        }

        #region GUI部品

        private static void SetStyleFont(GUIStyle style, Font font, System.Func<int, int> fontSize, FontStyle fontStyle)
        {
            if (font != null)
            {
                // フォントが指定されているならそれを設定
                style.font = font;
            }
            else if (style.font == null)
            {
                // フォントが null かつ、設定先も null ならば GUI.skin を設定
                style.font = GUI.skin.font;
            }
            // ダイナミックフォントの場合に有効なプロパティを設定
            if (style.font.dynamic)
            {
                style.fontSize = fontSize(style.fontSize != 0 ? style.fontSize : style.font.fontSize);
                style.fontStyle = fontStyle;
            }
        }

        /// <summary>
        /// Shurikenスタイルのヘッダを表示する
        /// </summary>
        /// <param name="position">位置</param>
        /// <param name="text">テキスト</param>
        /// <param name="prop">EnableトグルのProperty(またはnull)</param>
        /// <param name="alwaysOn">常時trueにするならばtrue、デフォルトはfalse</param>
        public static Rect DrawShurikenStyleHeader(Rect position, string text, GenericMenu menu = null)
        {
            var content = new GUIContent(text);

            // SurikenStyleHeader
            var style = new GUIStyle("ShurikenModuleTitle");
            SetStyleFont(style, EditorStyles.boldLabel.font, s => s + 2, FontStyle.Bold);
            style.fixedHeight = 20;
            style.contentOffset = new Vector2(20, -2);
            // Draw
            position.y += 8;
            position = EditorGUI.IndentedRect(position);
            GUI.Box(position, content, style);

            // ヘルプテキスト
            if (WFI18N.TryTranslate(text, out var helpText)) {
                var titleSize = style.CalcSize(content);
                var rect = new Rect(position.x + titleSize.x + 24, position.y, position.width - titleSize.x - 24, 16f);
                var style2 = new GUIStyle(EditorStyles.label);
                SetStyleFont(style2, null, s => style.fontSize - 1, FontStyle.Normal);
                style2.contentOffset = new Vector2(4, 1);
                GUI.Label(rect, helpText, style2);
            }

            // コンテキストメニュー
            if (menu != null)
            {
                var rect = new Rect(position.x + position.width - 20f, position.y + 1f, 16f, 16f);
                if (GUI.Button(rect, Styles.menuTex, EditorStyles.largeLabel))
                {
                    Event.current.Use();
                    menu.DropDown(rect);
                }
            }

            return position;
        }

        /// <summary>
        /// Shurikenスタイルのヘッダを表示する
        /// </summary>
        /// <param name="position">位置</param>
        /// <param name="text">テキスト</param>
        /// <param name="prop">EnableトグルのProperty(またはnull)</param>
        /// <param name="alwaysOn">常時trueにするならばtrue、デフォルトはfalse</param>
        public static Rect DrawShurikenStyleHeaderToggle(Rect position, string text, MaterialProperty prop, bool alwaysOn, GenericMenu menu = null)
        {
            position = DrawShurikenStyleHeader(position, text, menu);

            if (alwaysOn)
            {
                if (prop.hasMixedValue || prop.floatValue == 0.0f)
                {
                    prop.floatValue = 1.0f;
                }
            }
            else
            {
                bool value = WFCommonUtility.IsPropertyTrue(prop.floatValue);

                // Toggle
                {
                    Rect rect = EditorGUILayout.GetControlRect(true, 0, EditorStyles.layerMaskField);
                    rect.y -= 25;
                    rect.width -= 40;
                    rect.height = MaterialEditor.GetDefaultPropertyHeight(prop);

                    EditorGUI.showMixedValue = prop.hasMixedValue;
                    EditorGUI.BeginChangeCheck();
                    value = EditorGUI.Toggle(rect, " ", value);
                    if (EditorGUI.EndChangeCheck())
                    {
                        prop.floatValue = value ? 1.0f : 0.0f;
                    }
                    EditorGUI.showMixedValue = false;
                }

                // ▼
                {
                    var rect = new Rect(position.x + 4f, position.y + 2f, 13f, 13f);
                    if (Event.current.type == EventType.Repaint)
                    {
                        EditorStyles.foldout.Draw(rect, false, false, value, false);
                    }
                }
            }

            return position;
        }

        /// <summary>
        /// テクスチャとカラーを1行で表示する。
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="label"></param>
        /// <param name="propColor"></param>
        /// <param name="propTexture"></param>
        public static void DrawSingleLineTextureProperty(MaterialEditor materialEditor, GUIContent label, MaterialProperty propColor, MaterialProperty propTexture)
        {
            EditorGUI.BeginChangeCheck();
            var oldTexture = propTexture.textureValue;

            // 1行テクスチャプロパティ
            materialEditor.TexturePropertySingleLine(label, propTexture, propColor);
            // 追加のカラーコードフィールド
            DrawAdditionalColorCodeField(propColor);

            // もしテクスチャが新たに設定されたならば、カラーを白にリセットする
            if (EditorGUI.EndChangeCheck() && oldTexture == null && propTexture.textureValue != null)
            {
                propColor.colorValue = Color.white;
            }

            // もし NoScaleOffset がないなら ScaleOffset も追加で表示する
            if (!propTexture.flags.HasFlag(MaterialProperty.PropFlags.NoScaleOffset))
            {
                using (new EditorGUI.IndentLevelScope())
                {
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
        public static void DrawMinMaxProperty(MaterialEditor materialEditor, GUIContent label, MaterialProperty propMin, MaterialProperty propMax)
        {
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
            rect.x += oldLabelWidth + 2;
            minValue = EditorGUI.FloatField(rect, minValue);

            // propMax の FloatField

            rect.x += EditorGUIUtility.fieldWidth / 2 + 2;
            maxValue = EditorGUI.FloatField(rect, maxValue);

            EditorGUI.showMixedValue = false;
            EditorGUIUtility.labelWidth = oldLabelWidth;

            if (EditorGUI.EndChangeCheck())
            {
                if (propMin.type == MaterialProperty.PropType.Range)
                {
                    propMin.floatValue = Mathf.Clamp(minValue, propMinLimit.x, propMinLimit.y);
                }
                else
                {
                    propMin.floatValue = minValue;
                }
                if (propMax.type == MaterialProperty.PropType.Range)
                {
                    propMax.floatValue = Mathf.Clamp(maxValue, propMaxLimit.x, propMaxLimit.y);
                }
                else
                {
                    propMax.floatValue = maxValue;
                }
            }
        }

        public static void DrawZWriteProperty(MaterialEditor materialEditor, GUIContent label, MaterialProperty front, MaterialProperty back)
        {
            var value = front.floatValue < 0.001 ? 0 : back.floatValue < 0.001 ? 1 : 2;

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = front.hasMixedValue || back.hasMixedValue;

            value = EditorGUILayout.Popup(label, value, new string[] { "OFF", "ON", "TwoSided" });

            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                front.floatValue = value != 0 ? 1 : 0;
                back.floatValue = value == 2 ? 1 : 0;
            }
        }

        /// <summary>
        /// ラベル付きボタンフィールドを表示する。
        /// </summary>
        /// <param name="label"></param>
        /// <param name="buttonText"></param>
        /// <returns></returns>
        public static bool DrawButtonFieldProperty(GUIContent label, string buttonText)
        {
            Rect rect = EditorGUILayout.GetControlRect(true, 20);
            rect.y += 1;
            rect = EditorGUI.PrefixLabel(rect, label);
            rect.y -= 2;
            rect.height = 18;
            return GUI.Button(rect, buttonText);
        }

        /// <summary>
        /// 追加のカラーコードテキストフィールドを表示する。
        /// </summary>
        /// <param name="propColor"></param>
        public static void DrawAdditionalColorCodeField(MaterialProperty propColor)
        {
            var color = propColor.colorValue;
            var isHdr = (propColor.flags & MaterialProperty.PropFlags.HDR) != 0;
            var intensity = isHdr ? Mathf.Max(1f, color.maxColorComponent) : 1f;

            var color2 = color;
            color2.r /= intensity;
            color2.g /= intensity;
            color2.b /= intensity;
            var code = ColorUtility.ToHtmlStringRGB(color2);

            // 位置合わせ
            var rect2 = GUILayoutUtility.GetLastRect();
            rect2.x = rect2.xMax - EditorGUIUtility.fieldWidth * 2 - 4;
            rect2.y += Mathf.Max(0, rect2.height - 18);
            rect2.width = EditorGUIUtility.fieldWidth;
            rect2.height = 16;

            var style = new GUIStyle(EditorStyles.miniTextField);
            SetStyleFont(style, null, s => s - 1, FontStyle.Normal);

            // 表示
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = propColor.hasMixedValue;
            code = EditorGUI.DelayedTextField(rect2, code, style);
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                // 回収
                if (ColorUtility.TryParseHtmlString(code, out color) || ColorUtility.TryParseHtmlString("#" + code, out color))
                {
                    color.r *= intensity;
                    color.g *= intensity;
                    color.b *= intensity;
                    propColor.colorValue = color;
                }
            }
        }

        internal static bool ButtonWithDropdownList(GUIContent content, Action<Rect> openMenuCallback)
        {
            var style = new GUIStyle("DropDownButton");
            var rect = EditorGUILayout.GetControlRect(false, 20, style);

            var dropDownRect = rect;
            const float kDropDownButtonWidth = 20f;
            dropDownRect.xMin = dropDownRect.xMax - kDropDownButtonWidth;

            if (Event.current.type == EventType.MouseDown && dropDownRect.Contains(Event.current.mousePosition))
            {
                openMenuCallback(rect);
                Event.current.Use();
                return false;
            }

            return GUI.Button(rect, content, style);
        }

        internal static bool ButtonWithDropdownList(GUIContent content, string[] buttonNames, GenericMenu.MenuFunction2 selectMenuCallback)
        {
            return ButtonWithDropdownList(content, rect =>
            {
                var menu = new GenericMenu();
                for (int i = 0; i != buttonNames.Length; i++)
                {
                    menu.AddItem(new GUIContent(buttonNames[i]), false, selectMenuCallback, i);
                }
                menu.DropDown(rect);
            });
        }

#endregion

#region PropertyHook

        /// <summary>
        /// PropertyHookで使用する表示コンテキスト
        /// </summary>
        class PropertyGUIContext
        {
            /// <summary>
            /// 動作中のMaterialEditor
            /// </summary>
            public readonly MaterialEditor editor;
            /// <summary>
            /// 全てのMaterialProperty
            /// </summary>
            public readonly MaterialProperty[] all;
            /// <summary>
            /// 現在表示しようとしているMaterialProperty
            /// </summary>
            public readonly MaterialProperty current;

            /// <summary>
            /// 表示するMaterialPropertyのGUIContent。Hook内から変更することもできる。
            /// </summary>
            public GUIContent guiContent = null;
            /// <summary>
            /// 非表示にするときにHook内からtrueにする。
            /// </summary>
            public bool hidden = false;
            /// <summary>
            /// Hook内で独自にGUIを表示したとき(つまりデフォルトのShaderProperty呼び出しが不要なとき)にHook内からtrueにする。
            /// </summary>
            public bool custom = false;

            public PropertyGUIContext(MaterialEditor editor, MaterialProperty[] all, MaterialProperty current)
            {
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

            protected AbstractPropertyHook(string pattern)
            {
                this.matcher = new Regex(@"^(" + pattern + @")$", RegexOptions.Compiled);
            }

            public void OnBefore(PropertyGUIContext context)
            {
                if (matcher.IsMatch(context.current.name))
                {
                    OnBeforeProp(context);
                }
            }

            public void OnAfter(PropertyGUIContext context, bool changed)
            {
                if (matcher.IsMatch(context.current.name))
                {
                    OnAfterProp(context, changed);
                }
            }

            protected virtual void OnBeforeProp(PropertyGUIContext context)
            {

            }

            protected virtual void OnAfterProp(PropertyGUIContext context, bool changed)
            {

            }
        }

        /// <summary>
        /// テクスチャとカラーを1行のプロパティで表示する
        /// </summary>
        class SingleLineTexPropertyHook : AbstractPropertyHook
        {
            private readonly string colName;
            private readonly string texName;

            public SingleLineTexPropertyHook(string colName, string texName) : base(colName + "|" + texName)
            {
                this.colName = colName;
                this.texName = texName;
            }

            protected override void OnBeforeProp(PropertyGUIContext context)
            {
                if (context.hidden)
                {
                    return;
                }
                if (colName == context.current.name)
                {
                    // テクスチャとカラーを1行で表示する
                    MaterialProperty another = FindProperty(texName, context.all, false);
                    if (another != null)
                    {
                        DrawSingleLineTextureProperty(context.editor, context.guiContent, context.current, another);
                        context.custom = true;
                    }
                    else
                    {
                        // 相方がいない場合は単独で表示する (Mobile系の_TS_1stColorなどで発生)
                        context.custom = false;
                    }
                }
                else
                {
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
            private readonly string displayName;

            public MinMaxSliderPropertyHook(string minName, string maxName, string displayName = null) : base(minName + "|" + maxName)
            {
                this.minName = minName;
                this.maxName = maxName;
                this.displayName = displayName;
            }

            protected override void OnBeforeProp(PropertyGUIContext context)
            {
                if (context.hidden)
                {
                    return;
                }
                if (minName == context.current.name)
                {
                    // MinMaxSlider
                    MaterialProperty another = FindProperty(maxName, context.all, false);
                    if (another != null)
                    {
                        var display = string.IsNullOrWhiteSpace(displayName) ? context.guiContent : WFI18N.GetGUIContent(displayName);
                        DrawMinMaxProperty(context.editor, display, context.current, another);
                    }
                }
                context.custom = true;
                // 相方の側は何もしない
            }
        }

        /// <summary>
        /// ZWrite と ZWriteBack をひとつのプロパティとして表示する
        /// </summary>
        class ZWriteFrontBackPropertyHook : AbstractPropertyHook
        {
            private readonly string frontName;
            private readonly string backName;
            private readonly string displayName;

            public ZWriteFrontBackPropertyHook(string frontName, string backName, string displayName = null) : base(frontName + "|" + backName)
            {
                this.frontName = frontName;
                this.backName = backName;
                this.displayName = displayName;
            }

            protected override void OnBeforeProp(PropertyGUIContext context)
            {
                if (context.hidden)
                {
                    return;
                }
                if (frontName == context.current.name)
                {
                    MaterialProperty another = FindProperty(backName, context.all, false);
                    if (another != null)
                    {
                        var display = string.IsNullOrWhiteSpace(displayName) ? context.guiContent : WFI18N.GetGUIContent(displayName);
                        DrawZWriteProperty(context.editor, display, context.current, another);
                        context.custom = true;
                    }
                    else
                    {
                        // 相方がいない場合は単独で表示する
                        context.custom = false;
                    }
                }
                else
                {
                    // 相方の側は何もしない
                    context.custom = true;
                }
            }
        }

        /// <summary>
        /// 特定のプロパティが変更されたときに、他のプロパティのデフォルト値を設定する
        /// </summary>
        class DefValueSetPropertyHook : AbstractPropertyHook
        {
            public delegate void DefValueSetDelegate(PropertyGUIContext context);

            private readonly DefValueSetDelegate setter;

            public DefValueSetPropertyHook(string name, DefValueSetDelegate setter) : base(name)
            {
                this.setter = setter;
            }

            protected override void OnAfterProp(PropertyGUIContext context, bool changed)
            {
                if (changed)
                {
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

            public ConditionVisiblePropertyHook(string pattern, Predicate<PropertyGUIContext> pred) : base(pattern)
            {
                this.pred = pred;
            }

            protected override void OnBeforeProp(PropertyGUIContext context)
            {
                if (!pred(context))
                {
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

            public CustomPropertyHook(string pattern, OnBeforeDelegate before, OnAfterDelegate after) : base(pattern)
            {
                this.before = before;
                this.after = after;
            }

            protected override void OnBeforeProp(PropertyGUIContext context)
            {
                if (before != null)
                {
                    before(context);
                }
            }

            protected override void OnAfterProp(PropertyGUIContext context, bool changed)
            {
                if (after != null)
                {
                    after(context, changed);
                }
            }
        }

#endregion
    }

#region MaterialPropertyDrawer

    internal static class WFHeaderMenuController
    {
        private static Material copiedMaterial = null;

        public static GenericMenu GenerateMenuOrNull(MaterialEditor editor, MaterialProperty prop)
        {
            var prefix = WFCommonUtility.GetPrefixFromPropName(prop.name);
            if (string.IsNullOrWhiteSpace(prefix))
            {
                return null;
            }

            var menu = new GenericMenu();
            menu.AddItem(WFI18N.GetGUIContent("Copy material"), false, () =>
            {
                if (editor.target is Material)
                {
                    copiedMaterial = new Material((Material)editor.target);
                }
                else
                {
                    copiedMaterial = null;
                }
            });
            if (copiedMaterial != null)
            {
                menu.AddItem(WFI18N.GetGUIContent("Paste value"), false, () =>
                {
                    var param = CopyPropParameter.Create();
                    param.materialSource = copiedMaterial;
                    param.materialDestination = WFCommonUtility.AsMaterials(editor.targets);
                    param.prefixs = new string[] { prefix };
                    WFMaterialEditUtility.CopyProperties(param);
                });
                menu.AddItem(WFI18N.GetGUIContent("Paste (without Textures)"), false, () =>
                {
                    var param = CopyPropParameter.Create();
                    param.materialSource = copiedMaterial;
                    param.materialDestination = WFCommonUtility.AsMaterials(editor.targets);
                    param.prefixs = new string[] { prefix };
                    param.withoutTextures = true;
                    WFMaterialEditUtility.CopyProperties(param);
                });
            }
            else
            {
                menu.AddDisabledItem(WFI18N.GetGUIContent("Paste value"));
                menu.AddDisabledItem(WFI18N.GetGUIContent("Paste (without Textures)"));
            }
            menu.AddSeparator("");
            menu.AddItem(WFI18N.GetGUIContent("Reset"), false, () =>
            {
                var param = ResetParameter.Create();
                param.materials = WFCommonUtility.AsMaterials(editor.targets);
                param.resetPrefixs = new string[] { prefix };
                WFMaterialEditUtility.ResetProperties(param);
            });

            return menu;
        }
    }

    /// <summary>
    /// Shurikenヘッダを表示する
    /// </summary>
    internal class MaterialWFHeaderDecorator : MaterialPropertyDrawer
    {
        public readonly string text;

        public MaterialWFHeaderDecorator(string text)
        {
            this.text = text;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 32;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            ShaderCustomEditor.DrawShurikenStyleHeader(position, text, WFHeaderMenuController.GenerateMenuOrNull(editor, prop));
        }
    }

    /// <summary>
    /// Enableトグル付きのShurikenヘッダを表示する
    /// </summary>
    internal class MaterialWFHeaderToggleDrawer : MaterialPropertyDrawer
    {
        public readonly string text;

        public MaterialWFHeaderToggleDrawer(string text)
        {
            this.text = text;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 32;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            ShaderCustomEditor.DrawShurikenStyleHeaderToggle(position, text, prop, false, WFHeaderMenuController.GenerateMenuOrNull(editor, prop));
        }
    }

    /// <summary>
    /// 常時trueなEnableトグル付きのShurikenヘッダを表示する
    /// </summary>
    internal class MaterialWFHeaderAlwaysOnDrawer : MaterialPropertyDrawer
    {
        public readonly string text;

        public MaterialWFHeaderAlwaysOnDrawer(string text)
        {
            this.text = text;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 32;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            ShaderCustomEditor.DrawShurikenStyleHeaderToggle(position, text, prop, true, WFHeaderMenuController.GenerateMenuOrNull(editor, prop));
        }
    }

    [Obsolete]
    internal class MaterialFixFloatDrawer : MaterialWF_FixFloatDrawer
    {
        public MaterialFixFloatDrawer() : base()
        {
        }

        public MaterialFixFloatDrawer(float value) : base(value)
        {
        }
    }

    /// <summary>
    /// 常に指定のfloat値にプロパティを固定する、非表示のPropertyDrawer
    /// </summary>
    internal class MaterialWF_FixFloatDrawer : MaterialPropertyDrawer
    {
        public readonly float value;

        public MaterialWF_FixFloatDrawer()
        {
            this.value = 0;
        }

        public MaterialWF_FixFloatDrawer(float value)
        {
            this.value = value;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
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
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            prop.textureValue = null;
        }
    }

    /// <summary>
    /// 入力欄が2個あるVectorのPropertyDrawer
    /// </summary>
    internal class MaterialWF_Vector2Drawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return base.GetPropertyHeight(prop, label, editor) * 2;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;
            EditorGUI.showMixedValue = prop.hasMixedValue;

            Vector2 value = prop.vectorValue;
            EditorGUI.BeginChangeCheck();
            value = EditorGUI.Vector2Field(position, label, value);
            if (EditorGUI.EndChangeCheck())
            {
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
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return base.GetPropertyHeight(prop, label, editor) * 2;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;
            EditorGUI.showMixedValue = prop.hasMixedValue;

            Vector3 value = prop.vectorValue;
            EditorGUI.BeginChangeCheck();
            value = EditorGUI.Vector3Field(position, label, value);
            if (EditorGUI.EndChangeCheck())
            {
                prop.vectorValue = new Vector4(value.x, value.y, value.z, 0);
            }

            EditorGUI.showMixedValue = false;
            EditorGUIUtility.labelWidth = oldLabelWidth;
        }
    }

    /// <summary>
    /// sin/cos計算済みDirectionのPropertyDrawer
    /// </summary>
    internal class MaterialWF_RotMatrixDrawer : MaterialPropertyDrawer
    {
        public readonly float min;
        public readonly float max;

        public MaterialWF_RotMatrixDrawer()
        {
            this.min = 0;
            this.max = 360;
        }

        public MaterialWF_RotMatrixDrawer(float min, float max)
        {
            this.min = min;
            this.max = max;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            var value = prop.vectorValue;

            float oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;

            EditorGUI.showMixedValue = prop.hasMixedValue;
            EditorGUI.BeginChangeCheck();
            value.x = EditorGUI.Slider(position, label, value.x, min, max);
            if (EditorGUI.EndChangeCheck())
            {
                value.y = Mathf.Sin(Mathf.Deg2Rad * value.x);
                value.z = Mathf.Cos(Mathf.Deg2Rad * value.x);
                value.w = 0;
                prop.vectorValue = value;
            }
            EditorGUI.showMixedValue = false;

            EditorGUIUtility.labelWidth = oldLabelWidth;
        }
    }

    /// <summary>
    /// 常に指定のfloat値にプロパティを固定する、非活性Toggle表示のPropertyDrawer
    /// </summary>
    internal class MaterialWF_FixUIToggleDrawer : MaterialPropertyDrawer
    {
        public readonly float value;

        public MaterialWF_FixUIToggleDrawer()
        {
            this.value = 0;
        }

        public MaterialWF_FixUIToggleDrawer(float value)
        {
            this.value = value;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            prop.floatValue = this.value;
            bool value = (Math.Abs(prop.floatValue) > 0.001f);

            EditorGUI.LabelField(position, label);
            using (new EditorGUI.DisabledGroupScope(true))
            {
                EditorGUI.Toggle(position, " ", value);
            }
        }
    }

    /// <summary>
    /// 常に非表示のMaterialPropertyDrawer
    /// </summary>
    internal class MaterialWF_HidePropDrawer : MaterialPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
        }
    }

    internal class MaterialWF_EnumDrawer : MaterialPropertyDrawer
    {
        private readonly string enumName;
        private readonly string[] names;
        private readonly int[] values;

        public MaterialWF_EnumDrawer(string enumName)
        {
            this.enumName = enumName;
            ReadEnumValue(enumName, out this.names, out this.values);
        }

        public MaterialWF_EnumDrawer(string enumName, string e1) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1);
        }
        public MaterialWF_EnumDrawer(string enumName, string e1, string e2) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1, e2);
        }
        public MaterialWF_EnumDrawer(string enumName, string e1, string e2, string e3) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1, e2, e3);
        }
        public MaterialWF_EnumDrawer(string enumName, string e1, string e2, string e3, string e4) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1, e2, e3, e4);
        }
        public MaterialWF_EnumDrawer(string enumName, string e1, string e2, string e3, string e4, string e5) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1, e2, e3, e4, e5);
        }
        public MaterialWF_EnumDrawer(string enumName, string e1, string e2, string e3, string e4, string e5, string e6) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1, e2, e3, e4, e5, e6);
        }
        public MaterialWF_EnumDrawer(string enumName, string e1, string e2, string e3, string e4, string e5, string e6, string e7) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1, e2, e3, e4, e5, e6, e7);
        }
        public MaterialWF_EnumDrawer(string enumName, string e1, string e2, string e3, string e4, string e5, string e6, string e7, string e8) : this(enumName)
        {
            FilterEnumValue(ref this.names, ref this.values, e1, e2, e3, e4, e5, e6, e7, e8);
        }

        private static void ReadEnumValue(string enumName, out string[] names, out int[] values)
        {
            var loadedTypes = GetTypesDerivedFrom(typeof(Enum));
            try
            {
                var enumType = loadedTypes.FirstOrDefault(x => x.Name == enumName || x.FullName == enumName);
                var enumNames = Enum.GetNames(enumType);
                names = new string[enumNames.Length];
                for (int i = 0; i < enumNames.Length; ++i)
                {
                    names[i] = enumNames[i];
                }
                var enumVals = Enum.GetValues(enumType);
                values = new int[enumVals.Length];
                for (var i = 0; i < enumVals.Length; ++i)
                {
                    values[i] = (int)enumVals.GetValue(i);
                }
            }
            catch (Exception)
            {
                Debug.LogWarningFormat("Failed to create MaterialEnum, enum {0} not found", enumName);
                throw;
            }
        }

        private static IEnumerable<Type> GetTypesDerivedFrom(Type type)
        {
#if UNITY_2019_1_OR_NEWER
            return TypeCache.GetTypesDerivedFrom(type);
#else
            var types = new List<Type>();
            var assemblies = AppDomain.CurrentDomain.GetAssemblies();
            foreach (var assembly in assemblies)
            {
                Type[] allAssemblyTypes;
                try
                {
                    allAssemblyTypes = assembly.GetTypes();
                }
                catch (System.Reflection.ReflectionTypeLoadException e)
                {
                    allAssemblyTypes = e.Types;
                }

                var typesInAssembly = allAssemblyTypes.Where(t => !t.IsAbstract && t.IsSubclassOf(type));
                types.AddRange(typesInAssembly);
            }
            return types;
#endif
        }

        private static void FilterEnumValue(ref string[] names, ref int[] values, params string[] actual)
        {
            var names2 = new List<string>();
            var values2 = new List<int>();
            foreach(var nm in actual)
            {
                var idx = ArrayUtility.IndexOf(names, nm);
                if (0 <= idx)
                {
                    names2.Add(names[idx]);
                    values2.Add(values[idx]);
                }
            }
            names = names2.ToArray();
            values = values2.ToArray();
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            var value = (int)prop.floatValue;
            int selectedIndex = -1;
            for (var index = 0; index < values.Length; index++)
            {
                if (values[index] == value)
                {
                    selectedIndex = index;
                    break;
                }
            }

            var names = Translate(this.names);
            var selIndex = EditorGUI.Popup(position, label, selectedIndex, names);

            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = (float)values[selIndex];
            }
        }

        private GUIContent[] Translate(string[] names)
        {
            var result = new GUIContent[names.Length];
            for(int i = 0; i < result.Length; i++)
            {
                var key = enumName + "." + names[i];
                if (WFI18N.TryTranslate(key, out var after))
                {
                    result[i] = new GUIContent(after);
                }
                else
                {
                    result[i] = new GUIContent(names[i]);
                }
            }
            return result;
        }
    }

#endregion

    public enum BlendModeOVL
    {
        ALPHA = 0,
        ADD = 1,
        MUL = 2,
        ADD_AND_SUB = 3,
        SCREEN = 4, 
        OVERLAY = 5,
        HARD_LIGHT = 6
    }

    public enum BlendModeHL
    {
        ADD_AND_SUB = 0,
        ADD = 1,
        MUL = 2,
    }
    
    public enum BlendModeES
    {
        ADD = 0,
        ALPHA = 2,
        LEGACY_ALPHA = 1,
    }

    public enum BlendModeTR
    {
        ADD = 2,
        ALPHA = 1,
        ADD_AND_SUB = 0,
    }

    public enum SunSourceMode
    {
        AUTO = 0, 
        ONLY_DIRECTIONAL_LIT = 1,
        ONLY_POINT_LIT = 2,
        CUSTOM_WORLD_DIR = 3,
        CUSTOM_LOCAL_DIR = 4,
        CUSTOM_WORLD_POS = 5
    }
}

#endif
