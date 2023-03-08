// Specular multiplier fullscreen shader for Oblivion/Skyrim Reloaded

float4 TESR_ReciprocalResolution;
float4 TESR_SpecularData;					// x: luma treshold, y:blurMultiplier, z:glossiness, w:drawDistance
float4 TESR_SpecularEffects;				// x: specular strength, y:sky tint strenght, z:fresnel strength
float4 TESR_ViewSpaceLightDir;
float4 TESR_SunDirection;
float4 TESR_SunColor;
float4 TESR_SkyColor;
float4 TESR_HorizonColor;
float4 TESR_FogColor;
float4 TESR_WaterSettings;
float4 TESR_ShadowFade; // attenuation factor of sunsets/sunrises and moon phases

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SourceBuffer : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_NormalsBuffer : register(s3) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = NONE; MINFILTER = NONE; MIPFILTER = NONE; };

static const float LumTreshold = TESR_SpecularData.x;
static const float BlurRadius = TESR_SpecularData.y;
static const float Glossiness = TESR_SpecularData.z;
static const float DrawDistance = TESR_SpecularData.w;
static const float SpecStrength = TESR_SpecularEffects.x;
static const float SkyStrength = TESR_SpecularEffects.y;
static const float FresnelStrength = TESR_SpecularEffects.z;
static const float SkySaturation = TESR_SpecularEffects.w;


struct VSOUT
{
	float4 vertPos : POSITION;
	float2 UVCoord : TEXCOORD0;
};
 
struct VSIN
{
	float4 vertPos : POSITION0;
	float2 UVCoord : TEXCOORD0;
};
 
VSOUT FrameVS(VSIN IN)
{
	VSOUT OUT = (VSOUT)0.0f;
	OUT.vertPos = IN.vertPos;
	OUT.UVCoord = IN.UVCoord;
	return OUT;
}

#include "Includes/Helpers.hlsl"
#include "Includes/Depth.hlsl"
#include "Includes/Normals.hlsl"
#include "Includes/Blur.hlsl"
#include "Includes/Blending.hlsl"


float4 specularHighlight( VSOUT IN) : COLOR0
{
	float2 coord = IN.UVCoord;
	float depth = readDepth(coord);

	//reorient our sample kernel along the origin's normal
	float3 worldNormal = GetWorldNormal(coord);

	float3 positionVector = toWorld(IN.UVCoord);
	float3 camera_vector = positionVector * depth;
	float4 world_pos = float4(TESR_CameraPosition.xyz + camera_vector, 1.0f);

	if (world_pos.z < TESR_WaterSettings.x + 0.0001) return float4(0, 0, 0, 1); // no effect on water surface

	float3 viewRay = normalize(positionVector * -1);

	float fresnel = pow(1 - dot(viewRay, worldNormal), 5);
	float reflectance = 0.04;
	fresnel = fresnel + reflectance * (1 - fresnel);
	fresnel *= compress(dot(viewRay, TESR_SunDirection.xyz * -1)); // scale fresnel with light direction

	// blinn phong specular
	float3 halfwayDir = normalize(TESR_SunDirection.xyz + viewRay);
	float specular = pow(shades(worldNormal, halfwayDir), Glossiness) * (1 + fresnel); // scale specular with fresnel
	float skyLight = dot(worldNormal, float3(0, 0, 1));

	float3 result = float3(specular, skyLight, fresnel);
	result = lerp(result, 0.0, smoothstep(0, DrawDistance, depth));
	result.g = skyLight; //skylight isn't faded with draw distance

	return float4(result, 1.0);
}

#define screen(base, blend)  (base + blend - base*blend)

float4 CombineSpecular(VSOUT IN) :COLOR0
{
	// float4 color = float(0).xxxx;
	float depth = smoothstep(0, farZ / 4, readDepth(IN.UVCoord));
	float4 color = tex2D(TESR_SourceBuffer, IN.UVCoord);
	float4 light = tex2D(TESR_RenderedBuffer, IN.UVCoord);
	float luminance = luma(color);
	float sunLuma = luma (TESR_SunColor);
	float invLuma = 1 - sunLuma;
	float sunSetFade = 1 - TESR_ShadowFade.x;

	float4 result = color;

	// skylight
	float4 skyColor = lerp(TESR_SkyColor, TESR_HorizonColor, depth);
	skyColor = lerp(Desaturate(skyColor), skyColor, SkySaturation);

	// fresnel
	result += light.b * color * saturate(luminance * 2) * FresnelStrength * invLuma * sunSetFade; //fresnel scales with the luminance, but reaches full power at half max luminance

	// return skyColor;
	result += SkyStrength * light.g * skyColor * 0.1 * saturate(smoothstep(0.4, 0, luminance)) * invLuma * sunSetFade; // skylight is more pronounced in darker areas

	// specular
	result += lerp(0, light.r * SpecStrength * TESR_SunColor * color, saturate(invlerp(LumTreshold * sunLuma, 1, luminance))); // specular will boost areas above treshold

	return float4 (result.rgb, 1.0f);
}
 

technique
{
	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 specularHighlight();
	}

	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurRChannel(float2(1.0f, 0.0f), BlurRadius, 1, 1000000);
	}
	
	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurRChannel(float2(0.0f, 1.0f), BlurRadius, 1, 1000000);
	}

	// pass
	// { 
	// 	VertexShader = compile vs_3_0 FrameVS();
	// 	PixelShader = compile ps_3_0 BoxBlur();
	// }

	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 CombineSpecular();
	}
}