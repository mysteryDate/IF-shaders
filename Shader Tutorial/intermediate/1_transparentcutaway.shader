Shader "Aaron/tutorial/intermediate/1_transparentcutaway" {
	Properties {
		_Color("Color", Color) = (0.0,0.0,0.0,0.0)
		_Height ("Cutoff Height", Range(-1.0,1.0)) = 1.0
	}
	SubShader {
		Tags {"Queue" = "Transparent"}
		Pass {
			Cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 _Color;
			float _Height;
			
			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float4 vertPos : TEXCOORD0;
			};
			
			v2f vert(vertexInput v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.vertPos = v.vertex;
				return o;
			}
			
			float4 frag(v2f i) : COLOR {
				if(i.vertPos.y > _Height) {
					discard;
				}
				return _Color;
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
