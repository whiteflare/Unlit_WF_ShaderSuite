/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2025 whiteflare.
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
Shader "Hidden/UnlitWF/WF_UnToon_BakeTexture" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Color", Color) = (1, 1, 1, 1)

        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _AL_Power               ("[AL] Power", Range(0, 2)) = 1.0
            _AL_PowerMin            ("[AL] Power(Min)", Range(0, 2)) = 0

        [WFHeaderToggle(Main Texture 2nd)]
            _TX2_Enable             ("[TX2] Enable", Float) = 0
        [Enum(UV1,0,UV2,1)]
            _TX2_UVType             ("[TX2] UV Type", Float) = 0
            _TX2_MainTex            ("[TX2] Main Texture 2nd", 2D) = "white" {}
        [HDR]
            _TX2_Color              ("[TX2] Color 2nd", Color) = (1, 1, 1, 1)
        [NoScaleOffset]
            _TX2_MaskTex            ("[TX2] Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _TX2_InvMaskVal         ("[TX2] Invert Mask Value", Range(0, 1)) = 0

        [WFHeaderToggle(Gradient Map)]
            _CGR_Enable             ("[CGR] Enable", Float) = 0
        [NoScaleOffset]
            _CGR_GradMapTex         ("[CGR] Gradient Map", 2D) = "white" {}
        [NoScaleOffset]
            _CGR_MaskTex            ("[CGR] Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _CGR_InvMaskVal         ("[CGR] Invert Mask Value", Range(0, 1)) = 0

        [WFHeaderToggle(Color Change)]
            _CLC_Enable             ("[CLC] Enable", Float) = 0
        [ToggleUI]
            _CLC_Monochrome         ("[CLC] monochrome", Range(0, 1)) = 0
            _CLC_DeltaH             ("[CLC] Hur", Range(0, 1)) = 0
            _CLC_DeltaS             ("[CLC] Saturation", Range(-1, 1)) = 0
            _CLC_DeltaV             ("[CLC] Brightness", Range(-1, 1)) = 0
        [PowerSlider(2.0)]
            _CLC_Gamma              ("[CLC] Gamma", Range(0, 4)) = 1
        [NoScaleOffset]
            _CLC_MaskTex            ("[CLC] Mask Texture (R)", 2D) = "white" {}
        [ToggleUI]
            _CLC_InvMaskVal         ("[CLC] Invert Mask Value", Range(0, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2025/05/28 (2.9.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _VRCFallback            ("Hidden", Float) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "VRCFallback" = "Hidden"
        }

        Pass {
            Name "MAIN"

            Cull Off
            ZWrite Off
            Blend One Zero, One Zero
            ZTest Always

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 4.5

            #pragma shader_feature_local _WF_ALPHA_BLEND

            #pragma shader_feature_local _CGR_ENABLE
            #pragma shader_feature_local _CLC_ENABLE
            #pragma shader_feature_local _TX2_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #include "WF_UnToon.cginc"

            ENDCG
        }
    }

    FallBack OFF

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
