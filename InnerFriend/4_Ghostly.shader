Shader "Aaron/IF/4_Ghostly" {
	Properties {
	 	_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Color (RGB) Alpha (A)", 2D) = "white" {}
		_AlphaCutoff ("Alpha Cutoff", Range(0.0,1.0)) = 0.5
		
		_BumpTex ("Bumpmap", 2D) = "bump" {}
		_BumpDepth ("Bump Depth", Range(0.0, 2.0)) = 1

		_SpecColor ("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Glossiness ("Smoothness", Range(0.01,1.0)) = 0.5
		_SpecGlossMap("Specular", 2D) = "white" {}

		_RimColor ("Rim Color", Color) = (0.0,0.75,1.0,0.0)
		_RimPower ("Rim Power", Range(0.01,8.0)) = 1.0
	}
	SubShader { // Only one LOD right now, so only one subshader
		// In order to read the stencil buffer, we need to be drawn AFTER the avatar
		Tags { "Queue"="Geometry+1" "RenderType"="Opaque" }

		// Throw out pixels that != 1 in the stencil buffer
		Stencil {
			Ref 1
			Comp equal
			Pass keep
		}		

		Pass { // Base pass
			Tags {"LightMode" = "ForwardBase"}
			
			CGPROGRAM
			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
						
			// Variables
			// Textures
			sampler2D _MainTex;
			sampler2D _BumpTex;
			sampler2D _SpecGlossMap;
			
			float _BumpDepth;
			float4 _Color;
			float _AlphaCutoff;
			// Ligting
			float4 _RimColor;
			float _RimPower;
			float4 _SpecColor;
	  		float _Glossiness;
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

			vertexOutput vert(vertexInput v) {
				vertexOutput o;
				
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
	            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
    	        o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
        	    
            	o.posWorld = mul(_Object2World, v.vertex);
	            o.tex = v.texcoord;
    	        o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        	    return o;
			}
			
			float4 frag(vertexOutput i) : COLOR {
				float atten = 1.0;
	            
	            float4 texN = tex2D(_BumpTex, i.tex.xy);
				float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
//	            localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords);
				localCoords.z = _BumpDepth;

	            float3x3 local2WorldTranspose = float3x3(
	               i.tangentDir,
	               i.binormalDir,
	               i.normalDir);
	            
	            float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));   
	            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
			
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				
				float4 texS = tex2D(_SpecGlossMap, i.tex.xy);
				float3 specularReflection = atten * texS.rgb * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow( max(0.0, dot( reflect( -lightDirection, normalDirection), viewDirection)), _Glossiness);
				
				//Rim Lighting
				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
				float3 rimLighting = pow(rim, _RimPower) * _RimColor * atten;
				
				float3 lightFinal = diffuseReflection + specularReflection + rimLighting + UNITY_LIGHTMODEL_AMBIENT;
            	
            	float4 tex = tex2D(_MainTex, i.tex.xy) * _Color;
            	
            	if(tex.a < _AlphaCutoff) {
            		discard;
            	}
            	
            	return float4(tex.rgb * lightFinal, 1.0);
			}

			ENDCG
		} // Base pass
		
		Pass { // Additive lighting pass, we will need a separate differred lighting pass
			Tags {"LightMode" = "ForwardAdd"}
			Blend one one
			
			
			CGPROGRAM
			#pragma target 3.0
			
			// This line is necessary for attenuation, don't ask why
			#pragma multi_compile_fwdadd_fullshadows
			
			// Actually using the Unity built in pass for this
			#pragma vertex vertForwardAdd
			#pragma fragment fragForwardAdd 
			
			#include "UnityStandardCore.cginc"
			
			ENDCG
		} // Additive Pass
		
		// ------------------------------------------------------------------
		//  Shadow rendering pass
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma target 3.0
			// TEMPORARY: GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
			#pragma exclude_renderers gles
			
			// -------------------------------------


			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma multi_compile_shadowcaster

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster

			#include "UnityStandardShadow.cginc"

			ENDCG
		} // Shadow pass
	} // Subshader
}
