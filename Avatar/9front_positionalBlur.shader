Shader "Aaron/Avatar/9front_positionalBlur" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_BumpAmt  ("Water Distortion", Range (0,128)) = 10
		_BumpDepth ("Water Light", Range(-0.9,2.0)) = 2.2
		
		_Size ("Blur Size", Range(0, 20)) = 1
		_BlurPower ("Blur Power", Range(0, 4)) = 1
		[HideInInspector] _IFPos ("IF Position", Vector) = (0,0,0,0)
		_BumpTex ("Bumpmap", 2D) = "bump" {}
		_FrontColor ("Front Color", Color) = (0, 0, 0.24, 0.0)
		_RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
		_RimPower ("Rim Power", Range(0.1,8)) = 0.5
		
		_SpotRadius ("Spot Radius", Range(0, 10)) = 2 
		_SpotPower ("Spot Power", Range(0, 10)) = 5
		_BaseAlpha ("Minimum Alpha", Range(0,1)) = 0.2
		_MaxAlpha ("Maximum Alpha", Range(0,1)) = 0.9   

		_GlowTrans ("Glow Transparency", Range(-10,10)) = 0.5
		_Extrude ("Extrude Amout", Range(0,1)) = 0
		_GlowColor ("Glow Color", Color) = (0,0,0,0)
	}
 
	Category {

		// We must be transparent, so other objects are drawn before this one.
		// We can render opaque because of the grabpasses
		Tags { "Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent" }
		SubShader {
				// Alphatest Greater 0
				// Zwrite off
				

			// Horizontal blur
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
			 
				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord: TEXCOORD0;
				};
			 
				struct v2f {
					float4 vertex : POSITION;
					float4 uvgrab : TEXCOORD0;
					float4 posWorld : TEXCOORD1;
				};
			 
				v2f vert (appdata_t v) {
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
				
				sampler2D _GrabTexture;
				float4 _GrabTexture_TexelSize;
				float _Size;
				float4 _IFPos;
				float _BlurPower;
			 
				half4 frag( v2f i ) : COLOR {
					float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
					
					float dist = length( cross(i.posWorld.xyz - _IFPos.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld);
					
					float dist2 = pow(dist, _BlurPower) * _Size;
				 
					half4 sum = half4(0,0,0,0);

					#define GRABPIXEL(weight,kernelx) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x + _GrabTexture_TexelSize.x * kernelx*dist2, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight

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
			}

			// Vertical blur
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
			 
				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord: TEXCOORD0;
				};
			 
				struct v2f {
					float4 vertex : POSITION;
					float4 uvgrab : TEXCOORD0;
					float4 posWorld : TEXCOORD1;
				};
			 
				v2f vert (appdata_t v) {
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
			 
				sampler2D _GrabTexture;
				float4 _GrabTexture_TexelSize;
				float _Size;
				float4 _IFPos;
				float _BlurPower;
			 
				half4 frag( v2f i ) : COLOR {

					float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
					
					float dist = length( cross(i.posWorld.xyz - _IFPos.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld);
					
					float dist2 = pow(dist, _BlurPower) * _Size;
				 
					half4 sum = half4(0,0,0,0);

					#define GRABPIXEL(weight,kernely) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _GrabTexture_TexelSize.y * kernely*dist2, i.uvgrab.z, i.uvgrab.w))) * weight

					//G(X) = (1/(sqrt(2*PI*deviation*deviation))) * exp(-(x*x / (2*deviation*deviation)))
				 
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
			}
		 
			// Distortion
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
			 
				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord: TEXCOORD0;
				};
			 
				struct v2f {
					float4 vertex : POSITION;
					float4 uvgrab : TEXCOORD0;
					float2 uvbump : TEXCOORD1;
					float2 uvmain : TEXCOORD2;
				};
			 
				float _BumpAmt;
				float4 _BumpTex_ST;
				float4 _MainTex_ST;
			 
				v2f vert (appdata_t v) {
					v2f o;
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
				sampler2D _GrabTexture;
				float4 _GrabTexture_TexelSize;
				sampler2D _BumpTex;
				sampler2D _MainTex;
			 
				half4 frag( v2f i ) : COLOR {
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

			 // Transparency Layer
			Pass {
				Cull Back // second pass renders only front faces 
				// (the "outside")
//				 ZWrite On // Write to depth buffer to occlude particles in opaque bits
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
				float4 _IFPos;
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
//					float3 closestPoint: TEXCOORD5;
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

					float dist = length( cross(i.posWorld.xyz - _IFPos.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld);

					float al = pow(dist / _SpotRadius, _SpotPower);

					al = clamp(al, _BaseAlpha, _MaxAlpha);

					return float4(finalColor.rgb, al);
				} 
				ENDCG  
			} // Transparency Layer


			// Glow rim
			Pass {
				// ZTest Always
				// Cull Front
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
