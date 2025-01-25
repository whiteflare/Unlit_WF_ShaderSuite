/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2025 whiteflare.
 *
 *  This software is provided ‘as-is’, without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
 */

// #define WF_STRIP_DISABLE // Strippingそのものを無効化する
// #define WF_STRIP_LOG_SCAN_RESULT // シーンスキャン結果をログ出力する
// #define WF_STRIP_LOG_RESULT // Strippingの結果をログ出力する
// #define WF_STRIP_LOG_VERBOSE // Strip中の挙動をログ出力する

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
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

namespace UnlitWF
{
#if UNITY_2019_1_OR_NEWER

    class WF_ShaderPreprocessor : IPreprocessShaders
    {
#if ENV_VRCSDK3_AVATAR
        public class WF_PreprocessorForVRCSDK3Avatar : VRC.SDKBase.Editor.BuildPipeline.IVRCSDKPreprocessAvatarCallback
        {
            public int callbackOrder => 100;

            public bool OnPreprocessAvatar(GameObject avatarGameObject)
            {
                // VRCSDK3 Avatars からビルドリクエストされた場合は先にクリンナップ処理を動かす。
                CleanupMaterialsBeforeAvatarBuild(avatarGameObject);

                // avatarGameObject からマテリアルを回収
                Core.InitUsedShaderVariantListForVRCSDK3Avatar(avatarGameObject);

                return true;
            }

            private void CleanupMaterialsBeforeAvatarBuild(GameObject avatarGameObject)
            {
                var cleanupMaterials = new List<Material>();
                var setupMaterials = new List<Material>();
                foreach (var mat in new MaterialSeeker().GetAllMaterials(avatarGameObject).Distinct())
                {
                    if (WFEditorSetting.GetOneOfSettings().cleanupMaterialsBeforeAvatarBuild && !Converter.WFMaterialMigrationConverter.ExistsNeedsMigration(mat))
                    {
                        cleanupMaterials.Add(mat);
                    }
                    else
                    {
                        setupMaterials.Add(mat);
                    }
                }
                if (0 < cleanupMaterials.Count)
                {
                    var param = CleanUpParameter.Create();
                    param.materials = cleanupMaterials.ToArray();
                    param.execNonWFMaterials = false; // ビルド時は NonWF マテリアルのクリンナップを行わない
                    if (WFMaterialEditUtility.CleanUpProperties(param))
                    {
                        AssetDatabase.SaveAssets(); // 未保存のマテリアルを保存
                    }
                }
                if (0 < setupMaterials.Count)
                {
                    if (WFCommonUtility.SetupMaterials(setupMaterials.ToArray()))
                    {
                        AssetDatabase.SaveAssets(); // 未保存のマテリアルを保存
                    }
                }
            }
        }
#elif ENV_VRCSDK3_WORLD
        internal class WF_PreprocessorForVRCSDK3World : IProcessSceneWithReport
        {
            public int callbackOrder => 100;

            public void OnProcessScene(Scene scene, UnityEditor.Build.Reporting.BuildReport report)
            {
                // マテリアルのセットアップ
                CleanupMaterialsBeforeWorldBuild();

                // avatarGameObject からマテリアルを回収
                Core.InitUsedShaderVariantListForVRCSDK3World(scene);
            }

            private static void CleanupMaterialsBeforeWorldBuild()
            {
                var mats = new MaterialSeeker().GetAllMaterialsInScene().Distinct();
                if (WFCommonUtility.SetupMaterials(mats.ToArray()))
                {
                    AssetDatabase.SaveAssets(); // 未保存のマテリアルを保存
                }
            }
        }
#else
        internal class WF_PreprocessorForOther : IPreprocessShaders
        {
            public int callbackOrder => 100;

            public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
            {
                Core.ClearUsedShaderVariantListIfOtherPlatform(); // 他プラットフォームの場合はここでクリアする
            }
        }
#endif

        private static readonly Singleton Core = new Singleton();
        private readonly WFEditorSetting settings = WFEditorSetting.GetOneOfSettings();

        internal enum WFBuildPlatformType
        {
            VRCSDK3_Avatar,
            VRCSDK3_World,
            OtherEnvs,
        }

        public int callbackOrder => 101;

        public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
        {
#if !WF_STRIP_DISABLE
            if (IsStripTargetShader(shader))
            {
                // 設定はここで読み込む
                Core.InitUsedShaderVariantListForOtherPlatform();

                if (settings == null || !settings.enableStripping)
                {
                    // stripping しない
                    return;
                }

                var usedShaderVariantList = Core.GetList();

                var before = data.Count;
                var strip = 0;
                strip += DoStripForwardBasePass(shader, snippet, data, usedShaderVariantList);
                strip += DoStripShadowCasterPass(shader, snippet, data);
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
            if (snippet.passType != PassType.ForwardBase && snippet.passName != "CLR_BG")
            {
                // ここで stripping するのは ForwardBase だけ
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

            // _WF_EDITOR_HIDE_LMAP を除外する
            {
                var kwd_WF_EDITOR_HIDE_LMAP = new ShaderKeyword(shader, WFCommonUtility.KWD_EDITOR_HIDE_LMAP);
                for (int i = data.Count - 1; 0 <= i; i--)
                {
                    var d = data[i];
                    if (d.shaderKeywordSet.IsEnabled(kwd_WF_EDITOR_HIDE_LMAP))
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

        protected int DoStripShadowCasterPass(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
        {
            if (snippet.passType != PassType.ShadowCaster)
            {
                // ここで stripping するのは ShadowCaster だけ
                return 0;
            }
            if (!settings.stripUnusedVariant)
            {
                // 設定で無効化されているならば stripping しない
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

            // _WF_EDITOR_HIDE_LMAP を除外する
            {
                var kwd_WF_EDITOR_HIDE_LMAP = new ShaderKeyword(shader, WFCommonUtility.KWD_EDITOR_HIDE_LMAP);
                for (int i = data.Count - 1; 0 <= i; i--)
                {
                    var d = data[i];
                    if (d.shaderKeywordSet.IsEnabled(kwd_WF_EDITOR_HIDE_LMAP))
                    {
                        data.RemoveAt(i);
                        count++;
                        continue;
                    }
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
#if UNITY_2021_2_OR_NEWER
                .Select(k => k.name)
#else
                .Select(k => ShaderKeyword.GetKeywordName(shader, k))
#endif
                .Where(kwd => WFCommonUtility.IsEnableKeyword(kwd)).Distinct().ToArray();
        }

        internal class Singleton
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

            public void InitUsedShaderVariantListForVRCSDK3Avatar(GameObject avatar)
            {
                InitUsedShaderVariantList(WFBuildPlatformType.VRCSDK3_Avatar, avatar, null);
            }

            public void InitUsedShaderVariantListForVRCSDK3World(Scene scene)
            {
                InitUsedShaderVariantList(WFBuildPlatformType.VRCSDK3_World, null, scene);
            }

            public void InitUsedShaderVariantListForOtherPlatform()
            {
                InitUsedShaderVariantList(null, null, null);
            }

            private void InitUsedShaderVariantList(WFBuildPlatformType? currentPlatform, GameObject rootObject, Scene? scene)
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
                    usedShaderVariantList = new UsedShaderVariantSeeker().CreateUsedShaderVariantList(out materialCount, rootObject, scene);
                    // その他の変数も一緒に初期化
                    existLodGroupInScene = rootObject == null && ExistsLodGroupInScene(scene);
#if WF_STRIP_LOG_SCAN_RESULT
                    Debug.LogFormat("[WF][Preprocess] InitUsedShaderVariantList, this = {0}, currentPlatform = {1}", base.GetHashCode(), this.currentPlatform);
#endif
                }
            }

            private bool ExistsLodGroupInScene(Scene? scene)
            {
                if (scene != null)
                {
                    return ExistsLodGroupInScene((Scene)scene);
                }
                else
                {
                    for (int i = 0; i < SceneManager.sceneCount; i++)
                    {
                        if (ExistsLodGroupInScene(SceneManager.GetSceneAt(i)))
                        {
                            return true;
                        }
                    }
                }
                return false;
            }

            private bool ExistsLodGroupInScene(Scene scene)
            {
                if (scene != null && scene.isLoaded)
                {
                    if (scene.GetRootGameObjects().SelectMany(rt => rt.GetComponentsInChildren<LODGroup>(true)).Any(lod => lod != null))
                    {
                        return true;
                    }
                }
                return false;
            }
        }

        internal class UsedShaderVariantSeeker
        {
            private WFEditorSetting settings = WFEditorSetting.GetOneOfSettings(); // Assets 内に WF_EditorSetting があるならば読み込み
            private List<UsedShaderVariant> usedShaderVariantList = new List<UsedShaderVariant>();

            public List<UsedShaderVariant> CreateUsedShaderVariantList(out int materialCount, GameObject rootObject = null, Scene? scene = null)
            {
                var materials = new List<Material>();

                var sw = new System.Diagnostics.Stopwatch();
                sw.Start();

                // シーンから UsedShaderVariant を回収
                var materialSeeker = new MaterialSeeker();
                if (rootObject != null)
                {
                    materials.AddRange(materialSeeker.GetAllMaterials(rootObject));
                }
                else if (scene != null)
                {
                    materials.AddRange(materialSeeker.GetAllMaterials((Scene)scene));
                }
                else
                {
                    materials.AddRange(materialSeeker.GetAllMaterialsInScene());
                }
                materials = materials.Distinct()
                    .Where(mat => mat != null && IsStripTargetShader(mat.shader))
                    .ToList();
                materialCount = materials.Count;

                // 使っているバリアントを記録
                AppendUsedShaderVariant(materials);
                // ついでにシーンにあるマテリアルの検査もこのタイミングで行う。検査するだけで特に動作に影響しない。
                if (settings.validateSceneMaterials)
                {
                    ValidateMaterials(materials);
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

                Debug.LogFormat("[WF][Preprocess] finish material scan from {3}: {0} ms, {1} materials, {2} usedShaderVariantList",
                    sw.ElapsedMilliseconds, materialCount, result.Count,
                    rootObject != null ? "Avatar[" + rootObject.name + "]" : scene != null ? "Scene[" + ((Scene)scene).name + "]" : "All Scene");

                return result;
            }

            private void AppendUsedShaderVariant(IEnumerable<Material> mats)
            {
                foreach (var mat in mats)
                {
                    AppendUsedShaderVariant(mat, mat.shader);
                }
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
                        var name = WFAccessor.GetShaderFallBackTarget(shader);
                        var fallback = WFCommonUtility.FindShader(name);
                        if (IsStripTargetShader(fallback))
                        {
                            AppendUsedShaderVariant(mat, fallback);
                        }
                    }
                }
            }

            private void ValidateMaterials(IEnumerable<Material> mats)
            {
                foreach (var mat in mats)
                {
                    ValidateMaterials(mat);
                }
            }

            private void ValidateMaterials(Material mat)
            {
                if (WFCommonUtility.IsMigrationRequiredMaterial(mat))
                {
                    Debug.LogWarningFormat(mat, "[WF][Preprocess] {0}, mat = {1}", WFI18N.Translate(WFMessageText.LgWarnOlderVersion), mat);
                }
                if (WFCommonUtility.IsMobilePlatform() && !WFCommonUtility.IsMobileSupportedShader(mat))
                {
                    Debug.LogWarningFormat(mat, "[WF][Preprocess] {0}, mat = {1}", WFI18N.Translate(WFMessageText.LgWarnNotSupportAndroid), mat);
                }
            }
        }

        internal class UsedShaderVariant : System.IEquatable<UsedShaderVariant>
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
