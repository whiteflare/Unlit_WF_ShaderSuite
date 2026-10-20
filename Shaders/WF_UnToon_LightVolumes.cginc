#if !defined(INC_UNLIT_WF_COMMON_VRCLV) && !defined(VRC_LIGHT_VOLUMES_INCLUDED)

#ifndef INC_UNLIT_WF_COMMON_VRCLV
    #define INC_UNLIT_WF_COMMON_VRCLV
#endif
#ifndef VRC_LIGHT_VOLUMES_INCLUDED
    #define VRC_LIGHT_VOLUMES_INCLUDED
#endif

    ////////////////////////////
    // LightVolumes.cginc より使用する定義をピックアップする
    ////////////////////////////
#ifndef VRCLV_FORCE_FULL_FEATURES
//  #include "Packages/red.sim.lightvolumes/Shaders/LightVolumesBuildConfig.cginc"
#endif

// Close parent dependencies here as well as in the scene editor. A host shader may
// supply just a parent opt-out, without including the generated scene configuration.
#if defined(VRCLV_DISABLE_REGULAR_VOLUMES)
    #ifndef VRCLV_DISABLE_LIGHT_PROBES_BLENDING
        #define VRCLV_DISABLE_LIGHT_PROBES_BLENDING
    #endif
    #ifndef VRCLV_DISABLE_SMOOTH_BOUNDS
        #define VRCLV_DISABLE_SMOOTH_BOUNDS
    #endif
    #if defined(VRCLV_DISABLE_ADDITIVE_VOLUMES) && !defined(VRCLV_DISABLE_VOLUME_ROTATION)
        #define VRCLV_DISABLE_VOLUME_ROTATION
    #endif
#endif

#if defined(VRCLV_DISABLE_POINT_LIGHTS)
    #define VRCLV_POINT_LIGHTS_SUPPORTED 0
    #ifndef VRCLV_DISABLE_POINT_COOKIES
        #define VRCLV_DISABLE_POINT_COOKIES
    #endif
#else
    #define VRCLV_POINT_LIGHTS_SUPPORTED 1
#endif

#if defined(VRCLV_DISABLE_SPOT_LIGHTS)
    #define VRCLV_SPOT_LIGHTS_SUPPORTED 0
    #ifndef VRCLV_DISABLE_SPOT_COOKIES
        #define VRCLV_DISABLE_SPOT_COOKIES
    #endif
    #ifndef VRCLV_DISABLE_SINGLE_SLICE_SHADOWS
        #define VRCLV_DISABLE_SINGLE_SLICE_SHADOWS
    #endif
#else
    #define VRCLV_SPOT_LIGHTS_SUPPORTED 1
#endif

#if defined(VRCLV_DISABLE_AREA_LIGHTS)
    #define VRCLV_AREA_LIGHTS_SUPPORTED 0
    #ifndef VRCLV_DISABLE_AREA_COOKIES
        #define VRCLV_DISABLE_AREA_COOKIES
    #endif
#else
    #define VRCLV_AREA_LIGHTS_SUPPORTED 1
#endif
#define VRCLV_LIGHTS_SUPPORTED (VRCLV_POINT_LIGHTS_SUPPORTED || VRCLV_SPOT_LIGHTS_SUPPORTED || VRCLV_AREA_LIGHTS_SUPPORTED)

#if !VRCLV_POINT_LIGHTS_SUPPORTED && !VRCLV_SPOT_LIGHTS_SUPPORTED && !defined(VRCLV_DISABLE_LIGHT_LUTS)
    #define VRCLV_DISABLE_LIGHT_LUTS
#endif
#if !VRCLV_LIGHTS_SUPPORTED
    #ifndef VRCLV_DISABLE_CLUSTERING
        #define VRCLV_DISABLE_CLUSTERING
    #endif
    #ifndef VRCLV_DISABLE_SHADOWS
        #define VRCLV_DISABLE_SHADOWS
    #endif
#endif

#if defined(VRCLV_DISABLE_SHADOWS)
    #ifndef VRCLV_DISABLE_CUBEMAP_SHADOWS
        #define VRCLV_DISABLE_CUBEMAP_SHADOWS
    #endif
    #ifndef VRCLV_DISABLE_SINGLE_SLICE_SHADOWS
        #define VRCLV_DISABLE_SINGLE_SLICE_SHADOWS
    #endif
#endif

// World-space shadows select a bake origin for a receiver; they are not a separate
// shadow projection. Keep the Shadows parent independent when both children are off.
#if defined(VRCLV_DISABLE_CUBEMAP_SHADOWS) && defined(VRCLV_DISABLE_SINGLE_SLICE_SHADOWS) && !defined(VRCLV_DISABLE_WORLD_SPACE_SHADOWS)
    #define VRCLV_DISABLE_WORLD_SPACE_SHADOWS
#endif

#define VRCLV_VERSION 3
#define VRCLV_MIN_SUPPORTED_VERSION 2
#define VRCLV_MAX_VOLUMES_COUNT 32
#define VRCLV_MAX_LIGHTS_COUNT 128

// Unity's surface-shader analysis uses [loop] because it rejects [fastopt].
#if defined(SHADER_TARGET_SURFACE_ANALYSIS)
    #define VRCLV_DYNAMIC_LOOP [loop]
#else
    #define VRCLV_DYNAMIC_LOOP [fastopt]
#endif

CBUFFER_START(LightVolumeUniforms)

// Are Light Volumes enabled in the scene? Can be 0 or 1
uniform float _UdonLightVolumeEnabled;

// Returns 1, 2 or other number if there are light volumes on the scene. Number represents the light volumes system internal version number.
uniform float _UdonLightVolumeVersion;

// Total volume count in the scene
uniform float _UdonLightVolumeCount;

// Additive volumes max overdraw count
uniform float _UdonLightVolumeAdditiveMaxOverdraw;

// Additive volumes count
uniform float _UdonLightVolumeAdditiveCount;

// Should volumes be blended with lightprobes?
uniform float _UdonLightVolumeProbesBlend;

// Should volumes be with sharp edges when not blending with each other
uniform float _UdonLightVolumeSharpBounds;

// Point Lights count
uniform float _UdonPointLightVolumeCount;

// Cubemaps count in the custom textures array
uniform float _UdonPointLightVolumeCubeCount;

// Shadow cubemaps count in the shadow texture array
uniform float _UdonPointLightVolumeShadowCubeCount;

// Precomputed v3 EVSM receiver constants. XW = variance bias * positive/negative exponent,
// Y = -edge / (1 - edge), Z = 1 / (1 - edge). V2 managers never enter the EVSM path.
uniform float4 _UdonPointLightVolumeShadowReceiverParams;

// Texel count and max mip for Area Light with cookie
uniform float _UdonPointLightVolumeTextureTexelCount;
uniform float _UdonPointLightVolumeTextureMaxMip;
// World to Local (-0.5, 0.5) UVW Matrix 4x4
uniform float4x4 _UdonLightVolumeInvWorldMatrix[VRCLV_MAX_VOLUMES_COUNT];

// L1 SH matrix rotation relative to baked rotation. Stores row 0 and row 1; row 2 is reconstructed in shader.
uniform float4 _UdonLightVolumeRotation[VRCLV_MAX_VOLUMES_COUNT * 2];

// Value that is needed to smoothly blend volumes ( BoundsScale / edgeSmooth )
uniform float3 _UdonLightVolumeInvLocalEdgeSmooth[VRCLV_MAX_VOLUMES_COUNT];

// AABB bounds of islands on the 3D Texture atlas. XYZ: UvwMin, W: Scale per axis
uniform float4 _UdonLightVolumeUvwScale[VRCLV_MAX_VOLUMES_COUNT * 3];

// Color multiplier (RGB) | If we actually need to rotate L1 components at all (A)
uniform float4 _UdonLightVolumeColor[VRCLV_MAX_VOLUMES_COUNT];

// For World Space Shadows:
//   XYZ = shadow bake position in world space.
//   W = shadow projection tangent half-angle for single texture shadows, or negative inverse depth range fallback for cubemaps.
uniform float4 _UdonPointLightVolumeShadowReprojectionData[VRCLV_MAX_LIGHTS_COUNT];

//   XYZW = Rotation from current world space to baked shadow space.
uniform float4 _UdonPointLightVolumeShadowRotationData[VRCLV_MAX_LIGHTS_COUNT];

CBUFFER_END

CBUFFER_START(PointLightVolumeUniforms)


CBUFFER_END

// For point light: XYZ = Position, W = Inverse squared range
// For spot light: XYZ = Position, W = Inverse squared range, negated
// For area light: XYZ = Position, W = Width
uniform float4 _UdonPointLightVolumePosition[VRCLV_MAX_LIGHTS_COUNT];

// For point light: XYZ = Color, W = Cos of angle (for LUT)
// For spot light: XYZ = Color, W = Cos of outer angle if no custom texture, tan of outer angle otherwise
// For area light: XYZ = Color, W = 2 + Height
uniform float4 _UdonPointLightVolumeColor[VRCLV_MAX_LIGHTS_COUNT];

// Shared extra point-light data. Area cookies use RGB = Color * Intensity. Custom spot cookies use X = width / height aspect. Single-slice Spot shadows use Y = projection tangent. W = shadow near clip.
uniform float4 _UdonPointLightVolumeExtraData[VRCLV_MAX_LIGHTS_COUNT];

// For point light: XYZW = Rotation quaternion
// For spot light: XYZ = Direction, W = Cone falloff
// For area light: XYZW = Rotation quaternion
uniform float4 _UdonPointLightVolumeDirection[VRCLV_MAX_LIGHTS_COUNT];

// X = Custom ID:
//   If parametric: X stores 0
//   If uses custom lut: X stores LUT ID with positive sign
//   If uses custom texture: X stores texture ID with negative sign
// Y = shadow map ID. Fraction stores inverted shading strength. Abs >= 10000 disables shading.
// Z = Squared Culling Range. Just a precalculated culling range to not recalculate it in shader.
// W = signed inverse depth range for v3 Point and Spot shadows. A negative value marks a world-space shadow whose bake origin exactly matches the light position.
// Area Cookie keeps its tag/mirror enum here: 0 none/legacy, +1 none, -1 X, +2 Y, -2 XY. Near clip is stored in ExtraData.W.
uniform float4 _UdonPointLightVolumeCustomID[VRCLV_MAX_LIGHTS_COUNT];


// Main 3D Texture atlas
uniform Texture3D _UdonLightVolume;
uniform SamplerState sampler_UdonLightVolume;

// First elements must be cubemap faces (6 face textures per cubemap). Other textures follow.
uniform Texture2DArray _UdonPointLightVolumeTexture;
uniform SamplerState sampler_UdonPointLightVolumeTexture;

// First elements are baked shadow cubemap faces, 6 face textures per cubemap.
uniform Texture2DArray _UdonPointLightVolumeShadowTexture;
uniform SamplerState sampler_UdonPointLightVolumeShadowTexture;

// Samples textures using mip 0. Shadow maps keep their own sampler state so they always use the shadow texture wrap mode.
#define LV_SAMPLE(tex, uvw) tex.SampleLevel(sampler_UdonLightVolume, uvw, 0)
#define LV_SAMPLE_POINT(uvw) _UdonPointLightVolumeTexture.SampleLevel(sampler_UdonPointLightVolumeTexture, uvw, 0)
#define LV_SAMPLE_POINT_LOD(uvw, lod) _UdonPointLightVolumeTexture.SampleLevel(sampler_UdonPointLightVolumeTexture, uvw, lod)
#define LV_SAMPLE_SHADOW(uvw) _UdonPointLightVolumeShadowTexture.SampleLevel(sampler_UdonPointLightVolumeShadowTexture, uvw, 0)

#define LV_PI 3.141592653589793f
#define LV_INV_PI 0.3183098861837907f
#define LV_EVSM_POSITIVE_EXPONENT 5.54f
#define LV_EVSM_NEGATIVE_EXPONENT 5.0f

// Smoothstep to 0, 1 but cheaper
inline float LV_Smoothstep01(float x) {
    return x * x * (3 - 2 * x);
}

// Rotates vector by Quaternion
inline float3 LV_MultiplyVectorByQuaternion(float3 v, float4 q) {
    float3 t = 2 * cross(q.xyz, v);
    return v + q.w * t + cross(q.xyz, t);
}

// Builds orthonormal axes from a normalized quaternion
inline void LV_QuaternionAxes(float4 q, out float3 xAxis, out float3 yAxis, out float3 zAxis) {
    float x2 = q.x + q.x, y2 = q.y + q.y, z2 = q.z + q.z;
    float xx = q.x * x2, yy = q.y * y2, zz = q.z * z2;
    float xy = q.x * y2, xz = q.x * z2, yz = q.y * z2;
    float wx = q.w * x2, wy = q.w * y2, wz = q.w * z2;
    xAxis = float3(1 - yy - zz, xy + wz, xz - wy);
    yAxis = float3(xy - wz, 1 - xx - zz, yz + wx);
    zAxis = float3(xz + wy, yz - wx, 1 - xx - yy);
}

// Rotates vector by Matrix 3x3 with precomputed third axis
inline float3 LV_MultiplyVectorByMatrix3x3(float3 v, float3 r0, float3 r1, float3 r2) {
    return float3(dot(v, r0), dot(v, r1), dot(v, r2));
}

// Fast approximate arctangent for positive values. Max error is small enough for area light attenuation
inline float LV_FastAtanPositive(float x) {
    // atan(x) = PI/2 - atan(1/x) keeps the polynomial input in [0, 1].
    bool small = x <= 1;
    float invX = rcp(x);
    float t = small ? x : invX;
    float atanT = t * (LV_PI * 0.25 + 0.2730815 * (1 - t));
    return small ? atanT : LV_PI * 0.5 - atanT;
}


// Checks if local UVW point is in bounds from -0.5 to +0.5
inline bool LV_PointLocalAABB(float3 localUVW) {
    return all(abs(localUVW) <= 0.5);
}

// Calculates local UVW using volume ID
inline float3 LV_LocalFromVolume(uint volumeID, float3 worldPos) {
    return mul(_UdonLightVolumeInvWorldMatrix[volumeID], float4(worldPos, 1)).xyz;
}

// Projects a cubemap direction into face index and face UV. (xy: uv, z: face)
inline float3 LV_CubemapUvFace(float3 dir) {
    float2 uv;
    float face;
    float3 absDir = abs(dir);
    // Select the face numerator before dividing: flattened face branches otherwise keep
    // three reciprocal results live. Equal magnitudes use X/Y/Z tie priority.
    float majorAxis = max(absDir.x, max(absDir.y, absDir.z));
    [flatten] if (absDir.x == majorAxis) {
        face = dir.x > 0 ? 0 : 1;
        uv = float2((dir.x > 0 ? -dir.z : dir.z), -dir.y);
    } else [flatten] if (absDir.y == majorAxis) {
        face = dir.y > 0 ? 2 : 3;
        uv = float2(dir.x, (dir.y > 0 ? dir.z : -dir.z));
    } else {
        face = dir.z > 0 ? 4 : 5;
        uv = float2((dir.z > 0 ? dir.x : -dir.x), -dir.y);
    }
    uv *= rcp(majorAxis);
    return float3(uv * 0.5 + 0.5, face);
}

// Samples a cubemap from _UdonPointLightVolumeTexture array
inline float4 LV_SampleCubemapArray(uint id, float3 dir) {
    return LV_SAMPLE_POINT(LV_CubemapUvFace(dir) + float3(0, 0, id * 6));
}

// Shared EVSM warp and Chebyshev evaluation.
inline float LV_ShadowEVSMCore(float4 moments, float shadowDepth, float2 varianceScale, float bleedBias, float bleedScale) {
    float2 evsmExponents = float2(LV_EVSM_POSITIVE_EXPONENT, LV_EVSM_NEGATIVE_EXPONENT);
    float2 warpedDepth = exp2(evsmExponents * float2(shadowDepth, -shadowDepth) * 1.4426950408889634f) * float2(1.0f, -1.0f);
    float2 momentMean = moments.xy;
    float2 momentSq = moments.zw;
    float2 depthScale = varianceScale * warpedDepth;
    float2 minVariance = depthScale * depthScale;
    float2 variance = max(momentSq - momentMean * momentMean, minVariance);
    float2 d = warpedDepth - momentMean;
    float2 pMax = variance / (variance + d * d);
    float2 visibility = saturate(pMax * bleedScale + bleedBias);
    // step is binary and visibility is saturated, so max is the exact lit-side select.
    visibility = max(visibility, step(warpedDepth, momentMean));
    return LV_Smoothstep01(min(visibility.x, visibility.y));
}

// Evaluates EVSM filtered visibility using precomputed receiver parameters and reciprocal depth range.
inline float LV_ShadowEVSMInvRange(float4 moments, float distanceToShadowCenter, float nearClip, float invDepthRange) {
    float normalizedDepth = saturate((distanceToShadowCenter - nearClip) * invDepthRange);
    float shadowDepth = normalizedDepth * 2.0f - 1.0f;
    return LV_ShadowEVSMCore(moments, shadowDepth, _UdonPointLightVolumeShadowReceiverParams.xw,
        _UdonPointLightVolumeShadowReceiverParams.y, _UdonPointLightVolumeShadowReceiverParams.z);
}

// Samples the shared Spot/Area shadow layout. Area retains its legacy reprojection payload.
inline float LV_PointLightShadow(uint id, float3 worldPos, float3 lightVector, float sqDistanceToLight, float invDistanceToLight, float shadowNearClip, float localSingleShadowTanAngle, float signedShadowInvDepthRange, float shadowIdData, uint shadowId, bool forceCubemapShadow) {
    uint shadowCubeCount = (uint)_UdonPointLightVolumeShadowCubeCount;
    bool rotateSampleDir = false;
    #if defined(VRCLV_DISABLE_SINGLE_SLICE_SHADOWS)
    bool isSingleShadow = false;
    #elif defined(VRCLV_DISABLE_CUBEMAP_SHADOWS)
    bool isSingleShadow = !forceCubemapShadow;
    #else
    bool isSingleShadow = !forceCubemapShadow && shadowId >= shadowCubeCount;
    #endif
    bool reuseWorldShadowOrigin = signedShadowInvDepthRange < 0;
    float receiverInvDepthRange = abs(signedShadowInvDepthRange);
    float lightDistance = sqDistanceToLight * invDistanceToLight;
    float3 sampleDir = isSingleShadow ? 0.0f : lightVector; // Projected UVs are scale-invariant; depth uses lightDistance.
    float distanceToShadowCenter = isSingleShadow ? 0.0f : lightDistance;
    float shadowTanAngle = localSingleShadowTanAngle;
    float4 shadowReprojectionData = 0;

    // Local and manager-tagged same-origin world shadows reuse the current light vector.
    // The distance guard preserves legacy reprojection for a degenerate same-origin vector.
    #ifndef VRCLV_DISABLE_WORLD_SPACE_SHADOWS
    bool reuseLightVector = shadowIdData < 0 || (reuseWorldShadowOrigin && sqDistanceToLight > 0.0001);
    [branch] if (reuseLightVector)
    #endif
    {
        // Area keeps its legacy cubemap inverse depth range in reprojection W; Point/Spot carry it in CustomID.W.
        #ifdef VRCLV_DISABLE_WORLD_SPACE_SHADOWS
        if (forceCubemapShadow)
        #else
        if (forceCubemapShadow && shadowIdData < 0)
        #endif
        {
            shadowReprojectionData = _UdonPointLightVolumeShadowReprojectionData[id];
        }
        distanceToShadowCenter = lightDistance;
        sampleDir = lightVector;
        rotateSampleDir = true;
    }
    #ifndef VRCLV_DISABLE_WORLD_SPACE_SHADOWS
    else { // Distinct world-space bake origin, Area light, or legacy degenerate same-origin vector
        shadowReprojectionData = _UdonPointLightVolumeShadowReprojectionData[id];
        shadowTanAngle = shadowReprojectionData.w;
        float3 bakeDir = shadowReprojectionData.xyz - worldPos;
        float bakeSqLen = dot(bakeDir, bakeDir);
        [branch] if (bakeSqLen > 0.0001) { // Ignore degenerate vectors before normalizing baked direction
            distanceToShadowCenter = sqrt(bakeSqLen);
            // Cubemap-face and projected-spot UVs are scale-invariant; only depth needs the normalized length.
            sampleDir = bakeDir;
            rotateSampleDir = true;
        }
    }
    #endif

    // Fetch the quaternion only after selecting the raw vector. The degenerate baked-origin
    // fallback must remain unrotated, including the zero vector used by single-slice shadows.
    [branch] if (rotateSampleDir) sampleDir = LV_MultiplyVectorByQuaternion(sampleDir, _UdonPointLightVolumeShadowRotationData[id]);

    float attenuation = 1;
    float3 shadowUVW = 0;
    float invDepthRange = 0;
    bool hasShadowSample = false;
    #ifndef VRCLV_DISABLE_SINGLE_SLICE_SHADOWS
    [branch] if (isSingleShadow) { // Single slice shadows
        [branch] if (sampleDir.z < 0) { // Signless single-slice coordinates point down negative Z
            float shadowDenominator = sampleDir.z * max(shadowTanAngle, 0.0001f);
            // Cull outside the projected shadow slice before division and texture sampling.
            [branch] if (max(abs(sampleDir.x), abs(sampleDir.y)) <= -shadowDenominator) {
                float2 uv = sampleDir.xy / shadowDenominator;
                shadowUVW = float3(uv * 0.5 + 0.5, shadowId + shadowCubeCount * 5);
                invDepthRange = receiverInvDepthRange;
                hasShadowSample = true;
            }
        }
    }
    #ifndef VRCLV_DISABLE_CUBEMAP_SHADOWS
    else
    #endif
    #endif
    #ifndef VRCLV_DISABLE_CUBEMAP_SHADOWS
    { // Cubemap shadows
        float3 uvFace = LV_CubemapUvFace(sampleDir);
        shadowUVW = float3(uvFace.xy, shadowId * 6 + (uint)uvFace.z);
        invDepthRange = forceCubemapShadow ? -shadowReprojectionData.w : receiverInvDepthRange;
        hasShadowSample = true;
    }
    #endif

    [branch] if (hasShadowSample) {
        attenuation = LV_ShadowEVSMInvRange(LV_SAMPLE_SHADOW(shadowUVW), distanceToShadowCenter, shadowNearClip, invDepthRange);
    }
    return attenuation;
}

// V3 Point lights are always cubemap shadows and carry inverse depth range in CustomID.W.
inline float LV_PointLightShadowPackedCube(uint id, float3 worldPos, float3 lightVector, float sqDistanceToLight, float invDistanceToLight, float shadowNearClip, float signedShadowInvDepthRange, float shadowIdData, uint shadowId) {
    #ifdef VRCLV_DISABLE_CUBEMAP_SHADOWS
    return 1;
    #else
    float4 shadowRotationData = _UdonPointLightVolumeShadowRotationData[id];
    bool reuseWorldShadowOrigin = signedShadowInvDepthRange < 0;
    float receiverInvDepthRange = abs(signedShadowInvDepthRange);
    float lightDistance = sqDistanceToLight * invDistanceToLight;
    float3 sampleDir = lightVector; // Cubemap lookup is scale-invariant.
    float distanceToShadowCenter = lightDistance;

    // Local and nondegenerate manager-tagged same-origin shadows reuse the current vector;
    // all other world shadows reconstruct it from the baked origin.
    #ifdef VRCLV_DISABLE_WORLD_SPACE_SHADOWS
    sampleDir = LV_MultiplyVectorByQuaternion(lightVector, shadowRotationData);
    #else
    [branch] if (shadowIdData < 0 || (reuseWorldShadowOrigin && sqDistanceToLight > 0.0001)) {
        sampleDir = LV_MultiplyVectorByQuaternion(lightVector, shadowRotationData);
    } else { // Distinct world-space bake origin or legacy degenerate same-origin vector
        float3 bakeDir = _UdonPointLightVolumeShadowReprojectionData[id].xyz - worldPos;
        float bakeSqLen = dot(bakeDir, bakeDir);
        [branch] if (bakeSqLen > 0.0001) {
            distanceToShadowCenter = sqrt(bakeSqLen);
            sampleDir = LV_MultiplyVectorByQuaternion(bakeDir, shadowRotationData);
        }
    }
    #endif

    float3 uvFace = LV_CubemapUvFace(sampleDir);
    float3 shadowUVW = float3(uvFace.xy, shadowId * 6 + (uint)uvFace.z);
    return LV_ShadowEVSMInvRange(LV_SAMPLE_SHADOW(shadowUVW), distanceToShadowCenter, shadowNearClip, receiverInvDepthRange);
    #endif
}

// Projects a front-facing quad light into L1 SH using a cheap solid-angle approximation.
// Caller must cull localPos.z <= 0 before calling.
inline float4 LV_ProjectFastQuadLightIrradianceSH(float3 lightToWorldPos, float3 localPos, float centerSqDist, float3 xAxis, float3 yAxis, float2 size, out float3 pointLightShadingDir) {
    float2 halfSize = size * 0.5;
    float area = max(size.x * size.y, 1e-6);
    float extentSq = max(dot(halfSize, halfSize), 1e-6);

    float2 closestXY = clamp(localPos.xy, -halfSize, halfSize);
    float2 rectDelta = localPos.xy - closestXY;
    float rectDeltaSq = dot(rectDelta, rectDelta);
    float planeRectSq = rectDeltaSq + localPos.z * localPos.z;
    float closestSqDist = max(planeRectSq, 1e-6);
    float distanceBlend = planeRectSq * rcp(planeRectSq + extentSq);
    float solidSqDist = lerp(closestSqDist, centerSqDist, distanceBlend);
    float invSolidDist = rsqrt(solidSqDist);
    float invExtendedDist = rsqrt(solidSqDist + extentSq);

    float solidAngle = LV_FastAtanPositive(area * localPos.z * invSolidDist * invSolidDist * invExtendedDist * 0.25);
    float l0 = solidAngle * LV_INV_PI;

    float2 representativeXY = lerp(closestXY, 0, distanceBlend);
    float3 dir = xAxis * representativeXY.x + yAxis * representativeXY.y - lightToWorldPos;
    dir *= rsqrt(max(dot(dir, dir), 1e-6));
    pointLightShadingDir = dir;
    return float4(dir * saturate(1 - l0), l0);
}

// Calculates point light attenuation.
inline float3 LV_PointLightAttenuation(float sqdist, float sqlightSize, float3 color, float sqMaxDist) {
    float mask = saturate(1 - sqdist * rcp(sqMaxDist));
    return mask * mask * color * sqlightSize * rcp(sqdist + sqlightSize);
}

// Calculates Point Light shading for the normal mask using a pre-scaled surface normal and precomputed bias.
inline float LV_PointLightShading(float3 pointLightShadingNormal, float pointLightShadingBias, float3 lightDirNormal) {
    float ramp = dot(pointLightShadingNormal, lightDirNormal) + pointLightShadingBias;
    return LV_Smoothstep01(saturate(ramp));
}

// Resolves spot cookie UV and culls fragments outside the projected cookie before expensive shadow work.
inline float2 LV_SphereSpotLightCookieUv(float3 lightDir, float4 lightRot, float tanAngle) {
    float3 localDir = LV_MultiplyVectorByQuaternion(-lightDir, lightRot);
    if (localDir.z <= 0) return 2; // Outside the cookie bounds.
    else return localDir.xy * rcp(localDir.z * tanAngle);
}

// Samples a textured area emitter as a prefiltered mip-chain average: local high-frequency detail is blended with all available coarser mip levels to approximate the solid-angle tail from neighboring texels.
// Based on textured LTC prefiltering and filtered importance sampling:
// https://eheitzresearch.wordpress.com/415-2/
// https://developer.nvidia.com/gpugems/gpugems3/part-iii-rendering/chapter-20-gpu-based-importance-sampling
inline float4 LV_AreaLightCookie(float3 localPos, float invDist, float2 size, uint textureId) {
    float2 safeSize = max(size, float2(0.0001, 0.0001));
    float2 halfSize = safeSize * 0.5;
    float2 closestXY = clamp(localPos.xy, -halfSize, halfSize);
    float2 rectDelta = localPos.xy - closestXY;
    float planeRectSq = dot(rectDelta, rectDelta) + localPos.z * localPos.z;
    float lightArea = max(safeSize.x * safeSize.y, 0.000001);
    float invLightArea = rcp(lightArea);
    float textureTexelCount = max(_UdonPointLightVolumeTextureTexelCount, 1.0);
    float filterAreaRatio = max(planeRectSq * (LV_PI * invLightArea), rcp(textureTexelCount));
    float texelsCovered = max(filterAreaRatio * textureTexelCount, 1.0);
    float shapeBlend = saturate(sqrt(filterAreaRatio));
    float2 representativeXY = closestXY * (1.0 - shapeBlend);

    float2 edgeUv = abs(representativeXY) * (2.0 * rcp(safeSize));
    float edgeBlend = LV_Smoothstep01(saturate((max(edgeUv.x, edgeUv.y) - 0.65) * 2.8571429));
    float grazingBlend = saturate(1 - abs(localPos.z) * invDist);
    float mip = 0.5 * log2(texelsCovered) + edgeBlend * grazingBlend * (1.0 - shapeBlend) * 2.0;
    float maxMip = max(_UdonPointLightVolumeTextureMaxMip, 0.0);
    mip = min(mip, maxMip);

    float2 uv = representativeXY * rcp(safeSize) + 0.5;
    uv.x = 1.0 - uv.x;

    // Empirical four-tap mip blend; 0.36363636 normalizes weights 1 + 0.75 + 0.55 + 0.45.
    // The last mip needs only one sample.
    float4 tap1Cookie = LV_SAMPLE_POINT_LOD(float3(uv, textureId), mip);
    float3 emission = tap1Cookie.rgb * tap1Cookie.a;
    [branch] if (mip < maxMip) {
        float mipRange = maxMip - mip;
        float tap2Mip = mip + mipRange * 0.3;
        float tap3Mip = mip + mipRange * 0.5;
        float4 tap2Cookie = LV_SAMPLE_POINT_LOD(float3(uv, textureId), tap2Mip);
        float4 tap3Cookie = LV_SAMPLE_POINT_LOD(float3(uv, textureId), tap3Mip);
        float4 tap4Cookie = LV_SAMPLE_POINT_LOD(float3(uv, textureId), maxMip);
        float3 tap2Emission = tap2Cookie.rgb * tap2Cookie.a;
        float3 tap3Emission = tap3Cookie.rgb * tap3Cookie.a;
        float3 tap4Emission = tap4Cookie.rgb * tap4Cookie.a;
        emission = (emission + tap2Emission * 0.75 + tap3Emission * 0.55 + tap4Emission * 0.45) * 0.36363636;
    }
    return float4(emission, 1.0);
}

// Resolves point-light normal shading and baked shadows. lightVector samples shadows, normalMaskLightDir attenuates by surface normal.
// Returns false only for a normal-mask rejection before baked-shadow sampling.
// An exact-zero EVSM result still returns true because shadow sampling already consumed the overdraw budget.
inline bool LV_PointLightVolumeShadowMask(uint id, float shadowIdData, float shadowInvDepthRange, float3 worldPos, float3 lightVector, float3 normalMaskLightDir, float distSq, float invDist, float3 pointLightShadingNormal, float pointLightShadingBias, bool forceCubemapShadow, bool packedPointCube, out float shadow) {
    float shadowIdAbs = abs(shadowIdData);
    float normalAttenuation = 1;
    [flatten] if (pointLightShadingBias >= 0 && shadowIdAbs < 10000) {
        normalAttenuation = LV_PointLightShading(pointLightShadingNormal, pointLightShadingBias, normalMaskLightDir);
    }
    // Keep values crossing flattened control flow numeric for Unity HLSLcc. A bool phi/select can produce invalid GLES3 bitcasts.
    float shadowVisible;
    // Keep the common normal-only path free of strength decoding and shadow receiver state.
    // Use one return: early returns trigger FXC/HLSLcc uninitialized-output warnings in legacy targets.
    [branch] if (shadowIdData == 0) {
        shadow = normalAttenuation;
        shadowVisible = normalAttenuation > 0 ? 1.0 : 0.0;
    } else {
        shadow = 1;
        shadowVisible = 1.0;
        // Abs >= 10000 disables both surface-normal shading and baked shadows.
        [branch] if (shadowIdAbs < 10000) {
            float shadingStrength = 1 - frac(shadowIdAbs);
            // Partial-strength shading and exact-zero EVSM results still consume an overdraw slot.
            shadowVisible = (normalAttenuation > 0 || shadingStrength < 1) ? 1.0 : 0.0;
            float shadowAttenuation = 1;
            #if !defined(VRCLV_DISABLE_SHADOWS) && (!defined(VRCLV_DISABLE_CUBEMAP_SHADOWS) || !defined(VRCLV_DISABLE_SINGLE_SLICE_SHADOWS))
            [branch] if (shadowVisible > 0 && shadowIdAbs >= 1 && _UdonLightVolumeVersion >= 3) {
                uint shadowIndex = (uint)shadowIdAbs - 1;
                if (packedPointCube) {
                    shadowAttenuation = LV_PointLightShadowPackedCube(id, worldPos, lightVector, distSq, invDist, _UdonPointLightVolumeExtraData[id].w, shadowInvDepthRange, shadowIdData, shadowIndex);
                } else {
                    float4 shadowExtraData = _UdonPointLightVolumeExtraData[id];
                    shadowAttenuation = LV_PointLightShadow(id, worldPos, lightVector, distSq, invDist, shadowExtraData.w, shadowExtraData.y, shadowInvDepthRange, shadowIdData, shadowIndex, forceCubemapShadow);
                }
            }
            #endif
            shadow = lerp(1.0, saturate(normalAttenuation + shadowAttenuation - 1.0), shadingStrength);
        }
    }
    return shadowVisible > 0;
}

// Samples one Point Light Volume. Returns true once the light reaches shadow/contribution evaluation.
// Range, cone, projected-cookie-bounds and backface rejects do not consume an overdraw slot.
// Outputs: l0 = RGB irradiance, l1 = SH L1 direction term, lightDirNormal = center direction, specularSpreadSq = visible source size, shadow = normal mask and shadow
bool LV_PointLightVolumeContribution(uint id, float3 worldPos, float3 pointLightShadingNormal, float pointLightShadingBias, out float3 l0, out float3 l1, out float3 lightDirNormal, out float specularSpreadSq, out float shadow) {

    l0 = 0; l1 = 0; lightDirNormal = 0; specularSpreadSq = 0; shadow = 1;
    bool counted = false;

    #if VRCLV_LIGHTS_SUPPORTED
    // IDs and range data
    float4 pos = _UdonPointLightVolumePosition[id]; // Light position and squared source size or range data
    float3 dir = pos.xyz - worldPos;
    float distSq = max(dot(dir, dir), 1e-6);
    float4 customID_data = _UdonPointLightVolumeCustomID[id];
    float rangeSq = customID_data.z; // Squared culling distance

    [branch] if (distSq <= rangeSq) { // In-range light. Out-of-range lights keep zero outputs and do not consume an overdraw slot
        int customId = (int) customID_data.x; // Custom Texture ID
        float4 color = _UdonPointLightVolumeColor[id]; // Color, angle

        #if VRCLV_SPOT_LIGHTS_SUPPORTED && (VRCLV_POINT_LIGHTS_SUPPORTED || VRCLV_AREA_LIGHTS_SUPPORTED)
        bool nonNegativeLight = pos.w >= 0;
        #endif
        #if VRCLV_POINT_LIGHTS_SUPPORTED
        #if VRCLV_SPOT_LIGHTS_SUPPORTED && VRCLV_AREA_LIGHTS_SUPPORTED
        [branch] if (nonNegativeLight && color.w <= 1.5) // Point light. Non-negative pos.w selects point-light sign, and color.w <= 1.5 excludes area lights
        #elif VRCLV_SPOT_LIGHTS_SUPPORTED
        [branch] if (nonNegativeLight) // No Area lights: the position sign alone distinguishes Point and Spot.
        #elif VRCLV_AREA_LIGHTS_SUPPORTED
        [branch] if (color.w <= 1.5) // No Spot lights: the color tag alone distinguishes Point and Area.
        #endif
        {
            float invDist = rsqrt(distSq);
            float3 lightDir = dir * invDist;

            bool pointVisible = LV_PointLightVolumeShadowMask(id, customID_data.y, customID_data.w, worldPos, dir, lightDir, distSq, invDist, pointLightShadingNormal, pointLightShadingBias, true, true, shadow);
            counted = pointVisible;

            // Globally black lights are removed by the manager; skip per-pixel work behind a fully occluding shadow.
            [branch] if (shadow > 0) {
                lightDirNormal = lightDir;
                #ifndef VRCLV_DISABLE_LIGHT_LUTS
                [branch] if (customId > 0) { // Point light with a baked attenuation LUT
                    float dirRadius = distSq * pos.w;
                    uint textureId = (uint) _UdonPointLightVolumeCubeCount * 5 + customId;
                    float3 att = color.rgb * LV_SAMPLE_POINT(float3(0, sqrt(dirRadius), textureId)).xyz;
                    l0 = att;
                    l1 = lightDir;
                } else
                #endif
                { // Analytic point light, optionally tinted by a cubemap cookie
                    float invLightDist = rsqrt(distSq + pos.w); // Only surviving analytic receivers need finite-source normalization.
                    float invLightDistSq = invLightDist * invLightDist;
                    float rangeMask = saturate(1 - distSq * rcp(rangeSq));
                    float3 att = color.rgb * (rangeMask * rangeMask * pos.w * invLightDistSq);
                    specularSpreadSq = pos.w * invDist * invDist;
                    // Unnormalized dir combines the normalized light direction with its finite-source solid-angle coefficient.
                    l1 = dir * invLightDist;
                    #ifndef VRCLV_DISABLE_POINT_COOKIES
                    [branch] if (customId < 0) { // Point light with cubemap cookie. Cubemap ID starts from zero and should not include single texture array slices count
                        l0 = att * LV_SampleCubemapArray((uint)(-customId - 1), LV_MultiplyVectorByQuaternion(lightDir, _UdonPointLightVolumeDirection[id])).xyz;
                    } else
                    #endif
                    { // Plain analytic point light without custom texture data.
                        l0 = att;
                    }
                }
            }
        }
        #if VRCLV_SPOT_LIGHTS_SUPPORTED || VRCLV_AREA_LIGHTS_SUPPORTED
        else
        #endif
        #endif
        #if VRCLV_SPOT_LIGHTS_SUPPORTED || VRCLV_AREA_LIGHTS_SUPPORTED
        { // Non-point light. Split into spot lights and area lights when both are present.
            #if VRCLV_SPOT_LIGHTS_SUPPORTED
            #if VRCLV_AREA_LIGHTS_SUPPORTED
            [branch] if (!nonNegativeLight) // Spot light. Negative pos.w selects spot-light sign, magnitude is source size or LUT inverse range
            #endif
            {

                float invDist = rsqrt(distSq);
                float3 lightDir = dir * invDist;
                float angle = color.w;
                float spotMask = 0;
                float spotConeFalloff = 0;
                float2 cookieUv = 0;
                bool spotVisible = true;

                #ifndef VRCLV_DISABLE_SPOT_COOKIES
                [branch] if (customId >= 0) // Parametric or LUT spot light. Direction vector and cone falloff are stored directly
                #endif
                {
                    float4 directionData = _UdonPointLightVolumeDirection[id]; // Dir + falloff
                    spotMask = dot(directionData.xyz, -lightDir) - angle;
                    spotVisible = spotMask >= 0;
                    spotConeFalloff = directionData.w;
                }
                #ifndef VRCLV_DISABLE_SPOT_COOKIES
                else { // Textured spot light. Rotation projects the light direction into cookie UV space
                    float4 directionData = _UdonPointLightVolumeDirection[id]; // Rotation
                    cookieUv = LV_SphereSpotLightCookieUv(lightDir, directionData, angle);
                    float cookieAspect = _UdonLightVolumeVersion < 3 ? 1.0 : max(_UdonPointLightVolumeExtraData[id].x, 0.001);
                    cookieUv.y *= cookieAspect;
                    spotVisible = all(abs(cookieUv) <= 1);
                }
                #endif

                [branch] if (spotVisible) { // Spot receiver is inside the parametric cone or inside the projected cookie rectangle
                    // Spot light is not fully culled by surface-normal shading or shadow visibility
                    bool lightVisible = LV_PointLightVolumeShadowMask(id, customID_data.y, customID_data.w, worldPos, dir, lightDir, distSq, invDist, pointLightShadingNormal, pointLightShadingBias, false, false, shadow);
                    counted = lightVisible;
                    // Manager removes globally black lights; this per-pixel branch skips contribution work behind an EVSM shadow.
                    [branch] if (shadow > 0) {
                        lightDirNormal = lightDir;

                        #ifndef VRCLV_DISABLE_LIGHT_LUTS
                        [branch] if (customId > 0) { // Spot light with Attenuation LUT. LUT already includes cone attenuation
                            float dirRadius = distSq * -pos.w;
                            float spot = 1 - saturate(spotMask * rcp(1 - angle));
                            uint textureId = (uint) _UdonPointLightVolumeCubeCount * 5 + customId - 1;
                            float3 att = color.rgb * LV_SAMPLE_POINT(float3(sqrt(float2(spot, dirRadius)), textureId)).xyz;
                            l0 = att;
                            l1 = lightDir;
                        } else
                        #endif
                        { // Analytic spot light, optionally multiplied by a projected cookie
                            float3 att = LV_PointLightAttenuation(distSq, -pos.w, color.rgb, rangeSq);
                            specularSpreadSq = -pos.w * invDist * invDist;
                            float solidAngleFactor;
                            #ifndef VRCLV_DISABLE_SPOT_COOKIES
                            [branch] if (customId < 0) { // Textured spot light. Cookie RGB tints the light and alpha masks it
                                uint textureId = (uint) _UdonPointLightVolumeCubeCount * 5 - customId - 1;
                                float4 cookie = LV_SAMPLE_POINT(float3(cookieUv * 0.5 + 0.5, textureId));
                                l0 = att * cookie.rgb * cookie.a;
                                solidAngleFactor = 1 - saturate(rsqrt(1 + angle * angle));
                            } else
                            #endif
                            { // Plain analytic spot light. Cone falloff is evaluated procedurally
                                l0 = att * LV_Smoothstep01(saturate(spotMask * spotConeFalloff));
                                solidAngleFactor = saturate(1 - angle);
                            }
                            // Unnormalized dir folds normalization and the finite-source solid-angle factor into one rsqrt.
                            l1 = dir * rsqrt(distSq - pos.w * solidAngleFactor);
                        }
                    }
                }
            }
            #if VRCLV_AREA_LIGHTS_SUPPORTED
            else
            #endif
            #endif
            #if VRCLV_AREA_LIGHTS_SUPPORTED
            { // Area light. Positive pos.w stores width; color.w stores 2 + height
                float4 areaRotation = _UdonPointLightVolumeDirection[id]; // Rotation
                float3 lightToWorldPos = worldPos - pos.xyz;
                float2 areaSize = float2(pos.w, color.w - 2);
                float3 areaNormal, areaXAxis, areaYAxis;
                LV_QuaternionAxes(areaRotation, areaXAxis, areaYAxis, areaNormal);
                float3 areaLocalPos = float3(dot(lightToWorldPos, areaXAxis), dot(lightToWorldPos, areaYAxis), dot(lightToWorldPos, areaNormal));

                [branch] if (areaLocalPos.z > 0) { // Receiver is in front of the area emitter plane
                    float3 areaPointLightShadingDir;
                    float sourceSpreadSq = dot(areaSize, areaSize) * (0.25 * rcp(distSq));
                    float4 areaLightSH = LV_ProjectFastQuadLightIrradianceSH(lightToWorldPos, areaLocalPos, distSq, areaXAxis, areaYAxis, areaSize, areaPointLightShadingDir);
                    // Area projection is the expensive evaluation boundary, so later attenuation,
                    // cookie, normal-mask, or shadow rejection still consumes the overdraw slot.
                    counted = true;
                    float areaAttenuation = saturate(1 - distSq * rcp(rangeSq));

                    [branch] if (areaLightSH.w > 0 && areaAttenuation > 0) { // Area projection has non-zero solid angle and remains inside its culling range
                        float invDist = rsqrt(distSq);
                        float3 cookie = 1;
                        bool areaVisible = true;

                        #ifndef VRCLV_DISABLE_AREA_COOKIES
                        [branch] if (customID_data.w != 0) { // V3 textured Area light. V2 leaves W at zero.
                            uint textureId = (uint)_UdonPointLightVolumeCubeCount * 5 - customId - 1;
                            // Valid tags are +/-1 or +/-2: sign selects X mirror, magnitude 2 selects Y mirror.
                            float areaCookieMirror = customID_data.w;
                            areaLocalPos.xy *= float2(2.0 * saturate(areaCookieMirror) - 1.0, 3.0 - 2.0 * abs(areaCookieMirror));
                            cookie = LV_AreaLightCookie(areaLocalPos, invDist, areaSize, textureId).rgb;
                            color.rgb = _UdonPointLightVolumeExtraData[id].rgb;
                            areaVisible = max(max(cookie.r, cookie.g), cookie.b) > 0;
                        }
                        #endif

                        [branch] if (areaVisible) { // Area light is either untextured or has a non-black/non-transparent cookie sample
                            float3 lightDir = dir * invDist;
                            // Fold the irradiance factors before the shadow receiver to shorten their live ranges.
                            float3 areaIrradiance = color.rgb * (areaAttenuation * LV_PI * areaLightSH.w) * cookie;

                            [branch] if (LV_PointLightVolumeShadowMask(id, customID_data.y, 0.0, worldPos, dir, areaPointLightShadingDir, distSq, invDist, pointLightShadingNormal, pointLightShadingBias, true, false, shadow)) {
                                lightDirNormal = lightDir;
                                specularSpreadSq = sourceSpreadSq;
                                l0 = areaIrradiance;
                                l1 = areaLightSH.xyz;
                            }
                        }
                    }
                }
            }
            #endif
        }
        #endif
    }
    #endif
    return counted;
}

// Samples 3 SH textures and packs them into L1 channels
void LV_SampleLightVolumeTex(float3 uvw0, float3 uvw1, float3 uvw2, out float3 L0, out float3 L1r, out float3 L1g, out float3 L1b) {
    // Sampling 3D Atlas
    float4 tex0 = LV_SAMPLE(_UdonLightVolume, uvw0);
    float4 tex1 = LV_SAMPLE(_UdonLightVolume, uvw1);
    float4 tex2 = LV_SAMPLE(_UdonLightVolume, uvw2);
    // Packing final data
    L0 = tex0.rgb;
    L1r = float3(tex1.r, tex2.r, tex0.a);
    L1g = float3(tex1.g, tex2.g, tex1.a);
    L1b = float3(tex1.b, tex2.b, tex2.a);
}

// Bounds mask for a volume rotated in world space, using local UVW
float LV_BoundsMask(float3 localUVW, float3 invLocalEdgeSmooth) {
    float3 fade = saturate((0.5 - abs(localUVW)) * invLocalEdgeSmooth);
    return fade.x * fade.y * fade.z;
}

// Default light probes SH components
void LV_SampleLightProbe(inout float3 L0, inout float3 L1r, inout float3 L1g, inout float3 L1b) {
    L0 += float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
    L1r += unity_SHAr.xyz;
    L1g += unity_SHAg.xyz;
    L1b += unity_SHAb.xyz;
}

// Calculates atlas UVW coordinates for a volume sample using the compact bounds layout
void LV_VolumeAtlasUVW(uint id, float3 localUVW, out float3 uvw0, out float3 uvw1, out float3 uvw2) {
    uint uvwID = id * 3;
    float4 uvwPos0 = _UdonLightVolumeUvwScale[uvwID];
    float4 uvwPos1 = _UdonLightVolumeUvwScale[uvwID + 1];
    float4 uvwPos2 = _UdonLightVolumeUvwScale[uvwID + 2];
    float3 uvwScale = float3(uvwPos0.w, uvwPos1.w, uvwPos2.w);

    float3 uvwScaled = saturate(localUVW + 0.5) * uvwScale;
    uvw0 = uvwPos0.xyz + uvwScaled;
    uvw1 = uvwPos1.xyz + uvwScaled;
    uvw2 = uvwPos2.xyz + uvwScaled;
}

// Samples a Volume with ID and Local UVW
void LV_SampleVolume(uint id, float3 localUVW, inout float3 L0, inout float3 L1r, inout float3 L1g, inout float3 L1b) {

    // Additive UVW
    float3 uvw0, uvw1, uvw2;
    LV_VolumeAtlasUVW(id, localUVW, uvw0, uvw1, uvw2);

    // Sample additive
    float3 l0, l1r, l1g, l1b;
    LV_SampleLightVolumeTex(uvw0, uvw1, uvw2, l0, l1r, l1g, l1b);

    // Color correction
    float4 color = _UdonLightVolumeColor[id];
    L0 += l0 * color.rgb;
    l1r *= color.r;
    l1g *= color.g;
    l1b *= color.b;

    // Rotate if needed
    #ifndef VRCLV_DISABLE_VOLUME_ROTATION
    [branch] if (color.a != 0) {
        uint rotationID = id * 2;
        float3 r0 = _UdonLightVolumeRotation[rotationID].xyz;
        float3 r1 = _UdonLightVolumeRotation[rotationID + 1].xyz;
        float3 r2 = cross(r0, r1);
        l1r = LV_MultiplyVectorByMatrix3x3(l1r, r0, r1, r2);
        l1g = LV_MultiplyVectorByMatrix3x3(l1g, r0, r1, r2);
        l1b = LV_MultiplyVectorByMatrix3x3(l1b, r0, r1, r2);
    }
    #endif

    L1r += l1r;
    L1g += l1g;
    L1b += l1b;
}

// Accumulates one Point Light Volume with the shared diffuse SH operations.
inline bool LV_AccumulatePointLightVolumeSH(uint pid, float3 worldPos, float3 pointLightShadingNormal, float pointLightShadingBias, inout float3 L0, inout float3 L1r, inout float3 L1g, inout float3 L1b) {
    float3 l0, l1, unused_lightDirNormal;
    float unused_specularSpreadSq, shadow;
    if (!LV_PointLightVolumeContribution(pid, worldPos, pointLightShadingNormal, pointLightShadingBias, l0, l1, unused_lightDirNormal, unused_specularSpreadSq, shadow)) return false;

    l0 *= shadow;
    L0 += l0;
    L1r += l1 * l0.r;
    L1g += l1 * l0.g;
    L1b += l1 * l0.b;
    return true;
}


// Calculates L1 SH based on the world position. Only samples point lights, not volumes. Accumulates into L0/L1r/L1g/L1b.
void LV_PointLightVolumeSH(float3 worldPos, float3 worldNormal, float pointLightShading, inout float3 L0, inout float3 L1r, inout float3 L1g, inout float3 L1b) {
    #if VRCLV_LIGHTS_SUPPORTED
    uint pointCount = min((uint) _UdonPointLightVolumeCount, VRCLV_MAX_LIGHTS_COUNT);
    uint maxOverdraw = min((uint) _UdonLightVolumeAdditiveMaxOverdraw, pointCount);
    [branch] if (maxOverdraw == 0) return;

    #if VRCLV_CLUSTERING_SUPPORTED
    uint4 clusterMask = 0u;
    bool useClustering = false;
    LV_LoadClusterMask(worldPos, clusterMask, useClustering);
    [branch] if (useClustering && (clusterMask.x | clusterMask.y | clusterMask.z | clusterMask.w) == 0u) return;
    #endif

    float pointLightShadingScale = pointLightShading * 0.5; // Half-strength scale for the normal-shading ramp
    float3 pointLightShadingNormal = worldNormal * pointLightShadingScale; // Pre-scaled normal for point-light shading
    float pointLightShadingBias = pointLightShading > 0 ? 0.5 + 0.5 * saturate(1 - pointLightShading) : -1; // Bias for normal-shading ramp, -1 disables it
    uint pcount = 0; // Accumulated point-light count

    #if VRCLV_CLUSTERING_SUPPORTED
    uint traversalIndex = 0u;
    uint maskBits = clusterMask.x;
    uint sequentialEnd = useClustering ? 0u : pointCount;

    // Select IDs from the cluster mask or sequential range, then process them through one shared loop body.
    VRCLV_DYNAMIC_LOOP while (pcount < maxOverdraw) {
        uint pid;
        [branch] if (traversalIndex < sequentialEnd) {
            pid = traversalIndex++;
        } else
        {
            if (!LV_NextClusteredLight(clusterMask, traversalIndex, maskBits, pid)) break;
        }
        if (LV_AccumulatePointLightVolumeSH(pid, worldPos, pointLightShadingNormal, pointLightShadingBias, L0, L1r, L1g, L1b)) pcount++;
    }
    #else
    VRCLV_DYNAMIC_LOOP for (uint pid = 0u; pid < pointCount && pcount < maxOverdraw; pid++) {
        if (LV_AccumulatePointLightVolumeSH(pid, worldPos, pointLightShadingNormal, pointLightShadingBias, L0, L1r, L1g, L1b)) pcount++;
    }
    #endif
    #endif
}

// Calculates L1 SH based on the world position from regular volumes only.
void LV_LightVolumeRegularSH(float3 worldPos, inout float3 L0, inout float3 L1r, inout float3 L1g, inout float3 L1b) {
    #ifdef VRCLV_DISABLE_REGULAR_VOLUMES
    // Regular-volume absence has the same probe baseline as an empty runtime set.
    LV_SampleLightProbe(L0, L1r, L1g, L1b);
    #else
    // Clamping global iteration counts
    uint volumesCount = min((uint) _UdonLightVolumeCount, VRCLV_MAX_VOLUMES_COUNT);
    #ifdef VRCLV_DISABLE_ADDITIVE_VOLUMES
    uint additiveCount = 0u;
    #else
    uint additiveCount = min((uint) _UdonLightVolumeAdditiveCount, volumesCount);
    #endif

    [branch] if (volumesCount <= additiveCount) {
        LV_SampleLightProbe(L0, L1r, L1g, L1b);
        return;
    }

    float3 localUVW = 0; // Last tested local UVW for the lowest-weight fallback.

    // Find the dominant volume first; its index also records whether the search exhausted the range.
    uint volumeID_A = additiveCount;
    VRCLV_DYNAMIC_LOOP for (; volumeID_A < volumesCount; volumeID_A++) {
        localUVW = LV_LocalFromVolume(volumeID_A, worldPos);
        [branch] if (LV_PointLocalAABB(localUVW)) break;
    }
    bool isNoA = volumeID_A >= volumesCount;
    float3 localUVW_A = localUVW;
    float mask = 1;
    [branch] if (!isNoA) {
        mask = LV_BoundsMask(localUVW_A, _UdonLightVolumeInvLocalEdgeSmooth[volumeID_A]);
    }

    // Only a boundary A needs a second containing volume. Keep the last tested UVW when B is absent.
    uint volumeID_B = volumesCount;
    float3 localUVW_B = 0;
    [branch] if (mask != 1) {
        volumeID_B = volumeID_A + 1u;
        VRCLV_DYNAMIC_LOOP for (; volumeID_B < volumesCount; volumeID_B++) {
            localUVW = LV_LocalFromVolume(volumeID_B, worldPos);
            [branch] if (LV_PointLocalAABB(localUVW)) break;
        }
        localUVW_B = localUVW;
    }
    bool isNoB = volumeID_B >= volumesCount;

    // If no containing volume was found, use probes or the lowest-weight fallback volume.
    [branch] if (isNoA) {
        #ifndef VRCLV_DISABLE_LIGHT_PROBES_BLENDING
        [branch] if (_UdonLightVolumeProbesBlend) {
            LV_SampleLightProbe(L0, L1r, L1g, L1b);
            return;
        }
        #endif

        // Fallback to the lowest weight light volume if outside every volume
        volumeID_A = volumesCount - 1;
        localUVW_A = localUVW;
    }

    // Sample dominant Volume A once after selection.
    float3 L0_A = 0, L1r_A = 0, L1g_A = 0, L1b_A = 0;
    LV_SampleVolume(volumeID_A, localUVW_A, L0_A, L1r_A, L1g_A, L1b_A);

    // Return A directly in its interior or when sharp bounds suppress missing-B blending.
    #ifdef VRCLV_DISABLE_SMOOTH_BOUNDS
    [branch] if (mask == 1 || isNoB)
    #else
    [branch] if (mask == 1 || (isNoB && _UdonLightVolumeSharpBounds))
    #endif
    {
        L0  += L0_A;
        L1r += L1r_A;
        L1g += L1g_A;
        L1b += L1b_A;
        return;
    }

    // Resolve B from probes or an actual volume, then share the four-channel blend tail.
    float3 L0_B = 0, L1r_B = 0, L1g_B = 0, L1b_B = 0;
    #ifndef VRCLV_DISABLE_LIGHT_PROBES_BLENDING
    [branch] if (isNoB && _UdonLightVolumeProbesBlend) {
        LV_SampleLightProbe(L0_B, L1r_B, L1g_B, L1b_B);
    } else
    #endif
    {
        [branch] if (isNoB) {
            volumeID_B = volumesCount - 1;
            localUVW_B = localUVW;
        }
        LV_SampleVolume(volumeID_B, localUVW_B, L0_B, L1r_B, L1g_B, L1b_B);
    }
    L0  += lerp(L0_B,  L0_A,  mask);
    L1r += lerp(L1r_B, L1r_A, mask);
    L1g += lerp(L1g_B, L1g_A, mask);
    L1b += lerp(L1b_B, L1b_A, mask);
    #endif
}

// Calculates L1 SH based on the world position from additive volumes only.
void LV_LightVolumeAdditiveSH(float3 worldPos, inout float3 L0, inout float3 L1r, inout float3 L1g, inout float3 L1b) {
    #ifndef VRCLV_DISABLE_ADDITIVE_VOLUMES
    uint additiveCount = min((uint) _UdonLightVolumeAdditiveCount, VRCLV_MAX_VOLUMES_COUNT); // Clamping global iteration counts
    uint maxOverdraw = min((uint) _UdonLightVolumeAdditiveMaxOverdraw, additiveCount);
    [branch] if (maxOverdraw == 0) return;

    uint addVolumesCount = 0;
    VRCLV_DYNAMIC_LOOP for (uint id = 0; id < additiveCount && addVolumesCount < maxOverdraw; id++) {
        float3 localUVW = LV_LocalFromVolume(id, worldPos);
        [branch] if (LV_PointLocalAABB(localUVW)) {
            LV_SampleVolume(id, localUVW, L0, L1r, L1g, L1b);
            addVolumesCount++;
        }
    }
    #endif
}

// ----------------------- VRC LIGHT VOLUMES PUBLIC API --------------------------

// Checks if Light Volumes are used in this scene. Returns 0 if not, returns 1 if enabled
float LightVolumesEnabled() {
    return (_UdonLightVolumeEnabled != 0 && _UdonLightVolumeVersion >= VRCLV_MIN_SUPPORTED_VERSION) ? 1 : 0;
}

// Returns the light volumes version
float LightVolumesVersion() {
    float version = _UdonLightVolumeVersion;
    return version == 0 ? _UdonLightVolumeEnabled : version;
}

// Calculates L1 SH based on the world position. Samples regular volumes, additive volumes and Point Light Volumes.
void LightVolumeSH(float3 worldPos, out float3 L0, out float3 L1r, out float3 L1g, out float3 L1b, float3 worldPosOffset, float3 worldNormal, float pointLightShading = 3) {
    L0 = 0; L1r = 0; L1g = 0; L1b = 0;
    [branch] if (_UdonLightVolumeEnabled == 0 || _UdonLightVolumeVersion < VRCLV_MIN_SUPPORTED_VERSION) {
        LV_SampleLightProbe(L0, L1r, L1g, L1b);
    } else {
        LV_LightVolumeRegularSH(worldPos + worldPosOffset, L0, L1r, L1g, L1b);
        LV_LightVolumeAdditiveSH(worldPos + worldPosOffset, L0, L1r, L1g, L1b);
        LV_PointLightVolumeSH(worldPos, worldNormal, pointLightShading, L0, L1r, L1g, L1b);
    }
}

// V2 public signature. Old shaders did not provide a surface normal, so point-light normal shading stays disabled.
void LightVolumeSH(float3 worldPos, out float3 L0, out float3 L1r, out float3 L1g, out float3 L1b, float3 worldPosOffset = 0) {
    LightVolumeSH(worldPos, L0, L1r, L1g, L1b, worldPosOffset, 0, 0);
}

#endif
