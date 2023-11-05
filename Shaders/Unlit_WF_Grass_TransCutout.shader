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
Shader "UnlitWF/WF_Grass_TransCutout" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Albedo (RGB)", 2D) = "white" {}
            _Cutoff                 ("Cutoff", Range(0, 1)) = 0.8
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 0
        [ToggleUI]
            _UseVertexColor         ("Use Vertex Color", Range(0, 1)) = 0

        [WFHeader(Grass)]
        [Enum(WORLD_Y,0,UV,1,MASK_TEX,2,VERTEX_COLOR,3)]
            _GRS_HeightType         ("[GRS] Height Type", Int) = 0
            _GRS_WorldYBase         ("[GRS] Ground Y coordinate", Float) = 0
            _GRS_WorldYScale        ("[GRS] Height scale", Float) = 1
        [Enum(UV1,0,UV2,1,UV3,2)]
            _GRS_HeightUVType       ("[GRS] Height UV Type", Int) = 0
            _GRS_HeightMaskTex      ("[GRS] Height Mask Tex", 2D) = "white" {}
        [ToggleUI]
            _GRS_InvMaskVal         ("[GRS] Invert Mask Value", Float) = 0
            _GRS_UVFactor           ("[GRS] UV Factor", Vector) = (0, 1, 0, 0)
        [WF_Vector3]
            _GRS_ColorFactor        ("[GRS] Color Factor", Vector) = (0, 1, 0, 0)
            _GRS_ColorTop           ("[GRS] Tint Color Top", Color) = (1, 1, 1, 1)
            _GRS_ColorBottom        ("[GRS] Tint Color Bottom", Color) = (1, 1, 1, 1)
            _GRS_EraseSide          ("[GRS] Erase Side", Range(0, 1)) = 0

        [WFHeaderToggle(Grass Wave)]
            _GRW_Enable             ("[GRW] Enable", Float) = 0
            _GRW_WaveSpeed          ("[GRW] Wave Speed", Range(0, 1)) = 0.2
        [WF_Vector3]
            _GRW_WaveWidth          ("[GRW] Wave Amplitude", Vector) = (0.2, 0, 0.2, 0)
            _GRW_WaveExponent       ("[GRW] Wave Exponent", Range(0.5, 4)) = 1
            _GRW_WaveOffset         ("[GRW] Wave Offset", Range(-1, 1)) = 0
        [WF_Vector3]
            _GRW_WindVector         ("[GRW] Wind Vector", Vector) = (5, 0, 5, 0)

        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable              ("[AO] Enable", Float) = 0
        [WF_FixUIToggle(1.0)]
            _AO_UseLightMap         ("[AO] Use LightMap", Float) = 1
            _AO_Contrast            ("[AO] Contrast", Range(0, 2)) = 1
            _AO_Brightness          ("[AO] Brightness", Range(-1, 1)) = 0

        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8
        [ToggleUI]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1

        [WFHeaderToggle(Light Bake Effects)]
            _LBE_Enable             ("[LBE] Enable", Float) = 0
            _LBE_IndirectMultiplier ("[LBE] Indirect Multiplier", Range(0, 2)) = 1
            _LBE_EmissionMultiplier ("[LBE] Emission Multiplier", Range(0, 2)) = 1
            _LBE_IndirectChroma     ("[LBE] Indirect Chroma", Range(0, 2)) = 1

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/11/06 (1.6.1)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" "IgnoreProjector"="True" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite ON

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            // #define _WF_ALPHA_CUTOUT // UnToon の AlphaCutout は使用せず自前でclipする
            #define _WF_AO_ONLY_LMAP
            #define _WF_MOBILE

            #pragma shader_feature_local _ _GRS_MASKTEX_ENABLE
            #pragma shader_feature_local _ _GRS_ERSSIDE_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _GRW_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #include "WF_Grass.cginc"

            ENDCG

        }

        Pass {
            Name "SHADOWCASTER"
            Tags{ "LightMode" = "ShadowCaster" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert_shadow
            #pragma fragment frag_shadow

            // #define _WF_ALPHA_CUTOUT // UnToon の AlphaCutout は使用せず自前でclipする
            #define _WF_MOBILE

            #pragma shader_feature_local _ _GRS_MASKTEX_ENABLE
            #pragma shader_feature_local _ _GRS_ERSSIDE_ENABLE
            #pragma shader_feature_local _GRW_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "WF_Grass.cginc"

            ENDCG
        }

        Pass {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert_meta
            #pragma fragment frag_meta

            // #define _WF_ALPHA_CUTOUT // UnToon の AlphaCutout は使用せず自前でclipする
            #define _WF_MOBILE

            #pragma shader_feature_local _ _GRS_MASKTEX_ENABLE
            #pragma shader_feature_local _VC_ENABLE

            #pragma shader_feature EDITOR_VISUALIZATION

            #include "WF_Grass.cginc"

            ENDCG
        }
    }

    FallBack "Unlit/Transparent Cutout"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
