﻿/*
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
Shader "UnlitWF/WF_Water_Surface_Opaque" {

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

        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable              ("[AO] Enable", Float) = 0
        [WF_FixUIToggle(1.0)]
            _AO_UseLightMap         ("[AO] Use LightMap", Float) = 1
            _AO_Contrast            ("[AO] Contrast", Range(0, 2)) = 1
            _AO_Brightness          ("[AO] Brightness", Range(-1, 1)) = 0

        [WFHeader(Lit Advance)]
        [WF_Enum(UnlitWF.SunSourceMode)]
            _GL_LightMode           ("Sun Source", Float) = 0
            _GL_CustomAzimuth       ("Custom Sun Azimuth", Range(0, 360)) = 0
            _GL_CustomAltitude      ("Custom Sun Altitude", Range(-90, 90)) = 45
        [WF_Vector3]
            _GL_CustomLitPos        ("Custom Light Pos", Vector) = (0, 3, 0)

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/08/27 (1.4.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-10" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]

            CGPROGRAM

            #pragma vertex vert_top
            #pragma fragment frag_top

            #pragma target 3.0

            #define _WF_AO_ONLY_LMAP

            #pragma shader_feature_local _ _GL_AUTO_ENABLE _GL_ONLYDIR_ENABLE _GL_ONLYPOINT_ENABLE _GL_WSDIR_ENABLE _GL_LSDIR_ENABLE _GL_WSPOS_ENABLE
            #pragma shader_feature_local _ _WAM_ONLY2ND_ENABLE
            #pragma shader_feature_local _AO_ENABLE
            #pragma shader_feature_local _WAD_ENABLE
            #pragma shader_feature_local _WAM_ENABLE
            #pragma shader_feature_local _WAS_ENABLE
            #pragma shader_feature_local _WAV_ENABLE_1
            #pragma shader_feature_local _WAV_ENABLE_2
            #pragma shader_feature_local _WAV_ENABLE_3

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

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Opaque"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
