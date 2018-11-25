/*
 *  The MIT License
 *
 *  Copyright 2018 whiteflare.
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
using System.Collections.Generic;
using UnityEditor;
using System.Text.RegularExpressions;

namespace UnlitWF
{
    public class ShaderCustomEditor : ShaderGUI
    {
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
            // 現在無効なラベルを保持するリスト
            var disable = new List<string>();
            // プロパティを順に描画
            foreach (var prop in properties) {
                // ラベル付き displayName を、ラベルと名称に分割
                var mm = Regex.Match(prop.displayName, @"^\[(?<label>[A-Z]+)\]\s+(?<name>.+)$");
                if (mm.Success) {
                    string label = mm.Groups["label"].Value.ToUpper();
                    if (mm.Groups["name"].Value.ToLower() == "enable") {
                        // Enable チェックボックスなら有効無効をリストに追加
                        if ((int) prop.floatValue == 0) {
                            disable.Add(label);
                        }
                    }
                    else {
                        // それ以外の要素は disable に入っているならばスキップする
                        if (disable.Contains(label)) {
                            continue;
                        }
                    }
                }
                // 描画
                materialEditor.ShaderProperty(prop, prop.displayName);
            }
        }
    }
}
