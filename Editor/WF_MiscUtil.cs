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

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using System.Text.RegularExpressions;
using UnityEngine;

namespace UnlitWF
{
    internal class ShaderMaterialProperty
    {
        public readonly Material Material;
        private readonly Shader shader;
        private readonly int index;

        ShaderMaterialProperty(Material material, Shader shader, int index) {
            this.Material = material;
            this.shader = shader;
            this.index = index;
        }

        /// <summary>
        /// プロパティの物理名
        /// </summary>
        public string Name { get { return ShaderUtil.GetPropertyName(shader, index); } }
        /// <summary>
        /// プロパティの説明文
        /// </summary>
        public string Description { get { return ShaderUtil.GetPropertyDescription(shader, index); } }
        /// <summary>
        /// プロパティの型
        /// </summary>
        public ShaderUtil.ShaderPropertyType Type { get { return ShaderUtil.GetPropertyType(shader, index); } }

        public bool CopyTo(ShaderMaterialProperty dst) {
            var srcType = Type;
            var dstType = dst.Type;
            if (srcType == dstType) {
                switch (srcType) {
                    case ShaderUtil.ShaderPropertyType.Color:
                        dst.Material.SetColor(dst.Name, this.Material.GetColor(Name));
                        return true;
                    case ShaderUtil.ShaderPropertyType.Float:
                    case ShaderUtil.ShaderPropertyType.Range:
                        dst.Material.SetFloat(dst.Name, this.Material.GetFloat(Name));
                        return true;
                    case ShaderUtil.ShaderPropertyType.Vector:
                        dst.Material.SetVector(dst.Name, this.Material.GetVector(Name));
                        return true;
                    case ShaderUtil.ShaderPropertyType.TexEnv:
                        dst.Material.SetTexture(dst.Name, this.Material.GetTexture(Name));
                        dst.Material.SetTextureOffset(dst.Name, this.Material.GetTextureOffset(Name));
                        dst.Material.SetTextureScale(dst.Name, this.Material.GetTextureScale(Name));
                        return true;
                    default:
                        break;
                }
            }
            return false;
        }

        public static List<ShaderMaterialProperty> AsList(Material material) {
            var shader = material.shader;
            int cnt = ShaderUtil.GetPropertyCount(shader);
            var result = new List<ShaderMaterialProperty>();
            for (int i = 0; i < cnt; i++) {
                result.Add(new ShaderMaterialProperty(material, shader, i));
            }
            return result;
        }

        public static Dictionary<string, ShaderMaterialProperty> AsDict(Material material) {
            var result = new Dictionary<string, ShaderMaterialProperty>();
            foreach (var p in AsList(material)) {
                result.Add(p.Name, p);
            }
            return result;
        }
    }

    internal class ShaderSerializedProperty
    {
        public readonly string name;
        public readonly ShaderMaterialProperty materialProperty;
        private readonly SerializedObject serialObject;
        private readonly SerializedProperty parent;
        private readonly SerializedProperty property;
        private readonly SerializedProperty value;

        ShaderSerializedProperty(string name, ShaderMaterialProperty matProp, SerializedObject serialObject, SerializedProperty parent, SerializedProperty property) {
            this.name = name;
            this.materialProperty = matProp;
            this.serialObject = serialObject;
            this.parent = parent;
            this.property = property;

            this.value = property.FindPropertyRelative("second");
        }

        private static string GetSerializedName(SerializedProperty p) {
            SerializedProperty first = p.FindPropertyRelative("first");
            return first != null ? first.stringValue : null;
        }

        private static SerializedProperty GetSerializedValue(SerializedProperty p) {
            return p.FindPropertyRelative("second");
        }

        public bool HasPropertyInShader
        {
            get { return materialProperty != null; }
        }

        public ShaderUtil.ShaderPropertyType Type { get { return materialProperty.Type; } }

        public string ParentName { get { return parent.name; } }

        public float FloatValue { get { return value.floatValue; } set { this.value.floatValue = value; } }
        public Color ColorValue { get { return value.colorValue; } set { this.value.colorValue = value; } }
        public Vector4 VectorValue { get { return value.vector4Value; } set { this.value.vector4Value = value; } }

        public void Rename(string newName) {
            property.FindPropertyRelative("first").stringValue = newName;
        }

        private static void TryCopyValue(SerializedProperty src, SerializedProperty dst) {
            if (src == null || dst == null) {
                return;
            }

            switch (src.propertyType) {
                case SerializedPropertyType.Generic:
                    // テクスチャ系の子をコピーする
                    TryCopyValue(src.FindPropertyRelative("m_Texture"), dst.FindPropertyRelative("m_Texture"));
                    TryCopyValue(src.FindPropertyRelative("m_Scale"), dst.FindPropertyRelative("m_Scale"));
                    TryCopyValue(src.FindPropertyRelative("m_Offset"), dst.FindPropertyRelative("m_Offset"));
                    break;
                case SerializedPropertyType.Float:
                    dst.floatValue = src.floatValue;
                    break;
                case SerializedPropertyType.Color:
                    dst.colorValue = src.colorValue;
                    break;
                case SerializedPropertyType.ObjectReference:
                    dst.objectReferenceValue = src.objectReferenceValue;
                    break;
                case SerializedPropertyType.Integer:
                    dst.intValue = src.intValue;
                    break;
                case SerializedPropertyType.Boolean:
                    dst.boolValue = src.boolValue;
                    break;
                case SerializedPropertyType.Enum:
                    dst.enumValueIndex = src.enumValueIndex;
                    break;
                case SerializedPropertyType.Vector2:
                    dst.vector2Value = src.vector2Value;
                    break;
                case SerializedPropertyType.Vector3:
                    dst.vector3Value = src.vector3Value;
                    break;
                case SerializedPropertyType.Vector4:
                    dst.vector4Value = src.vector4Value;
                    break;
                case SerializedPropertyType.Vector2Int:
                    dst.vector2IntValue = src.vector2IntValue;
                    break;
                case SerializedPropertyType.Vector3Int:
                    dst.vector3IntValue = src.vector3IntValue;
                    break;
            }
        }

        public void CopyTo(ShaderSerializedProperty other) {
            TryCopyValue(this.value, other.value);
        }

        public void Remove() {
            for (int i = parent.arraySize - 1; 0 <= i; i--) {
                var prop = parent.GetArrayElementAtIndex(i);
                if (GetSerializedName(prop) == this.name) {
                    parent.DeleteArrayElementAtIndex(i);
                }
            }
        }

        public static void AllApplyPropertyChange(IEnumerable<ShaderSerializedProperty> props) {
            foreach (var so in GetUniqueSerialObject(props)) {
                so.ApplyModifiedProperties();
            }
        }

        public static HashSet<SerializedObject> GetUniqueSerialObject(IEnumerable<ShaderSerializedProperty> props) {
            var ret = new HashSet<SerializedObject>();
            foreach (var prop in props) {
                if (prop != null && prop.serialObject != null) {
                    ret.Add(prop.serialObject);
                }
            }
            return ret;
        }

        public static Dictionary<string, ShaderSerializedProperty> AsDict(Material material) {
            var result = new Dictionary<string, ShaderSerializedProperty>();
            foreach (var prop in AsList(material)) {
                result[prop.name] = prop;
            }
            return result;
        }

        public static List<ShaderSerializedProperty> AsList(IEnumerable<Material> matlist) {
            var result = new List<ShaderSerializedProperty>();
            foreach (Material mat in matlist) {
                result.AddRange(AsList(mat));
            }
            return result;
        }

        public static List<ShaderSerializedProperty> AsList(Material material) {
            var matProps = ShaderMaterialProperty.AsDict(material);
            SerializedObject so = new SerializedObject(material);
            so.Update();
            var result = new List<ShaderSerializedProperty>();
            var m_SavedProperties = so.FindProperty("m_SavedProperties");
            if (m_SavedProperties != null) {
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_Floats"), matProps));
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_Colors"), matProps));
                result.AddRange(AsList(material, so, m_SavedProperties.FindPropertyRelative("m_TexEnvs"), matProps));
            }
            return result;
        }

        private static List<ShaderSerializedProperty> AsList(Material material, SerializedObject so, SerializedProperty parent, Dictionary<string, ShaderMaterialProperty> matProps) {
            var result = new List<ShaderSerializedProperty>();
            if (parent != null) {
                for (int i = 0; i < parent.arraySize; i++) {
                    var prop = parent.GetArrayElementAtIndex(i);
                    var name = GetSerializedName(prop);
                    if (name != null) {
                        result.Add(new ShaderSerializedProperty(name, matProps.GetValueOrNull(name), so, parent, prop));
                    }
                }
            }
            return result;
        }
    }

    internal static class CollectionUtility
    {
        public static T GetValueOrNull<K, T>(this Dictionary<K, T> dict, K key) where T : class {
            T value;
            if (dict.TryGetValue(key, out value)) {
                return value;
            }
            return null;
        }
    }

    internal class WeakRefCache<T> where T : class
    {
        private readonly List<WeakReference> refs = new List<WeakReference>();

        public bool Contains(T target) {
            lock (refs) {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 参照が存在しているならばtrue
                foreach (var r in refs) {
                    if (r.Target == target) {
                        return true;
                    }
                }
                return false;
            }
        }

        public void Add(T target) {
            lock (refs) {
                if (Contains(target)) {
                    return;
                }
                refs.Add(new WeakReference(target));
            }
        }

        public void Remove(T target) {
            RemoveAll(target);
        }

        public void RemoveAll(params object[] targets) {
            lock (refs) {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 一致しているものを全て削除
                refs.RemoveAll(r => {
                    var tgt = r.Target as T;
                    return tgt != null && targets.Contains(tgt);
                });
            }
        }
    }

}

#endif
