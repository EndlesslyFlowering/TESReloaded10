//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/SLS2001.pso /Fcshaderdump19/SLS2001.pso.dis
//
//
// Parameters:
//
float4 AmbientColor : register(c1);
float4 PSLightColor[4] : register(c2);
float4 Toggles : register(c7);
float4 TESR_TerrainData : register(c8);

sampler2D BaseMap : register(s0);
sampler2D NormalMap : register(s1);
sampler2D NoiseMap : register(s6);
sampler2D TESR_Noise : register(s10) < string ResourceName = "Effects\TerrainNoise_n.dds"; > = sampler_state { ADDRESSU = WRAP; ADDRESSV = WRAP; MAGFILTER = LINEAR; MINFILTER = MINDEF; MIPFILTER = MIPDEF; };

//
//
// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   AmbientColor const_1       1
//   PSLightColor[0] const_2        1
//   Toggles      const_7       1
//   BaseMap      texture_0       1
//   NormalMap    texture_1       1
//   NoiseMap    texture_6       1
//

/* ----------------------------------------------------------------------------- */

// Structures:

struct VS_OUTPUT {
    float4 Fog : COLOR1;
    float2 BaseUV : TEXCOORD0;
    float3 Light0Dir : TEXCOORD1_centroid;
    float FarClip : TEXCOORD7_centroid;
};

struct PS_OUTPUT {
    float4 Color : COLOR0;
};

// Code:

PS_OUTPUT main(VS_OUTPUT IN) {
    PS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	shades(n, l)	saturate(dot(n, l))

    float3 q0;
    float3 q1;
    float4 r0;
    float3 r1;
    float4 r2;
	float spclr;
	
    r0.xyzw = 0.1 - IN.FarClip.x;
    clip(r0.xyzw);
	
	r0.xyz  = tex2D(BaseMap, IN.BaseUV.xy).rgb;
    r2.xyzw  = tex2D(NormalMap, IN.BaseUV.xy);
    r2.xyz   = normalize(expand(r2.xyz));
	
    float3 noisec = (tex2D(NoiseMap, IN.BaseUV.xy * 20).xyz * 2 + tex2D(NoiseMap, IN.BaseUV.xy * 2).xyz) * 0.3333;
    r1.x   = saturate(0.50 + 1.25 * (smoothstep(1.0, 0.0, pow(noisec.x, 0.5))));
    r1.xyz = lerp(r1.x, 1, pow(length(r0.rgb) / length(1), 2));
	
    float3 noisen = expand(tex2D(TESR_Noise, IN.BaseUV.xy * 40).xyz);
    r2.xyz = normalize(r2.xyz + float3(noisen.xy * TESR_TerrainData.y, 0));
	
	float3 LightDir = IN.Light0Dir.xyz;
	LightDir.x = LightDir.x < 0.4 ? max(LightDir.y, 0.8) : LightDir.x; // Trick to avoid to flat the bumpmap when midday
	
    q0.xyz = (shades(r2.xyz, LightDir.xyz) * PSLightColor[0].rgb) + AmbientColor.rgb;
    q1.xyz = r0.xyz * max(q0.xyz, 0);
    q1.xyz = q1.xyz * r1.x;
    q1.xyz = (Toggles.y <= 0.0 ? q1.xyz : ((IN.Fog.a * (IN.Fog.rgb - q1.xyz)) + q1.xyz));	
	spclr = smoothstep(0.0, 0.25, length(r0.rgb)) * (r0.b * 2.0 * TESR_TerrainData.x) + 1.0;	
    OUT.Color.a = r0.w * AmbientColor.a;
    OUT.Color.rgb = q1.xyz * spclr;
    return OUT;
};

// approximately 24 instruction slots used (4 texture, 20 arithmetic)
