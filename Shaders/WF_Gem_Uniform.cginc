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

    half            _GMF_Enable;
    half            _GMF_FlakeSizeFront;
    half            _GMF_FlakeSizeBack;
    half            _GMF_FlakeShear;
    half            _GMF_FlakeBrighten;
    half            _GMF_FlakeDarken;
    half            _GMF_Twinkle;
    half            _GMF_BlendNormal;

    half            _GMR_Enable;
    half            _GMR_Power;
    half            _GMR_Brightness;
    half            _GMR_Monochrome;
    half4           _GMR_Cubemap_HDR;
    half            _GMR_CubemapPower;
    half            _GMR_CubemapHighCut;
    half            _GMR_BlendNormal;

    half            _AlphaFront;
    half            _AlphaBack;

    half            _GMB_Enable;
    half4           _GMB_ColorBack;

#endif
