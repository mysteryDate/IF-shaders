Shader "Aaron/Particles/Additive (Soft)" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	_Mult ("Base", Range(0,30)) = 1
	_AddMult ("Additive", Range(0,300)) = 1
	_AddRange ("Additive Range", Range(0,10)) = 1
	[HideInInspector]_WaterHeight ("Water Line", float) = 1
	[MaterialToggle] _HideAbove ("Hide above water", Float) = 1
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend One OneMinusSrcColor
	ColorMask RGB
	Cull Off Lighting Off ZWrite off

	SubShader {
	
		Stencil {
			Ref 1
			Comp equal
			Pass keep
		}
	
		// Base pass
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
			float _WaterHeight;
			float _HideAbove;
			
			fixed4 frag (v2f i) : SV_Target
			{
				if(i.posWorld.y > _WaterHeight && _HideAbove) {
					discard;
				}
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif
				
				half4 col = i.color * tex2D(_MainTex, i.texcoord);
				col.rgb *= col.a;
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
				return col * _Mult;
//				return float4(0,0,0,0);
			}
			ENDCG 
		} // Base pass
		
		// Additive pass
		Pass {
			Tags {"LightMode" = "ForwardAdd"}
		
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
			
			// Lighting
			float4 _LightColor0;
			float4x4 _LightMatrix0;
			sampler2D _LightTextureB0;
			sampler2D _LightTexture0;
			
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
			float _AddMult;
			float _AddRange;
			float _WaterHeight;
			float _HideAbove;
			
			fixed4 frag (v2f i) : SV_Target
			{
				if(i.posWorld.y > _WaterHeight && _HideAbove) {
					discard;
				}
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif
				
				float3 lightCoord = mul(_LightMatrix0, float4(i.posWorld.xyz,1)).xyz;
				float atten = (tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr)).UNITY_ATTEN_CHANNEL;
				atten = pow(atten,_AddRange);
				
				half4 col = i.color * tex2D(_MainTex, i.texcoord);
				col.rgb *= atten * _LightColor0;
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
//				return fixed4(atten, 0, 0, 1) * _Mult;
				return col * _AddMult * col.a ;
			}
			ENDCG 
		} // Additive pass
	} 
}
}

