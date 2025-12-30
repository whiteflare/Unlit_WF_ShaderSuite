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

#if UNITY_EDITOR

using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace UnlitWF
{

    class WF_DebugViewEditor : ShaderGUI
    {
        public const string SHADER_NAME_DEBUGVIEW = "UnlitWF/Debug/WF_DebugView";

        public const string TAG_PREV_SHADER = "PrevShader";
        public const string TAG_PREV_QUEUE = "PrevQueue";

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            PreChangeShader(material, oldShader, newShader);

            // newShaderの割り当て
            var oldMat = new Material(material);
            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            PostChangeShader(oldMat, material, oldShader, newShader);
        }

        public static void PreChangeShader(Material material, Shader oldShader, Shader newShader)
        {
            // 古いシェーダ名の保存に OverrideTag を利用する
            if (material != null && oldShader != null && !IsSupportedShader(oldShader))
            {
                material.SetOverrideTag(TAG_PREV_SHADER, oldShader.name);
                material.SetOverrideTag(TAG_PREV_QUEUE, WFAccessor.GetMaterialRenderQueueValue(material).ToString());
            }
        }

        public static void PostChangeShader(Material oldMat, Material material, Shader oldShader, Shader newShader)
        {
            // nop
        }

        public static bool IsSupportedShader(Shader shader)
        {
            return WFCommonUtility.IsSupportedShader(shader) && shader.name.Contains("WF_DebugView");
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            materialEditor.SetDefaultGUIWidths();

            // 元シェーダに戻すボタン
            OnGuiSub_SwitchPrevShaderButton(materialEditor);

            var mat = WFCommonUtility.GetCurrentMaterial(materialEditor);
            var mats = WFCommonUtility.GetCurrentMaterials(materialEditor);

            // モード変更メニュー表示
            foreach (var section in sections)
            {
                GUI.Label(EditorGUI.IndentedRect(EditorGUILayout.GetControlRect()), section.name, EditorStyles.boldLabel);
                foreach (var mode in section.modes)
                {
                    bool active = mode.IsActive(mat);
                    EditorGUI.showMixedValue = mode.IsMixedValue(mats);
                    EditorGUI.BeginChangeCheck();
                    active = EditorGUILayout.Toggle(mode.displayName, active);
                    if (EditorGUI.EndChangeCheck())
                    {
                        mode.SetActive(mats);
                    }
                    EditorGUI.showMixedValue = false;
                }
                EditorGUILayout.Space();
            }

            // モード変更以外のプロパティを表示
            foreach (var p in properties)
            {
                if (!p.name.StartsWith("_Mode"))
                {
                    if (p.flags.HasFlag(MaterialProperty.PropFlags.HideInInspector))
                    {
                        continue;
                    }
                    materialEditor.ShaderProperty(p, p.displayName);
                }
            }
            EditorGUILayout.Space();

            GUI.Label(EditorGUI.IndentedRect(EditorGUILayout.GetControlRect()), "Advanced Options", EditorStyles.boldLabel);
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
            materialEditor.DoubleSidedGIField();
            EditorGUILayout.Space();

            // 一番下にも、元シェーダに戻すボタンを置く
            OnGuiSub_SwitchPrevShaderButton(materialEditor);
        }

        private static void OnGuiSub_SwitchPrevShaderButton(MaterialEditor materialEditor)
        {
            // 編集中のマテリアルの配列
            var mats = WFCommonUtility.GetCurrentMaterials(materialEditor);

            // PrevShader タグを持っているものがひとつでもあればボタン表示
            if (mats.Select(m => m.GetTag(TAG_PREV_SHADER, false)).Any(tag => !string.IsNullOrWhiteSpace(tag)))
            {

                if (GUI.Button(EditorGUI.IndentedRect(EditorGUILayout.GetControlRect()), "Switch Prev Shader"))
                {
                    // 元のシェーダに戻す
                    Undo.RecordObjects(mats, "change shader");
                    // それぞれのマテリアルに設定された PrevShader へと切り替え
                    foreach (var mat in mats)
                    {
                        var name = mat.GetTag(TAG_PREV_SHADER, false);
                        var queue = mat.GetTag(TAG_PREV_QUEUE, false);
                        // DebugViewの保存に使っているタグはクリア
                        ClearDebugOverrideTag(mat);
                        // シェーダ切り替え
                        WFCommonUtility.ChangeShader(name, mat);
                        // queue戻し
                        if (queue != null && int.TryParse(queue, out int numQueue))
                        {
                            mat.renderQueue = numQueue;
                        }
                    }
                }
                EditorGUILayout.Space();
            }
        }

        public static void ClearDebugOverrideTag(Material mat)
        {
            if (mat != null)
            {
                mat.SetOverrideTag(TAG_PREV_SHADER, "");
                mat.SetOverrideTag(TAG_PREV_QUEUE, "");
            }
        }

        private readonly List<DebugModeSection> sections = new List<DebugModeSection>() {
            new DebugModeSection("Fill Color", new List<DebugMode>(){
                new DebugMode("White", "_ModeColor", 1),
                new DebugMode("Black", "_ModeColor", 2),
                new DebugMode("Magenta", "_ModeColor", 3),
                new DebugMode("Transparent", "_ModeColor", 4),
            }),
            new DebugModeSection("Model Visualization", new List<DebugMode>(){
                new DebugMode("Vertex Color", "_ModeColor", 5),
                new DebugMode("Facing", "_ModeColor", 6),
                new DebugMode("Facing (Lightmapped Only)", "_ModeColor", 7),
            }),
            new DebugModeSection("UV Visualization", new List<DebugMode>(){
                new DebugMode("UV1", "_ModeUV", 1),
                new DebugMode("UV2", "_ModeUV", 2),
                new DebugMode("UV3", "_ModeUV", 3),
                new DebugMode("UV4", "_ModeUV", 4),
                new DebugMode("Lightmap UV", "_ModeUV", 5),
                new DebugMode("Dynamic Lightmap UV", "_ModeUV", 6),
            }),
            new DebugModeSection("Normal Visualization (LocalSpace)", new List<DebugMode>(){
                new DebugMode("Normal", "_ModeNormal", 1),
                new DebugMode("Tangent", "_ModeNormal", 2),
                new DebugMode("BiTangent", "_ModeNormal", 3),
            }),
            new DebugModeSection("Normal Visualization (WorldSpace)", new List<DebugMode>(){
                new DebugMode("Normal", "_ModeNormal", 4),
                new DebugMode("Tangent", "_ModeNormal", 5),
                new DebugMode("BiTangent", "_ModeNormal", 6),
            }),
            new DebugModeSection("Texture Visualization", new List<DebugMode>(){
                new DebugMode("_MainTex", "_ModeTexture", 1),
                new DebugMode("_MetallicGlossMap", "_ModeTexture", 2),
                new DebugMode("_SpecGlossMap", "_ModeTexture", 3),
                new DebugMode("_BumpMap", "_ModeTexture", 4),
                new DebugMode("_OcclusionMap", "_ModeTexture", 5),
                new DebugMode("_EmissionMap", "_ModeTexture", 6),
            }),
            new DebugModeSection("LightMap Visualization", new List<DebugMode>(){
                new DebugMode("Lightmap", "_ModeLightMap", 1),
                new DebugMode("Dynamic Lightmap", "_ModeLightMap", 2),
            }),
        };

        class DebugModeSection
        {
            public readonly string name;
            public readonly List<DebugMode> modes;

            public DebugModeSection(string name, List<DebugMode> listMode)
            {
                this.name = name;
                this.modes = listMode;
            }
        }

        class DebugMode
        {
            public readonly string displayName;
            public readonly string propertyName;
            public readonly int value;

            public DebugMode(string displayName, string propertyName, int value)
            {
                this.displayName = displayName;
                this.propertyName = propertyName;
                this.value = value;
            }

            public bool IsActive(Material mat)
            {
                return mat != null && mat.HasProperty(propertyName) && mat.GetInt(propertyName) == value;
            }

            public bool IsMixedValue(Material[] targets)
            {
                return WFCommonUtility.AsMaterials(targets).Select(mat => IsActive(mat)).Distinct().Count() == 2;
            }

            public void SetActive(Material[] targets)
            {
                foreach (var mat in WFCommonUtility.AsMaterials(targets))
                {
                    // リセット
                    foreach (var p in ShaderMaterialProperty.AsList(mat).Where(p => p.Name.StartsWith("_Mode")))
                    {
                        mat.SetInt(p.Name, 0);
                    }
                    // セット
                    mat.SetInt(propertyName, value);
                }
            }
        }
    }
}

#endif
