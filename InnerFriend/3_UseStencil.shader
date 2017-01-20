Shader "Aaron/IF/3_UseStencil" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpTex ("Normalmap", 2D) = "bump" {}
		_SpecColor ("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Specular Power", Float) = 10 
		_RimColor ("Rim Color", Color) = (1.0,1.0,1.0,1.0)
		_RimPower ("Rim Power", Range(0.1,10.0)) = 3.0
	}
	SubShader {
		Tags { "Queue" = "Geometry" "RenderType"="Opaque" }
		
		// Throw out pixels that != 1 in the stencil buffer
		Stencil {
			Ref 1
			Comp equal
			Pass keep
		}
		
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			
			CGPROGRAM
			
			#pragma vertex v2f
			#pragma fragment frag
			
			//Variables
			sampler2D _MainTex;
			sampler2D _BumpTex;
			// Lighting
			// Specular
			float4 _SpecColor;
			float _Shininess;
			// Rim
			float4 _RimColor;
			float _RimPower;
			float4 _LightColor0; //This comes from Unity
			
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 tex : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
            	float3 binormalDir: TEXCOORD4;
			};
			
			// Vertex function
			vertexOutput v2f(vertexInput v) {
				vertexOutput o;
				
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
	            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
    	        o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
        	    
            	o.posWorld = mul(_Object2World, v.vertex);
	            o.tex = v.texcoord;
    	        o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        	    return o;
			}
			
			// Fragment function
			float4 frag(vertexOutput i) : COLOR {
			
	            float atten = 1.0;
	            
	            float4 texN = tex2D(_BumpTex, i.tex.xy);
				float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
	            // TODO: attach a slider to this and see what happens
	            localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords);
//				localCoords.z = _BumpDepth;

	            float3x3 local2WorldTranspose = float3x3(
	               i.tangentDir,
	               i.binormalDir,
	               i.normalDir);

//        	    float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));
				float3 normalDirection = i.normalDir;
            	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
            	
				//lighting
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				float3 specularReflection = atten * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow( max(0.0, dot( reflect( -lightDirection, normalDirection), viewDirection)), _Shininess);
				
				//Rim Lighting
				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
				float3 rimLighting = saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower) * _RimColor * atten * _LightColor0.xyz;
				
				float3 lightFinal = diffuseReflection + specularReflection + rimLighting + UNITY_LIGHTMODEL_AMBIENT;
//				lightFinal = diffuseReflection;
            	
            	float4 tex = tex2D(_MainTex, i.tex.xy);
            	
            	return float4(tex.rgb * lightFinal, 1.0);
			}
			ENDCG
		}
		Pass {  // 2nd pass for ligting
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			
			CGPROGRAM
			
			#pragma vertex v2f
			#pragma fragment frag
			
			//Variables, no need for main tex
			sampler2D _BumpMap;
			// Lighting
			// Specular
			float4 _SpecColor;
			float _Shininess;
			// Rim
			float4 _RimColor;
			float _RimPower;
			float4 _LightColor0; //This comes from Unity
			
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 tex : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
            	float3 binormalDir: TEXCOORD4;
			};
			
			// Vertex function
			vertexOutput v2f(vertexInput v) {
				vertexOutput o;
				
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
	            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
    	        o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
        	    
            	o.posWorld = mul(_Object2World, v.vertex);
	            o.tex = v.texcoord;
    	        o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        	    return o;
			}
			
			// Fragment function
			float4 frag(vertexOutput i) : COLOR {
			
	            float atten = 1.0;
	            float3 lightDirection;
	            
//				if(_WorldSpaceLightPos0.w == 0.0) // directional light 
//				{
//					atten = 1.0; // Light does not attenuate
//					lightDirection = normalize(_WorldSpaceLightPos0.xyz); 
//				}
//				else { // Point lights
//					float3 vertexToLightSource = float3(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
//					float distance = length(vertexToLightSource);
//					atten = 1.0/distance;
//					lightDirection = normalize(vertexToLightSource);
//				}			

				// Optimize code above without if statement
				// Takes advantage of the fact that _WorldSpaceLightPos0.w will only ever be 1 or 0
				float3 vertexToLightSource = float3(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
				float distance = length(vertexToLightSource);
				lightDirection = normalize( lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
				atten = lerp(1.0, 1.0/distance, _WorldSpaceLightPos0.w);

        	    float3 normalDirection = i.normalDir;
            	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
            	
				//lighting
				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				float3 specularReflection = atten * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow( max(0.0, dot( reflect( -lightDirection, normalDirection), viewDirection)), _Shininess);
				
				//Rim Lighting
				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
				float3 rimLighting = saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower) * _RimColor * atten * _LightColor0.xyz;
				
				float3 lightFinal = diffuseReflection + specularReflection + rimLighting + UNITY_LIGHTMODEL_AMBIENT;          	
            	
            	return float4(lightFinal, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}