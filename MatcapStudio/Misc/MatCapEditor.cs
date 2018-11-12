#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;

public class MatCapEditor {

    [MenuItem("Tools/Shader_UnlitWF/Create MatCap 128x128")]
    public static void CreateMatCap128() {
        CreateMatCap(128);
    }

    [MenuItem("Tools/Shader_UnlitWF/Create MatCap 256x256")]
    public static void CreateMatCap256() {
        CreateMatCap(256);
    }

    [MenuItem("Tools/Shader_UnlitWF/Create MatCap 512x512")]
    public static void CreateMatCap512() {
        CreateMatCap(512);
    }

    private static void CreateMatCap(int px) {
        var cmgo = GameObject.FindGameObjectWithTag("MainCamera");
        if (cmgo == null) {
            return;
        }
        var camera = cmgo.GetComponent<Camera>();
        if (camera == null) {
            return;
        }

        var rt = RenderTexture.GetTemporary(px, px);
        var oldTex = camera.targetTexture;
        var oldRt = RenderTexture.active;
        try {
            camera.targetTexture = rt;
            camera.Render();

            RenderTexture.active = rt;
            var texture = new Texture2D(px, px, TextureFormat.RGB24, false);
            texture.ReadPixels(new Rect(0, 0, px, px), 0, 0);
            texture.Apply();

            var path = EditorUtility.SaveFilePanel("Save", "Assets", "matcap", "png");
            if (string.IsNullOrEmpty(path)) {
                return;
            }

            System.IO.File.WriteAllBytes(path, texture.EncodeToPNG());
            AssetDatabase.Refresh();
            Debug.Log(string.Format("MatCapEditor: save png {0}", path));

        } finally {
            RenderTexture.active = oldRt;
            camera.targetTexture = oldTex;
            RenderTexture.ReleaseTemporary(rt);
        }
    }
}

#endif
