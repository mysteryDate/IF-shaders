Shader "Aaron/Avatar/9back_noHandOcclusion" {
	Properties {
		_BackTex ("Back Texture", 2D) = "BlueSpace" {}
		_BumpTex ("Bumpmap", 2D) = "bump" {}
		_RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
		_RimPower ("Rim Power", Range(0,2)) = 1
		_BumpDepth ("BumpDepth", Range(.00001,3.0)) = 2.2
		_TextureShift ("Texture Shift", Vector) = (0.54,0.7,0,0)
		_TextureScale ("Texture Scale", Vector) = (8.55,27.53,0,0)
		_IFPos ("IF Position", Vector) = (0,0,0,0)
		_WaterHeight ("Water Height", float) = 0
		_WaterTint ("Water Tint", Color) = (1.0,1.0,1.0,1.0)
		[MaterialToggle] _UseUV ("Use UV Map", Float) = 0
	}
	SubShader {
		Tags { "Queue" = "Geometry" "IgnoreProjector" = "True"} 

		// Write 1s to the stencil buffer
		// This keep items from being drawn outside
		Stencil
		{
			Ref 1
			Comp always
			Pass replace
		}

		// Pass one draws only to depth buffer
		// This prevents hand occlusion
		Pass {
			Cull Front
			ZWrite On
			ColorMask 0

			CGPROGRAM 

			#pragma vertex vert 
			#pragma fragment frag

			// Variables
			float4 _IFPos;

			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 cameraPos : TEXCOORD1;
			};

			// vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.posWorld = mul(_Object2World, v.vertex);
				o.cameraPos = _WorldSpaceCameraPos.xyz;
				return o;
			}


			// Fragment function
			float4 frag(vertexOutput i) : COLOR 
			{
				float dist = length( cross(i.posWorld.xyz - _IFPos.xyz, i.posWorld.xyz - i.cameraPos) ) / length (i.cameraPos - i.posWorld.xyz);
				if( length(i.posWorld.xyz - i.cameraPos) < length(_IFPos.xyz - i.cameraPos )) {
					discard;
				}
				// A bright pink just to see if something's wrong
				return float4(1,0,1,1);
			} 

			ENDCG  
		} // Depth buffer pass

		// First pass for base lighting
		// Includes hand occlusion
		Pass {
			Tags { "LightMode" = "ForwardBase"}

			Cull Front // first pass renders only back faces
			ZWrite Off // Don't write to the depth buffer, we already did that
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM 
			
			#pragma vertex vert 
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			// Variables
			uniform sampler2D _BackTex;
			float4 _BackTex_ST;
			uniform sampler2D _BumpTex;
			float _BumpDepth;
			float4 _IFPos;
			float _WaterHeight;
			float4 _WaterTint;
			sampler2D _LightTextureB0;
			
			// Lighting
			float4 _LightColor0;

			//base input structs
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
				float2 tex : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
				float3 binormalDir: TEXCOORD4;
				float4 viewPos : TEXCOORD5;
			};

			// vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				o.normalDir = ( mul( float4(v.normal, 0.0), _World2Object).xyz );
				o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);

				o.posWorld = mul(_Object2World, v.vertex);
				o.tex = TRANSFORM_TEX(v.texcoord, _BackTex);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}


			// Fragment function
			float4 frag(vertexOutput i) : COLOR 
			{
				float atten = 1.0;

				// Normals from bumpmap
				float4 texN = tex2D(_BumpTex, i.tex.xy);
				float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
				localCoords.z = _BumpDepth;
				float3x3 local2WorldTranspose = float3x3(
					i.tangentDir,
					i.binormalDir,
					i.normalDir);
				// We need to negate the normal, because this is the back side
				float3 normalDirection = -normalize( mul(localCoords, local2WorldTranspose));
				
				// Lighting
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));

				// For discarding occluding pixels
				float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
				float alpha = 1;
				float dist = length( cross(i.posWorld.xyz - _IFPos.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld);
				if( length(i.posWorld.xyz - cameraPos.xyz) + 0.5 < length(_IFPos.xyz - cameraPos.xyz )) {
					alpha = dist/2;
				}

				float4 tex = tex2D(_BackTex, i.tex.xy);
				
				if( i.posWorld.y < _WaterHeight ) {
					tex *= _WaterTint;
				}

				return float4(tex.rgb * diffuseReflection, alpha);
			} 

			ENDCG  
		}

		// Second pass for the point light
		Pass {
			Tags { "LightMode" = "ForwardAdd"}
			Blend One One
			Cull Front // first pass renders only back faces
			ZWrite Off // write to the depth buffer, since this side is opaque

			CGPROGRAM 

			#pragma vertex vert 
			#pragma fragment frag
			#include "UnityCG.cginc"

			// Variables
			uniform sampler2D _BackTex;
			float4 _BackTex_ST;
			uniform sampler2D _BumpTex;
			float _BumpDepth;
			
			// Lighting
			float4 _LightColor0;
			float4x4 _LightMatrix0;
			sampler2D _LightTextureB0;
			sampler2D _LightTexture0;

			//base input structs
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
				float2 tex : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
				float3 binormalDir: TEXCOORD4;
				float4 posLight : TEXCOORD5;
			};

			// vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				
				o.normalDir = ( mul( float4(v.normal, 0.0), _World2Object).xyz );
				o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
				
				o.posWorld = mul(_Object2World, v.vertex);
				o.tex = TRANSFORM_TEX(v.texcoord, _BackTex);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.posLight = mul(_LightMatrix0, o.posWorld);
				return o;
			}


			// Fragment function
			float4 frag(vertexOutput i) : COLOR 
			{
				float atten = 1.0;

				// Normals from bumpmap
				float4 texN = tex2D(_BumpTex, i.tex.xy);
				float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
				localCoords.z = _BumpDepth;
				float3x3 local2WorldTranspose = float3x3(
					i.tangentDir,
					i.binormalDir,
					i.normalDir);
				float3 normalDirection = -normalize( mul(localCoords, local2WorldTranspose));

				// Lighting
				float3 vertexToLightSource = float3(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
				float3 lightDirection = normalize( lerp(_WorldSpaceLightPos0.xyz, vertexToLightSource, _WorldSpaceLightPos0.w));
				float lightCoord = pow(i.posLight.z,2);
				atten = lerp(1.0, tex2D(_LightTexture0, float2(lightCoord,lightCoord)).r, _WorldSpaceLightPos0.w);

				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));

				return float4(diffuseReflection, 1);
			} 

			ENDCG  
		} // Additive pass
	} // Subshader
//	Fallback "Diffuse"
}
