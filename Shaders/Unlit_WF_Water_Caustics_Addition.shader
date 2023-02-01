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
Shader "UnlitWF/WF_Water_Caustics_Addition" {

    Properties {
        [WFHeader(Base)]
            _MainTex                ("Main Texture", 2D) = "white" {}
        [HDR]
            _Color                  ("Caustics Color", Color) = (1, 1, 1, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        [WFHeader(Water)]
            _WaterLevel             ("[WA] Water Level (World Y Coord)", Float) = 0
        [ToggleUI]
            _HideCausticsAbove      ("[WA] Hide Caustics above water", Float) = 0

        [WFHeaderToggle(Waving 1)]
            _WAV_Enable_1           ("[WA1] Enable", Float) = 1
        [Enum(UV1,0,UV2,1,WORLD_XZ,2)]
            _WAV_UVType_1           ("[WA1] UV Type", Float) = 0
        [WF_RotMatrix(0, 360)]
            _WAV_Direction_1        ("[WA1] Direction", Vector) = (0, 0, 1, 0)
            _WAV_Speed_1            ("[WA1] Speed", Range(0, 10)) = 0
            _WAV_CausticsTex_1      ("[WA1] Caustics Tex", 2D) = "black" {}

        [WFHeaderToggle(Waving 2)]
            _WAV_Enable_2           ("[WA2] Enable", Float) = 0
        [Enum(UV1,0,UV2,1,WORLD_XZ,2)]
            _WAV_UVType_2           ("[WA2] UV Type", Float) = 0
        [WF_RotMatrix(0, 360)]
            _WAV_Direction_2        ("[WA2] Direction", Vector) = (120, 0.866, -0.5, 0)
            _WAV_Speed_2            ("[WA2] Speed", Range(0, 10)) = 0
            _WAV_CausticsTex_2      ("[WA2] Caustics Tex", 2D) = "black" {}

        [WFHeaderToggle(Waving 3)]
            _WAV_Enable_3           ("[WA3] Enable", Float) = 0
        [Enum(UV1,0,UV2,1,WORLD_XZ,2)]
            _WAV_UVType_3           ("[WA3] UV Type", Float) = 0
        [WF_RotMatrix(0, 360)]
            _WAV_Direction_3        ("[WA3] Direction", Vector) = (240, -0.866, -0.5, 0)
            _WAV_Speed_3            ("[WA3] Speed", Range(0, 10)) = 0
            _WAV_CausticsTex_3      ("[WA3] Caustics Tex", 2D) = "black" {}

        [WFHeaderToggle(Ambient Occlusion)]
            _AO_Enable              ("[AO] Enable", Float) = 0
        [WF_FixUIToggle(1.0)]
            _AO_UseLightMap         ("[AO] Use LightMap", Float) = 1
            _AO_Contrast            ("[AO] Contrast", Range(0, 2)) = 1
            _AO_Brightness          ("[AO] Brightness", Range(-1, 1)) = 0

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2023/02/04", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-80" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite OFF
            Blend One One, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert_caustics
            #pragma fragment frag_caustics

            #pragma target 3.0

            #define _WF_AO_ONLY_LMAP

            #define _AO_ENABLE
            #define _WAV_ENABLE_1
            #define _WAV_ENABLE_2
            #define _WAV_ENABLE_3

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ _WF_EDITOR_HIDE_LMAP

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #define _WF_WATER_CAUSTICS
            #include "WF_Water.cginc"

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack OFF

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
