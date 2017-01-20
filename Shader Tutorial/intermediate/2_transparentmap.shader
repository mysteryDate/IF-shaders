Shader "Aaron/tutorial/intermediate/2 Transparent Map" {
	Properties {
		_Color("Color", Color) = (0.0,0.0,0.0,0.0)
		_transMap ("Transparency (A)", 2D) = "white" {}
	}
	SubShader {
		Tags {"Queue" = "Transparent"}
		Pass {
			Cull off
			Zwrite off
			Blend srcalpha oneminussrcalpha
//			Blend srcalpha one
//			Blend one oneminussrcalpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 _Color;
			sampler2D _transMap;
			float4 _transMap_ST;
			
			struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD1;
			};
			
			v2f vert(vertexInput v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;
				return o;
			}
			
			float4 frag(v2f i) : COLOR {
				float4 tex = tex2D(_transMap, _transMap_ST.xy * i.tex.xy + _transMap_ST.zw);
				float alpha = tex.a * _Color.a; 
				return float4(_Color.rgb, alpha);
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
