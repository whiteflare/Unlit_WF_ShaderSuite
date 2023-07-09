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
Shader "UnlitWF/WF_Water_Sun_Addition" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Reflection Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        [WFHeaderAlwaysOn(Sun Reflection)]
            _WAR_Enable             ("[WAR] Enable", Float) = 1
            _WAR_Power              ("[WAR] Power", Range(0, 2)) = 1
            _WAR_Azimuth            ("[WAR] Sun Azimuth", Range(0, 360)) = 0
            _WAR_Altitude           ("[WAR] Sun Altitude", Range(-90, 90)) = 5
        [NoScaleOffset]
            _WAR_CookieTex          ("[WAR] Cookie", 2D) = "white" {}
            _WAR_Size               ("[WAR] Size", Range(0, 1)) = 0.1
            _WAR_BlendNormal        ("[WAR] Blend Normal", Range(0, 1)) = 0.2

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

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/07/10 (1.3.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+51" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite [_AL_ZWrite]
            Blend One One

            CGPROGRAM

            #pragma vertex vert_lamp
            #pragma fragment frag_lamp

            #pragma target 3.0

            #pragma shader_feature_local _WAR_ENABLE
            #pragma shader_feature_local _WAV_ENABLE_1
            #pragma shader_feature_local _WAV_ENABLE_2
            #pragma shader_feature_local _WAV_ENABLE_3

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #define _WF_WATER_LAMP_DIR
            #include "WF_Water.cginc"

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack "UnlitWF/UnToon_Mobile/WF_UnToon_Mobile_Transparent"

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
