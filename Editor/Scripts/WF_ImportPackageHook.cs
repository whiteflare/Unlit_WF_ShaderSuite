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
using System.Collections.Generic;
using UnityEditor;

namespace UnlitWF
{
    class WF_ImportPackageHook
    {
        [InitializeOnLoadMethod]
        static void Init()
        {
            AssetDatabase.importPackageStarted -= ImportPackageStarted;
            AssetDatabase.importPackageStarted += ImportPackageStarted;
        }

        private static void ImportPackageStarted(string packageName)
        {
            if (!WFCommonUtility.IsManagedUPM())
            {
                return;
            }
            if (packageName != null && packageName.StartsWith("UnlitWF_", StringComparison.InvariantCultureIgnoreCase))
            {
                // UPM管理のときはunitypackageからのUnlitWFインポートを阻止する
                var msg = WFI18N.Translate(WFMessageText.DgDontImportUnityPackage);
                EditorUtility.DisplayDialog(WFCommonUtility.DialogTitle, msg, "OK");
                CoroutineHandler.StartStaticCoroutine(ClosePackageImportWindow());
            }
        }

        private static IEnumerator<object> ClosePackageImportWindow()
        {
            var sw = new System.Diagnostics.Stopwatch();
            sw.Start();
            while (sw.ElapsedMilliseconds < 10000)
            {
                var window = EditorWindow.focusedWindow;
                if (window != null && window.GetType().FullName == "UnityEditor.PackageImport")
                {
                    window.Close();
                    break;
                }
                yield return null;
            }
        }
    }
}

#endif
