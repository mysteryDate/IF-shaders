Shader "Aaron/tutorial/intermediate/5 depth fog" {
	Properties {
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_FogColor ("Fog Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_RangeStart ("Fog Far Distance", Float) = 25
		_RangeEnd ("Fog Close Distance", Float) = 25
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;
			fixed4 _FogColor;
			half _RangeStart;
			half _RangeEnd;
			
			half4 _LightColor0;
			
			struct vertexInput {
				half4 vertex : POSITION;
			};
			struct v2f {
				half4 pos : SV_POSITION;
				half4 posWorld : TEXCOORD0;
			};
			
			v2f vert(vertexInput v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.posWorld = mul(_Object2World, v.vertex);

				return o;
			}
			
			fixed4 frag(v2f i) : COLOR 
			{	
				half dist = distance(i.posWorld, _WorldSpaceCameraPos.xyz);
				fixed distClamp = saturate((dist - _RangeStart)/_RangeEnd);
				

				return fixed4(distClamp *  _FogColor.xyz + _Color.xyz, 1.0);
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
