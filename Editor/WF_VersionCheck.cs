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

using System.Collections;
using UnityEditor;
using UnityEngine;
using UnityEngine.Networking;

namespace UnlitWF
{
    public class WF_VersionCheck
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

                    if (req.isHttpError || req.isNetworkError)
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

    public class CoroutineHandler : MonoBehaviour
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

        static public Coroutine StartStaticCoroutine(IEnumerator coroutine)
        {
            return instance.StartCoroutine(coroutine);
        }
    }
}

#endif
