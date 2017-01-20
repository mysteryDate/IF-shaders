Shader "Aaron/Sandbox/3DGhostPlane" {
	Properties {
		_MainTex ("Base (RGBA) Trans (A)", 2D) = "white" {}
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_Alpha ("Alpha", Float) = 0.5
	}
	SubShader {
		Pass {

			CGPROGRAM
				
				//pragmas
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"


				//user defined variables
				uniform float4 _Color;
				uniform float _Alpha;

				sampler2D _MainTex;
				float4 _MainTex_ST;

				//base input structs
				struct vertexInput{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
				};
				struct vertexOutput{
					float4 pos : SV_POSITION;
					half2 texcoord : TEXCOORD0;
				};

				//vetex shader
				vertexOutput vert(vertexInput v) {
					vertexOutput o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}

				//fragment shader	
				float4 frag(vertexOutput i) : COLOR
				{
					float4 col = tex2D(_MainTex, i.texcoord);
					if (col.r + col.g + col.b < _Alpha) {
						discard;
					}
					
					return col;
				}
				
			ENDCG
		}
	} 
//	FallBack "Diffuse"
}

