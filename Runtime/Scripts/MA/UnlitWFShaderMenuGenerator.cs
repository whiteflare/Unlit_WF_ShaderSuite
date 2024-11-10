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

using UnityEngine;

namespace UnlitWF.MA
{
    [DisallowMultipleComponent]
    public class UnlitWFShaderMenuGenerator : MonoBehaviour
#if ENV_VRCSDK3_AVATAR
        , VRC.SDKBase.IEditorOnly
#endif
    {
        public string menuName = "UnlitWF";

        [System.NonSerialized] public bool generateLitMin = false;
        [System.NonSerialized] public bool generateLitDirection = false;
        [System.NonSerialized] public bool generateLitOverride = false;
        [System.NonSerialized] public bool generateBackLit = false;

        private void OnEnable()
        {
            // これ入れておくとInspectorに有効無効のチェックボックスが追加される
        }
    }
}
