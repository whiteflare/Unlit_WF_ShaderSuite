using System.Collections.Generic;
using UnityEngine;

/*
 *  The MIT License
 *
 *  Copyright 2018-2020 whiteflare.
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

using System.Linq;
using UnityEditor;

namespace UnlitWF
{

    public class WF_DebugViewEditor : ShaderGUI
    {
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
            materialEditor.SetDefaultGUIWidths();

            var mat = materialEditor.target as Material;

            // モード変更メニュー表示
            foreach (var section in sections) {
                GUI.Label(EditorGUI.IndentedRect(EditorGUILayout.GetControlRect()), section.name, EditorStyles.boldLabel);
                foreach (var mode in section.modes) {
                    bool active = mode.IsActive(mat);
                    EditorGUI.BeginChangeCheck();
                    active = EditorGUILayout.Toggle(mode.displayName, active);
                    if (EditorGUI.EndChangeCheck()) {
                        mode.SetActive(mat);
                    }
                }
                EditorGUILayout.Space();
            }

            // モード変更以外のプロパティを表示
            foreach (var p in properties) {
                if (!p.name.StartsWith("_Mode")) {
                    materialEditor.ShaderProperty(p, p.displayName);
                }
            }
            EditorGUILayout.Space();

            GUI.Label(EditorGUI.IndentedRect(EditorGUILayout.GetControlRect()), "Advanced Options", EditorStyles.boldLabel);
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
        }

        private readonly List<DebugModeSection> sections = new List<DebugModeSection>() {
            new DebugModeSection("Fill Color", new List<DebugMode>(){
                new DebugMode("White", "_ModeColor", 1),
                new DebugMode("Black", "_ModeColor", 2),
                new DebugMode("Magenta", "_ModeColor", 3),
                new DebugMode("Discard", "_ModeColor", 4),
                new DebugMode("Vertex Color", "_ModeColor", 5),
            }),
            new DebugModeSection("Show Positions", new List<DebugMode>(){
                new DebugMode("Local space", "_ModePos", 1),
                new DebugMode("World space", "_ModePos", 2),
            }),
            new DebugModeSection("Show UVs", new List<DebugMode>(){
                new DebugMode("UV1", "_ModeUV", 1),
                new DebugMode("UV2", "_ModeUV", 2),
                new DebugMode("UV3", "_ModeUV", 3),
                new DebugMode("UV4", "_ModeUV", 4),
                new DebugMode("Lightmap UV", "_ModeUV", 5),
                new DebugMode("Dynamic Lightmap UV", "_ModeUV", 6),
            }),
            new DebugModeSection("Show Normals", new List<DebugMode>(){
                new DebugMode("Normal", "_ModeNormal", 1),
                new DebugMode("Tangent", "_ModeNormal", 2),
            }),
            new DebugModeSection("Show Lightings", new List<DebugMode>(){
                new DebugMode("Light 0", "_ModeLight", 1),
                new DebugMode("Light 1-4", "_ModeLight", 2),
                new DebugMode("ShadeSH9", "_ModeLight", 3),
            }),
            new DebugModeSection("Show LightMaps", new List<DebugMode>(){
                new DebugMode("Lightmap", "_ModeLightMap", 1),
                new DebugMode("Dynamic Lightmap", "_ModeLightMap", 2),
            }),
            new DebugModeSection("Show SpecCubes", new List<DebugMode>(){
                new DebugMode("SpecCube0", "_ModeSpecCube", 1),
                new DebugMode("SpecCube1", "_ModeSpecCube", 2),
            }),
        };

        class DebugModeSection
        {
            public readonly string name;
            public readonly List<DebugMode> modes;

            public DebugModeSection(string name, List<DebugMode> listMode) {
                this.name = name;
                this.modes = listMode;
            }
        }

        class DebugMode
        {
            public readonly string displayName;
            public readonly string propertyName;
            public readonly int value;

            public DebugMode(string displayName, string propertyName, int value) {
                this.displayName = displayName;
                this.propertyName = propertyName;
                this.value = value;
            }

            public bool IsActive(Material mat) {
                return mat != null && mat.HasProperty(propertyName) && mat.GetInt(propertyName) == value;
            }

            public void SetActive(Material mat) {
                if (mat != null) {
                    // リセット
                    foreach (var p in ShaderMaterialProperty.AsList(mat).Where(p => p.Name.StartsWith("_Mode"))) {
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
