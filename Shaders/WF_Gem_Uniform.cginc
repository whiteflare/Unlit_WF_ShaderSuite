/*
 *  The MIT License
 *
 *  Copyright 2018-2022 whiteflare.
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

#ifndef INC_UNLIT_WF_GEM_UNIFORM
#define INC_UNLIT_WF_GEM_UNIFORM

    #include "WF_UnToon_Uniform.cginc"

    ////////////////////////////
    // Texture & Sampler
    ////////////////////////////

    DECL_MAIN_TEXCUBE(_GMR_Cubemap);

    ////////////////////////////
    // Other uniform variable
    ////////////////////////////

    float           _GMF_Enable;
    float           _GMF_FlakeSizeFront;
    float           _GMF_FlakeSizeBack;
    float           _GMF_FlakeShear;
    float           _GMF_FlakeBrighten;
    float           _GMF_FlakeDarken;
    float           _GMF_Twinkle;
    float           _GMF_BlendNormal;

    float           _GMR_Enable;
    float           _GMR_Power;
    float           _GMR_Brightness;
    float           _GMR_Monochrome;
    float4          _GMR_Cubemap_HDR;
    float           _GMR_CubemapPower;
    float           _GMR_CubemapHighCut;
    float           _GMR_BlendNormal;

    float           _AlphaFront;
    float           _AlphaBack;

    float           _GMB_Enable;
    float4          _GMB_ColorBack;

#endif
