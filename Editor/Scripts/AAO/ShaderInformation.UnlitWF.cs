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

#if UNITY_EDITOR && ENV_AAO

using System.Linq;
using Anatawa12.AvatarOptimizer.API;
using UnityEditor;
using UnityEngine;

namespace UnlitWF.AAO
{
    class UnlitWFShaderInformation : ShaderInformation
    {
        [InitializeOnLoadMethod]
        public static void Register()
        {
            foreach(var sn in WFShaderNameDictionary.GetCurrentRpNames())
            {
                if (sn.Familly == "UnToon" || sn.Familly == "FakeFur" || sn.Familly == "Gem")
                {
                    var sh = WFCommonUtility.FindShader(sn.Name);
                    if (WFCommonUtility.IsSupportedShader(sh))
                    {
                        ShaderInformationRegistry.RegisterShaderInformation(sh, new UnlitWFShaderInformation(sh));
                    }
                }
            }
        }

        private readonly Shader shader;

        public UnlitWFShaderInformation(Shader shader)
        {
            this.shader = shader;
        }

        public override ShaderInformationKind SupportedInformationKind => ShaderInformationKind.VertexIndexUsage | ShaderInformationKind.TextureAndUVUsage;

        public override void GetMaterialInformation(MaterialInformationCallback matInfo)
        {
            if (shader == null)
            {
                return;
            }

            var _MainTex_ST = GetST(matInfo, "_MainTex");
            if (RegisterTextureUVUsage(matInfo,"_MainTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST))
            {
                // マスク系
                RegisterTextureUVUsage(matInfo, "_AL_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, () => IsIntValue(matInfo, "_AL_Source", 1, 2));
                RegisterTextureUVUsage(matInfo, "_CGR_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_CGR_Enable");
                RegisterTextureUVUsage(matInfo, "_CLC_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_CLC_Enable");
                RegisterTextureUVUsage(matInfo, "_ES_AU_DelayTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST,
                    () => IsIntValue(matInfo, "_ES_Enable", 1) && IsIntValue(matInfo, "_ES_AuLinkEnable", 1) && IsIntValue(matInfo, "_ES_AU_DelayDir", 5));
                RegisterTextureUVUsage(matInfo, "_FUR_LenMaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST);
                RegisterTextureUVUsage(matInfo, "_FUR_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST);
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable");
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex_1", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable_1");
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex_2", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable_2");
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex_3", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable_3");
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex_4", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable_4");
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex_5", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable_5");
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex_6", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable_6");
                RegisterTextureUVUsage(matInfo, "_HL_MaskTex_7", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_HL_Enable_7");
                RegisterTextureUVUsage(matInfo, "_LME_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_LME_Enable");
                RegisterTextureUVUsage(matInfo, "_NS_2ndMaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_NS_Enable");
                RegisterTextureUVUsage(matInfo, "_OVL_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_OVL_Enable");
                RegisterTextureUVUsage(matInfo, "_TBL_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TBL_Enable");
                RegisterTextureUVUsage(matInfo, "_TE_SmoothPowerTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST);
                RegisterTextureUVUsage(matInfo, "_TL_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TL_Enable");
                RegisterTextureUVUsage(matInfo, "_TM_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TM_Enable");
                RegisterTextureUVUsage(matInfo, "_TR_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TR_Enable");
                RegisterTextureUVUsage(matInfo, "_TS_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TS_Enable");
                RegisterTextureUVUsage(matInfo, "_TX2_MaskTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TX2_Enable");
                // その他のテクスチャ
                RegisterTextureUVUsage(matInfo, "_DFD_ColorTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_DFD_Enable");
                RegisterTextureUVUsage(matInfo, "_EmissionMap", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_ES_Enable");
                RegisterTextureUVUsage(matInfo, "_MetallicGlossMap", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_MT_Enable");
                RegisterTextureUVUsage(matInfo, "_OcclusionMap", "_MainTex", GetUVType(matInfo, "_AO_UVType"), _MainTex_ST, "_AO_Enable");
                RegisterTextureUVUsage(matInfo, "_SpecGlossMap", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_MT_Enable");
                RegisterTextureUVUsage(matInfo, "_TL_CustomColorTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TL_Enable");
                RegisterTextureUVUsage(matInfo, "_TS_1stTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TS_Enable");
                RegisterTextureUVUsage(matInfo, "_TS_2ndTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TS_Enable");
                RegisterTextureUVUsage(matInfo, "_TS_3rdTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TS_Enable");
                RegisterTextureUVUsage(matInfo, "_TS_BaseTex", "_MainTex", UsingUVChannels.UV0, _MainTex_ST, "_TS_Enable");
            }

            // 独自のサンプラでMainTexと同じSTを持つもの
            RegisterTextureUVUsage(matInfo, "_BumpMap", "_BumpMap", UsingUVChannels.UV0, _MainTex_ST, "_NM_Enable");
            RegisterTextureUVUsage(matInfo, "_FUR_BumpMap", "_FUR_BumpMap", UsingUVChannels.UV0, _MainTex_ST);

            // MainTexのサンプラで独自のSTを持つもの
            RegisterTextureUVUsage(matInfo, "_BKT_BackTex", "_MainTex", GetUVType(matInfo, "_TX2_UVType"), GetST(matInfo, "_BKT_BackTex"), "_BKT_Enable");
            RegisterTextureUVUsage(matInfo, "_DSV_CtrlTex", "_MainTex", UsingUVChannels.UV0, GetST(matInfo, "_DSV_CtrlTex"), "_DSV_Enable");
            RegisterTextureUVUsage(matInfo, "_LME_Texture", "_MainTex", GetUVType(matInfo, "_LME_UVType"), GetST(matInfo, "_LME_Texture"), "_LME_Enable");
            RegisterTextureUVUsage(matInfo, "_TX2_MainTex", "_MainTex", GetUVType(matInfo, "_BKT_UVType"), GetST(matInfo, "_TX2_MainTex"), "_TX2_Enable");

            // 独自のサンプラでUV0かUV1を使うもの
            RegisterTextureUVUsage(matInfo, "_DetailNormalMap", "_DetailNormalMap", GetUVType(matInfo, "_DetailNormalMap"), GetST(matInfo, "_DetailNormalMap"), "_NS_Enable");
            RegisterTextureUVUsage(matInfo, "_FUR_NoiseTex", "_FUR_NoiseTex", UsingUVChannels.UV0, GetST(matInfo, "_FUR_NoiseTex"));
            RegisterTextureUVUsage(matInfo, "_OVL_OverlayTex", "_OVL_OverlayTex", GetOVLUVType(matInfo, "_OVL_UVType"), GetST(matInfo, "_OVL_OverlayTex"), "_OVL_Enable");

            // Matcap
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex", "_HL_MatcapTex", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable");
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex_1", "_HL_MatcapTex_1", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable_1");
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex_2", "_HL_MatcapTex_2", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable_2");
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex_3", "_HL_MatcapTex_3", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable_3");
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex_4", "_HL_MatcapTex_4", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable_4");
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex_5", "_HL_MatcapTex_5", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable_5");
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex_6", "_HL_MatcapTex_6", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable_6");
            RegisterTextureUVUsage(matInfo, "_HL_MatcapTex_7", "_HL_MatcapTex_7", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_HL_Enable_7");

            // GradMap
            RegisterTextureUVUsage(matInfo, "_CGR_GradMapTex", "_CGR_GradMapTex", UsingUVChannels.NonMesh, Matrix2x3.Identity, "_CGR_Enable");
            RegisterTextureUVUsage(matInfo, "_ES_SC_GradTex", "_ES_SC_GradTex", UsingUVChannels.NonMesh, Matrix2x3.Identity,
                () => IsIntValue(matInfo, "_ES_Enable", 1) && IsIntValue(matInfo, "_ES_ScrollEnable", 1) && IsIntValue(matInfo, "_ES_SC_Shape", 3));

            // UVを直に使う場合は登録

            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV0, Eq("_ES_Enable", 1), Eq("_ES_ScrollEnable", 1), Eq("_ES_SC_DirType", 2), Eq("_ES_SC_UVType", 0));
            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV1, Eq("_ES_Enable", 1), Eq("_ES_ScrollEnable", 1), Eq("_ES_SC_DirType", 2), Eq("_ES_SC_UVType", 1));
            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV0, Eq("_ES_Enable", 1), Eq("_ES_AuLinkEnable", 1), Eq("_ES_AU_DelayDir", 1, 2));
            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV1, Eq("_ES_Enable", 1), Eq("_ES_AuLinkEnable", 1), Eq("_ES_AU_DelayDir", 3, 4));

            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV1, Eq("_OVL_Enable", 1), Eq("_OVL_UVType", 3)); // AngelRing
            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV0, Eq("_OVL_Enable", 1), Eq("_OVL_UVType", 0), _ => {
                return HasShaderProperty(matInfo, "_OVL_UVScroll") && matInfo.GetVector("_OVL_UVScroll") is { } uvScroll && (uvScroll.x != 0f || uvScroll.y != 0f);
            });
            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV1, Eq("_OVL_Enable", 1), Eq("_OVL_UVType", 1), _ => {
                return HasShaderProperty(matInfo, "_OVL_UVScroll") && matInfo.GetVector("_OVL_UVScroll") is { } uvScroll && (uvScroll.x != 0f || uvScroll.y != 0f);
            });

            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV0, Eq("_LME_Enable", 1), Eq("_LME_UVType", 0));
            RegisterOtherUVUsage(matInfo, UsingUVChannels.UV1, Eq("_LME_Enable", 1), Eq("_LME_UVType", 1));
        }

        private bool RegisterTextureUVUsage(MaterialInformationCallback matInfo, string propName, string samplerName, UsingUVChannels uv, Matrix2x3? st, System.Func<bool> cond = null)
        {
            if (HasShaderProperty(matInfo, propName))
            {
                if (cond == null || cond())
                {
                    matInfo.RegisterTextureUVUsage(propName, samplerName, uv, st);
                    return true;
                }
            }
            return false;
        }

        private bool RegisterTextureUVUsage(MaterialInformationCallback matInfo, string propName, string samplerName, UsingUVChannels uv, Matrix2x3? st, string enablePropName)
        {
            return RegisterTextureUVUsage(matInfo, propName, samplerName, uv, st, () => IsIntValue(matInfo, enablePropName, 1));
        }

        private bool RegisterOtherUVUsage(MaterialInformationCallback matInfo, UsingUVChannels uv, params System.Func<MaterialInformationCallback, bool>[] preds)
        {
            foreach(var p in preds)
            {
                if (!p(matInfo))
                {
                    return false;
                }
            }
            matInfo.RegisterOtherUVUsage(uv);
            return true;
        }

        private System.Func<MaterialInformationCallback, bool> Eq(string propName, params int[] values)
        {
            return matInfo => IsIntValue(matInfo, propName, values);
        }

        private bool IsIntValue(MaterialInformationCallback matInfo, string propName, params int[] values)
        {
            if (HasShaderProperty(matInfo, propName))
            {
                var val = matInfo.GetInt(propName);
                return val == null || values.Contains(val.Value); // アニメーションで変化するなら該当と判定する
            }
            return false;
        }

        private Matrix2x3? GetST(MaterialInformationCallback matInfo, string texPropName)
        {
            string propName = texPropName + "_ST";
            if (matInfo.GetVector(propName) is { } st)
            {
                return Matrix2x3.NewScaleOffset(st);
            }
            return null;
        }

        private UsingUVChannels GetUVType(MaterialInformationCallback matInfo, string propName)
        {
            if (HasShaderProperty(matInfo, propName))
            {
                return matInfo.GetInt(propName) switch
                {
                    0 => UsingUVChannels.UV0,
                    1 => UsingUVChannels.UV1,
                    _ => UsingUVChannels.UV0 | UsingUVChannels.UV1,
                };
            }
            return UsingUVChannels.Unknown;
        }

        private UsingUVChannels GetOVLUVType(MaterialInformationCallback matInfo, string propName)
        {
            if (HasShaderProperty(matInfo, propName))
            {
                switch(matInfo.GetInt(propName))
                {
                    case 0:
                        return UsingUVChannels.UV0;
                    case 1:
                        return UsingUVChannels.UV1;
                    case 2: // Skybox
                        return UsingUVChannels.NonMesh;
                    case 3: // AngelRing
                        return UsingUVChannels.NonMesh;
                    case 4: // Matcap
                        return UsingUVChannels.NonMesh;
                }
            }
            return UsingUVChannels.Unknown;
        }

        private bool HasShaderProperty(MaterialInformationCallback matInfo, string propName)
        {
            return WFAccessor.HasShaderProperty(shader, propName);
        }
    }
}

#endif
