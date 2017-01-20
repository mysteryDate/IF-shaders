Shader "Aaron/tutorial/1_flat_color" {
	Properties {
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader {
		Pass {
			CGPROGRAM
			
			//pragmas
			#pragma vertex vert
			#pragma fragment frag

			//user defined variables
			uniform float4 _Color;

			//base input structs
			struct vertexInput{
				float4 vertex : POSITION;
				
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 col : TEXCOORD0;
			};

			//vetex shader
			vertexOutput vert(vertexInput v) {
				vertexOutput o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.col = v.vertex;
				return o;
			}

			//fragment shader	
			float4 frag(vertexOutput i) : COLOR
			{
				return _Color;
			}
			
			ENDCG
		}
	}
	// Fallback commented out during development
//	Fallback "Diffuse"
}
