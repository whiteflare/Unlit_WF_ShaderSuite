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

#ifdef _V2F_HAS_VERTEXCOLOR
        o.vertex_color  = MUL_BARY(i, vertex_color);
#endif
        o.light_color   = MUL_BARY(i, light_color);
#ifdef _V2F_HAS_SHADOWPOWER
        o.shadow_power  = MUL_BARY(i, shadow_power);
#endif
        o.uv            = MUL_BARY(i, uv);
        o.uv2           = MUL_BARY(i, uv2);
        o.ws_vertex     = MUL_BARY(i, ws_vertex);
        o.ws_light_dir  = MUL_BARY(i, ws_light_dir);
        o.ws_normal     = MUL_BARY(i, ws_normal);  // frag で normalize するので、ここでは normalize しない
#ifdef _V2F_HAS_TANGENT
        o.ws_tangent    = MUL_BARY(i, ws_tangent);
        o.ws_bitangent  = MUL_BARY(i, ws_bitangent);
#endif

        // Phong Tessellation
        float3 phg[3];
        for (int a = 0; a < 3; a++) {
            float3 nml = normalize(i[a].ws_normal);
            phg[a] = nml * (dot( i[a].ws_vertex.xyz, nml ) - dot(o.ws_vertex.xyz, nml));
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
        affectNearClipCancel(o.vs_vertex);
        return o;
    }

    [domain("tri")]
    v2f domain_outline(HsConstantOutput hsConst, const OutputPatch<v2f, 3> i, float3 bary : SV_DomainLocation) {
        v2f o = domainCore(hsConst, i, bary);
        // SV_POSITION を上書き
        o.vs_vertex = shiftOutlineVertex(o); // NCC済み

        return o;
    }

#endif
