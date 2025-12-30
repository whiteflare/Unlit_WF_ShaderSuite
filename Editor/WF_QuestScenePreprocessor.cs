/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2026 whiteflare.
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
using UnityEngine;
using UnityEditor;
using UnityEditor.Build;
using UnityEngine.SceneManagement;
using UnityEditor.Build.Reporting;

namespace UnlitWF
{
#if UNITY_2019_1_OR_NEWER

    class WF_QuestScenePreprocessor : IProcessSceneWithReport
    {
        public int callbackOrder => 90;

        public void OnProcessScene(Scene scene, BuildReport report)
        {
#if !ENV_VRCSDK3_AVATAR
            // もしAvatarのときはここに来ても何もしない(再生ボタンを押したときに発生する)
            ReplaceQuestSupportShader(scene);
#endif
        }

        private void ReplaceQuestSupportShader(Scene scene)
        {
            if (!WFCommonUtility.IsMobilePlatform())
            {
                return;
            }
            if (!WFEditorSetting.GetOneOfSettings().autoSwitchQuestShader)
            {
                return;
            }

            // シーン内からMobile非対応のWFマテリアルを全て検索する
            var allUnmobileMaterials = new MaterialSeeker().GetAllMaterials(scene).Distinct()
                .Where(mat => WFCommonUtility.IsSupportedShader(mat.shader) && !WFCommonUtility.IsMobileSupportedShader(mat.shader))
                .ToArray();
            if (allUnmobileMaterials.Length == 0)
            {
                return;
            }

            // マテリアルを複製してモバイルに変換する
            var allMobiledMaterials = allUnmobileMaterials.Select(mat => new Material(mat)).ToArray();
            var cnt = new Converter.WFMaterialToMobileShaderConverter().ExecAutoConvertWithoutUndo(allMobiledMaterials);
            if (cnt <= 0)
            {
                return;
            }

            // シーン内のマテリアルを差し替える
            foreach (var go in scene.GetRootGameObjects())
            {
                foreach (var renderer in go.GetComponentsInChildren<Renderer>(true))
                {
                    var mats = renderer.sharedMaterials;
                    Replace(allUnmobileMaterials, allMobiledMaterials, mats);
                    renderer.sharedMaterials = mats;
                }

                foreach (var renderer in go.GetComponentsInChildren<ParticleSystemRenderer>(true))
                {
                    renderer.trailMaterial = Replace(allUnmobileMaterials, allMobiledMaterials, renderer.trailMaterial);
                }

                foreach (var projector in go.GetComponentsInChildren<Projector>(true))
                {
                    projector.material = Replace(allUnmobileMaterials, allMobiledMaterials, projector.material);
                }

#if ENV_VRCSDK3_WORLD
                foreach (var desc in go.GetComponentsInChildren<VRC.SDK3.Components.VRCSceneDescriptor>(true))
                {
                    Replace(allUnmobileMaterials, allMobiledMaterials, desc.DynamicMaterials);
                }
#endif
            }
        }

        private static void Replace(Material[] before, Material[] after, List<Material> list)
        {
            for (int i = 0; i < list.Count; i++)
            {
                list[i] = Replace(before, after, list[i]);
            }
        }

        private static void Replace(Material[] before, Material[] after, Material[] array)
        {
            for (int i = 0; i < array.Length; i++)
            {
                array[i] = Replace(before, after, array[i]);
            }
        }

        private static Material Replace(Material[] before, Material[] after, Material mat)
        {
            if (mat != null)
            {
                int length = System.Math.Min(before.Length, after.Length);
                for (int i = 0; i < length; i++)
                {
                    if (before[i] == mat)
                    {
                        return after[i];
                    }
                }
            }
            return mat;
        }
    }

#endif
}
