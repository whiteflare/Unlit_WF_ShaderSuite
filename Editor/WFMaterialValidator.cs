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
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

#if UNITY_2021_2_OR_NEWER
using UnityEditor.SceneManagement;
#else
using UnityEditor.Experimental.SceneManagement;
#endif

namespace UnlitWF
{
    class WFMaterialValidator
    {
        private readonly Func<Material[], Material[]> validate;
        private readonly MessageType messageType;
        private readonly Func<Material[], string> getMessage;
        private readonly Action<Material[]> action;

        public WFMaterialValidator(Func<Material[], Material[]> validate, MessageType messageType, Func<Material[], string> getMessage, Action<Material[]> action)
        {
            this.validate = validate;
            this.messageType = messageType;
            this.getMessage = getMessage;
            this.action = action;
        }

        public Advice Validate(params Material[] mats)
        {
            var targets = validate(mats.Where(mat => mat != null && WFCommonUtility.IsSupportedShader(mat)).ToArray());
            if (targets == null || targets.Length == 0)
            {
                return null;
            }
            return new Advice(this, targets, messageType, getMessage(targets), action == null ? (Action)null : () => action(targets));
        }

        internal class Advice
        {
            public readonly WFMaterialValidator source;
            public readonly Material[] targets;
            public readonly string message;
            public readonly MessageType messageType;
            public readonly Action action;

            public Advice(WFMaterialValidator source, Material[] targets, MessageType messageType, string message, Action action)
            {
                this.source = source;
                this.targets = targets;
                this.messageType = messageType;
                this.message = message;
                this.action = action;
            }
        }
    }

    static class WFMaterialValidators
    {
        public static WFMaterialValidator[] Validators = {
            // マイグレーションが必要な時に警告
            new WFMaterialValidator(
                targets => WFMaterialCache.instance.FilterOldMaterial(targets),
                MessageType.Warning,
                targets => WFI18N.Translate(WFMessageText.PlzMigration),
                targets => {
                    WFMaterialEditUtility.MigrationMaterial(targets);
                }
            ),

            // BatchingStatic 向け設定がされていないマテリアルに対する警告
            new WFMaterialValidator(
                targets => {
                    targets = targets.Where(target => {
                        // 現在のシェーダが DisableBatching == False のとき以外は何もしない (Batching されないので)
                        if (target == null || !target.GetTag("DisableBatching", false, "False").Equals("False", StringComparison.OrdinalIgnoreCase))
                        {
                            return false;
                        }
                        // 設定用プロパティが設定されていない場合に設定する
                        if (!WFAccessor.GetBool(target, "_GL_DisableBasePos", true))
                        {
                            return true;
                        }
                        if (target.HasProperty("_GL_DisableBackLit"))
                        {
                            if (!WFAccessor.GetBool(target, "_GL_DisableBackLit", true))
                            {
                                return true;
                            }
                        }
                        else
                        {
                            if (WFEditorSetting.GetOneOfSettings().GetDisableBackLitInCurrentEnvironment() == MatForceSettingMode.PerMaterial)
                            {
                                if (WFAccessor.GetBool(target, "_TS_Enable", false) && !WFAccessor.GetBool(target, "_TS_DisableBackLit", true))
                                {
                                    return true;
                                }
                                if (WFAccessor.GetBool(target, "_TR_Enable", false) && !WFAccessor.GetBool(target, "_TR_DisableBackLit", true))
                                {
                                    return true;
                                }
                            }
                        }
                        // それ以外は設定不要
                        return false;
                    }).ToArray();

                    // BatchingStatic 付きのマテリアルを返却
                    return FilterBatchingStaticMaterials(targets);
                },
                MessageType.Info,
                targets => WFI18N.Translate(WFMessageText.PlzBatchingStatic),
                targets => {
                    Undo.RecordObjects(targets, "Fix BatchingStatic Materials");
                    // _GL_DisableBackLit と _GL_DisableBasePos をオンにする
                    foreach (var mat in targets)
                    {
                        WFAccessor.SetBool(mat, "_GL_DisableBackLit", true);
                        WFAccessor.SetBool(mat, "_GL_DisableBasePos", true);
                        if (WFEditorSetting.GetOneOfSettings().GetDisableBackLitInCurrentEnvironment() == MatForceSettingMode.PerMaterial)
                        {
                            if (WFAccessor.GetBool(mat, "_TS_Enable", false))
                            {
                                WFAccessor.SetBool(mat, "_TS_DisableBackLit", true);
                            }
                            if (WFAccessor.GetBool(mat, "_TR_Enable", false))
                            {
                                WFAccessor.SetBool(mat, "_TR_DisableBackLit", true);
                            }
                        }
                    }
                }
            ),

            // LightmapStatic 向け設定がされていないマテリアルに対する警告
            new WFMaterialValidator(
                targets => {
                    targets = targets.Where(target => {
                        // ターゲットが設定用プロパティを両方とも持っていないならば何もしない
                        if (target.HasProperty("_AO_Enable") && target.HasProperty("_AO_UseLightMap"))
                        {
                            // Lightmap Static のときにオンにしたほうがいい設定がオンになっているならば何もしない
                            if (!WFAccessor.GetBool(target, "_AO_Enable", true) || !WFAccessor.GetBool(target, "_AO_UseLightMap", true))
                            {
                                return true;
                            }
                        }
                        return false;
                    }).ToArray();

                    // LightmapStatic 付きのマテリアルを返却
                    return FilterLightmapStaticMaterials(targets);
                },
                MessageType.Info,
                targets => WFI18N.Translate(WFMessageText.PlzLightmapStatic),
                targets => {
                    Undo.RecordObjects(targets, "Fix LightmapStatic Materials");
                    // _AO_Enable と _AO_UseLightMap をオンにする
                    foreach (var mat in targets)
                    {
                        WFAccessor.SetBool(mat, "_AO_Enable", true);
                        WFAccessor.SetBool(mat, "_AO_UseLightMap", true);
                    }
                }
            ),

            // 不透明レンダーキューを使用している半透明マテリアルに対する警告
            new WFMaterialValidator(
                // 現在編集中のマテリアルの配列のうち、RenderType が Transparent なのに 2500 以下で描画しているもの(かつCLR_BG非対応のもの)
                targets => targets.Where(mat => WFAccessor.IsMaterialRenderType(mat, "Transparent")
                    && mat.renderQueue <= 2500
                    && !WFAccessor.GetShaderClearBgSupported(mat.shader)).ToArray(),
                MessageType.Warning,
                targets => WFI18N.Translate(WFMessageText.PlzFixQueue),
                targets => {
                    Undo.RecordObjects(targets, "Fix RenderQueue Materials");
                    foreach (var mat in targets)
                    {
                        mat.renderQueue = -1;
                    }
                }
            ),

            WFMaterialParticleValidator.Validator,

            // 今後削除される予定の機能を使っている場合に警告
            new WFMaterialValidator(
                targets => targets.Where(mat => WFAccessor.GetInt(mat, "_CHM_Enable", 0) != 0).ToArray(),
                MessageType.Warning,
                targets => WFI18N.Translate(WFMessageText.PlzDeprecatedFeature) + ": " + WFI18N.Translate("3ch Color Mask"),
                null // アクションなし
            ),
            new WFMaterialValidator(
                targets => targets.Where(mat => WFAccessor.GetInt(mat, "_MT_Enable", 0) != 0 && WFAccessor.GetInt(mat, "_MT_MetallicMapType", 0) != 0).ToArray(),
                MessageType.Warning,
                targets => WFI18N.Translate(WFMessageText.PlzDeprecatedFeature) + ": " + WFI18N.Translate("MT", "MetallicMap Type"),
                null // アクションなし
            ),

            // DoubleSidedGI が付いていない両面マテリアルに対する情報
            new WFMaterialValidator(
                targets => {
                    targets = targets.Where(target => {
                        // DoubleSidedGI が付いていない、かつ Transparent か TransparentCutout なマテリアル
                        return !target.doubleSidedGI && WFAccessor.IsMaterialRenderType(target, "Transparent", "TransparentCutout");
                    }).ToArray();

                    // LightmapStatic 付きのマテリアルを返却
                    return FilterLightmapStaticMaterials(targets);
                },
                MessageType.Info,
                targets => WFI18N.Translate(WFMessageText.PlzFixDoubleSidedGI),
                targets => {
                    Undo.RecordObjects(targets, "Fix DoubleSidedGI");
                    // DoubleSidedGI をオンにする
                    foreach (var mat in targets)
                    {
                        mat.doubleSidedGI = true;
                    }
                }
            ),

            // 不透明レンダーキューを使用している半透明マテリアルに対する情報
            new WFMaterialValidator(
                // 現在編集中のマテリアルの配列のうち、RenderType が Transparent なのに 2500 以下で描画しているもの(かつCLR_BG対応のもの)
                targets => targets.Where(mat => WFAccessor.IsMaterialRenderType(mat, "Transparent")
                    && mat.renderQueue <= 2500
                    && WFAccessor.GetShaderClearBgSupported(mat.shader)).ToArray(),
                MessageType.Info,
                targets => WFI18N.Translate(WFMessageText.PlzFixQueueWithClearBg),
                null // アクションなし
            ),

            // モバイル向けではないシェーダを使用している場合にメッセージ
            new WFMaterialValidator(
                targets => WFCommonUtility.IsQuestPlatform() ? targets.Where(tgt => !WFCommonUtility.IsMobileSupportedShader(tgt)).ToArray() : new Material[0],
                MessageType.Info,
                targets => WFI18N.Translate(WFMessageText.PlzQuestSupport),
                null // アクションなし、変えると戻すのが大変なので
            ),

        };

        public static List<WFMaterialValidator.Advice> ValidateAll(params Material[] mats)
        {
            var result = new List<WFMaterialValidator.Advice>();
            foreach(var v in Validators)
            {
                var advice = v.Validate(mats);
                if (advice != null)
                {
                    result.Add(advice);
                }
            }
            return result.OrderByDescending(adv => adv.messageType).ToList();
        }

        /// <summary>
        /// 引数のマテリアルのうち、BatchingStatic 付き MeshRenderer から使用されているものを返却する。
        /// </summary>
        /// <param name="src"></param>
        /// <returns></returns>
        private static Material[] FilterBatchingStaticMaterials(Material[] mats)
        {
            var scene = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene();

            // 現在のシーンにある BatchingStatic の付いた MeshRenderer が使っているマテリアルを整理
            var matsInScene = scene.GetRootGameObjects()
                .SelectMany(go => go.GetComponentsInChildren<MeshRenderer>(true))
                .Where(mf => GameObjectUtility.AreStaticEditorFlagsSet(mf.gameObject, StaticEditorFlags.BatchingStatic))
                .SelectMany(mf => mf.sharedMaterials)
                .ToArray();

            return mats.Where(mat => matsInScene.Contains(mat)).ToArray();
        }

        /// <summary>
        /// 引数のマテリアルのうち、LightmapStatic 付き MeshRenderer から使用されているものを返却する。
        /// </summary>
        /// <param name="src"></param>
        /// <returns></returns>
        private static Material[] FilterLightmapStaticMaterials(Material[] mats)
        {
            var scene = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene();

            // 現在のシーンにある LightmapStatic の付いた MeshRenderer が使っているマテリアルを整理
            var matsInScene = scene.GetRootGameObjects()
                .SelectMany(go => go.GetComponentsInChildren<MeshRenderer>(true))
#if UNITY_2019_1_OR_NEWER
                .Where(mf => GameObjectUtility.AreStaticEditorFlagsSet(mf.gameObject, StaticEditorFlags.ContributeGI))
                .Where(mf => mf.receiveGI == ReceiveGI.Lightmaps)
                .Where(mf => 0 < mf.scaleInLightmap) // Unity2018では見えない
#else
                .Where(mf => GameObjectUtility.AreStaticEditorFlagsSet(mf.gameObject, StaticEditorFlags.LightmapStatic))
#endif
                .SelectMany(mf => mf.sharedMaterials)
                .ToArray();

            return mats.Where(mat => matsInScene.Contains(mat)).ToArray();
        }
    }

    class WFMaterialCache : ScriptableSingleton<WFMaterialCache>
    {
        private readonly WeakRefCache<Material> oldMaterialVersionCache = new WeakRefCache<Material>();
        private readonly WeakRefCache<Material> newMaterialVersionCache = new WeakRefCache<Material>();

        public void OnEnable()
        {
            Undo.undoRedoPerformed += OnUndoOrRedo;
        }

        public void OnDestroy()
        {
            Undo.undoRedoPerformed -= OnUndoOrRedo;
        }

        private void OnUndoOrRedo()
        {
            // undo|redo のタイミングではキャッシュが当てにならないのでクリアする
            oldMaterialVersionCache.Clear();
            newMaterialVersionCache.Clear();
        }

        public bool IsOldMaterial(Material mat)
        {
            if (mat == null)
            {
                return false;
            }
            if (newMaterialVersionCache.Contains(mat))
            {
                return false;
            }
            if (oldMaterialVersionCache.Contains(mat))
            {
                return true;
            }
            bool old = WFMaterialEditUtility.ExistsNeedsMigration(mat);
            if (old)
            {
                oldMaterialVersionCache.Add(mat);
            }
            else
            {
                newMaterialVersionCache.Add(mat);
            }
            return old;
        }

        public bool IsOldMaterial(params Material[] mats)
        {
            return mats.Any(mat => IsOldMaterial(mat));
        }

        public Material[] FilterOldMaterial(Material[] mats)
        {
            return mats.Where(mat => IsOldMaterial(mat)).ToArray();
        }

        public void ResetOldMaterialTable(params Material[] values)
        {
            var mats = values.Where(mat => mat != null).ToArray();
            oldMaterialVersionCache.RemoveAll(mats);
            newMaterialVersionCache.RemoveAll(mats);
        }
    }

    class WFMaterialParticleValidator : ScriptableSingleton<WFMaterialParticleValidator>
    {
        public static readonly WFMaterialValidator Validator = new WFMaterialValidator(
                ValidateMaterials,
                MessageType.Warning,
                targets => WFI18N.Translate(WFMessageText.PlzFixParticleVertexStreams),
                FixParticleSystems
            );

        public void OnEnable()
        {
            EditorApplication.hierarchyChanged += OnHierarchyChanged;
            PrefabStage.prefabStageOpened += OnPrefabStageOpened;
        }

        public void OnDestroy()
        {
            EditorApplication.hierarchyChanged -= OnHierarchyChanged;
            PrefabStage.prefabStageOpened -= OnPrefabStageOpened;
        }

        private void OnHierarchyChanged()
        {
            renderers = null;
        }

        private void OnPrefabStageOpened(PrefabStage obj)
        {
            renderers = null;
        }

        private ParticleSystemRenderer[] renderers = null;

        private ParticleSystemRenderer[] GetSceneRenderers()
        {
            if (renderers != null)
                return renderers;

            var list = new List<ParticleSystemRenderer>();

            var prefabStage = PrefabStageUtility.GetCurrentPrefabStage();
            if (prefabStage != null)
            {
                var root = prefabStage.prefabContentsRoot;
                list.AddRange(root.GetComponentsInChildren<ParticleSystemRenderer>(true));
            }
            else
            {
                for (int i = 0; i < SceneManager.sceneCount; i++)
                {
                    Scene scene = SceneManager.GetSceneAt(i);
                    if (scene.isLoaded) // SceneManagerで取るときはisLoadedを確認する
                    {
                        foreach (var root in scene.GetRootGameObjects())
                        {
                            list.AddRange(root.GetComponentsInChildren<ParticleSystemRenderer>(true));
                        }
                    }
                }
            }

            return renderers = list.ToArray();
        }

        private ParticleSystemRenderer[] GetRenderers(Material mat)
        {
            var all = GetSceneRenderers();
            return all.Where(r => r != null && r.sharedMaterial == mat).ToArray();
        }

        private static Material[] ValidateMaterials(params Material[] targets)
        {
            // パーティクル系シェーダを使っているマテリアルに対して
            targets = targets.Where(mat => mat.shader.name.Contains("Particle")).ToArray();
            if (targets.Length == 0)
            {
                // パーティクル系ではないときは何もしない
                return new Material[0];
            }

            var renderers = instance.GetSceneRenderers();
            if (renderers.Length == 0)
            {
                return new Material[0];
            }

            return targets.Where(mat =>
            {
                GetRequiredStream(mat, out var streams, out var instancedStreams);
                return instance.GetRenderers(mat).Any(r =>
                {
                    var st = new List<ParticleSystemVertexStream>();
                    r.GetActiveVertexStreams(st);
                    if (IsUseMeshInstancing(r))
                        return !st.SequenceEqual(instancedStreams);
                    else
                        return !st.SequenceEqual(streams);
                });
            }).ToArray();
        }

        private static void FixParticleSystems(params Material[] targets)
        {
            var renderers = instance.GetSceneRenderers();
            if (renderers.Length == 0)
            {
                return;
            }

            Undo.RecordObjects(renderers.ToArray(), "Apply custom vertex streams from material");

            foreach(var mat in targets)
            {
                GetRequiredStream(mat, out var streams, out var instancedStreams);
                foreach(var r in instance.GetRenderers(mat))
                {
                    if (IsUseMeshInstancing(r))
                        r.SetActiveVertexStreams(instancedStreams);
                    else
                        r.SetActiveVertexStreams(streams);
                }
            }
        }

        private static bool IsUseMeshInstancing(ParticleSystemRenderer r)
        {
#if UNITY_2019_4_OR_NEWER
            return r.renderMode == ParticleSystemRenderMode.Mesh && r.supportsMeshInstancing;
#else
            return false;
#endif
        }

        private static void GetRequiredStream(Material mat, out List<ParticleSystemVertexStream> streams, out List<ParticleSystemVertexStream> instancedStreams)
        {
            streams = new List<ParticleSystemVertexStream>();
            streams.Add(ParticleSystemVertexStream.Position);
            streams.Add(ParticleSystemVertexStream.Color);
            streams.Add(ParticleSystemVertexStream.UV);

            instancedStreams = new List<ParticleSystemVertexStream>(streams);

            if (WFAccessor.GetBool(mat, "_PA_UseFlipBook", false))
            {
                streams.Add(ParticleSystemVertexStream.UV2);
                streams.Add(ParticleSystemVertexStream.AnimBlend);
            }

            // Instancing時はFlipBook使用しているか否かに関わらずAnimFrameを含める必要がある
            instancedStreams.Add(ParticleSystemVertexStream.AnimFrame);
        }

        public static WFMaterialValidator.Advice Validate(params Material[] targets)
        {
            return Validator.Validate(targets);
        }

        public static IEnumerable<string> GetRequiredStreamText(Material[] mat)
        {
            var rs = mat.SelectMany(instance.GetRenderers).ToArray();
            var useGPUInstancing = rs.Any(IsUseMeshInstancing);
            var useFlipBookBlending = mat.Any(m => WFAccessor.GetBool(m, "_PA_UseFlipBook", false));

            var result = new List<string>();
            
            if (!useGPUInstancing)
            {
                result.Add("Position (POSITION.xyz)");
                result.Add("Color(COLOR.xyzw)");
                result.Add("UV (TEXCOORD0.xy)");
                if (useFlipBookBlending)
                {
                    result.Add("UV2 (TEXCOORD0.zw)");
                    result.Add("AnimBlend (TEXCOORD1.x)");
                }
            }
            else
            {
                result.Add("Position (POSITION.xyz)");
                result.Add("Color(INSTANCED0.xyzw)");
                result.Add("UV (TEXCOORD0.xy)");
                result.Add("AnimFrame (INSTANCED1.x)"); // Instancing時はFlipBook使用しているか否かに関わらずAnimFrameを含める必要がある
            }

            return result;
        }
    }
}

#endif
