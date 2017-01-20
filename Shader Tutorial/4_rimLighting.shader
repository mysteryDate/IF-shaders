Shader "Aaron/tutorial/4_rimLighting" {
	Properties {
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor ("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Shininess", Float) = 10
		_RimColor ("Rim Color", Color) = (1.0,1.0,1.0,1.0)
		_RimPower ("Rim Power", Range(0.1,10.0)) = 3.0
	}
	SubShader {
		Pass {
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined variables
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform float4 _RimColor;
			uniform float _RimPower;
			
			//Unity defined variables;
			uniform float4 _LightColor0;
//			These are already in unity
//			float4x4 _Object2World;
//			float4x4 _World2Object;
//			float4 _WorldSpaceLightPos0;

			//base input structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
			};
			
			// vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				
				o.posWorld = mul(_Object2World, v.vertex);
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
				
				
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
				
				
				
			}
			
			//fragment function
			float4 frag(vertexOutput i) : COLOR {
			
				//vectors
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 lightDirection;
				float atten = 1.0;
				
				//lighting
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				float3 specularReflection = atten * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow( max(0.0, dot( reflect( -lightDirection, normalDirection), viewDirection)), _Shininess);
				
				//Rim Lighting
				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
				float3 rimLighting = saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower) * _RimColor * atten * _LightColor0.xyz;
				
				float3 lightFinal = diffuseReflection + specularReflection + rimLighting + UNITY_LIGHTMODEL_AMBIENT;


				return float4(lightFinal * _Color.rgb, 1.0);
			}
			
			ENDCG
		}
	}
//	Fallback "Diffuse"
}
