/*
 *  The MIT License
 *
 *  Copyright 2018-2021 whiteflare.
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

#ifndef INC_UNLIT_WF_UNTOON_TESSELLATION
#define INC_UNLIT_WF_UNTOON_TESSELLATION

    #include "WF_UnToon.cginc"
    #include "Tessellation.cginc"

    #ifndef WF_TEX2D_SMOOTH_MASK_TEX
        #define WF_TEX2D_SMOOTH_MASK_TEX(uv)    SAMPLE_MASK_VALUE_LOD(_TE_SmoothPowerTex, uv, _TE_InvMaskVal).r
    #endif

    struct HsConstantOutput {
        float tessFact[3]    : SV_TessFactor;
        float insideTessFact : SV_InsideTessFactor;
    };

    [domain("tri")]
    [partitioning("integer")]
    [outputtopology("triangle_cw")]
    [patchconstantfunc("hullConst")]
    [outputcontrolpoints(3)]
    v2f hull(InputPatch<v2f, 3> i, uint id : SV_OutputControlPointID) {
        return i[id];
    }

    float4 worldDistanceBasedTess(float3 ws_vertex, float minDist, float maxDist, float tess) {
        float dist = distance(ws_vertex, worldSpaceViewPointPos());
        float f = clamp(1.0 - (dist - minDist) / NON_ZERO_FLOAT(maxDist - minDist), 0.01, 1.0) * tess;
        return UnityCalcTriEdgeTessFactors(f.xxx);
    }

    HsConstantOutput hullConst(InputPatch<v2f, 3> i) {
        UNITY_SETUP_INSTANCE_ID(i[0]);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i[0]);

        // 2～16 の値域をもつ _TE_Factor から SV_TessFactor を計算する
        float4 tessFactor = worldDistanceBasedTess(calcWorldSpaceBasePos(i[0].ws_vertex), _TE_MinDist, _TE_MaxDist, _TE_Factor);

        HsConstantOutput o = (HsConstantOutput) 0;
        o.tessFact[0] = tessFactor.x;
        o.tessFact[1] = tessFactor.y;
        o.tessFact[2] = tessFactor.z;
        o.insideTessFact = tessFactor.w;

        return o;
    }

    v2f domainCore(HsConstantOutput hsConst, const OutputPatch<v2f, 3> i, float3 bary) {
        v2f o = i[0];
        UNITY_SETUP_INSTANCE_ID(o);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o);

        #define MUL_BARY(array, member)   (bary.x * array[0].member + bary.y * array[1].member + bary.z * array[2].member)

#ifdef _VC_ENABLE
        o.vertex_color  = MUL_BARY(i, vertex_color);
#endif
        o.light_color   = MUL_BARY(i, light_color);
#ifdef _TS_ENABLE
        o.shadow_power  = MUL_BARY(i, shadow_power);
#endif
        o.uv            = MUL_BARY(i, uv);
        o.uv_lmap       = MUL_BARY(i, uv_lmap);
        o.ws_vertex     = MUL_BARY(i, ws_vertex);
        o.ws_light_dir  = MUL_BARY(i, ws_light_dir);
        o.normal        = normalize( MUL_BARY(i, normal) );
#ifdef _NM_ENABLE
        o.tangent   = normalize( MUL_BARY(i, tangent) );
        o.bitangent = normalize( MUL_BARY(i, bitangent) );
#endif

        // Phong Tessellation
        float3 phg[3];
        for (int a = 0; a < 3; a++) {
            phg[a] = i[a].normal * (dot( i[a].ws_vertex.xyz, i[a].normal ) - dot(o.ws_vertex.xyz, i[a].normal));
        }
        float2 uv_main = TRANSFORM_TEX(o.uv, _MainTex);
        float smmoth = max(0, _TE_SmoothPower * WF_TEX2D_SMOOTH_MASK_TEX(uv_main)) / 2.0;
        o.ws_vertex.xyz += MUL_BARY(phg, xyz) * smmoth;

        #undef MUL_BARY

        return o;
    }

    [domain("tri")]
    v2f domain(HsConstantOutput hsConst, const OutputPatch<v2f, 3> i, float3 bary : SV_DomainLocation) {
        v2f o = domainCore(hsConst, i, bary);
        o.vs_vertex = UnityWorldToClipPos(o.ws_vertex.xyz);
        return o;
    }

    [domain("tri")]
    v2f domain_outline(HsConstantOutput hsConst, const OutputPatch<v2f, 3> i, float3 bary : SV_DomainLocation) {
        v2f o = domainCore(hsConst, i, bary);
        // SV_POSITION を上書き
        o.vs_vertex = shiftOutlineVertex(o);

        return o;
    }

#endif
