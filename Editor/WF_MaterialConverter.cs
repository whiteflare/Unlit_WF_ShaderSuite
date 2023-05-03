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
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace UnlitWF.Converter
{
    /// <summary>
    /// 変換コンテキスト
    /// </summary>
    class ConvertContext
    {
        /// <summary>
        /// 変換中のマテリアル
        /// </summary>
        public readonly Material target;
        /// <summary>
        /// 変換前のマテリアル
        /// </summary>
        public readonly Material oldMaterial;
        /// <summary>
        /// 変換前のマテリアルに入っていたShaderSerializedProperty
        /// </summary>
        public readonly Dictionary<string, ShaderSerializedProperty> oldProps;

        public ConvertContext(Material mat)
        {
            this.target = mat;
            this.oldMaterial = new Material(mat);
            this.oldProps = ShaderSerializedProperty.AsDict(oldMaterial);
        }
    }

    abstract class AbstractMaterialConverter<CTX> where CTX : ConvertContext
    {
        private readonly List<Action<CTX>> converters;

        protected AbstractMaterialConverter(List<Action<CTX>> converters)
        {
            this.converters = converters;
        }

        public int ExecAutoConvert(params Material[] mats)
        {
            Undo.RecordObjects(mats, "WF " + GetShortName());
            return ExecAutoConvertWithoutUndo(mats);
        }

        public abstract string GetShortName();

        public abstract CTX CreateContext(Material target);

        public int ExecAutoConvertWithoutUndo(params Material[] mats)
        {
            int count = 0;
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

                var ctx = CreateContext(mat);
                foreach (var cnv in converters)
                {
                    cnv(ctx);
                }
                count++;
                OnAfterConvert(ctx);
            }
            OnAfterExecute(mats, count);
            return count;
        }

        protected virtual void OnAfterConvert(CTX ctx)
        {
            if (ctx.oldMaterial.shader.name != ctx.target.shader.name)
            {
                Debug.LogFormat("[WF] {0} {1}: {2} -> {3}", GetShortName(), ctx.target, ctx.oldMaterial.shader.name, ctx.target.shader.name);
            }
        }

        protected virtual void OnAfterExecute(Material[] mats, int total)
        {
            if (0 < total)
            {
                Debug.LogFormat("[WF] {0}: total {1} material converted", GetShortName(), total);
            }
        }

        /// <summary>
        /// 変換元マテリアルが変換対象かどうかを判定する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        protected abstract bool Validate(Material mat);

        protected static bool IsMatchShaderName(ConvertContext ctx, string name)
        {
            return IsMatchShaderName(ctx.oldMaterial.shader, name);
        }

        protected static bool IsMatchShaderName(Shader shader, string name)
        {
            return new Regex(".*" + name + ".*", RegexOptions.IgnoreCase).IsMatch(shader.name);
        }

        [Obsolete]
        private static bool hasCustomValue(Dictionary<string, ShaderSerializedProperty> props, string name)
        {
            if (props.TryGetValue(name, out var prop))
            {
                return hasCustomValue(prop);
            }
            return false;
        }

        [Obsolete]
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

        private static ShaderSerializedProperty GetProperty(Dictionary<string, ShaderSerializedProperty> props, string name, bool ignoreCase = false)
        {
            if (ignoreCase)
            {
                foreach(var item in props)
                {
                    if (item.Key.Equals(name, StringComparison.InvariantCultureIgnoreCase))
                    {
                        return item.Value;
                    }
                }
                return null;
            }
            else
            {
                return props.GetValueOrNull(name);
            }
        }

        /// <summary>
        /// 変換前マテリアルにプロパティが存在する。
        /// </summary>
        /// <param name="ctx"></param>
        /// <param name="names"></param>
        /// <returns></returns>
        protected static bool HasOldProperty(ConvertContext ctx, params string[] names)
        {
            return HasOldProperty(ctx, names, false);
        }

        protected static bool HasOldPropertyIgnoreCase(ConvertContext ctx, params string[] names)
        {
            return HasOldProperty(ctx, names, true);
        }

        private static bool HasOldProperty(ConvertContext ctx, string[] names, bool ignoreCase)
        {
            return names.Any(name =>
            {
                var prop = GetProperty(ctx.oldProps, name, ignoreCase);
                return prop != null;
            });
        }

        /// <summary>
        /// 変換前マテリアルにプロパティが存在し、何らかの値が設定されている。
        /// </summary>
        /// <param name="ctx"></param>
        /// <param name="names"></param>
        /// <returns></returns>
        protected static bool HasOldPropertyValue(ConvertContext ctx, params string[] names)
        {
            return HasOldPropertyValue(ctx, names, false);
        }

        protected static bool HasOldPropertyValueIgnoreCase(ConvertContext ctx, params string[] names)
        {
            return HasOldPropertyValue(ctx, names, true);
        }

        private static bool HasOldPropertyValue(ConvertContext ctx, string[] names, bool ignoreCase)
        {
            return names.Any(name =>
            {
                var prop = GetProperty(ctx.oldProps, name, ignoreCase);
                if (prop != null)
                {
                    return hasCustomValue(prop);
                }
                return false;
            });
        }

        protected static bool HasNewProperty(ConvertContext ctx, params string[] names)
        {
            return names.Any(name => WFAccessor.HasShaderProperty(ctx.target.shader, name));
        }

        protected static bool HasNewPropertyValue(ConvertContext ctx, params string[] names)
        {
            var newProp = ShaderSerializedProperty.AsDict(ctx.target);
            return names.Any(name =>
            {
                if (newProp.TryGetValue(name, out var prop))
                {
                    return hasCustomValue(prop);
                }
                return false;
            });
        }

        private static bool hasCustomValue(ShaderSerializedProperty prop)
        {
            if (prop == null)
            {
                return false;
            }
            switch (prop.Type)
            {
                case ShaderUtil.ShaderPropertyType.Float:
                case ShaderUtil.ShaderPropertyType.Range:
                    return 0.001f < Mathf.Abs(prop.FloatValue);

                case ShaderUtil.ShaderPropertyType.Color:
                    var col = prop.ColorValue;
                    return 0.001f < Mathf.Abs(col.r) || 0.001f < Mathf.Abs(col.g) || 0.001f < Mathf.Abs(col.b);

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
    }

    /// <summary>
    /// WFマテリアルをMobile系に変換するコンバータ
    /// </summary>
    class WFMaterialToMobileShaderConverter : AbstractMaterialConverter<ConvertContext>
    {
        public WFMaterialToMobileShaderConverter() : base(CreateConverterList())
        {
        }

        public override string GetShortName()
        {
            return "Convert To MobileShader";
        }

        public override ConvertContext CreateContext(Material target)
        {
            return new ConvertContext(target);
        }

        protected override bool Validate(Material mat)
        {
            // UnlitWFのマテリアルを対象に、URPではない場合に変換する
            return WFCommonUtility.IsSupportedShader(mat) && !WFCommonUtility.IsMobileSupportedShader(mat) && !WFCommonUtility.IsURP();
        }

        protected static List<Action<ConvertContext>> CreateConverterList()
        {
            return new List<Action<ConvertContext>>() {
                ctx => {
                    bool cnv = false;
                    var shader = ctx.target.shader;
                    while (WFCommonUtility.IsSupportedShader(shader) && !WFCommonUtility.IsMobileSupportedShader(shader)) {
                        // シェーダ切り替え
                        var fallback = WFAccessor.GetShaderFallBackTarget(shader) ?? "Hidden/UnlitWF/WF_UnToon_Hidden";
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
    class WFMaterialFromOtherShaderConverter : AbstractMaterialConverter<WFMaterialFromOtherShaderConverter.SelectShaderContext>
    {
        public WFMaterialFromOtherShaderConverter() : base(CreateConverterList())
        {
        }

        public override SelectShaderContext CreateContext(Material target)
        {
            return new SelectShaderContext(target);
        }

        public override string GetShortName()
        {
            return "Convert From OtherShader";
        }

        protected override bool Validate(Material mat)
        {
            // UnlitWF系ではないマテリアルを対象に処理する
            return !WFCommonUtility.IsSupportedShader(mat);
        }

        internal class SelectShaderContext : ConvertContext
        {
            public ShaderType renderType = ShaderType.NoMatch;
            public bool outline = false;

            public SelectShaderContext(Material mat) : base(mat)
            {

            }
        }

        internal enum ShaderType
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
                    else if (HasOldPropertyValueIgnoreCase(ctx,
                        "_OutlineMask",
                        "_OutlineWidthMask",
                        "_Outline_Sampler",
                        "_OutLineEnable",
                        "_OutlineTex",
                        "_OutlineTexture",
                        "_OutlineMode",
                        "_UseOutline")) {
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
                        if (HasOldPropertyValueIgnoreCase(ctx, "_ClippingMask")) {
                            ctx.renderType = ShaderType.Cutout;
                        }
                        if (HasOldPropertyValueIgnoreCase(ctx, "_AlphaMask"))
                        {
                            ctx.renderType = ShaderType.Transparent;
                        }
                    }
                },
                ctx => {
                    // 半透明はアウトライン付きには変換しない
                    if (ctx.renderType == ShaderType.Transparent && ctx.outline)
                    {
                        ctx.outline = false;
                    }
                },
                ctx => { 
                    // シェーダ切り替える直前に、削除したいプロパティを削除
                    WFMaterialEditUtility.RemovePropertiesWithoutUndo(ctx.target, "_GI_Intensity");
                    // _GI_Intensity は UTS が保持しているが、UnToon でも過去に同名プロパティを持っていてマイグレーション対象にしているため削除する
                },
                ctx => {
                    if (WFCommonUtility.IsURP()) {
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
                    if (ctx.target.renderQueue != ctx.oldMaterial.renderQueue)
                    {
                        ctx.target.renderQueue = ctx.oldMaterial.renderQueue;
                    }
                },
                ctx => {
                    // _CullModeのコピー
                    if (ctx.target.HasProperty("_CullMode"))
                    {
                        WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                            PropertyNameReplacement.MatchIgnoreCase("_CullMode", "_CullMode"),
                            PropertyNameReplacement.MatchIgnoreCase("_Culling", "_CullMode"),
                            PropertyNameReplacement.MatchIgnoreCase("_Cull", "_CullMode"));
                    }
                },
                ctx => {
                    // アウトライン付きかつ _CullMode が BACK の場合、OFF に変更する
                    if (ctx.outline && ctx.target.HasProperty("_CullMode") && ctx.target.GetInt("_CullMode") == 2)
                    {
                        ctx.target.SetInt("_CullMode", 0);
                    }
                },
                ctx => {
                    // 半透明の場合はZWriteをコピー
                    if (ctx.renderType == ShaderType.Transparent)
                    {
                        WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                            PropertyNameReplacement.MatchIgnoreCase("_ZWrite", "_AL_ZWrite"),
                            PropertyNameReplacement.MatchIgnoreCase("_EnableZWrite", "_AL_ZWrite"),
                            PropertyNameReplacement.MatchIgnoreCase("_ZWriteMode", "_AL_ZWrite"));
                    }
                },
                ctx => {
                    if (HasOldPropertyValue(ctx, "_MainTex")) {
                        // メインテクスチャがあるならば _Color は白にする
                        if (!IsMatchShaderName(ctx, "Standard") && !IsMatchShaderName(ctx, "Autodesk") && !IsMatchShaderName(ctx, "Unlit/Color"))
                        {
                            ctx.target.SetColor("_Color", Color.white);
                        }
                    }
                },
                ctx => {
                    // プロパティ名変更開始
                    WFMaterialEditUtility.BeginReplacePropertyNames(ctx.target);
                },
                ctx => {
                    // アルファマスク
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        PropertyNameReplacement.MatchIgnoreCase("_AlphaMask", "_AL_MaskTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_ClippingMask", "_AL_MaskTex"));
                    if (HasNewPropertyValue(ctx, "_AL_MaskTex")) {
                        ctx.target.SetInt("_AL_Source", 1); // AlphaSource = MASK_TEX_RED
                    }
                },
                ctx => {
                    // ノーマルマップ
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        PropertyNameReplacement.Match("_NormalMap", "_BumpMap"));
                    if (HasNewPropertyValue(ctx, "_BumpMap")) {
                        ctx.target.SetInt("_NM_Enable", 1);
                    }
                },
                ctx => {
                    // ノーマルマップ2nd
                    if (HasNewPropertyValue(ctx, "_DetailNormalMap")) {
                        ctx.target.SetInt("_NS_Enable", 1);
                    }
                },
                ctx => {
                    // メタリック
                    if (HasNewPropertyValue(ctx, "_MetallicGlossMap", "_SpecGlossMap")) {
                        ctx.target.SetInt("_MT_Enable", 1);
                    }
                },
                ctx => {
                    // AO
                    if (HasNewPropertyValue(ctx, "_OcclusionMap")) {
                        ctx.target.SetInt("_AO_Enable", 1);
                    }
                },
                ctx => {
                    // Emission
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        PropertyNameReplacement.MatchIgnoreCase("_Emissive_Tex", "_EmissionMap"),
                        PropertyNameReplacement.MatchIgnoreCase("_Emissive_Color", "_EmissionColor"));
                    if (HasOldPropertyValue(ctx, "_EmissionMap", "_UseEmission", "_EmissionEnable", "_EnableEmission")) {
                        ctx.target.SetInt("_ES_Enable", 1);
                    }
                },
                ctx => {
                    if (IsMatchShaderName(ctx, "Unlit/"))
                    {
                        return;
                    }
                    // Toon影
                    ctx.target.SetInt("_TS_Enable", 1);
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        // 1影
                        PropertyNameReplacement.MatchIgnoreCase("_1st_ShadeMap", "_TS_1stTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_ShadowColorTex", "_TS_1stTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_1st_ShadeColor", "_TS_1stColor"),
                        PropertyNameReplacement.MatchIgnoreCase("_ShadowColor", "_TS_1stColor"),
                        // 2影
                        PropertyNameReplacement.MatchIgnoreCase("_2nd_ShadeMap", "_TS_2ndTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_Shadow2ndColorTex", "_TS_2ndTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_2nd_ShadeColor", "_TS_2ndColor"),
                        PropertyNameReplacement.MatchIgnoreCase("_Shadow2ndColor", "_TS_2ndColor")
                        );
                    // 1影2影とも色相だけ反映して彩度・明度はリセットしてしまう
                    if (HasNewProperty(ctx, "_TS_1stColor")) {
                        float hur, sat, val;
                        Color.RGBToHSV(ctx.target.GetColor("_TS_1stColor"), out hur, out sat, out val);
                        if (sat < 0.05f) {
                            hur = 4 / 6f;
                        }
                        ctx.target.SetColor("_TS_1stColor", Color.HSVToRGB(hur, 0.1f, 0.9f));
                    }
                    if (HasNewProperty(ctx, "_TS_2ndColor")) {
                        float hur, sat, val;
                        Color.RGBToHSV(ctx.target.GetColor("_TS_2ndColor"), out hur, out sat, out val);
                        if (sat < 0.05f) {
                            hur = 4 / 6f;
                        }
                        ctx.target.SetColor("_TS_2ndColor", Color.HSVToRGB(hur, 0.15f, 0.8f));
                    }
                    // これらのテクスチャが設定されているならば _MainTex を _TS_BaseTex にも設定する
                    if (HasNewPropertyValue(ctx, "_TS_1stTex", "_TS_2ndTex")) {
                        if (!HasNewPropertyValue(ctx, "_TS_BaseTex")) {
                            ctx.target.SetTexture("_TS_BaseTex", ctx.target.GetTexture("_MainTex"));
                        }
                        if (!HasNewPropertyValue(ctx, "_TS_1stTex")) {
                            ctx.target.SetTexture("_TS_1stTex", ctx.target.GetTexture("_TS_BaseTex"));
                        }
                        if (!HasNewPropertyValue(ctx, "_TS_2ndTex")) {
                            ctx.target.SetTexture("_TS_2ndTex", ctx.target.GetTexture("_TS_1stTex"));
                        }
                        if (!HasNewPropertyValue(ctx, "_TS_3rdTex")) {
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
                    if (HasOldPropertyValue(ctx, "_UseRim", "_RimLight", "_RimLitEnable", "_EnableRimLighting")) {
                        ctx.target.SetInt("_TR_Enable", 1);
                        WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                            PropertyNameReplacement.Match("_RimColor", "_TR_Color"),
                            PropertyNameReplacement.Match("_RimLitColor", "_TR_Color"),
                            PropertyNameReplacement.Match("_RimLightColor", "_TR_Color"),
                            PropertyNameReplacement.Match("_RimLitMask", "_TR_MaskTex"),
                            PropertyNameReplacement.Match("_RimBlendMask", "_TR_MaskTex"),
                            PropertyNameReplacement.Match("_Set_RimLightMask", "_TR_Color"),
                            PropertyNameReplacement.Match("_RimMask", "_TR_Color")
                            );
                        if (HasNewPropertyValue(ctx, "_TR_Color")) {
                            ctx.target.SetInt("_TR_BlendType", 2);  // ADD
                        }
                    }
                },
                ctx => {
                    // アウトライン
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        PropertyNameReplacement.MatchIgnoreCase("_OutlineColor", "_TL_LineColor"),
                        PropertyNameReplacement.MatchIgnoreCase("_Outline_Color", "_TL_LineColor"),
                        PropertyNameReplacement.MatchIgnoreCase("_LineColor", "_TL_LineColor"),
                        // ColorTex
                        PropertyNameReplacement.MatchIgnoreCase("_OutlineTex", "_TL_CustomColorTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_OutlineTexture", "_TL_CustomColorTex"),
                        // MaskTex
                        PropertyNameReplacement.MatchIgnoreCase("_OutlineWidthMask", "_TL_MaskTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_Outline_Sampler", "_TL_MaskTex"),
                        PropertyNameReplacement.MatchIgnoreCase("_OutlineMask", "_TL_MaskTex")
                        );
                    if (HasNewPropertyValue(ctx, "_TL_CustomColorTex")) {
                        if (ctx.target.GetTexture("_TL_CustomColorTex") == ctx.target.GetTexture("_MainTex"))
                        {
                            // CustomColorTex と MainTex が同一の場合、CustomColorTex を削除して BlendBase を調整する
                            ctx.target.SetTexture("_TL_CustomColorTex", null);
                            ctx.target.SetFloat("_TL_BlendBase", 0.5f);
                        }
                        else
                        {
                            // そうではない場合 BlendCustom を調整する
                            ctx.target.SetFloat("_TL_BlendCustom", 0.5f);
                        }
                    }
                },
                ctx => {
                    // プロパティ名変更終了
                    WFMaterialEditUtility.EndReplacePropertyNames(ctx.target);
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

    static class ScanAndMigrationExecutor
    {
        public const int VERSION = 5;
        private static readonly string KEY_MIG_VERSION = "UnlitWF.ShaderEditor/autoMigrationVersion";

        /// <summary>
        /// shader インポート時に全スキャンする。
        /// </summary>
        public static void ExecuteScanWhenImportShader()
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
            if (WFCommonUtility.IsInSpecialProject())
            {
                // 特殊なプロジェクト内ならば何もしない
                return;
            }

            var msg = WFI18N.Translate(WFMessageText.DgMigrationAuto);
            var lang = WFEditorPrefs.LangMode;
            var ok = lang == EditorLanguage.日本語 ? "実行する" : "Go Ahead";
            var cancel = lang == EditorLanguage.日本語 ? "結構です" : "No Thanks";
            var alt = lang == EditorLanguage.日本語 ? "後で聞いて" : "Ask Me Later";

            switch (EditorUtility.DisplayDialogComplex(WFCommonUtility.DialogTitle, msg, ok, cancel, alt))
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

        /// <summary>
        /// 手動で全スキャンする。
        /// </summary>
        public static void ExecuteScanByManual()
        {
            var msg = WFI18N.Translate(WFMessageText.DgMigrationManual);
            var lang = WFEditorPrefs.LangMode;
            var ok = lang == EditorLanguage.日本語 ? "実行する" : "Go Ahead";
            var cancel = lang == EditorLanguage.日本語 ? "結構です" : "No Thanks";
            if (EditorUtility.DisplayDialog(WFCommonUtility.DialogTitle, msg, ok, cancel))
            {
                ScanAndMigration();
                SaveCurrentMigrationVersion();
            }
        }

        /// <summary>
        /// material インポート時にそのマテリアルをマイグレーションする。
        /// </summary>
        /// <param name="paths"></param>
        public static void ExecuteMigrationWhenImportMaterial(string[] paths)
        {
            if (!WFEditorSetting.GetOneOfSettings().enableMigrationWhenImport)
            {
                // 設定で無効化されているならば何もしない
                return;
            }

            var done = 0;
            foreach (var path in paths)
            {
                if (Migration(path))
                {
                    done++;
                }
            }
            if (0 < done)
            {
                Debug.LogFormat("[WF] Import And Migration {0} materials", done);
            }
        }

        private static int GetCurrentMigrationVersion()
        {
            if (int.TryParse(EditorUserSettings.GetConfigValue(KEY_MIG_VERSION) ?? "0", out var version))
            {
                return version;
            }
            return 0;
        }

        private static void SaveCurrentMigrationVersion()
        {
            EditorUserSettings.SetConfigValue(KEY_MIG_VERSION, VERSION.ToString());
        }

        private static void ScanAndMigration()
        {
            // Go Ahead
            var done = new MaterialSeeker().SeekProjectAllMaterial("migration materials", Migration);
            if (0 < done)
            {
                AssetDatabase.SaveAssets();
                Debug.LogFormat("[WF] Scan And Migration {0} materials", done);
            }
        }

        private static bool Migration(string path)
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
            return new WFMaterialMigrationConverter().ExecAutoConvert(mat) != 0;
        }
    }

    /// <summary>
    /// 古いWFマテリアルをマイグレーションするコンバータ
    /// </summary>
    class WFMaterialMigrationConverter : AbstractMaterialConverter<ConvertContext>
    {
        public WFMaterialMigrationConverter() : base(CreateConverterList())
        {
        }

        public override string GetShortName()
        {
            return "Migration Materials";
        }

        public override ConvertContext CreateContext(Material target)
        {
            return new ConvertContext(target);
        }

        protected override bool Validate(Material mat)
        {
            return ExistsNeedsMigration(mat);
        }

        /// <summary>
        /// 古いマテリアルのマイグレーション：プロパティ名のリネーム辞書
        /// </summary>
        public static readonly List<PropertyNameReplacement> OldPropNameToNewPropNameList = new List<PropertyNameReplacement>() {
            PropertyNameReplacement.Group("2020/01/28"),
            PropertyNameReplacement.Match("_AL_CutOff", "_Cutoff"),
            PropertyNameReplacement.Match("_ES_Color", "_EmissionColor"),
            PropertyNameReplacement.Match("_ES_MaskTex", "_EmissionMap"),
            PropertyNameReplacement.Match("_GL_BrendPower", "_GL_BlendPower"),
            PropertyNameReplacement.Match("_MT_BlendType", "_MT_Brightness"),
            PropertyNameReplacement.Match("_MT_MaskTex", "_MetallicGlossMap"),
            PropertyNameReplacement.Match("_MT_Smoothness", "_MT_ReflSmooth"),
            PropertyNameReplacement.Match("_MT_Smoothness2", "_MT_SpecSmooth"),

            PropertyNameReplacement.Group("2020/09/04"),
            PropertyNameReplacement.Match("_CutOffLevel", "_Cutoff"),
            PropertyNameReplacement.Match("_FurHeight", "_FR_Height"),
            PropertyNameReplacement.Match("_FurMaskTex", "_FR_MaskTex"),
            PropertyNameReplacement.Match("_FurNoiseTex", "_FR_NoiseTex"),
            PropertyNameReplacement.Match("_FurRepeat", "_FR_Repeat"),
            PropertyNameReplacement.Match("_FurShadowPower", "_FR_ShadowPower"),

            PropertyNameReplacement.Group("2020/12/18"),
            PropertyNameReplacement.Match("_FG_BumpMap", "_FR_BumpMap"),
            PropertyNameReplacement.Match("_FG_FlipTangent", "_FR_FlipMirror"),

            PropertyNameReplacement.Group("2021/01/11"),
            PropertyNameReplacement.Match("_Smoothing", "_TE_SmoothPower"),
            PropertyNameReplacement.Match("_TessFactor", "_TE_Factor"),

            PropertyNameReplacement.Group("2022/06/04"),
            PropertyNameReplacement.Match("_FR_FlipMirror", "_FlipMirror"),
            PropertyNameReplacement.Match("_FR_FlipTangent", "_FlipMirror"),
            PropertyNameReplacement.Match("_NM_2ndMaskTex", "_NS_2ndMaskTex"),
            PropertyNameReplacement.Match("_NM_2ndType", "_NS_Enable", p => p.IntValue = p.IntValue != 0 ? 1 : 0),
            PropertyNameReplacement.Match("_NM_2ndUVType", "_NS_2ndUVType"),
            PropertyNameReplacement.Match("_NM_FlipMirror", "_FlipMirror"),
            PropertyNameReplacement.Match("_NM_InvMaskVal", "_NS_InvMaskVal"),

            PropertyNameReplacement.Group("2022/06/08"),
            PropertyNameReplacement.Match("_NS_2ndUVType", "_NS_UVType"),
            PropertyNameReplacement.Match("_TS_Feather", "_TS_1stFeather"), // 1stに名称変更して、2ndと3rdのコピーは別途行う

            PropertyNameReplacement.Group("2022/09/12"),
            PropertyNameReplacement.Prefix("_BK_", "_BKT_"),
            PropertyNameReplacement.Prefix("_CC_", "_CCT_"),
            PropertyNameReplacement.Prefix("_CH_", "_CHM_"),
            PropertyNameReplacement.Prefix("_CL_", "_CLC_"),
            PropertyNameReplacement.Prefix("_DF_", "_DFD_"),
            PropertyNameReplacement.Prefix("_FG_", "_TFG_"),
            PropertyNameReplacement.Prefix("_FR_", "_FUR_"),
            PropertyNameReplacement.Prefix("_GB_", "_GMB_"),
            PropertyNameReplacement.Prefix("_GF_", "_GMF_"),
            PropertyNameReplacement.Prefix("_GI_", "_LBE_"),
            PropertyNameReplacement.Prefix("_GR_", "_GMR_"),
            PropertyNameReplacement.Prefix("_LM_", "_LME_"),
            PropertyNameReplacement.Prefix("_OL_", "_OVL_"),
            PropertyNameReplacement.Prefix("_RF_", "_CRF_"),

            PropertyNameReplacement.Group("2022/10/15"),
            PropertyNameReplacement.Match("_ES_Shape", "_ES_SC_Shape"),
            PropertyNameReplacement.Match("_ES_DirType", "_ES_SC_DirType"),
            PropertyNameReplacement.Match("_ES_Direction", "_ES_SC_Direction"),
            PropertyNameReplacement.Match("_ES_LevelOffset", "_ES_SC_LevelOffset"),
            PropertyNameReplacement.Match("_ES_Sharpness", "_ES_SC_Sharpness"),
            PropertyNameReplacement.Match("_ES_Speed", "_ES_SC_Speed"),
            PropertyNameReplacement.Match("_ES_AlphaScroll", "_ES_SC_AlphaScroll"),
        };

        public static bool ExistsNeedsMigration(Material mat)
        {
            // UnlitWFのマテリアルを対象に変換する
            return WFCommonUtility.IsSupportedShader(mat) && WFMaterialEditUtility.ExistsNeedsMigration(mat, OldPropNameToNewPropNameList);
        }

        protected static int GetIntOrDefault(Material mat, string name, int _default = default)
        {
            if (mat.HasProperty(name))
            {
                return mat.GetInt(name);
            }
            return _default;
        }

        protected static void CopyFloatValue(Material mat, string from, string to)
        {
            if (mat.HasProperty(from) && mat.HasProperty(to))
            {
                mat.SetFloat(to, mat.GetFloat(from));
            }
        }

        protected override void OnAfterConvert(ConvertContext ctx)
        {
            // 大量に変換すると大量にログが出るので出さない
        }

        protected override void OnAfterExecute(Material[] mats, int total)
        {
            // 大量に変換すると大量にログが出るので出さない
        }

        protected static List<Action<ConvertContext>> CreateConverterList()
        {
            return new List<Action<ConvertContext>>()
            {
                ctx => {
                    // まずはナイーブに名称変更
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target, OldPropNameToNewPropNameList);
                    // Validate で確認しているのでここで変更されなかったというのは無いはず
                },
                ctx => {
                    // NSを変換して有効になったとき
                    if (GetIntOrDefault(ctx.oldMaterial, "_NS_Enable") == 0 && GetIntOrDefault(ctx.target, "_NS_Enable") != 0)
                    {
                        // BlendNormalを複製する
                        foreach(var propName in ctx.oldProps.Keys)
                        {
                            if (WFCommonUtility.FormatPropName(propName, out var label, out var name)) {
                                if (name == "BlendNormal")
                                {
                                    var propName2 = propName.Replace("_BlendNormal", "_BlendNormal2");
                                    CopyFloatValue(ctx.target, propName, propName2);
                                }
                            }
                        }
                        // BumpMap が未設定ならば _NM_Enable をオフにする
                        if (!HasNewPropertyValue(ctx, "_BumpMap"))
                        {
                            ctx.target.SetInt("_NM_Enable", 0);
                        }
                    }
                },
                ctx => {
                    // _TS_Featherありの状態から_TS_1stFeatherに変更されたならば、
                    if (HasOldProperty(ctx, "_TS_Feather") && HasNewProperty(ctx, "_TS_1stFeather"))
                    {
                        CopyFloatValue(ctx.target, "_TS_1stFeather", "_TS_2ndFeather");
                        CopyFloatValue(ctx.target, "_TS_1stFeather", "_TS_3rdFeather");
                    }
                },
                ctx => {
                    // _ES_Shapeありの状態から_ES_SC_Shapeに変更されたならば、
                    if (HasOldProperty(ctx, "_ES_Shape") && HasNewProperty(ctx, "_ES_SC_Shape"))
                    {
                        // CONSTANTでないならばEmissiveScroll有効
                        ctx.target.SetInt("_ES_ScrollEnable", ctx.target.GetInt("_ES_SC_Shape") != 3 ? 1 : 0);
                    }
                },
                ctx => {
                    // _ES_DirTypeありの状態から_ES_SC_DirTypeに変更されたならば、
                    if (HasOldProperty(ctx, "_ES_DirType") && HasNewProperty(ctx, "_ES_SC_DirType"))
                    {
                        // 変更前で 3:UV2 だったなら、2:UV に変更してUVTypeを 1:UV2 にする
                        if (ctx.target.GetInt("_ES_SC_DirType") == 3)
                        {
                            ctx.target.SetInt("_ES_SC_DirType", 2);
                            ctx.target.SetInt("_ES_SC_UVType", 1);
                        }
                    }
                },
                ctx => {
                    // シェーダキーワードを整理
                    WFCommonUtility.SetupShaderKeyword(ctx.target);
                    EditorUtility.SetDirty(ctx.target);
                },
            };
        }
    }
}

#endif
