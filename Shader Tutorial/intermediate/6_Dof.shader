Shader "Aaron/tutorial/intermediate/6 depth of field" {
	Properties {
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BlurTex ("Blur Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_FogColor ("Fog Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_RangeStart ("Fog Far Distance", Float) = 25
		_RangeEnd ("Fog Close Distance", Float) = 25
		_BlurSize ("Blur Size", Range(0,1)) = 1
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _MainTex;
			half4 _MainTex_ST;
			sampler2D _BlurTex;
			half4 _BlurTex_ST;
			fixed4 _Color;
			fixed4 _FogColor;
			half _RangeStart;
			half _RangeEnd;
			half _BlurSize;
			
			half4 _LightColor0;
			
			struct vertexInput {
				half4 vertex : POSITION;
				half4 texcoord : TEXCOORD0;
			};
			struct v2f {
				half4 pos : SV_POSITION;
				half4 posWorld : TEXCOORD0;
				half4 tex : TEXCOORD1;
			};
			
			v2f vert(vertexInput v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.posWorld = mul(_Object2World, v.vertex);

				o.tex = v.texcoord;
				return o;
			}
			
			fixed4 frag(v2f i) : COLOR 
			{	
				half dist = distance(i.posWorld, _WorldSpaceCameraPos.xyz);
				fixed distClamp = saturate((dist - _RangeStart)/_RangeEnd);
				
				fixed4 tex = tex2D(_MainTex, _MainTex_ST.xy * i.tex.xy + _MainTex_ST.zw);
				fixed4 texB = tex2D(_BlurTex, _BlurTex_ST.xy * i.tex.xy + _BlurTex_ST.zw);
				
				fixed4 colorBlur = lerp(tex, texB, distClamp * _BlurSize);

				return fixed4(colorBlur * _Color.xyz + _FogColor * distClamp, 1.0);
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
