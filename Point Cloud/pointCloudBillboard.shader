// Reads from a position texture instead of mesh data 
// Meant to used with cavernPointCloud.cs
// Uses the geometry pass, see http://forum.unity3d.com/threads/billboard-geometry-shader.169415/
Shader "Aaron/PointCloud/Billboard" {
	Properties 
	{
		_PosTex ("Pos Tex", 2D) = "" {}
		_Size ("Size", Range(0, 3)) = 0.5
		_Color ("Color", color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" }
		Pass
		{
			Tags { "RenderType"="Opaque" }
			Blend SrcAlpha OneMinusSrcAlpha
			Zwrite Off
			LOD 200
		
			CGPROGRAM
				#pragma target 5.0
				#pragma vertex VS_Main
				#pragma fragment FS_Main
				#pragma geometry GS_Main
				#include "UnityCG.cginc" 
				
				
				float4 _Color;

				// **************************************************************
				// Data structures												*
				// **************************************************************
				struct VS_INPUT
				{
					float4 vertex 	: POSITION;
					float4 texcoord : TEXCOORD0;
					float4 normal 	: NORMAL;
					float4 texcoord2 : TEXCOORD1;	
				};
				
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
				sampler2D _PosTex;

				// **************************************************************
				// Shader Programs												*
				// **************************************************************

				// Vertex Shader ------------------------------------------------
				GS_INPUT VS_Main(VS_INPUT v)
				{
					GS_INPUT output = (GS_INPUT)0;
					
					// Position from teh texture
					float4 pos = tex2Dlod(_PosTex, float4(v.texcoord2.xy, 0, 0));
					pos.w = 1;
					
					output.pos = mul(_Object2World, pos);
					
					output.normal = v.normal;
					output.tex0 = float2(0, 0);

					return output;
				}



				// Geometry Shader -----------------------------------------------------
				// It should be noted that these billboards are always vertical
				[maxvertexcount(4)]
				void GS_Main(point GS_INPUT p[1], inout TriangleStream<FS_INPUT> triStream)
				{
					
					float3 look = normalize(_WorldSpaceCameraPos - p[0].pos);
					float3 up = normalize(cross(look, float3(1, 0, 0)));
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
					float distFromCenter =  length(input.tex0 - float2(0.5,0.5));
					// 2.718 = e, 13 is just a magic number that makes falloff work right (particles look like balls, not squares)
					float mix = 1/(1 + pow(2.718, 13*distFromCenter));
					return float4(_Color.rgb, mix);
				}

			ENDCG
		}
	} 
}


