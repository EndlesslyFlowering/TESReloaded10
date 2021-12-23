//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
// Parameters:
//
row_major float4x4 ModelViewProj : register(c0);
float3 LightDirection[3] : register(c13);
float4 LightPosition[3] : register(c16);
float4 EyePosition : register(c25);
row_major float4x4 TESR_InvViewProjectionTransform : register(c34);
//
//
// Registers:
//
//   Name           Reg   Size
//   -------------- ----- ----
//   ModelViewProj[0]  const_0        1
//   ModelViewProj[1]  const_1        1
//   ModelViewProj[2]  const_2        1
//   ModelViewProj[3]  const_3        1
//   LightDirection[0] const_13       1
//   LightPosition[0]  const_16       1
//   LightPosition[1]  const_17       1
//   LightPosition[2]  const_18       1
//   EyePosition    const_25      1
//


// Structures:

struct VS_INPUT {
    float4 Position : POSITION;
    float3 tangent : TANGENT;
    float3 binormal : BINORMAL;
    float3 normal : NORMAL;
    float4 BaseUV : TEXCOORD0;

#define	TanSpaceProj	float3x3(IN.tangent.xyz, IN.binormal.xyz, IN.normal.xyz)
};

struct VS_OUTPUT {
    float4 Position : POSITION;
    float2 BaseUV : TEXCOORD0;
    float3 Light0Dir : TEXCOORD1;
    float3 Light1Dir : TEXCOORD2;
    float3 Light2Dir : TEXCOORD3;
    float4 Att1UV : TEXCOORD4;
    float4 Att2UV : TEXCOORD5;
    float3 CameraDir : TEXCOORD6;
	float4 texcoord_7 : TEXCOORD7;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)

    float3 lit0;
    float3 lit3;
	float4 r0;
	
	r0.xyzw = mul(ModelViewProj, IN.Position.xyzw);
    lit3.xyz = LightPosition[2].xyz - IN.Position.xyz;
    lit0.xyz = LightPosition[1].xyz - IN.Position.xyz;
	OUT.Position.xyzw = r0.xyzw;
    OUT.BaseUV.xy = IN.BaseUV.xy;
    OUT.Light0Dir.xyz = normalize(mul(TanSpaceProj, LightDirection[0].xyz));
    OUT.Light1Dir.xyz = mul(TanSpaceProj, normalize(lit0.xyz));
    OUT.Light2Dir.xyz = mul(TanSpaceProj, normalize(lit3.xyz));
    OUT.Att1UV.w = 0.5;
    OUT.Att1UV.xyz = compress(lit0.xyz / LightPosition[1].w);
    OUT.Att2UV.w = 0.5;
    OUT.Att2UV.xyz = compress(lit3.xyz / LightPosition[2].w);
    OUT.CameraDir.xyz = normalize(mul(TanSpaceProj, normalize(EyePosition.xyz - IN.Position.xyz)));
	OUT.texcoord_7.xyzw = mul(r0.xyzw, TESR_InvViewProjectionTransform);
    return OUT;
};

// approximately 43 instruction slots used
