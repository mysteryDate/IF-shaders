Shader "Aaron/Sandbox/geometryTest" {
	Properties 
	{
		_SpriteTex ("Base (RGB)", 2D) = "white" {}
		_Size ("Size", Range(0, 3)) = 0.5
		_Color ("Color", color) = (1.0, 1.0, 1.0, 1.0)
		_Foo ("Foo", float) = 1
		_Bar ("Bar", float) = 1
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" }
		Pass
		{
			Tags { "RenderType"="Opaque" }
			Blend SrcAlpha OneMinusSrcAlpha
//			Ztest Always
			Zwrite Off
			LOD 200
		
			CGPROGRAM
				#pragma target 5.0
				#pragma vertex VS_Main
				#pragma fragment FS_Main
				#pragma geometry GS_Main
				#include "UnityCG.cginc" 
				
				
				float4 _Color;
				float _Foo;
				float _Bar;

				// **************************************************************
				// Data structures												*
				// **************************************************************
				struct GS_INPUT
				{
					float4	pos		: POSITION;
					float3	normal	: NORMAL;
					float2  tex0	: TEXCOORD0;
				};

				struct FS_INPUT
				{
					float4	pos		: POSITION;
					float2  tex0	: TEXCOORD0;
				};


				// **************************************************************
				// Vars															*
				// **************************************************************

				float _Size;
				float4x4 _VP;
				Texture2D _SpriteTex;
				SamplerState sampler_SpriteTex;

				// **************************************************************
				// Shader Programs												*
				// **************************************************************

				// Vertex Shader ------------------------------------------------
				GS_INPUT VS_Main(appdata_base v)
				{
					GS_INPUT output = (GS_INPUT)0;

					output.pos =  mul(_Object2World, v.vertex);
					output.normal = v.normal;
					output.tex0 = float2(0, 0);

					return output;
				}



				// Geometry Shader -----------------------------------------------------
				[maxvertexcount(4)]
				void GS_Main(point GS_INPUT p[1], inout TriangleStream<FS_INPUT> triStream)
				{
					float3 up = float3(0, 1, 0);
					float3 look = _WorldSpaceCameraPos - p[0].pos;
					look.y = 0;
					look = normalize(look);
					float3 right = cross(up, look);
					
					float halfS = 0.5f * _Size;
							
					float4 v[4];
					v[0] = float4(p[0].pos + halfS * right - halfS * up, 1.0f);
					v[1] = float4(p[0].pos + halfS * right + halfS * up, 1.0f);
					v[2] = float4(p[0].pos - halfS * right - halfS * up, 1.0f);
					v[3] = float4(p[0].pos - halfS * right + halfS * up, 1.0f);

					float4x4 vp = mul(UNITY_MATRIX_MVP, _World2Object);
					FS_INPUT pIn;
					pIn.pos = mul(vp, v[0]);
					pIn.tex0 = float2(1.0f, 0.0f);
					triStream.Append(pIn);

					pIn.pos =  mul(vp, v[1]);
					pIn.tex0 = float2(1.0f, 1.0f);
					triStream.Append(pIn);

					pIn.pos =  mul(vp, v[2]);
					pIn.tex0 = float2(0.0f, 0.0f);
					triStream.Append(pIn);

					pIn.pos =  mul(vp, v[3]);
					pIn.tex0 = float2(0.0f, 1.0f);
					triStream.Append(pIn);
				}



				// Fragment Shader -----------------------------------------------
				float4 FS_Main(FS_INPUT input) : COLOR
				{
					float4 tex = _SpriteTex.Sample(sampler_SpriteTex, input.tex0);
					float alpha =  length(input.tex0 - float2(0.5,0.5));
					float mix = 1/(1 + pow(2.718, _Foo*(alpha)));
					float4 answer = float4(_Color.rgb,mix);
//					 answer = tex;
					return answer;
				}

			ENDCG
		}
	} 
}


