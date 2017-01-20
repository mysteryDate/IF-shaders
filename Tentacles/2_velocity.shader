Shader "Aaron/Tentacle/2_velocity" 
{
	// Bound with the inspector.
 	Properties 
 	{
        _Color ("Main Color", Color) = (0, 1, 1,0.3)
		_VelScale ("Velocity Scale", float) = 1
		_DiffBright ("Diffuse Brightness", float) = 1
    }

	SubShader 
	{
		Tags { "Queue"="Geometry+2" "RenderType"="Opaque" }
		Stencil {
			Ref 1
			Comp equal
			Pass keep
		}

		// Base lighting pass
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			Blend SrcAlpha one

			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			// The same particle data structure used by both the compute shader and the shader.
			struct Particle
			{
				float3 position;
				float3 velocity;
			};
			
			struct appdata_base_compute {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				uint id : SV_VertexID;
				uint inst : SV_InstanceID;
			};
			
			// structure linking the data between the vertex and the fragment shader
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 color : TEXCOORD2;
				float3 velocity : TEXCOORD3;
			};
			
			// The buffer holding the particles shared with the compute shader.
			StructuredBuffer<Particle> particleBuffer;
			
			// Variables from the properties.
			float4 _Color;
			int _strandLength;
			float4 _LightColor0;
			float _VelScale;
			float _DiffBright;

			vertexOutput vert (appdata_base_compute v)
			{
				vertexOutput o;

				v.vertex.xyz = particleBuffer[v.id].position;
				o.velocity = particleBuffer[v.id].velocity;
				
				v.normal = o.velocity;
					
				// position computation
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.posWorld = mul(_Object2World, v.vertex);
				o.normalDir = normalize( mul (float4(v.normal, 0.0), _World2Object).xyz);
				
				return o;
			}

			float4 frag (vertexOutput i) : COLOR
			{
				//vectors
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 lightDirection;
				float atten = 1.0;
				
				//lighting
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz;
				
				float al = length(i.velocity.xyz) * _VelScale;
				
				float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT + _Color * pow(al, _DiffBright);

//				return float4(1,1,1,1);
				return float4(lightFinal, 1);
			}
			
			ENDCG
		
		} // Base lighting pass

		// Additive lighting
		Pass {
			Tags {"LightMode" = "ForwardAdd"}
			Blend one one

			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			// The same particle data structure used by both the compute shader and the shader.
			struct Particle
			{
				float3 position;
				float3 velocity;
			};
			
			struct appdata_base_compute {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				uint id : SV_VertexID;
				uint inst : SV_InstanceID;
			};
			
			// structure linking the data between the vertex and the fragment shader
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 color : TEXCOORD2;
				float4 posLight : TEXCOORD3;
			};
			
			// The buffer holding the particles shared with the compute shader.
			StructuredBuffer<Particle> particleBuffer;
			
			// Variables from the properties.
			float4 _Color;
			int _strandLength;
			float4 _LightColor0;
			float4x4 _LightMatrix0;
			sampler2D _LightTexture0;
			float4 _LightTint;

			vertexOutput vert (appdata_base_compute v)
			{
				vertexOutput o;
			
				v.vertex.xyz = particleBuffer[v.id].position;
				v.normal.xyz = particleBuffer[v.id].velocity;
					
				// position computation
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.posWorld = mul(_Object2World, v.vertex);
				o.normalDir = normalize( mul (float4(v.normal, 0.0), _World2Object).xyz);
				
				o.posLight = mul(_LightMatrix0, v.vertex);
				
				return o;
			}
			
			float4 frag (vertexOutput i) : COLOR
			{
				//vectors
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float atten = 1.0;
				
				float3 lightCoord = mul(_LightMatrix0, float4(i.posWorld.xyz,1)).xyz;
				atten = (tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr)).UNITY_ATTEN_CHANNEL;
				
				//lighting
				float3 vertexToLightSource = float3(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
				float lightTexCoord = abs(i.posLight.z);
				float3 lightDirection = normalize( lerp(_WorldSpaceLightPos0.xyz, vertexToLightSource, _WorldSpaceLightPos0.w));
				
				float3 diffuseReflection = atten * _LightColor0.xyz;
				
				float3 lightFinal = diffuseReflection;

				return float4(lightFinal * _LightTint, 1.0);
			}
			
			ENDCG
		
		} // Additive lighting
	}

	Fallback Off
}
