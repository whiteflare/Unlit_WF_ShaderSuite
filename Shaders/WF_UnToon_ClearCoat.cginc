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

#ifndef INC_UNLIT_WF_UNTOON_CLEARCOAT
#define INC_UNLIT_WF_UNTOON_CLEARCOAT

    #include "WF_UnToon.cginc"

    ////////////////////////////
    // vertex&fragment shader
    ////////////////////////////

    half    _CCT_Width;
    half    _CCT_Z_Shift;

    v2f vert_clearcoat(appdata v) {
        // 通常の vert を使う
        v2f o = vert(v);
        // SV_POSITION を上書き
        o.vs_vertex = shiftNormalAndDepthVertex(o.ws_vertex, o.ws_normal, _CCT_Width * 0.001, -_CCT_Z_Shift);
        affectNearClipCancel(o.vs_vertex);

        return o;
    }

    half4 frag_clearcoat(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

        drawing d = prepareDrawing(i, 1);
        d.color = half4(0, 0, 0, 1);

        prepareMainTex(i, d);
        prepareBumpNormal(i, d);
        prepareDetailNormal(i, d);
        d.matcapVector = calcMatcapVectorArray(d.ws_view_dir, d.ws_camera_dir, d.ws_normal, d.ws_bump_normal, d.ws_detail_normal);

        drawBumpNormal(d);          // ノーマルマップ
        drawMetallic(d);            // メタリック

        drawMatcapColor(d);         // マットキャップ

        // Anti-Glare とライト色ブレンドを同時に計算
        d.color.rgb *= d.light_color;

        drawOcclusion(d);           // オクルージョンとライトマップ

        return d.color;
    }

#endif
