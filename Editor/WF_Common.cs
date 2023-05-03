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

#define _WF_LEGACY_FEATURE_SWITCH
// #define WF_COMMON_LOG_KEYWORD // キーワード変更時のログを出力する

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine;

namespace UnlitWF
{
    static class WFCommonUtility
    {
        /// <summary>
        /// DisplayDialogのタイトル文字列。汎用的に使うもの。
        /// </summary>
        public static readonly string DialogTitle = "UnlitWF Shader";

        #region プロパティ判定

        /// <summary>
        /// GUIに表示されるDisplayNameのパターン
        /// </summary>
        private static readonly Regex PAT_DISP_NAME = new Regex(@"^\[(?<label>[A-Z][A-Z0-9]*)\]\s+(?<name>.+)$", RegexOptions.Compiled);
        /// <summary>
        /// マテリアルに保存されるプロパティ名のパターン
        /// </summary>
        private static readonly Regex PAT_PROP_NAME = new Regex(@"^_(?<prefix>[A-Z][A-Z0-9]*)_(?<name>.+?)(?<suffix>(?:_\d+)?)$", RegexOptions.Compiled);
        /// <summary>
        /// ENABLEキーワードのパターン
        /// </summary>
        private static readonly Regex PAT_ENABLE_KEYWORD = new Regex(@"^_(?<prefix>[A-Z][A-Z0-9]*)_((?<func>[A-Z0-9]+)_)?ENABLE(?<suffix>(?:_\d+)?)$", RegexOptions.Compiled);

        /// <summary>
        /// プロパティのディスプレイ名から、Prefixと名前を分割する。
        /// </summary>
        /// <param name="text">ディスプレイ名</param>
        /// <param name="label">Prefix</param>
        /// <param name="name">名前</param>
        /// <param name="dispName">ディスプレイ文字列</param>
        /// <returns></returns>
        public static bool FormatDispName(string text, out string label, out string name, out string dispName)
        {
            var mm = PAT_DISP_NAME.Match(text ?? "");
            if (mm.Success)
            {
                label = mm.Groups["label"].Value.ToUpper();
                name = mm.Groups["name"].Value;
                dispName = "[" + label + "] " + name;
                return true;
            }
            else
            {
                label = null;
                name = text;
                dispName = text;
                return false;
            }
        }

        /// <summary>
        /// プロパティ名の文字列から、Prefix+Suffixと名前を分割する。
        /// </summary>
        /// <param name="text">プロパティ名</param>
        /// <param name="label">Prefix+Suffix</param>
        /// <param name="name">名前</param>
        /// <returns></returns>
        public static bool FormatPropName(string text, out string label, out string name)
        {
            var mm = PAT_PROP_NAME.Match(text ?? "");
            if (mm.Success)
            {
                label = mm.Groups["prefix"].Value.ToUpper() + mm.Groups["suffix"].Value.ToUpper();
                name = mm.Groups["name"].Value;
                return true;
            }
            else
            {
                label = null;
                name = text;
                return false;
            }
        }

        /// <summary>
        /// プロパティ物理名からラベル文字列を抽出する。特殊な名称は辞書を参照してラベル文字列を返却する。
        /// </summary>
        /// <param name="prop_name"></param>
        /// <returns></returns>
        public static string GetPrefixFromPropName(string prop_name)
        {
            string label = WFShaderDictionary.SpecialPropNameToLabelMap.GetValueOrNull(prop_name);
            if (label != null)
            {
                return label;
            }
            string name;
            FormatPropName(prop_name, out label, out name);
            return label;
        }

        /// <summary>
        /// プロパティ物理名から Enable トグルかどうかを判定する。
        /// </summary>
        /// <param name="prop_name"></param>
        /// <returns></returns>
        public static bool IsEnableToggleFromPropName(string prop_name)
        {
            string label, name;
            FormatPropName(prop_name, out label, out name);
            return IsEnableToggle(label, name);
        }

        /// <summary>
        /// キーワード文字列が Enable キーワードかどうかを判定する。
        /// </summary>
        /// <param name="keyword"></param>
        /// <returns></returns>
        public static bool IsEnableKeyword(string keyword)
        {
            return PAT_ENABLE_KEYWORD.IsMatch(keyword);
        }

        /// <summary>
        /// ラベル＋プロパティ名から Enable トグルかどうかを判定する。
        /// </summary>
        /// <param name="label"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static bool IsEnableToggle(string label, string name)
        {
            return label != null && name.ToLower() == "enable";
        }

        public static bool IsPropertyTrue(Material mat, string prop_name)
        {
            return IsPropertyTrue(mat.GetFloat(prop_name));
        }

        public static bool IsPropertyTrue(float value)
        {
            return 0.001f < Math.Abs(value);
        }

        #endregion

        #region シェーダキーワード整理

        /// <summary>
        /// 見つけ次第削除するシェーダキーワード
        /// </summary>
        private static readonly List<string> DELETE_KEYWORD = new List<string>() {
            "_",
            "_ALPHATEST_ON",
            "_ALPHABLEND_ON",
            "_ALPHAPREMULTIPLY_ON",
        };

        /// <summary>
        /// 各マテリアルのEnableキーワードを設定する
        /// </summary>
        /// <param name="mats"></param>
        public static void SetupShaderKeyword(params Material[] mats)
        {
            // 不要なシェーダキーワードは削除
            foreach (var mat in mats)
            {
                if (!IsSupportedShader(mat))
                {
                    continue;
                }
                foreach (var key in DELETE_KEYWORD)
                {
                    if (mat.IsKeywordEnabled(key))
                    {
                        mat.DisableKeyword(key);
                    }
                }
            }
            // Enableキーワードを整理する
            foreach (var mat in mats)
            {
                if (!IsSupportedShader(mat))
                {
                    continue;
                }
                bool changed = false;
                foreach (var prop_name in WFAccessor.GetAllPropertyNames(mat.shader))
                {
                    // 対応するキーワードが指定されているならばそれを設定する
                    var kwd = WFShaderDictionary.SpecialPropNameToKeywordMap.GetValueOrNull(prop_name);
                    if (kwd != null)
                    {
                        changed |= kwd.SetKeywordTo(mat);
                        continue;
                    }

                    // Enableプロパティならば、それに対応するキーワードを設定する
                    if (IsEnableToggleFromPropName(prop_name))
                    {
                        changed |= new WFCustomKeywordSettingBool(prop_name, prop_name.ToUpper()).SetKeywordTo(mat);
                        continue;
                    }
                }
                if (changed)
                {
#if WF_COMMON_LOG_KEYWORD
                    Debug.LogFormat("[WF] {0} has {1} keywords {2}", mat, mat.shaderKeywords.Length, string.Join(" ", mat.shaderKeywords.OrderBy(k => k)));
#endif
                }
                // _ES_ENABLE に連動して MaterialGlobalIlluminationFlags を設定する
                if (mat.HasProperty("_ES_Enable"))
                {
                    var flag = mat.GetInt("_ES_Enable") != 0 ? MaterialGlobalIlluminationFlags.BakedEmissive : MaterialGlobalIlluminationFlags.None;
                    if (mat.globalIlluminationFlags != flag)
                    {
                        mat.globalIlluminationFlags = flag;
                    }
                }
            }
        }

        #endregion

        #region シェーダ切り替え

        /// <summary>
        /// マテリアルの shader を指定の名前のものに変更する。
        /// </summary>
        /// <param name="name"></param>
        /// <param name="mats"></param>
        public static void ChangeShader(string name, params Material[] mats)
        {
            if (string.IsNullOrWhiteSpace(name) || mats.Length == 0)
            {
                return; // なにもしない
            }
            var newShader = FindShader(name);
            if (newShader != null)
            {
                Undo.RecordObjects(mats, "change shader");
                foreach (var m in mats)
                {
                    if (m == null)
                    {
                        continue;
                    }
                    var oldM = new Material(m);

                    // 初期化処理の呼び出し (カスタムエディタを取得してAssignNewShaderToMaterialしたかったけど手が届かなかったので静的アクセス)
                    if (WF_DebugViewEditor.IsSupportedShader(newShader))
                    {
                        WF_DebugViewEditor.PreChangeShader(m, oldM.shader, newShader);
                    }
                    else if (ShaderCustomEditor.IsSupportedShader(newShader))
                    {
                        ShaderCustomEditor.PreChangeShader(m, oldM.shader, newShader);
                    }
                    // マテリアルにシェーダ割り当て
                    m.shader = newShader;
                    // 初期化処理の呼び出し (カスタムエディタを取得してAssignNewShaderToMaterialしたかったけど手が届かなかったので静的アクセス)
                    if (WF_DebugViewEditor.IsSupportedShader(newShader))
                    {
                        WF_DebugViewEditor.PostChangeShader(oldM, m, oldM.shader, newShader);
                    }
                    else if (ShaderCustomEditor.IsSupportedShader(newShader))
                    {
                        ShaderCustomEditor.PostChangeShader(oldM, m, oldM.shader, newShader);
                    }
                }
            }
            else
            {
                Debug.LogErrorFormat("[WF][Common] Shader Not Found in this projects: {0}", name);
            }
        }

        /// <summary>
        /// 指定名称の Shader を検索して返す。
        /// もし名称が UnlitWF/ で始まる場合、アセットパスを元に並び替えて先頭の Shader を返却する。
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public static Shader FindShader(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return null;
            }
            if (!name.StartsWith("UnlitWF/"))
            {
                // もしシェーダ名が UnlitWF/ で始まらないならばサポート外シェーダへの切り替えなので通常の Shader.Find を使う
                // IsSupportedShader はここでは使わない (Custom/UnlitWF/ のように ShaderCustomEditor を使う独自シェーダはこちらに倒す)
                return Shader.Find(name);
            }

            // 全シェーダをロードしてしまうとAssetDatabase.FindAssetsでも高速に切り替えられるのでGetAllShaderInfoは使用しない
            //var cnt = ShaderUtil.GetAllShaderInfo().Count(si => si.name == name);
            //if (cnt <= 1)
            //{
            //    // もし同一名称の Shader が複数存在しないのであれば、通常の Shader.Find を使う
            //    return Shader.Find(name);
            //}

            // 同一名称の Shader からひとつを選択する
            var shaders = AssetDatabase.FindAssets("t:Shader")
                // パスを取得
                .Select(guid => AssetDatabase.GUIDToAssetPath(guid)).Where(path => !string.IsNullOrWhiteSpace(path))
                // シェーダをロード
                .Select(path => new ShaderAndAssetPath(path, AssetDatabase.LoadAssetAtPath<Shader>(path))).Where(sp => sp.shader != null)
                // 名称の一致するシェーダのみリストアップする
                .Where(sp => sp.shader.name == name)
                // 優先度順に並び替える
                .OrderBy(sp => sp).ToArray();
            if (shaders.Length == 0)
            {
                return null;
            }
            if (2 <= shaders.Length)
            {
                string msg = "[WF][Common] Multiple Shaders hit: name = " + name;
                foreach(var sh in shaders)
                {
                    msg += "\n  " + sh.path;
                }
                Debug.LogWarning(msg);
            }

            return shaders[0].shader;
        }

        private class ShaderAndAssetPath : IComparable<ShaderAndAssetPath>
        {
            public readonly string path;
            public readonly Shader shader;

            private readonly bool isMatch;
            private readonly int root; // 0:Packages, 1:Assets
            private readonly string parent;
            private readonly string folder;
            private readonly string tail;

            public ShaderAndAssetPath(string path, Shader shader)
            {
                this.path = path;
                this.shader = shader;
                this.root = path.StartsWith("Packages/") ? 0 : 1;

                var mm = pattern.Match(path);
                this.isMatch = mm.Success;
                if (isMatch)
                {
                    this.parent = mm.Groups["parent"].Value;
                    this.folder = mm.Groups["folder"].Value;
                    this.tail = mm.Groups["tail"].Value;
                }
                else
                {
                    this.parent = "";
                    this.folder = "";
                    this.tail = path;
                }
            }

            private static readonly Regex pattern = new Regex(@"^(?<root>(?:Packages|Assets)(?<parent>/[^/]+)*)/(?<folder>Unlit_?WF_?Shader[A-Za-z]*|jp\.whiteflare\.unlitwf[A-Za-z0-9\.]*)/(?<tail>.*)$", RegexOptions.Compiled);

            public int CompareTo(ShaderAndAssetPath other)
            {
                int ret;

                // マッチするものはマッチしないものよりも優先
                ret = -this.isMatch.CompareTo(other.isMatch);
                if (ret != 0)
                {
                    return ret;
                }

                // Packages は Assets よりも優先
                ret = -this.root.CompareTo(other.root);
                if (ret != 0)
                {
                    return ret;
                }

                // parent が浅いものほど優先
                ret = this.parent.Count(c => c == '/').CompareTo(other.parent.Count(c => c == '/'));
                if (ret != 0)
                {
                    return ret;
                }

                // parent + folder の辞書順で比較
                ret = (this.parent + "/" + this.folder).CompareTo(other.parent + "/" + other.folder);
                if (ret != 0)
                {
                    return ret;
                }

                // tail の長さ順で比較
                ret = this.tail.Length.CompareTo(other.tail.Length);
                if (ret != 0)
                {
                    return ret;
                }

                // tail の辞書順で比較
                return this.tail.CompareTo(other.tail);
            }
        }

        #endregion

        #region シェーダ・マテリアル判定

        /// <summary>
        /// ShaderがUnlitWFでサポートされるものかどうか判定する。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static bool IsSupportedShader(Shader shader)
        {
            if (shader == null)
            {
                return false;
            }
            var name = shader.name;
            if (!name.Contains("UnlitWF"))
            {
                return false;
            }
            if (IsURP())
            {
                return name.Contains("_URP");
            }
            return !name.Contains("_URP");
        }

        /// <summary>
        /// ShaderがUnlitWFでサポートされるものかどうか判定する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        public static bool IsSupportedShader(Material mat)
        {
            return mat != null && IsSupportedShader(mat.shader);
        }

        /// <summary>
        /// ShaderがVRC QuestでサポートされるUnlitWFかどうか判定する。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static bool IsMobileSupportedShader(Shader shader)
        {
            if (!IsSupportedShader(shader))
            {
                return false;
            }
            var name = shader.name;
            if (name.Contains("_Mobile_") || name.Contains("WF_UnToon_Hidden") || name.Contains("WF_DebugView"))
            {
                return true;
            }
            if (WFAccessor.GetShaderQuestSupported(shader))
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// ShaderがVRC QuestでサポートされるUnlitWFかどうか判定する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        public static bool IsMobileSupportedShader(Material mat)
        {
            return mat != null && IsMobileSupportedShader(mat.shader);
        }

        /// <summary>
        /// マテリアルがマイグレーション必要なプロパティを含んでいるかどうか判定する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        public static bool IsMigrationRequiredMaterial(Material mat)
        {
            return mat != null && Converter.WFMaterialMigrationConverter.ExistsNeedsMigration(mat);
        }

        /// <summary>
        /// UnlitWFのシェーダアセットパスに一致するアセットパスの正規表現
        /// </summary>
        private static readonly Regex regexPath = new Regex(@".*WF_.*\.shader", RegexOptions.Compiled | RegexOptions.IgnoreCase);

        /// <summary>
        /// 指定のアセットパスがUnlitWFのシェーダのものかどうか判定する。
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static bool IsSupportedShaderPath(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
            {
                return false;
            }
            return regexPath.IsMatch(path);
        }

        /// <summary>
        /// 指定のアセットパスがUnlitWFのシェーダのものかどうか判定する。
        /// </summary>
        /// <param name="paths"></param>
        /// <returns></returns>
        public static bool IsSupportedShaderPath(IEnumerable<string> paths)
        {
            return paths.Any(IsSupportedShaderPath);
        }

        #endregion

        #region バージョンチェック

        /// <summary>
        /// 最新リリースのVersionInfo
        /// </summary>
        private static WFVersionInfo LatestVersion = null;

        /// <summary>
        /// 最新リリースのVersionInfoを返却する。不明のときはnullを返却する。
        /// </summary>
        /// <returns></returns>
        public static WFVersionInfo GetLatestVersion()
        {
            return LatestVersion;
        }

        /// <summary>
        /// 最新リリースのVersionInfoを設定する。
        /// </summary>
        /// <param name="ver"></param>
        public static void SetLatestVersion(WFVersionInfo ver)
        {
            LatestVersion = ver != null && ver.HasValue() ? ver : null;
        }

        /// <summary>
        /// 指定のバージョン文字列が最新リリースよりも古いかどうか判定する。不明のときはfalseを返す。
        /// </summary>
        /// <param name="version"></param>
        /// <returns></returns>
        public static bool IsOlderShaderVersion(string version)
        {
            if (LatestVersion == null || version == null)
            {
                return false;
            }
            return version.CompareTo(LatestVersion.latestVersion) < 0;
        }

        /// <summary>
        /// 最新リリースのダウンロードページを開く。
        /// </summary>
        public static void OpenDownloadPage()
        {
            if (LatestVersion == null)
            {
                return;
            }
            Application.OpenURL(LatestVersion.downloadPage);
        }

        #endregion

        #region その他の汎用ユーティリティ

        /// <summary>
        /// Object[] -> Material[] のユーティリティ関数。
        /// </summary>
        /// <param name="array"></param>
        /// <returns></returns>
        public static Material[] AsMaterials(params UnityEngine.Object[] array)
        {
            return array == null ? new Material[0] : array.Select(obj => obj as Material).Where(m => m != null).ToArray();
        }

        public static string GetCurrentRenderPipeline()
        {
            return WFCommonUtility.IsURP() ? "URP" : "BRP";
        }

        public static bool IsURP()
        {
#if UNITY_2019_1_OR_NEWER
            return UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline != null;
#else
            return false;
#endif
        }

        public static bool IsQuestPlatform()
        {
            return EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android;
        }

        public static bool IsManagedUPM()
        {
            return AssetDatabase.IsValidFolder("Packages/jp.whiteflare.unlitwf");
        }

        public const string KWD_EDITOR_HIDE_LMAP = "_WF_EDITOR_HIDE_LMAP";

        public static bool IsKwdEnableHideLmap()
        {
            return Shader.IsKeywordEnabled(KWD_EDITOR_HIDE_LMAP);
        }

        public static void SetKwdEnableHideLmap(bool value)
        {
            if (value)
            {
                Shader.EnableKeyword(KWD_EDITOR_HIDE_LMAP);
            }
            else
            {
                Shader.DisableKeyword(KWD_EDITOR_HIDE_LMAP);
            }
        }

        private static bool? inSpecialProject = null;

        /// <summary>
        /// UnlitWFが特殊なプロジェクト内にあるかどうか判定する。
        /// </summary>
        /// <returns></returns>
        public static bool IsInSpecialProject()
        {
            var result = inSpecialProject;
            if (result == null)
            {
                var asset = AssetDatabase.LoadAssetAtPath<DefaultAsset>("Assets/VketTools");
                if (asset == null)
                {
                    asset = AssetDatabase.LoadAssetAtPath<DefaultAsset>("Assets/VitDeck");
                }
                result = inSpecialProject = (asset != null);
            }
            return (bool)result;
        }

        [InitializeOnLoadMethod]
        private static void ClearSpecialProjectFlag()
        {
            inSpecialProject = null;
        }

        #endregion
    }

    static class WFAccessor
    {
        /// <summary>
        /// Shader に指定のプロパティが存在するかどうか返す。
        /// </summary>
        /// <param name="shader"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static bool HasShaderProperty(Shader shader, string name)
        {
            return 0 <= findPropertyIndex(shader, name);
        }

        /// <summary>
        /// Shader に指定のプロパティが Texture タイプで存在するかどうか返す。
        /// </summary>
        /// <param name="shader"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static bool HasShaderPropertyTexture(Shader shader, string name)
        {
            var idx = findPropertyIndex(shader, name);
            if (idx < 0)
            {
                return false;
            }
#if UNITY_2019_1_OR_NEWER
            return shader.GetPropertyType(idx) == UnityEngine.Rendering.ShaderPropertyType.Texture;
#else
            return ShaderUtil.GetPropertyType(shader, idx) == ShaderUtil.ShaderPropertyType.TexEnv;
#endif
        }

        /// <summary>
        /// Shader の全てのプロパティ名を返す。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static IEnumerable<string> GetAllPropertyNames(Shader shader)
        {
#if UNITY_2019_1_OR_NEWER
            for (int idx = 0; idx < shader.GetPropertyCount(); idx++)
            {
                yield return shader.GetPropertyName(idx);
            }
#else
            for (int idx = ShaderUtil.GetPropertyCount(shader) - 1; 0 <= idx; idx--)
            {
                yield return ShaderUtil.GetPropertyName(shader, idx);
            }
#endif
        }

        /// <summary>
        /// Shader から 指定の名前のプロパティの PropertyIndex を取得する。
        /// </summary>
        /// <param name="shader"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        private static int findPropertyIndex(Shader shader, string name)
        {
#if UNITY_2019_1_OR_NEWER
            return shader.FindPropertyIndex(name);
#else
            for (int idx = ShaderUtil.GetPropertyCount(shader) - 1; 0 <= idx; idx--)
            {
                if (name == ShaderUtil.GetPropertyName(shader, idx))
                {
                    return idx;
                }
            }
            return -1;
#endif
        }

        /// <summary>
        /// Shader から 指定の名前のプロパティの description を取得する。
        /// </summary>
        /// <param name="shader"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static string GetPropertyDescription(Shader shader, string name, string _default = null)
        {
            var idx = findPropertyIndex(shader, name);
            if (0 <= idx)
            {
#if UNITY_2019_1_OR_NEWER
                return shader.GetPropertyDescription(idx);
#else
                return ShaderUtil.GetPropertyDescription(shader, idx);
#endif
            }
            return _default;
        }

        /// <summary>
        /// Shader から _CurrentVersion の値を取得する。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static string GetShaderCurrentVersion(Shader shader)
        {
            return GetPropertyDescription(shader, "_CurrentVersion");
        }

        /// <summary>
        /// Shader から _FallBack の値を取得する。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static string GetShaderFallBackTarget(Shader shader)
        {
            return GetPropertyDescription(shader, "_FallBack");
        }

        /// <summary>
        /// Shader から QuestSupported の値を取得する。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static bool GetShaderQuestSupported(Shader shader)
        {
            return GetPropertyDescription(shader, "_QuestSupported", "false").ToLower() == "true";
        }


        /// <summary>
        /// Material から _CurrentVersion の値を取得する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        public static string GetShaderCurrentVersion(Material mat)
        {
            return mat == null ? null : GetShaderCurrentVersion(mat.shader);
        }

        /// <summary>
        /// Material から _FallBack の値を取得する。
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        public static string GetShaderFallBackTarget(Material mat)
        {
            return mat == null ? null : GetShaderFallBackTarget(mat.shader);
        }

        public static int GetMaterialRenderQueueValue(Material mat)
        {
            // Material.renderQueue の値を単に参照すると -1 (FromShader) が取れないので SerializedObject から取得する
            var so = new SerializedObject(mat);
            so.Update();
            var prop = so.FindProperty("m_CustomRenderQueue");
            if (prop != null)
            {
                return prop.intValue;
            }
            return mat.renderQueue;
        }

        public static string GetMaterialRenderType(Material mat)
        {
            return mat.GetTag("RenderType", true, "Opaque");
        }

        public static bool IsMaterialRenderType(Material mat, params string[] tags)
        {
            return tags.Contains(GetMaterialRenderType(mat));
        }

        public static int GetInt(Material mat, string name, int _default)
        {
            if (mat.HasProperty(name))
            {
                return mat.GetInt(name);
            }
            return _default;
        }

        public static float GetFloat(Material mat, string name, float _default)
        {
            if (mat.HasProperty(name))
            {
                return mat.GetFloat(name);
            }
            return _default;
        }
    }

    abstract class WFCustomKeywordSetting
    {
        public readonly string propertyName;
        public string enablePropName;

        protected WFCustomKeywordSetting(string propertyName)
        {
            this.propertyName = propertyName;
        }

        public abstract bool SetKeywordTo(Material mat);

        protected bool IsEnable(Material mat)
        {
            if (string.IsNullOrWhiteSpace(enablePropName))
            {
                // 未指定のときはOK
                return true;
            }
            return WFCommonUtility.IsPropertyTrue(mat, enablePropName);
        }

        protected bool ApplyKeyword(Material mat, string[] kwds, int value)
        {
            bool enable = IsEnable(mat);
            bool changed = false;
            for (int i = 0; i < kwds.Length; i++)
            {
                changed |= SetKeyword(mat, kwds[i], enable && i == value);
            }
            return changed;
        }

        public bool ApplyKeywordByBool(Material mat, string kwd, bool value)
        {
            bool enable = IsEnable(mat);
            return SetKeyword(mat, kwd, enable && value);
        }

        public static bool SetKeyword(Material mat, string kwd, bool value)
        {
#if !UNITY_2019_1_OR_NEWER || _WF_LEGACY_FEATURE_SWITCH
            // 旧版では常に false として扱う。これにより既にマテリアルに設定されていたキーワードは2018で消去される。
            value = false;
#endif
            if (string.IsNullOrEmpty(kwd) || kwd == "_" || mat.IsKeywordEnabled(kwd) == value)
            {
                return false;
            }
            if (value)
            {
                mat.EnableKeyword(kwd);
            }
            else
            {
                mat.DisableKeyword(kwd);
            }
            return true;
        }
    }

    class WFCustomKeywordSettingBool : WFCustomKeywordSetting
    {
        public readonly string keyword;

        public WFCustomKeywordSettingBool(string propertyName, string keyword) : base(propertyName)
        {
            this.keyword = keyword;
        }

        public override bool SetKeywordTo(Material mat)
        {
            return ApplyKeywordByBool(mat, keyword, WFCommonUtility.IsPropertyTrue(mat, propertyName));
        }
    }

    class WFCustomKeywordSettingEnum : WFCustomKeywordSetting
    {
        public readonly string[] keywords;
        public readonly int[] index;

        public WFCustomKeywordSettingEnum(string propertyName, params string[] keywords) : base(propertyName)
        {
            // キーワードの配列を重複なしに変換し、インデックスの変換表を作成する
            var newKwdArray = new List<string>();
            var newIdxArray = new List<int>();
            for (int i = 0; i < keywords.Length; i++)
            {
                string kwd = keywords[i];
                int idx = newKwdArray.IndexOf(kwd);
                if (idx < 0)
                {
                    idx = newKwdArray.Count;
                    newKwdArray.Add(kwd);
                }
                newIdxArray.Add(idx);
            }

            this.keywords = newKwdArray.ToArray();
            this.index = newIdxArray.ToArray();
        }

        public override bool SetKeywordTo(Material mat)
        {
            int value = mat.GetInt(propertyName);
            value = 0 <= value && value < index.Length ? index[value] : -1;
            return ApplyKeyword(mat, keywords, value);
        }
    }

    [Serializable]
    class WFVersionInfo
    {
        public string latestVersion;
        public string downloadPage;

        public bool HasValue()
        {
            return latestVersion != null && downloadPage != null;
        }
    }

    class WFShaderFunction
    {
        private static List<string> uniqueLabel = new List<string>();

        public readonly string Label;
        public readonly string Prefix;
        public readonly string Name;
        private readonly Func<WFShaderFunction, Material, bool> _contains;

        internal WFShaderFunction(string label, string prefix, string name) : this(label, prefix, name, IsEnable)
        {
        }

        public static bool IsEnable(WFShaderFunction func, Material mat)
        {
            return IsEnable("_" + func.Prefix + "_Enable", mat);
        }

        public static bool IsEnable(string name, Material mat)
        {
            if (mat.HasProperty(name))
            {
                return mat.GetInt(name) != 0;
            }
            return false;
        }

        internal WFShaderFunction(string label, string prefix, string name, Func<WFShaderFunction, Material, bool> contains)
        {
            Label = label;
            Prefix = prefix;
            Name = name;
            _contains = contains;

            if (uniqueLabel.Contains(Label))
            {
                Debug.LogWarningFormat("[WF][Common] WFShaderFunction duplicate Label: " + Label);
            }
            else
            {
                uniqueLabel.Add(Label);
            }
        }

        public bool IsEnable(Material mat)
        {
            if (!WFCommonUtility.IsSupportedShader(mat))
            {
                return false;
            }
            return _contains(this, mat);
        }

        public static List<string> LabelToPrefix(List<string> labelList)
        {
            return labelList.Select(LabelToPrefix).Where(prefix => prefix != null).Distinct().ToList();
        }

        public static string LabelToPrefix(string label)
        {
            return WFShaderDictionary.ShaderFuncList.Where(func => func.Label == label).Select(func => func.Prefix).FirstOrDefault();
        }

        public static WFShaderFunction[] GetEnableFunctionList(Material mat)
        {
            var result = new List<WFShaderFunction>();
            foreach (var func in WFShaderDictionary.ShaderFuncList)
            {
                if (func.IsEnable(mat))
                {
                    result.Add(func);
                }
            }
            return result.ToArray();
        }
    }

    enum EditorLanguage
    {
        English, 日本語, 한국어
    }

    class WFI18NTranslation
    {
        public readonly string Before;
        public readonly string After;
        private readonly HashSet<string> Tags = new HashSet<string>();

        public WFI18NTranslation(string before, string after) : this(null, before, after)
        {
        }

        public WFI18NTranslation(string tag, string before, string after)
        {
            Before = before;
            After = after;
            AddTag(tag);
        }

        public WFI18NTranslation AddTag(params string[] tags)
        {
            foreach (var tag in tags)
            {
                if (tag != null)
                {
                    Tags.Add(tag);
                }
            }
            return this;
        }

        public bool ContainsTag(string tag)
        {
            return tag != null && (Tags.Count == 0 || Tags.Contains(tag));
        }

        public bool HasNoTag()
        {
            return Tags.Count == 0;
        }
    }

    static class WFEditorPrefs
    {
        private static readonly string KEY_EDITOR_LANG = "UnlitWF.ShaderEditor/Lang";
        private static readonly string KEY_MENU_TO_BOTTOM = "UnlitWF.ShaderEditor/MenuToBottom";

        private static bool? menuToBottom = null;
        private static EditorLanguage? langMode = null;

        public static bool MenuToBottom
        {
            get
            {
                if (menuToBottom == null)
                {
                    menuToBottom = EditorPrefs.GetBool(KEY_MENU_TO_BOTTOM, false);
                }
                return menuToBottom.Value;
            }
            set
            {
                if (menuToBottom != value)
                {
                    menuToBottom = value;
                    if (value)
                    {
                        EditorPrefs.SetBool(KEY_MENU_TO_BOTTOM, true);
                    }
                    else
                    {
                        EditorPrefs.DeleteKey(KEY_MENU_TO_BOTTOM);
                    }
                }
            }
        }

        public static EditorLanguage LangMode
        {
            get
            {
                if (langMode == null)
                {
                    string lang = EditorPrefs.GetString(KEY_EDITOR_LANG) ?? "";
                    if (!string.IsNullOrWhiteSpace(lang))
                    {
                        return ToEditorLanguage(lang);
                    }
                    langMode = ToEditorLanguage(System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                }
                return langMode.Value;
            }
            set
            {
                langMode = value;
                SetLangModeInternal(langMode);
            }
        }

        private static EditorLanguage ToEditorLanguage(string lang)
        {
            switch (lang)
            {
                case "ja":
                    return EditorLanguage.日本語;
                case "ko":
                    return EditorLanguage.한국어;
                default:
                    return EditorLanguage.English;
            }
        }

        private static void SetLangModeInternal(EditorLanguage? value)
        {
            if (value == null)
            {
                EditorPrefs.DeleteKey(KEY_EDITOR_LANG);
            }
            else
            {
                switch (value)
                {
                    case EditorLanguage.日本語:
                        EditorPrefs.SetString(KEY_EDITOR_LANG, "ja");
                        break;
                    case EditorLanguage.한국어:
                        EditorPrefs.SetString(KEY_EDITOR_LANG, "ko");
                        break;
                    default:
                        EditorPrefs.SetString(KEY_EDITOR_LANG, "en");
                        break;
                }
            }
        }
    }

    static class WFI18N
    {
        private static readonly Dictionary<string, List<WFI18NTranslation>> EN = new Dictionary<string, List<WFI18NTranslation>>();
        private static readonly Dictionary<string, List<WFI18NTranslation>> JA = ToDict(WFShaderDictionary.LangEnToJa);
        private static readonly Dictionary<string, List<WFI18NTranslation>> KO = ToDict(WFShaderDictionary.LangEnToKo);

        static Dictionary<string, List<WFI18NTranslation>> GetDict()
        {
            switch (WFEditorPrefs.LangMode)
            {
                case EditorLanguage.日本語:
                    return JA;
                case EditorLanguage.한국어:
                    return KO;
                default:
                    return EN;
            }
        }

        public static string Translate(string before)
        {
            TryTranslate(null, before, out var after);
            return after;
        }

        public static string Translate(string label, string before)
        {
            TryTranslate(label, before, out var after);
            return after;
        }

        public static bool TryTranslate(string before, out string after)
        {
            return TryTranslate(null, before, out after);
        }

        public static bool TryTranslate(string label, string before, out string after)
        {
            if (string.IsNullOrWhiteSpace(before))
            {
                // 空白のときは空文字にして変換失敗とする
                after = "";
                return false;
            }

            var current = GetDict();
            if (current == null || current.Count == 0)
            {
                after = before; // 無いなら変換しない
                return false;
            }

            if (current.TryGetValue(before, out var list))
            {
                string text;
                // テキストと一致する変換のなかからラベルも一致するものを翻訳にする
                if (!string.IsNullOrWhiteSpace(label))
                {
                    text = list.Where(t => t.ContainsTag(label)).Select(t => t.After).FirstOrDefault();
                    if (text != null)
                    {
                        after = text;
                        return true;
                    }
                }

                // ラベルなしでテキストが一致するものを検索する
                text = list.Where(t => t.HasNoTag()).Select(t => t.After).FirstOrDefault();
                if (text != null)
                {
                    after = text;
                    return true;
                }
            }

            // マッチするものがないなら変換しない
            after = before;
            return false;
        }

        private static string SplitAndTranslate(string before)
        {
            if (WFCommonUtility.FormatDispName(before, out var label, out var text, out var _))
            {
                // text がラベルとテキストに分割できるならば
                return "[" + label + "] " + Translate(label, text);
            }
            else
            {
                // そうでなければ
                return Translate(before);
            }
        }

        public static GUIContent GetGUIContent(string text)
        {
            var localized = SplitAndTranslate(text);
            return new GUIContent(localized);
        }

        public static GUIContent GetGUIContent(string label, string text, string tooltip = null)
        {
            string localized = Translate(label, text);
            if (string.IsNullOrWhiteSpace(tooltip))
            {
                return new GUIContent("[" + label + "] " + localized);
            }
            return new GUIContent("[" + label + "] " + localized, tooltip);
        }

        private static Dictionary<string, List<WFI18NTranslation>> ToDict(List<WFI18NTranslation> from)
        {
            var result = new Dictionary<string, List<WFI18NTranslation>>();

            foreach (var group in from.GroupBy(t => t.Before))
            {
                result[group.Key] = new List<WFI18NTranslation>(group.OrderBy(t => t.HasNoTag()));
            }

            return result;
        }
    }

    class WFShaderName
    {
        public readonly string RenderPipeline;
        public readonly string Familly;
        public readonly string Variant;
        public readonly string RenderType;
        public readonly string Name;
        public readonly bool Represent;

        public WFShaderName(string rp, string familly, string variant, string renderType, string name, bool represent = false)
        {
            RenderPipeline = rp;
            Familly = familly;
            Variant = variant;
            RenderType = renderType;
            Name = name;
            Represent = represent;
        }
    }

    class WFVariantList
    {
        public readonly WFShaderName current;

        public readonly List<WFShaderName> familyList = new List<WFShaderName>();
        public readonly List<WFShaderName> variantList = new List<WFShaderName>();
        public readonly List<WFShaderName> renderTypeList = new List<WFShaderName>();

        public int idxFamily = -1;
        public int idxVariant = -1;
        public int idxRenderType = -1;

        public WFVariantList(WFShaderName current)
        {
            this.current = current;
        }

        public string[] LabelFamilyList { get => familyList.Select(nm => nm == null ? "" : nm.Familly).ToArray(); }
        public string[] LabelVariantList { get => variantList.Select(nm => nm == null ? "" : nm.Variant).ToArray(); }
        public string[] LabelRenderTypeList { get => renderTypeList.Select(nm => nm == null ? "" : nm.RenderType).ToArray(); }
    }

    static class WFShaderNameDictionary
    {
        private static volatile List<WFShaderName> additionalShaderNamesCache = null;

        internal class CacheCleaner : AssetPostprocessor
        {
            public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromPath)
            {
                if (WFCommonUtility.IsSupportedShaderPath(importedAssets))
                {
                    additionalShaderNamesCache = null;
                }
            }
        }

        private static IEnumerable<WFShaderName> GetAdditionalShaderNames(string rp, List<WFShaderName> wellknownShaders)
        {
            var result = additionalShaderNamesCache;
            if (result == null)
            {
                // カスタムシェーダをAssetDatabaseから検索
                result = new List<WFShaderName>(AssetDatabase.FindAssets("t:Shader")
                    // パスを取得
                    .Select(guid => AssetDatabase.GUIDToAssetPath(guid)).Where(path => !string.IsNullOrWhiteSpace(path))
                    // シェーダをロード
                    .Select(path => AssetDatabase.LoadAssetAtPath<Shader>(path)).Where(shader => shader != null)
                    // UnlitWFのシェーダであること
                    .Where(shader => WFCommonUtility.IsSupportedShader(shader))
                    // result内に名称が一致するものがないこと
                    .Where(shader => !wellknownShaders.Any(snm => shader.name == snm.Name))
                    // Categoryプロパティを正しく分解できること
                    .Where(shader =>
                    {
                        var categoryString = WFAccessor.GetPropertyDescription(shader, "_Category");
                        return categoryString != null && 4 <= categoryString.Split('|').Length;
                    })
                    // Categoryプロパティの文字列で並び替える
                    .OrderBy(shader => WFAccessor.GetPropertyDescription(shader, "_Category"))
                    // WFShaderName を作成して追加
                    .SelectMany(shader =>
                    {
                        var category = WFAccessor.GetPropertyDescription(shader, "_Category").Split('|');
                        if (rp == category[0] && wellknownShaders.Select(snm => snm.Familly).Contains(category[1]))
                        {
                            if (category[2] != "" && category[3] != "")
                            {
                                return new WFShaderName[] { new WFShaderName(category[0], category[1], category[2], category[3], shader.name) };
                            }
                        }
                        return new WFShaderName[0];
                    }));

                /********************
                 * _Category プロパティの仕様
                 * 
                 * - `_Category` の名前で shader プロパティとして用意して、DisplayName 部分を読み取る。
                 * - '|' で4要素以上に分解できるものを有効なカテゴリとして使用する。
                 * - フォーマットは `RenderPipeline|Family|Variant|RenderType`
                 * - RenderPipeline は利用するパイプライン。`BRP` あるいは `URP` が有効。
                 * - Family は既存の Family に一致するものを有効とする。`UnToon` とか `FakeFur` とか。
                 * - 具体例: "BRP|UnToon|Custom/ClearCoat|Transparent"
                 * 
                 ********************/

                additionalShaderNamesCache = result;
            }
            return result;
        }

        private static IEnumerable<WFShaderName> GetCurrentRpNames()
        {
            var result = new List<WFShaderName>();
            var rp = WFCommonUtility.GetCurrentRenderPipeline();

            // ShaderNameList からRPが一致するものを列挙
            result.AddRange(WFShaderDictionary.ShaderNameList.Where(nm => nm.RenderPipeline == rp));
            // カスタムシェーダをAssetDatabaseから検索
            result.AddRange(GetAdditionalShaderNames(rp, result));

            return result;
        }

        public static WFShaderName TryFindFromName(string name)
        {
            return GetCurrentRpNames().Where(nm => nm.Name == name).FirstOrDefault();
        }

        public static List<WFShaderName> GetFamilyList()
        {
            var result = new List<WFShaderName>();
            foreach(var group in GetCurrentRpNames().GroupBy(p => p.Familly))
            {
                // Family ごとにグループ化して、Represent が true のものがあればそれを取得、そうでなければ最初の1件を取得してリストに詰める
                var represent = group.Where(p => p.Represent).Union(group).FirstOrDefault();
                if (represent != null)
                {
                    result.Add(represent);
                }
            }
            return result;
        }

        public static List<WFShaderName> GetVariantList(WFShaderName name)
        {
            var first = new List<WFShaderName>();
            if (name == null)
            {
                return first;
            }

            var second = new List<WFShaderName>();
            var third = new List<WFShaderName>();

            // Variant でグループ化して、RenderType の一致するものを first に、一致しないものを second に追加
            foreach (var group in GetCurrentRpNames().Where(nm => nm.Familly == name.Familly).GroupBy(nm => nm.Variant))
            {
                if (!IsVariantCustomOrLegacy(group.Key))
                {
                    var snm = group.Where(nm => nm.RenderType == name.RenderType).FirstOrDefault();
                    if (snm != null)
                    {
                        first.Add(snm);
                    }
                    else
                    {
                        second.Add(group.First());
                    }
                }
                else
                {
                    var snm = group.Where(nm => nm.RenderType == name.RenderType).FirstOrDefault();
                    if (snm != null)
                    {
                        third.Add(snm);
                    }
                    else
                    {
                        third.Add(group.First());
                    }
                }
            }

            // 結合
            if (0 < first.Count && 0 < second.Count)
            {
                first.Add(null);
            }
            first.AddRange(second);
            if (0 < first.Count && 0 < third.Count)
            {
                first.Add(null);
            }
            first.AddRange(third);

            return first;
        }

        public static List<WFShaderName> GetRenderTypeList(WFShaderName name)
        {
            var first = new List<WFShaderName>();
            if (name == null)
            {
                return first;
            }

            var second = new List<WFShaderName>();

            // RenderType でグループ化して、Variant の一致するものを first に、一致しないものを second に追加
            foreach (var group in GetCurrentRpNames().Where(nm => nm.Familly == name.Familly).GroupBy(nm => nm.RenderType))
            {
                var snm = group.Where(nm => nm.Variant == name.Variant).FirstOrDefault();
                if (snm != null)
                {
                    first.Add(snm);
                }
                else
                {
                    // ただし一致しない場合では Custom と Legacy は無視する
                    snm = group.Where(nm => !(IsVariantCustomOrLegacy(nm))).FirstOrDefault();
                    if (snm != null)
                    {
                        second.Add(snm);
                    }
                }
            }

            if (0 < first.Count && 0 < second.Count)
            {
                first.Add(null);
            }
            first.AddRange(second);

            return first;
        }

        private static bool IsVariantCustomOrLegacy(WFShaderName nm)
        {
            return nm != null && IsVariantCustomOrLegacy(nm.Variant);
        }

        private static bool IsVariantCustomOrLegacy(string variant)
        {
            return variant != null && (variant.StartsWith("Custom/") || variant.StartsWith("Legacy/"));
        }

        public static WFVariantList CreateVariantList(WFShaderName current)
        {
            WFVariantList result = new WFVariantList(current);
            {
                result.familyList.AddRange(GetFamilyList());
                result.idxFamily = Array.IndexOf(result.LabelFamilyList, current.Familly);
            }
            {
                result.variantList.AddRange(GetVariantList(current));
                result.idxVariant = Array.IndexOf(result.LabelVariantList, current.Variant);
            }
            {
                result.renderTypeList.AddRange(GetRenderTypeList(current));
                result.idxRenderType = Array.IndexOf(result.LabelRenderTypeList, current.RenderType);
            }
            return result;
        }
    }
}

#endif
