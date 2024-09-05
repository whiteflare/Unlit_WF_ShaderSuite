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

#ifndef INC_UNLIT_WF_INPUT_GRASS
#define INC_UNLIT_WF_INPUT_GRASS

    #include "WF_Common.cginc"

    #ifndef WF_DEFINED_UNIFORM
    #define WF_DEFINED_UNIFORM

        CBUFFER_START(UnityPerMaterial)

        #include "WF_Grass_Uniform.cginc"

        CBUFFER_END

    #endif

    #ifndef _V2F_HAS_VERTEXCOLOR
        #if defined(_VC_ENABLE)
            #define _V2F_HAS_VERTEXCOLOR
        #endif
    #endif

    #ifndef _V2F_HAS_UV_LMAP
        #if defined(_AO_ENABLE)
            #define _V2F_HAS_UV_LMAP
        #endif
    #endif

#endif
