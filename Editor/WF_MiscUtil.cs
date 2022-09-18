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

// VRCSDK有無の判定ここから //////
#if VRC_SDK_VRCSDK3
#define ENV_VRCSDK3
#if UDON
#define ENV_VRCSDK3_WORLD
#else
#define ENV_VRCSDK3_AVATAR
#endif
#endif
// VRCSDK有無の判定ここまで //////

using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.Animations;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UnlitWF
{
    internal enum MatSelectMode
    {
        FromScene = 1,
        FromAsset = 2,
        FromSceneOrAsset = 3,
        FromAssetDeep = 6,
    }

    internal class MaterialSeeker
    {
        public System.Func<Component, bool> FilterHierarchy = cmp => true;

        #region マテリアル列挙系(プロジェクトから)

        public IEnumerable<string> GetProjectAllMaterialPaths(params string[] folderPaths)
        {
            return (folderPaths.Length == 0 ?
                    AssetDatabase.FindAssets("t:Material") :
                    AssetDatabase.FindAssets("t:Material", folderPaths))
                        .Select(guid => AssetDatabase.GUIDToAssetPath(guid))
                        .Where(path => !string.IsNullOrWhiteSpace(path) && path.EndsWith(".mat"))
                        .Distinct();
        }

        public IEnumerable<string> GetProjectAllMaterialTemplatePaths(params string[] folderPaths)
        {
            return (folderPaths.Length == 0 ?
                    AssetDatabase.FindAssets("t:" + nameof(WFMaterialTemplate)) :
                    AssetDatabase.FindAssets("t:" + nameof(WFMaterialTemplate), folderPaths))
                        .Select(guid => AssetDatabase.GUIDToAssetPath(guid))
                        .Where(path => !string.IsNullOrWhiteSpace(path) && path.EndsWith(".asset"))
                        .Distinct();
        }

        public int SeekProjectAllMaterial(string title, System.Func<Material, bool> action)
        {
            return VisitMaterials<Material>(title, GetProjectAllMaterialPaths().ToArray(), mat => mat, action)
                + VisitMaterials<WFMaterialTemplate>(title, GetProjectAllMaterialTemplatePaths().ToArray(), tmp => tmp.material, action);
        }

        private int VisitMaterials<T>(string title, string[] path, System.Func<T, Material> load, System.Func<Material, bool> action) where T : UnityEngine.Object
        {
            int done = 0;
            if (0 < path.Length)
            {
                int current = 0;
                for (int i = 0; i < path.Length; i++)
                {
                    if (VisitMaterial<T>(path[i], load, action))
                    {
                        done++;
                    }
                    if (++current % 50 == 0 && EditorUtility.DisplayCancelableProgressBar("WF", title, current / (float)path.Length))
                    {
                        break;
                    }
                }
            }
            EditorUtility.ClearProgressBar();
            return done;
        }

        private bool VisitMaterial<T>(string path, System.Func<T, Material> load, System.Func<Material, bool> action) where T : UnityEngine.Object
        {
            if (!string.IsNullOrWhiteSpace(path))
            {
                var asset = AssetDatabase.LoadAssetAtPath<T>(path);
                if (asset != null)
                {
                    var mat = load(asset);
                    if (mat != null && action(mat))
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        #endregion

        #region マテリアル列挙系(Selectionから)

        public IEnumerable<Material> GetSelectionAllMaterial(MatSelectMode mode, List<Material> result = null)
        {
            InitList(ref result);

            if ((mode & MatSelectMode.FromScene) != 0)
            {
                // GameObject
                GetAllMaterials(Selection.GetFiltered<GameObject>(SelectionMode.Editable), result);
            }
            if ((mode & MatSelectMode.FromAsset) != 0)
            {
                // Materialアセット自体
                GetAllMaterials(Selection.GetFiltered<Material>(SelectionMode.Assets), result);
                // MaterialTemplate
                GetAllMaterials(Selection.GetFiltered<WFMaterialTemplate>(SelectionMode.Assets), result);
            }
            // サブフォルダ含めて
            if ((mode & MatSelectMode.FromAssetDeep) == MatSelectMode.FromAssetDeep)
            {
                var folders = Selection.GetFiltered<DefaultAsset>(SelectionMode.Assets)
                    .Select(asset => AssetDatabase.GetAssetPath(asset))
                    .Where(path => !string.IsNullOrWhiteSpace(path))
                    .Distinct()
                    .Where(path => System.IO.File.GetAttributes(path).HasFlag(System.IO.FileAttributes.Directory))
                    .ToArray();
                if (0 < folders.Length)
                {
                    GetAllMaterials(folders, result);
                }
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(string[] folderPaths, List<Material> result = null)
        {
            InitList(ref result);
            result.AddRange(
                GetProjectAllMaterialPaths(folderPaths)
                    .Select(path => AssetDatabase.LoadAssetAtPath<Material>(path))
                    .Where(mat => mat != null));
            result.AddRange(
                GetProjectAllMaterialTemplatePaths(folderPaths)
                    .Select(path => AssetDatabase.LoadAssetAtPath<WFMaterialTemplate>(path))
                    .Where(temp => temp != null && temp.material != null)
                    .Select(temp => temp.material));
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(Material[] mats, List<Material> result = null)
        {
            InitList(ref result);
            foreach (var mat in mats)
            {
                if (mat != null)
                {
                    result.Add(mat);
                }
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(WFMaterialTemplate[] temps, List<Material> result = null)
        {
            InitList(ref result);
            foreach (var temp in temps)
            {
                if (temp != null && temp.material != null)
                {
                    result.Add(temp.material);
                }
            }
            return result;
        }

        #endregion

        #region マテリアル列挙系(シーンから)

        public IEnumerable<Material> GetAllSceneAllMaterial(List<Material> result = null)
        {
            InitList(ref result);
            for (int i = 0; i < EditorSceneManager.sceneCount; i++)
            {
                GetAllMaterials(EditorSceneManager.GetSceneAt(i), result);
            }

            return result;
        }

        public IEnumerable<Material> GetAllMaterials(Scene scene, List<Material> result = null)
        {
            InitList(ref result);
            if (scene == null)
            {
                return result;
            }
            return GetAllMaterials(scene.GetRootGameObjects(), result);
        }

        public IEnumerable<Material> GetAllMaterials(GameObject[] gos, List<Material> result = null)
        {
            InitList(ref result);
            foreach (var go in gos)
            {
                GetAllMaterials(go, result);
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(GameObject go, List<Material> result = null)
        {
            InitList(ref result);
            if (go == null)
            {
                return result;
            }

            // Renderer -> Material
            foreach (var renderer in go.GetComponentsInChildren<Renderer>(true))
            {
                if (FilterHierarchy(renderer))
                {
                    GetAllMaterials(renderer, result);
                }
            }

            // Animator -> Controller -> AnimationClip -> Material
            foreach (var animator in go.GetComponentsInChildren<Animator>(true))
            {
                if (FilterHierarchy(animator))
                {
                    GetAllMaterials(animator.runtimeAnimatorController, result);
                }
            }

#if ENV_VRCSDK3_AVATAR
            // VRCAvatarDescriptor -> Controller -> AnimationClip -> Material
            foreach (var desc in go.GetComponentsInChildren<VRC.SDK3.Avatars.Components.VRCAvatarDescriptor>(true))
            {
                if (FilterHierarchy(desc))
                {
                    if (desc.customizeAnimationLayers)
                    {
                        foreach (var layer in desc.baseAnimationLayers)
                        {
                            GetAllMaterials(layer.animatorController, result);
                        }
                    }
                    foreach (var layer in desc.specialAnimationLayers)
                    {
                        GetAllMaterials(layer.animatorController, result);
                    }
                }
            }
#endif

            return result;
        }


        public IEnumerable<Material> GetAllMaterials(Renderer renderer, List<Material> result = null)
        {
            InitList(ref result);
            if (renderer == null)
            {
                return result;
            }
            foreach (var mat in renderer.sharedMaterials)
            {
                if (mat != null)
                {
                    result.Add(mat);
                }
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(RuntimeAnimatorController controller, List<Material> result = null)
        {
            InitList(ref result);
            if (controller == null)
            {
                return result;
            }
            if (controller is AnimatorController c2)
            {
                GetAllMaterials(c2, result);
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(AnimatorController controller, List<Material> result = null)
        {
            InitList(ref result);
            if (controller == null)
            {
                return result;
            }
            foreach (var clip in GetAllAnimationClip(controller))
            {
                foreach (var binding in AnimationUtility.GetObjectReferenceCurveBindings(clip))
                {
                    foreach (var keyFrame in AnimationUtility.GetObjectReferenceCurve(clip, binding))
                    {
                        if (keyFrame.value is Material mat)
                        {
                            result.Add(mat);
                        }
                    }
                }
            }
            return result;
        }

        private void InitList<T>(ref List<T> list)
        {
            if (list == null)
            {
                list = new List<T>();
            }
        }

        /// <summary>
        /// AnimatorControllerLayer 内の全ての AnimatorState を列挙する。
        /// </summary>
        /// <param name="layer"></param>
        /// <returns></returns>
        public IEnumerable<AnimatorState> GetAllState(AnimatorControllerLayer layer)
        {
            return GetAllState(layer?.stateMachine);
        }

        /// <summary>
        /// AnimatorStateMachine 内の全ての AnimatorState を列挙する。
        /// </summary>
        /// <param name="stateMachine"></param>
        /// <returns></returns>
        public IEnumerable<AnimatorState> GetAllState(AnimatorStateMachine stateMachine)
        {
            var result = new List<AnimatorState>();
            if (stateMachine != null)
            {
                result.AddRange(stateMachine.states.Select(state => state.state));
                foreach (var child in stateMachine.stateMachines)
                {
                    result.AddRange(GetAllState(child.stateMachine));
                }
            }
            return result;
        }

        /// <summary>
        /// AnimatorController 内の全ての AnimationClip を列挙する。
        /// </summary>
        /// <param name="animator"></param>
        /// <returns></returns>
        public IEnumerable<AnimationClip> GetAllAnimationClip(AnimatorController animator)
        {
            return animator.layers.SelectMany(ly => GetAllAnimationClip(ly)).Distinct();
        }

        /// <summary>
        /// AnimatorControllerLayer 内の全ての AnimationClip を列挙する。
        /// </summary>
        /// <param name="layer"></param>
        /// <returns></returns>
        public IEnumerable<AnimationClip> GetAllAnimationClip(AnimatorControllerLayer layer)
        {
            return GetAllState(layer).SelectMany(state => GetAllAnimationClip(state.motion)).Distinct();
        }

        private IEnumerable<AnimationClip> GetAllAnimationClip(Motion motion, List<AnimationClip> result = null)
        {
            if (result == null)
            {
                result = new List<AnimationClip>();
            }
            if (motion is AnimationClip clip)
            {
                if (!result.Contains(clip))
                {
                    result.Add(clip);
                }
            }
            else if (motion is BlendTree tree)
            {
                foreach (var ch in tree.children)
                {
                    GetAllAnimationClip(ch.motion, result);
                }
            }
            return result;
        }

        #endregion

    }

    internal static class CollectionUtility
    {
        public static T GetValueOrNull<K, T>(this Dictionary<K, T> dict, K key) where T : class
        {
            T value;
            if (dict.TryGetValue(key, out value))
            {
                return value;
            }
            return null;
        }
    }

    internal class WeakRefCache<T> where T : class
    {
        private readonly List<System.WeakReference> refs = new List<System.WeakReference>();

        public bool Contains(T target)
        {
            lock (refs)
            {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 参照が存在しているならばtrue
                foreach (var r in refs)
                {
                    if (r.Target == target)
                    {
                        return true;
                    }
                }
                return false;
            }
        }

        public void Add(T target)
        {
            lock (refs)
            {
                if (Contains(target))
                {
                    return;
                }
                refs.Add(new System.WeakReference(target));
            }
        }

        public void Remove(T target)
        {
            RemoveAll(target);
        }

        public void RemoveAll(params object[] targets)
        {
            lock (refs)
            {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 一致しているものを全て削除
                refs.RemoveAll(r =>
                {
                    var tgt = r.Target as T;
                    return tgt != null && targets.Contains(tgt);
                });
            }
        }

        public void Clear()
        {
            lock (refs)
            {
                refs.Clear();
            }
        }
    }

}

#endif
