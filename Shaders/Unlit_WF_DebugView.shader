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
Shader "UnlitWF/Debug/WF_DebugView" {

    Properties {
        [Header(Base)]
        [Enum(OFF,0,WHITE,1,BLACK,2,MAGENTA,3,DISCARD,4,VERTEX,5)]
        _ModeColor  ("Color", Float)                = 1

        [Header(Position)]
        [Enum(OFF,0,LOCAL_POSITION,1,WORLD_POSITION,2)]
        _ModePos    ("show Position", Float)        = 0

        [Header(UV Chart)]
        [Enum(OFF,0,UV1,1,UV2,2,UV3,3,UV4,4,LIGHTMAP_UV,5,DYNAMIC_LIGHTMAP_UV,6)]
        _ModeUV     ("show UV", Float)              = 0

        [Header(Normal and Tangent)]
        [Enum(OFF,0,NORMAL_LS,1,TANGENT_LS,2,BITANGENT_LS,3,NORMAL_WS,4,TANGENT_WS,5,BITANGENT_LS,6)]
        _ModeNormal ("show Normal", Float)          = 0

        [Enum(OFF,0,VIEW_PARA_NORMAL,1)]
        _ModeParaNormal ("show Parallel Normal", Float) = 0

        [Header(Lighting)]
        [Enum(OFF,0,LIGHT_0,1,LIGHT_4,2,SHADE_SH9,3)]
        _ModeLight      ("show Light", Float)       = 0

        [Header(Lightmap)]
        [Enum(OFF,0,LIGHT_MAP,1,DYNAMIC_LIGHT_MAP,2)]
        _ModeLightMap   ("show LightMap", Float)    = 0

        [Header(SpecCube)]
        [Enum(OFF,0,SPEC_CUBE_0,1,SPEC_CUBE_1,2)]
        _ModeSpecCube   ("show SpecCube", Float)    = 0
  
        [Header(Other Settings)]
        [IntRange]
        _GridScale  ("grid scale", Range(0,8))      = 4
        _GridFactor ("grid factor", Range(0, 1))    = 0.5

        [HideInInspector]
        [WF_FixFloat(0.0)]
            _CurrentVersion         ("2021/07/31", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            Cull OFF

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

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
                float3 normal   : NORMAL;
                float4 tangent  : TANGENT;
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
                float3 normal       : TEXCOORD6;
                float3 tangent      : TEXCOORD7;
                float3 bitangent    : TEXCOORD8;
            };

            v2f vert (appdata v)
            {
                v2f o;
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
            int _ModePos;
            int _ModeUV;
            int _ModeNormal;
            int _ModeParaNormal;
            int _ModeLight;
            int _ModeLightMap;
            int _ModeSpecCube;
            int _GridScale;
            float _GridFactor;

            float3 pickSpecCube(float3 ws_vertex, float3 ws_normal, float spec0, float spec1) {
                float lod = 0;
                float3 ws_camera_dir = normalize(_WorldSpaceCameraPos.xyz - ws_vertex );
                float3 reflect_dir = reflect(-ws_camera_dir, ws_normal);

                float3 dir0 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
                float3 dir1 = BoxProjectedCubemapDirection(reflect_dir, ws_vertex, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);

                float4 color0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dir0, lod);
                float4 color1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, dir1, lod);

                color0.rgb = DecodeHDR(color0, unity_SpecCube0_HDR);
                color1.rgb = DecodeHDR(color1, unity_SpecCube1_HDR);

                return color0.rgb * spec0 + color1.rgb * spec1;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0, 0, 0, 1);

                // 基本色
                switch(_ModeColor) {
                    case 1:
                        color.rgb = 1;
                        break;
                    case 3:
                        color.rb = 1;
                        break;
                    case 4:
                        discard;
                        break;
                    case 5:
                        color.rgb = i.vcolor;
                        break;
                    default:
                        break;
                }

                // 座標
                switch(_ModePos) {
                    case 1:
                        color.rgb = saturate(i.ls_vertex + 0.5);
                        break;
                    case 2:
                        color.rgb = saturate(i.ws_vertex + 0.5);
                        break;
                    default:
                        break;
                }

                // UV
                float2 grid_uv;
                switch(_ModeUV) {
                    case 1:
                        color.rg = grid_uv = saturate(i.uv);
                        color.b = 0;
                        break;
                    case 2:
                        color.rg = grid_uv = saturate(i.uv2);
                        color.b = 0;
                        break;
                    case 3:
                        color.rg = grid_uv = saturate(i.uv3);
                        color.b = 0;
                        break;
                    case 4:
                        color.rg = grid_uv = saturate(i.uv4);
                        color.b = 0;
                        break;
                    case 5:
#ifdef LIGHTMAP_ON
                        color.rg = grid_uv = saturate(i.uv2 * unity_LightmapST.xy + unity_LightmapST.zw);
                        color.b = 0;
#else
                        grid_uv.xy = 0;
                        discard;
#endif
                        break;
                    case 6:
#ifdef DYNAMICLIGHTMAP_ON
                        color.rg = grid_uv = saturate(i.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw);
                        color.b = 0;
#else
                        grid_uv.xy = 0;
                        discard;
#endif
                        break;
                    default:
                        grid_uv = saturate(i.uv);
                        break;
                }

                // 法線
                switch(_ModeNormal) {
                    case 1:
                        color.rgb = saturate(normalize(i.normal.xyz) + 0.5);
                        break;
                    case 2:
                        color.rgb = saturate(normalize(i.tangent.xyz) + 0.5);
                        break;
                    case 3:
                        color.rgb = saturate(normalize(i.bitangent.xyz) + 0.5);
                        break;
                    case 4:
                        color.rgb = saturate(UnityObjectToWorldNormal(i.normal.xyz) + 0.5);
                        break;
                    case 5:
                        color.rgb = saturate(UnityObjectToWorldNormal(i.tangent.xyz) + 0.5);
                        break;
                    case 6:
                        color.rgb = saturate(UnityObjectToWorldNormal(i.bitangent.xyz) + 0.5);
                        break;
                    default:
                        break;
                }
                switch(_ModeParaNormal) {
                    case 1:
                        color.rgb = saturate( pow( abs( dot(UnityObjectToWorldNormal(i.normal.xyz), UnityObjectToWorldNormal(i.tangent.xyz)) ), 100));
                        break;
                    default:
                        break;
                }

                // ライト
                switch(_ModeLight) {
                    case 1:
                        color.rgb = _LightColor0.rgb * saturate( dot(UnityObjectToWorldNormal(i.normal), _WorldSpaceLightPos0.xyz - i.ws_vertex.xyz * _WorldSpaceLightPos0.w));
                        break;
                    case 2:
                        color.rgb = Shade4PointLights(
                            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                            unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                            unity_4LightAtten0,
                            i.ws_vertex, UnityObjectToWorldNormal(i.normal));
                        break;
                    case 3:
                        color.rgb = ShadeSH9( float4(UnityObjectToWorldNormal(i.normal), 1) );
                        break;
                    default:
                        break;
                }

                // ライトマップ
                switch(_ModeLightMap) {
                    case 1:
#ifdef LIGHTMAP_ON
                        color.rgb = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2 * unity_LightmapST.xy + unity_LightmapST.zw));
#else
                        discard;
#endif
                        break;
                    case 2:
#ifdef DYNAMICLIGHTMAP_ON
                        color.rgb = DecodeRealtimeLightmap(UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, i.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw));
#else
                        discard;
#endif
                        break;
                    default:
                        break;
                }

                // 環境マップ
                switch(_ModeSpecCube) {
                    case 1:
                        color.rgb = pickSpecCube(i.ws_vertex, UnityObjectToWorldNormal(i.normal), 1, 0);
                        break;
                    case 2:
                        color.rgb = pickSpecCube(i.ws_vertex, UnityObjectToWorldNormal(i.normal), 0, 1);
                        break;
                    default:
                        break;
                }

                float2 grid = step(frac(grid_uv * (pow(2, _GridScale) - 1)), 0.5);
                color.rgb *= grid.x == grid.y ? 1 : _GridFactor;

                return color;
            }

            ENDCG
        }
    }

    CustomEditor "UnlitWF.WF_DebugViewEditor"
}
