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

#ifndef INC_UNLIT_WF_UNTOON_CLEARCOAT
#define INC_UNLIT_WF_UNTOON_CLEARCOAT

    #include "WF_UnToon.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    float _CCT_Width;
    float _CCT_Z_Shift;

    v2f vert_clearcoat(appdata v) {
        // 通常の vert を使う
        v2f o = vert(v);
        // SV_POSITION を上書き
        o.vs_vertex = shiftNormalAndDepthVertex(o.ws_vertex, o.ws_normal, _CCT_Width * 0.001, -_CCT_Z_Shift);
        affectNearClipCancel(o.vs_vertex);

        return o;
    }

    float4 frag_clearcoat(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        drawing d = prepareDrawing(i, 1);
        d.color = float4(0, 0, 0, 1);

        prepareMainTex(i, d);
        prepareBumpNormal(i, d);
        prepareDetailNormal(i, d);
        prepareMatcapVector(i, d);

        drawBumpNormal(d);          // ノーマルマップ
        drawMetallic(d);            // メタリック

        drawMatcapColor(d);         // マットキャップ

        // Anti-Glare とライト色ブレンドを同時に計算
        d.color.rgb *= d.light_color;

        drawOcclusion(d);           // オクルージョンとライトマップ

        return d.color;
    }

#endif
