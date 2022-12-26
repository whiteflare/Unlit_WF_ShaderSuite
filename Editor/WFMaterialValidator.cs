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
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace UnlitWF
{
    public class WFMaterialValidator
    {
        private readonly Func<Material[], Material[]> validate;
        private readonly Func<Material[], string> getMessage;
        private readonly MessageType messageType;
        private readonly Action<Material[]> action;

        public WFMaterialValidator(Func<Material[], Material[]> validate, Func<Material[], string> getMessage, MessageType messageType, Action<Material[]> action)
        {
            this.validate = validate;
            this.getMessage = getMessage;
            this.messageType = messageType;
            this.action = action;
        }

        public Result Validate(params Material[] targets)
        {
            targets = targets.Where(mat => mat != null && WFCommonUtility.IsSupportedShader(mat)).ToArray();
            targets = validate(targets);
            if (targets == null || targets.Length == 0)
            {
                return Result.Success;
            }
            return new Result(false, getMessage(targets), messageType, () => action(targets));
        }

        public struct Result
        {
            public static readonly Result Success = new Result(true, "", MessageType.None, () => { });

            public readonly bool valid;
            public readonly string message;
            public readonly MessageType messageType;
            public readonly Action action;

            public Result(bool valid, string message, MessageType messageType, Action action)
            {
                this.valid = valid;
                this.message = message;
                this.messageType = messageType;
                this.action = action;
            }
        }
    }

    public static class WFMaterialValidators
    {
        public static WFMaterialValidator[] Validators = {
            // マイグレーション
            new WFMaterialValidator(
                targets => WFMaterialCache.instance.FilterOldMaterial(targets),
                targets => WFI18N.Translate(WFMessageText.PlzMigration),
                MessageType.Warning,
                targets => {
                    WFMaterialEditUtility.MigrationMaterial(targets);
                }
            ),

            // BatchingStatic 向け設定がされていないマテリアルに対するアドバイス
            new WFMaterialValidator(
                targets => {
                    targets = targets.Where(target => {
                        // 現在のシェーダが DisableBatching == False のとき以外は何もしない (Batching されないので)
                        if (target == null || !target.GetTag("DisableBatching", false, "False").Equals("False", StringComparison.OrdinalIgnoreCase))
                        {
                            return false;
                        }
                        // ターゲットが設定用プロパティをどちらも持っていないならば何もしない
                        if (!target.HasProperty("_GL_DisableBackLit") && !target.HasProperty("_GL_DisableBasePos"))
                        {
                            return false;
                        }
                        // 設定用プロパティがどちらも設定されているならば何もしない
                        if (target.GetInt("_GL_DisableBackLit") != 0 && target.GetInt("_GL_DisableBasePos") != 0)
                        {
                            return false;
                        }
                        // それ以外は設定対象
                        return true;
                    }).ToArray();

                    // BatchingStatic 付きのマテリアルを返却
                    return FilterBatchingStaticMaterials(targets);
                },
                targets => WFI18N.Translate(WFMessageText.PlzBatchingStatic),
                MessageType.Info,
                targets => {
                    Undo.RecordObjects(targets, "Fix BatchingStatic Materials");
                    // _GL_DisableBackLit と _GL_DisableBasePos をオンにする
                    foreach (var mat in targets)
                    {
                        mat.SetInt("_GL_DisableBackLit", 1);
                        mat.SetInt("_GL_DisableBasePos", 1);
                    }
                }
            ),

            // LightmapStatic 向け設定がされていないマテリアルに対するアドバイス
            new WFMaterialValidator(
                targets => {
                    targets = targets.Where(target => {
                        // ターゲットが設定用プロパティを持っていないならば何もしない
                        if (!target.HasProperty("_AO_Enable") || !target.HasProperty("_AO_UseLightMap"))
                        {
                            return false;
                        }
                        // Lightmap Static のときにオンにしたほうがいい設定がオンになっているならば何もしない
                        if (target.GetInt("_AO_Enable") != 0 && target.GetInt("_AO_UseLightMap") != 0)
                        {
                            return false;
                        }
                        return true;
                    }).ToArray();

                    // LightmapStatic 付きのマテリアルを返却
                    return FilterLightmapStaticMaterials(targets);
                },
                targets => WFI18N.Translate(WFMessageText.PlzLightmapStatic),
                MessageType.Info,
                targets => {
                    Undo.RecordObjects(targets, "Fix LightmapStatic Materials");
                    // _AO_Enable と _AO_UseLightMap をオンにする
                    foreach (var mat in targets)
                    {
                        mat.SetInt("_AO_Enable", 1);
                        mat.SetInt("_AO_UseLightMap", 1);
                    }
                }
            ),

            new WFMaterialValidator(
                targets => {
                    targets = targets.Where(target => {
                        // DoubleSidedGI が付いていない、かつ Transparent か TransparentCutout なマテリアル
                        return !target.doubleSidedGI && WFAccessor.IsMaterialRenderType(target, "Transparent", "TransparentCutout");
                    }).ToArray();

                    // LightmapStatic 付きのマテリアルを返却
                    return FilterLightmapStaticMaterials(targets);
                },
                targets => WFI18N.Translate(WFMessageText.PlzFixDoubleSidedGI),
                MessageType.Info,
                targets => {
                    Undo.RecordObjects(targets, "Fix DoubleSidedGI");
                    // DoubleSidedGI をオンにする
                    foreach (var mat in targets)
                    {
                        mat.doubleSidedGI = true;
                    }
                }
            ),

            // 不透明レンダーキューを使用している半透明マテリアルに対する警告
            new WFMaterialValidator(
                // 現在編集中のマテリアルの配列のうち、RenderType が Transparent なのに 2500 未満で描画しているもの
                targets => targets.Where(mat => WFAccessor.IsMaterialRenderType(mat, "Transparent") && mat.renderQueue < 2500).ToArray(),
                targets => WFI18N.Translate(WFMessageText.PlzFixQueue),
                MessageType.Warning,
                targets => {
                    Undo.RecordObjects(targets, "Fix RenderQueue Materials");
                    foreach (var mat in targets)
                    {
                        mat.renderQueue = -1;
                    }
                }
            ),
        };

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

    public class WFMaterialCache : ScriptableSingleton<WFMaterialCache>
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
}

#endif
