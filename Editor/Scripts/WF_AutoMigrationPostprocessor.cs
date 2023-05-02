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
    public class WF_AutoMigrationPostprocessor : AssetPostprocessor
    {
        public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromPath)
        {
            // マテリアルのマイグレーション
            Converter.ScanAndMigrationExecutor.ExecuteMigrationWhenImportMaterial(importedAssets);

            // もしshaderファイルがimportされたなら、そのタイミングで全スキャンも動作させる
            if (WFCommonUtility.IsSupportedShaderPath(importedAssets))
            {
                Converter.ScanAndMigrationExecutor.ExecuteScanWhenImportShader();
            }
        }
    }
}

#endif
