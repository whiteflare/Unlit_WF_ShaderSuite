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

#ifndef INC_UNLIT_WF_FAKEFUR_UNIFORM
#define INC_UNLIT_WF_FAKEFUR_UNIFORM

    #include "WF_UnToon_Uniform.cginc"

    ////////////////////////////
    // Texture & Sampler
    ////////////////////////////

    DECL_MAIN_TEX2D (_FR_NoiseTex);
    DECL_VERT_TEX2D (_FR_BumpMap);
    DECL_SUB_TEX2D  (_FR_MaskTex);

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

    float4          _FR_NoiseTex_ST;
    float           _FR_Height;
    float4          _FR_Vector;
    uint            _FR_FlipMirror;

    uint            _FR_Repeat;
    float           _FR_ShadowPower;

#endif
