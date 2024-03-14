/*
 *  The MIT License
 *
 *  Copyright 2018-2024 whiteflare.
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
Shader "UnlitWF/Debug/WF_DebugView" {

    Properties {
        [Header(Base)]
        [IntRange]
        _ModeColor                  ("Color", Range(0, 6))          = 1

        [Header(UV Chart)]
        [IntRange]
        _ModeUV                     ("show UV", Range(0, 6))        = 0

        [Header(Normal and Tangent)]
        [IntRange]
        _ModeNormal                 ("show Normal", Range(0, 6))    = 0

        [Header(Texture)]
        [IntRange]
        _ModeTexture                ("show Texture", Range(0, 6))   = 0

        [Header(Lightmap)]
        [IntRange]
        _ModeLightMap               ("show LightMap", Range(0, 2))  = 0

        [Header(Other Settings)]
        [ToggleUI]
        _GridEnable                 ("Grid Enable", Range(0, 1))    = 1
        [IntRange]
        _GridScale                  ("Grid Scale", Range(0, 8))     = 4
        _GridAlpha                  ("Grid Alpha", Range(0, 1))     = 0.5

        [HideInInspector]
        _MainTex                    ("Albedo", 2D)          = "white" {}
        [HideInInspector]
        _MetallicGlossMap           ("Metallic", 2D)        = "white" {}
        [HideInInspector]
        _SpecGlossMap               ("Roughness Map", 2D)   = "white" {}
        [HideInInspector]
        _BumpMap                    ("Normal Map", 2D)      = "bump" {}
        [HideInInspector]
        _OcclusionMap               ("Occlusion", 2D)       = "white" {}
        [HideInInspector]
        _EmissionMap                ("Emission", 2D)        = "white" {}

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2024/03/16 (1.12.0)", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _QuestSupported         ("True", Float) = 0
        [HideInInspector]
        [WF_FixFloat(0.0)]
            _VRCFallback            ("Hidden", Float) = 0
    }

    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "VRCFallback" = "Hidden"
        }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex   : POSITION;
                float3 vcolor   : COLOR0;
                float2 uv       : TEXCOORD0;
                float2 uv2      : TEXCOORD1;
                float2 uv3      : TEXCOORD2;
                float2 uv4      : TEXCOORD3;
                half3 normal   : NORMAL;
                half4 tangent  : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex       : SV_POSITION;
                float3 vcolor       : COLOR0;
                float3 ls_vertex    : TEXCOORD0;
                float3 ws_vertex    : TEXCOORD1;
                float2 uv           : TEXCOORD2;
                float2 uv2          : TEXCOORD3;
                float2 uv3          : TEXCOORD4;
                float2 uv4          : TEXCOORD5;
                half3 normal       : TEXCOORD6;
                float3 tangent      : TEXCOORD7;
                float3 bitangent    : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex    = UnityObjectToClipPos(v.vertex);
                o.vcolor    = v.vcolor;
                o.ls_vertex = v.vertex.xyz;
                o.ws_vertex = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv        = v.uv;
                o.uv2       = v.uv2;
                o.uv3       = v.uv3;
                o.uv4       = v.uv4;
                o.normal    = v.normal;
                o.tangent   = v.tangent.xyz;
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                return o;
            }

            int _ModeColor;
            int _ModeUV;
            int _ModeNormal;
            int _ModeTexture;
            int _ModeLightMap;
            int _GridEnable;
            int _GridScale;
            float _GridAlpha;

            sampler2D _MainTex;             float4  _MainTex_ST;
            sampler2D _MetallicGlossMap;    float4  _MetallicGlossMap_ST;
            sampler2D _SpecGlossMap;        float4  _SpecGlossMap_ST;
            sampler2D _BumpMap;             float4  _BumpMap_ST;
            sampler2D _OcclusionMap;        float4  _OcclusionMap_ST;
            sampler2D _EmissionMap;         float4  _EmissionMap_ST;

            float3 pickSpecCube(float3 ws_vertex, half3 ws_normal, float spec0, float spec1) {
                float lod = 0;
                half3 ws_camera_dir = normalize(_WorldSpaceCameraPos.xyz - ws_vertex );
                float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

                float3 dir0 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
                float3 dir1 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

                float4 color0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dir0, lod);
                float4 color1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, dir1, lod);

                color0.rgb = DecodeHDR(color0, unity_SpecCube0_HDR);
                color1.rgb = DecodeHDR(color1, unity_SpecCube1_HDR);

                return color0.rgb * spec0 + color1.rgb * spec1;
            }

            half4 frag (v2f i, uint facing: SV_IsFrontFace) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                half4 color = half4(0, 0, 0, 1);
                float2 grid_uv = float2(0, 0);

                // 基本色
                switch(_ModeColor) {
                    case 1:
                        grid_uv = i.uv;
                        color.rgb = 1;
                        break;
                    case 3:
                        grid_uv = i.uv;
                        color.rb = 1;
                        break;
                    case 4:
                        discard;
                        break;
                    case 5:
                        grid_uv = i.uv;
                        color.rgb = i.vcolor;
                        break;
                    case 6:
                        grid_uv = i.uv;
                        color.rgb = facing ? half4(0, 1, 0, 1) : half4(1, 0, 0, 1);
                        break;
                    case 7:
#ifdef LIGHTMAP_ON
                        grid_uv = saturate(i.uv2 * unity_LightmapST.xy + unity_LightmapST.zw);
                        color.rgb = facing ? half4(0, 1, 0, 1) : half4(1, 0, 0, 1);
                        break;
#else
                        discard;
                        break;
#endif
                    default:
                        break;
                }

                // UV
                switch(_ModeUV) {
                    case 1:
                        grid_uv = i.uv;
                        color.rg = saturate(grid_uv);
                        color.b = 0;
                        break;
                    case 2:
                        grid_uv = i.uv2;
                        color.rg = saturate(grid_uv);
                        color.b = 0;
                        break;
                    case 3:
                        grid_uv = i.uv3;
                        color.rg = saturate(grid_uv);
                        color.b = 0;
                        break;
                    case 4:
                        grid_uv = i.uv4;
                        color.rg = saturate(grid_uv);
                        color.b = 0;
                        break;
                    case 5:
#ifdef LIGHTMAP_ON
                        color.rg = grid_uv = saturate(i.uv2 * unity_LightmapST.xy + unity_LightmapST.zw);
                        color.b = 0;
                        break;
#else
                        discard;
                        break;
#endif
                    case 6:
#ifdef DYNAMICLIGHTMAP_ON
                        color.rg = grid_uv = saturate(i.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw);
                        color.b = 0;
                        break;
#else
                        discard;
                        break;
#endif
                    default:
                        break;
                }

                // 法線
                switch(_ModeNormal) {
                    case 1:
                        grid_uv = i.uv;
                        color.rgb = saturate(normalize(i.normal.xyz) + 0.5);
                        break;
                    case 2:
                        grid_uv = i.uv;
                        color.rgb = saturate(normalize(i.tangent.xyz) + 0.5);
                        break;
                    case 3:
                        grid_uv = i.uv;
                        color.rgb = saturate(normalize(i.bitangent.xyz) + 0.5);
                        break;
                    case 4:
                        grid_uv = i.uv;
                        color.rgb = saturate(UnityObjectToWorldNormal(i.normal.xyz) + 0.5);
                        break;
                    case 5:
                        grid_uv = i.uv;
                        color.rgb = saturate(UnityObjectToWorldNormal(i.tangent.xyz) + 0.5);
                        break;
                    case 6:
                        grid_uv = i.uv;
                        color.rgb = saturate(UnityObjectToWorldNormal(i.bitangent.xyz) + 0.5);
                        break;
                    default:
                        break;
                }

                // テクスチャ表示
                switch(_ModeTexture) {
                    case 1:
                        grid_uv     = TRANSFORM_TEX(i.uv, _MainTex);
                        color.rgb   = tex2D(_MainTex, grid_uv);
                        break;
                    case 2:
                        grid_uv     = TRANSFORM_TEX(i.uv, _MainTex);
                        color.rgb   = tex2D(_MetallicGlossMap, grid_uv);
                        break;
                    case 3:
                        grid_uv     = TRANSFORM_TEX(i.uv, _MainTex);
                        color.rgb   = tex2D(_SpecGlossMap, grid_uv);
                        break;
                    case 4:
                        grid_uv     = TRANSFORM_TEX(i.uv, _MainTex);
                        color.rgb   = tex2D(_BumpMap, grid_uv);
                        break;
                    case 5:
                        grid_uv     = TRANSFORM_TEX(i.uv, _MainTex);
                        color.rgb   = tex2D(_OcclusionMap, grid_uv);
                        break;
                    case 6:
                        grid_uv     = TRANSFORM_TEX(i.uv, _EmissionMap);
                        color.rgb   = tex2D(_EmissionMap, grid_uv);
                        break;
                    default:
                        break;
                }

                // ライトマップ
                switch(_ModeLightMap) {
                    case 1:
#ifdef LIGHTMAP_ON
                        grid_uv     = saturate(i.uv2 * unity_LightmapST.xy + unity_LightmapST.zw);
                        color.rgb   = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, grid_uv));
#else
                        discard;
#endif
                        break;
                    case 2:
#ifdef DYNAMICLIGHTMAP_ON
                        grid_uv     = saturate(i.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw);
                        color.rgb   = DecodeRealtimeLightmap(UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, grid_uv));
#else
                        discard;
#endif
                        break;
                    default:
                        break;
                }

                if (_GridEnable) {
                    float2 grid = step(frac(grid_uv * (pow(2, _GridScale) - 1)), 0.5);
                    color.rgb *= grid.x == grid.y ? 1 : (1 - _GridAlpha);
                }
                return color;
            }

            ENDCG
        }
    }

    CustomEditor "UnlitWF.WF_DebugViewEditor"
}
