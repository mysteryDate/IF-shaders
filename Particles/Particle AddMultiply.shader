Shader "Aaron/Particles/Additive-Multiply" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(-10,30.0)) = 1.0
	_Mult ("Multiplier", Range(0,3000)) = 1
	_WaterLine ("Water Line", float) = 1
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend One OneMinusSrcColor
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off

	SubShader {
	
		Stencil {
			Ref 1
			Comp equal
			Pass keep
		}
	
		// Base lighting
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD2;
				#endif
				float4 posWorld : TEXCOORD3;
			};

			float4 _MainTex_ST;
			float4x4 _Camera2World;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.posWorld = mul(_Camera2World, v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			float _Mult;
			float _WaterLine;
			
			fixed4 frag (v2f i) : SV_Target
			{
				if(i.posWorld.y > _WaterLine)
					discard;
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif
				
				fixed4 tex = tex2D(_MainTex, i.texcoord);
				fixed4 col;
				col.rgb = tex.rgb * i.color.rgb * 2.0f;
				col.a = (1 - tex.a) * (i.color.a * 2.0f);
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
//				return fixed4(0,0,0,0);
				return col * _Mult;
			}
			ENDCG 
		} // Base Lighting
		
		// Additive lighting
		Pass {
			Tags {"LightMode" = "ForwardAdd"}
			Blend one one
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			
			// Lighting
			float4 _LightColor0;
			float4x4 _LightMatrix0;
			sampler2D _LightTexture0;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD2;
				#endif
				float3 lightCoord : TEXCOORD3;
				float4 posWorld : TEXCOORD4;
			};

			float4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				
				o.posWorld = mul(_Object2World, v.vertex);
//				o.lightCoord = mul(_LightMatrix0, mul(_Object2World, v.vertex)).xyz;
				return o;
			}

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			float _Mult;
			
			fixed4 frag (v2f i) : SV_Target
			{
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif
				
				// Lighting
//				float atten = lerp(1.0, tex2D(_LightTexture0, float2(lightCoord,lightCoord)).r, _WorldSpaceLightPos0.w);
				float3 lightCoord = mul(_LightMatrix0, float4(i.posWorld.xyz, 1)).xyz;
				float atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).a;
//				float atten = 1.0;
				
				float3 diffuseReflection = atten * _LightColor0.xyz;// * max(0.0, dot(normalDirection, lightDirection));
				fixed4 tex = tex2D(_MainTex, i.texcoord);
				fixed4 col;
				col.rgb = tex.rgb * i.color.rgb * 2.0f * diffuseReflection;
				col.a = (1 - tex.a) * (i.color.a * 2.0f) * diffuseReflection;
//				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
//				return col * _Mult;
				return fixed4(0,0,0,0);
			}
			ENDCG 
		} // Additive Lighting
	} 
}
}

