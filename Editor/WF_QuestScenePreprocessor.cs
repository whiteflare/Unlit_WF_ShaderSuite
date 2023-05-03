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
            if (!WFCommonUtility.IsQuestPlatform())
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
