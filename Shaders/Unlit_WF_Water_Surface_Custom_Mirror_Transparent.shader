﻿/*
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
Shader "UnlitWF/WF_Water_Surface_Custom_Mirror_Transparent" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Water Color", Color) = (1, 1, 1, 1)
        [HDR]
            _Color2                 ("Water Color 2", Color) = (0.7, 0.7, 1, 1)
            _ShadowPower            ("Shadow Power", Range(0, 1)) = 0.5
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        [WFHeader(Transparent Alpha)]
        [Enum(MAIN_TEX_ALPHA,0,MASK_TEX_RED,1,MASK_TEX_ALPHA,2)]
            _AL_Source              ("[AL] Alpha Source", Float) = 0
        [NoScaleOffset]
            _AL_MaskTex             ("[AL] Alpha Mask Texture", 2D) = "white" {}
        [ToggleUI]
            _AL_InvMaskVal          ("[AL] Invert Mask Value", Range(0, 1)) = 0
            _AL_Power               ("[AL] Power", Range(0, 2)) = 1.0
            _AL_PowerMin            ("[AL] Power(Min)", Range(0, 2)) = 0
            _Cutoff                 ("[AL] Cutoff Threshold", Range(0, 1)) = 0.05
            _AL_Fresnel             ("[AL] Fresnel Power", Range(0, 2)) = 0
        [Enum(OFF,0,ON,1)]
            _AL_ZWrite              ("[AL] ZWrite", int) = 0

        [WFHeaderAlwaysOn(VRC Mirror Reflection)]
            _WMI_Enable             ("[WMI] Enable", Float) = 1
            _WMI_Power              ("[WMI] Power", Range(0, 1)) = 0.8
            _WMI_Color              ("[WMI] Tint Color", Color) = (0.5, 0.5, 0.5, 1)
            _WMI_BlendNormal        ("[WMI] Blend Normal", Range(0, 1)) = 0.05
        [HideInInspector][WF_HideProp] _ReflectionTex0("", 2D) = "white" {}
        [HideInInspector][WF_HideProp] _ReflectionTex1("", 2D) = "white" {}

        [WFHeaderToggle(Distance Fade)]
            _WAD_Enable             ("[WAD] Enable", Float) = 0
            _WAD_Color              ("[WAD] Tint Color", Color) = (0.7, 0.7, 1, 1)
            _WAD_MinDist            ("[WAD] Fade Distance (Near)", Float) = 100
            _WAD_MaxDist            ("[WAD] Fade Distance (Far)", Float) = 200
            _WAD_Power              ("[WAD] Power", Range(0, 1)) = 1

        [WFHeaderToggle(Waving 1)]
            _WAV_Enable_1           ("[WA1] Enable", Float) = 1
        [Enum(UV1,0,UV2,1,WORLD_XZ,2)]
            _WAV_UVType_1           ("[WA1] UV Type", Float) = 0
        [WF_RotMatrix(0, 360)]
            _WAV_Direction_1        ("[WA1] Direction", Vector) = (0, 0, 1, 0)
            _WAV_Speed_1            ("[WA1] Speed", Range(0, 10)) = 0
            _WAV_NormalScale_1      ("[WA1] Wave Normal Scale", Range(0, 8)) = 1
        [Normal]
            _WAV_NormalMap_1        ("[WA1] Wave NormalMap", 2D) = "bump" {}
            _WAV_HeightMap_1        ("[WA1] Wave HeightMap", 2D) = "white" {}

        [WFHeaderToggle(Waving 2)]
            _WAV_Enable_2           ("[WA2] Enable", Float) = 0
        [Enum(UV1,0,UV2,1,WORLD_XZ,2)]
            _WAV_UVType_2           ("[WA2] UV Type", Float) = 0
        [WF_RotMatrix(0, 360)]
            _WAV_Direction_2        ("[WA2] Direction", Vector) = (120, 0.866, -0.5, 0)
            _WAV_Speed_2            ("[WA2] Speed", Range(0, 10)) = 0
            _WAV_NormalScale_2      ("[WA2] Wave Normal Scale", Range(0, 8)) = 1
        [Normal]
            _WAV_NormalMap_2        ("[WA2] Wave NormalMap", 2D) = "bump" {}
            _WAV_HeightMap_2        ("[WA2] Wave HeightMap", 2D) = "white" {}

        [WFHeaderToggle(Waving 3)]
            _WAV_Enable_3           ("[WA3] Enable", Float) = 0
        [Enum(UV1,0,UV2,1,WORLD_XZ,2)]
            _WAV_UVType_3           ("[WA3] UV Type", Float) = 0
        [WF_RotMatrix(0, 360)]
            _WAV_Direction_3        ("[WA3] Direction", Vector) = (240, -0.866, -0.5, 0)
            _WAV_Speed_3            ("[WA3] Speed", Range(0, 10)) = 0
            _WAV_NormalScale_3      ("[WA3] Wave Normal Scale", Range(0, 8)) = 1
        [Normal]
            _WAV_NormalMap_3        ("[WA3] Wave NormalMap", 2D) = "bump" {}
            _WAV_HeightMap_3        ("[WA3] Wave HeightMap", 2D) = "white" {}

        [WFHeaderToggle(Specular)]
            _WAS_Enable             ("[WAS] Enable", Float) = 0
            _WAS_Power              ("[WAS] Specular Power", Range(0, 2)) = 1
        [HDR]
            _WAS_Color              ("[WAS] Specular Color", Color) = (1, 1, 1, 1)
            _WAS_Smooth             ("[WAS] Specular Smoothness", Range(0, 1)) = 0.9
        [Header(Specular 2)]
            _WAS_Power2             ("[WAS] Specular 2 Power", Range(0, 2)) = 1
        [HDR]
            _WAS_Color2             ("[WAS] Specular 2 Color", Color) = (0.7, 0.7, 1, 1)
            _WAS_Smooth2            ("[WAS] Specular 2 Smoothness", Range(0, 1)) = 0.7

        [WFHeaderToggle(Reflection)]
            _WAM_Enable             ("[WAM] Enable", Float) = 0
            _WAM_Power              ("[WAM] Power", Range(0, 1)) = 0.5
            _WAM_Smooth             ("[WAM] Smoothness", Range(0, 1)) = 0.9
            _WAM_Bright             ("[WAM] Brightness", Range(0, 1)) = 0.2
        [Enum(REFLECTION_PROBE,0,CUSTOM,2)]
            _WAM_CubemapType        ("[WAM] 2nd CubeMap Blend", Float) = 0
        [NoScaleOffset]
            _WAM_Cubemap            ("[WAM] Cube Map", Cube) = "" {}
            _WAM_CubemapHighCut     ("[WAM] Hi-Cut Filter", Range(0, 1)) = 0

        [WFHeader(Lit Advance)]
        [WF_Enum(UnlitWF.SunSourceMode)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2025/03/23 (2.8.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _Category               ("BRP|Water|Custom/Surface_VRCMirror|Transparent", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-50" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite [_AL_ZWrite]
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert_top
            #pragma fragment frag_top

            #pragma target 3.0

            #define _WF_ALPHA_FRESNEL
            #define _WF_WATER_CUTOUT

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _WAM_ONLY2ND_ENABLE
            #pragma shader_feature_local _WAD_ENABLE
            #pragma shader_feature_local _WAM_ENABLE
            #pragma shader_feature_local _WAS_ENABLE
            #pragma shader_feature_local _WAV_ENABLE_1
            #pragma shader_feature_local _WAV_ENABLE_2
            #pragma shader_feature_local _WAV_ENABLE_3
            #pragma shader_feature_local _WMI_ENABLE

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ _WF_EDITOR_HIDE_LMAP

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #define _WF_WATER_SURFACE
            #include "WF_Water.cginc"

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
