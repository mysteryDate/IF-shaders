Shader "Aaron/Avatar/10front_multipleSpots" {
	Properties {
		
		
		_Color ("Water Tint", Color) = (1,1,1,1)
		_BumpAmt  ("Water Distortion", Range (0,128)) = 10
		_BumpDepth ("Water Light", Range(-0.9,2.0)) = 2.2
		_BumpTex ("Bumpmap", 2D) = "bump" {}
		
		[HideInInspector]
		 _IFPos0 ("IFPos0", Vector) = (0,0,0,0)
		[HideInInspector] 
		_IFPos1 ("IFPos1", Vector) = (0,0,0,0)
		_SpotRadius0 ("First Transparency Radius", Range(0, 10)) = 2 
		_SpotRadius1 ("Second Transparency Radius", Range(0, 10)) = 2 
		_SpotPower ("Transparency Falloff", Range(0, 10)) = 5
		_BaseAlpha ("Minimum Alpha", Range(0,1)) = 0.2
		_MaxAlpha ("Maximum Alpha", Range(0,1)) = 0.9  
		
		_FrontColor ("Front Color", Color) = (0, 0, 0.24, 0.0) 
		_Size ("Blur Size", Range(0, 20)) = 1
		_BlurPower ("Blur Power", Range(1, 4)) = 1

		_RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
		_RimPower ("Rim Power", Range(0.1,8)) = 0.5

		_GlowColor ("Glow Color", Color) = (0,0,0,0) 
		_GlowTrans ("Glow Transparency", Range(-10,10)) = 0.5
		_Extrude ("Extrude Amout", Range(0,1)) = 0
		
	}
 
Category {
	
CGINCLUDE
	
	#include "UnityCG.cginc"
	
	struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord: TEXCOORD0;
	};  
	struct v2f {
		float4 vertex : POSITION;
		float4 uvgrab : TEXCOORD0;
		float4 posWorld : TEXCOORD1;
	};
	
	float _BlurPower;
	float _Size;
	
	// A list of inner game objects that we want to highlight
	// If this gets unweildy, we can use a texture, but an array will not work
	float4 _IFPos0;
	float4 _IFPos1;
	float _SpotRadius0;
	float _SpotRadius1;
	
	sampler2D _GrabTexture;
	float4 _GrabTexture_TexelSize;

	// Returns distance to the closest IF and transparency radius
	float findClosestIFDistance(float4 posWorld) {
		
		float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
		
		// It would be great to do this in a loop, but again, can't pass array data from unity
		float dist0 = length( cross(posWorld.xyz - _IFPos0.xyz, posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - posWorld);
		float dist1 = length( cross(posWorld.xyz - _IFPos1.xyz, posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - posWorld);
		float minDist = min(dist0, dist1);
		
		return minDist;
	}
		
	v2f vert_blur (appdata_t v) {
		v2f o;
		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
		#else
		float scale = 1.0;
		#endif
		o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
		o.uvgrab.zw = o.vertex.zw;
		o.posWorld = mul(_Object2World, v.vertex);
		return o;
	}
	
	half4 frag_horizontal_blur( v2f i ) : COLOR {
		
	 	float dist = findClosestIFDistance(i.posWorld);
	 	dist = pow(dist, _BlurPower) * _Size;
		half4 sum = half4(0,0,0,0);

		#define GRABPIXEL(weight,kernelx) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x + _GrabTexture_TexelSize.x * kernelx* dist, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight

		sum += GRABPIXEL(0.05, -4.0);
		sum += GRABPIXEL(0.09, -3.0);
		sum += GRABPIXEL(0.12, -2.0);
		sum += GRABPIXEL(0.15, -1.0);
		sum += GRABPIXEL(0.18,  0.0);
		sum += GRABPIXEL(0.15, +1.0);
		sum += GRABPIXEL(0.12, +2.0);
		sum += GRABPIXEL(0.09, +3.0);
		sum += GRABPIXEL(0.05, +4.0);
	 
		return sum;
	}
	
	half4 frag_vertical_blur( v2f i ) : COLOR {

		float dist = findClosestIFDistance(i.posWorld);
	 	dist = pow(dist, _BlurPower) * _Size;
		half4 sum = half4(0,0,0,0);
		
		#define GRABPIXEL(weight,kernely) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _GrabTexture_TexelSize.y * kernely * dist, i.uvgrab.z, i.uvgrab.w))) * weight

		sum += GRABPIXEL(0.05, -4.0);
		sum += GRABPIXEL(0.09, -3.0);
		sum += GRABPIXEL(0.12, -2.0);
		sum += GRABPIXEL(0.15, -1.0);
		sum += GRABPIXEL(0.18,  0.0);
		sum += GRABPIXEL(0.15, +1.0);
		sum += GRABPIXEL(0.12, +2.0);
		sum += GRABPIXEL(0.09, +3.0);
		sum += GRABPIXEL(0.05, +4.0);
	 
		return sum;
	}

ENDCG

	// We must be transparent, so other objects are drawn before this one.
	// We can render opaque because of the grabpasses
	Tags { "Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent" }
	SubShader {
			
		// Horizontal blur
		GrabPass {                     
			Tags { "LightMode" = "Always" }
		}
		Pass {
			Tags { "LightMode" = "Always" }
		 
			CGPROGRAM
			#pragma vertex vert_blur
			#pragma fragment frag_horizontal_blur
			#pragma fragmentoption ARB_precision_hint_fastest

			ENDCG
		}

		// Vertical blur
		GrabPass {                         
			Tags { "LightMode" = "Always" }
		}
		Pass {
			Tags { "LightMode" = "Always" }
		 
			CGPROGRAM
			#pragma vertex vert_blur
			#pragma fragment frag_vertical_blur
			#pragma fragmentoption ARB_precision_hint_fastest
		 
			ENDCG
		}
 
		// Distortion, this is only for the water light effect
		GrabPass {                         
			Tags { "LightMode" = "Always" }
		}
		Pass {
			Tags { "LightMode" = "Always" }
		 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct v2f_bump {
				float4 vertex : POSITION;
				float4 uvgrab : TEXCOORD0;
				float2 uvbump : TEXCOORD1;
				float2 uvmain : TEXCOORD2;
			};
		 
			float _BumpAmt;
			float4 _BumpTex_ST;
			float4 _MainTex_ST;
		 
			v2f_bump vert (appdata_t v) {
				v2f_bump o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
				o.uvgrab.zw = o.vertex.zw;
				o.uvbump = TRANSFORM_TEX( v.texcoord, _BumpTex );
				o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
				return o;
			}
		 
			fixed4 _Color;
			sampler2D _BumpTex;
			sampler2D _MainTex;
		 
			half4 frag( v2f_bump i ) : COLOR {
				// calculate perturbed coordinates
				half2 bump = UnpackNormal(tex2D( _BumpTex, i.uvbump )).rg; // we could optimize this by just reading the x  y without reconstructing the Z
				//half2 bump = tex2D(_BumpTex, i.uvbump).ga;
				float2 offset = bump * _BumpAmt * _GrabTexture_TexelSize.xy;
				i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
			 
				half4 col = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				half4 tint = tex2D( _MainTex, i.uvmain ) * _Color;
			 
				return col * _Color;
				 
			}
			ENDCG
		}

		 // Transparency Layer and ripples layer
		 // If it just black with alpha, turn on the ripples script
		Pass {
			Cull Back // only front facing polygons 
			Blend SrcAlpha OneMinusSrcAlpha // use alpha blending

			CGPROGRAM 

			#pragma vertex vert 
			#pragma fragment frag

			// Variables
			uniform sampler2D _MainTex;
			uniform sampler2D _BumpTex;
			float4 _FrontColor;
			float4 _RimColor;
			float _RimPower;
			float _BumpDepth;
			float _BaseAlpha;
			float _MaxAlpha;   
			float _SpotRadius;
			float _SpotPower;

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
				float4 tex : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
				float3 binormalDir: TEXCOORD4;
			};

			// vertex function
			vertexOutput vert(vertexInput v){
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
			float4 frag(vertexOutput i) : COLOR 
			{
				// Normals for the ripple effect
				float4 texN = tex2D(_BumpTex, i.tex.xy);
				float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
				localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

				float3x3 local2WorldTranspose = float3x3(
					 i.tangentDir,
					 i.binormalDir,
					 i.normalDir);

				localCoords = (localCoords + _BumpDepth * float3(0,0,1)) / (1 + _BumpDepth);
				float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float rim = (1 - dot(normalize(viewDirection), normalDirection));
				float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
				float4 finalColor = _FrontColor + _RimColor * pow(rim, _RimPower);

				// Alpha calculation (based on distance
				float al0 = length( cross(i.posWorld.xyz - _IFPos0.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld) / _SpotRadius0;
				float al1 = length( cross(i.posWorld.xyz - _IFPos1.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld) / _SpotRadius1;
				float al = pow(min(al0, al1), _SpotPower);
				al = clamp(al, _BaseAlpha, _MaxAlpha);

				return float4(finalColor.rgb, al);
			} 
			ENDCG  
		} // Transparency Layer


		// Glow rim
		Pass {

			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
				
			//pragmas
			#pragma vertex vert
			#pragma fragment frag

			//user defined variables
			uniform float4 _Color;
			float _GlowTrans;
			float _Extrude;
			float4 _GlowColor;

			//base input structs
			struct vertexInput{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 col : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float4 normal : TEXCOORD2;
			};

			//vetex shader
			vertexOutput vert(vertexInput v) {
				vertexOutput o;
				o.posWorld = mul(_Object2World, v.vertex);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
				o.normal = normalize( mul( v.normal, _World2Object));
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex) +  normalize(mul(UNITY_MATRIX_MVP, float4(v.normal.xyz, 0))) * _Extrude;// + _Extrude * normalize(mul(_World2Object, v.normal));
				o.col = normalize(mul(UNITY_MATRIX_MVP, v.normal));
				
				return o;
			}

			//fragment shader	
			float4 frag(vertexOutput i) : COLOR
			{
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float rim = 1 - saturate(dot(normalize(viewDirection), i.normal));
				return float4(_GlowColor.rgb, pow(rim, _GlowTrans));
			}
				
			ENDCG

        } // Glow rim
	} // Subshader
	}
	Fallback "Transparent/VertexLit"
}
