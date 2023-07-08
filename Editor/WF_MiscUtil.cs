﻿/*
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
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UnlitWF
{
    enum MatSelectMode
    {
        FromScene = 1,
        FromAsset = 2,
        FromSceneOrAsset = 3,
        FromAssetDeep = 6,
    }

    class MaterialSeeker
    {
        public readonly List<IFromAssetSeeker> ProjectSeekers = new List<IFromAssetSeeker>();
        public readonly List<IFromComponentSeeker> ComponentSeekers = new List<IFromComponentSeeker>();
        public System.Func<Component, bool> FilterHierarchy = cmp => true;

        public string progressBarTitle = null;
        public string progressBarText = null;
        public int progressBarSpan = 10;

        public MaterialSeeker()
        {
            ProjectSeekers.Add(new FromAssetSeeker<Material>(".mat", mat => new Material[] { mat }));
            ProjectSeekers.Add(new FromAssetSeeker<WFMaterialTemplate>(".asset", temp => new Material[] { temp.material }));

            ComponentSeekers.Add(new FromComponentSeeker<Renderer>(GetAllMaterials));
            ComponentSeekers.Add(new FromComponentSeeker<Animator>(GetAllMaterials));
            ComponentSeekers.Add(new FromComponentSeeker<Projector>(GetAllMaterials));
            ComponentSeekers.Add(new FromComponentSeeker<Skybox>((skybox, result) => GetAllMaterials(skybox.material, result)));
#if ENV_VRCSDK3_AVATAR
            // VRCAvatarDescriptor -> Controller -> AnimationClip -> Material
            ComponentSeekers.Add(new FromComponentSeeker<VRC.SDK3.Avatars.Components.VRCAvatarDescriptor>((desc, result) => {
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
                return result;
            }));
#endif
#if ENV_VRCSDK3_WORLD
            ComponentSeekers.Add(new FromComponentSeeker<VRC.SDK3.Components.VRCSceneDescriptor>((desc, result) => {
                GetAllMaterials(desc.DynamicMaterials, result);
                return result;
            }));
#endif
        }

        #region マテリアル列挙系(プロジェクトから)

        public IEnumerable<Material> GetAllMaterialsFromProject(params string[] folderPaths)
        {
            var visited = new HashSet<Material>();
            return IterateAllMaterialsFromProject(folderPaths, visited).SelectMany(getter => getter());
        }

        public int VisitAllMaterialsInProject(System.Func<Material, bool> action, params string[] folderPaths)
        {
            var visited = new HashSet<Material>();
            return VisitAllMaterials(IterateAllMaterialsFromProject(folderPaths, visited).ToArray(), action);
        }

        private int VisitAllMaterials(System.Func<IEnumerable<Material>>[] getters, System.Func<Material, bool> action)
        {
            var done = 0;
            var useProgressBar = !string.IsNullOrWhiteSpace(progressBarTitle) && !string.IsNullOrWhiteSpace(progressBarText) && 0 < progressBarSpan;

            var current = 0;
            foreach (var getter in getters)
            {
                foreach (var mat in getter())
                {
                    if (mat != null && action(mat))
                    {
                        done++;
                    }
                }
                current++;
                if (useProgressBar && current % progressBarSpan == 0)
                {
                    var progress = current / (float)getters.Length;
                    if (EditorUtility.DisplayCancelableProgressBar(progressBarTitle, progressBarText, progress))
                    {
                        goto EXIT;
                    }
                }
            }

        EXIT:
            if (useProgressBar)
            {
                EditorUtility.ClearProgressBar();
            }
            return done;
        }

        private IEnumerable<System.Func<IEnumerable<Material>>> IterateAllMaterialsFromProject(string[] folderPaths, HashSet<Material> visited)
        {
            foreach (var seeker in ProjectSeekers)
            {
                var guids = folderPaths.Length == 0 ?
                    AssetDatabase.FindAssets("t:" + seeker.ComponentType.Name) :
                    AssetDatabase.FindAssets("t:" + seeker.ComponentType.Name, folderPaths);
                var paths = guids
                        .Select(AssetDatabase.GUIDToAssetPath)
                        .Where(seeker.IsValidPath)
                        .Distinct().ToArray();
                foreach (var path in paths)
                {
                    yield return () => FilterNotVisited(seeker.LoadFromPath(path), visited);
                }
            }
        }

        private static IEnumerable<Material> FilterNotVisited(IEnumerable<Material> src, HashSet<Material> visited)
        {
            foreach(var mat in src)
            {
                if (visited.Contains(mat))
                {
                    continue;
                }
                visited.Add(mat);
                yield return mat;
            }
        }

        #endregion

        #region マテリアル列挙系(Selectionから)

        public IEnumerable<Material> GetAllMaterialsInSelection(MatSelectMode mode)
        {
            var visited = new HashSet<Material>();
            return IterateAllMaterialsFromSelection(mode, visited).SelectMany(getter => getter());
        }

        public int VisitAllMaterialsInSelection(MatSelectMode mode, System.Func<Material, bool> action)
        {
            var visited = new HashSet<Material>();
            return VisitAllMaterials(IterateAllMaterialsFromSelection(mode, visited).ToArray(), action);
        }

        private IEnumerable<System.Func<IEnumerable<Material>>> IterateAllMaterialsFromSelection(MatSelectMode mode, HashSet<Material> visited)
        {
            if ((mode & MatSelectMode.FromScene) != 0)
            {
                // GameObject
                foreach(var mat in FilterNotVisited(GetAllMaterials(Selection.GetFiltered<GameObject>(SelectionMode.Editable)), visited))
                {
                    yield return () => new Material[] { mat };
                }
            }
            if ((mode & MatSelectMode.FromAsset) != 0)
            {
                foreach (var seeker in ProjectSeekers)
                {
                    foreach (var mat in FilterNotVisited(seeker.LoadFromSelection(), visited))
                    {
                        yield return () => new Material[] { mat };
                    }
                }
            }
            // サブフォルダ含めて
            if ((mode & MatSelectMode.FromAssetDeep) == MatSelectMode.FromAssetDeep)
            {
                var folderPaths = Selection.GetFiltered<DefaultAsset>(SelectionMode.Assets)
                    .Select(asset => AssetDatabase.GetAssetPath(asset))
                    .Where(path => !string.IsNullOrWhiteSpace(path))
                    .Distinct()
                    .Where(path => System.IO.File.GetAttributes(path).HasFlag(System.IO.FileAttributes.Directory))
                    .ToArray();
                if (0 < folderPaths.Length)
                {
                    foreach(var getter in IterateAllMaterialsFromProject(folderPaths, visited))
                    {
                        yield return getter;
                    }
                }
            }
        }

        #endregion

        #region マテリアル列挙系(シーンから)

        public IEnumerable<Material> GetAllMaterialsInScene(List<Material> result = null)
        {
            InitList(ref result);
            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                Scene scene = SceneManager.GetSceneAt(i);
                if (scene.isLoaded) // SceneManagerで取るときはisLoadedを確認する
                {
                    GetAllMaterials(scene, result);
                }
            }

            return result;
        }

        public IEnumerable<Material> GetAllMaterials(Scene scene, List<Material> result = null)
        {
            InitList(ref result);
            if (scene == null) // IProcessSceneWithReport.OnProcessSceneの実装クラスから呼び出されるここではisLoadedは確認しない
            {
                return result;
            }
            // スカイボックス取得
            GetAllMaterials(RenderSettings.skybox, result);
            // 各GameObject配下のマテリアルを取得
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
            foreach (var seeker in ComponentSeekers)
            {
                seeker.FindMaterials(go, FilterHierarchy, result);
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(Renderer renderer, List<Material> result = null)
        {
            InitList(ref result);
            if (renderer == null)
            {
                return result;
            }
            GetAllMaterials(renderer.sharedMaterials, result);
            if (renderer is ParticleSystemRenderer psr)
            {
                GetAllMaterials(psr.trailMaterial, result);
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(Projector projector, List<Material> result = null)
        {
            InitList(ref result);
            if (projector == null)
            {
                return result;
            }
            GetAllMaterials(projector.material, result);
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(Animator animator, List<Material> result = null)
        {
            InitList(ref result);
            if (animator == null)
            {
                return result;
            }
            GetAllMaterials(animator.runtimeAnimatorController, result);
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
                        GetAllMaterials(keyFrame.value as Material, result);
                    }
                }
            }
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(IEnumerable<Material> materials, List<Material> result)
        {
            InitList(ref result);
            if (materials == null)
            {
                return result;
            }
            result.AddRange(materials.Where(mat => mat != null));
            return result;
        }

        public IEnumerable<Material> GetAllMaterials(Material mat, List<Material> result)
        {
            InitList(ref result);
            if (mat != null)
            {
                result.Add(mat);
            }
            return result;
        }

        private static void InitList<T>(ref List<T> list)
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
        private IEnumerable<AnimatorState> GetAllState(AnimatorControllerLayer layer)
        {
            return GetAllState(layer?.stateMachine);
        }

        /// <summary>
        /// AnimatorStateMachine 内の全ての AnimatorState を列挙する。
        /// </summary>
        /// <param name="stateMachine"></param>
        /// <returns></returns>
        private IEnumerable<AnimatorState> GetAllState(AnimatorStateMachine stateMachine)
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
        private IEnumerable<AnimationClip> GetAllAnimationClip(AnimatorController animator)
        {
            return animator.layers.SelectMany(ly => GetAllAnimationClip(ly)).Distinct();
        }

        /// <summary>
        /// AnimatorControllerLayer 内の全ての AnimationClip を列挙する。
        /// </summary>
        /// <param name="layer"></param>
        /// <returns></returns>
        private IEnumerable<AnimationClip> GetAllAnimationClip(AnimatorControllerLayer layer)
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

        public interface IFromAssetSeeker
        {
            System.Type ComponentType { get; }
            bool IsValidPath(string path);
            IEnumerable<Material> LoadFromPath(string path);
            IEnumerable<Material> LoadFromSelection();
        }

        public class FromAssetSeeker<T> : IFromAssetSeeker where T : Object
        {
            public readonly string extension;
            public readonly System.Func<T, IEnumerable<Material>> getMaterials;

            public FromAssetSeeker(string extension, System.Func<T, IEnumerable<Material>> getMaterials)
            {
                this.extension = extension;
                this.getMaterials = getMaterials;
            }

            public System.Type ComponentType => typeof(T);

            public bool IsValidPath(string path)
            {
                return !string.IsNullOrWhiteSpace(path) && path.EndsWith(extension);
            }

            public IEnumerable<Material> LoadFromPath(string path)
            {
                if (IsValidPath(path))
                {
                    return getMaterials(AssetDatabase.LoadAssetAtPath<T>(path));
                }
                return new Material[0];
            }

            public IEnumerable<Material> LoadFromSelection()
            {
                return Selection.GetFiltered<T>(SelectionMode.Assets).SelectMany(getMaterials).Distinct();
            }
        }

        public interface IFromComponentSeeker
        {
            void FindMaterials(GameObject go, System.Func<Component, bool> filter, List<Material> result);
        }

        public class FromComponentSeeker<T> : IFromComponentSeeker where T : Component
        {
            public System.Func<T, List<Material>, IEnumerable<Material>> getMaterials;

            public FromComponentSeeker(System.Func<T, List<Material>, IEnumerable<Material>> getMaterials)
            {
                this.getMaterials = getMaterials;
            }

            public void FindMaterials(GameObject go, System.Func<Component, bool> filter, List<Material> result)
            {
                foreach (var cmp in go.GetComponentsInChildren<T>(true))
                {
                    if (filter(cmp))
                    {
                        getMaterials((T)cmp, result);
                    }
                }
            }
        }
    }

    static class CollectionUtility
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

    class WeakRefCache<T> where T : class
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

    class CoroutineHandler : MonoBehaviour
    {
        private static CoroutineHandler m_Instance;
        private static CoroutineHandler instance
        {
            get
            {
                if (m_Instance == null)
                {
                    GameObject o = new GameObject("CoroutineHandler");
                    o.hideFlags = HideFlags.HideAndDontSave;
                    m_Instance = o.AddComponent<CoroutineHandler>();
                }
                return m_Instance;
            }
        }

        public void OnDisable()
        {
            if (m_Instance)
            {
                Destroy(m_Instance.gameObject);
            }
        }

        public static Coroutine StartStaticCoroutine(System.Collections.IEnumerator coroutine)
        {
            return instance.StartCoroutine(coroutine);
        }
    }
}

#endif
