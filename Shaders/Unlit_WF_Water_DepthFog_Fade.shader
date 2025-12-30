/*
 *  The zlib/libpng License
 *
 *  Copyright 2018-2026 whiteflare.
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
Shader "UnlitWF/WF_Water_DepthFog_Fade" {

    Properties {
        [WFHeader(Base)]
        [HDR]
            _Color                  ("Fog Color", Color) = (0.3, 0.4, 0.8, 1)
        [Enum(OFF,0,FRONT,1,BACK,2)]
            _CullMode               ("Cull Mode", int) = 2

        [WFHeader(Water)]
            _WaterLevel             ("[WA] Water Level (World Y Coord)", Float) = 0
            _WaterTransparency      ("[WA] Water Transparency", Float) = 1

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2026/01/01 (2.12.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent-70" }

        Pass {
            Name "MAIN"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_CullMode]
            ZWrite OFF
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert_depthfog
            #pragma fragment frag_depthfog

            #pragma target 3.0

            #pragma multi_compile_fwdbase
            // #pragma multi_compile_fog // DepthFog は Fog には対応しない
            #pragma multi_compile_instancing
            // #pragma multi_compile _ _WF_EDITOR_HIDE_LMAP // ライトマップは使わない

            #pragma skip_variants SHADOWS_SCREEN SHADOWS_CUBE

            #define _WF_WATER_DEPTHFOG
            #include "WF_Water.cginc"

            ENDCG
        }

        UsePass "Hidden/UnlitWF/WF_UnToon_Hidden/META"
    }

    FallBack OFF

    CustomEditor "UnlitWF.ShaderCustomEditor"
}
