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
Shader "UnlitWF/Custom/WF_UnToon_Custom_LameOnly_Transparent" {

    Properties {
        [WFHeader(Base)]
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2
            _Z_Shift                ("Z-shift (tweak)", Range(-0.5, 0.5)) = 0

        [WFHeaderAlwaysOn(Lame)]
            _LME_Enable             ("[LME] Enable", Float) = 1
        [Enum(UV1,0,UV2,1)]
            _LME_UVType             ("[LME] UV Type", Float) = 0
        [HDR]
            _LME_Color              ("[LME] Color", Color) = (1, 1, 1, 1)
            _LME_Texture            ("[LME] Texture", 2D) = "white" {}
        [HDR]
            _LME_RandColor          ("[LME] Random Color", Color) = (0, 0, 0, 1)
        [HideInInspector]
        [WF_FixFloat(1.0)]
            _LME_ChangeAlpha        ("[LME] Change Alpha Transparency", Range(0, 1)) = 1
        [Enum(POLYGON,0,POINT,1)]
            _LME_Shape              ("[LME] Shape", Float) = 0
            _LME_Scale              ("[LME] Scale", Range(0, 4)) = 0.5
            _LME_Dencity            ("[LME] Dencity", Range(0, 1)) = 0.2
            _LME_Glitter            ("[LME] Glitter", Range(0, 1)) = 0.5
            _LME_MinDist            ("[LME] FadeOut Distance (Near)", Range(0, 5)) = 2.0
            _LME_MaxDist            ("[LME] FadeOut Distance (Far)", Range(0, 5)) = 4.0
            _LME_Spot               ("[LME] FadeOut Angle", Range(0, 16)) = 2.0
            _LME_AnimSpeed          ("[LME] Anim Speed", Range(0, 1)) = 0.2
            _LME_MaskTex            ("[LME] Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _LME_InvMaskVal         ("[LME] Invert Mask Value", Range(0, 1)) = 0

        [WFHeader(Lit)]
        [Gamma]
            _GL_LevelMin            ("Unlit Intensity", Range(0, 1)) = 0.125
        [Gamma]
            _GL_LevelMax            ("Saturate Intensity", Range(0, 1)) = 0.8
            _GL_BlendPower          ("Chroma Reaction", Range(0, 1)) = 0.8

        [WFHeader(Lit Advance)]
        [WF_Enum(UnlitWF.SunSourceMode)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)
        [ToggleUI]
            _GL_DisableBasePos      ("Disable ObjectBasePos", Range(0, 1)) = 0
        [ToggleUI]
            _GL_NCC_Enable          ("Cancel Near Clipping", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2024/07/27 (2.2.1)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _Category               ("BRP|UnToon|Custom/LameOnly|Transparent", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _VRCFallback            ("Hidden", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+450"
            "IgnoreProjector" = "True"
            "VRCFallback" = "Hidden"
        }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite OFF
            Blend SrcAlpha One, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag_lameonly

            #pragma target 4.5

            #define _WF_ALPHA_BLEND
            #define _WF_FORCE_USE_SAMPLER
            #define _WF_MAIN_Z_SHIFT    (-_Z_Shift)

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _GL_NCC_ENABLE
            #pragma shader_feature_local_fragment _LME_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #include "WF_UnToon.cginc"

            half4 frag_lameonly(v2f i) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                UNITY_APPLY_DITHER_CROSSFADE(i.vs_vertex);

                drawing d = prepareDrawing(i, 1);
                d.color = half4(0, 0, 0, 0);

                prepareMainTex(i, d);
                prepareBumpNormal(i, d);

                drawLame(d);

                // Anti-Glare とライト色ブレンドを同時に計算
                d.color.rgb *= d.light_color;

                // Alpha は 0-1 にクランプ
                d.color.a = saturate(d.color.a);

                return d.color;
            }

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack "Hidden/UnlitWF/WF_UnToon_Hidden"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
