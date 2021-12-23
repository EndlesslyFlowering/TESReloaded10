//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
//   vsa shaderdump19/HDR004.vso /Fcshaderdump19/HDR004.vso.dis
//
//
// Parameters:
//
float4 texRatio0 : register(c6);
float4 texRatio1 : register(c7);
//
//
// Registers:
//
//   Name         Reg   Size
//   ------------ ----- ----
//   texRatio0    const_6       1
//   texRatio1    const_7       1
//


// Structures:

struct VS_INPUT {
    float4 position : POSITION;
    float4 texcoord_0 : TEXCOORD0;
};

struct VS_OUTPUT {
    float4 position : POSITION;
    float2 texcoord_0 : TEXCOORD0;
    float2 texcoord_1 : TEXCOORD1;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

    OUT.position.xyzw = IN.position.xyzw;
    OUT.texcoord_0.xy = (IN.texcoord_0.xy * texRatio0.xy) + texRatio0.zw;
    OUT.texcoord_1.xy = (IN.texcoord_0.xy * texRatio1.xy) + texRatio1.zw;

    return OUT;
};

// approximately 3 instruction slots used
