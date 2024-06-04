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
