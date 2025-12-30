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

#ifndef INC_UNLIT_WF_FAKEFUR_UNIFORM
#define INC_UNLIT_WF_FAKEFUR_UNIFORM

    #include "WF_UnToon_Uniform.cginc"

    ////////////////////////////
    // Texture & Sampler
    ////////////////////////////

    DECL_MAIN_TEX2D (_FUR_NoiseTex);
    DECL_VERT_TEX2D (_FUR_BumpMap);
    DECL_VERT_TEX2D (_FUR_LenMaskTex);
    DECL_SUB_TEX2D  (_FUR_MaskTex);

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

#ifndef _FUR_HEIGHT_PARAM
    #define _FUR_HEIGHT_PARAM _FUR_Height
#endif
#ifndef _FUR_REPEAT_PARAM
    #define _FUR_REPEAT_PARAM _FUR_Repeat
#endif

    float4          _FUR_NoiseTex_ST;
    half            _FUR_HEIGHT_PARAM;
    half4           _FUR_Vector;

    uint            _FUR_REPEAT_PARAM;
    half            _FUR_ShadowPower;
    half4           _FUR_TintColorBase;
    half4           _FUR_TintColorTip;
    half            _FUR_InvMaskVal;
    half            _FUR_InvLenMaskVal;
    half            _FUR_Random;

#endif
