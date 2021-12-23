//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
// Parameters:

float4 AmbientColor : register(c1);
float4 PSLightColor[4] : register(c2);
float4 Toggles : register(c7);
float4 TESR_ShadowData : register(c8);
float4 TESR_ShadowLightPosition[4] : register(c9);
float4 TESR_ShadowCubeMapBlend : register(c13);

sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
samplerCUBE TESR_ShadowCubeMapBuffer0 : register(s8) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; ADDRESSW = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   AmbientColor const_1       1
//   PSLightColor[0] const_2        1
//   Toggles      const_7       1
//   BaseMap      texture_0       1
//   NormalMap    texture_1       1
//


// Structures:

struct VS_INPUT {
    float2 BaseUV : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1_centroid;
	float4 texcoord_7 : TEXCOORD7;
    float3 LCOLOR_0 : COLOR0;
    float4 LCOLOR_1 : COLOR1;
};

struct VS_OUTPUT {
    float4 color_0 : COLOR0;
};

#include "..\Includes\ShadowCube.hlsl"

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)	saturate(dot(n, l))

    float3 noxel0;
    float3 q1;
    float3 q3;
    float3 q4;
    float3 q5;
    float4 r0;
	float Shadow = 1.0f;
	
	if (TESR_ShadowLightPosition[0].w) Shadow = GetLightAmount(TESR_ShadowCubeMapBuffer0, IN.texcoord_7, TESR_ShadowLightPosition[0], TESR_ShadowCubeMapBlend.x);
    noxel0.xyz = tex2D(NormalMap, IN.BaseUV.xy).xyz;
    r0.xyzw = tex2D(BaseMap, IN.BaseUV.xy);
    q1.xyz = Shadow * shades(normalize(expand(noxel0.xyz)), IN.texcoord_1.xyz) * PSLightColor[0].rgb + AmbientColor.rgb;
    q3.xyz = (Toggles.x <= 0.0 ? r0.xyz : (r0.xyz * IN.LCOLOR_0.xyz));
    q4.xyz = max(q1.xyz, 0) * q3.xyz;
    q5.xyz = (Toggles.y <= 0.0 ? q4.xyz : ((IN.LCOLOR_1.w * (IN.LCOLOR_1.xyz - q4.xyz)) + q4.xyz));
    OUT.color_0.a = r0.w * AmbientColor.a;
    OUT.color_0.rgb = q5.xyz;
    return OUT;
	
};

// approximately 19 instruction slots used (2 texture, 17 arithmetic)