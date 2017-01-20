// A shader that uses uv2 data to draw world vertex positions to a texture
// To be used with a camera rendering to a texture
Shader "Aaron/Utils/VertexToTexture" {
	Properties {
	}
	SubShader {
		Tags {"Queue" = "Overlay"}
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			struct vertexInput {
				float4 vertex : POSITION;
				float4 uv2 	  : TEXCOORD1; // The second uv set
			};
			struct v2f {
				float4 pos 		: SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};
			
			v2f vert(vertexInput v) {
				v2f o;

				o.pos = float4(v.uv2.x * 2 - 1, v.uv2.y * -2 + 1 , 0, 1);
//				o.worldPos = mul(_Object2World, v.vertex);
				o.worldPos = v.vertex;

				return o;
			}
			
			fixed4 frag(v2f i) : COLOR {
	
				return i.worldPos;
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
