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

using UnityEditor;
using UnityEngine;

namespace UnlitWF.MA
{
    [CustomEditor(typeof(UnlitWFShaderMenuGenerator))]
    public class UnlitWFShaderMenuGeneratorEditor : Editor
    {
        private SerializedProperty menuName;

        public void OnEnable()
        {
            menuName = serializedObject.FindProperty("menuName");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            var component = target as UnlitWFShaderMenuGenerator;
            if (component == null)
            {
                return;
            }
            EditorGUILayout.HelpBox("UnlitWF マテリアルを使用している場合、Exメニューに項目が追加されます", MessageType.Info);

            EditorGUILayout.PropertyField(menuName);

            serializedObject.ApplyModifiedProperties();
        }

#if ENV_VRCSDK3_AVATAR && ENV_MA
        [MenuItem(WFMenu.GAMEOBJECT_AVATARMENU, priority = 11)] // GameObject/配下は priority の扱いがちょっと特殊
        private static void Generate_GameObject(MenuCommand menuCommand)
        {
            var go = menuCommand.context as GameObject;
            if (go != null)
            {
                var desc = go.GetComponentInParent<VRC.SDKBase.VRC_AvatarDescriptor>(true);
                if (desc != null)
                {
                    var menuGo = new GameObject();
                    menuGo.name = "UnlitWF Menu";
                    menuGo.transform.parent = desc.transform;
                    menuGo.AddComponent<UnlitWFShaderMenuGenerator>();
                    Undo.RegisterCreatedObjectUndo(menuGo, "Generate UnlitWF Avatar Menu Component");
                }
            }
        }
#endif
    }
}

#endif
