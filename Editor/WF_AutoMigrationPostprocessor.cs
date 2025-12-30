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

/*
 * NOTE: もしインポート時にダイアログを表示させたくない場合、このcsファイルを削除してください。
 * If you do not want the dialog to appear on import, delete this cs file.
 */

#if UNITY_EDITOR

using UnityEditor;

namespace UnlitWF
{
    /// <summary>
    /// マテリアルとシェーダが新規インポートされたタイミングでプロジェクト内をスキャンしてマテリアルをマイグレーションするAssetPostprocessor
    /// </summary>
    class WF_AutoMigrationPostprocessor : AssetPostprocessor
    {
        public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromPath)
        {
            // マテリアルのマイグレーション
            Converter.ScanAndMigrationExecutor.ExecuteMigrationWhenImportMaterial(importedAssets);

            // もしshaderファイルがimportされたなら、そのタイミングで全スキャンも動作させる
            if (WFCommonUtility.IsSupportedShaderPath(importedAssets))
            {
                EditorApplication.delayCall += Converter.ScanAndMigrationExecutor.ExecuteScanWhenImportShader;
            }
        }
    }
}

#endif
