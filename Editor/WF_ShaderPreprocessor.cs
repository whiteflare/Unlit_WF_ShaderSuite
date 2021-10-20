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

// #define WF_STRIP_DISABLE // Strippingそのものを無効化する
// #define WF_STRIP_LOG_SCAN_RESULT // シーンスキャン結果をログ出力する
// #define WF_STRIP_LOG_RESULT // Strippingの結果をログ出力する
// #define WF_STRIP_LOG_VERBOSE // Strip中の挙動をログ出力する

using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.Animations;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

namespace UnlitWF
{
#if UNITY_2019_1_OR_NEWER

    public class WF_ShaderPreprocessor : IPreprocessShaders
    {
        private bool initialized = false;
        private List<UsedShaderVariant> usedShaderVariantList;
        private WFEditorSetting settings;

        public int callbackOrder
        {
            get
            {
                ClearUsedShaderVariantList();
                return 100;
            }
        }

        public WF_ShaderPreprocessor()
        {
            ClearUsedShaderVariantList();
        }

        public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
        {
#if !WF_STRIP_DISABLE
            if (IsStripTargetShader(shader))
            {
                // 設定はここで読み込む
                InitUsedShaderVariantList();

                if (settings == null || !settings.enableStripping)
                {
                    // stripping しない
                    return;
                }

                var before = data.Count;
                var strip = 0;
                strip += DoStripForwardBasePass(shader, snippet, data);
                strip += DoStripMetaPass(shader, snippet, data);

#if WF_STRIP_LOG_RESULT
                if (data.Count < before) {
                    Debug.LogFormat("[WF][Preprocess] shader stripping: {0}/{1} at {2}/{3}/{4}", strip, before, shader.name, snippet.passName, snippet.shaderType);
                }
#endif
            }
#endif
        }

        protected int DoStripForwardBasePass(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
        {
            if (snippet.passType != PassType.ForwardBase)
            {
                // ここで stripping するのは ForwardBase だけ
                return 0;
            }

            // 存在するキーワードの配列
            var existingKwds = GetExistingShaderKeywords(shader, data);
            if (existingKwds.Length == 0)
            {
                // feature keyword が無いならば何もしない
                return 0;
            }

            var count = 0;

            for (int i = data.Count - 1; 0 <= i; i--)
            {
                var d = data[i];

                if (ContainsShaderVariant(settings.alwaysIncludeShaders, shader, snippet, d))
                {
#if WF_STRIP_LOG_VERBOSE
                        Debug.LogFormat("[WF][Preprocess] always include: {0}/{1}/{2}/{3} ({4})", 
                            shader.name, 
                            snippet.passName, 
                            snippet.shaderType,
                            d.shaderCompilerPlatform,
                            string.Join(", ", ToKeywordArray(shader, d.shaderKeywordSet)));
#endif
                    continue;
                }

                if (usedShaderVariantList.Any(v => v.IsMatchVariant(shader, existingKwds, d)))
                {
#if WF_STRIP_LOG_VERBOSE
                        Debug.LogFormat("[WF][Preprocess] match variant: {0}/{1}/{2}/{3} ({4})", 
                            shader.name, 
                            snippet.passName, 
                            snippet.shaderType,
                            d.shaderCompilerPlatform,
                            string.Join(", ", ToKeywordArray(shader, d.shaderKeywordSet)));
#endif
                    // 使用しているバリアントならば何もしない
                    continue;
                }
                // 使用してないバリアントは削除
                data.RemoveAt(i);
                count++;
            }

            return count;
        }

        private bool ContainsShaderVariant(ShaderVariantCollection collection, Shader shader, ShaderSnippetData snippet, ShaderCompilerData data)
        {
            if (collection == null)
            {
                return false;
            }
            return collection.Contains(new ShaderVariantCollection.ShaderVariant(shader, snippet.passType, ToKeywordArray(shader, data.shaderKeywordSet)));
        }

        protected int DoStripMetaPass(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
        {
            if (snippet.passType != PassType.Meta)
            {
                // ここで stripping するのは Meta だけ
                return 0;
            }
            if (!settings.stripMetaPass)
            {
                // 設定で Meta パス削減しないときには何もしない
                return 0;
            }

            int count = data.Count;
            data.Clear();
            return count;
        }

        private string[] ToKeywordArray(Shader shader, ShaderKeywordSet keys)
        {
            return keys.GetShaderKeywords().Select(kwd => ShaderKeyword.GetKeywordName(shader, kwd)).ToArray();
        }

        private static bool IsStripTargetShader(Shader shader)
        {
            if (shader == null)
            {
                return false;
            }
            if (!WFCommonUtility.IsSupportedShader(shader))
            {
                return false;
            }
            if (shader.name.Contains("WF_DebugView"))
            {
                return false;
            }
            if (shader.name.Contains("WF_UnToon_Hidden"))
            {
                return false;
            }
            return true;
        }

        private string[] GetExistingShaderKeywords(Shader shader, IList<ShaderCompilerData> data)
        {
            return data.SelectMany(d => d.shaderKeywordSet.GetShaderKeywords())
                .Where(k => ShaderKeyword.IsKeywordLocal(k))
                .Select(k => ShaderKeyword.GetKeywordName(shader, k))
                .Where(kwd => WFCommonUtility.IsEnableKeyword(kwd)).Distinct().ToArray();
        }

        private void ClearUsedShaderVariantList()
        {
            initialized = false;
            usedShaderVariantList = null;
        }

        private void InitUsedShaderVariantList()
        {
            if (initialized)
            {
                // 初期化済みならば何もしない
                return;
            }
            // Assets 内に WF_EditorSetting があるならば読み込み
            settings = WFEditorSetting.GetOneOfSettings();

            var materials = new List<Material>();
            var used = new List<UsedShaderVariant>();

            var sw = new System.Diagnostics.Stopwatch();
            sw.Start();

            // シーンから UsedShaderVariant を回収
            materials.AddRange(MaterialSeeker.GetAllSceneAllMaterial());

            // EditorSettings から UsedShaderVariant を回収
            if (settings.alwaysIncludeMaterials != null)
            {
                materials.AddRange(settings.alwaysIncludeMaterials);
            }
            materials = materials.Distinct()
                .Where(mat => mat != null && IsStripTargetShader(mat.shader))
                .ToList();

            foreach (var mat in materials)
            {
                AppendUsedShaderVariant(used, mat, mat.shader);
            }

            sw.Stop();

            usedShaderVariantList = used.Distinct().ToList();
            initialized = true;

#if WF_STRIP_LOG_SCAN_RESULT
            foreach (var mat in materials) {
                Debug.Log(string.Format("[WF][Preprocess] find materials in scene: {0}", mat), mat);
            }
            foreach (var uv in usedShaderVariantList) {
                Debug.LogFormat("[WF][Preprocess] used variant: {0}", uv);
            }
#endif

            Debug.LogFormat("[WF][Preprocess] fnish scene material scanning: {0} ms, {1} materials, {2} usedShaderVariantList", sw.ElapsedMilliseconds, materials.Count, usedShaderVariantList.Count);
        }

        private void AppendUsedShaderVariant(List<UsedShaderVariant> result, Material mat, Shader shader)
        {
            // マテリアルから _XX_ENABLE となっているキーワードを回収
            IEnumerable<string> keywords = mat.shaderKeywords.Where(kwd => WFCommonUtility.IsEnableKeyword(kwd));

            UsedShaderVariant usv = new UsedShaderVariant(shader.name, keywords);
            if (!result.Contains(usv))
            {
                result.Add(usv);

                // 直接のシェーダではなく、そのフォールバックを利用できるならばそれも追加する
                if (settings == null || !settings.stripFallback)
                {
                    var name = WFCommonUtility.GetShaderFallBackTarget(shader);
                    var fallback = name == null ? null : Shader.Find(name);
                    if (IsStripTargetShader(fallback))
                    {
                        AppendUsedShaderVariant(result, mat, fallback);
                    }
                }
            }
        }

        public class UsedShaderVariant : System.IEquatable<UsedShaderVariant>
        {
            public readonly string shaderName;
            public readonly List<string> keywords;

            public UsedShaderVariant(string shaderName, IEnumerable<string> keywords)
            {
                this.shaderName = shaderName;
                this.keywords = new List<string>(keywords);
                this.keywords.Sort();
            }

            public bool Equals(UsedShaderVariant obj)
            {
                return shaderName == obj.shaderName && keywords.SequenceEqual(obj.keywords);
            }

            public override int GetHashCode()
            {
                return shaderName.GetHashCode();
            }

            public bool IsMatchVariant(Shader shader, IEnumerable<string> existing, ShaderCompilerData data)
            {
                if (shader.name != shaderName)
                {
                    return false;
                }

                foreach (var kwd in existing)
                {
                    if (keywords.Contains(kwd) != data.shaderKeywordSet.IsEnabled(new ShaderKeyword(shader, kwd)))
                    {
                        return false;
                    }
                }
                return true;
            }

            public override string ToString()
            {
                return shaderName + "(" + string.Join(", ", keywords) + ")";
            }
        }
    }

    internal static class MaterialSeeker
    {
        #region マテリアル列挙系

        public static IEnumerable<Material> GetAllSceneAllMaterial(List<Material> result = null)
        {
            InitList(ref result);
            for (int i = 0; i < EditorSceneManager.sceneCount; i++)
            {
                GetAllMaterials(EditorSceneManager.GetSceneAt(i), result);
            }

            return result;
        }

        public static IEnumerable<Material> GetAllMaterials(Scene scene, List<Material> result = null)
        {
            InitList(ref result);
            if (scene == null)
            {
                return result;
            }
            foreach (var go in scene.GetRootGameObjects())
            {
                GetAllMaterials(go, result);
            }
            return result;
        }

        public static IEnumerable<Material> GetAllMaterials(GameObject go, List<Material> result = null)
        {
            InitList(ref result);
            if (go == null)
            {
                return result;
            }

            // Renderer -> Material
            foreach (var renderer in go.GetComponentsInChildren<Renderer>(true))
            {
                GetAllMaterials(renderer, result);
            }

            // Animator -> Controller -> AnimationClip -> Material
            foreach (var animator in go.GetComponentsInChildren<Animator>(true))
            {
                GetAllMaterials(animator.runtimeAnimatorController, result);
            }

#if VRC_SDK_VRCSDK3 && !UDON
            // SDK2では無効、SDK3Worlds でも無効、SDK3Avatars でだけ有効になるよう細工

            // VRCAvatarDescriptor -> Controller -> AnimationClip -> Material
            foreach (var desc in go.GetComponentsInChildren<VRC.SDK3.Avatars.Components.VRCAvatarDescriptor>(true))
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
#endif

            return result;
        }


        public static IEnumerable<Material> GetAllMaterials(Renderer renderer, List<Material> result = null)
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

        public static IEnumerable<Material> GetAllMaterials(RuntimeAnimatorController controller, List<Material> result = null)
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

        public static IEnumerable<Material> GetAllMaterials(AnimatorController controller, List<Material> result = null)
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
        public static IEnumerable<AnimatorState> GetAllState(AnimatorControllerLayer layer)
        {
            return GetAllState(layer?.stateMachine);
        }

        /// <summary>
        /// AnimatorStateMachine 内の全ての AnimatorState を列挙する。
        /// </summary>
        /// <param name="stateMachine"></param>
        /// <returns></returns>
        public static IEnumerable<AnimatorState> GetAllState(AnimatorStateMachine stateMachine)
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
        public static IEnumerable<AnimationClip> GetAllAnimationClip(AnimatorController animator)
        {
            return animator.layers.SelectMany(ly => GetAllAnimationClip(ly)).Distinct();
        }

        /// <summary>
        /// AnimatorControllerLayer 内の全ての AnimationClip を列挙する。
        /// </summary>
        /// <param name="layer"></param>
        /// <returns></returns>
        public static IEnumerable<AnimationClip> GetAllAnimationClip(AnimatorControllerLayer layer)
        {
            return GetAllState(layer).SelectMany(state => GetAllAnimationClip(state.motion)).Distinct();
        }

        private static IEnumerable<AnimationClip> GetAllAnimationClip(Motion motion, List<AnimationClip> result = null)
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

#endif
}
