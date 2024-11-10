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

#if UNITY_EDITOR && ENV_VRCSDK3_AVATAR && ENV_MA

using System.Collections.Generic;
using System.Linq;
using UnityEditor.Animations;
using UnityEditor;
using UnityEngine;
using VRC.SDK3.Avatars.Components;
using nadena.dev.modular_avatar.core;
using nadena.dev.ndmf;
using static VRC.SDK3.Avatars.ScriptableObjects.VRCExpressionsMenu.Control;

[assembly: ExportsPlugin(typeof(UnlitWF.MA.UnlitWFShaderMenuGeneratorNdmfPlugin))]

namespace UnlitWF.MA
{
    public class UnlitWFShaderMenuGeneratorNdmfPlugin : Plugin<UnlitWFShaderMenuGeneratorNdmfPlugin>
    {
        private const string PN_LitMin = "WF_LitBright";
        private const string PN_LitOverride = "WF_LitOverride";
        private const string PN_LitDirection = "WF_LitDirection";
        private const string PN_BackLit = "WF_BackLit";

        public override string QualifiedName => "jp.whiteflare.unlitwf.menugen";

        public override string DisplayName => "UnlitWF MenuGenerator";

        protected override void Configure()
        {
            InPhase(BuildPhase.Generating).Run("GenerateMenu", GenerateMenu);
            InPhase(BuildPhase.Transforming).Run("GenerateAnimation", GenerateAnimation);
        }

        private void GenerateMenu(BuildContext ctx)
        {
            var avatarRoot = ctx.AvatarRootObject;
            if (avatarRoot == null)
            {
                return;
            }
            var component = (UnlitWFShaderMenuGenerator) null;
            foreach(var c in avatarRoot.GetComponentsInChildren<UnlitWFShaderMenuGenerator>(true))
            {
                if (c.enabled && c.gameObject.activeInHierarchy)
                {
                    if (component == null)
                    {
                        component = c;
                        continue;
                    }
                }
                Object.DestroyImmediate(c); // ひとつを残して他は削除
            }
            if (component == null)
            {
                return;
            }

            var mats = new MaterialSeeker().GetAllMaterials(avatarRoot).ToArray();
            component.generateLitMin = mats.Any(PredHasProperty("_GL_LevelTweak"));
            component.generateLitDirection = mats.Any(PredHasProperty("_GL_CustomAzimuth"));
            component.generateLitOverride = mats.Any(PredHasProperty("_GL_LitOverride"));
            component.generateBackLit = mats.Any(PredFuncEnable("_TBL_Enable"));

            if (!AnyGenerate(component))
            {
                return;
            }

            var goMenuRoot = CreateSubGameObject(avatarRoot, "UnlitWF MenuRoot");
            goMenuRoot.AddComponent<ModularAvatarMenuInstaller>();
            goMenuRoot.AddComponent<ModularAvatarMenuGroup>();
            var pa = goMenuRoot.AddComponent<ModularAvatarParameters>();

            var menuName = component.menuName;
            if (string.IsNullOrWhiteSpace(menuName))
            {
                menuName = "UnlitWF";
            }

            var goMenuUnlitWF = CreateSubGameObject(goMenuRoot, menuName);
            {
                var mi = goMenuUnlitWF.AddComponent<ModularAvatarMenuItem>();
                mi.Control.type = ControlType.SubMenu;
                mi.MenuSource = SubmenuSource.Children;
            }

            var lang = WFEditorPrefs.LangMode;
            if (component.generateLitMin)
            {
                var text = lang == EditorLanguage.日本語 ? "ライト明度" : "Lit Brightness";
                AddMenuItem(goMenuUnlitWF, text, pa, PN_LitMin, ParameterSyncType.Float, ControlType.RadialPuppet, 0.5f);
            }
            if (component.generateLitDirection)
            {
                var text = lang == EditorLanguage.日本語 ? "ライト方向" : "Lit Direction";
                AddMenuItem(goMenuUnlitWF, text, pa, PN_LitDirection, ParameterSyncType.Float, ControlType.RadialPuppet, 0.5f);
            }
            if (component.generateLitOverride)
            {
                var text = lang == EditorLanguage.日本語 ? "ライト無視" : "Lit Override";
                AddMenuItem(goMenuUnlitWF, text, pa, PN_LitOverride, ParameterSyncType.Bool, ControlType.Toggle, 0f);
            }
            if (component.generateBackLit)
            {
                var text = lang == EditorLanguage.日本語 ? "逆光ライト" : "BackLit";
                AddMenuItem(goMenuUnlitWF, text, pa, PN_BackLit, ParameterSyncType.Float, ControlType.RadialPuppet, 0f);
            }
        }

        private bool AnyGenerate(UnlitWFShaderMenuGenerator component)
        {
            return component.generateLitMin || component.generateLitDirection || component.generateLitOverride || component.generateBackLit;
        }

        private GameObject CreateSubGameObject(GameObject root, string name)
        {
            var go = new GameObject(name);
            go.transform.parent = root.transform;
            return go;
        }

        private System.Func<Material, bool> PredHasProperty(string shaderPropName)
        {
            return mat => WFCommonUtility.IsSupportedShader(mat) && mat.HasProperty(shaderPropName);
        }

        private System.Func<Material, bool> PredFuncEnable(string shaderPropName)
        {
            return mat => WFCommonUtility.IsSupportedShader(mat) && WFAccessor.GetBool(mat, shaderPropName, false);
        }

        private void AddMenuItem(GameObject parent, string name, ModularAvatarParameters param, string paramName, ParameterSyncType paramType, ControlType controlType, float defaultValue)
        {
            var go = CreateSubGameObject(parent, name);
            var mi = go.AddComponent<ModularAvatarMenuItem>();
            mi.Control.type = controlType;
            if (controlType != ControlType.RadialPuppet)
            {
                mi.Control.parameter = new Parameter()
                {
                    name = paramName
                };
            }
            else
            {
                mi.Control.subParameters = new Parameter[] {
                    new Parameter() {
                        name = paramName
                    }
                };
            }
            param.parameters.Add(new ParameterConfig()
            {
                nameOrPrefix = paramName,
                syncType = paramType,
                defaultValue = defaultValue,
            });
        }

        private void GenerateAnimation(BuildContext ctx)
        {
            var avatarRoot = ctx.AvatarRootObject;
            var component = avatarRoot?.GetComponentInChildren<UnlitWFShaderMenuGenerator>();
            try
            {
                if (component == null || !component.enabled)
                {
                    return;
                }
                if (!AnyGenerate(component))
                {
                    return;
                }

                var descriptor = ctx.AvatarDescriptor;
                if (descriptor == null)
                {
                    return;
                }

                var fx = descriptor.baseAnimationLayers.Where(ly => ly.type == VRCAvatarDescriptor.AnimLayerType.FX).FirstOrDefault();
                var animator = fx.animatorController as AnimatorController;
                if (fx.type != VRCAvatarDescriptor.AnimLayerType.FX || animator == null)
                {
                    return;
                }

                var renderers = new List<Renderer>();
                renderers.AddRange(avatarRoot.GetComponentsInChildren<SkinnedMeshRenderer>(true));
                renderers.AddRange(avatarRoot.GetComponentsInChildren<MeshRenderer>(true));

                var states = animator.layers.Where(ly => ly != null).SelectMany(ly => IterStateMachines(ly.stateMachine)).SelectMany(sm => sm.states).Select(ch => ch.state).Distinct().ToArray();
                var WD = states.Length / 2 < states.Where(st => st != null && st.writeDefaultValues).Count();

                if (component.generateLitMin)
                {
                    AddParameterIfAbsent(animator, PN_LitMin);
                    AddAnimatorLayer(animator, "WF_Menu_LitBright", CreateAnimationClip(avatarRoot.transform, renderers, "_GL_LevelTweak", -1, 1, PredHasProperty("_GL_LevelTweak")), PN_LitMin, WD);
                }
                if (component.generateLitDirection)
                {
                    AddParameterIfAbsent(animator, PN_LitDirection);
                    AddAnimatorLayer(animator, "WF_Menu_LitDirection", CreateAnimationClip(avatarRoot.transform, renderers, "_GL_CustomAzimuth", 0, 360, PredHasProperty("_GL_CustomAzimuth")), PN_LitDirection, WD);
                }
                if (component.generateLitOverride)
                {
                    AddParameterIfAbsent(animator, PN_LitOverride);
                    AddAnimatorLayer(animator, "WF_Menu_LitOverride", CreateAnimationClip(avatarRoot.transform, renderers, "_GL_LitOverride", 0, 1, PredHasProperty("_GL_LitOverride")), PN_LitOverride, WD);
                }
                if (component.generateBackLit)
                {
                    AddParameterIfAbsent(animator, PN_BackLit);
                    AddAnimatorLayer(animator, "WF_Menu_BackLit", CreateAnimationClip(avatarRoot.transform, renderers, "_TBL_Power", 0, 1, PredFuncEnable("_TBL_Enable")), PN_BackLit, WD);
                }
            }
            finally
            {
                if (component != null)
                {
                    Object.DestroyImmediate(component);
                }
            }
        }

        private IEnumerable<AnimatorStateMachine> IterStateMachines(AnimatorStateMachine stateMachine)
        {
            if (stateMachine != null)
            {
                yield return stateMachine;
                foreach(var c in stateMachine.stateMachines.SelectMany(c => IterStateMachines(c.stateMachine)))
                {
                    yield return c;
                }
            }
        }

        private AnimatorControllerParameter AddParameterIfAbsent(AnimatorController animator, string paramName)
        {
            var param = animator.parameters.Where(p => p.name == paramName).FirstOrDefault();
            if (param == null) {
                param = new AnimatorControllerParameter()
                {
                    name = paramName,
                    type = AnimatorControllerParameterType.Float,
                };
                animator.AddParameter(param);
            }
            return param;
        }

        private void AddAnimatorLayer(AnimatorController animator, string layerName, AnimationClip clip, string paramName, bool wd)
        {
            var layer = new AnimatorControllerLayer()
            {
                name = layerName,
                defaultWeight = 1.0f,
                stateMachine = new AnimatorStateMachine()
                {
                    name = layerName,
                    hideFlags = HideFlags.HideInHierarchy,
                },
            };

            var state = layer.stateMachine.AddState(paramName);
            state.motion = clip;
            state.timeParameterActive = true;
            state.timeParameter = paramName;
            state.writeDefaultValues = wd;

            animator.AddLayer(layer);
            AssetDatabase.AddObjectToAsset(layer.stateMachine, animator);
        }

        private AnimationClip CreateAnimationClip(Transform root, IEnumerable<Renderer> targets, string shaderParamName, float start, float end, System.Func<Material, bool> pred)
        {
            var clip = new AnimationClip();
            clip.name = shaderParamName;

            foreach(var r in targets)
            {
                if (r.materials.Any(pred))
                {
                    var path = AnimationUtility.CalculateTransformPath(r.transform, root);
                    var binding = EditorCurveBinding.FloatCurve(path, r.GetType(), "material." + shaderParamName);
                    var curve = AnimationCurve.Linear(0f, start, 1f, end);
                    AnimationUtility.SetEditorCurve(clip, binding, curve);
                }
            }

            return clip;
        }
    }
}

#endif
