Shader "Aaron/tutorial/intermediate/3a Cube map reflections" {
	Properties {
		_Cube ("Cube Map", Cube) = "" {}
	}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			samplerCUBE _Cube;
			
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float3 normalDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			};
			
			v2f vert(vertexInput v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
				o.viewDir = (mul(_Object2World, v.vertex) - _WorldSpaceCameraPos).xyz;
				
				return o;
			}
			
			float4 frag(v2f i) : COLOR {
				
				// reflect the ray to get cube coordinates
				float3 reflectDir = reflect(i.viewDir, i.normalDir);
				
				float4 texC = texCUBE(_Cube, reflectDir);
				
				return texC;
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
