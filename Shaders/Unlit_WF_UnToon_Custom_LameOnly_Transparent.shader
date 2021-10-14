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
Shader "UnlitWF/Custom/WF_UnToon_Custom_LameOnly_Transparent" {

    Properties {
        // 基本
        [WFHeader(Base)]
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2
            _Z_Shift                ("Z-shift (tweak)", Range(-0.5, 0.5)) = 0

        // ラメ
        [WFHeaderAlwaysOn(Lame)]
            _LM_Enable              ("[LM] Enable", Float) = 1
        [Enum(UV1,0,UV2,1)]
            _LM_UVType              ("[LM] UV Type", Float) = 0
        [HDR]
            _LM_Color               ("[LM] Color", Color) = (1, 1, 1, 1)
            _LM_Texture             ("[LM] Texture", 2D) = "white" {}
        [HDR]
            _LM_RandColor           ("[LM] Random Color", Color) = (0, 0, 0, 1)
        [HideInInspector]
        [WF_FixFloat(1.0)]
            _LM_ChangeAlpha         ("[LM] Change Alpha Transparency", Range(0, 1)) = 1
        [Enum(POLYGON,0,POINT,1)]
            _LM_Shape               ("[LM] Shape", Float) = 0
        [PowerSlider(4.0)]
            _LM_Scale               ("[LM] Scale", Range(0, 4)) = 0.5
        [PowerSlider(4.0)]
            _LM_Dencity             ("[LM] Dencity", Range(0.3, 4)) = 0.5
            _LM_Glitter             ("[LM] Glitter", Range(0, 1)) = 0.5
            _LM_MinDist             ("[LM] FadeOut Distance (Near)", Range(0, 5)) = 2.0
            _LM_MaxDist             ("[LM] FadeOut Distance (Far)", Range(0, 5)) = 4.0
            _LM_Spot                ("[LM] FadeOut Angle", Range(0, 16)) = 2.0
            _LM_AnimSpeed           ("[LM] Anim Speed", Range(0, 1)) = 0.2
            _LM_MaskTex             ("[LM] Mask Texture", 2D) = "white" {}
        [Toggle(_)]
            _LM_InvMaskVal          ("[LM] Invert Mask Value", Range(0, 1)) = 0

        // Lit
        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8
        [Toggle(_)]
            _GL_CastShadow          ("Cast Shadows", Range(0, 1)) = 1

        [WFHeader(Lit Advance)]
        [Enum(AUTO,0,ONLY_DIRECTIONAL_LIT,1,ONLY_POINT_LIT,2,CUSTOM_WORLDSPACE,3,CUSTOM_LOCALSPACE,4)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [Toggle(_)]
            _GL_DisableBackLit      ("Disable BackLit", Range(0, 1)) = 0
        [Toggle(_)]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2021/10/16", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+450"
            "IgnoreProjector" = "True"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite OFF
            Blend SrcAlpha One

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag_lameonly

            #pragma target 4.5

            #define _WF_ALPHA_BLEND
            #define _WF_FORCE_USE_SAMPLER
            #define _WF_MAIN_Z_SHIFT    (-_Z_Shift)

            #pragma shader_feature_local _LM_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "WF_UnToon.cginc"

            float4 _LM_MaskTex_ST;

            float4 frag_lameonly(v2f i) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float2 uv_main = TRANSFORM_TEX(i.uv, _LM_MaskTex);

                // メイン
                float4 color = float4(0, 0, 0, 0);

                float3 ws_normal = i.normal;

                // ラメ
                affectLame(i, uv_main, ws_normal, color);

                // Anti-Glare とライト色ブレンドを同時に計算
                color.rgb *= i.light_color;

                // Alpha は 0-1 にクランプ
                color.a = saturate(color.a);

                return color;
            }

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack "Hidden/UnlitWF/WF_UnToon_Hidden"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
