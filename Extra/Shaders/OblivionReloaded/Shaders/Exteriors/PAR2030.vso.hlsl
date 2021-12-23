//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
// Parameters:

row_major float4x4 ModelViewProj : register(c0);
float3 LightDirection[3] : register(c13);
float4 EyePosition : register(c25);
row_major float4x4 TESR_ShadowCameraToLightTransform[2] : register(c34);

// Registers:
//
//   Name           Reg   Size
//   -------------- ----- ----
//   ModelViewProj[0]  const_0        1
//   ModelViewProj[1]  const_1        1
//   ModelViewProj[2]  const_2        1
//   ModelViewProj[3]  const_3        1
//   LightDirection[0] const_13       1
//   EyePosition    const_25      1
//


// Structures:

struct VS_INPUT {
    float4 LPOSITION : POSITION;
    float3 LTANGENT : TANGENT;
    float3 LBINORMAL : BINORMAL;
    float3 LNORMAL : NORMAL;
    float4 LTEXCOORD_0 : TEXCOORD0;
};

struct VS_OUTPUT {
    float4 position : POSITION;
    float2 texcoord_0 : TEXCOORD0;
    float3 texcoord_1 : TEXCOORD1;
    float3 texcoord_3 : TEXCOORD3;
	float4 texcoord_5 : TEXCOORD5;
    float3 texcoord_6 : TEXCOORD6;
	float4 texcoord_7 : TEXCOORD7;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

    float3 eye0;
    float3 q12;
    float3 q16;
    float3 q3;
    float4 r0;
	
	r0.xyzw = mul(ModelViewProj, IN.LPOSITION.xyzw);
    q12.xyz = mul(float3x3(IN.LTANGENT.xyz, IN.LBINORMAL.xyz, IN.LNORMAL.xyz), LightDirection[0].xyz);
    OUT.position.xyzw = r0.xyzw;
    OUT.texcoord_0.xy = IN.LTEXCOORD_0.xy;
    OUT.texcoord_1.xyz = normalize(q12.xyz);
    eye0.xyz = normalize(EyePosition.xyz - IN.LPOSITION.xyz);
    q3.xyz = normalize(eye0.xyz + LightDirection[0].xyz);
    OUT.texcoord_3.xyz = mul(float3x3(IN.LTANGENT.xyz, IN.LBINORMAL.xyz, IN.LNORMAL.xyz), q3.xyz);
    q16.xyz = mul(float3x3(IN.LTANGENT.xyz, IN.LBINORMAL.xyz, IN.LNORMAL.xyz), eye0.xyz);
    OUT.texcoord_6.xyz = normalize(q16.xyz);
	OUT.texcoord_5.xyzw = mul(r0.xyzw, TESR_ShadowCameraToLightTransform[0]);
	OUT.texcoord_7.xyzw = mul(r0.xyzw, TESR_ShadowCameraToLightTransform[1]);
    return OUT;
};

// approximately 30 instruction slots used