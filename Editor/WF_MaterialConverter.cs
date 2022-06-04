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

#if UNITY_EDITOR

using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace UnlitWF.Converter
{
    /// <summary>
    /// 変換コンテキスト
    /// </summary>
    public class ConvertContext
    {
        /// <summary>
        /// 変換中のマテリアル
        /// </summary>
        public Material target;
        /// <summary>
        /// 変換前のマテリアル
        /// </summary>
        public Material oldMaterial;
        /// <summary>
        /// 変換前のマテリアルに入っていたShaderSerializedProperty
        /// </summary>
        public Dictionary<string, ShaderSerializedProperty> oldProps;
    }

    public abstract class AbstractMaterialConverter<CTX> where CTX: ConvertContext, new()
    {
        private readonly List<Action<CTX>> converters;

        protected AbstractMaterialConverter(List<Action<CTX>> converters)
        {
            this.converters = converters;
        }

        public void ExecAutoConvert(params Material[] mats)
        {
            Undo.RecordObjects(mats, "WF Convert materials");
            ExecAutoConvertWithoutUndo(mats);
        }

        public void ExecAutoConvertWithoutUndo(params Material[] mats)
        {
            foreach (var mat in mats)
            {
                if (mat == null)
                {
                    continue;
                }
                if (!Validate(mat))
                {
                    continue;
                }

                var ctx = new CTX();
                ctx.target = mat;
                ctx.oldMaterial = new Material(mat);
                ctx.oldProps = ShaderSerializedProperty.AsDict(ctx.oldMaterial);

                foreach (var cnv in converters)
                {
                    cnv(ctx);
                }
                Debug.LogFormat("[WF] Convert {0}: {1} -> {2}", ctx.target, ctx.oldMaterial.shader.name, ctx.target.shader.name);
            }
        }

        /// <summary>
        /// 変換元マテリアルが変換対象かどうかを判定する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        protected virtual bool Validate(Material mat)
        {
            return true;
        }

        protected static bool IsMatchShaderName(ConvertContext ctx, string name)
        {
            return IsMatchShaderName(ctx.oldMaterial.shader, name);
        }

        protected static bool IsMatchShaderName(Shader shader, string name)
        {
            return new Regex(".*" + name + ".*", RegexOptions.IgnoreCase).IsMatch(shader.name);
        }

        private static bool hasCustomValue(Dictionary<string, ShaderSerializedProperty> props, string name)
        {
            if (props.TryGetValue(name, out var prop))
            {
                switch (prop.Type)
                {
                    case ShaderUtil.ShaderPropertyType.Float:
                    case ShaderUtil.ShaderPropertyType.Range:
                        return 0.001f < Mathf.Abs(prop.FloatValue);

                    case ShaderUtil.ShaderPropertyType.Color:
                    case ShaderUtil.ShaderPropertyType.Vector:
                        var vec = prop.VectorValue;
                        return 0.001f < Mathf.Abs(vec.x) || 0.001f < Mathf.Abs(vec.y) || 0.001f < Mathf.Abs(vec.z);

                    case ShaderUtil.ShaderPropertyType.TexEnv:
                        var tex = prop.TextureValue;
                        return tex != null && !string.IsNullOrEmpty(AssetDatabase.GetAssetPath(tex));

                    default:
                        return false;
                }
            }
            return false;
        }

        protected static bool HasCustomValue(ConvertContext ctx, params string[] names)
        {
            var newProp = ShaderSerializedProperty.AsDict(ctx.target);

            foreach (var name in names)
            {
                // 新しいマテリアルから設定されていないかを調べる
                if (hasCustomValue(newProp, name))
                {
                    return true;
                }
                // 古いマテリアルの側から設定されていないかを調べる
                if (hasCustomValue(ctx.oldProps, name))
                {
                    return true;
                }
            }
            return false;
        }

        protected static bool IsURP()
        {
#if UNITY_2019_1_OR_NEWER
            return UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline != null;
#else
            return false;
#endif
        }
    }

    /// <summary>
    /// WFマテリアルをMobile系に変換するコンバータ
    /// </summary>
    public class WFMaterialToMobileShaderConverter : AbstractMaterialConverter<ConvertContext>
    {
        public WFMaterialToMobileShaderConverter() : base(CreateConverterList())
        {
        }

        protected override bool Validate(Material mat)
        {
            // UnlitWFのマテリアルを対象に、URPではない場合に変換する
            return WFCommonUtility.IsSupportedShader(mat) && !WFCommonUtility.IsMobileSupportedShader(mat) && !IsURP();
        }

        protected static List<Action<ConvertContext>> CreateConverterList()
        {
            return new List<Action<ConvertContext>>() {
                ctx => {
                    bool cnv = false;
                    var shader = ctx.target.shader;
                    while (WFCommonUtility.IsSupportedShader(shader) && !WFCommonUtility.IsMobileSupportedShader(shader)) {
                        // シェーダ切り替え
                        var fallback = WFCommonUtility.GetShaderFallBackTarget(shader) ?? "Hidden/UnlitWF/WF_UnToon_Hidden";
                        WFCommonUtility.ChangeShader(fallback, ctx.target);

                        // シェーダ切り替え後に RenderQueue をコピー
                        if (ctx.oldMaterial.renderQueue != ctx.oldMaterial.shader.renderQueue   // FromShader では無かった場合
                            || ctx.target.shader.renderQueue != ctx.oldMaterial.shader.renderQueue) // shader で指定の queue が異なっていた場合
                        {
                            ctx.target.renderQueue = ctx.oldMaterial.renderQueue;
                        }

                        shader = ctx.target.shader;
                        cnv = true;
                    }
                    if (cnv) {
                        WFCommonUtility.SetupShaderKeyword(ctx.target);
                        EditorUtility.SetDirty(ctx.target);
                    }
                },
                ctx => {
                    if (IsMatchShaderName(ctx.oldMaterial.shader, "Transparent3Pass") && !IsMatchShaderName(ctx.target.shader, "Transparent3Pass")) {
                        // Transparent3Pass からそうではないシェーダの切り替えでは、_AL_ZWrite を ON に変更する
                        ctx.target.SetInt("_AL_ZWrite", 1);
                    }
                },
            };
        }
    }

    /// <summary>
    /// WF系ではないマテリアルをWF系に変換するコンバータ
    /// </summary>
    public class WFMaterialFromOtherShaderConverter : AbstractMaterialConverter<WFMaterialFromOtherShaderConverter.SelectShaderContext>
    {
        public WFMaterialFromOtherShaderConverter() : base(CreateConverterList())
        {
        }

        protected override bool Validate(Material mat)
        {
            // UnlitWF系ではないマテリアルを対象に処理する
            return !WFCommonUtility.IsSupportedShader(mat);
        }

        public class SelectShaderContext : ConvertContext
        {
            public ShaderType renderType = ShaderType.NoMatch;
            public bool outline = false;
        }

        public enum ShaderType
        {
            NoMatch, Opaque, Cutout, Transparent
        }

        protected static List<Action<SelectShaderContext>> CreateConverterList()
        {
            return new List<Action<SelectShaderContext>>() {
                ctx => {
                    // アウトライン有無を判定する
                    if (IsMatchShaderName(ctx, "outline") && !IsMatchShaderName(ctx, "nooutline")) {
                        ctx.outline = true;
                    }
                    else if (HasCustomValue(ctx, "_OutlineMask", "_OutLineMask", "_OutlineWidthMask", "_Outline_Sampler", "_OutLineEnable", "_OutlineMode", "_UseOutline")) {
                        ctx.outline = true;
                    }
                },
                ctx => {
                    // RenderType からシェーダタイプを判定する
                    if (IsMatchShaderName(ctx, "InternalErrorShader")) {
                        return;
                    }
                    if (ctx.renderType == ShaderType.NoMatch) {
                        switch(ctx.oldMaterial.GetTag("RenderType", false, ""))
                        {
                            case "Opaque":
                                ctx.renderType = ShaderType.Opaque;
                                break;
                            case "TransparentCutout":
                                ctx.renderType = ShaderType.Cutout;
                                break;
                            case "Transparent":
                                ctx.renderType = ShaderType.Transparent;
                                break;
                        }
                    }
                },
                ctx => {
                    // シェーダ名からシェーダタイプを判定する
                    if (ctx.renderType == ShaderType.NoMatch) {
                        if (IsMatchShaderName(ctx, "opaque") || IsMatchShaderName(ctx, "texture")) {
                            ctx.renderType = ShaderType.Opaque;
                        }
                        else if (IsMatchShaderName(ctx, "cutout")) {
                            ctx.renderType = ShaderType.Cutout;
                        }
                        else if (IsMatchShaderName(ctx, "trans")) {
                            ctx.renderType = ShaderType.Transparent;
                        }
                    }
                },
                ctx => {
                    // RenderQueue からシェーダタイプを判定する
                    if (IsMatchShaderName(ctx, "InternalErrorShader")) {
                        return;
                    }
                    if (ctx.renderType == ShaderType.NoMatch) {
                        var queue = ctx.oldMaterial.renderQueue;
                        if (queue < 0) {
                            queue = ctx.oldMaterial.shader.renderQueue;
                        }
                        if (queue < 2450) {
                            ctx.renderType = ShaderType.Opaque;
                        } else if (queue < 2500) {
                            ctx.renderType = ShaderType.Cutout;
                        } else {
                            ctx.renderType = ShaderType.Transparent;
                        }
                    }
                },
                ctx => {
                    // _ClippingMask の有無からシェーダタイプを判定する
                    if (ctx.renderType == ShaderType.NoMatch) {
                        if (HasCustomValue(ctx, "_ClippingMask")) {
                            ctx.renderType = ShaderType.Cutout;
                        }
                    }
                },
                ctx => {
                    if (IsURP()) {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_TransCutout", ctx.target);
                                break;
                            default:
                                WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_Opaque", ctx.target);
                                break;
                        }
                    }
                    else if (ctx.outline) {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_TransCutout", ctx.target);
                                break;
                            default:
                                WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_Opaque", ctx.target);
                                break;
                        }
                    } else {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_TransCutout", ctx.target);
                                break;
                            default:
                                WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_Opaque", ctx.target);
                                break;
                        }
                    }
                    // シェーダ切り替え後に RenderQueue をコピー
                    ctx.target.renderQueue = ctx.oldMaterial.renderQueue;
                },
                ctx => {
                    if (HasCustomValue(ctx, "_MainTex")) {
                        // メインテクスチャがあるならば _Color は白にする
                        ctx.target.SetColor("_Color", Color.white);
                    }
                },
                ctx => {
                    // アルファマスク
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_AlphaMask", "_AL_MaskTex"),
                        new PropertyNameReplacement("_ClippingMask", "_AL_MaskTex"));
                    if (HasCustomValue(ctx, "_AL_MaskTex")) {
                        ctx.target.SetInt("_AL_Source", 1); // AlphaSource = MASK_TEX_RED
                    }
                },
                ctx => {
                    // ノーマルマップ
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_NormalMap", "_BumpMap"));
                    if (HasCustomValue(ctx, "_BumpMap", "_DetailNormalMap")) {
                        ctx.target.SetInt("_NM_Enable", 1);
                    }
                },
                ctx => {
                    // メタリック
                    if (HasCustomValue(ctx, "_MetallicGlossMap", "_SpecGlossMap")) {
                        ctx.target.SetInt("_MT_Enable", 1);
                    }
                },
                ctx => {
                    // AO
                    if (HasCustomValue(ctx, "_OcclusionMap")) {
                        ctx.target.SetInt("_AO_Enable", 1);
                    }
                },
                ctx => {
                    // Emission
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_Emissive_Tex", "_EmissionMap"),
                        new PropertyNameReplacement("_Emissive_Color", "_EmissionColor"));
                    if (HasCustomValue(ctx, "_EmissionMap", "_UseEmission", "_EmissionEnable", "_EnableEmission")) {
                        ctx.target.SetInt("_ES_Enable", 1);
                    }
                },
                ctx => {
                    // Toon影
                    ctx.target.SetInt("_TS_Enable", 1);
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        // 1影
                        new PropertyNameReplacement("_1st_ShadeMap", "_TS_1stTex"),
                        new PropertyNameReplacement("_ShadowColorTex", "_TS_1stTex"),
                        new PropertyNameReplacement("_1st_ShadeColor", "_TS_1stColor"),
                        new PropertyNameReplacement("_ShadowColor", "_TS_1stColor"),
                        // 2影
                        new PropertyNameReplacement("_2nd_ShadeMap", "_TS_2ndTex"),
                        new PropertyNameReplacement("_Shadow2ndColorTex", "_TS_2ndTex"),
                        new PropertyNameReplacement("_2nd_ShadeColor", "_TS_2ndColor"),
                        new PropertyNameReplacement("_Shadow2ndColor", "_TS_2ndColor")
                        );
                    // 1影2影とも色相だけ反映して彩度・明度はリセットしてしまう
                    if (HasCustomValue(ctx, "_TS_1stColor")) {
                        float hur, sat, val;
                        Color.RGBToHSV(ctx.target.GetColor("_TS_1stColor"), out hur, out sat, out val);
                        if (sat < 0.05f) {
                            hur = 4 / 6f;
                        }
                        ctx.target.SetColor("_TS_1stColor", Color.HSVToRGB(hur, 0.1f, 0.9f));
                    }
                    if (HasCustomValue(ctx, "_TS_2ndColor")) {
                        float hur, sat, val;
                        Color.RGBToHSV(ctx.target.GetColor("_TS_2ndColor"), out hur, out sat, out val);
                        if (sat < 0.05f) {
                            hur = 4 / 6f;
                        }
                        ctx.target.SetColor("_TS_2ndColor", Color.HSVToRGB(hur, 0.15f, 0.8f));
                    }
                    // これらのテクスチャが設定されているならば _MainTex を _TS_BaseTex にも設定する
                    if (HasCustomValue(ctx, "_TS_1stTex", "_TS_2ndTex")) {
                        if (!HasCustomValue(ctx, "_TS_BaseTex")) {
                            ctx.target.SetTexture("_TS_BaseTex", ctx.target.GetTexture("_MainTex"));
                        }
                        if (!HasCustomValue(ctx, "_TS_1stTex")) {
                            ctx.target.SetTexture("_TS_1stTex", ctx.target.GetTexture("_TS_BaseTex"));
                        }
                        if (!HasCustomValue(ctx, "_TS_2ndTex")) {
                            ctx.target.SetTexture("_TS_2ndTex", ctx.target.GetTexture("_TS_1stTex"));
                        }
                        if (!HasCustomValue(ctx, "_TS_3rdTex")) {
                            ctx.target.SetTexture("_TS_3rdTex", ctx.target.GetTexture("_TS_2ndTex"));
                        }
                        // ただし _TS_BaseTex, _TS_1stTex, _TS_2ndTex, _TS_3rdTex が全て同じ Texture を指しているならば全てクリアする
                        if (ctx.target.GetTexture("_TS_BaseTex") == ctx.target.GetTexture("_TS_1stTex")
                            && ctx.target.GetTexture("_TS_1stTex") == ctx.target.GetTexture("_TS_2ndTex")
                            && ctx.target.GetTexture("_TS_2ndTex") == ctx.target.GetTexture("_TS_3rdTex")) {
                            ctx.target.SetTexture("_TS_BaseTex", null);
                            ctx.target.SetTexture("_TS_1stTex", null);
                            ctx.target.SetTexture("_TS_2ndTex", null);
                            ctx.target.SetTexture("_TS_3rdTex", null);
                        }
                    }
                },
                ctx => {
                    // リムライト
                    if (HasCustomValue(ctx, "_UseRim", "_RimLight", "_RimLitEnable", "_EnableRimLighting")) {
                        ctx.target.SetInt("_TR_Enable", 1);
                        WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                            new PropertyNameReplacement("_RimColor", "_TR_Color"),
                            new PropertyNameReplacement("_RimLitColor", "_TR_Color"),
                            new PropertyNameReplacement("_RimLightColor", "_TR_Color"),
                            new PropertyNameReplacement("_RimLitMask", "_TR_MaskTex"),
                            new PropertyNameReplacement("_RimBlendMask", "_TR_MaskTex"),
                            new PropertyNameReplacement("_Set_RimLightMask", "_TR_Color"),
                            new PropertyNameReplacement("_RimMask", "_TR_Color")
                            );
                        if (HasCustomValue(ctx, "_TR_Color")) {
                            ctx.target.SetInt("_TR_BlendType", 2);  // ADD
                        }
                    }
                },
                ctx => {
                    // アウトライン
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        new PropertyNameReplacement("_OutlineColor", "_TL_LineColor"),
                        new PropertyNameReplacement("_Outline_Color", "_TL_LineColor"),
                        new PropertyNameReplacement("_OutLineColor", "_TL_LineColor"),
                        new PropertyNameReplacement("_LineColor", "_TL_LineColor"),
                        // ColorTex
                        new PropertyNameReplacement("_OutlineTex", "_TL_CustomColorTex"),
                        new PropertyNameReplacement("_OutLineTexture", "_TL_CustomColorTex"),
                        new PropertyNameReplacement("_OutlineTexture", "_TL_CustomColorTex"),
                        // MaskTex
                        new PropertyNameReplacement("_OutlineWidthMask", "_TL_MaskTex"),
                        new PropertyNameReplacement("_Outline_Sampler", "_TL_MaskTex"),
                        new PropertyNameReplacement("_OutlineMask", "_TL_MaskTex"),
                        new PropertyNameReplacement("_OutLineMask", "_TL_MaskTex")
                        );
                },
                ctx => {
                    // アルファをリセットし、キーワードを整理する
                    var resetParam = ResetParameter.Create();
                    resetParam.materials = new Material[]{ ctx.target };
                    resetParam.resetColorAlpha = true;
                    // resetParam.resetUnused = true;
                    resetParam.resetKeywords = true;
                    WFMaterialEditUtility.ResetPropertiesWithoutUndo(resetParam);
                },
            };
        }
    }

    public static class ScanAndMigrationExecutor
    {
        public const int VERSION = 2;
        private static readonly string KEY_MIG_VERSION = "UnlitWF.ShaderEditor/autoMigrationVersion";

        public static void ExecuteAuto()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                // 実行中は何もしない
                return;
            }
            if (VERSION <= GetCurrentMigrationVersion())
            {
                // バージョンが新しいなら何もしない
                return;
            }
            if (!WFEditorSetting.GetOneOfSettings().enableScanProjects)
            {
                // 設定で無効化されているならば何もしない
                return;
            }

            var msg = WFI18N.Translate(WFMessageText.DgMigrationAuto);
            var lang = WFEditorPrefs.LangMode;
            var ok = lang == EditorLanguage.日本語 ? "実行する" : "Go Ahead";
            var cancel = lang == EditorLanguage.日本語 ? "結構です" : "No Thanks";
            var alt = lang == EditorLanguage.日本語 ? "後で聞いて" : "Ask Me Later";

            switch (EditorUtility.DisplayDialogComplex("WF migration materials", msg, ok, cancel, alt))
            {
                case 0:
                    // 実行してバージョン上書き
                    ScanAndMigration();
                    break;
                case 1:
                    // 実行せずバージョン上書き
                    break;
                case 2:
                    // あとで確認する
                    return;
            }

            // Setting の中のバージョンを上書き
            SaveCurrentMigrationVersion();
        }

        public static void ExecuteByManual()
        {
            var msg = WFI18N.Translate(WFMessageText.DgMigrationManual);
            var lang = WFEditorPrefs.LangMode;
            var ok = lang == EditorLanguage.日本語 ? "実行する" : "Go Ahead";
            var cancel = lang == EditorLanguage.日本語 ? "結構です" : "No Thanks";
            if (EditorUtility.DisplayDialog("WF migration materials", msg, ok, cancel))
            {
                ScanAndMigration();
                SaveCurrentMigrationVersion();
            }
        }

        public static int GetCurrentMigrationVersion()
        {
            if (int.TryParse(EditorUserSettings.GetConfigValue(KEY_MIG_VERSION) ?? "0", out var version))
            {
                return version;
            }
            return 0;
        }

        public static void SaveCurrentMigrationVersion()
        {
            EditorUserSettings.SetConfigValue(KEY_MIG_VERSION, VERSION.ToString());
        }

        public static void ScanAndMigration()
        {
            // Go Ahead
            var done = MaterialSeeker.SeekProjectAllMaterial("migration materials", Migration);
            if (0 < done)
            {
                AssetDatabase.SaveAssets();
                Debug.LogFormat("[WF] Scan And Migration {0} materials", done);
            }
        }

        public static bool Migration(string[] paths)
        {
            bool result = false;
            foreach (var path in paths)
            {
                result |= Migration(path);
            }
            return result;
        }

        public static bool Migration(string path)
        {
            if (string.IsNullOrWhiteSpace(path) || !path.EndsWith(".mat"))
            {
                return false;
            }
            var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
            return Migration(mat);
        }

        private static bool Migration(Material mat)
        {
            if (!WFCommonUtility.IsSupportedShader(mat))
            {
                return false;
            }
            WFMaterialEditUtility.MigrationMaterialWithoutUndo(mat);
            return true;
        }
    }
}

#endif
