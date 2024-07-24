/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
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

    [Serializable]
    public class AbortAndResetConvertException : Exception
    {
        public AbortAndResetConvertException() { }
        public AbortAndResetConvertException(string message) : base(message) { }
        public AbortAndResetConvertException(string message, Exception inner) : base(message, inner) { }
        protected AbortAndResetConvertException(
          System.Runtime.Serialization.SerializationInfo info,
          System.Runtime.Serialization.StreamingContext context) : base(info, context) { }
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
            // 対象を収集
            var targets = new List<Material>();
            foreach (var mat in mats)
            {
                if (mat == null)
                {
                    continue;
                }
                if (!Validate(mat))
                {
                    OnSkipConvert(mat);
                    continue;
                }
                targets.Add(mat);
            }

            // 変換前処理
            foreach(var mat in targets)
            {
                PreConvert(mat);
            }

            // 変換本体を実行
            int count = 0;
            foreach (var mat in targets)
            {
                var ctx = CreateContext(mat);
                try
                {
                    foreach (var cnv in converters)
                    {
                        cnv(ctx);
                    }
                    count++;
                    OnAfterConvert(ctx);
                }
                catch (AbortAndResetConvertException ex)
                {
                    OnAbortConvert(ctx, ex);
                    EditorUtility.CopySerializedIfDifferent(ctx.oldMaterial, ctx.target);
                    EditorUtility.SetDirty(ctx.target);
                }
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
            // インクリメンタルに変換する処理があるのでここではログを出さず、呼び出し元でログを出す
        }

        protected virtual void OnSkipConvert(Material mat)
        {

        }

        protected virtual void OnAbortConvert(CTX ctx, AbortAndResetConvertException ex)
        {
            Debug.LogWarningFormat("[WF] {0} {1}: Abort Convert", GetShortName(), ctx.target);
        }

        /// <summary>
        /// 変換元マテリアルが変換対象かどうかを判定する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        protected abstract bool Validate(Material mat);

        /// <summary>
        /// 変換前処理を行う。
        /// </summary>
        /// <param name="mat"></param>
        protected virtual void PreConvert(Material mat)
        {

        }

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

        protected override void PreConvert(Material mat)
        {
#if UNITY_2022_1_OR_NEWER
            // マテリアルバリアントは変換できないのでこのタイミングでフラットにする
            if (mat.isVariant)
            {
                mat.parent = null;
            }
#endif
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
                        if (shader == ctx.target.shader)
                        {
                            // 変換できなかった場合は変換を中止
                            throw new AbortAndResetConvertException();
                        }

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
                        WFCommonUtility.SetupMaterial(ctx.target);
                        EditorUtility.SetDirty(ctx.target);
                    }
                },
                ctx => {
                    if (IsMatchShaderName(ctx.oldMaterial.shader, "Transparent3Pass") && !IsMatchShaderName(ctx.target.shader, "Transparent3Pass")) {
                        // Transparent3Pass からそうではないシェーダの切り替えでは、_AL_ZWrite を ON に変更する
                        WFAccessor.SetBool(ctx.target, "_AL_ZWrite", true);
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
            public bool particle = false;

            public SelectShaderContext(Material mat) : base(mat)
            {

            }
        }

        internal enum ShaderType
        {
            NoMatch, Opaque, Cutout, Transparent, Additive, Multiply
        }

        protected override void PreConvert(Material mat)
        {
#if UNITY_2022_1_OR_NEWER
            // マテリアルバリアントは変換できないのでこのタイミングでフラットにする
            if (mat.isVariant)
            {
                mat.parent = null;
            }
#endif
        }

        protected static List<Action<SelectShaderContext>> CreateConverterList()
        {
            return new List<Action<SelectShaderContext>>() {
                ctx => {
                    // パーティクルかどうかを判定する
                    if (IsMatchShaderName(ctx, "Particles/Standard Surface") && IsMatchShaderName(ctx, "Particles/Standard Unlit")) {
                        ctx.particle = true;
                        switch(ctx.oldMaterial.GetInt("_Mode"))
                        {
                            case 0: // Opaque
                                ctx.renderType = ShaderType.Opaque;
                                break;
                            case 1: // Cutout
                                ctx.renderType = ShaderType.Cutout;
                                break;
                            case 2: // Fade
                            case 3: // Transparent
                                ctx.renderType = ShaderType.Transparent;
                                break;
                            case 4: // Additive
                                ctx.renderType = ShaderType.Additive;
                                break;
                            default:
                                break;
                        }
                    }
                    else if (IsMatchShaderName(ctx, "Particle")) {
                        ctx.particle = true;
                    }
                },
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
                        } else if (queue <= 2500) {
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
                    WFMaterialEditUtility.DeletePropertiesWithoutUndo(ctx.target, "_GI_Intensity");
                    // _GI_Intensity は UTS が保持しているが、UnToon でも過去に同名プロパティを持っていてマイグレーション対象にしているため削除する
                },
                ctx => {
                    var changed = false;
                    if (WFCommonUtility.IsURP()) {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_TransCutout", ctx.target);
                                break;
                            default:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF_URP/WF_UnToon_Opaque", ctx.target);
                                break;
                        }
                    }
#if UNITY_2019_1_OR_NEWER // Particle系は2018には入れないのでスキップする
                    else if (ctx.particle) {
                        switch(ctx.renderType) {
                            case ShaderType.Opaque:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_Particle_Opaque", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_Particle_TransCutout", ctx.target);
                                break;
                            case ShaderType.Transparent:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_Particle_Transparent", ctx.target);
                                break;
                            case ShaderType.Additive:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_Particle_Addition", ctx.target);
                                break;
                            default:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_Particle_Transparent", ctx.target);
                                break;
                        }
                    }
#endif
                    else if (ctx.outline) {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_TransCutout", ctx.target);
                                break;
                            default:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/UnToon_Outline/WF_UnToon_Outline_Opaque", ctx.target);
                                break;
                        }
                    }
                    else {
                        switch(ctx.renderType) {
                            case ShaderType.Transparent:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_Transparent", ctx.target);
                                break;
                            case ShaderType.Cutout:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_TransCutout", ctx.target);
                                break;
                            default:
                                changed |= WFCommonUtility.ChangeShader("UnlitWF/WF_UnToon_Opaque", ctx.target);
                                break;
                        }
                    }
                    // 変更に失敗した場合は変換を中止
                    if (!changed) {
                        throw new AbortAndResetConvertException();
                    }
                    // シェーダ切り替え後に RenderQueue をコピー
                    if (ctx.target.renderQueue != ctx.oldMaterial.renderQueue)
                    {
                        ctx.target.renderQueue = ctx.oldMaterial.renderQueue;
                    }
                },
                ctx => {
                    // もしTransparentかつQueueが2450未満のときは、2460に設定する
                    if (ctx.renderType == ShaderType.Transparent)
                    {
                        if (ctx.target.renderQueue < 2450)
                        {
                            ctx.target.renderQueue = 2460;
                        }
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
                    if (ctx.outline && WFAccessor.GetInt(ctx.target, "_CullMode", 0) == 2)
                    {
                        WFAccessor.SetInt(ctx.target, "_CullMode", 0);
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
                            WFAccessor.SetColor(ctx.target, "_Color", Color.white);
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
                        WFAccessor.SetInt(ctx.target, "_AL_Source", 1); // AlphaSource = MASK_TEX_RED
                    }
                },
                ctx => {
                    // ノーマルマップ
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        PropertyNameReplacement.Match("_NormalMap", "_BumpMap"));
                    if (HasNewPropertyValue(ctx, "_BumpMap")) {
                        WFAccessor.SetBool(ctx.target, "_NM_Enable", true);
                    }
                },
                ctx => {
                    // ノーマルマップ2nd
                    if (HasNewPropertyValue(ctx, "_DetailNormalMap")) {
                        WFAccessor.SetBool(ctx.target, "_NS_Enable", true);
                    }
                },
                ctx => {
                    // メタリック
                    if (HasNewPropertyValue(ctx, "_MetallicGlossMap", "_SpecGlossMap")) {
                        WFAccessor.SetBool(ctx.target, "_MT_Enable", true);
                    }
                },
                ctx => {
                    // AO
                    if (HasNewPropertyValue(ctx, "_OcclusionMap")) {
                        WFAccessor.SetBool(ctx.target, "_AO_Enable", true);
                    }
                },
                ctx => {
                    // Emission
                    WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                        PropertyNameReplacement.MatchIgnoreCase("_Emissive_Tex", "_EmissionMap"),
                        PropertyNameReplacement.MatchIgnoreCase("_Emissive_Color", "_EmissionColor"));
                    if (HasOldPropertyValue(ctx, "_EmissionMap", "_UseEmission", "_EmissionEnable", "_EnableEmission")) {
                        WFAccessor.SetBool(ctx.target, "_ES_Enable", true);
                    }
                },
                ctx => {
                    if (IsMatchShaderName(ctx, "Unlit/"))
                    {
                        return;
                    }
                    // Toon影
                    WFAccessor.SetBool(ctx.target, "_TS_Enable", true);
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
                        Color.RGBToHSV(WFAccessor.GetColor(ctx.target, "_TS_1stColor", Color.white), out hur, out sat, out val);
                        if (sat < 0.05f) {
                            hur = 4 / 6f;
                        }
                        WFAccessor.SetColor(ctx.target, "_TS_1stColor", Color.HSVToRGB(hur, 0.1f, 0.9f));
                    }
                    if (HasNewProperty(ctx, "_TS_2ndColor")) {
                        float hur, sat, val;
                        Color.RGBToHSV(WFAccessor.GetColor(ctx.target, "_TS_2ndColor", Color.white), out hur, out sat, out val);
                        if (sat < 0.05f) {
                            hur = 4 / 6f;
                        }
                        WFAccessor.SetColor(ctx.target, "_TS_2ndColor", Color.HSVToRGB(hur, 0.1f, 0.9f));
                    }
                    // これらのテクスチャが設定されているならば _MainTex を _TS_BaseTex にも設定する
                    if (HasNewPropertyValue(ctx, "_TS_1stTex", "_TS_2ndTex")) {
                        if (!HasNewPropertyValue(ctx, "_TS_BaseTex")) {
                            WFAccessor.CopyTextureValue(ctx.target, "_MainTex", "_TS_BaseTex");
                        }
                        if (!HasNewPropertyValue(ctx, "_TS_1stTex")) {
                            WFAccessor.CopyTextureValue(ctx.target, "_TS_BaseTex", "_TS_1stTex");
                        }
                        if (!HasNewPropertyValue(ctx, "_TS_2ndTex")) {
                            WFAccessor.CopyTextureValue(ctx.target, "_TS_1stTex", "_TS_2ndTex");
                        }
                        if (!HasNewPropertyValue(ctx, "_TS_3rdTex")) {
                            WFAccessor.CopyTextureValue(ctx.target, "_TS_2ndTex", "_TS_3rdTex");
                        }
                        // ただし _TS_BaseTex, _TS_1stTex, _TS_2ndTex, _TS_3rdTex が全て同じ Texture を指しているならば全てクリアする
                        if (ctx.target.GetTexture("_TS_BaseTex") == ctx.target.GetTexture("_TS_1stTex")
                            && ctx.target.GetTexture("_TS_1stTex") == ctx.target.GetTexture("_TS_2ndTex")
                            && ctx.target.GetTexture("_TS_2ndTex") == ctx.target.GetTexture("_TS_3rdTex")) {
                            WFAccessor.SetTexture(ctx.target, "_TS_BaseTex", null);
                            WFAccessor.SetTexture(ctx.target, "_TS_1stTex", null);
                            WFAccessor.SetTexture(ctx.target, "_TS_2ndTex", null);
                            WFAccessor.SetTexture(ctx.target, "_TS_3rdTex", null);
                        }
                    }
                },
                ctx => {
                    // リムライト
                    if (HasOldPropertyValue(ctx, "_UseRim", "_RimLight", "_RimLitEnable", "_EnableRimLighting")) {
                        WFAccessor.SetBool(ctx.target, "_TR_Enable", true);
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
                            WFAccessor.SetInt(ctx.target, "_TR_BlendType", 2);  // ADD
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
                            WFAccessor.SetTexture(ctx.target, "_TL_CustomColorTex", null);
                            WFAccessor.SetFloat(ctx.target, "_TL_BlendBase", 0.1f);
                        }
                        else
                        {
                            // そうではない場合 BlendCustom を調整する
                            WFAccessor.SetFloat(ctx.target, "_TL_BlendCustom", 0.1f);
                        }
                    }
                },
                ctx => {
                    // 色変換
                    var p = ctx.oldProps.GetValueOrNull("_MainTexHSVG");
                    if (p != null && (p.Type == ShaderUtil.ShaderPropertyType.Vector || p.Type == ShaderUtil.ShaderPropertyType.Color)) {
                        var hsv = p.ColorValue;
                        if (hsv.r != 0 || hsv.g != 1 || hsv.b != 1 || hsv.a != 1)
                        {
                            WFAccessor.SetBool(ctx.target, "_CLC_Enable", true);
                            WFAccessor.SetFloat(ctx.target, "_CLC_DeltaH", 0 <= hsv.r ? hsv.r : (hsv.r + 1));
                            WFAccessor.SetFloat(ctx.target, "_CLC_DeltaS", hsv.g - 1);
                            WFAccessor.SetFloat(ctx.target, "_CLC_DeltaV", hsv.b - 1);
                            WFAccessor.SetFloat(ctx.target, "_CLC_Gamma", hsv.a);
                        }
                        var t = ctx.oldProps.GetValueOrNull("_MainColorAdjustMask");
                        if (t != null && t.Type == ShaderUtil.ShaderPropertyType.TexEnv)
                        {
                            var tex = t.TextureValue;
                            WFAccessor.SetTexture(ctx.target, "_CLC_MaskTex", tex);
                        }
                    }
                },
                ctx => {
                    // グラデーションマップ
                    if (HasOldPropertyValue(ctx, "_MainGradationTex"))
                    {
                        WFAccessor.SetBool(ctx.target, "_CGR_Enable", true);
                        WFMaterialEditUtility.ReplacePropertyNamesWithoutUndo(ctx.target,
                            PropertyNameReplacement.MatchIgnoreCase("_MainGradationTex", "_CGR_GradMapTex")
                        );
                        var t = ctx.oldProps.GetValueOrNull("_MainColorAdjustMask");
                        if (t != null && t.Type == ShaderUtil.ShaderPropertyType.TexEnv)
                        {
                            var tex = t.TextureValue;
                            WFAccessor.SetTexture(ctx.target, "_CGR_MaskTex", tex);
                        }
                    }
                },
                ctx => {
                    if (IsMatchShaderName(ctx, "Particles/Standard Unlit") && HasOldPropertyValue(ctx, "_ColorMode"))
                    {
                        switch(WFAccessor.GetInt(ctx.oldMaterial, "_ColorMode", 0))
                        {
                            case 0: // Multiply
                                WFAccessor.SetInt(ctx.target, "_PA_VCBlendType", 0);
                                break;
                            case 1: // Additive
                                WFAccessor.SetInt(ctx.target, "_PA_VCBlendType", 1);
                                break;
                            case 2: // Subtractive
                                WFAccessor.SetInt(ctx.target, "_PA_VCBlendType", 2);
                                break;
                        }
                    }
                },
                ctx => {
                    // フリップブック
                    if (HasOldPropertyValue(ctx, "_FlipbookMode"))
                    {
                        WFAccessor.SetBool(ctx.target, "_PA_UseFlipBook", true);
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
                    resetParam.resetLit = true;
                    // resetParam.resetUnused = true;
                    resetParam.resetKeywords = true;
                    WFMaterialEditUtility.ResetPropertiesWithoutUndo(resetParam);
                },
            };
        }
    }

    static class ScanAndMigrationExecutor
    {
        public const int VERSION = 9;
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
            // 先に未保存分は全て書き出す
            AssetDatabase.SaveAssets();

            // Go Ahead
            var seeker = new MaterialSeeker();
            seeker.progressBarTitle = WFCommonUtility.DialogTitle;
            seeker.progressBarText = "Convert Materials...";
            var done = seeker.VisitAllMaterialsInProject(Migration);
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
            // 変換
            bool done = new WFMaterialMigrationConverter().ExecAutoConvert(mat) != 0;
            // 変換要否にかかわらずシェーダキーワードを整理する
            done |= WFCommonUtility.SetupMaterial(mat);
            if (done)
            {
                EditorUtility.SetDirty(mat);
            }
            return done;
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

            PropertyNameReplacement.Group("2023/08/27"),
            PropertyNameReplacement.Match("_GL_DisableBackLit", "_TS_DisableBackLit"), // 後でTRにもコピーする

            PropertyNameReplacement.Group("2024/01/28"), // TODO 後で変更
            PropertyNameReplacement.Match("_TR_Power", "_TR_Width"),
            PropertyNameReplacement.Match("_TR_PowerTop", "_TR_WidthTop"),
            PropertyNameReplacement.Match("_TR_PowerSide", "_TR_WidthSide"),
            PropertyNameReplacement.Match("_TR_PowerBottom", "_TR_WidthBottom"),
        };

        public static bool ExistsNeedsMigration(Material mat)
        {
            // UnlitWFのマテリアルを対象に変換する
            return WFCommonUtility.IsSupportedShader(mat) && WFMaterialEditUtility.ExistsNeedsMigration(mat, OldPropNameToNewPropNameList);
        }

        public static int GetIntOrDefault(Material mat, string name, int _default = default)
        {
            if (mat.HasProperty(name))
            {
                return mat.GetInt(name);
            }
            return _default;
        }

        protected override void OnAfterConvert(ConvertContext ctx)
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
                            if (WFCommonUtility.FormatPropName(propName, out var _, out var name)) {
                                if (name == "BlendNormal")
                                {
                                    var propName2 = propName.Replace("_BlendNormal", "_BlendNormal2");
                                    WFAccessor.CopyFloatValue(ctx.target, propName, propName2);
                                }
                            }
                        }
                        // BumpMap が未設定ならば _NM_Enable をオフにする
                        if (!HasNewPropertyValue(ctx, "_BumpMap"))
                        {
                            WFAccessor.SetBool(ctx.target, "_NM_Enable", false);
                        }
                    }
                },
                ctx => {
                    // _TS_Featherありの状態から_TS_1stFeatherに変更されたならば、
                    if (HasOldProperty(ctx, "_TS_Feather") && HasNewProperty(ctx, "_TS_1stFeather"))
                    {
                        WFAccessor.CopyFloatValue(ctx.target, "_TS_1stFeather", "_TS_2ndFeather");
                        WFAccessor.CopyFloatValue(ctx.target, "_TS_1stFeather", "_TS_3rdFeather");
                    }
                },
                ctx => {
                    // _ES_Shapeありの状態から_ES_SC_Shapeに変更されたならば、
                    if (HasOldProperty(ctx, "_ES_Shape") && HasNewProperty(ctx, "_ES_SC_Shape"))
                    {
                        // CONSTANTでないならばEmissiveScroll有効
                        WFAccessor.SetInt(ctx.target, "_ES_ScrollEnable", WFAccessor.GetInt(ctx.target, "_ES_SC_Shape", 3) != 3 ? 1 : 0);
                    }
                },
                ctx => {
                    // _ES_DirTypeありの状態から_ES_SC_DirTypeに変更されたならば、
                    if (HasOldProperty(ctx, "_ES_DirType") && HasNewProperty(ctx, "_ES_SC_DirType"))
                    {
                        // 変更前で 3:UV2 だったなら、2:UV に変更してUVTypeを 1:UV2 にする
                        if (WFAccessor.GetInt(ctx.target, "_ES_SC_DirType", 0) == 3)
                        {
                            WFAccessor.SetInt(ctx.target, "_ES_SC_DirType", 2);
                            WFAccessor.SetInt(ctx.target, "_ES_SC_UVType", 1);
                        }
                    }
                },
                ctx => {
                    // _GL_DisableBackLitありの状態からなしの状態に変更されたならば
                    if (HasOldProperty(ctx, "_GL_DisableBackLit") && HasNewProperty(ctx, "_TS_DisableBackLit"))
                    {
                        WFAccessor.CopyIntValue(ctx.target, "_TS_DisableBackLit", "_TR_DisableBackLit");
                    }
                },
                ctx => {
                    // _TR_Powerありの状態から_TR_Widthに変更されたならば、
                    if (HasOldProperty(ctx, "_TR_Power") && HasNewProperty(ctx, "_TR_Width"))
                    {
                        WFAccessor.SetFloat(ctx.target, "_TR_Width", Mathf.Clamp(WFAccessor.GetFloat(ctx.target, "_TR_Width", 1) * 0.1f, 0, 1));
                        WFAccessor.SetFloat(ctx.target, "_TR_WidthTop", Mathf.Clamp(WFAccessor.GetFloat(ctx.target, "_TR_WidthTop", 1) * 10, 0, 1));
                        WFAccessor.SetFloat(ctx.target, "_TR_WidthSide", Mathf.Clamp(WFAccessor.GetFloat(ctx.target, "_TR_WidthSide", 1) * 10, 0, 1));
                        WFAccessor.SetFloat(ctx.target, "_TR_WidthBottom", Mathf.Clamp(WFAccessor.GetFloat(ctx.target, "_TR_WidthBottom", 1) * 10, 0, 1));
                        WFAccessor.SetFloat(ctx.target, "_TR_Feather", 0.05f); // Featherはリセット
                    }
                },
            };
        }
    }
}

#endif
