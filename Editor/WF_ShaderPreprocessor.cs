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

// #define WF_STRIP_DISABLE // Strippingそのものを無効化する
// #define WF_STRIP_LOG_SCAN_RESULT // シーンスキャン結果をログ出力する
// #define WF_STRIP_LOG_RESULT // Strippingの結果をログ出力する
// #define WF_STRIP_LOG_VERBOSE // Strip中の挙動をログ出力する

#if VRC_SDK_VRCSDK3
#define ENV_VRCSDK3
#if UDON
#define ENV_VRCSDK3_WORLD
#else
#define ENV_VRCSDK3_AVATAR
#endif
#endif

using System.Collections.Generic;
using System.Linq;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnlitWF
{
#if UNITY_2019_1_OR_NEWER

    public class WF_ShaderPreprocessor : IPreprocessShaders
#if ENV_VRCSDK3
        , VRC.SDKBase.Editor.BuildPipeline.IVRCSDKBuildRequestedCallback
#endif
    {
        private static readonly Singleton Core = new Singleton();

        public int callbackOrder
        {
            get
            {
                Core.ClearUsedShaderVariantListIfOtherPlatform(); // 他プラットフォームの場合はここでクリアする
                return 100;
            }
        }

        public enum WFBuildPlatformType
        {
            VRCSDK3_Avatar,
            VRCSDK3_World,
            OtherEnvs,
        }

#if ENV_VRCSDK3
        bool VRC.SDKBase.Editor.BuildPipeline.IVRCSDKBuildRequestedCallback.OnBuildRequested(VRC.SDKBase.Editor.BuildPipeline.VRCSDKRequestedBuildType requestedBuildType)
        {
            // VRCSDK3 からビルドリクエストされた場合はここでクリア＆初期化する
            switch (requestedBuildType)
            {
                case VRC.SDKBase.Editor.BuildPipeline.VRCSDKRequestedBuildType.Avatar:
                    Core.InitUsedShaderVariantList(WFBuildPlatformType.VRCSDK3_Avatar);
                    break;
                case VRC.SDKBase.Editor.BuildPipeline.VRCSDKRequestedBuildType.Scene:
                    Core.InitUsedShaderVariantList(WFBuildPlatformType.VRCSDK3_World);
                    break;
            }
            return true;
        }
#endif

        private readonly WFEditorSetting settings = WFEditorSetting.GetOneOfSettings();

        public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
        {
#if !WF_STRIP_DISABLE
            if (IsStripTargetShader(shader))
            {
                // 設定はここで読み込む
                Core.InitUsedShaderVariantList();

                if (settings == null || !settings.enableStripping)
                {
                    // stripping しない
                    return;
                }

                var usedShaderVariantList = Core.GetList();

                var before = data.Count;
                var strip = 0;
                strip += DoStripForwardBasePass(shader, snippet, data, usedShaderVariantList);
                strip += DoStripMetaPass(shader, snippet, data);

#if WF_STRIP_LOG_RESULT
                if (data.Count < before)
                {
                    Debug.LogFormat("[WF][Preprocess] shader stripping: {0}/{1} at {2}/{3}/{4}", strip, before, shader.name, snippet.passName, snippet.shaderType);
                }
#endif
            }
#endif
        }

        protected int DoStripForwardBasePass(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data, List<UsedShaderVariant> usedShaderVariantList)
        {
            if (snippet.passType != PassType.ForwardBase && snippet.passType != PassType.ShadowCaster)
            {
                // ここで stripping するのは ForwardBase と ShadowCaster だけ
                return 0;
            }
            if (!settings.stripUnusedVariant)
            {
                // 設定で無効化されているならば stripping しない
                return 0;
            }
            if (Core.MaterialCount == 0)
            {
                // 対応シェーダのOnProcessShaderが呼ばれているのにシーンにマテリアルが見つからないのはシーンの検索に失敗しているということなので
                // 警告を出力して stripping はしない
                Debug.LogWarning("[WF][Preprocess] Disable Stripping because there was no material in the scene.");
                return 0;
            }

            var count = 0;

            // LOD_FADE_CROSSFADE を除外する
            if (CanStripLodFade())
            {
                var kwd_LOD_FADE_CROSSFADE = new ShaderKeyword(shader, "LOD_FADE_CROSSFADE");
                for (int i = data.Count - 1; 0 <= i; i--)
                {
                    var d = data[i];
                    if (d.shaderKeywordSet.IsEnabled(kwd_LOD_FADE_CROSSFADE))
                    {
                        data.RemoveAt(i);
                        count++;
                        continue;
                    }
                }
            }

            // 使用していない Enable キーワードの組み合わせを除外する
            var existingKwds = GetExistingShaderKeywords(shader, data);
            if (existingKwds.Length != 0)
            {
                for (int i = data.Count - 1; 0 <= i; i--)
                {
                    var d = data[i];

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
            }

            return count;
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

        private bool CanStripLodFade()
        {
            if (settings.stripUnusedLodFade) // 設定で LodCrossFade の strip が有効のときに
            {
                if (Core.CurrentPlatform == WFBuildPlatformType.VRCSDK3_Avatar)
                {
                    return true; // VRCSDK3_Avatar からキックされたならば LODGroup は使っていないので削除できる
                }
                if (!Core.ExistLodGroupInScene)
                {
                    return true; // シーン内に LODGroup が無いならば削除できる
                }
            }
            return false; // それ以外では削除しない
        }

#if WF_STRIP_LOG_VERBOSE
        private string[] ToKeywordArray(Shader shader, ShaderKeywordSet keys)
        {
            return keys.GetShaderKeywords().Select(kwd => ShaderKeyword.GetKeywordName(shader, kwd)).ToArray();
        }
#endif

        private string[] GetExistingShaderKeywords(Shader shader, IList<ShaderCompilerData> data)
        {
            return data.SelectMany(d => d.shaderKeywordSet.GetShaderKeywords())
                .Where(k => ShaderKeyword.IsKeywordLocal(k))
                .Select(k => ShaderKeyword.GetKeywordName(shader, k))
                .Where(kwd => WFCommonUtility.IsEnableKeyword(kwd)).Distinct().ToArray();
        }

        public class Singleton
        {
            private readonly object lockToken = new object();

            private List<UsedShaderVariant> usedShaderVariantList = null;
            private bool existLodGroupInScene = false;
            private WFBuildPlatformType currentPlatform = WFBuildPlatformType.OtherEnvs;
            private int materialCount = 0;

            public int MaterialCount => materialCount;

            public WFBuildPlatformType CurrentPlatform
            {
                get => currentPlatform;
            }

            public bool ExistLodGroupInScene
            {
                get => existLodGroupInScene;
            }

            public List<UsedShaderVariant> GetList()
            {
                lock (lockToken)
                {
                    var list = new List<UsedShaderVariant>();
                    if (usedShaderVariantList != null)
                    {
                        list.AddRange(usedShaderVariantList);
                    }
                    return list;
                }
            }

            public void ClearUsedShaderVariantList()
            {
                lock (lockToken)
                {
                    usedShaderVariantList = null;
                    existLodGroupInScene = false;
                    materialCount = 0;
#if WF_STRIP_LOG_SCAN_RESULT
                    Debug.LogFormat("[WF][Preprocess] ClearUsedShaderVariantList, this = {0}, currentPlatform = {1}", GetHashCode(), currentPlatform);
#endif
                }
            }

            public void ClearUsedShaderVariantListIfOtherPlatform()
            {
                lock (lockToken)
                {
                    if (currentPlatform == WFBuildPlatformType.OtherEnvs)
                    {
                        ClearUsedShaderVariantList();
                    }
                }
            }

            public void InitUsedShaderVariantList(WFBuildPlatformType? currentPlatform = null)
            {
                lock (lockToken)
                {
                    // プラットフォーム指定されたときは設定してリセット
                    if (currentPlatform != null)
                    {
                        this.currentPlatform = (WFBuildPlatformType)currentPlatform;
                        ClearUsedShaderVariantList();
                    }
                    // 初期化済みならば何もしない
                    if (usedShaderVariantList != null)
                    {
                        return;
                    }

                    // 作成する
                    usedShaderVariantList = new UsedShaderVariantSeeker().CreateUsedShaderVariantList(out materialCount);
                    // その他の変数も一緒に初期化
                    existLodGroupInScene = ExistsLodGroupInScene();
#if WF_STRIP_LOG_SCAN_RESULT
                    Debug.LogFormat("[WF][Preprocess] InitUsedShaderVariantList, this = {0}, currentPlatform = {1}", base.GetHashCode(), this.currentPlatform);
#endif
                }
            }

            private bool ExistsLodGroupInScene()
            {
                for (int i = 0; i < UnityEditor.SceneManagement.EditorSceneManager.sceneCount; i++)
                {
                    var scene = UnityEditor.SceneManagement.EditorSceneManager.GetSceneAt(i);
                    if (scene.GetRootGameObjects().SelectMany(rt => rt.GetComponentsInChildren<LODGroup>(true)).Any(lod => lod != null))
                    {
                        return true;
                    }
                }
                return false;
            }
        }

        public class UsedShaderVariantSeeker
        {
            private WFEditorSetting settings = WFEditorSetting.GetOneOfSettings(); // Assets 内に WF_EditorSetting があるならば読み込み
            private List<UsedShaderVariant> usedShaderVariantList = new List<UsedShaderVariant>();

            public List<UsedShaderVariant> CreateUsedShaderVariantList(out int materialCount)
            {
                var materials = new List<Material>();

                var sw = new System.Diagnostics.Stopwatch();
                sw.Start();

                // シーンから UsedShaderVariant を回収
                var materialSeeker = new MaterialSeeker();
#if ENV_VRCSDK3_AVATAR
                if (Core.CurrentPlatform == WFBuildPlatformType.VRCSDK3_Avatar)
                {
                    // もしSDK3Avatarからのリクエストならば、非アクティブのAvatarDescriptorを親に持つGameObjectは無視するようにする
                    materialSeeker.FilterHierarchy = cmp =>
                        !(cmp.GetComponentsInParent<VRC.SDK3.Avatars.Components.VRCAvatarDescriptor>(true).Any(d => !d.isActiveAndEnabled));
                }
#endif
                materials.AddRange(materialSeeker.GetAllSceneAllMaterial());
                materials = materials.Distinct()
                    .Where(mat => mat != null && IsStripTargetShader(mat.shader))
                    .ToList();
                materialCount = materials.Count;

                foreach (var mat in materials)
                {
                    AppendUsedShaderVariant(mat, mat.shader);
                }

                sw.Stop();

                var result = usedShaderVariantList.Distinct().ToList();

#if WF_STRIP_LOG_SCAN_RESULT
                foreach (var mat in materials)
                {
                    Debug.Log(string.Format("[WF][Preprocess] find materials in scene: {0}", mat), mat);
                }
                foreach (var uv in result)
                {
                    Debug.LogFormat("[WF][Preprocess] used variant: {0}", uv);
                }
#endif

                Debug.LogFormat("[WF][Preprocess] fnish scene material scanning: {0} ms, {1} materials, {2} usedShaderVariantList", sw.ElapsedMilliseconds, materialCount, result.Count);
                return result;
            }

            private void AppendUsedShaderVariant(Material mat, Shader shader)
            {
                // マテリアルから _XX_ENABLE となっているキーワードを回収
                IEnumerable<string> keywords = mat.shaderKeywords.Where(kwd => WFCommonUtility.IsEnableKeyword(kwd));

                UsedShaderVariant usv = new UsedShaderVariant(shader.name, keywords);
                if (!usedShaderVariantList.Contains(usv))
                {
                    usedShaderVariantList.Add(usv);

                    // 直接のシェーダではなく、そのフォールバックを利用できるならばそれも追加する
                    if (settings == null || !settings.stripFallback)
                    {
                        var name = WFCommonUtility.GetShaderFallBackTarget(shader);
                        var fallback = name == null ? null : Shader.Find(name);
                        if (IsStripTargetShader(fallback))
                        {
                            AppendUsedShaderVariant(mat, fallback);
                        }
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

#endif
}
