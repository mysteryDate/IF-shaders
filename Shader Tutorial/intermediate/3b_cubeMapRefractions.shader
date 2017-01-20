Shader "Aaron/tutorial/intermediate/3b CubeMap Refractions" {
	Properties {
		_Cube ("Cube Map", Cube) = "" {}
		_RefractiveIndex ("Refractive Index", float) = 1
	}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			samplerCUBE _Cube;
			float _RefractiveIndex;
			
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
				float3 refractDir = refract(i.viewDir, i.normalDir, 1/_RefractiveIndex);
				
				float4 texC = texCUBE(_Cube, refractDir);
				
				return texC;
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
