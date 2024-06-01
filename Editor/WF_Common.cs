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

// #define _WF_LEGACY_FEATURE_SWITCH
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
            if (text != null)
            {
                var mm = PAT_DISP_NAME.Match(text ?? "");
                if (mm.Success)
                {
                    label = mm.Groups["label"].Value.ToUpper();
                    name = mm.Groups["name"].Value;
                    dispName = "[" + label + "] " + name;
                    return true;
                }
            }
            label = null;
            name = text;
            dispName = text;
            return false;
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

        public static string GetHelpUrl(MaterialEditor editor, string displayName, string headerTitle)
        {
            string url;
            if (FormatDispName(displayName, out var label, out var _, out var _))
            {
                if (WFShaderDictionary.ShaderFuncHelpUrl.TryGetValue(label, out url))
                {
                    return url;
                }
            }
            var shaderName = WFShaderNameDictionary.TryFindFromName(GetCurrentShader(editor)?.name);
            if (shaderName != null)
            {
                if (WFShaderDictionary.ShaderFuncHelpUrl.TryGetValue(shaderName.Familly + "/" + shaderName.Variant + "/" + headerTitle, out url))
                {
                    return url;
                }
                if (WFShaderDictionary.ShaderFuncHelpUrl.TryGetValue(shaderName.Familly + "/" + headerTitle, out url))
                {
                    return url;
                }
            }
            if (WFShaderDictionary.ShaderFuncHelpUrl.TryGetValue(headerTitle, out url))
            {
                return url;
            }
            return null;
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
            return mat != null && mat.HasProperty(prop_name) && IsPropertyTrue(mat.GetFloat(prop_name));
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
        public static bool SetupMaterials(params Material[] mats)
        {
            bool changed = false;
            foreach(var mat in mats)
            {
                changed |= SetupMaterial(mat);
            }
            return changed;
        }

        /// <summary>
        /// 各マテリアルのEnableキーワードを設定する
        /// </summary>
        /// <param name="mats"></param>
        public static bool SetupMaterial(Material mat)
        {
            var changed = false;
            if (IsSupportedShader(mat))
            {
                changed |= SetupMaterial_CommonMaterialSettings(mat);
                changed |= SetupMaterial_GIFrags(mat);
                changed |= SetupMaterial_ClearBgPass(mat);
                changed |= SetupMaterial_SetupKeyword(mat);
                changed |= SetupMaterial_DeleteKeyword(mat);
            }
            return changed;
        }

        private static bool SetupMaterial_DeleteKeyword(Material mat)
        {
            // 不要なシェーダキーワードは削除
            bool changed = false;
            foreach (var key in DELETE_KEYWORD)
            {
                if (mat.IsKeywordEnabled(key))
                {
                    mat.DisableKeyword(key);
                    changed = true;
                }
            }
            return changed;
        }

        private static bool SetupMaterial_SetupKeyword(Material mat)
        {
            // Enableキーワードを整理する
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

            return changed;
        }

        private static bool SetupMaterial_GIFrags(Material mat)
        {
            // _ES_ENABLE に連動して MaterialGlobalIlluminationFlags を設定する
            bool changed = false;
            if (mat.HasProperty("_ES_Enable"))
            {
                var flag = mat.GetInt("_ES_Enable") != 0 ? MaterialGlobalIlluminationFlags.BakedEmissive : MaterialGlobalIlluminationFlags.None;
                if (mat.globalIlluminationFlags != flag)
                {
                    mat.globalIlluminationFlags = flag;
                    changed = true;
                }
            }
            return changed;
        }

        private static bool SetupMaterial_ClearBgPass(Material mat)
        {
            // 半透明描画のときはAlwaysパス(CLR_BG)を無効化し、それ以外は有効化する
            bool changed = false;
            var isOpaque = mat.renderQueue <= 2500
                || IsURP()
                || !WFAccessor.GetShaderClearBgSupported(mat.shader)
                ;
            if (mat.GetShaderPassEnabled("Always") != isOpaque)
            {
                mat.SetShaderPassEnabled("Always", isOpaque);
                changed = true;
            }
            return changed;
        }

        private static bool SetupMaterial_CommonMaterialSettings(Material mat)
        {
            var changed = false;
            var settings = WFEditorSetting.GetOneOfSettings();
            changed |= SetupMaterial_CommonMaterialSettings(mat, "_GL_NCC_Enable", (int) settings.GetEnableNccInCurrentEnvironment());
            changed |= SetupMaterial_CommonMaterialSettings(mat, "_CRF_UseDepthTex", (int)settings.GetUseDepthTexInCurrentEnvironment());
            changed |= SetupMaterial_CommonMaterialSettings(mat, "_CGL_UseDepthTex", (int)settings.GetUseDepthTexInCurrentEnvironment());
            changed |= SetupMaterial_CommonMaterialSettings(mat, "_TS_DisableBackLit", (int)settings.GetDisableBackLitInCurrentEnvironment());
            changed |= SetupMaterial_CommonMaterialSettings(mat, "_TR_DisableBackLit", (int)settings.GetDisableBackLitInCurrentEnvironment());
            return changed;
        }

        private static bool SetupMaterial_CommonMaterialSettings(Material mat, string name, int newVal)
        {
            bool changed = false;
            if (0 <= newVal && mat.HasProperty(name)) // ForceOFF または ForceON の場合に設定する
            {
                var oldVal = mat.GetInt(name);
                if (oldVal != newVal)
                {
                    mat.SetInt(name, newVal);
                    changed = true;
                }
            }
            return changed;
        }

        #endregion

        #region シェーダ切り替え

        /// <summary>
        /// マテリアルの shader を指定の名前のものに変更する。
        /// </summary>
        /// <param name="name"></param>
        /// <param name="mats"></param>
        public static bool ChangeShader(string name, params Material[] mats)
        {
            if (string.IsNullOrWhiteSpace(name) || mats.Length == 0)
            {
                return false; // なにもしない
            }

            var newShader = FindShader(name);
            if (newShader == null)
            {
                Debug.LogErrorFormat("[WF][Common] Shader Not Found in this projects: {0}", name);
                return false;
            }

            Undo.RecordObjects(mats, "change shader");
            var changed = false;
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
                changed |= true;
            }
            return changed;
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

        public static Material GetCurrentMaterial(MaterialEditor editor)
        {
            if (editor == null)
            {
                return null;
            }
            return editor.target as Material;
        }

        public static Material[] GetCurrentMaterials(MaterialEditor editor)
        {
            if (editor == null)
            {
                return null;
            }
            return AsMaterials(editor.targets);
        }

        public static Shader GetCurrentShader(MaterialEditor editor)
        {
            return GetCurrentMaterial(editor)?.shader;
        }

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

        public static CurrentEntironment GetCurrentEntironment()
        {
#if ENV_VRCSDK3_AVATAR
            return CurrentEntironment.VRCSDK3_Avatar;
#elif ENV_VRCSDK3_WORLD
            return CurrentEntironment.VRCSDK3_World;
#else
            return CurrentEntironment.Other;
#endif
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

    enum CurrentEntironment
    {
        VRCSDK3_Avatar,
        VRCSDK3_World,
        Other,
    }

    static class WFAccessor
    {
        #region シェーダプロパティの取得

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
        /// Shader から VRCFallback の値を取得する。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static string GetVRCFallback(Shader shader)
        {
            return GetPropertyDescription(shader, "_VRCFallback");
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
        /// Shader から QuestSupported の値を取得する。
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static bool GetShaderClearBgSupported(Shader shader)
        {
            return GetPropertyDescription(shader, "_ClearBgSupported", "false").ToLower() == "true";
        }

        #endregion

        #region マテリアルプロパティの取得

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

        public static bool IsVariant(Material mat)
        {
#if UNITY_2022_1_OR_NEWER
            return mat.isVariant;
#else
            return false;
#endif
        }

        public static bool IsVariant(UnityEngine.Object[] mats)
        {
#if UNITY_2022_1_OR_NEWER
            return WFCommonUtility.AsMaterials(mats).Any(IsVariant);
#else
            return false;
#endif
        }

        public static bool IsPropertyLockedByAncestor(Material mat, string name)
        {
#if UNITY_2022_1_OR_NEWER
            return mat.IsPropertyLockedByAncestor(name);
#else
            return false;
#endif
        }

        public static bool IsPropertyLockedByAncestor(UnityEngine.Object[] mats, string name)
        {
#if UNITY_2022_1_OR_NEWER
            return WFCommonUtility.AsMaterials(mats).Any(mat => IsPropertyLockedByAncestor(mat, name));
#else
            return false;
#endif
        }

        #endregion

        #region マテリアル値の取得

        private static bool CanRead(Material mat, string name)
        {
            return mat != null && mat.HasProperty(name);
        }

        public static bool GetBool(Material mat, string name, bool _default)
        {
            if (CanRead(mat, name))
            {
                return mat.GetInt(name) != 0;
            }
            return _default;
        }

        public static int GetInt(Material mat, string name, int _default)
        {
            if (CanRead(mat, name))
            {
                return mat.GetInt(name);
            }
            return _default;
        }

        public static float GetFloat(Material mat, string name, float _default)
        {
            if (CanRead(mat, name))
            {
                return mat.GetFloat(name);
            }
            return _default;
        }

        public static Color GetColor(Material mat, string name, Color _default)
        {
            if (CanRead(mat, name))
            {
                return mat.GetColor(name);
            }
            return _default;
        }

        public static Vector4 GetVector(Material mat, string name, Vector4 _default)
        {
            if (CanRead(mat, name))
            {
                return mat.GetVector(name);
            }
            return _default;
        }

        public static Texture GetTexture(Material mat, string name)
        {
            if (CanRead(mat, name))
            {
                return mat.GetTexture(name);
            }
            return null;
        }

#endregion

#region マテリアル値の設定

        private static bool CanWrite(Material mat, string name)
        {
            return mat != null && mat.HasProperty(name) && !IsPropertyLockedByAncestor(mat, name);
        }

        public static bool SetBool(Material mat, string name, bool value)
        {
            if (CanWrite(mat, name))
            {
                mat.SetInt(name, value ? 1 : 0);
                return true;
            }
            return false;
        }

        public static bool SetInt(Material mat, string name, int value)
        {
            if (CanWrite(mat, name))
            {
                mat.SetInt(name, value);
                return true;
            }
            return false;
        }

        public static bool SetFloat(Material mat, string name, float value)
        {
            if (CanWrite(mat, name))
            {
                mat.SetFloat(name, value);
                return true;
            }
            return false;
        }

        public static bool SetColor(Material mat, string name, Color value)
        {
            if (CanWrite(mat, name))
            {
                mat.SetColor(name, value);
                return true;
            }
            return false;
        }

        public static bool SetVector(Material mat, string name, Vector4 value)
        {
            if (CanWrite(mat, name))
            {
                mat.SetVector(name, value);
                return true;
            }
            return false;
        }

        public static bool SetTexture(Material mat, string name, Texture value)
        {
            if (CanWrite(mat, name))
            {
                mat.SetTexture(name, value);
                return true;
            }
            return false;
        }

        public static bool CopyFloatValue(Material mat, string from, string to)
        {
            if (CanRead(mat, from) && CanWrite(mat, to))
            {
                mat.SetFloat(to, mat.GetFloat(from));
                return true;
            }
            return false;
        }

        public static bool CopyIntValue(Material mat, string from, string to)
        {
            if (CanRead(mat, from) && CanWrite(mat, to))
            {
                mat.SetInt(to, mat.GetInt(from));
                return true;
            }
            return false;
        }

        public static bool CopyTextureValue(Material mat, string from, string to)
        {
            if (CanRead(mat, from) && CanWrite(mat, to))
            {
                mat.SetTexture(to, mat.GetTexture(from));
                return true;
            }
            return false;
        }

#endregion
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
#if UNITY_2021_2_OR_NEWER
            if (!mat.shader.keywordSpace.keywordNames.Contains(kwd))
            {
                return false;
            }
#endif
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

    class WFCustomKeywordSettingCustom : WFCustomKeywordSetting
    {
        public readonly string keyword;
        private readonly Func<Material, bool> cond;

        public WFCustomKeywordSettingCustom(string propertyName, Func<Material, bool> cond, string keyword) : base(propertyName)
        {
            this.keyword = keyword;
            this.cond = cond;
        }

        public override bool SetKeywordTo(Material mat)
        {
            return ApplyKeywordByBool(mat, keyword, cond(mat));
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
            if (string.IsNullOrWhiteSpace(label))
            {
                return null;
            }
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

        public readonly List<string> labelFamilyList = new List<string>();
        public readonly List<string> labelVariantList = new List<string>();
        public readonly List<string> labelRenderTypeList = new List<string>();

        public int idxFamily = -1;
        public int idxVariant = -1;
        public int idxRenderType = -1;

        public WFVariantList(WFShaderName current)
        {
            this.current = current;
        }
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

        private static IEnumerable<WFShaderName> GetCurrentFamillyNames(WFShaderName name)
        {
            return GetCurrentRpNames().Where(nm => nm.Familly == name.Familly);
        }

        public static WFShaderName TryFindFromName(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                return null;
            }
            return GetCurrentRpNames().Where(nm => nm.Name == name).FirstOrDefault();
        }

        public static void CreateFamilyList(WFShaderName name, WFVariantList result)
        {
            foreach(var group in GetCurrentRpNames().GroupBy(p => p.Familly))
            {
                if (name.Familly == group.First().Familly)
                {
                    // current と Familly が一致するものは current 自体を詰める
                    result.familyList.Add(name);
                    result.labelFamilyList.Add(name.Familly);
                }
                else
                {
                    // Represent が true のものがあればそれを取得、そうでなければ最初の1件を取得してリストに詰める
                    var represent = group.Where(p => p.Represent).Union(group).FirstOrDefault();
                    if (represent != null)
                    {
                        result.familyList.Add(represent);
                        result.labelFamilyList.Add(represent.Familly);
                    }
                }
            }
        }

        public static void CreateVariantList(WFShaderName name, WFVariantList result)
        {
            if (name == null)
            {
                return;
            }

            void AddToList(IEnumerable<WFShaderName> shaders)
            {
                foreach (var group in shaders.GroupBy(nm => nm.Variant))
                {
                    var snm = group.Where(nm => nm.RenderType == name.RenderType).FirstOrDefault();
                    if (snm != null)
                    {
                        // RenderTypeが一致するものを追加
                        result.variantList.Add(snm);
                        result.labelVariantList.Add(snm.Variant);
                    }
                    else
                    {
                        // RenderTypeが一致するものがない場合は、ラベルに印を付けて追加
                        var snm2 = group.OrderByDescending(nm => nm.RenderType.Length).Where(nm => name.RenderType.StartsWith(nm.RenderType)).FirstOrDefault();
                        if (snm2 != null)
                        {
                            // RenderTypeの文字数の降順に並べて先頭一致する最初のものを追加
                            result.variantList.Add(snm2);
                            result.labelVariantList.Add(snm2.Variant + " *");
                        }
                        else
                        {
                            // 一致するものがなければグループの先頭を追加
                            result.variantList.Add(group.First());
                            result.labelVariantList.Add(group.First().Variant + " *");
                        }
                    }
                }
            }

            // カスタム以外を追加
            AddToList(GetCurrentFamillyNames(name).Where(nm => !IsVariantCustomOrLegacy(nm)));

            // カスタムシェーダを追加
            var custonVariants = GetCurrentFamillyNames(name).Where(nm => IsVariantCustomOrLegacy(nm));
            if (0 < custonVariants.Count())
            {
                result.variantList.Add(null);
                result.labelVariantList.Add("");
                AddToList(custonVariants);
            }
        }

        public static void CreateRenderTypeList(WFShaderName name, WFVariantList result)
        {
            if (name == null)
            {
                return;
            }

            var listedRenderType = new List<string>();

            // Familly と Variant が一致するものの RenderType をまず追加
            foreach (var snm in GetCurrentFamillyNames(name).Where(nm => nm.Variant == name.Variant))
            {
                result.renderTypeList.Add(snm);
                listedRenderType.Add(snm.RenderType);
            }

            var tempList = new List<WFShaderName>();

            // Familly が一致するが Variant が一致しないものについて
            foreach (var group in GetCurrentFamillyNames(name).Where(nm => nm.Variant != name.Variant
                // 未追加のRenderTypeかつLegacyでもCustomでもないものをRenderTypeでグループ化
                && !listedRenderType.Contains(nm.RenderType) && !IsVariantCustomOrLegacy(nm)).GroupBy(nm => nm.RenderType))
            {
                tempList.AddRange(group);
            }

            if (0 < tempList.Count)
            {
                result.renderTypeList.Add(null);
                result.renderTypeList.AddRange(tempList);
            }

            result.labelRenderTypeList.AddRange(result.renderTypeList.Select(nm => nm == null ? "" : (nm.Variant == name.Variant ? nm.RenderType : nm.RenderType + "/" + nm.Variant)));
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

            CreateFamilyList(current, result);
            CreateVariantList(current, result);
            CreateRenderTypeList(current, result);

            result.idxFamily = result.familyList.IndexOf(current);
            result.idxVariant = result.variantList.IndexOf(current);
            result.idxRenderType = result.renderTypeList.IndexOf(current);

            return result;
        }
    }
}

#endif
