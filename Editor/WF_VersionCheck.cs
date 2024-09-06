/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2024 whiteflare.
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

#if UNITY_EDITOR

using System;
using System.Collections;
using UnityEditor;
using UnityEngine;
using UnityEngine.Networking;

namespace UnlitWF
{
    class WF_VersionCheck
    {
        private const string URI_HEAD = @"https://github.com/whiteflare/Unlit_WF_ShaderSuite";

        /// <summary>
        /// バージョンチェック用JSONファイルのURI
        /// </summary>
        private const string URI_VERSION_JSON = URI_HEAD + "/raw/master/version.json";
        /// <summary>
        /// ローカルテスト用JSONデータ。テストが終わったらnullにする。
        /// </summary>
        private const string localTestData = null; // @"{ ""latestVersion"": ""2021/01/20"", ""downloadPage"": ""/releases/tag/Unlit_WF_ShaderSuite_20210120"" }";

        [InitializeOnLoadMethod]
        private static void Initialize()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                return;
            }
            CoroutineHandler.StartStaticCoroutine(Execute());
        }

        private static IEnumerator Execute()
        {
            string rawText = localTestData;

            if (string.IsNullOrWhiteSpace(rawText))
            {
                using (UnityWebRequest req = UnityWebRequest.Get(URI_VERSION_JSON))
                {
                    yield return req.SendWebRequest();

#if UNITY_2020_1_OR_NEWER
                    if (req.result == UnityWebRequest.Result.ProtocolError || req.result == UnityWebRequest.Result.ConnectionError)
#else
                    if (req.isHttpError || req.isNetworkError)
#endif
                    {
                        Debug.LogWarningFormat("[WF][Version] An NetworkError was occured in version checking: {0}", req.error);
                        yield break;
                    }
                    rawText = req.downloadHandler.text;
                }
            }
            if (string.IsNullOrWhiteSpace(rawText))
            {
                yield break;
            }

            var version = new WFVersionInfo();
            EditorJsonUtility.FromJsonOverwrite(rawText, version);

            if (version.HasValue())
            {
                version.downloadPage = URI_HEAD + version.downloadPage;
                WFCommonUtility.SetLatestVersion(version);
                Debug.LogFormat("[WF][Version] VersionCheck Succeed, LatestVersion is {0}", version.latestVersion);
            }
        }
    }
}

#endif
